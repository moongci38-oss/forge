# MCP써야 진짜 Claude다! 500% 활용 튜토리얼 (개념부터 활용까지)

> **채널**: 시민개발자 구씨 | **영상 ID**: fkqXQOjj8cA | **게시일**: 2025-04-05
> **시청 시간**: 26:04 | **조회수**: 166.9K | **좋아요**: 4.1K | **댓글**: 320
> **자막 신뢰도**: Medium (자동 생성 자막 기반 — 발음 오류/이어쓰기 다수 존재)

---

## 1. TL;DR

MCP(Model Context Protocol)의 개념을 비개발자 관점에서 설명하고, Claude Desktop에서 Firecrawl·Slack·Puppeteer·Notion MCP 서버를 직접 설치해 웹 크롤링→Slack 전송 및 YouTube 채널 리포트→Notion 저장 워크플로를 시연한 실습 튜토리얼이다. JSON 설정 파일에 코드 스니펫을 붙여 넣는 수준으로 비개발자도 MCP 서버를 설치할 수 있음을 강조한다.

---

## 2. 카테고리

**tech/ai** — Claude, MCP

`#MCP` `#ModelContextProtocol` `#Claude` `#ClaudeDesktop` `#Firecrawl` `#Puppeteer` `#SlackAutomation` `#NotionAutomation` `#AIAgent` `#비개발자` `#자동화` `#워크플로`

---

## 3. 핵심 포인트

