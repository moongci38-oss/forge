---
name: kaizen
description: "Encodes continuous improvement principles (Kaizen, Poka-Yoke, Standardized Work, Just-In-Time) as coding guidelines. Use when improving code quality, refactoring existing code, or discussing process standardization. Guides toward smallest viable change, error-proofing at design time, and YAGNI-based scope control."
context: fork
---

# Kaizen: Continuous Improvement

## Overview

Small improvements, continuously. Error-proof by design. Follow what works. Build only what's needed.

**Core principle:** Many small improvements beat one big change. Prevent errors at design time, not with fixes.

## The Four Pillars

### 1. Continuous Improvement (Kaizen)
- Make smallest viable change that improves quality
- One improvement at a time, verify each before next
- Always leave code better than you found it
- Iterative refinement: work → clear → efficient (not all at once)

### 2. Poka-Yoke (Error Proofing)
- Make errors impossible through type system
- Validate at system boundaries, not everywhere
- Defense in layers: types → validation → guards → error boundaries
- Make invalid states unrepresentable

### 3. Standardized Work
- Follow existing codebase patterns (consistency over cleverness)
- Documentation lives with code
- Automate standards (linters, type checks, CI/CD)
- New pattern only if significantly better

### 4. Just-In-Time (JIT)
- YAGNI: implement only current requirements
- Simplest thing that works first
- Optimize when measured, not assumed
- Abstract only when pattern proven across 3+ cases

## Red Flags

- "I'll refactor it later" (Kaizen violation)
- "Users should just be careful" (Poka-Yoke violation)
- "I prefer to do it my way" (Standardization violation)
- "We might need this someday" (JIT violation)

## Output Requirements

Every kaizen response MUST include ALL of the following — missing any one is a failure:

1. **Name the pillar FIRST**: The very first line MUST be: "**Pillar: [Kaizen|Poka-Yoke|Standardized Work|JIT]**"
2. **Before/After code**: ALWAYS show a `### Before` code block and an `### After` code block — never skip the comparison
3. **Specific references**: Include concrete file names, function names, or variable names — never give abstract advice
4. **Smallest change only**: Propose the single smallest improvement first, not a rewrite

## Mindset

Good enough today, better tomorrow. Repeat.
