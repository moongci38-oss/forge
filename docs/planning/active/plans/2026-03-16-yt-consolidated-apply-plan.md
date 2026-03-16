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

현재 우리 시스템(Trine/SIGIL)은 개발 영역의 컨텍스트 설계, 병렬 실행, 자동화 파이프라인에서 이미 높은 수준으로 구현되어 있다. 갭은 두 곳이다. 첫째, **비개발 영역(마케팅·콘텐츠·리서치)의 컨텍스트 브리프와 콘텐츠 품질 기준**이 미비하다. 둘째, **Claude Code의 Google 계정 접근 범위가 무제한 상태**로 Google 자동화 도구 도입 전 리스크가 방치되어 있다.

영상 2·3은 동일 채널에서 gwscli를 주제로 제작된 쌍둥이 영상이며, 핵심 행동 요구사항이 완전히 겹친다. 샌드박스 계정 분리, gws-cli 테스트 환경 구축, MCP vs CLI 선택 기준 수립이 그것이다. 두 영상에서 동시에 강조된 항목은 실행 우선순위를 높게 가져간다.

---

## 통합 우선순위 매트릭스

> 중복 제안은 출처 영상을 병기하여 하나로 통합함. 2개 이상 영상에서 겹친 항목은 우선순위 상향 적용.

### P0 — 즉시 실행 (오늘~내일)

| # | 작업 | 출처 | 적용 대상 | 예상 효과 |
|:-:|------|------|-----------|-----------|
| P0-1 | **샌드박스 Google 계정 생성 + 접근 범위 선언** | 영상 2 + 영상 3 ★중복 | 전체 시스템 (SIGIL + Trine) | gws-cli/Google MCP 도입 리스크 80% 감소. 현재 메인 계정 무제한 접근 상태 즉시 해소 |
| P0-2 | **비개발 프로젝트 컨텍스트 브리프 템플릿 생성** | 영상 1 | SIGIL 파이프라인 | Cowork 세션 초기화 비용 제거. 브랜드·타겟·톤·금지 표현 1회 정의 → 반복 재입력 제거 |

**P0-1 실행 상세 (영상 2·3 공통 지침 통합):**
1. `ai-agent@gmail.com` 또는 `claude-workspace@gmail.com` 계정 생성
2. 접근 허용 범위 명시적 선언:
   - Drive: 전용 `AI-Workspace/` 폴더만 공유
   - Gmail: 에이전트 전용 레이블/폴더로 격리
   - Calendar: 전용 캘린더만 공유 (메인 캘린더 접근 차단)
3. `09-tools/rules-source/always/security.md`에 Google 계정 접근 정책 추가

**P0-2 실행 상세:**
- `09-tools/templates/project-context-brief.md` 생성 (브랜드·타겟 독자·톤앤매너·차별점·금지 표현 섹션)
- `CLAUDE.md`에 "Cowork 세션 시작 시 `project-context-brief.md` 참조" 규칙 한 줄 추가

---

### P1 — 이번 주

| # | 작업 | 출처 | 적용 대상 | 예상 효과 |
|:-:|------|------|-----------|-----------|
| P1-1 | **MCP vs CLI 선택 기준 규칙 문서화** | 영상 2(P2) + 영상 3(P1) ★중복→상향 | SIGIL + Trine 규칙 파일 | 도구 선택 혼선 방지. 고빈도 단순 작업의 불필요한 토큰 소비 제거 |
| P1-2 | **gws-cli 테스트 환경 구축** | 영상 2(P1) + 영상 3(P2 선행) ★중복→상향 | SIGIL 자동화 파이프라인 | Google Workspace 자동화 기반 마련. P2 파일럿 실행 선행 조건 |
| P1-3 | **Model Armor 무료 티어 테스트** | 영상 2 | Claude Code + Google Workspace 연동 구간 | 프롬프트 인젝션 방어, 외부 데이터 처리 보안 향상 (월 200만 토큰 무료) |
| P1-4 | **gwscli GitHub Watch 설정** | 영상 3 | 도구 관리 | 현재 버그(URL 오타, 토큰 업데이트 이슈) 있는 gwscli 안정화 시점 추적. `weekly-research`에 `gwscli` 키워드 추가 |
| P1-5 | **콘텐츠 큐레이션 기준 문서 초안** | 영상 1 | SIGIL S3/S4 콘텐츠 산출물 | AI 생성 콘텐츠 PASS/FAIL 기준 명시화 (80점 → 95점 끌어올리는 기준선 확보) |
| P1-6 | **autoFix 실패 원인 분류 스키마 설계** | 영상 1 | Portfolio/GodBlade Trine 파이프라인 | "다시 해 줘" 대신 실패 유형 진단 체계화 (`CONTEXT_MISSING` / `DIRECTION_ERROR` / `RULE_CONFLICT`) |
| P1-7 | **Cowork 병렬 Task 가이드 간소화** | 영상 1 | SIGIL Cowork 환경 (비개발자) | 비개발자의 병렬 Task 활용 활성화. 2페이지 레퍼런스 카드 |

