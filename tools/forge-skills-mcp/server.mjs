#!/usr/bin/env node
/**
 * Forge Skills MCP Server
 * Exposes Forge skills as MCP tools for IDE/external tool access.
 *
 * Transport: stdio (standard MCP pattern)
 * Registration: add to ~/.claude.json mcpServers as "forge-skills"
 *
 * Each tool:
 *   1. Reads the skill's SKILL.md to get description/frontmatter
 *   2. Returns a formatted claude CLI invocation string
 *   3. Optionally executes it via child_process (if FORGE_MCP_EXECUTE=1)
 */

import { readFileSync, readdirSync, existsSync } from 'fs';
import { resolve, join } from 'path';
import { homedir } from 'os';
import { spawn } from 'child_process';
import { createInterface } from 'readline';

const HOME = homedir();
const SKILL_ROOTS = [
  join(HOME, 'forge/.claude/skills'),
  join(HOME, '.claude/skills'),
];
const EXECUTE = process.env.FORGE_MCP_EXECUTE === '1';
const CLAUDE_BIN = process.env.CLAUDE_BIN || join(HOME, '.local/bin/claude');

// ── skill discovery ────────────────────────────────────────────────────────

function parseSkillMeta(skillDir) {
  const skillMd = join(skillDir, 'SKILL.md');
  if (!existsSync(skillMd)) return null;
  const raw = readFileSync(skillMd, 'utf-8');
  // extract YAML front matter
  const match = raw.match(/^---\n([\s\S]*?)\n---/);
  if (!match) return null;
  const fm = {};
  for (const line of match[1].split('\n')) {
    const [k, ...rest] = line.split(':');
    if (k && rest.length) fm[k.trim()] = rest.join(':').trim().replace(/^["']|["']$/g, '');
  }
  return {
    name: fm.name || null,
    description: fm.description || '',
    argumentHint: fm['argument-hint'] || '',
    userInvocable: fm['user-invocable'] !== 'false',
    model: fm.model || 'sonnet',
    skillMd,
    body: raw.replace(/^---[\s\S]*?---\n/, '').trim(),
  };
}

function discoverSkills() {
  const skills = new Map();
  for (const root of SKILL_ROOTS) {
    if (!existsSync(root)) continue;
    for (const entry of readdirSync(root, { withFileTypes: true })) {
      if (!entry.isDirectory() || entry.name.startsWith('_')) continue;
      const meta = parseSkillMeta(join(root, entry.name));
      if (!meta || !meta.name || !meta.userInvocable) continue;
      if (!skills.has(meta.name)) skills.set(meta.name, meta);
    }
  }
  return skills;
}

// ── MCP protocol (stdio JSON-RPC 2.0) ─────────────────────────────────────

function send(obj) {
  process.stdout.write(JSON.stringify(obj) + '\n');
}

function mcpError(id, code, message) {
  send({ jsonrpc: '2.0', id, error: { code, message } });
}

async function executeSkill(skillName, args) {
  const prompt = args ? `/${skillName} ${args}` : `/${skillName}`;
  return new Promise((resolve, reject) => {
    const proc = spawn(CLAUDE_BIN, ['-p', prompt, '--no-stream'], {
      stdio: ['ignore', 'pipe', 'pipe'],
      env: { ...process.env },
    });
    let out = '';
    let err = '';
    proc.stdout.on('data', d => { out += d; });
    proc.stderr.on('data', d => { err += d; });
    proc.on('close', code => {
      if (code !== 0) reject(new Error(`claude exited ${code}: ${err}`));
      else resolve(out.trim());
    });
  });
}

async function handleRequest(req) {
  const { id, method, params } = req;

  if (method === 'initialize') {
    send({
      jsonrpc: '2.0', id,
      result: {
        protocolVersion: '2024-11-05',
        capabilities: { tools: {} },
        serverInfo: { name: 'forge-skills', version: '1.0.0' },
      },
    });
    return;
  }

  if (method === 'notifications/initialized') return;

  if (method === 'tools/list') {
    const skills = discoverSkills();
    const tools = Array.from(skills.values()).map(s => ({
      name: s.name,
      description: s.description + (s.argumentHint ? `\nArgs: ${s.argumentHint}` : ''),
      inputSchema: {
        type: 'object',
        properties: {
          args: {
            type: 'string',
            description: s.argumentHint || 'Arguments to pass to the skill',
          },
        },
        required: [],
      },
    }));
    send({ jsonrpc: '2.0', id, result: { tools } });
    return;
  }

  if (method === 'tools/call') {
    const toolName = params?.name;
    const args = params?.arguments?.args || '';
    const skills = discoverSkills();
    const skill = skills.get(toolName);

    if (!skill) {
      mcpError(id, -32602, `Unknown skill: ${toolName}`);
      return;
    }

    if (EXECUTE) {
      try {
        const result = await executeSkill(toolName, args);
        send({
          jsonrpc: '2.0', id,
          result: { content: [{ type: 'text', text: result }] },
        });
      } catch (e) {
        mcpError(id, -32603, e.message);
      }
    } else {
      // Return the invocation command + skill description (read-only mode)
      const claudeCmd = args
        ? `claude -p "/${toolName} ${args}"`
        : `claude -p "/${toolName}"`;
      const text = [
        `## Skill: ${toolName}`,
        '',
        skill.description,
        '',
        '### Invocation',
        '```bash',
        claudeCmd,
        '```',
        '',
        '### SKILL.md',
        skill.body.substring(0, 2000),
      ].join('\n');
      send({
        jsonrpc: '2.0', id,
        result: { content: [{ type: 'text', text }] },
      });
    }
    return;
  }

  mcpError(id, -32601, `Method not found: ${method}`);
}

// ── main loop ──────────────────────────────────────────────────────────────

const rl = createInterface({ input: process.stdin, crlfDelay: Infinity });
rl.on('line', async line => {
  if (!line.trim()) return;
  try {
    const req = JSON.parse(line);
    await handleRequest(req);
  } catch (e) {
    send({ jsonrpc: '2.0', id: null, error: { code: -32700, message: 'Parse error' } });
  }
});

process.stderr.write('[forge-skills-mcp] Server started (execute=' + EXECUTE + ')\n');
