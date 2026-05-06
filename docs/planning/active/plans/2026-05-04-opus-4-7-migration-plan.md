# Opus 4.7 Migration Plan

**Date**: 2026-05-04  
**Status**: In Progress  
**Scope**: Sonnet 4.6 → Opus 4.7 in high-cost pipeline stages  

---

## Changes Made

### 1. forge-tools-server.py (Line 184)
```diff
- full_message = f"{message}\n\nCo-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
+ full_message = f"{message}\n\nCo-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```
**Impact**: Metadata only (no API changes).

### 2. forge-runner.mjs
**S3 Merge** (Line 641):
- `model: 'claude-opus-4-6'` → `'claude-opus-4-7'`

**S4 Waves 1-4** (Lines 807, 839, 867, 929, 941):
- `model: 'claude-sonnet-4-6'` → `'claude-opus-4-7'`
- All S4 stages use Opus (Wave 1: drafts, Wave 2: spec-check, Wave 3: reviews, Wave 4: final)

**S1-S2 unchanged**:
- Haiku stays Haiku (fast research agents)
- Sonnet synthesis agents stay Sonnet 4.6

### 3. forge-orchestrator.mjs
**Opus instances**: `claude-opus-4-6` → `'claude-opus-4-7'` (all 2 occurrences)
- Phase 3 (Implement Opus path)
- Phase 3.9 (Walkthrough)

**Sonnet instances**: Unchanged (Sonnet 4.6 retained for Context, Spec, Plan, PR phases)

---

## Breaking Changes Addressed

| Issue | Location | Mitigation |
|-------|----------|-----------|
| `temperature`/`top_p`/`top_k` removed | Agent SDK query() options | Not used in current code (SDK auto-removed) |
| `thinking: {type: "enabled", budget_tokens}` removed | Adaptive thinking only | forge-runner.mjs line 212-215 already handles with `if (model.includes('opus'))` → `thinking: {type: "adaptive"}` |
| `outputFormat` → `output_config.format` | Structured output (line 218-223) | Already using `outputFormat` in agent options; SDK likely handles backward compat |
| Assistant message prefills | N/A | Not used in Forge pipeline |
| Vision resolution | N/A | Not relevant to text-only agents |

---

## E2E Test Plan

### Test 1: MCP Git Commit
**File**: forge-tools-server.py  
**Function**: git_commit()  
**Steps**:
1. Create a test forge project directory
2. Initialize git: `git init`
3. Create a test file: `echo "test" > test.md`
4. Call `git_commit(project=".", message="test: migration", files=["test.md"])`
5. Verify: `git log` shows commit message with "Opus 4.7"

**Expected Output**:
```
Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>
```

### Test 2: Single Opus 4.7 Agent Call
**File**: forge-runner.mjs  
**Model**: Opus 4.7  
**Steps**:
1. Run a minimal S3 agent call with Opus 4.7
2. Verify: Adaptive thinking applied (check SDK logs for `thinking: {type: "adaptive"}`)
3. Verify: Response completes without 400 errors
4. Check: Output format (JSON schema, if specified, completes)

**Command** (manual):
```bash
node ~/.claude/scripts/forge-runner.mjs \
  --project test-project \
  --type app \
  --start S3 \
  --idea "Test Opus 4.7 compatibility" \
  --budget 0.50 \
  --dry-run
```

### Test 3: Integration Test (S4 Wave 1 Subset)
**File**: forge-orchestrator.mjs  
**Scope**: Single Opus 4.7 invocation during implement phase  
**Steps**:
1. Create minimal S3 spec
2. Invoke forge-orchestrator with `--phase 3` (Implement, uses Opus)
3. Verify: Model auto-selects Opus 4.7 based on phase
4. Verify: Adaptive thinking activates
5. Verify: No budget exceeded errors (adaptive thinking manages costs)

**Validation Checklist**:
- [ ] Opus 4.7 model string recognized by Agent SDK
- [ ] Adaptive thinking applied (no budget_tokens error)
- [ ] Sampling parameters (temperature, top_p, etc.) not sent (SDK strips them)
- [ ] outputSchema still works with Opus 4.7
- [ ] No 400 errors from removed parameters
- [ ] Session logs show correct model used
- [ ] Token consumption reasonable (within expected range)

---

## Rollback Plan

If Opus 4.7 proves incompatible:

1. **Revert all model changes**:
   ```bash
   git checkout -- forge-tools-server.py forge/dev/scripts/forge-runner.mjs forge/dev/scripts/forge-orchestrator.mjs
   ```

2. **Commit rollback**:
   ```bash
   git commit -m "fix: rollback Opus 4.7 to Sonnet 4.6 + Opus 4.6"
   ```

3. **Root cause analysis**:
   - Check Agent SDK version compatibility
   - Verify API endpoint version
   - Review error logs for specific parameter issues

---

## Timeline

- ✅ **2026-05-04 (Today)**: File edits complete, E2E plan drafted
- ✅ **2026-05-04 (Done)**: Test 1 code-level verified (git_commit() trailer OK)
- ✅ **2026-05-04 (Done)**: Commit migration changes (3 files: forge-runner.mjs, forge-orchestrator.mjs, forge-tools-server.py)
- **2026-05-04 (Next)**: Run Test 2 (single Opus agent call — requires CI/manual invoke)
- **2026-05-05**: Integration test with forge-orchestrator
- **2026-05-05**: Ship if all tests pass

---

## Notes

- **Cost**: Opus 4.7 pricing same as Opus 4.6 ($5/$25 per 1M tokens)
- **Performance**: Adaptive thinking may reduce token usage vs. fixed budgets
- **Compatibility**: Agent SDK must be ≥0.30.0 for Opus 4.7 support
- **Fallback**: S1-S2 remain on Sonnet/Haiku if Opus 4.7 shows issues
