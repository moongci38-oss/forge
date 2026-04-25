#!/usr/bin/env node
/**
 * forge-sync.mjs v1.6.0
 * Forge Dev Global + Project Sync Engine
 *
 * v1.6.0: GitHub Spec Kit migration (GitLab → GitHub)
 *   - github-spec-kit/ → project .github/ + scripts/ (scope: all)
 *   - Override tracking for CI configs, templates, scripts
 *
 * v1.4.0: Global deployment model
 *   - rules, agents, skills, commands, prompts → ~/.claude/ (global, all projects)
 *   - templates → project .specify/templates/ (project-only, scope: all)
 *   - hooks → project .claude/hooks/ (project-only, --include-recommended)
 *   - docs, shared-docs → no longer deployed (reference from ~/forge/dev/ directly)
 *
 * Override tracking:
 *   Only templates use per-project state-based override tracking.
 *   Global components always sync to match source (no override).
 *
 * Installed at: ~/.claude/scripts/forge-sync.mjs
 * Source:       ~/forge/dev/
 * Manifest:     ~/forge/dev/manifest.json
 *
 * Usage:
 *   node ~/.claude/scripts/forge-sync.mjs <command> [args]
 *
 * Commands:
 *   sync [--target <name>] [--include-recommended] [--dry-run]
 *   status [--quiet]
 *   diff [<target>]
 *   list [--workspace <key>]
 *   init <path> --name <name> [--scope all|shared-only] [--description "..."] [--workspace <key>]
 *   remove <name>
 *
 * Exit codes:
 *   0 = Success (or up-to-date)
 *   1 = Error
 *   2 = Out of sync (status --quiet)
 */

import { readFileSync, writeFileSync, mkdirSync, existsSync, readdirSync, copyFileSync, renameSync } from 'node:fs';
import { join, dirname, relative, resolve } from 'node:path';
import { createHash } from 'node:crypto';
import { homedir } from 'node:os';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const HOME = homedir();
const CLAUDE_DIR = join(HOME, '.claude');
const FORGE_DEV_ROOT = join(CLAUDE_DIR, 'forge');
const MANIFEST_PATH = join(FORGE_DEV_ROOT, 'manifest.json');

// Global deployment: forge source → ~/.claude/ (applies to ALL projects)
// NOTE: 'rules' moved to PROJECT_MAPPINGS (dev-only, not for business workspace)
const GLOBAL_MAPPINGS = [
  { src: 'global-rules', dst: 'rules' },
  { src: 'agents',       dst: 'agents' },
  { src: 'skills',       dst: 'skills' },
  { src: 'commands',     dst: 'commands' },
  { src: 'prompts',      dst: 'prompts' },
];

// Global recommended (also to ~/.claude/, skip if file exists)
const GLOBAL_RECOMMENDED_MAPPINGS = [
  { src: 'recommended/skills',   dst: 'skills' },
  { src: 'recommended/commands', dst: 'commands' },
  { src: 'recommended/prompts',  dst: 'prompts' },
];

// Project-only deployment (scope: all targets only)
const PROJECT_MAPPINGS = [
  { src: 'rules',     dst: '.claude/rules' },  // Forge Dev dev rules → project .claude/rules/
  { src: 'templates', dst: '.specify/templates' },
  { src: 'github-spec-kit/workflows', dst: '.github/workflows' },
  { src: 'github-spec-kit/issue-templates', dst: '.github/ISSUE_TEMPLATE' },
  { src: 'github-spec-kit/mr-template', dst: '.github' },
  { src: 'github-spec-kit/scripts', dst: 'scripts' },
];

// Project-only recommended (hooks are project-specific)
const PROJECT_RECOMMENDED_MAPPINGS = [
  { src: 'recommended/hooks', dst: '.claude/hooks' },
];

