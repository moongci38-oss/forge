---
name: kaizen
description: "Guide for continuous improvement, error proofing, and standardization. Use this skill when the user wants to improve code quality, refactor, or discuss process improvements. 코드 개선, 리팩토링, 프로세스 개선, 품질 향상, 표준화"
allowed-tools: "Read, Grep, Glob"
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

## Mindset

Good enough today, better tomorrow. Repeat.
