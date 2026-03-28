---
skill: slash-command-creator
version: 2
---

# Assessment: slash-command-creator

## 테스트 입력

- input_1: "Create a slash command that generates release notes from git log"
- input_2: "Create a slash command that runs database migrations"
- input_3: "Create a slash command for health checking all services"

## 평가 기준 (Yes/No)

1. Frontmatter 구조 안내: `---`로 감싼 YAML frontmatter 예시가 코드블록에 포함되어 있거나, `description` 필드가 언급/설명되어 있는가?
2. 파일 경로 명시: 커맨드 파일을 저장할 경로(`.claude/commands/` 또는 `~/.claude/commands/` 하위)가 명시되어 있는가?
3. 프롬프트 내용 존재: Claude에게 전달될 지시 내용(프롬프트 본문)이 코드블록 안에 포함되어 있거나, 주요 기능/동작이 구체적으로 설명되어 있는가?
4. 도구/모델 언급: `allowed-tools`, `model`, Bash 실행 등 커맨드에 필요한 도구나 설정이 언급되어 있는가?
5. 사용 예시 또는 호출 방법: `/command-name` 형태의 호출 방법이나 사용 예시가 포함되어 있는가?

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상
