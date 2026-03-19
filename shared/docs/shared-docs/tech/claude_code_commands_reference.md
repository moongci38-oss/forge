# Claude Code 전체 명령어 / 스킬 / 플러그인 정리

> 현재 세션 기준 사용 가능한 모든 항목을 카테고리별로 정리

---

## 1. 내장 슬래시 명령어 (Built-in CLI Commands)

| 명령어 | 설명 | 인자 |
|--------|------|------|
| `/help` | 사용법 도움말 | - |
| `/clear` | 대화 기록 초기화 | - |
| `/compact [instructions]` | 대화 압축 (컨텍스트 절약) | 선택: 포커스 지시 |
| `/config` | 설정 인터페이스 열기 | - |
| `/context` | 현재 컨텍스트 사용량 시각화 | - |
| `/cost` | 토큰 사용량 통계 | - |
| `/copy` | 마지막 응답 클립보드 복사 | - |
| `/debug [desc]` | 디버그 로그로 세션 문제 진단 | 선택: 설명 |
| `/doctor` | Claude Code 설치 상태 점검 | - |
| `/exit` | REPL 종료 | - |
| `/export [filename]` | 대화 내보내기 (파일/클립보드) | 선택: 파일명 |
| `/init` | `CLAUDE.md` 초기화 가이드 | - |
| `/mcp` | MCP 서버 연결 관리 | - |
| `/memory` | `CLAUDE.md` 메모리 파일 편집 | - |
| `/model` | AI 모델 선택/변경 | - |
| `/permissions` | 권한 확인/수정 | - |
| `/plan` | Plan 모드 진입 | - |
| `/rename <name>` | 현재 세션 이름 변경 | 필수: 이름 |
| `/resume [session]` | 이전 세션 복원 | 선택: 세션ID/이름 |
| `/rewind` | 대화/코드 되감기 | - |
| `/stats` | 일일 사용량, 세션 히스토리 시각화 | - |
| `/status` | 버전, 모델, 계정 정보 | - |
| `/statusline` | 상태줄 UI 설정 | - |
| `/tasks` | 백그라운드 작업 목록/관리 | - |
| `/teleport` | claude.ai 원격 세션 복원 | - |
| `/theme` | 색상 테마 변경 | - |
| `/todos` | TODO 항목 목록 | - |
| `/usage` | 플랜 사용량/레이트리밋 확인 | - |
| `/vim` | Vim 편집 모드 활성화 | - |

---

## 2. 공식 플러그인 스킬 (Marketplace Plugins)

### 2.1 문서 생성 플러그인

| 스킬 | 트리거 | 설명 |
|------|--------|------|
| `/pdf` | PDF 관련 모든 작업 | PDF 읽기, 합치기, 분할, 회전, 워터마크, 폼 채우기, OCR |
| `/xlsx` | 스프레드시트 작업 | Excel/CSV 읽기, 편집, 생성, 차트, 서식, 데이터 정리 |
| `/docx` | Word 문서 작업 | .docx 생성, 편집, TOC, 헤더, 페이지번호, 이미지 삽입 |
| `/pptx` | 프레젠테이션 작업 | 슬라이드 생성, 편집, 템플릿, 노트, 합치기/분할 |

### 2.2 프론트엔드/디자인 플러그인

| 스킬 | 트리거 | 설명 |
|------|--------|------|
| `/frontend-design` | 웹 UI 빌드 요청 | 고품질 프로덕션급 프론트엔드 인터페이스 생성 (React, Tailwind) |
| `/web-artifacts-builder` | 복잡한 HTML Artifact | React 18 + shadcn/ui 멀티컴포넌트 아티팩트 빌드 |
| `/theme-factory` | 테마 적용 | 10개 프리셋 테마 + 커스텀 테마 생성, 아티팩트에 적용 |
| `/webapp-testing` | 웹앱 테스트 | Playwright 기반 로컬 웹앱 테스트, 스크린샷, 디버깅 |

