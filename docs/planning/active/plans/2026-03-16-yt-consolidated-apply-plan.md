# [종합] YouTube 분석 적용 계획 — 2026-03-16
> 분석 영상 3개 | 생성일: 2026-03-16

## 분석 영상 목록

| # | 제목 | 채널 | URL |
|:-:|------|------|-----|
| 1 | AI 스킬 9가지… 이거 모르면 내년에 도태됩니다 | 메이커 에반 | https://youtu.be/v8T7u3IJZ7Q |
| 2 | 구글의 새로운 CLI가 Claude Code를 완전히 해금했습니다 | Tech Bridge | https://youtu.be/vLyEv9KNdLE |
| 3 | Google의 새로운 CLI가 Claude Code의 완벽한 보완입니다 | Tech Bridge | https://youtu.be/JErg2lwXHl0 |

---

## 핵심 테마 종합

세 영상의 공통 메시지는 하나다. **AI 도구의 성능보다 사용자의 운용 설계가 생산성을 결정한다.** 영상 1은 개인 레벨에서 AI 협업 스킬(컨텍스트 설계, 기억 관리, 병렬 운용, 큐레이션)을 명시화하고, 영상 2·3은 시스템 레벨에서 Claude Code와 Google Workspace의 실질적 통합 아키텍처를 제시한다.

현재 우리 시스템(SIGIL/Trine)은 개발 영역의 컨텍스트 설계, 병렬 실행, 자동화 파이프라인에서 이미 높은 수준으로 구현되어 있다. 비개발 영역도 SessionStart hook + Auto Memory + Rules-as-Code + Skills의 4-layer 컨텍스트 자동 주입이 동작 중이다. 갭은 **기존 구조의 보완** 수준이다: 비개발 프로젝트 브리프 범용화, 콘텐츠 품질 기준 확장, autoFix 실패 원인 분류, Cowork 병렬 가이드 구체화.

영상 2·3은 동일 채널에서 gwscli를 주제로 제작된 쌍둥이 영상이며, 핵심 행동 요구사항이 완전히 겹친다. 샌드박스 계정 분리, gws-cli 테스트 환경 구축, MCP vs CLI 선택 기준 수립이 그것이다. 두 영상에서 동시에 강조된 항목은 실행 우선순위를 높게 가져간다.

---

## 통합 우선순위 매트릭스

> 중복 제안은 출처 영상을 병기하여 하나로 통합함. 2개 이상 영상에서 겹친 항목은 우선순위 상향 적용.

### P0 — 즉시 실행 (오늘~내일)

| # | 작업 | 출처 | 적용 대상 | 예상 효과 |
|:-:|------|------|-----------|-----------|
| ~~P0-1~~ | ~~**샌드박스 Google 계정 생성 + 접근 범위 선언**~~ | ~~영상 2 + 영상 3~~ | ~~전체 시스템~~ | **[보류]** 현재 외부 협업자/클라이언트 없음. Google Workspace 자동화 실익 부족. Notion+Git으로 충분. 외부 협업 시작 시 재검토 |
| P0-2 | **비개발 프로젝트 컨텍스트 브리프 템플릿 생성** | 영상 1 | SIGIL 파이프라인 | Cowork 세션 초기화 비용 제거. 브랜드·타겟·톤·금지 표현 1회 정의 → 반복 재입력 제거 |

> **기존 구현 현황**: 마케팅 특화 `product-marketing-context` 스킬 존재 + SessionStart hook + Cowork 규칙 구현됨. 범용 프로젝트 브리프(게임/웹 포함) 템플릿만 추가 필요.

**P0-2 실행 상세:**
- `09-tools/templates/project-context-brief.md` 생성 (브랜드·타겟 독자·톤앤매너·차별점·금지 표현 섹션)
- 기존 `product-marketing-context` 스킬을 참조하여 범용화
- `CLAUDE.md`에 "Cowork 세션 시작 시 `project-context-brief.md` 참조" 규칙 한 줄 추가

---

### P1 — 이번 주