// Override policy: templates + github-spec-kit use state-based tracking
const OVERRIDE_CATEGORIES = new Set([
  'templates',
  'github-spec-kit/workflows',
  'github-spec-kit/issue-templates',
  'github-spec-kit/mr-template',
  'github-spec-kit/scripts',
]);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function loadManifest() {
  if (!existsSync(MANIFEST_PATH)) {
    console.error('Error: manifest.json not found at', MANIFEST_PATH);
    process.exit(1);
  }
  return JSON.parse(readFileSync(MANIFEST_PATH, 'utf8'));
}

function saveManifest(manifest) {
  const content = JSON.stringify(manifest, null, 2) + '\n';
  const tmpPath = MANIFEST_PATH + '.tmp';
  writeFileSync(tmpPath, content, 'utf8');
  renameSync(tmpPath, MANIFEST_PATH);
}

function fileHash(filePath) {
  if (!existsSync(filePath)) return null;
  const content = readFileSync(filePath);
  return createHash('sha256').update(content).digest('hex').slice(0, 12);
}

function ensureDir(dirPath) {
  if (!existsSync(dirPath)) {
    mkdirSync(dirPath, { recursive: true });
  }
}

function collectFiles(dirPath, basePath = dirPath) {
  const files = [];
  if (!existsSync(dirPath)) return files;

  for (const entry of readdirSync(dirPath, { withFileTypes: true })) {
    const fullPath = join(dirPath, entry.name);
    if (entry.isDirectory()) {
      files.push(...collectFiles(fullPath, basePath));
    } else {
      files.push(relative(basePath, fullPath).replace(/\\/g, '/'));
    }
  }
  return files;
}

function normalPath(p) {
  return p.replace(/\\/g, '/');
}

// ---------------------------------------------------------------------------
// Sync State (per-project override tracking — templates only)
// ---------------------------------------------------------------------------

function getSyncStatePath(projectPath) {
  return join(projectPath, '.claude', 'forge-sync-state.json');
}

function loadSyncState(projectPath) {
  const statePath = getSyncStatePath(projectPath);
  if (!existsSync(statePath)) return { version: '1.0.0', files: {} };
  try {
    return JSON.parse(readFileSync(statePath, 'utf8'));
  } catch {
    return { version: '1.0.0', files: {} };
  }
}

function saveSyncState(projectPath, state, dryRun) {
  if (dryRun) return;
  const statePath = getSyncStatePath(projectPath);
  ensureDir(dirname(statePath));
  const content = JSON.stringify(state, null, 2) + '\n';
  const tmpPath = statePath + '.tmp';
  writeFileSync(tmpPath, content, 'utf8');
  renameSync(tmpPath, statePath);
}

// ---------------------------------------------------------------------------
// Global Sync (no override tracking — always match source)
// ---------------------------------------------------------------------------

function syncGlobal(mappings, dryRun, isRecommended) {
  let copied = 0, upToDate = 0;

  for (const mapping of mappings) {
    const srcDir = join(FORGE_DEV_ROOT, mapping.src);
    if (!existsSync(srcDir)) continue;

    const dstDir = join(CLAUDE_DIR, mapping.dst);
    ensureDir(dstDir);
    const files = collectFiles(srcDir);

    for (const relFile of files) {
      const srcFile = join(srcDir, relFile);
      const dstFile = join(dstDir, relFile);

      const srcHash = fileHash(srcFile);
      const dstHash = fileHash(dstFile);

      // Recommended: skip if already exists
      if (isRecommended && dstHash) {
        upToDate++;
        continue;
      }

      if (srcHash === dstHash) {
        upToDate++;
        continue;
      }

      if (!dryRun) {
        ensureDir(dirname(dstFile));
        copyFileSync(srcFile, dstFile);
      }

      const action = dstHash ? '↻' : '+';
      console.log(`  ${action} ~/.claude/${mapping.dst}/${relFile}`);
      copied++;
    }
  }

  return { copied, upToDate };
}

// ---------------------------------------------------------------------------
// Project Sync (templates with override tracking)
// ---------------------------------------------------------------------------

