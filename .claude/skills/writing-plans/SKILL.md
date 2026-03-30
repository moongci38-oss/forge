---
name: writing-plans
description: "Transforms a spec or requirements document into a comprehensive, bite-sized implementation plan before touching code. Produces TDD-oriented task sequences with exact file paths, step-by-step actions (2-5 minutes each), and explicit test verification steps. Use when starting multi-step implementations with a spec, but before any code changes begin."
context: fork
model: sonnet
---

# Writing Plans

## Output Requirements

Every plan MUST include ALL of the following — missing any one is a failure:

1. **Structured header**: Goal + Architecture + Tech Stack
2. **3+ Tasks**: Each task as a numbered `### Task N: [Name]` section
3. **File paths per task**: Every task MUST list at least 2 concrete file paths with extensions in a `**Files:**` block (e.g., `src/services/comment.service.ts`, `tests/comment.e2e-spec.ts`)
4. **Test steps**: Every task MUST include "Write the failing test" and "Run test" steps
5. **Ordered dependencies**: Tasks MUST be numbered in implementation order

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch for each task, code, testing, docs they might need to check, how to test it. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. Assume they don't know good test design very well.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Save plans to:** `.specify/plans/` or `docs/plans/YYYY-MM-DD-<feature-name>.md`

## Bite-Sized Task Granularity

**Each step is one action (2-5 minutes):**
- "Write the failing test" - step
- "Run it to make sure it fails" - step
- "Implement the minimal code to make the test pass" - step
- "Run the tests and make sure they pass" - step
- "Commit" - step

## Plan Document Header

**Every plan MUST start with this header:**

```markdown
# [Feature Name] Implementation Plan

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

---
```

## Task Structure

```markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file`
- Modify: `exact/path/to/existing`
- Test: `tests/exact/path/to/test`

**Step 1: Write the failing test**
**Step 2: Run test to verify it fails**
**Step 3: Write minimal implementation**
**Step 4: Run test to verify it passes**
**Step 5: Commit**
```

## Remember
- **Exact file paths always** — every task MUST reference at least 2 concrete file paths with extensions (e.g., `src/services/comment.service.ts`, `tests/comment.e2e-spec.ts`)
- Complete code in plan (not "add validation")
- Exact commands with expected output
- DRY, YAGNI, TDD, frequent commits
