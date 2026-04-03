# Claude Code 고도화 비교 분석 리포트
> 분석 영상: gstack 완전 분석 + 클로드코드 10단계 로드맵 | 작성일: 2026-03-30

---

## 개요

두 영상 모두 Claude Code 워크플로우 최적화를 다루며, 서로 보완적인 관점을 제시한다.
- **gstack 영상**: 시스템(스킬 구조, 브라우저 자동화) 관점
- **10단계 영상**: 사용자 역량 개발(학습 순서, 컨텍스트 관리) 관점

---

## 핵심 공통 발견

| 주제 | gstack 영상 | 10단계 영상 | 우리 현황 |
|------|------------|------------|---------|
| MCP 41% 오버헤드 | 브라우저 데몬을 MCP 대신 CLI로 구현하여 우회 | 직접 수치로 제시, 비활성화 권장 | forge 5개 MCP 항시 활성 |
| 스킬 lazy loading | gstack 전체가 스킬 구조 | 토큰 거의 안 먹는 이유로 권장 | 이미 적용 |
| 배포 자동화 | /ship, /land-and-deploy | 언급 | forge-release 스킬 적용 중 |
| 컨텍스트 관리 | CLAUDE.md에 gstack 사용 지침 포함 | CLAUDE.md = 장기 메모리 핵심 | forge-core.md 패시브 요약 적용 |

---

## 우리 시스템 대비 갭 매트릭스

| 기능/패턴 | 영상 출처 | 우리 현황 | 갭 설명 | 영향도 | 난이도 |
|----------|---------|---------|--------|:----:|:----:|
| MCP 조건부 활성화 | 두 영상 공통 | forge 5개 항시 활성 | drawio/replicate/stitch 불필요 시에도 41% 소비 | H | L |
| persistent 브라우저 세션 | gstack /browse | playwright-cli (stateless) | 세션 재사용 없음, 쿠키 수동 관리 | M | M |
| /plan-eng-review 커맨드 | gstack | forge Phase 3 에이전트 회의 | 이미 더 엄밀한 구조로 적용됨 | — | — |
| /retro (스프린트 회고 자동화) | gstack | 미존재 | git log 기반 자동 회고 없음 | L | M |
| autocompact buffer 33K 대응 | 10단계 | /clear 사용 가이드 없음 | buffer가 45K→33K로 감소, 더 빠른 compaction | M | L |
| 작업 단위 쪼개기 습관 | 10단계 | 계획에 있으나 명시 규칙 없음 | 장기 세션에서 compaction 증가 | M | L |

---

## 이미 적용된 항목 (제안에서 제외)

- CLAUDE.md 패시브/딥 로딩 분리 구조 (forge-core.md, forge-planning.md)
- Skills 시스템 30개+ (lazy loading)
- MCP 프로젝트별 분산 (글로벌 2개, Forge 5개)
- 코드 리뷰 에이전트 (code-reviewer-base.md)
- 배포 자동화 (forge-release 스킬)
- 기획 검토 에이전트 회의 (Phase 3 Competing Hypotheses)

---

## 결론

gstack의 핵심 패턴(역할 기반 커맨드, CLAUDE.md 기반 컨텍스트 관리)은 이미 forge에 적용되어 있다. 실질적인 갭은 **MCP 오버헤드(즉시 조치 가능)**와 **playwright 세션 관리(중기 개선)** 두 가지로 좁혀진다.
