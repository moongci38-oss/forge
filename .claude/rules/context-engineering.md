# 컨텍스트 & 하네스 엔지니어링 규칙

## CLAUDE.md 작성 강제

- 새 프로젝트·작업 폴더 진입 시 CLAUDE.md 없으면 **생성 필수**
- 최소 섹션: 목적 / 반드시 지킬 규칙 / 참조 파일
- 하위 `.claude/CLAUDE.md` — scope 전용 컨텍스트. 상위 cascade 상속.
- CLAUDE.md 없는 `.claude/` 작업은 무결성 보장 불가 — 반드시 선행 생성

## .claude/ 폴더 작업 강제

| 작업 | 강제 도구 | 직접 작성 |
|------|-----------|----------|
| 에이전트 생성 | `subagent-creator` 스킬 | 금지 |
| 스킬 생성 | `skill-creator` 스킬 | 금지 |
| rules/*.md | frontmatter(`name/description/type`) | 필수 |
| hooks/*.sh | 파일 상단에 트리거 이벤트·matcher 명시 | 필수 |
| agents/*.md | frontmatter(`name/description/tools/model`) | 필수 |

## 하네스 패턴 강제

| 상황 | 패턴 |
|------|------|
| 버그 수정 | `/pge` 하네스 |
| 복잡한 기획서·다단계 생성 | PGE 또는 Agent Teams |
| 산출물 품질 검증 | Evaluator subagent |
| 대용량 출력 발생 | subagent 격리 (메인 컨텍스트 보호) |
| 독립 병렬 작업 2~3개 | Agent Teams 단일 메시지 스폰 |

**하네스 없이 직접 구현 금지**: 복잡도 높은 작업에서 PGE/Teams 스킵 금지.

## 컨텍스트 토큰 관리

- **70% 소비** → `/compact` 권장 — 캐시 TTL(5분) 안에서 의도적 요약
- **90% 소비** → `/compact` 강제 — 품질 저하 임계점
- Wave 전환·Phase 진입 직전 → 자연 분할점으로 `/compact` 우선
- 세션 재개 → handover 문서 먼저 확인 후 작업 시작

## 컨텍스트 레이어 인식 (L1~L4)

| 레이어 | 위치 | 용도 |
|--------|------|------|
| L1 | CLAUDE.md / rules/ | 항상 로드 (프로젝트 지침) |
| L2 | handover/*.md | 세션 재개 시 읽기 |
| L3 | 기획서·Spec 문서 | 구현 전 확인 |
| L4 | .claude/reference/ | 분석 캐시 (Read on-demand) |

레이어 순서 위반 금지 — L3 없이 L4 참조, L2 없이 구현 시작 금지.

## On-demand 패턴 (cascade 최소화 — P52-D)

**`rules/`** = 모든 세션 자동 cascade. 사용 빈도 **High** (모든 세션 필수)만 위치.
**`rules-on-demand/`** = 자동 cascade 차단. 사용 빈도 **Low/Medium** (작업 트리거 시) 위치.

분류 결정 트리:
- 모든 세션에서 적용? → `rules/`
- 특정 작업 트리거 시만? → `rules-on-demand/`
- 1회용·디버그용? → 미생성

신규 `.md` 추가 시 **cascade 영향 자가 검토 의무**. 의심 시 `rules-on-demand/` 우선.

CLAUDE.md 200줄 초과 시 → 인덱스만 유지 + 상세 룰 = `rules*/` 분리 (CLAUDE.md cascade는 모든 세션 강제).

## 단순 검색 = subagent 위임 (CRITICAL)

**Grep·Glob·find·다중 Read 등 단순 탐색 작업 = subagent 사용 의무.**

- **Why**: 메인 컨텍스트 보호. 검색 결과·중간 파일 read 출력이 메인 윈도우 오염
- **사용 도구**: `Agent` tool with `subagent_type="Explore"` (검색 전용 + 결과 요약)
- **임계값**: 3+ 쿼리 또는 다중 위치 탐색 → 즉시 subagent
- **예외**: 정확한 단일 파일·심볼 (정확 path 알 때) → 직접 Read/grep
- **선례**: Explore agent 1개 audit = 메인 윈도우 ~3K, 직접 했으면 ~30K+ 오염

## 측정 하네스 (P52-D)

| 도구 | 역할 |
|---|---|
| `~/.claude/hooks/session-context-budget.sh` | SessionStart 자동 측정 + 35K 임계값 stderr 경고 |
| `~/.claude/scripts/audit-context-cascade.sh` | 수동 audit, 매트릭스 + 정리 권장 + `~/.claude/cache/` 보고서 |

수동 호출: `bash ~/.claude/scripts/audit-context-cascade.sh [project_path]`

## 메모리 카논

- `~/.claude/projects/*/memory/MEMORY.md` = 인덱스만 (얇게 유지)
- 사용 0회 메모리 = 분기별 archive
- 프로젝트 전용 정보 = 프로젝트 로컬 (`.claude/rules-on-demand/` 또는 `.claude/feedback/`)
- 글로벌 vs 프로젝트 결정 트리: 다른 프로젝트 사용? → 글로벌 / NO → 프로젝트 로컬