| # | 작업 | 출처 | 적용 대상 | 예상 효과 |
|:-:|------|------|-----------|-----------|
| P1-1 | **MCP vs CLI 선택 기준 규칙 명문화** | 영상 2(P2) + 영상 3(P1) ★중복→상향 | SIGIL + Trine 규칙 파일 | 이미 실행 중인 판단(Playwright CLI 전환 등)을 규칙으로 명문화. 소규모 작업 |
| ~~P1-2~~ | ~~**gws-cli 테스트 환경 구축**~~ | ~~영상 2 + 영상 3~~ | ~~SIGIL 자동화~~ | **[보류]** P0-1과 동일 사유. 외부 협업 시작 시 재검토 |
| ~~P1-3~~ | ~~**Model Armor 무료 티어 테스트**~~ | ~~영상 2~~ | ~~Google Workspace 연동~~ | **[보류]** gws-cli 도입 보류에 따라 연동 대상 없음. 외부 데이터 처리 시작 시 재검토 |
| ~~P1-4~~ | ~~**gwscli GitHub Watch 설정**~~ | ~~영상 3~~ | ~~도구 관리~~ | **[보류]** gws-cli 도입 보류에 따라 추적 불필요 |
| P1-5 | **콘텐츠 큐레이션 기준 확장** | 영상 1 | SIGIL S3/S4 콘텐츠 산출물 | `content-creator` 스킬에 SEO 75점+ 등 기본 기준 존재. AI 생성 콘텐츠 검증 절차 + 뉴스레터/기술 문서 기준 확장 |
| P1-6 | **autoFix 실패 원인 분류 enum 추가** | 영상 1 | Portfolio/GodBlade Trine 파이프라인 | 기존 autoFix 카운터(cycle/resolved)에 `failureReason` enum 필드 추가. 소규모 개선 |
| P1-7 | **Cowork 병렬 Task 실행 예시 추가** | 영상 1 | SIGIL Cowork 환경 (비개발자) | `business-core.md`에 매핑 표 존재. 실행 예시 + 의존성 판단 가이드 보강 |

**P1-1 MCP vs CLI 선택 기준 (영상 2·3 통합):**

| 기준 | MCP 선택 | CLI 선택 |
|------|---------|---------|
| 작업 복잡도 | 멀티스텝, 함수 직접 호출 필요 | 단일 명령, 단순 조회/실행 |
| 사용 빈도 | 세션당 1-2회 | 고빈도(일 10회+) |
| 이식성 | 에이전트 플랫폼 고정 가능 | 여러 에이전트/환경 동작 필요 |
| 디버깅 | 에이전트 내 컨텍스트로 추적 | 터미널에서 단독 테스트 |

> ~~P1-2 gws-cli 테스트 환경 구축~~ — **[보류]** 외부 협업 시작 시 재검토

---

### P2 — 이번 달

| # | 작업 | 출처 | 적용 대상 | 예상 효과 |
|:-:|------|------|-----------|-----------|
| ~~P2-1~~ | ~~**리서치 파이프라인 → Google Drive/Docs 자동 저장**~~ | ~~영상 2 + 영상 3~~ | ~~리서치 출력~~ | **[보류]** Notion 자동 업로드로 충분. 외부 공유 필요 시 재검토 |
| ~~P2-2~~ | ~~**gwscli 파일럿 3대 워크플로**~~ | ~~영상 3~~ | ~~Business 전반~~ | **[보류]** gws-cli 도입 보류에 따라 전체 보류 |
| ~~P2-3~~ | ~~**반복 프롬프트 컨텍스트 자동 주입 스크립트**~~ | ~~영상 1~~ | ~~SIGIL 스크립트~~ | **[제거]** Claude Code의 4-layer 자동 주입(SessionStart hook + Auto Memory + Rules + Skills)이 이미 90% 커버. 별도 래퍼 스크립트 실익 부족 |
| ~~P2-4~~ | ~~**Trine 스크립트 JSON 출력 옵션 추가**~~ | ~~영상 3~~ | ~~`run.sh`, `session-state.mjs`~~ | **[제거]** `session-state.mjs`는 이미 전체 JSON 출력 구현됨. `run.sh`는 에이전트가 파싱하지 않아 JSON 불필요 |
| ~~P2-5~~ | ~~**SIGIL Handoff → Trine 컨텍스트 자동 변환 스크립트**~~ | ~~영상 1~~ | ~~GodBlade, Portfolio~~ | **[제거]** 기존 파이프라인(규칙 + sigil-runner.mjs + trine-router + symlink)에서 이미 구현됨 |

