---
skill: hook-creator
version: 2
---

# Assessment: hook-creator

## 테스트 입력

- input_1: "Create a hook that logs all bash commands to ~/.claude/bash-history.log"
- input_2: "Create a hook that sends a desktop notification when any git commit is made"
- input_3: "Auto-format Python files with black after every edit"

## 평가 기준 (Yes/No)

1. 훅 설정 존재: JSON 코드블록에 hooks 설정이 포함되어 있거나, 훅이 이미 존재/생성되었다는 안내가 있는가?
2. 이벤트 명시: PreToolUse, PostToolUse, Notification, Stop 중 하나의 이벤트 이름이 출력에 언급되어 있는가?
3. 동작 설명: 훅이 무엇을 하는지(로깅, 차단, 포맷팅 등) 구체적으로 설명되어 있는가?
4. 설정 경로: settings.json 또는 hooks 스크립트 경로가 출력에 언급되어 있는가?
5. 구현 완료 또는 가이드: 훅이 실제 동작 중이라는 확인이거나, 적용 방법이 구체적으로 안내되어 있는가?

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
