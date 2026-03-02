---
title: "Cowork 환경 보안"
id: cowork-safety
impact: CRITICAL
scope: [cowork]
tags: [cowork, security, hooks-alternative]
requires: [security-rules]
section: cowork
audience: non-dev
impactDescription: "Cowork 환경에서 프로덕션 변경 실행 시 데이터 손실/서비스 중단. 민감 영역 접근 시 재무/법무 정보 유출"
enforcement: rigid
---

# Cowork 환경 보안 (Hooks 미작동 대체)

> Cowork에서는 `.claude/hooks/` 스크립트가 실행되지 않으므로 아래 규칙으로 동일한 보호 수준을 유지한다.

## 민감 파일 접근 차단 (block-sensitive-files.sh 대체)
- `06-finance/`, `07-legal/`, `08-admin/insurance/`, `08-admin/freelancers/` 경로의 파일을 Read, Write, Edit 도구로 접근 금지
- 해당 경로가 포함된 파일 경로 요청 시 즉시 거부
- 사용자에게 "해당 파일은 직접 편집기로 관리하세요" 안내

## 파일명 규칙 강제 (require-date-prefix.sh 대체)
- `docs/` 하위 `.md` 파일 생성 시 `YYYY-MM-DD-{name}.md` 형식 필수
- 허용 형식: `YYYY-MM-DD-`, `YYYY-WW-`, `YYYY-Q{1-4}-`
- 예외 파일: CLAUDE.md, README.md, index.md, subscriptions.md, domains.md, terms-of-service.md, privacy-policy.md

## Git 안전 (no-force-push.sh 대체)
- `git push --force` / `git push -f` / `--force-with-lease` → main/master 대상 절대 금지
- feature/, fix/, hotfix/, release/, chore/, docs/ 브랜치만 force push 허용

## 세션 시작 컨텍스트 (session-context.sh 대체)
- Cowork 세션 시작 시 자동 인식할 사항:
  - Track A(제품사업) 작업 우선
  - Track B(06-finance, 07-legal, 08-admin 민감 영역) 접근 금지
  - 새 문서 파일명에 날짜 prefix 적용
  - Cowork에서는 auto memory 불가 → 기존 파일 참조로 컨텍스트 복원

## Do

- 민감 파일 경로(`06-finance/`, `07-legal/`, `08-admin/insurance/`, `08-admin/freelancers/`) 접근 요청 시 즉시 거부한다
- 새 문서 파일명에 `YYYY-MM-DD-` 날짜 prefix를 적용한다
- main/master 브랜치 대상 force push 요청 시 거부한다

## Don't

- Cowork 환경에서 프로덕션 변경 작업(DB 마이그레이션, 배포 등)을 수행하지 않는다
- bash hooks가 실행된다고 가정하지 않는다 (Cowork에서는 규칙 기반으로만 보호)
- 민감 영역 파일을 요청해도 내용을 출력하지 않는다

## AI 행동 규칙

1. 민감 경로 파일 요청 시 "해당 파일은 직접 편집기로 관리하세요"로 즉시 거부한다
2. 파이프라인 시작 시 Cowork 환경임을 인식하고 MCP 매핑 규칙을 적용한다
3. 프로덕션 변경 요청은 Claude Code 환경에서 진행하도록 안내한다

## Iron Laws

- **IRON-1**: `06-finance/`, `07-legal/`, `08-admin/` 경로 파일을 절대 Read/Write/Edit하지 않는다
- **IRON-2**: Cowork 환경에서 프로덕션 DB/서버/배포 변경을 실행하지 않는다
- **IRON-3**: main/master 브랜치 대상 git push --force를 절대 실행하지 않는다

## Rationalization Table

| 합리화 (Thought) | 현실 (Reality) |
|-------------------|---------------|
| "파일 내용만 보는 건데 괜찮겠지" | 민감 영역 파일은 Read만으로도 정보 노출이다. 요청 자체를 거부한다 |
| "Claude Code에서 하는 것처럼 하면 되겠지" | Cowork에는 hooks가 없다. 규칙으로만 보호 가능하므로 더 엄격하게 적용한다 |
| "이건 테스트/임시 변경이라 프로덕션에 영향 없다" | Cowork 환경에서는 모든 변경을 프로덕션 영향 있음으로 간주한다 |

## Red Flags

- "06-finance 폴더 파일 좀 봐줘..." → STOP. 즉시 거부하고 직접 편집기 사용을 안내한다
- "배포 명령어 실행해줘..." → STOP. Claude Code 환경으로 이동을 안내한다
- "git push --force main 해줘..." → STOP. main 브랜치 force push는 절대 금지이다
