---
skill: forge-onboard
version: 1
---

# Assessment: forge-onboard

## 테스트 입력

- input_1: "Onboard a new Next.js project at ~/test-project to the Forge pipeline"
- input_2: "Register an existing Unity game project for Forge Dev workflow"
- input_3: "Set up Forge integration for a Python FastAPI backend project"

## 평가 기준 (Yes/No)

1. 프로젝트 등록 단계(manifest, forge-workspace.json)가 안내되어 있는가?
2. 규칙/템플릿 배포 계획이 포함되어 있는가?
3. CLAUDE.md 또는 constitution 스캐폴딩이 언급되어 있는가?
4. 프로젝트 경로가 구체적으로 참조되어 있는가?
5. 4단계 온보딩 프로세스가 순서대로 설명되어 있는가?

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상
