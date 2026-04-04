# 종합 적용 계획 보고서
> 분석 영상: gstack 완전 분석(QJU), 클로드코드 잘 쓰는 10단계(메이커 에반) | 작성일: 2026-03-30

---

## 핵심 요약
두 영상이 공통으로 지적한 문제는 **MCP 토큰 오버헤드(41%)**와 **context compaction 관리 미흡**이다. gstack의 역할 기반 스킬 패턴은 이미 forge에 구현되어 있으므로 중복 도입 불필요. 실질 개선 대상은 MCP 조건부 활성화(P1)와 세션 관리 가이드화(P2) 두 가지다.

---

## 영상별 주요 인사이트 종합

| 영상 | 핵심 제안 | 우리 시스템 적용 여부 |
|------|---------|:-----------------:|
| gstack 완전 분석 | 역할 기반 15개 슬래시 커맨드로 워크플로우 자동화 | 이미 적용 (forge 스킬 30개+) |
| gstack 완전 분석 | 영속적 브라우저 데몬으로 QA 자동화 | 부분 (stateless playwright만 존재) |
| gstack 완전 분석 | MCP 대신 CLI/스킬로 브라우저 자동화 → 토큰 절약 | 부분 (playwright-cli 존재, persistent 없음) |
| 클로드코드 10단계 | MCP 5개 = 컨텍스트 41% 소비, 미사용 즉시 비활성화 | 미적용 (5개 항시 활성) |
| 클로드코드 10단계 | CLAUDE.md는 짧고 핵심적으로, compaction 시 자동 재로드 | 이미 적용 (패시브 요약 구조) |
| 클로드코드 10단계 | /clear로 컨텍스트 초기화 습관화 | 미적용 (명시 규칙 없음) |

---

## 현재 시스템 대비 갭 분석

| 기능/패턴 | 영상 출처 | 우리 현황 | 갭 | 영향도 | 난이도 |
|----------|---------|---------|:--:|:----:|:----:|
| forge MCP 5개 항시 활성 | 10단계 | 항시 5개 로드 | drawio/replicate/stitch 불필요 시에도 소비 | H | L |
| context compaction 대응 | 10단계 | 가이드 없음 | buffer 33K, 빠른 compaction 발동 | M | L |
| persistent 브라우저 세션 | gstack | stateless playwright | 세션 재사용 없음 | M | M |

---

## 꼭 필요한 적용 항목

### P1 — 이번 주

- **[Forge]** MCP 조건부 활성화: forge .mcp.json에서 drawio, replicate, stitch 제거 → 필요 시 임시 추가
  - 현황: 5개 항시 로드 → 세션 시작 시 ~41% 컨텍스트 고정 소비
  - 변경: sequential-thinking, nano-banana만 상시 유지. drawio/replicate/stitch는 해당 작업 시만 활성화
  - 기대 효과: 세션당 가용 컨텍스트 ~25% 증가, compaction 빈도 감소
  - 검증: 변경 후 `/context`로 MCP 토큰 확인

### P2 — 이번 달

- **[Forge]** 세션 관리 가이드 명문화: forge-core.md에 /clear 사용 기준 추가 (새 작업 시작 시, 이상 동작 시)
- **[Portfolio/GodBlade]** playwright-cli 스킬 storageState 지원 검토: gstack /browse 참고하여 인증 유지 자동화

---

## 제외 항목

| 항목 | 제외 이유 |
|------|---------|
| gstack 전체 설치 | forge 스킬 구조가 이미 gstack 패턴을 구현 중, 중복 도입 불필요 |
| /retro 스킬 신규 개발 | 현재 blocking 없음, 영향도 L |
| Max 플랜 업그레이드 | 소비 패턴 측정 선행 필요, P2 이후 재검토 |
| plan-ceo-review 커맨드 추가 | Forge Phase 3 에이전트 회의가 더 엄밀하게 구현되어 있음 |

---

## 실행 체크리스트

- [ ] forge .mcp.json drawio/replicate/stitch 제거 + `/context` 토큰 확인 (Forge, 30min, P1)
- [ ] forge-core.md /clear 가이드 추가 (Forge, 15min, P2)
- [ ] playwright-cli SKILL.md 검토 → storageState 지원 타당성 판단 (Portfolio, 1h, P2)

---

## 참고 영상

| 영상 | URL | 분석 파일 |
|------|-----|---------|
| 투자사 YC 대표의 클로드코드 설정 공개 \| gstack 완전 분석 | https://youtu.be/0322tGsiauo | `01-research/videos/analyses/2026-03-30-0322tGsiauo-...-analysis.md` |
| 클로드코드 잘 쓰는 10단계 | https://youtu.be/d-iNXwtwdFU | `01-research/videos/analyses/2026-03-30-d-iNXwtwdFU-...-analysis.md` |
| gstack GitHub | https://github.com/garrytan/gstack | — |
| MCP 오버헤드 측정 | https://scottspence.com/posts/optimising-mcp-server-context-usage-in-claude-code | — |
