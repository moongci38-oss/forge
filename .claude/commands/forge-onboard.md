---
description: 신규 프로젝트를 Forge 파이프라인에 온보딩 — 등록부터 환경 설정까지 4단계 자동화
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Agent
argument-hint: <project-path> --name <name> --type <web|game> [--description "설명"]
---

# /forge-onboard — 신규 프로젝트 온보딩

forge-onboard 스킬을 실행합니다.

## 인자 파싱

사용자가 제공한 인자에서 추출:
- `project-path`: 프로젝트 경로 (필수)
- `--name`: 프로젝트 이름 (필수, kebab-case)
- `--type`: web 또는 game (필수)
- `--description`: 설명 (선택)

누락된 필수 인자는 사용자에게 확인.

## 실행

forge-onboard 스킬의 4단계를 순서대로 실행:

1. **Phase 1**: forge-sync init → manifest 등록
2. **Phase 2**: forge-sync sync → 규칙/템플릿 배포
3. **Phase 3**: 프로젝트 스캐폴딩 (CLAUDE.md, constitution, agent-teams, verify.sh, docs/)
4. **Phase 4**: forge-workspace.json 연결

완료 후 체크리스트로 검증.
