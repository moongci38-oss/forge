---
skill: hook-creator
version: 1
---

# Assessment: hook-creator

## 테스트 입력

- input_1: "Create a hook that logs all bash commands to ~/.claude/bash-history.log"
- input_2: "Block any attempt to edit .env files and show a warning"
- input_3: "Auto-format Python files with black after every edit"

## 평가 기준 (Yes/No)

1. JSON 구조 존재: 출력에 "hooks" 키를 포함하는 JSON 코드 블록이 존재하는가?
2. 유효한 이벤트: 이벤트 이름이 PreToolUse, PostToolUse, Notification, Stop 중 하나인가?
3. matcher 존재: "matcher" 필드가 존재하고 값이 비어있지 않은가? ("*", "Bash", "Edit|Write" 등)
4. command 존재: "command" 필드가 존재하고 실행 가능한 셸 명령(bash, python3, jq 등)을 포함하는가?
5. 저장 위치 안내: 설정 파일 경로(~/.claude/settings.json 또는 .claude/settings.json)가 언급되어 있는가?

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
