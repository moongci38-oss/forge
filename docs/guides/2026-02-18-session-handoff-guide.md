# Claude Code 세션 이동 가이드 (VSCode ↔ 터미널 ↔ 웹)

**작성일**: 2026-02-18

---

## 핵심 원리

Claude Code는 **세션 저장소를 공유**한다. VSCode 채팅 패널, 통합 터미널 CLI, claude.ai 웹 어디서 만든 세션이든 동일한 `~/.claude/sessions/`에 저장되므로 환경 간 자유롭게 이동 가능.

---

## 1. VSCode 내 이동 (채팅 패널 ↔ 터미널 CLI)

### 채팅 패널 → 터미널 CLI
- **Command Palette** (`Ctrl+Shift+P`) → **"Claude Code: Open in Terminal"** 실행
- 또는 터미널(`Ctrl+``)을 열고:
  ```bash
  claude --resume              # 대화형 세션 선택 UI
  claude -r "세션이름"          # 이름으로 바로 재개
  ```

### 터미널 CLI → 채팅 패널
1. VSCode에서 Claude Code 채팅 패널 열기
2. 상단 **Past Conversations** 드롭다운 클릭
3. 키워드 검색 또는 시간순 탐색 (Today, Yesterday 등)
4. 터미널에서 했던 세션 선택 → 전체 대화 이력과 함께 재개

### VSCode 설정 옵션
- Settings → Extensions → Claude Code → **Use Terminal** 체크 시 기본 실행이 터미널 모드로 변경

---

## 2. 외부 환경 간 이동

### claude.ai 웹 → 로컬 (터미널/VSCode)
```bash
claude --teleport            # 웹 세션을 로컬로 가져오기
```
또는 VSCode에서:
1. Past Conversations → **Remote** 탭
2. claude.ai 세션 목록에서 선택 → 로컬로 다운로드 후 재개

### 로컬 → Claude Desktop 앱
```bash
/desktop                     # CLI에서 Desktop 앱으로 핸드오프
```

---

## 3. 주요 명령어

| 명령어 | 설명 |
|--------|------|
| `claude --resume` / `-r` | 세션 선택 UI (대화형) |
| `claude -r "이름"` | 이름으로 세션 재개 |
| `claude -c` / `--continue` | 현재 디렉토리의 가장 최근 세션 이어서 |
| `claude -r "이름" "추가 질문"` | 세션 재개 + 즉시 새 프롬프트 전달 |
| `claude --fork-session` | 세션 분기 (원본 유지, 새 브랜치 생성) |
| `/rename 이름` | 세션 내에서 이름 변경 (나중에 찾기 쉽도록) |
| `/teleport` | claude.ai 원격 세션 로컬로 가져오기 |
| `/desktop` | CLI에서 Desktop 앱으로 핸드오프 |

---

## 4. 세션 이동 시 보존되는 것 / 안 되는 것

### 보존됨
- 전체 대화 이력 (메시지, 응답)
- 파일 편집 내역
- 세션 ID, 작업 디렉토리
- CLAUDE.md 설정
- 모델 선택 (Opus, Sonnet 등)

### 보존 안 됨
- 백그라운드 작업 (재시작 필요)
- 터미널 상태 (bash 환경변수 등)

---

## 5. 실전 워크플로우

### VSCode 채팅에서 시작 → 터미널에서 마무리
```
1. VSCode 채팅 패널에서 작업 진행
2. /rename feature-auth 로 세션 이름 부여
3. Ctrl+` 로 터미널 열기
4. claude -r "feature-auth" "남은 작업 마무리해줘"
```

### 터미널에서 시작 → VSCode 채팅에서 리뷰
```
1. 터미널: claude "새 기능 구현해줘"
2. VSCode 채팅 패널 열기
3. Past Conversations → 해당 세션 선택
4. IDE 통합 기능으로 변경사항 리뷰
```

### 웹에서 시작 → 로컬에서 이어서
```
1. claude.ai Cowork 탭에서 작업 시작
2. 로컬 터미널: claude --teleport
3. 웹 세션 이력 그대로 로컬에서 계속
```

---

## 6. 팁

- **세션 이름 붙이기**: `/rename`으로 의미 있는 이름을 주면 나중에 찾기 쉬움
- **`-c` vs `-r`**: 빠르게 직전 세션 이어가려면 `claude -c`, 특정 세션 골라서 가려면 `claude -r`
- **`--fork-session`**: 같은 세션에서 다른 방향을 시도하고 싶을 때 분기
- **Remote 탭 조건**: claude.ai 구독 + GitHub 레포 컨텍스트가 있는 세션만 Remote 탭에 표시
- **Command Palette 명령어**: `Claude Code: Open in Terminal`, `Open in Side Bar`, `Open in New Tab`, `Open in New Window`

---

*출처: Claude Code 공식 문서 (2026-02)*