**P1-1 MCP vs CLI 선택 기준 (영상 2·3 통합):**

| 기준 | MCP 선택 | CLI 선택 |
|------|---------|---------|
| 작업 복잡도 | 멀티스텝, 함수 직접 호출 필요 | 단일 명령, 단순 조회/실행 |
| 사용 빈도 | 세션당 1-2회 | 고빈도(일 10회+) |
| 이식성 | 에이전트 플랫폼 고정 가능 | 여러 에이전트/환경 동작 필요 |
| 디버깅 | 에이전트 내 컨텍스트로 추적 | 터미널에서 단독 테스트 |

**P1-2 gws-cli 테스트 환경 구축 단계:**
1. Google Cloud Console → 신규 프로젝트 생성 (샌드박스 계정으로)
2. `npm install -g @googleworkspace/cli`
3. OAuth 2.0 클라이언트 ID 발급 (Redirect URI: localhost:5165)
4. Gmail API / Drive API / Calendar API 활성화
5. 기본 동작 테스트: 이메일 읽기, 파일 생성

---

### P2 — 이번 달

| # | 작업 | 출처 | 적용 대상 | 예상 효과 |
|:-:|------|------|-----------|-----------|
| P2-1 | **리서치 파이프라인 → Google Drive/Docs 자동 저장** | 영상 2 + 영상 3 ★중복 | `/daily-system-review`, `/weekly-research` 출력 | Notion MCP + Google Drive 이중 백업. 외부 공유 편의성 향상 |
| P2-2 | **gwscli 파일럿 3대 워크플로** | 영상 3 | Business 전반 | SIGIL→Drive 자동 공유 / Weekly Research→Gmail 초안 / 마일스톤→Calendar 자동 등록 |
| P2-3 | **반복 프롬프트 컨텍스트 자동 주입 스크립트** | 영상 1 | SIGIL 스크립트 | `scripts/content-gen-wrapper.sh` — 반복 콘텐츠 작업 시 컨텍스트 파일 자동 첨부. 자동화의 자동화 직접 구현 |
| P2-4 | **Trine 스크립트 JSON 출력 옵션 추가** | 영상 3 | `run.sh` (daily/weekly), `session-state.mjs` | 에이전트 친화적 구조화 출력으로 스크립트 파싱 안정성 향상 |
| P2-5 | **SIGIL Handoff → Trine 컨텍스트 자동 변환 스크립트** | 영상 1 | GodBlade, Portfolio 신규 Spec | `scripts/sigil-to-trine-context.sh` — Phase 1 컨텍스트 로딩 시간 단축 |

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
| P0 | 샌드박스 Google 계정 생성 (P0-1) |
| P0 | 비개발 컨텍스트 브리프 템플릿 생성 (P0-2) |
| P1 | MCP vs CLI 선택 기준 규칙 문서화 (P1-1) |
| P1 | gws-cli 테스트 환경 구축 (P1-2) |
| P1 | Model Armor 무료 티어 테스트 (P1-3) |
| P1 | gwscli GitHub Watch 설정 (P1-4) |
| P1 | 콘텐츠 큐레이션 기준 문서 초안 (P1-5) |
| P1 | Cowork 병렬 Task 가이드 간소화 (P1-7) |
| P2 | 리서치 파이프라인 → Google Drive 자동 저장 (P2-1) |
| P2 | gwscli 파일럿 3대 워크플로 (P2-2) |
| P2 | 반복 컨텍스트 자동 주입 래퍼 스크립트 (P2-3) |


### Trine — Portfolio (Next.js + NestJS)

| 우선순위 | 항목 |
|:--------:|------|
| P1 | autoFix 실패 원인 분류 스키마 설계 (P1-6) — `CONTEXT_MISSING` / `DIRECTION_ERROR` / `RULE_CONFLICT` 분류로 Trine 파이프라인 진단 체계화 |
| P2 | Trine 스크립트 JSON 출력 옵션 추가 (P2-4) |
| P2 | SIGIL Handoff → Trine 컨텍스트 자동 변환 스크립트 (P2-5) |

### Trine — GodBlade (Unity)

