# 이 영상 하나만 보시면 됩니다. | 모든 Claude Code 세팅, 효과적인 워크플로우, 추천하는 서비스들

> 개발동생 | 56.1K views | 30:13
> 원본: https://youtu.be/Ek_I0iFyyZU

---

> **자막 신뢰도: Medium** (`is_generated_subtitle: true` — AI 자동 생성)
> 주요 오류: "연료" = 완료, "훅수/쿠스" = 훅스(Hooks), "차드 CN" = shadcn/ui,
> "프리티어" = Prettier, "서버에트" = 서브에이전트, "클로드.닷m" = CLAUDE.md
> 수치(78.95%)는 문맥상 원문 인용으로 처리. 독립 검증 필요.

---

## 1. TL;DR

Claude Code의 핵심 설정(CLAUDE.md, MCP, Hooks, 서브에이전트, 슬래시 명령어, 권한 설정)과 추천 서드파티 서비스(cc-usage, SuperClaude, claudecodetemplate)를 30분 안에 실습 위주로 훑는 입문자 친화적 가이드로, 커서(Cursor)에서 Claude Code로 전환을 고려하는 한국어권 개발자를 주 대상으로 한다.

---

## 2. 카테고리

**tech/ai** | **tech/devtools**

`#claude-code` `#mcp` `#subagent` `#hooks` `#ai-coding` `#workflow` `#cursor-migration` `#parallel-agents` `#한국어`

---

## 3. 핵심 포인트