function syncProject(mappings, projectPath, dryRun, isRecommended, syncState) {
  let copied = 0, skipped = 0, upToDate = 0, autoUpdated = 0;

  for (const mapping of mappings) {
    const srcDir = join(FORGE_DEV_ROOT, mapping.src);
    if (!existsSync(srcDir)) continue;

    const files = collectFiles(srcDir);
    const category = mapping.src.replace('recommended/', '');

    for (const relFile of files) {
      const srcFile = join(srcDir, relFile);
      const dstFile = join(projectPath, mapping.dst, relFile);
      const stateKey = normalPath(join(mapping.dst, relFile));

      const srcHash = fileHash(srcFile);
      const dstHash = fileHash(dstFile);
      let isAutoUpdate = false;

      // Override tracking: templates only
      if (OVERRIDE_CATEGORIES.has(category) && dstHash) {
        if (srcHash === dstHash) {
          syncState.files[stateKey] = srcHash;
          upToDate++;
          continue;
        }

        const deployedHash = syncState.files[stateKey];
        if (deployedHash && dstHash === deployedHash) {
          isAutoUpdate = true;
        } else {
          if (!deployedHash) {
            syncState.files[stateKey] = dstHash;
          }
          console.log(`  ⏭ ${normalPath(relative(projectPath, dstFile))} (project override)`);
          skipped++;
          continue;
        }
      }

      // Recommended: skip if file already exists
      if (isRecommended && dstHash) {
        upToDate++;
        continue;
      }

      if (srcHash === dstHash) {
        syncState.files[stateKey] = srcHash;
        upToDate++;
        continue;
      }

      if (!dryRun) {
        ensureDir(dirname(dstFile));
        copyFileSync(srcFile, dstFile);
      }
      syncState.files[stateKey] = srcHash;

      if (isAutoUpdate) {
        console.log(`  ↻ ${normalPath(relative(projectPath, dstFile))} (auto)`);
        autoUpdated++;
      } else {
        const action = dstHash ? '↻' : '+';
        console.log(`  ${action} ${normalPath(relative(projectPath, dstFile))}`);
        copied++;
      }
    }
  }

  return { copied, skipped, upToDate, autoUpdated };
}

// ---------------------------------------------------------------------------
// Commands
// ---------------------------------------------------------------------------

function cmdSync(args) {
  const manifest = loadManifest();
  const targetName = getArg(args, '--target');
  const includeRecommended = args.includes('--include-recommended');
  const dryRun = args.includes('--dry-run');

  let totalCopied = 0, totalSkipped = 0, totalUpToDate = 0, totalAutoUpdated = 0;

  // 1. Global sync → ~/.claude/ (always, regardless of --target)
  console.log('\n🌐 Global Sync → ~/.claude/');
  const globalResult = syncGlobal(GLOBAL_MAPPINGS, dryRun, false);
  totalCopied += globalResult.copied;
  totalUpToDate += globalResult.upToDate;

  if (includeRecommended) {
    const recResult = syncGlobal(GLOBAL_RECOMMENDED_MAPPINGS, dryRun, true);
    totalCopied += recResult.copied;
    totalUpToDate += recResult.upToDate;
  }

  // 2. Project sync → templates + hooks (scope: all targets only)
  const targets = targetName
    ? { [targetName]: manifest.targets[targetName] }
    : manifest.targets;

  if (targetName && !manifest.targets[targetName]) {
    console.error(`Error: target '${targetName}' not found in manifest.`);
    console.error('Available targets:', Object.keys(manifest.targets).join(', '));
    process.exit(1);
  }

  for (const [name, config] of Object.entries(targets)) {
    const projectPath = resolve(config.path);
    if (!existsSync(projectPath)) {
      console.warn(`⚠ Target '${name}' path not found: ${projectPath}`);
      continue;
    }

    const scope = config.scope || 'all';
    if (scope === 'shared-only') continue;

    console.log(`\n📦 Project → ${name}`);

    const syncState = loadSyncState(projectPath);

    const projResult = syncProject(PROJECT_MAPPINGS, projectPath, dryRun, false, syncState);
    totalCopied += projResult.copied;
    totalSkipped += projResult.skipped;
    totalUpToDate += projResult.upToDate;
    totalAutoUpdated += projResult.autoUpdated;

    if (includeRecommended) {
      const recResult = syncProject(PROJECT_RECOMMENDED_MAPPINGS, projectPath, dryRun, true, syncState);
      totalCopied += recResult.copied;
      totalSkipped += recResult.skipped;
      totalUpToDate += recResult.upToDate;
      totalAutoUpdated += recResult.autoUpdated;
    }

    saveSyncState(projectPath, syncState, dryRun);
  }

  // Summary
  const parts = [`${totalCopied} copied`];
  if (totalAutoUpdated > 0) parts.push(`${totalAutoUpdated} override auto-updated`);
  if (totalSkipped > 0) parts.push(`${totalSkipped} skipped (customized)`);
  parts.push(`${totalUpToDate} up-to-date`);
  console.log(`\n✅ Sync complete: ${parts.join(', ')}`);
  if (dryRun) console.log('   (dry-run — no files were actually copied)');
}