1. **[🕐 00:40](https://youtu.be/fkqXQOjj8cA?t=40) — MCP 정의**: MCP(Model Context Protocol)는 AI 모델이 외부 서비스와 표준화된 방식으로 소통하도록 돕는 프로토콜. API 연동 코딩 없이 "서버만 붙이면" 서비스 연결이 가능해진다.

2. **[🕐 01:06](https://youtu.be/fkqXQOjj8cA?t=66) — 4계층 구조**: Host(Claude Desktop 등) → Client(통신 중계) → Server(서비스별 MCP 서버) → Resource(외부 서비스) 계층으로 구성. 각 서비스마다 MCP 서버를 설치하면 Claude에서 직접 제어 가능.

3. **[🕐 02:30](https://youtu.be/fkqXQOjj8cA?t=150) — MCP의 핵심 장점**: 기존에는 Slack을 쓰려면 채널 리스트업·메시지 전송·스레드 답장·이모지 리액션 등 API 콜 하나하나를 직접 코딩해야 했으나, MCP 서버 설치 후에는 자연어 프롬프트 하나로 동일 작업 수행 가능.

4. **[🕐 05:10](https://youtu.be/fkqXQOjj8cA?t=310) — 설치 선행 조건**: Claude Desktop(웹 버전 불가), VS Code(JSON 편집용), Node.js(로컬 MCP 서버 실행용) 세 가지를 먼저 설치해야 한다.

5. **[🕐 06:20](https://youtu.be/fkqXQOjj8cA?t=380) — Firecrawl 설치 방법**: GitHub의 Anthropic 공식 MCP 레포지토리 → Firecrawl 항목 → JSON 코드 스니펫 복사 → `claude_desktop_config.json`에 붙여 넣기 → API 키 입력 → Claude 재시작. 코딩 없이 완료.

6. **[🕐 11:40](https://youtu.be/fkqXQOjj8cA?t=700) — Slack MCP 설정의 복잡성**: Slack MCP는 Slack 앱 생성 → Bot Token 스코프 5개 부여 → 워크스페이스 설치 → 채널에 앱 추가 → Token·TeamID를 JSON에 입력하는 다단계 절차가 필요해, Firecrawl보다 복잡하다.

7. **[🕐 16:00](https://youtu.be/fkqXQOjj8cA?t=960) — 실습 1: 크롤링→Slack 전송**: Firecrawl로 TechCrunch AI 뉴스 5개 크롤링 → Slack Block Kit 호환 JSON 형식으로 정리 → AI 뉴스 채널에 자동 게시. Claude가 어떤 MCP 서버를 쓸지 스스로 판단해 권한 요청 팝업을 띄운다.

8. **[🕐 19:30](https://youtu.be/fkqXQOjj8cA?t=1170) — 실습 2: Puppeteer로 YouTube 크롤링**: Puppeteer MCP는 오픈소스라 API 키 불필요. 실제 브라우저 창을 띄워 YouTube 채널 동영상 탭을 탐색하며 최근 영상 10개 지표(조회수·업로드 주기 등)를 수집, 채널 분석 리포트를 자동 작성.

9. **[🕐 22:50](https://youtu.be/fkqXQOjj8cA?t=1370) — Notion 저장**: Notion Integration 생성 → Secret Key 취득 → 대상 페이지에 커넥션 추가 → JSON에 토큰 삽입. 이후 자연어 프롬프트로 Notion DB에 채널 리포트 페이지 자동 생성. 내용이 길면 Claude가 자동으로 분할 전송한다.

10. **[🕐 24:50](https://youtu.be/fkqXQOjj8cA?t=1490) — 성숙도 경고**: MCP 프로토콜이 도입된 지 얼마 안 되어 버그 발생, 도중 중단 등 불안정 사례가 존재한다. ChatGPT도 MCP 도입 예정이므로 Claude에서 먼저 테스트해볼 것을 권장.

---

## 4. 비판적 분석

### 주장 1: "MCP 서버는 JSON 파일에 붙여넣기만 하면 누구나 설치할 수 있다"

| 항목 | 내용 |
|------|------|
| **근거** | 실제 영상에서 `claude_desktop_config.json`에 코드 스니펫을 붙여넣기하는 과정만으로 Firecrawl이 설치됨을 시연 |
| **근거 유형** | 경험적 (본인 환경에서의 시연) |
| **한계** | Slack 설치 시 앱 생성→스코프 설정→워크스페이스 설치→채널 추가→Token/TeamID 확보의 다단계 진행. 비개발자에게는 여전히 높은 진입 장벽. Node.js 설치, JSON 문법 오류 디버깅도 난관 |
| **반론/대안** | MCP 서버 설치 자체보다 API 키 발급·권한 설정 등 외부 서비스 연동 절차가 실제 난이도의 대부분을 차지한다. 영상 제목("누구나")은 과장에 가깝다 |

### 주장 2: "MCP를 활용하면 Claude 생산성이 500% 증가한다"

| 항목 | 내용 |
|------|------|
| **근거** | 제목 및 도입부에서 반복 언급. 외부 서비스 연동으로 기존 텍스트/코드 작업의 한계를 넘는다는 논리 |
| **근거 유형** | 의견 (수치 측정 없음) |
| **한계** | 500%라는 수치의 측정 기준 부재. MCP 활용 전후 실제 시간 절감 데이터 미제시. 마케팅성 수사에 가깝다 |
| **반론/대안** | MCP 서버 안정성 문제(영상 자체에서도 인정)로 실제 업무 적용 시 신뢰성이 낮을 수 있다. 생산성 향상은 서버 품질·태스크 유형에 크게 의존한다 |

### 주장 3: "Claude가 어떤 MCP 서버를 써야 할지 스스로 판단한다"

| 항목 | 내용 |
|------|------|
| **근거** | 실습 1에서 Firecrawl과 Slack 중 적절한 서버를 Claude가 자동 선택해 권한 팝업을 띄우는 장면 시연 |
| **근거 유형** | 경험적 (단일 시연) |
| **한계** | 복잡한 워크플로에서 잘못된 서버를 선택하거나 불필요한 권한 요청이 발생하는 경우 미검증. 단순한 2-서버 환경에서의 시연이라 일반화 어려움 |
| **반론/대안** | 설치된 MCP 서버 수가 많아질수록 Claude의 서버 선택 정확도와 프롬프트 토큰 소비량 증가에 대한 논의가 필요. `trine-context-management.md`의 MCP 토큰 인지 규칙이 이 점을 이미 다루고 있다 |

### 주장 4: "Puppeteer MCP로 자바스크립트 코딩 없이 브라우저 자동화를 할 수 있다"

| 항목 | 내용 |
|------|------|
| **근거** | YouTube 채널 크롤링을 프롬프트만으로 수행, 실시간 브라우저 조작 화면 시연 |
| **근거 유형** | 경험적 (시연) |
| **한계** | 동적 SPA 사이트, 로그인 필요 사이트, rate limiting, CAPTCHA 등 실무 환경의 복잡한 케이스는 미다룸. Puppeteer MCP는 아직 안정성이 낮다 |
| **반론/대안** | Playwright, Selenium 등 대안 도구와의 비교 없이 Puppeteer만 소개. 비개발자가 에러 발생 시 디버깅하기 어렵다. Business 워크스페이스는 이미 Playwright CLI로 전환 완료된 상태 |

### 주장 5: "MCP는 AI 에이전트 시대의 표준 프로토콜이 될 것이다"

| 항목 | 내용 |
|------|------|
| **근거** | 샘 알트먼의 ChatGPT MCP 도입 발표, 기업들의 공식 MCP 서버 제공 추세 |
| **근거 유형** | 실증적 (외부 발표 인용) — 단 검증 불가한 2차 인용 |
| **한계** | Google(Gemini), Microsoft(Copilot) 등 경쟁 AI 생태계의 동향 미언급. 독자적 프로토콜을 고수하는 대형 플레이어로 인해 MCP가 표준이 안 될 수도 있다 |
| **반론/대안** | USB-C처럼 산업 표준으로 자리잡으려면 오픈 거버넌스 체계와 주요 플랫폼들의 공식 채택이 선행되어야 한다. Google의 A2A Protocol 등 경쟁 프로토콜 동향도 모니터링 필요 |

---

## 5. 팩트체크 대상

- **주장**: "샘 알트먼이 ChatGPT에도 MCP를 도입하기로 결정했다" | **검증 필요 이유**: 영상 제작 시점(2025-04-05) 기준의 발표이며, 실제 ChatGPT에 MCP가 통합되었는지 및 통합 범위 확인 필요 | **검증 방법**: OpenAI 공식 블로그/릴리즈 노트, MCP 공식 사이트(modelcontextprotocol.io) 파트너 목록 확인

- **주장**: "파이어크롤(Firecrawl) 무료 티어에서 신용카드 정보 없이도 테스트 가능하다" | **검증 필요 이유**: SaaS 요금제 정책은 자주 변경되며, 영상 이후 유료 전환이나 무료 한도 변경이 있었을 수 있음 | **검증 방법**: Firecrawl 공식 사이트(firecrawl.dev) 현재 요금제 페이지 직접 확인

- **주장**: "노션 MCP는 공식 서버 없이 커뮤니티 서버만 존재한다" | **검증 필요 이유**: 영상 제작 이후 Notion이 공식 MCP 서버를 출시했을 가능성이 있으며, 영상에서 언급한 'sko 버전' 커뮤니티 서버의 현재 유지보수 상태도 확인 필요 | **검증 방법**: Anthropic 공식 MCP 레포지토리(github.com/modelcontextprotocol/servers)의 최신 서드파티/공식 서버 목록 확인

---

## 6. 실행 가능 항목

- [ ] **[즉시] Business 워크스페이스 MCP 현황 감사**: 현재 설치된 MCP 서버 목록(Notion, Filesystem, Sequential Thinking 등)이 올바르게 구성되어 있는지 확인 — *Business workspace 운영자*

- [ ] **[단기] Firecrawl MCP 검토**: Business S1 리서치 단계에서 경쟁사 사이트·시장 데이터 크롤링 자동화 가능성 평가. 현재 WebSearch 내장 도구 대비 깊이 있는 크롤링이 필요한 케이스 식별 — *SIGIL S1 리서치 시*

- [ ] **[단기] Puppeteer MCP vs Playwright CLI 비교**: Business 워크스페이스는 `@playwright/cli`(npm global) 전환 완료. Puppeteer MCP가 추가로 제공하는 가치(비코딩 브라우저 자동화)가 있는지 실용성 평가 — *스킬 담당자*

- [ ] **[중기] Slack MCP 파이럿**: 영상의 실습 패턴(크롤링→리포트→Slack 전송)을 Business `cron` + daily-system-review 파이프라인에 연동하는 가능성 검토. 현재 로그 파일 생성에 그치는 리포트를 Slack 채널로 자동 발행 가능 여부 평가 — *daily-system-review 자동화 담당*

- [ ] **[중기] MCP 서버 안정성 fallback 패턴 명시화**: 영상에서 언급된 버그·중단 이슈를 감안해, Business MCP 서버별 fallback 처리(MCP 실패 시 내장 도구로 자동 전환) 패턴을 `business-core.md`에 추가 — *규칙 관리자*

- [ ] **[참고] MCP 공식 서버 목록 월 1회 리뷰**: github.com/modelcontextprotocol/servers 레포지토리를 월 1회 확인하여 새로 추가된 서드파티 공식 서버 중 Business 워크스페이스에 유용한 것을 식별 — *시스템 관리자*

---

## 7. 시스템 적용 맥락

| 영상 제안 | 현재 상태 | 갭 | 우선순위 |
|----------|----------|-----|---------|
| JSON 설정으로 MCP 서버 설치 | Business: Notion, Filesystem, Sequential Thinking, NanoBanana, Stitch, Lighthouse, A11y MCP 설치 완료 (`--scope project`/`--scope user` 방식) | 이미 구축됨. 서버별 fallback 로직 미정의 | 낮음 |
| Firecrawl로 경쟁사 사이트 크롤링 | SIGIL S1 리서치에서 WebSearch 내장 도구 사용 | 단일 URL 심층 크롤링이 필요한 경우 Firecrawl이 보완 가능. 현재 미설치 | 중간 — S1 리서치 품질 향상 필요 시 도입 검토 |
| Slack MCP로 리포트 자동 전송 | daily-system-review: cron 후 로컬 로그 파일 저장에 그침 (`scripts/weekly-report/logs/`) | Slack 알림 채널 미운영 → 리포트 가시성 낮음 | 중간 — Slack 워크스페이스 운영 여부에 따라 결정 |
| Puppeteer로 비코딩 브라우저 자동화 | Playwright CLI(npm global) 전환 완료, 스킬로 관리 | Puppeteer MCP는 Claude 내에서 프롬프트만으로 실행되나 안정성 낮음. Playwright CLI가 더 안정적 | 낮음 — 현재 Playwright CLI로 충분 |
| Notion MCP로 리포트 자동 저장 | Notion MCP 설치 완료, SIGIL 파이프라인에서 2-tier fallback 구현 | 이미 활용 중. 영상의 채널 리포트 패턴을 weekly-research Notion 저장에 최적화 적용 가능 | 낮음 — 패턴 최적화만 검토 |
| MCP 서버 GitHub 목록 정기 모니터링 | 별도 모니터링 체계 없음 | 신규 유용 서버 발견 지연 가능성 | 낮음 — 월 1회 수동 리뷰로 충분 |
| 다중 MCP 서버 동시 활용 (토큰 영향) | `trine-context-management.md`에 "MCP 서버 상시 로드 시 도구 정의만으로 상당한 토큰 소비" 규칙 반영됨 | MCP Tool Search(레이지 로딩) 활성화로 일부 완화. 추가 최적화 여지 있음 | 낮음 — 현재 규칙으로 인지·관리 중 |

---

## 8. 관련성

| 프로젝트 | 점수 | 이유 |
|---------|------|------|
| **Portfolio** | 2/5 | Portfolio 개발(Next.js + NestJS)에 직접적인 기술 내용 없음. MCP 설치 방법은 이미 구현된 내용이며, Puppeteer 자동화는 Playwright CLI로 대체됨 |
| **GodBlade** | 1/5 | Unity C# 게임 개발과 MCP 서버 설치 튜토리얼 간 관련성 거의 없음 |
| **비즈니스** | 4/5 | Business 워크스페이스 MCP 운영 체계 직접 관련. Firecrawl(S1 리서치 강화), Slack MCP(리포트 자동화), Notion MCP 활용 패턴 개선에 참고 가능. 단, 영상 내용 대부분이 이미 구현된 상태라 새로운 인사이트는 제한적 |

---

## 핵심 인용

> "MCP를 활용하면 그냥 서버만 설치해서 표준화된 방식으로 쉽게 여러 서비스를 적용할 수 있으니까 AI 에이전트를 만들기가 훨씬 수월해지겠죠."
> — 시민개발자 구씨, [🕐 02:50](https://youtu.be/fkqXQOjj8cA?t=170)

> "MCP 서버는 아직 도입된지 얼마 안 된 프로토콜이기 때문에 모든 MCP 서버들이 잘 돌아가는 건 아닌데요. 몇 가지 서버 설치해서 테스트해 보시다 보면 잘 작동하는 것도 있고 어떤 경우에는 버그가 발생하거나 실행하다가 도중에 멈추거나 하는 것들도 존재합니다."
> — 시민개발자 구씨, [🕐 24:50](https://youtu.be/fkqXQOjj8cA?t=1490)

---

## 추가 리서치 필요

- **MCP 표준화 현황 2025-2026**: Anthropic 외 Google(A2A Protocol)·Microsoft·OpenAI의 MCP 채택 또는 경쟁 프로토콜 동향
- **Claude Code vs Claude Desktop MCP 차이**: Business 워크스페이스는 Claude Code(CLI) 기반인데 영상은 Claude Desktop 기준 시연. `--scope project`/`--scope user` 방식과 `claude_desktop_config.json` 방식의 동작 차이 심층 확인
- **Firecrawl vs WebSearch vs Playwright CLI 벤치마크**: S1 리서치에서 각 도구의 크롤링 품질·속도·비용 비교 데이터
