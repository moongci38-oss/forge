# Claude Code가 대규모 업그레이드를 받았습니다 (Agent Loops)
> Tech Bridge | 2026-03-10 수집 | 조회수 미제공 | 약 11분
> 원본: https://youtu.be/9R1bX7L-YFo

---

## TL;DR

Claude Code의 신규 `/loop` 기능(Agent Loops)은 세션 내에서 최대 3일간 반복 예약 작업을 수행하는 도구지만, 세션 종료 시 함께 중단된다는 결정적 제약이 있다. "24시간 에이전트"나 "Claude 2.0" 같은 과장 마케팅과 달리 진정한 상시 자율 에이전트가 아니며, 장기 반복 작업에는 Claude Code Desktop의 `/schedule`, GitHub 이벤트 기반 작업에는 GitHub Actions가 각각 더 적합하다.

---

## 카테고리

tech/ai | #claude-code #agent-loops #automation #scheduled-tasks #anthropic #devtools

---

## 핵심 포인트

1. **Agent Loops(/loop)는 어제 최신 업데이트에서 출시** [🕐 01:54](https://youtu.be/9R1bX7L-YFo?t=114)
   `/loop` 명령어가 보이지 않는다면 Claude Code를 최신 버전으로 업그레이드하면 된다.

2. **핵심 제약: "세션 내에서"만 동작** [🕐 02:13](https://youtu.be/9R1bX7L-YFo?t=133)
   세션이 살아있는 동안에만 반복 실행된다. 터미널 창 닫기, 컴퓨터 종료, 절전 모드 진입 모두 즉시 중단을 유발한다.

3. **3대 운영 제약 — 반드시 숙지 필요** [🕐 03:29](https://youtu.be/9R1bX7L-YFo?t=209)
   (1) 최대 3일 후 자동 만료, (2) 앱과 컴퓨터가 항상 켜져 있어야 함, (3) 예약 작업이 기존 진행 중인 작업을 선점하지 않음 — 현재 작업 완료 후 순차 실행.

4. **실제 유효한 사용 사례: 단기 마이크로 자동화** [🕐 04:21](https://youtu.be/9R1bX7L-YFo?t=261)
   "10분마다 웹사이트 배포 상태 확인" 또는 "5분마다 Playwright로 폼 제출 동작 검증"처럼 특정 작업 세션 내 반복 점검이 핵심 용도다.

5. **Claude Code Desktop의 /schedule이 장기 반복 작업에 더 강력** [🕐 05:20](https://youtu.be/9R1bX7L-YFo?t=320)
   Desktop 전용 `/schedule`은 (1) 시간 제한 없음, (2) 세션 비종속(앱 재시작 후에도 유지), (3) 실행 시마다 독립 새 세션 생성 — 현재 작업 방해 없음. Terminal CLI에는 `/schedule` 없음.

6. **Desktop Schedule의 주의점: 실행 빈도에 따른 세션 증식** [🕐 06:56](https://youtu.be/9R1bX7L-YFo?t=416)
   매분 실행하면 60분에 60개 세션이 생성된다. Desktop이 열려 있어야 실행되며, 컴퓨터가 꺼지면 중단된다.

7. **GitHub Actions: 로컬 PC 독립 자동화지만 GitHub 범위 한정** [🕐 08:22](https://youtu.be/9R1bX7L-YFo?t=502)
   컴퓨터 상태와 무관하게 GitHub 인프라에서 실행되나 PR 처리, 코드 검증 등 GitHub 관련 작업에만 적합하다. 텔레그램 연동 같은 범용 에이전트 목적에는 맞지 않는다.

8. **Claude Code Remote 역시 동일한 세션 제약** [🕐 09:06](https://youtu.be/9R1bX7L-YFo?t=546)
   내장 Remote Control도 해당 세션에서만 동작한다. 컴퓨터가 꺼지면 종료된다.

9. **용도별 선택 기준** [🕐 07:32](https://youtu.be/9R1bX7L-YFo?t=452)
   단기(오늘 하루) 집중 반복 → `/loop`, 장기(매일 보고서, 영구 반복) → Desktop `/schedule`, GitHub 이벤트 트리거 → GitHub Actions.

10. **Boris Cherny(Claude Code 개발자)의 공식 사용 예시** [🕐 02:22](https://youtu.be/9R1bX7L-YFo?t=142)
    "모든 PR을 모니터링하고 빌드 이슈를 자동 수정하며, Worktree 에이전트로 코멘트 반영" 및 "매일 아침 Slack MCP로 태그된 중요 게시물 요약 수신".

---

## 비판적 분석

| 주장 | 검증 | 판정 |
|------|------|------|
| "Agent Loops는 24시간 에이전트다" | 세션 종료 시 중단, 최대 3일 제한. 진정한 상시 에이전트 아님 | 과장 (영상이 정확히 반박함) |
| "Desktop Schedule은 만료 없이 영구 실행된다" | Desktop이 열려 있고 컴퓨터가 켜져 있어야 함. 사실상 조건부 영구 | 부분적으로 맞음, 뉘앙스 필요 |
| "GitHub Actions로 Claude Code를 항상 클라우드에서 실행할 수 있다" | GitHub 이벤트 한정. 범용 자율 에이전트 목적에는 부적합 | 조건부 정확 |
| "/loop 실행 중 기존 작업을 방해한다" | 기존 작업 완료 후 순차 실행. 방해하지 않음 | 오해 (실제로는 방해 없음) |
| "Slack MCP 요약 같은 장기 반복 작업은 CLI /loop로 구현해야 한다" | 3일마다 재설정 필요 → Desktop Schedule이 적합. 보리스의 예시도 사실상 Desktop용 | 잘못된 적용 (Desktop이 올바른 선택) |

---

## 팩트체크 대상

1. **"최대 3일 제한"의 정확한 메커니즘** — 3일 후 완전 삭제인지, 재설정만 필요한지 Anthropic 공식 문서에서 확인 필요. 영상은 "자동으로 꺼진다"고만 설명.
2. **Desktop Schedule의 세션 증식 실제 영향** — "60분에 60개 세션" 시나리오가 실제 메모리/성능 문제를 유발하는지 벤치마크 데이터 없음. 극단적 예시일 가능성.
3. **Claude Code Remote의 현재 공개 범위** — 영상에서 "내장된 Remote Control"을 언급하나 공개 문서에서의 기능 범위와 현재 접근 방법이 불명확. 공식 채널 확인 필요.

---

## 실행 가능 항목

- [ ] `claude --version` 확인 후 `/loop` 명령어 없으면 Claude Code 업그레이드 실행
- [ ] Trine Check 3 반복 실행을 `/loop 10m "bash verify.sh code"` 패턴으로 자동화 프로토타입 테스트
- [ ] `business/scripts/weekly-report` cron 작업을 Desktop `/schedule`로 이관하는 방안 검토 (만료 없는 장기 반복)
- [ ] GitHub Actions에 Claude Code 통합하여 Trine PR 자동 리뷰 파이프라인 구축 (`@anthropic-ai/claude-code-action` 확인)
- [ ] `/loop` 사용 시 3일 만료 알림을 캘린더 또는 cron으로 등록하여 수동 재설정 리마인더 추가

---

## 시스템 적용 맥락 (Gap Table)

현재 Trine/SIGIL 워크플로우에서 Agent Loops/Schedule이 메울 수 있는 공백:

| 현재 방식 | 대체 가능 도구 | 적합 이유 | 우선순위 |
|-----------|-------------|----------|---------|
| 수동 `verify.sh code` 반복 실행 (Check 3) | `/loop 10m` | 단기 작업 세션 내 반복 점검 | 높음 |
| `daily-system-review` cron (00:00 UTC) | Desktop `/schedule` | 장기 반복, 만료 없음 | 높음 |
| PR CI 상태 수동 폴링 (`/loop 2m`) | GitHub Actions | 컴퓨터 독립, PR 이벤트 트리거 | 중간 |
| Playwright E2E 수동 실행 | `/loop 5m` | 배포 세션 중 지속 검증 | 중간 |
| weekly-research cron 결과 확인 | Desktop `/schedule` 실행 + 요약 알림 | 장기 반복 자동화 | 낮음 |

**현재 시스템과의 충돌 지점**: `trine-workflow.md`의 `/loop 2m` 폴링 규칙(PR Code Review Gate)은 실제 CLI `/loop` 명령어가 아닌 "2분마다 반복 확인"을 의미하는 인간 지시어임. Agent Loops의 `/loop`와 혼동 주의 — 문서상 표기 명확화 권장.

---

## 관련성

- **Portfolio (Next.js + NestJS)**: 4/5 — `/loop`로 배포 상태 주기 확인, GitHub Actions로 PR 자동 리뷰, Playwright 반복 E2E 검증에 직접 적용 가능. Trine Check 3 자동화와 연계 실용성 높음.
- **GodBlade (Unity 게임)**: 2/5 — Unity CLI 빌드 상태 주기 확인에 이론적으로 활용 가능하나 Unity 빌드 환경이 CLI 자동화에 제한적. GitHub Actions PR 모니터링에는 유효.
- **비즈니스 (SIGIL/Trine 시스템)**: 5/5 — 직접 관련성 최상. daily-system-review, weekly-research, Check 3 루프, Trine PR 폴링 등 운영 중인 자동화 파이프라인 전반에 영향. `/loop` vs Desktop `/schedule` vs GitHub Actions 선택 기준을 명확히 이해해야 올바른 도구 선택 가능.

---

## 핵심 인용

> "세션 내에서라는 것이 중요한 포인트입니다."
> [🕐 02:13](https://youtu.be/9R1bX7L-YFo?t=133) — 모든 제약의 근거가 되는 핵심 경고.

> "루프를 거의 하나의 스킬이나 스킬들의 스킬로 만들 수 있습니다. 클로드 코드에서 계속 반복하고 있던 모든 것을 이제 루프를 통해 체계적으로 할 수 있습니다."
> [🕐 04:51](https://youtu.be/9R1bX7L-YFo?t=291) — 기능의 긍정적 가치 평가.

> "결론적으로 에이전트 루프는 훌륭하지만 범위가 실제로는 꽤 작고 여러분의 특정 프로젝트와 작업에 따라 달라집니다."
> [🕐 09:22](https://youtu.be/9R1bX7L-YFo?t=562) — 영상의 최종 결론.

---

## 추가 리서치 필요

- Anthropic 공식 문서에서 `/loop` 만료 메커니즘 상세 스펙 확인
- Claude Code GitHub Actions 통합 공식 가이드 (`@anthropic-ai/claude-code-action`)
- Desktop `/schedule` 세션 생성 수 제한 또는 관리 방법 (대량 세션 축적 문제 대응)
- `claude remote` 기능의 현재 공개 범위 및 로드맵
- `/loop` 기능이 MCP 서버(Slack, Notion 등)와 함께 동작하는 방식 실제 테스트

---

## 자막 신뢰도

자동 생성 자막(`is_generated_subtitle: true`), 한국어. 전체 의미 파악은 가능하나 고유명사 오인식 일부 확인됨:

| 오인식 표기 | 실제 의미 | 신뢰도 영향 |
|-----------|----------|-----------|
| "엔스로피기" | Anthropic | 낮음 (문맥 명확) |
| "보리스 체르니" | Boris Cherny | 없음 (정확) |
| "노포로" | 문맥상 GitHub PR 또는 nohup 추정 | 낮음 |
| "플레이라이" | Playwright | 없음 (정확) |
| "기트 오브 액션즈" | GitHub Actions | 없음 (정확) |
| "클라이" | CLI | 없음 (정확) |

핵심 사실관계는 신뢰 가능. 세부 고유명사는 원문 영상 대조 권장.