### 2.3 Claude Code 확장 플러그인

| 스킬 | 트리거 | 설명 |
|------|--------|------|
| `/keybindings-help` | 키보드 단축키 커스텀 | `~/.claude/keybindings.json` 편집 가이드 |
| `/hook-creator` | Hook 생성/설정 | PreToolUse, PostToolUse 등 이벤트 훅 설정 |
| `/slash-command-creator` | 슬래시 명령어 생성 | 커스텀 슬래시 명령어 작성 가이드 |
| `/subagent-creator` | 서브에이전트 생성 | 커스텀 서브에이전트 정의 생성 |

### 2.4 Ralph Loop 플러그인

| 스킬 | 트리거 | 설명 |
|------|--------|------|
| `/ralph-loop` | Ralph Loop 시작 | 현재 세션에서 자율 루프 실행 |
| `/cancel-ralph` | Ralph Loop 취소 | 활성 Ralph Loop 중단 |
| `/ralph-loop:help` | 도움말 | Ralph Loop 플러그인 설명 |

---

## 3. Superpowers 플러그인 (워크플로우 스킬)

> 개발 워크플로우 전반을 체계화하는 고급 스킬 모음

### 3.1 계획 & 설계

| 스킬 | 트리거 시점 | 설명 |
|------|------------|------|
| `/brainstorming` | 창작/기능 구현 **전** | 요구사항 탐색, 사용자 의도 파악, 디자인 검토 |
| `/writing-plans` | Spec/요구사항 확보 후, 코딩 **전** | 멀티스텝 작업 구현 계획 수립 |

### 3.2 구현 & 실행

| 스킬 | 트리거 시점 | 설명 |
|------|------------|------|
| `/executing-plans` | 작성된 Plan이 있을 때 | 리뷰 체크포인트와 함께 계획 실행 |
| `/subagent-driven-development` | 독립 Task가 여러 개일 때 | 서브에이전트 기반 병렬 구현 |
| `/dispatching-parallel-agents` | 2+ 독립 작업 시 | 병렬 에이전트 디스패치 |
| `/test-driven-development` | 기능/버그픽스 구현 **전** | TDD 방식 (테스트 먼저 → 구현) |
| `/using-git-worktrees` | 격리된 작업 환경 필요 시 | Git worktree 기반 격리 개발 |

### 3.3 검증 & 리뷰

| 스킬 | 트리거 시점 | 설명 |
|------|------------|------|
| `/verification-before-completion` | 작업 완료 주장 **전** | 증거 기반 검증 (테스트/빌드 실행 확인 후 완료 선언) |
| `/requesting-code-review` | 주요 기능 완성 후 | 요구사항 대비 구현 검증 요청 |
| `/receiving-code-review` | 코드 리뷰 피드백 수신 시 | 기술적 엄밀성으로 피드백 검토 (맹목적 동의 방지) |
| `/systematic-debugging` | 버그/테스트 실패 발생 시 | 체계적 디버깅 (수정 제안 전 근본 원인 분석) |

### 3.4 완료 & 배포

| 스킬 | 트리거 시점 | 설명 |
|------|------------|------|
| `/finishing-a-development-branch` | 구현+테스트 완료 후 | 브랜치 통합 방법 결정 (merge/PR/cleanup) |
| `/code-review` | PR 리뷰 시 | PR 코드 리뷰 수행 |

### 3.5 메타

| 스킬 | 트리거 시점 | 설명 |
|------|------------|------|
| `/using-superpowers` | 대화 시작 시 | Superpowers 스킬 탐색/사용 가이드 |
| `/writing-skills` | 새 스킬 생성/편집 시 | 스킬 작성 및 검증 가이드 |

---

## 4. 프로젝트 커스텀 (Project-Specific)

### 4.1 커스텀 슬래시 명령어 (`.claude/commands/`)

