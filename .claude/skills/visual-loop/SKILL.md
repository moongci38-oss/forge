---
name: visual-loop
description: 프론트엔드 변경 시 정적 분석(ux-audit)에 더해 실제 렌더링 스크린샷을 Playwright로 캡처하고 Gemini Vision으로 분석하여 closed loop 검증을 수행한다. Boris Cherny Chrome 확장 패턴의 WSL 환경 대체 구현. .tsx/.jsx/.css 변경 시 /ux-audit 이후 보완 호출.
user-invocable: true
argument-hint: "[url] [--viewport=desktop,tablet,mobile]"
allowed-tools: "Bash,Read,Write,Edit,Glob,Grep,Skill,Agent"
context: fork
model: sonnet
---

**역할**: 당신은 프론트엔드 변경사항을 정적+시각 closed loop로 검증하는 UX 품질 엔지니어입니다.
**컨텍스트**: /ux-audit 정적 분석 이후 "실제 렌더링이 의도한 대로 나오는지" 추가 검증이 필요한 시점에 호출됩니다.
**출력**: 3 viewport 스크린샷 + Gemini Vision 분석 + 정적 분석과의 delta 리포트.

# Visual Loop Skill (Boris Chrome 확장 패턴의 WSL 대체)

> 출처: Boris Cherny 15 features (Chrome 확장 + Claude Desktop 브라우저 자동 검증 루프)
> WSL 제약: Chrome 확장/Claude Desktop 대신 Playwright + Gemini Vision 조합
> 관련 스킬: /ux-audit (정적), /screenshot-analyze (비전 분석), /playwright-cli (브라우저 자동화)

## PoC 목적

**정적 분석의 맹점 보완.** /ux-audit은 CSS/Tailwind 코드 읽기만 함 — 실제 브라우저 렌더링 결과(폰트 로딩 실패, flex 깨짐, 3rd-party CSS 간섭 등)는 못 잡음. 이 스킬이 **실제 렌더링을 시각적으로 검증**하여 false negative를 줄인다.

## 실행 조건

- 사용자 수동 호출 `/visual-loop <url>` OR
- Forge Dev Check 3.6 후 ux-audit 결과가 모두 PASS인데 **사용자가 의심스러운 경우** 추가 호출
- `.tsx/.jsx/.css` 변경된 PR에서 시각 검증 필요 시

## 인자

- `$1` = 검증 URL (예: `http://localhost:3000/dashboard`)
- `--viewport=` (선택) = `desktop,tablet,mobile` 중 콤마 구분. 기본: 3개 모두

## 절차

### Step 1 — 사전 검증

```bash
# 1.1 playwright 설치 확인
command -v playwright-cli || echo "playwright-cli 없음 — npm install -g @playwright/cli 필요"

# 1.2 dev server 가동 확인
curl -sf --max-time 3 -o /dev/null "$URL" && echo "server OK" || echo "server 미가동"

# 1.3 dev server 자동 기동 옵션 (package.json 감지)
if [ -f "package.json" ] && grep -q '"\"dev"\"'  package.json; then
  echo "package.json 감지 — 'npm run dev' 병행 실행 필요"
fi
```

Dev server 없으면: 사용자에게 `npm run dev`를 별도 터미널에서 실행하라고 안내 후 **대기 금지 종료**.

### Step 2 — 스크린샷 캡처 (3 viewport 병렬)

```bash
# Viewport 정의
# desktop: 1440x900  (일반 PC)
# tablet:  768x1024  (iPad 세로)
# mobile:  375x667   (iPhone SE)

mkdir -p /tmp/visual-loop-screenshots/

# playwright-cli 호출 (스킬 내부에서 Skill tool로 위임)
# 병렬 3개 viewport 스크린샷 → /tmp/visual-loop-screenshots/{viewport}.png
```

`/playwright-cli` 스킬을 **3개 병렬 Agent**로 호출 (각 viewport 담당). 결과 저장:
- `/tmp/visual-loop-screenshots/desktop.png`
- `/tmp/visual-loop-screenshots/tablet.png`
- `/tmp/visual-loop-screenshots/mobile.png`

### Step 3 — Gemini Vision 분석 (3 screenshot 병렬)

각 스크린샷에 대해 `/screenshot-analyze` 스킬을 병렬 Agent로 호출:

```
프롬프트 템플릿:
"다음 스크린샷({viewport} viewport, {width}x{height})을 분석하여:
1. 시각적 계층 구조 (Visual hierarchy) — 가장 큰 주목 요소
2. 색상 대비 이슈 (텍스트 가독성)
3. Touch target 크기 (모바일만)
4. Layout 깨짐 (overflow, overlap, 잘림)
5. Empty/error state 렌더링 누락
각 항목을 PASS/WARN/FAIL로 판정. JSON 반환."
```

출력: `/tmp/visual-loop-analysis-{viewport}.json`

### Step 3.5 — 독립 Evaluator 스폰: 시각 비교 결과 종합 판정 (신규)

> **핵심 원칙**: 스크린샷을 캡처하고 구현한 Generator(Lead 에이전트)가 직접 시각 결과를 평가하면
> 자기합리화 편향이 생긴다. 독립 Evaluator subagent가 결과를 종합하여 PASS/FAIL을 판정한다.

```python
evaluator_agent = Agent(
  subagent_type="general-purpose",
  model="sonnet",
  prompt="""
당신은 독립 Visual QA Evaluator 에이전트입니다.
구현 에이전트(Generator)의 컨텍스트(의도, 디자인 결정 이유)를 공유받지 않습니다.
오직 아래 파일만을 근거로 시각 품질을 판정하십시오.

입력 파일 경로:
  - ux-audit 정적 분석 결과: {ux_audit_result_path}
  - 시각 분석 결과 (desktop): /tmp/visual-loop-analysis-desktop.json
  - 시각 분석 결과 (tablet):  /tmp/visual-loop-analysis-tablet.json
  - 시각 분석 결과 (mobile):  /tmp/visual-loop-analysis-mobile.json
  - 스크린샷 (desktop): /tmp/visual-loop-screenshots/desktop.png
  - 스크린샷 (tablet):  /tmp/visual-loop-screenshots/tablet.png
  - 스크린샷 (mobile):  /tmp/visual-loop-screenshots/mobile.png

수행할 작업:
1. 각 JSON 파일 Read → 항목별 PASS/WARN/FAIL 수집
2. 스크린샷 Read → 분석 결과와 육안 대조 (상충 시 시각 결과 우선)
3. 정적 ux-audit 결과와 시각 결과 비교 → Delta 분류:
   - 정적 PASS → 시각 WARN/FAIL: "시각 발견" (정적 분석이 놓친 이슈)
   - 정적 FAIL → 시각 PASS: "오탐 가능" (재검토 필요)
   - 양쪽 FAIL: "이슈 확정"
4. 최종 PASS/FAIL 판정 (FAIL 기준: 시각 발견 2건 이상 OR P0 이슈 1건 이상)
5. 판정 결과를 {evaluator_result_path} 에 JSON으로 Write

절대 관대하게 보지 않는다:
- "전체적으로 괜찮아 보인다" 금지 → 각 항목 개별 검증
- Generator의 의도를 추정하여 실수를 용납하지 않는다
"""
)
```

**입력/출력 파일**:
- 입력: `/tmp/visual-loop-analysis-{viewport}.json` × 3, ux-audit 결과 (있으면)
- 출력: `/tmp/visual-loop-evaluator-result.json`

Evaluator 결과가 나오면 Step 4(Delta 분석)는 해당 JSON을 기반으로 요약만 수행한다.

### Step 4 — 정적 분석과의 Delta (교차 검증)

Evaluator 결과 (`/tmp/visual-loop-evaluator-result.json`) 를 읽어 Delta 요약:

**Delta 판정 기준:**

| 정적 결과 | 시각 결과 | 판정 | 처리 |
|---|---|---|---|
| PASS | PASS | 일치 | 보고만 |
| PASS | WARN/FAIL | **시각 발견** | 정적 분석이 놓친 이슈 → 리포트 |
| FAIL | PASS | 검토 필요 | 정적 오탐 가능 → 재검토 |
| FAIL | FAIL | 일치 | 이슈 확정 |

"시각 발견" 항목이 이 PoC의 **핵심 가치**.

### Step 5 — 통합 리포트 생성

저장 경로: `forge-outputs/docs/reviews/visual-loop/{YYYY-MM-DD}-{slug}-report.md`

리포트 구조:

```markdown
# Visual Loop Report — {URL}

**날짜:** {date}  **Viewport:** {desktop/tablet/mobile}

## 요약
- 정적 ux-audit: {PASS X / WARN Y / FAIL Z}
- 시각 분석: {PASS X / WARN Y / FAIL Z}
- **시각 발견(정적 누락):** {count}
- **Evaluator 최종 판정**: PASS / FAIL

## 스크린샷
![desktop](./screenshots/desktop.png)
![tablet](./screenshots/tablet.png)
![mobile](./screenshots/mobile.png)

## Delta 상세
### 정적 PASS → 시각 WARN/FAIL (시각 발견)
| 항목 | Viewport | Gemini 소견 | 제안 수정 |
|---|---|---|---|

### 정적 FAIL → 시각 PASS (오탐 가능)
...

## 권고 조치
- P0 (즉시): ...
- P1 (이번 주): ...
```

### Step 6 — 자동 fix PR (선택, 사용자 승인 시)

시각 발견이 명확한 경우(예: 모바일에서 버튼 잘림):
1. 변경 제안을 PR diff 형식으로 출력
2. [STOP] 게이트 — 사용자 승인 대기
3. 승인 시: Edit 도구로 파일 수정 + 재검증 루프

## 비용·리소스

| 리소스 | 1회 호출당 |
|---|---|
| Playwright 실행 | 로컬 (무료) |
| Gemini Vision API | ~$0.01~0.05 (3 스크린샷) |
| 스킬 Agent fan-out | 7개 (playwright 3 + analyze 3 + evaluator 1) |
| 소요 시간 | ~35~70초 |

**비용 통제:** 매 PR 자동 호출 금지. 의심 PR만 수동 호출.

## 제약 사항

1. **Dev server 필수** — 사용자가 별도 터미널에서 `npm run dev` 실행 필요
2. **WSL 환경 Playwright** — 의존성 설치 필요 (`playwright install chromium`)
3. **Gemini API 키 필요** — `GEMINI_API_KEY` 환경변수 or forge `.env`
4. **localhost 한정** — 원격 스테이징/프로덕션 URL은 CORS/인증 이슈 가능

## Chrome 확장 vs 이 스킬 (설계 결정)

Boris는 "Chrome 확장 + Claude Desktop 내장 브라우저"를 추천. 우리 환경 제약:
- WSL → Chrome 확장 설치 불가
- Claude Desktop 앱 → WSL bash에서 자동화 불가

**결론:** Playwright + Gemini Vision 조합이 **같은 가치**(코드→실행→스크린샷→분석 closed loop)를 WSL에서 달성. Chrome 확장은 대화형 UX 이점만 있고, 자동화 효과는 이 스킬이 동등.

## 향후 확장

- **E2E 시나리오 테스트 통합**: `/playwright-parallel-test`와 연계해서 사용자 플로우(로그인→결제→확인) 검증 후 스크린샷 캡처
- **Visual regression**: 이전 버전 스크린샷과 diff (pixelmatch) 통합
- **a11y 자동 검사**: axe-playwright로 WCAG 자동 검증 추가

## 사용 예시

```bash
# 기본 (3 viewport)
/visual-loop http://localhost:3000/dashboard

# 모바일만
/visual-loop http://localhost:3000/checkout --viewport=mobile

# 카드게임 프로젝트 예시 (PC 버전)
/visual-loop http://localhost:5173/game/baduki --viewport=desktop
```

## 트러블슈팅

| 증상 | 원인 | 해결 |
|---|---|---|
| `playwright-cli: command not found` | Playwright 미설치 | `npm install -g @playwright/cli && playwright install chromium` |
| `ECONNREFUSED localhost:3000` | Dev server 미기동 | 별도 터미널에서 `npm run dev` 후 재실행 |
| Gemini API 429 rate limit | 과다 호출 | `--viewport=mobile` 등으로 축소, 10초 sleep 삽입 |
| 스크린샷 빈 화면 | JS 렌더링 대기 부족 | Playwright `--wait-until networkidle` 옵션 |
| Evaluator 스폰 실패 | Agent 도구 미허용 | `allowed-tools`에 Agent 포함 확인 (frontmatter) |

---

**출처 및 관련 문서:**
- Boris Cherny 15 features 원본: `forge-outputs/01-research/articles/2026-04-17/2026-04-17-yozm-wishket-com-boris-cherny-15-claude-code-features-analysis.md`
- 관련 스킬: `/ux-audit` (정적 분석), `/screenshot-analyze` (Gemini Vision), `/playwright-cli` (브라우저 자동화), `/playwright-parallel-test` (E2E)