**P2-1·P2-2 통합 설계 방향 (영상 2·3 공통):**
- Notion MCP: 구조화된 데이터베이스 + 검색 (현재 주력, 유지)
- Google Drive: 원문 보관 + 외부 공유용 (보조)
- Gmail: 클라이언트/파트너 업데이트 이메일 초안 자동 생성
- Calendar: SIGIL S4 세션 로드맵 마일스톤 자동 등록

**P2-2 gwscli 파일럿 선행 조건:** P0-1(샌드박스 계정) + P1-2(gws-cli 환경) 완료 + gwscli 버그 해결 확인

---

## 프로젝트별 요약

### SIGIL (비개발 파이프라인)

| 우선순위 | 항목 |
|:--------:|------|
| ~~P0~~ | ~~샌드박스 Google 계정 생성 (P0-1)~~ **[보류]** |
| P0 | 비개발 컨텍스트 브리프 템플릿 생성 (P0-2) |
| P1 | MCP vs CLI 선택 기준 규칙 문서화 (P1-1) |
| ~~P1~~ | ~~gws-cli 테스트 환경 구축 (P1-2)~~ **[보류]** |
| ~~P1~~ | ~~Model Armor 무료 티어 테스트 (P1-3)~~ **[보류]** |
| ~~P1~~ | ~~gwscli GitHub Watch 설정 (P1-4)~~ **[보류]** |
| P1 | 콘텐츠 큐레이션 기준 확장 (P1-5) — 기존 content-creator 스킬 기준 보강 |
| P1 | Cowork 병렬 Task 실행 예시 추가 (P1-7) — 기존 매핑 표에 가이드 보강 |
| ~~P2~~ | ~~리서치 파이프라인 → Google Drive 자동 저장 (P2-1)~~ **[보류]** |
| ~~P2~~ | ~~gwscli 파일럿 3대 워크플로 (P2-2)~~ **[보류]** |
| ~~P2~~ | ~~반복 컨텍스트 자동 주입 래퍼 스크립트 (P2-3)~~ **[제거]** 4-layer 자동 주입으로 충분 |


### Trine — Portfolio (Next.js + NestJS)

| 우선순위 | 항목 |
|:--------:|------|
| P1 | autoFix 실패 원인 분류 enum 추가 (P1-6) — 기존 카운터에 `failureReason` 필드 추가 |
| ~~P2~~ | ~~Trine 스크립트 JSON 출력 옵션 추가 (P2-4)~~ **[제거]** session-state.mjs 이미 구현, run.sh 불필요 |
| ~~P2~~ | ~~SIGIL Handoff → Trine 컨텍스트 자동 변환 스크립트 (P2-5)~~ **[제거]** 기존 파이프라인에서 구현됨 |

### Trine — GodBlade (Unity)

| 우선순위 | 항목 |
|:--------:|------|
| P1 | autoFix 실패 원인 분류 enum 추가 (P1-6) — Portfolio와 공유 |
| ~~P2~~ | ~~SIGIL Handoff → Trine 컨텍스트 자동 변환 스크립트 (P2-5)~~ **[제거]** 기존 파이프라인에서 구현됨 |

---

## 위험 요소 및 대응

| 위험 | 가능성 | 대응 |
|------|:------:|------|
| ~~Model Armor 초과 요금~~ | — | **[보류]** gws-cli 도입 보류 |
| ~~gwscli OAuth 설정 복잡도~~ | — | **[보류]** gws-cli 도입 보류 |
| ~~자동화 버그로 이메일 오발송~~ | — | **[보류]** gws-cli 도입 보류 |
| ~~gwscli WSL 호환성 문제~~ | — | **[보류]** gws-cli 도입 보류 |
| ~~gwscli 현재 버그 상태~~ | — | **[보류]** gws-cli 도입 보류 |

---

## 통합 실행 체크리스트

### P0 (오늘~내일)
- ~~[ ] 샌드박스 Google 계정 생성~~ **[보류]**
- ~~[ ] Drive/Gmail/Calendar 접근 범위 선언 및 문서화~~ **[보류]**
- ~~[ ] `security.md` 규칙에 Google 계정 접근 정책 추가~~ **[보류]**
- [ ] `09-tools/templates/project-context-brief.md` 템플릿 생성 (브랜드·타겟·톤·금지사항 포함)
- [ ] `CLAUDE.md`에 Cowork 세션 시작 시 `project-context-brief.md` 참조 규칙 추가

