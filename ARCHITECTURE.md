# Forge Architecture Descriptor

> 이 파일은 AI 에이전트가 레포를 탐색하기 전 읽어야 할 구조 지도다.
> 탐색 스텝을 줄이는 것이 목적 — 모르는 파일을 열기 전 여기를 먼저 확인한다.

## 레포 역할

Forge는 AI 기반 통합 개발 파이프라인이다. Claude Code가 오케스트레이터이며 산출물은 `~/forge-outputs/`에 저장된다.

## 핵심 경로

| 경로 | 역할 |
|------|------|
| `.claude/rules/` | 전역 행동 규칙 (forge-core.md가 진입점) |
| `.claude/agents/` | 서브에이전트 정의 (`.md` 파일마다 1개 에이전트) |
| `.claude/skills/` | 스킬 정의 (각 폴더 내 `SKILL.md`) |
| `.claude/commands/` | 슬래시 커맨드 래퍼 |
| `.claude/hooks/` | 이벤트 훅 스크립트 |
| `shared/scripts/` | cron/CI 실행 스크립트 |
| `pipeline.md` | 전체 파이프라인 정의 (S1~S5, Phase 1~12) |

## 모델 라우팅

- Lead/오케스트레이션 → `claude-opus-4-7` (effortLevel: high, xhigh for complex)
- 구현/작성 → `claude-sonnet-4-6`
- 탐색/검색 → `claude-haiku-4-5`

## 에이전트 네이밍 규칙

파일명 = 에이전트 ID. `@에이전트명`으로 호출. 접두사:
- `axis-*`: ACHCE 감사 축 에이전트
- `yt-*`: YouTube 분석 파이프라인
- `*-analyst`: 분석 전문 에이전트

## 스킬 찾기

1. 스킬 이름 안다면: `.claude/skills/{이름}/SKILL.md`
2. 모른다면: `.claude/skills.yaml` (전체 목록 + 설명)

## 규칙 읽기 순서

1. `forge-core.md` — Iron Laws, 모델 라우팅, 8-Check 체인
2. `opus-4-7-best-practices.md` — 행동/지식/안전/effort 원칙
3. `forge-planning.md` — 기획 파이프라인 규칙

## 자주 묻는 것

- handover 문서: `프로젝트루트/.claude/handover/YYYY-MM-DD-slug.md`
- 산출물 저장: `~/forge-outputs/` 하위 (forge 레포 내 생성 금지)
- 현재 프로젝트 목록: `~/forge-outputs/forge-workspace.json`