function cmdStatus(args) {
  const manifest = loadManifest();
  const quiet = args.includes('--quiet');
  let allSynced = true;

  // 1. Global status
  let globalOutOfSync = 0, globalMissing = 0, globalSynced = 0;

  for (const mapping of GLOBAL_MAPPINGS) {
    const srcDir = join(FORGE_DEV_ROOT, mapping.src);
    if (!existsSync(srcDir)) continue;

    const files = collectFiles(srcDir);
    for (const relFile of files) {
      const srcFile = join(srcDir, relFile);
      const dstFile = join(CLAUDE_DIR, mapping.dst, relFile);

      if (!existsSync(dstFile)) {
        globalMissing++;
      } else if (fileHash(srcFile) === fileHash(dstFile)) {
        globalSynced++;
      } else {
        globalOutOfSync++;
      }
    }
  }

  if (!quiet) {
    const status = (globalOutOfSync === 0 && globalMissing === 0) ? '✅' : '⚠';
    console.log(`\n[global] ~/.claude/`);
    console.log(`  ${status} ${globalSynced} synced, ${globalOutOfSync} outdated, ${globalMissing} missing`);
  }

  if (globalOutOfSync > 0 || globalMissing > 0) allSynced = false;

  // 2. Project status (templates only, scope: all)
  const statusLines = [];

  for (const [name, config] of Object.entries(manifest.targets)) {
    const projectPath = resolve(config.path);
    const scope = config.scope || 'all';

    if (scope === 'shared-only') continue;

    if (!existsSync(projectPath)) {
      if (!quiet) statusLines.push({ name, workspace: config.workspace || null, line: `⚠ ${name}: path not found` });
      allSynced = false;
      continue;
    }

    const syncState = loadSyncState(projectPath);
    let outOfSync = 0, missing = 0, synced = 0;

    for (const mapping of PROJECT_MAPPINGS) {
      const srcDir = join(FORGE_DEV_ROOT, mapping.src);
      if (!existsSync(srcDir)) continue;

      const files = collectFiles(srcDir);

      for (const relFile of files) {
        const srcFile = join(srcDir, relFile);
        const dstFile = join(projectPath, mapping.dst, relFile);
        const stateKey = normalPath(join(mapping.dst, relFile));

        if (!existsSync(dstFile)) {
          missing++;
        } else {
          const srcHash = fileHash(srcFile);
          const dstHash = fileHash(dstFile);

          if (srcHash === dstHash) {
            synced++;
          } else if (OVERRIDE_CATEGORIES.has(mapping.src)) {
            const deployedHash = syncState.files[stateKey];
            if (deployedHash && dstHash === deployedHash) {
              outOfSync++;
            } else {
              synced++;  // customized override
            }
          } else {
            outOfSync++;
          }
        }
      }
    }

    if (!quiet) {
      const status = (outOfSync === 0 && missing === 0) ? '✅' : '⚠';
      statusLines.push({
        name,
        workspace: config.workspace || null,
        line: `${status} ${name}: ${synced} synced, ${outOfSync} outdated, ${missing} missing`,
      });
    }

    if (outOfSync > 0 || missing > 0) allSynced = false;
  }

  if (quiet) {
    process.exit(allSynced ? 0 : 2);
  }

  // Group output by workspace
  if (statusLines.length > 0) {
    const workspaces = manifest.workspaces || {};
    const grouped = {};
    const ungrouped = [];

    for (const item of statusLines) {
      if (item.workspace && workspaces[item.workspace]) {
        if (!grouped[item.workspace]) grouped[item.workspace] = [];
        grouped[item.workspace].push(item.line);
      } else {
        ungrouped.push(item.line);
      }
    }

    for (const [wsKey, lines] of Object.entries(grouped)) {
      console.log(`\n[${wsKey}]`);
      for (const line of lines) console.log(`  ${line}`);
    }
    if (ungrouped.length > 0) {
      if (Object.keys(grouped).length > 0) console.log('\n[ungrouped]');
      for (const line of ungrouped) console.log(`  ${line}`);
    }
  }
}

