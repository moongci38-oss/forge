# Claude Code + Playwright CLI = 브라우저 자동화 혁신

> **영상**: [Claude Code + Playwright = 놀라운 브라우저 자동화입니다](https://youtu.be/GaVoI5ZxV10)
> **채널**: Tech Bridge
> **자막 신뢰도**: Medium (자동 생성 자막 — 음차 오류 다수: "플레이라이크라이", "크레이", "클라이", "카이" 등은 모두 `@playwright/cli`를 의미)
> **분석일**: 2026-03-10

---

## 1. TL;DR

Playwright CLI(`@playwright/cli`)는 Claude Code의 브라우저 자동화 도구로 Playwright MCP 대비 약 9만 토큰을 절약하며, 병렬 서브에이전트와 헤드리스 모드를 모두 지원한다. 반복 테스트 워크플로우를 Skill Creator로 패키징하면 한 문장으로 다중 에이전트 UI 테스트가 실행된다.

---

## 2. 카테고리

**tech/ai**, **tech/devtools**, **tech/testing**

`#claude-code` `#playwright` `#browser-automation` `#ui-testing` `#subagent` `#skills` `#token-optimization` `#headless` `#mcp-comparison`

---

## 3. 핵심 포인트

- [🕐 00:00](https://youtu.be/GaVoI5ZxV10?t=0) — 데모 오프닝: Claude Code에 "3개의 병렬 서브에이전트로 폼 제출 테스트" 명령 → 즉시 3개 서브에이전트가 Playwright CLI를 사용해 병렬 실행. 수동 QA 없이 에지케이스·유효성검사·정상경로를 동시 검증.

- [🕐 02:54](https://youtu.be/GaVoI5ZxV10?t=174) — 왜 Playwright CLI인가: Playwright MCP, Claude in Chrome 확장 3가지를 비교. 핵심 주장: CLI만이 "효율적"이다. 이유는 토큰 효율, 헤드리스 지원, 병렬 처리 3가지.

- [🕐 03:34](https://youtu.be/GaVoI5ZxV10?t=214) — 토큰 절감 수치: Playwright 팀 자체 비교 영상 기준 동일 작업에서 MCP 대비 약 **9만 토큰** 차이. Claude in Chrome은 스크린샷 기반이라 가장 비용이 높고, 헤드리스·병렬 모두 불가.

- [🕐 05:44](https://youtu.be/GaVoI5ZxV10?t=344) — 토큰 차이의 기술적 이유: Playwright는 내부적으로 **접근성 트리(Accessibility Tree)**를 사용. MCP는 전체 트리를 컨텍스트에 직접 주입 → 토큰 폭발. CLI는 트리를 디스크에 저장 후 **요약본만** Claude Code에 전달.

- [🕐 07:25](https://youtu.be/GaVoI5ZxV10?t=445) — 설치 3단계: ① `playwright-cli` 설치, ② `npx playwright install chromium` 브라우저 엔진 설치, ③ `playwright-cli install-skills` Skill 등록. 또는 Claude Code에 GitHub 저장소 링크를 주고 "다 설치해 줘" 한 마디로 가능.

- [🕐 09:42](https://youtu.be/GaVoI5ZxV10?t=582) — 기본 헤드리스 모드: 명시 요청 없으면 브라우저 UI가 보이지 않음. "헤디드 브라우저로 해 줘"라고 지정해야 화면에 표시. 자체 프로젝트는 코드베이스 파악 상태라 접근성 트리 파싱 실패 가능성이 낮아 특히 효과적.

- [🕐 11:07](https://youtu.be/GaVoI5ZxV10?t=667) — 병렬 에이전트 실전: "세 개의 병렬 에이전트로 여러 각도에서 공격해라" 두 문장으로 전체 UI 테스트 대체. Claude Code에게 "이 폼 스트레스 테스트 최선 방법이 뭐야?"라고 묻는 것도 가능.

- [🕐 11:31](https://youtu.be/GaVoI5ZxV10?t=691) — 워크플로우를 Skill로 패키징: 반복 테스트를 매번 설명하지 않도록 Skill Creator로 메타스킬 생성. "폼 테스터 스킬 실행해 줘" 한 마디로 3-에이전트 병렬 테스트 자동 실행. 핵심 마인드셋: **"표준화할 수 있나? → Skill로 만들 수 있나?"**

- [🕐 13:40](https://youtu.be/GaVoI5ZxV10?t=820) — 활용 범위: UI 테스트 외에도 로그인 자동화, 지속 세션, 쿠키 관리, 쇼핑 자동화 등 브라우저 상호작용이 필요한 모든 영역 적용 가능. Claude Code가 Playwright의 복잡한 API를 추상화.

---

## 4. 비판적 분석

### 주장 1: "Playwright CLI가 MCP보다 9만 토큰 절약"
- **근거**: Playwright 팀의 자체 비교 영상 인용 (영상 내 구체적 링크 미제공)
- **근거 유형**: 경험적 (1회 비교 실험, 맥락 불명확)
- **한계**: 어떤 작업 유형, 페이지 복잡도, 모델 버전 기준인지 미공개. 복잡한 SPA나 동적 컨텐츠에서는 차이가 다를 수 있음.
- **반론/대안**: MCP는 추가 설정 없이 즉시 사용 가능. 소규모 1회성 작업에서는 9만 토큰 절감이 설치·학습 비용보다 크지 않을 수 있음.

### 주장 2: "Claude in Chrome 확장이 세 가지 중 가장 비효율적"
- **근거**: 스크린샷 기반 작동 방식 → 이미지 토큰 소모, 헤드리스 불가, 병렬 불가
- **근거 유형**: 기술적 사실 (스크린샷이 텍스트 대비 토큰 소모가 큰 것은 실증적으로 검증됨)
- **한계**: Claude in Chrome의 장점(시각적 렌더링 검증, JavaScript 에러 감지)은 언급 없음. 픽셀 단위 UI 검증이 필요한 케이스에서는 스크린샷 방식이 오히려 정확할 수 있음.
- **반론/대안**: 디자인 일치성 검증 등 시각적 테스트에서는 스크린샷 방식이 유일한 선택지일 수 있음.

### 주장 3: "Skill Creator로 워크플로우를 패키징하면 반복 작업이 사라진다"
- **근거**: 영상 내 실시간 데모 (폼 테스터 스킬 생성 및 실행 시연)
- **근거 유형**: 경험적 (시연 환경 = 단순 폼, 실제 복잡한 SPA 미검증)
- **한계**: Skill의 유지보수 비용 미언급. UI가 변경되면 Skill도 갱신해야 하며, 잘못 작성된 Skill은 오히려 잘못된 테스트를 반복할 위험. Playwright Codegen이나 기존 Cypress/Playwright 테스트 코드 관리 방식과의 비교 없음.
- **반론/대안**: 전통적인 Playwright test 파일(`*.spec.ts`) 작성 후 CI에 연동하는 방식이 장기 유지보수에서 더 안정적일 수 있음.

### 주장 4: "두 문장이면 모든 UI 테스트를 대신한다"
- **근거**: 오프닝 데모 및 단일 폼 테스트 시연
- **근거 유형**: 의견 (과장적 표현)
- **한계**: 복잡한 인증 플로우, WebSocket, Canvas 등 접근성 트리로 커버하기 어려운 UI 패턴 미언급. AI가 생성한 테스트 시나리오의 누락 케이스 위험.
- **반론/대안**: AI 생성 테스트는 "탐색적 테스트"에 유용하나, 수용 기준이 명확한 회귀 테스트는 여전히 코드로 작성된 Spec이 신뢰성 높음.

---

## 5. 팩트체크 대상

- **주장**: "Playwright CLI와 MCP 비교 시 같은 작업에서 약 9만 토큰 차이가 났다" | **검증 필요 이유**: 영상 출처(Playwright 팀 비교 영상)를 직접 확인하지 않음. 작업 유형·페이지 복잡도·모델 버전이 결과에 크게 영향을 미침. | **검증 방법**: Playwright 팀 YouTube 채널 및 공식 blog에서 CLI vs MCP 벤치마크 영상 확인. 또는 동일 테스트 케이스를 양쪽으로 직접 실행 후 토큰 사용량 비교.

- **주장**: "Playwright CLI는 접근성 트리를 디스크에 저장하고 요약본만 Claude Code에 전달한다" | **검증 필요 이유**: 내부 구현 방식에 대한 설명이 단순화되어 있을 수 있음. 실제 구현이 다를 경우 토큰 절약 메커니즘의 근거가 달라짐. | **검증 방법**: Playwright CLI GitHub 저장소(`microsoft/playwright`) 소스 코드 확인. 특히 Claude Code 연동 부분의 접근성 트리 처리 로직 분석.

- **주장**: "Playwright CLI는 몇 주 전에 추가된 비교적 최신 기능이다" | **검증 필요 이유**: 영상 녹화 시점이 불명확(published 정보 없음). 현재(2026-03-10) 기준 Playwright CLI의 Claude Code Skill 지원 상태 및 버전 확인 필요. | **검증 방법**: npm `@playwright/cli` 패키지 릴리즈 히스토리 및 Playwright 공식 문서의 Claude Code 연동 섹션 확인.

---

## 6. 실행 가능 항목

- [ ] **Playwright CLI 설치 상태 검증** (적용 대상: Portfolio 프로젝트 개발 환경) — `playwright-cli install-skills`가 현재 `scripts/manage-skills.sh list`의 `playwright-cli` Skill과 동일한지 확인.
- [ ] **MCP vs CLI 토큰 실측 비교** (적용 대상: 개인 검증) — 동일 폼 테스트를 Playwright MCP와 CLI 양쪽으로 실행 후 `/context` 명령으로 토큰 사용량 비교. 9만 토큰 주장 검증.
- [ ] **Portfolio 폼 테스트 메타스킬 생성** (적용 대상: Portfolio Next.js 프로젝트) — Contact 폼, 로그인 폼, 에디터 제출 플로우를 Skill Creator로 "form-tester" 메타스킬로 패키징. Trine Check 3 이후 UI 검증 단계에 통합.
- [ ] **헤드리스/헤디드 워크플로우 기준 문서화** (적용 대상: Trine 개발 파이프라인) — CI 환경(headless)과 로컬 디버깅(headed) 분기 기준을 `.claude/skills/playwright-cli/SKILL.md`에 명시.
- [ ] **Playwright 팀 CLI vs MCP 벤치마크 영상 확인** (적용 대상: 도구 선택 검증) — 팩트체크 #1 이행. 9만 토큰 차이의 조건(작업 유형, 페이지 복잡도) 파악.
- [ ] **"표준화 → Skill 패키징" 원칙을 Trine 가이드에 추가** (적용 대상: Business 워크스페이스 운영) — 반복 워크플로우 발견 시 Skill Creator로 패키징하는 사고방식을 `trine-workflow.md` 또는 Skills 관련 문서에 명시.

---

## 7. 시스템 적용 맥락

| 영역 | 영상 제안 | 현재 상태 | 갭 | 우선순위 |
|------|-----------|-----------|-----|---------|
| **Claude Code + Skills** | Playwright Skill을 Skill Creator로 메타스킬화 | `playwright-cli` Skill 설치 완료 (MEMORY.md 기록) | 폼 테스터 메타스킬 미생성 | 높음 |
| **Trine (Check 3 / Check 3.5)** | UI 변경 후 자동으로 병렬 브라우저 테스트 실행 | Check 3에 build/lint/test 포함, UI 자동화 테스트 미통합 | Playwright CLI를 Check 3 이후 게이트로 편입하는 정의 없음 | 중간 |
| **Trine (Phase 3 TDD, T-6)** | "두 문장으로 UI 탐색적 테스트" | Phase 3에 Playwright E2E spec 파일 작성 (T-1, T-6) | AI 자연어 탐색적 테스트 vs 코드 기반 `*.e2e-spec.ts` 역할 분리 기준 없음 | 중간 |
| **Next.js (Portfolio)** | 폼 제출, 로그인, 에디터 등 핵심 플로우 자동 테스트 | 수동 테스트 또는 Playwright `*.e2e-spec.ts` | 병렬 에이전트 탐색적 테스트 + 코드 기반 회귀 테스트 분리 정의 필요 | 높음 |
| **Claude Code + MCP** | CLI가 MCP보다 토큰 효율 압도적 우위 | 2026-03-09 MCP → CLI 전환 완료 | 전환 완료 상태. 토큰 절감 실측 데이터 수집 필요 | 낮음 |
| **Trine + Skills (Skill Creator)** | 반복 워크플로우를 메타스킬로 패키징 | Skills 2.0 완료, Skill Creator 영상 참조됨 | "워크플로우 표준화 → Skill 패키징" 사고방식을 Trine 파이프라인 가이드에 명시 없음 | 중간 |
| **cron / 자동화** | 코드 변경마다 로컬 개발 서버에서 폼 테스트 반복 | CI 자동화 미언급 | pre-commit hook 또는 Trine Check 3에 playwright 헤드리스 테스트 통합 검토 | 낮음 |

---

## 8. 관련성

| 프로젝트 | 점수 | 이유 |
|---------|------|------|
| **Portfolio (Next.js + NestJS)** | 5/5 | 폼 제출, 인증, 에디터, 댓글 등 UI 테스트 대상이 명확. Playwright Skill → Claude Code 연동이 즉시 적용 가능. Trine Check 3 UI 게이트 강화에 직결. |
| **GodBlade (Unity)** | 1/5 | Unity 게임 클라이언트는 브라우저 자동화 대상 아님. 관련 웹 운영툴(관리자 페이지) 개발 시 적용 가능하나 현재 단계에서 관련성 낮음. |
| **비즈니스 워크스페이스** | 2/5 | 비개발 업무 중심. 단, 웹 스크래핑, 시장조사 자동화(경쟁사 웹페이지 수집), 리서치 자동화에 Playwright CLI 활용 가능. |

---

## 핵심 인용

> "표준화할 수 있을까? 표준화했다면 그 표준 플로우를 스킬로 만들 수 있을까? 그러면 정말 쉬워집니다."
> — [🕐 13:29](https://youtu.be/GaVoI5ZxV10?t=809)

이 한 문장이 영상의 핵심 메시지다. Claude Code 워크플로우 설계 원칙으로 확장 가능하며, Trine 파이프라인 내 반복 검증 프로세스(Check 3, 3.5, 3.7)를 Skill로 패키징하는 방향과 완전히 일치한다.

---

## 추가 리서치 필요

1. **Playwright CLI GitHub 구현 분석** — `microsoft/playwright` 저장소에서 Claude Code Skill 구현 방식 및 접근성 트리 처리 로직 확인. 팩트체크 #2 이행.
2. **Playwright 팀 CLI vs MCP 벤치마크 영상** — 9만 토큰 차이의 구체적 조건(페이지 유형, 작업 수, 모델) 확인. 팩트체크 #1 이행.
3. **AI 탐색적 테스트 vs 코드 기반 회귀 테스트 역할 분리** — 장기 유지보수 관점에서 두 방식의 최적 조합 기준 조사. Trine T-1, T-6 체크와 연계하여 가이드라인 수립.
