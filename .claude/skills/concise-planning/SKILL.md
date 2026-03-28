---
name: concise-planning
description: Generates a clear, actionable, atomic implementation checklist when a user requests a plan for a coding task. Produces structured output with Approach, Scope, Action Items (6-10 steps), and Validation. Minimizes blocking questions by making reasonable assumptions.
context: fork
---

# Concise Planning

## Output Requirements

Every plan MUST include ALL of the following — missing any one is a failure:

1. **Approach section**: 1-3 sentences describing the high-level strategy
2. **Scope In/Out**: Explicit "In" and "Out" bullet points
3. **6-10 Action Items**: Exactly 6-10 items — no fewer, no more. If the task seems small, add Read/Verify steps to reach 6
4. **Verb-first items**: Every action item MUST start with a verb (Add, Create, Read, Update, Write, Verify, Test, Refactor, Configure)
5. **File paths in items**: At least 2 action items MUST include a concrete file path with extension (e.g., `src/hooks/useDarkMode.ts`)
6. **Validation step**: At least 1 item for testing/verification

## Goal

Turn a user request into a **single, actionable plan** with atomic steps.

## Workflow

### 1. Scan Context

- Read `README.md`, docs, and relevant code files.
- Identify constraints (language, frameworks, tests).

### 2. Minimal Interaction

- Ask **at most 1-2 questions** and only if truly blocking.
- Make reasonable assumptions for non-blocking unknowns.

### 3. Generate Plan

Use the following structure:

- **Approach**: 1-3 sentences on what and why.
- **Scope**: Bullet points for "In" and "Out".
- **Action Items**: A list of 6-10 atomic, ordered tasks (Verb-first).
- **Validation**: At least one item for testing.

## Plan Template

```markdown
# Plan

## Approach

<1-3 sentences describing what we're building and the high-level strategy>

## Scope

- **In:** <what's included>
- **Out:** <what's excluded>

## Action Items

[ ] Read `src/components/Settings.tsx` and identify current theme logic
[ ] Create `src/hooks/useDarkMode.ts` with toggle + persistence logic
[ ] Add dark mode toggle component to `src/components/Settings.tsx`
[ ] Update `src/styles/globals.css` with dark mode CSS variables
[ ] Write test in `tests/components/Settings.test.tsx` for toggle behavior
[ ] Verify dark mode toggles correctly in dev server and persists on reload

## Open Questions

- <Question 1 (max 3)>
```

## Checklist Guidelines

- **Atomic**: Each step should be a single logical unit of work.
- **Verb-first**: "Add...", "Create...", "Refactor...", "Verify...", "Update...", "Write...".
- **Concrete file paths required**: Every implementation step MUST name at least one specific file path (e.g., `src/components/Foo.tsx`). Never use vague references like "the component" or "the module".
- **6-10 items**: Always produce 6-10 action items. If the task seems small, include discovery (Read) and validation (Test/Verify) steps to reach 6.