### P1 (이번 주)
- [ ] MCP vs CLI 선택 기준 규칙 명문화 (`09-tools/rules-source/always/` — 기존 판단 문서화)
- [ ] `manage-rules.sh build` 실행 (compiled 규칙 갱신)
- ~~[ ] Google Cloud 프로젝트 생성~~ **[보류]**
- ~~[ ] `npm install -g @googleworkspace/cli`~~ **[보류]**
- ~~[ ] OAuth 클라이언트 ID 설정~~ **[보류]**
- ~~[ ] Gmail API / Drive API / Calendar API 활성화~~ **[보류]**
- ~~[ ] gws-cli 기본 동작 테스트~~ **[보류]**
- ~~[ ] Model Armor API 활성화~~ **[보류]**
- ~~[ ] Model Armor 공식 초과 요금 확인~~ **[보류]**
- ~~[ ] gwscli GitHub 저장소 Watch 설정~~ **[보류]**
- ~~[ ] `weekly-research` 추적 키워드에 `gwscli` 추가~~ **[보류]**
- [ ] `content-creator` 스킬 기준 확장 (AI 검증 절차 + 뉴스레터/기술 문서 기준 추가)
- [ ] `manage-rules.sh build` 실행 (MCP vs CLI + 콘텐츠 기준 반영)
- [ ] `session-state.mjs` autoFix에 `failureReason` enum 필드 추가 (기존 카운터 보강)
- [ ] `business-core.md` Cowork 병렬 매핑에 실행 예시 + 의존성 판단 가이드 추가

### P2 (이번 달)
- ~~[ ] gwscli 안정화 버전 출시 확인~~ **[보류]**
- ~~[ ] gwscli 파일럿 워크플로 1~3번~~ **[보류]**
- ~~[ ] `/daily-system-review` → Google Drive 연동~~ **[보류]**
- ~~[ ] `/weekly-research` → Google Docs 연동~~ **[보류]**
- [ ] MCP vs CLI 선택 기준 CLAUDE.md 최종 반영
- ~~[ ] `scripts/content-gen-wrapper.sh` 반복 콘텐츠 작업용 컨텍스트 자동 주입 래퍼~~ **[제거]** 4-layer 자동 주입으로 충분
- ~~[ ] `scripts/sigil-to-trine-context.sh`~~ **[제거]** 기존 파이프라인에서 구현됨
- ~~[ ] `run.sh` (daily-review) JSON 출력 옵션 추가~~ **[제거]** 에이전트 파싱 사용 사례 없음
- ~~[ ] `run.sh` (weekly-research) JSON 출력 옵션 추가~~ **[제거]** 에이전트 파싱 사용 사례 없음
- ~~[ ] `session-state.mjs` JSON 출력 옵션 추가~~ **[제거]** 이미 전체 JSON 출력 구현됨
- [ ] 전체 파이프라인 비용 모니터링 (30일 후 리뷰)

---

## 다음 리뷰 일정

- **P0 완료 확인**: 2026-03-17
- **P1 완료 확인**: 2026-03-21 (금요일)
- **P2 진행 확인**: 2026-03-31

---

## 참조 문서

| 항목 | 경로 |
|------|------|
| 영상 1 개별 분석 | `01-research/videos/analyses/2026-03-16-v8T7u3IJZ7Q-analysis.md` |
| 영상 2 개별 분석 | `01-research/videos/analyses/2026-03-16-vLyEv9KNdLE-analysis.md` |
| 영상 3 개별 분석 | `01-research/videos/analyses/2026-03-16-JErg2lwXHl0-analysis.md` |
| 영상 1 적용 계획 | `docs/planning/active/plans/2026-03-16-v8T7u3IJZ7Q-apply-plan.md` |
| 영상 2 적용 계획 | `docs/planning/active/plans/2026-03-16-vLyEv9KNdLE-apply-plan.md` |
| 영상 3 적용 계획 | `docs/planning/active/plans/2026-03-16-JErg2lwXHl0-apply-plan.md` |
| 관련 규칙 | `business-core.md` §병렬 실행, `trine-session-state.md`, `security.md` |

*생성일: 2026-03-16 | 대상 영상: v8T7u3IJZ7Q + vLyEv9KNdLE + JErg2lwXHl0*
