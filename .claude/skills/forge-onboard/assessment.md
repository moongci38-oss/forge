---
skill: forge-onboard
version: 2
---

# Assessment: forge-onboard

## 테스트 입력

- input_1: "Onboard a new Next.js project at ~/test-project to the Forge pipeline including Inspector Reference setup"
- input_2: "Register an existing Unity game project for Forge Dev workflow — run all 4 phases including Phase 3.5"
- input_3: "Set up Forge integration for a Python FastAPI backend project and deploy rules, templates, and docs structure"

## 평가 기준 (Yes/No)

1. Output MUST execute Phase 1 (forge-sync init) and Phase 2 (forge-sync sync with rules, templates, hooks) in order.
2. Output MUST scaffold Phase 3 artifacts: CLAUDE.md, .specify/constitution.md, .claude/rules/agent-teams.md, and verify.sh.
3. Output MUST execute Phase 3.5 Inspector Reference auto-deployment — copying template to docs/references/inspector-reference.md.
4. Output MUST create the full docs/ folder structure including references/ subfolder.
5. Output MUST complete Phase 4 (forge-workspace.json registration) and display completion checklist.

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상