function cmdDiff(args) {
  const targetName = args[0];
  const manifest = loadManifest();

  // No target → show global diff
  if (!targetName) {
    console.log('📊 Diff: forge source vs global (~/.claude/)\n');

    for (const mapping of GLOBAL_MAPPINGS) {
      const srcDir = join(FORGE_DEV_ROOT, mapping.src);
      if (!existsSync(srcDir)) continue;

      const files = collectFiles(srcDir);
      for (const relFile of files) {
        const srcFile = join(srcDir, relFile);
        const dstFile = join(CLAUDE_DIR, mapping.dst, relFile);

        const srcHash = fileHash(srcFile);
        const dstHash = fileHash(dstFile);

        if (!dstHash) {
          console.log(`  + ${mapping.dst}/${relFile} (missing)`);
        } else if (srcHash !== dstHash) {
          console.log(`  ≠ ${mapping.dst}/${relFile} (src=${srcHash} dst=${dstHash})`);
        }
      }
    }
    return;
  }

  // With target → show project diff (templates)
  const config = manifest.targets[targetName];
  if (!config) {
    console.error(`Error: target '${targetName}' not found.`);
    process.exit(1);
  }

  const projectPath = resolve(config.path);
  const syncState = loadSyncState(projectPath);
  console.log(`📊 Diff: forge project files vs ${targetName}\n`);

  for (const mapping of PROJECT_MAPPINGS) {
    const srcDir = join(FORGE_DEV_ROOT, mapping.src);
    if (!existsSync(srcDir)) continue;

    const files = collectFiles(srcDir);

    for (const relFile of files) {
      const srcFile = join(srcDir, relFile);
      const dstFile = join(projectPath, mapping.dst, relFile);
      const stateKey = normalPath(join(mapping.dst, relFile));

      const srcHash = fileHash(srcFile);
      const dstHash = fileHash(dstFile);

      if (!dstHash) {
        console.log(`  + templates/${relFile} (missing in project)`);
      } else if (srcHash !== dstHash) {
        const deployedHash = syncState.files[stateKey];
        if (deployedHash && dstHash === deployedHash) {
          console.log(`  ↻ templates/${relFile} (will auto-update, src=${srcHash} dst=${dstHash})`);
        } else {
          console.log(`  ⏭ templates/${relFile} (customized, src=${srcHash} dst=${dstHash})`);
        }
      }
    }
  }
}

