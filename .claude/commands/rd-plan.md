---
description: "R&D 정부과제 사업계획서 작성 — 기술/컨텐츠 입력 → 맞춤 목차 → 섹션별 작성 + QA → 기관 양식 기입"
argument-hint: <grant-path> [--section N] [--qa] [--export]
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, WebSearch, WebFetch, Agent, TaskCreate, TaskUpdate
model: opus
---

# /rd-plan — R&D 정부과제 문서 생성 파이프라인

Read the skill at `.claude/skills/rd-plan/SKILL.md` and follow the workflow exactly.

## Arguments

- `<grant-path>`: 과제 폴더 경로 (예: `~/forge-outputs/09-grants/kocca/2026-문화체육관광RD-스타트업혁신성장`)
- `--section N`: 특정 섹션만 작성/재작성
- `--qa`: QA만 실행 (이미 작성된 문서)
- `--export`: 기관 양식 기입 + 출력만

## 실행

1. SKILL.md 읽기
2. `<grant-path>/_grant-info.md` 읽기
3. `section-rules.json` 기반 조건 평가
4. Phase 0~4 순차 실행