| 명령어 | 역할 | 사용 시점 |
|--------|------|----------|
| `/architect-init` | Spec 분석 → Task 분해 + 도메인 분류 | Phase 3 시작 시 1회 ("구현해줘" 직후) |
| `/architect-assign` | Task를 Builder 서브에이전트에 할당 | `/architect-init` 후 Task별 1회 |
| `/architect-status` | 프로젝트 상태 대시보드 표시 | 언제든 (init 후) |
| `/test-all` | Frontend + Backend + E2E 병렬 테스트 | 구현 완료 후 검증 |

### 4.2 커스텀 에이전트 스킬 (`.claude/skills/agents/`)

| 에이전트 | 역할 | 모델 | 모드 |
|----------|------|------|------|
| **Orchestrator** | 전체 조율, Task 분배, State 관리 | Opus | Foreground |
| **Builder** (x3) | 코드 구현 (Frontend/Backend/Shared) | Sonnet | Background 병렬 |
| **Tester** | 테스트 작성 및 실행 | Sonnet | Background |
| **Reviewer** | 코드 리뷰 (read-only) | Sonnet | Read-only |
| **Debugger** | 에러 분석, 수정 가이드 (read-only) | Sonnet | Read-only |

### 4.3 커스텀 유틸리티 스킬 (`.claude/skills/`)

| 스킬 | 설명 |
|------|------|
| `portfolio-analyzer` | 프로젝트 소스 → 포트폴리오 콘텐츠 자동 추출 |
| `spec-to-module` | Spec → NestJS 모듈 4종 세트 자동 생성 |
| `quote-generator` | 요구사항 → 견적서 자동 생성 |

> ~~`code-reviewer`~~, ~~`skill-creator`~~ → 공식 기능으로 대체 (Ver 5.1)

---

## 5. MCP 플러그인 (Tool Providers)

| MCP 서버 | 제공 도구 | 용도 |
|----------|----------|------|
| **Playwright** | `browser_navigate`, `browser_click`, `browser_snapshot`, `browser_take_screenshot` 등 20+ | 브라우저 자동화, E2E 테스트 |
| **Context7** | `resolve-library-id`, `query-docs` | 라이브러리 최신 문서 조회 |

---

## 6. Task 서브에이전트 타입

> `Task` 도구로 spawn 가능한 전문 에이전트

| 타입 | 용도 |
|------|------|
| `Bash` | 명령어 실행 전문 |
| `Explore` | 코드베이스 탐색/검색 |
| `Plan` | 구현 계획 설계 |
| `general-purpose` | 범용 리서치/멀티스텝 |
| `claude-code-guide` | Claude Code 사용법 안내 |
| `code-simplifier` | 코드 정리/단순화 |
| `superpowers:code-reviewer` | 코드 리뷰 (Plan 대비 검증) |
| `spec-writer` | Spec 문서 작성 |
| `statusline-setup` | 상태줄 설정 |

---

## 7. 키보드 단축키 (주요)

| 단축키 | 기능 |
|--------|------|
| `Ctrl+C` | 현재 생성 취소 |
| `Ctrl+D` | 세션 종료 |
| `Ctrl+L` | 터미널 화면 클리어 |
| `Ctrl+G` | 텍스트 에디터로 열기 |
| `Ctrl+O` | Verbose 출력 토글 |
| `Ctrl+B` | 백그라운드 작업 전환 |
| `Ctrl+T` | Task 목록 토글 |
| `Shift+Tab` / `Alt+M` | 권한 모드 전환 (Auto/Plan/Normal/Delegate) |
| `Alt+P` | 모델 전환 |
| `Alt+T` | Extended Thinking 토글 |
| `Esc Esc` | Rewind (되감기) |
| `\` + `Enter` | 멀티라인 입력 |
| `!command` | 바로 Bash 실행 |
| `@path` | 파일 경로 자동완성 |

---

*Last Updated: 2026-02-10*