function cmdInit(args) {
  const projectPath = args[0];
  const name = getArg(args, '--name');

  if (!projectPath || !name) {
    console.error('Usage: forge-sync.mjs init <path> --name <name> [--scope all|shared-only] [--description "..."] [--workspace <key>]');
    process.exit(1);
  }

  const resolvedPath = resolve(projectPath);
  if (!existsSync(resolvedPath)) {
    console.error(`Error: path '${resolvedPath}' does not exist.`);
    process.exit(1);
  }

  const manifest = loadManifest();
  if (manifest.targets[name]) {
    console.error(`Error: target '${name}' already exists.`);
    process.exit(1);
  }

  const normalResolved = normalPath(resolvedPath);
  const existingByPath = Object.entries(manifest.targets)
    .find(([, cfg]) => normalPath(resolve(cfg.path)) === normalResolved);
  if (existingByPath) {
    console.error(`Error: path already registered as '${existingByPath[0]}'.`);
    process.exit(1);
  }

  const scope = getArg(args, '--scope') || 'all';
  if (scope !== 'all' && scope !== 'shared-only') {
    console.error(`Error: --scope must be 'all' or 'shared-only' (got '${scope}').`);
    process.exit(1);
  }

  const description = getArg(args, '--description') || '';
  const workspace = getArg(args, '--workspace') || null;

  if (workspace && manifest.workspaces && !manifest.workspaces[workspace]) {
    const available = Object.keys(manifest.workspaces).join(', ');
    console.warn(`⚠ Workspace '${workspace}' not found in manifest. Available: ${available}`);
  }

  const target = { path: normalResolved, scope };
  if (description) target.description = description;
  if (workspace) target.workspace = workspace;

  manifest.targets[name] = target;
  saveManifest(manifest);

  // Generate .specify/config.json if not exists (scope: all only)
  if (scope === 'all') {
    const specifyDir = join(resolvedPath, '.specify');
    const configPath = join(specifyDir, 'config.json');
    if (!existsSync(configPath)) {
      ensureDir(specifyDir);
      const forgeWorkspacePath = join(dirname(dirname(FORGE_DEV_ROOT)), 'forge-workspace.json');
      let tasksDbId = '';
      if (existsSync(forgeWorkspacePath)) {
        try {
          const fw = JSON.parse(readFileSync(forgeWorkspacePath, 'utf8'));
          const tasksUrl = fw.notionDBs?.tasks || '';
          // Extract DB ID from Notion URL
          const match = tasksUrl.match(/([a-f0-9]{32})/);
          if (match) {
            const raw = match[1];
            tasksDbId = `${raw.slice(0,8)}-${raw.slice(8,12)}-${raw.slice(12,16)}-${raw.slice(16,20)}-${raw.slice(20)}`;
          }
        } catch { /* ignore */ }
      }
      const config = {
        projectName: name.charAt(0).toUpperCase() + name.slice(1),
        projectType: 'web',
        notion: {
          projectName: name.charAt(0).toUpperCase() + name.slice(1),
          tasksDbId: tasksDbId,
        },
        autoMerge: false,
      };
      writeFileSync(configPath, JSON.stringify(config, null, 2) + '\n', 'utf8');
      console.log(`  + .specify/config.json (generated — edit projectName/type as needed)`);
    }
  }

  console.log(`✅ Registered '${name}' → ${normalResolved}`);
  if (description) console.log(`   Description: ${description}`);
  if (workspace) console.log(`   Workspace: ${workspace}`);
  console.log(`   Scope: ${scope}`);

  if (scope === 'all') {
    console.log(`\nNext: node ~/.claude/scripts/forge-sync.mjs sync --target ${name} --include-recommended`);
  } else {
    console.log(`\n   scope: shared-only → global components already available, no project sync needed.`);
  }
}