| 우선순위 | 항목 |
|:--------:|------|
| P1 | autoFix 실패 원인 분류 스키마 설계 (P1-6) — Portfolio와 공유 |
| P2 | SIGIL Handoff → Trine 컨텍스트 자동 변환 스크립트 (P2-5) — 신규 Spec 시작 시 Phase 1 컨텍스트 로딩 자동화 |

---

## 위험 요소 및 대응

| 위험 | 가능성 | 대응 |
|------|:------:|------|
| Model Armor 초과 요금 | 중 | 도입 전 Google Cloud 공식 가격 페이지 확인 + 월 예산 상한 알림 설정 |
| gwscli OAuth 설정 복잡도 | 높 | 공식 README 단계별 따르기 + 샌드박스에서 1회 연습 후 진행 |
| 자동화 버그로 이메일 오발송 | 중 | 샌드박스 계정 원칙 준수 + 쓰기 권한 테스트 후 단계적 부여 |
| gwscli WSL 호환성 문제 | 낮 | 공식 이슈 트래커 사전 확인 (WSL2 환경) |
| gwscli 현재 버그 상태 | 높 | P2 도입 전 안정화 확인 필수. P1-4에서 GitHub Watch로 추적 |

---

## 통합 실행 체크리스트

### P0 (오늘~내일)
- [ ] 샌드박스 Google 계정 생성 (ai-agent@gmail.com 또는 동등)
- [ ] Drive/Gmail/Calendar 접근 범위 선언 및 문서화
- [ ] `security.md` 규칙에 Google 계정 접근 정책 추가
- [ ] `09-tools/templates/project-context-brief.md` 템플릿 생성 (브랜드·타겟·톤·금지사항 포함)
- [ ] `CLAUDE.md`에 Cowork 세션 시작 시 `project-context-brief.md` 참조 규칙 추가

### P1 (이번 주)
- [ ] MCP vs CLI 선택 기준 규칙 파일 작성 (`09-tools/rules-source/always/` 또는 `CLAUDE.md`)
- [ ] `manage-rules.sh build` 실행 (compiled 규칙 갱신)
- [ ] Google Cloud 프로젝트 생성 (샌드박스 계정으로)
- [ ] `npm install -g @googleworkspace/cli`
- [ ] OAuth 클라이언트 ID 설정
- [ ] Gmail API / Drive API / Calendar API 활성화
- [ ] gws-cli 기본 동작 테스트 (이메일 읽기, 파일 생성)
- [ ] Model Armor API 활성화 + gws-cli 파이프라인 삽입 테스트
- [ ] Model Armor 공식 초과 요금 확인 + 월 토큰 사용량 알림 설정
- [ ] gwscli GitHub 저장소 URL 확인 + Watch 설정 (Releases 알림)
- [ ] `weekly-research` 추적 키워드에 `gwscli` 추가
- [ ] `09-tools/rules-source/content-quality-criteria.md` 초안 작성 (블로그·마케팅 문구 큐레이션 기준)
- [ ] `manage-rules.sh build`로 `business-core.md`에 콘텐츠 큐레이션 규칙 컴파일
- [ ] Trine autoFix 실패 원인 분류 스키마 설계 문서 작성 (`session-state.json` 확장 제안서)
- [ ] `09-tools/templates/cowork-parallel-guide.md` 비개발자 병렬 Task 레퍼런스 카드 2페이지

### P2 (이번 달)
- [ ] gwscli 안정화 버전 출시 확인 (GitHub Watch)
- [ ] gwscli 파일럿 워크플로 1번: SIGIL 산출물 → Drive 자동 업로드 테스트
- [ ] gwscli 파일럿 워크플로 2번: Weekly Research → Gmail 초안 자동 생성 테스트
- [ ] gwscli 파일럿 워크플로 3번: SIGIL 마일스톤 → Calendar 이벤트 자동 등록 테스트
- [ ] `/daily-system-review` 출력 → Google Drive 자동 저장 연동
- [ ] `/weekly-research` 출력 → Google Docs 자동 저장 연동
- [ ] MCP vs CLI 선택 기준 CLAUDE.md 최종 반영
- [ ] `scripts/content-gen-wrapper.sh` 반복 콘텐츠 작업용 컨텍스트 자동 주입 래퍼
- [ ] `scripts/sigil-to-trine-context.sh` SIGIL Handoff → Trine 컨텍스트 파일 자동 변환 스크립트
- [ ] `run.sh` (daily-review) JSON 출력 옵션 추가
- [ ] `run.sh` (weekly-research) JSON 출력 옵션 추가
- [ ] `session-state.mjs` JSON 출력 옵션 추가
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