1. **[🕐 00:51](https://youtu.be/Ek_I0iFyyZU?t=51) `/init` 명령어로 CLAUDE.md 자동 생성** — 프로젝트를 직접 분석해 코드베이스 구조, 프레임워크, 아키텍처를 CLAUDE.md에 기록. 이후 모든 프롬프트의 시스템 컨텍스트 최상단에 삽입됨. 커서의 `.cursorrules`와 동등한 역할.

2. **[🕐 03:02](https://youtu.be/Ek_I0iFyyZU?t=182) MCP 서버 스코프 3단계** — local / project(`.mcp.json`) / user 스코프로 연동 가능. `claude mcp add` 명령 또는 `.mcp.json` 직접 편집. `claude mcp` 명령으로 연결 상태 확인.

3. **[🕐 04:57](https://youtu.be/Ek_I0iFyyZU?t=297) Claude Sonnet 4 MCP 벤치마크 1위** — 95개 일상 태스크 + 527개 MCP 도구 환경 테스트에서 78.95% 성공률로 1위. 실제로 Claude Code에서 MCP 사용 시 다른 모델 대비 체감 성능 차이가 있다고 주장. (논문 출처 미언급 — 팩트체크 필요)

4. **[🕐 05:37](https://youtu.be/Ek_I0iFyyZU?t=337) Plan Mode(`Shift+Tab`)와 Accept Edit Mode 2단계 전환** — 먼저 Plan Mode로 계획을 수립한 뒤, 계획 확정 후 Accept Edit Mode로 코드 변경. 발표자 개인 권장 워크플로우.

5. **[🕐 06:13](https://youtu.be/Ek_I0iFyyZU?t=373) `/config` → `useTodoList` + Output Style 커스터마이징** — 복잡한 작업을 소단위 체크리스트로 자동 분해. 기본 3종(Default / Verbose / Learning) 외 `/output-style new` 명령으로 사용자 정의 스타일 생성. `.claude/output-styles/` 폴더에 저장.

6. **[🕐 09:23](https://youtu.be/Ek_I0iFyyZU?t=563) 서브에이전트 병렬 실행으로 개발 속도 N배 향상** — `.claude/agents/` 폴더에 마크다운으로 에이전트 정의(역할/도구/모델/색상). `/agents create new agent` 명령으로 Claude가 초안 자동 생성. 자연어로 "에이전트 4개 병렬 처리" 지시 가능. 각 에이전트가 독립 컨텍스트 보유.

7. **[🕐 12:40](https://youtu.be/Ek_I0iFyyZU?t=760) Hooks — LLM 응답과 무관하게 쉘 명령 보장 실행** — `settings.json`에 이벤트별 쉘 명령 등록. 주요 이벤트: `stop`(응답 완료), `PostToolUse`(도구 사용 후). 활용 사례: TTS 알림, 확장자별 포매터 자동 실행(JS→Prettier, Python→Black), 파일 생성 후 `git add` 자동 스테이징. CLAUDE.md는 "LLM이 따르면 좋겠는 규칙"인 반면 Hooks는 "반드시 실행되는 명령".

8. **[🕐 17:35](https://youtu.be/Ek_I0iFyyZU?t=1055) 기능 단위 세션 분리 — `/clear`, `/resume`, `/export`** — 컨텍스트 오버플로 방지를 위해 기능 완료 시 `/clear`. 이전 세션은 `/resume`으로 복구. `/export`로 대화 내역을 클립보드/파일로 추출해 Cursor로 이관 가능. 커스텀 슬래시 명령어는 `.claude/commands/` 폴더에 `.md` 파일로 정의.

9. **[🕐 22:25](https://youtu.be/Ek_I0iFyyZU?t=1345) `--dangerously-skip-permissions` + Dev Container 조합** — 완전 자율 모드 활성화 시 Dev Container(Dockerfile + 커스텀 방화벽) 내에서 실행 권장. Anthropic 제공 `.devcontainer/` 설정 파일(Dockerfile, devcontainer.json, 방화벽 스크립트) 다운로드 후 VS Code Dev Containers 확장 사용. 허용된 네트워크에만 접근 가능한 격리 환경.

10. **[🕐 25:40](https://youtu.be/Ek_I0iFyyZU?t=1540) 추천 서드파티 서비스 3종** — ① `npx cc` (cc-usage): 일별 입출력 토큰/캐시/비용 시각화 ② SuperClaude: 페르소나 자동 전환(Architect/Frontend/Backend) + 사전 구축 커스텀 명령어 ③ claudecodetemplate.com: 필요한 Hooks/Commands/MCP 템플릿만 장바구니 선택 후 일괄 설치.

---

## 4. 비판적 분석

### 주장 1: "Claude Sonnet 4가 MCP 벤치마크에서 78.95% 성공률로 모든 LLM 중 1위"
- **근거**: 발표자가 논문 인용. 95개 과제, 527개 MCP 도구 환경에서 Claude Sonnet 4 최고 성능.
- **근거 유형**: 실증적 (타인 연구) — 단, 원문 검증 불가
- **한계**: 논문명, 저자, 게재처, 발표일, 비교 대상 모델 미언급. 자동 생성 자막 특성상 수치 오류 가능성. 벤치마크 설계 공정성(Anthropic 친화적 태스크 선정 여부) 불명.
- **반론/대안**: MCP 성능은 모델 지능 외에도 프롬프트 설계, 도구 정의 품질, 시스템 설정에 크게 의존. 단일 벤치마크가 실사용 성능을 대표하지 않을 수 있음.

### 주장 2: "서브에이전트 병렬 처리가 단순 병렬 실행보다 컨텍스트 최적화가 더 잘 된다"
- **근거**: shadcn/ui 마이그레이션 4개 에이전트 병렬 데모 시연.
- **근거 유형**: 실증적 (단일 사례 데모)
- **한계**: "컨텍스트 최적화" 메커니즘 설명 없음. 단순 컨텍스트 격리(isolation)인지 실제 최적화인지 불명확. 파일 충돌, race condition, API rate limit 이슈 미언급.
- **반론/대안**: 서브에이전트는 에이전트마다 공통 프로젝트 지식을 별도 로딩해 토큰 비용이 N배. "4배 빠름"은 시간 기준이지 비용 기준이 아님. 파일 의존성이 높은 작업은 병렬화 효과가 제한적.

### 주장 3: "Hooks가 LLM 응답과 별개로 동작을 보장한다"
- **근거**: stop 이벤트에 TTS 알림, PostToolUse에 git add, 포매터 자동 실행 데모.
- **근거 유형**: 실증적 (라이브 데모)
- **한계**: Hooks 스크립트 오류 시 Claude Code 동작(중단/무시/경고) 미언급. 보안 위험(임의 쉘 실행). git add 자동화는 의도치 않은 파일 스테이징 위험.
- **반론/대안**: lint-staged, husky pre-commit hook 등 기존 도구와의 충돌 가능성. 스테이징 전 diff 확인 Hooks 추가가 안전. 팀 환경에서는 개인 Hooks가 CI/CD와 불일치 유발 가능.

### 주장 4: "기능 단위 세션 분리로 LLM 성능 유지"
- **근거**: 하나의 세션에서 오래 개발하면 컨텍스트 포화로 성능 저하 경험 기반.
- **근거 유형**: 경험적 (1인 관찰)
- **한계**: `/compact`로 컨텍스트 압축 후 유지하는 대안과 비교 없음. 세션 분리 시 이전 컨텍스트(코드 패턴, 결정 사항) 유실.
- **반론/대안**: `/compact` 활용이 더 효율적인 경우도 있음. 세션 분리보다 CLAUDE.md 품질 관리(영속 컨텍스트 정의)가 근본 해결책.

### 주장 5: "Dev Container를 사용하면 bypass-permissions 모드를 안전하게 활용할 수 있다"
- **근거**: Anthropic 제공 Docker 기반 격리 환경 + 커스텀 방화벽 설정.
- **근거 유형**: 기술적 설명 (공식 지원 도구)
- **한계**: 방화벽 규칙이 실제로 얼마나 강력한지, 사이드채널 공격 방어 수준 미언급. Docker 환경 설정 복잡도.
- **반론/대안**: WSL 기반 환경도 어느 정도 격리 제공. 완전 자율 모드는 꼭 필요한 경우에만 사용이 원칙.

---

## 5. 팩트체크 대상

- **주장**: "Claude Sonnet 4가 MCP 벤치마크에서 78.95% 성공률로 1위" | **검증 필요 이유**: 논문 출처(제목, 저자, 게재처) 미언급. 자막 특성상 수치 오류 가능. | **검증 방법**: 영상 설명란 링크 확인 → `arXiv MCP benchmark LLM evaluation 2025 Claude Sonnet 527 tools` 검색 → 원문 방법론 및 비교 모델 목록 검토.

- **주장**: "Output Style 기능으로 Learning 모드 등 커스텀 스타일 생성 가능" | **검증 필요 이유**: 영상 게시일 불명확. 2026-03-10 기준 인터페이스 변경 가능성. `/output-style new` 명령이 현재 버전에도 동일하게 존재하는지 불명. | **검증 방법**: Anthropic 공식 Claude Code 문서 또는 GitHub 릴리즈 노트에서 현재 Output Style 기능 상태 확인.

- **주장**: "SuperClaude가 작업 성격에 따라 Architect/Frontend/Backend 페르소나를 자동으로 전환한다" | **검증 필요 이유**: 서드파티 서비스로 유지보수 상태, 공식 Claude Code 업데이트와의 충돌 가능성 미언급. | **검증 방법**: SuperClaude GitHub 저장소 최종 커밋 날짜 및 열린 이슈 확인. 실제 설치 후 복잡한 태스크로 페르소나 전환 동작 검증.

---

## 6. 실행 가능 항목

- [ ] **Hooks 도입 (Business 워크스페이스)** — `settings.json`의 `hooks` 필드에 `stop` 이벤트 등록: 장시간 작업 완료 시 WSL 알림(`powershell.exe -c "[console]::beep(1000,500)"`). daily-review, weekly-research 자동화 스크립트와 연계. (대상: business 워크스페이스 `~/.claude.json` 또는 `.claude/settings.json`)

- [ ] **cc-usage 설치 — 비용 모니터링** — `npx cc`로 일별 토큰/비용 현황 파악. 월별 Claude Code 예산 관리에 활용. (즉시 실행 가능)

- [ ] **Portfolio `.claude/agents/` 표준화** — 현재 Trine 에이전트 정의를 Claude Code 네이티브 `.claude/agents/` 마크다운 파일로도 정의. `frontend-dev.md`(Next.js + Tailwind), `backend-dev.md`(NestJS + TypeORM), `test-writer.md`(TDD Red-Green) 최소 3종.

- [ ] **PostToolUse Hooks — ESLint/Prettier 자동화 (Portfolio)** — `.ts`, `.tsx` 파일 변경 후 Prettier 자동 실행 Hooks 등록. git add 자동화는 의도치 않은 스테이징 위험으로 보류.

- [ ] **Hooks → 규칙 빌드 자동화 (Business)** — `09-tools/rules-source/` 내 `.md` 파일 변경 감지 후 `manage-rules.sh build` 자동 실행 Hooks 검토. 현재 수동 단계 제거 가능.

- [ ] **claudecodetemplate.com 탐색** — 현재 구현된 Hooks/Commands 패턴과 중복되는 커뮤니티 템플릿 확인. 중복 구현 방지 및 아직 구현하지 않은 유용한 패턴 발굴.

- [ ] **`useTodoList` 활성화 확인** — `/config`에서 `useTodoList: true` 상태 확인 및 활성화. SIGIL 리서치 병렬 작업의 단계별 진행 추적에 활용.

---

## 7. 시스템 적용 맥락

| 영상 제안 | 현재 상태 | 갭 | 우선순위 |
|-----------|----------|-----|---------|
| CLAUDE.md `/init` + 규칙 추가 | `.claude/rules/` 기반 Rules-as-Code 체계로 CLAUDE.md보다 정교하게 운영. `sigil-compiled.md`, `business-core.md` 등 컴파일된 규칙 자동 로드 | 이미 초과 달성. CLAUDE.md 프로젝트 구조 설명 섹션만 보완 여지 | 낮음 |
| MCP 3스코프(local/project/user) | user 스코프(NanoBanana, Stitch, Lighthouse, A11y, Notion) + project 스코프(filesystem) 운영 중 | 현재 구성과 완전 일치. 추가 MCP 도입 시 스코프 결정 기준 이미 `business-core.md`에 정의 | 없음 |
| Hooks 이벤트 자동화 | Hooks 개념 인지, 실제 `settings.json` Hooks 미구성 | **갭 존재**. PostToolUse에 포매터, 규칙 빌드 자동화, 알림 연계 여지. Trine Check 3와 연계 가능 | **높음** |
| 기능 단위 세션 분리 + `/clear` | Trine session-state 체계 + `/compact` 규칙(`trine-context-management.md`)으로 이미 관리 | 이미 초과 달성. `/compact`가 `/clear`보다 더 정교한 전략 | 없음 |
| 서브에이전트 병렬 실행 | Subagent Fan-out/Fan-in 기본 도구 전환 완료(2026-03-10). Wave 기반 의존성 관리, 파일 소유권 선언 규칙 | 영상 제안보다 훨씬 정교한 체계 운영 중 | 없음 |
| Plan Mode → Accept Edit 2단계 | Trine Phase 2(Spec/Plan) → Phase 3(구현)이 더 정교한 2단계 구현 | 이미 초과 달성 | 없음 |
| Output Style 커스터마이징 | Skills/Agents 체계로 출력 스타일보다 정교한 페르소나 관리 | 현재 체계가 더 우수. `.claude/output-styles/`는 Skill 호출 불가한 간단 세션용으로 보완 가치 | 낮음 |
| cc-usage 비용 모니터링 | 비용 모니터링 도구 미도입 | **갭 존재**. `npx cc`로 일별 토큰/비용 파악 → 월별 Claude Code 예산 관리에 직접 활용 | **높음** |
| Dev Container + bypass-permissions | 완전 자율 모드 미사용. WSL 기반 작업 환경이 어느 정도 격리 제공 | 대규모 자율 실행 필요 시 `.devcontainer/` 구성 검토. 현재는 낮은 필요성 | 낮음 |
| SuperClaude / claudecodetemplate | 자체 Skills/Agents/Commands 체계로 동등 기능 이미 구현 | 커뮤니티 Hooks/Commands 패턴에서 아직 구현 안 한 유용한 것 탐색 용도 | 낮음 |

**시스템별 핵심 시사점:**
- **Hooks 미도입**: Claude Code 네이티브 기능 중 유일한 실질적 갭. `PostToolUse`에 포매터/규칙빌드/알림 연결로 수동 단계 제거 가능.
- **cc-usage**: 비용 가시성 확보. 월별 예산 관리를 위한 즉시 설치 권장.
- **나머지**: 이미 영상 제안을 초과 달성하는 정교한 체계 운영 중.

---

## 8. 관련성

| 프로젝트 | 점수 | 이유 |
|---------|------|------|
| **Portfolio** | 4/5 | 서브에이전트 파일 표준화, Hooks 포매터 자동화, shadcn/ui 병렬 마이그레이션 패턴 직접 적용 가능. Trine Check 3와 Hooks 연동 검토 가치. |
| **GodBlade** | 2/5 | CLAUDE.md 구조 정의, Unity C# 전문 에이전트 생성에 적용 가능. 영상 예시가 JS/TS 중심이어서 C# 환경 적용 시 변환 필요. |
| **비즈니스** | 4/5 | Hooks 알림 자동화, 비용 모니터링(cc-usage), 규칙 빌드 자동화에 직접 적용 가능. SIGIL 병렬 리서치 에이전트 패턴이 영상의 서브에이전트 구조와 동일함을 확인. |

---

## 핵심 인용

> "클로드 코드의 훅스라는 기능을 통해서 사용자가 셸 명령을 등록하게 되면은 클로드 코드가 동작하는 과정 중에서 다양한 시점에 원하는 작업을 자동으로 실행해 줄 수 있게 만들어 주는 그런 기능 중에 하나입니다."

→ CLAUDE.md(소프트 규칙, LLM이 따르는 것)와 Hooks(하드 강제, 반드시 실행)의 역할 분리가 핵심. 현재 `business-core.md`의 "Do/Don't" 규칙 체계는 소프트 규칙 영역에 해당하며, 일부 품질 게이트는 Hooks로 하드 강제로 격상 가능.

---

## 추가 리서치 필요

- **MCP 벤치마크 논문 원문**: 영상 설명란 링크 확인 후 `arXiv MCP benchmark LLM evaluation Claude Sonnet 527 tools 2025` 검색. 원문 방법론, 비교 모델 목록, 2위 모델 성능 확인.
- **Claude Code Hooks 공식 문서 전체 이벤트 목록**: `PreToolUse`, `PostToolUse`, `stop` 외 추가 이벤트 유형 파악. Trine Check 3(lint/build/test) 자동화 연동 가능성 탐색.

---

*분석 생성: 2026-03-10 | 전체 transcript(30:13) 분석 완료.*