function cmdList(args) {
  const manifest = loadManifest();
  const wsFilter = getArg(args, '--workspace');
  const targets = manifest.targets;
  const workspaces = manifest.workspaces || {};

  if (wsFilter && workspaces[wsFilter] === undefined) {
    console.error(`Error: workspace '${wsFilter}' not found. Available: ${Object.keys(workspaces).join(', ')}`);
    process.exit(1);
  }

  const groups = {};
  const ungrouped = [];

  for (const [name, config] of Object.entries(targets)) {
    const ws = config.workspace;
    if (wsFilter && ws !== wsFilter) continue;
    if (ws && workspaces[ws]) {
      if (!groups[ws]) groups[ws] = [];
      groups[ws].push({ name, config });
    } else {
      if (!wsFilter) ungrouped.push({ name, config });
    }
  }

  const totalShown = Object.values(groups).reduce((s, g) => s + g.length, 0) + ungrouped.length;
  console.log(`\nForge Dev Registered Targets (${totalShown})\n`);

  for (const [wsKey, items] of Object.entries(groups)) {
    const ws = workspaces[wsKey];
    console.log(`[${wsKey}] ${ws.description || wsKey}  (${ws.basePath})`);
    for (const { name, config } of items) {
      const exists = existsSync(resolve(config.path));
      const mark = exists ? '✓' : '✗';
      const missing = exists ? '' : ' [missing]';
      const scopeLabel = config.scope === 'shared-only' ? ' (global-only)' : '';
      console.log(`  ${mark} ${name.padEnd(14)} ${normalPath(config.path)}${missing}${scopeLabel}`);
    }
    console.log('');
  }

  if (ungrouped.length > 0) {
    console.log('[ungrouped]');
    for (const { name, config } of ungrouped) {
      const exists = existsSync(resolve(config.path));
      const mark = exists ? '✓' : '✗';
      const missing = exists ? '' : ' [missing]';
      console.log(`  ${mark} ${name.padEnd(14)} ${normalPath(config.path)}${missing}`);
    }
    console.log('');
  }
}

function cmdRemove(args) {
  const name = args[0];
  if (!name) {
    console.error('Usage: forge-sync.mjs remove <name>');
    process.exit(1);
  }

  const manifest = loadManifest();
  if (!manifest.targets[name]) {
    console.error(`Error: target '${name}' not found.`);
    process.exit(1);
  }

  delete manifest.targets[name];
  saveManifest(manifest);
  console.log(`✅ Removed '${name}' from manifest.`);
}

// ---------------------------------------------------------------------------
// CLI
// ---------------------------------------------------------------------------

function getArg(args, flag) {
  const idx = args.indexOf(flag);
  return idx !== -1 && idx + 1 < args.length ? args[idx + 1] : null;
}

function main() {
  const args = process.argv.slice(2);
  const command = args.shift();

  switch (command) {
    case 'sync':
      cmdSync(args);
      break;
    case 'status':
      cmdStatus(args);
      break;
    case 'diff':
      cmdDiff(args);
      break;
    case 'list':
      cmdList(args);
      break;
    case 'init':
      cmdInit(args);
      break;
    case 'remove':
      cmdRemove(args);
      break;
    default:
      console.log(`Forge Dev Sync Engine v1.6.0 (Global Deployment Model)

Usage: node ~/.claude/scripts/forge-sync.mjs <command>

Commands:
  sync [--target <name>] [--include-recommended] [--dry-run]
                            Deploy: global → ~/.claude/, project files → projects
  status [--quiet]          Check sync status (exit 2 = out of sync)
  diff [<target>]           Show differences (no target = global diff)
  list [--workspace <key>]  List all registered targets
  init <path> --name <name> [--scope all|shared-only] [--description "..."] [--workspace <key>]
                            Register a new project
  remove <name>             Unregister a project

Deployment:
  Global (all projects):  rules, agents, skills, commands, prompts → ~/.claude/
  Project (scope: all):   templates → .specify/templates/
                          gitlab-spec-kit → .gitlab/ + scripts/
  Reference only:         docs, shared-docs → ~/forge/dev/ (not deployed)

Source: ${normalPath(FORGE_DEV_ROOT)}
Manifest: ${normalPath(MANIFEST_PATH)}`);
      process.exit(command ? 1 : 0);
  }
}

main();
