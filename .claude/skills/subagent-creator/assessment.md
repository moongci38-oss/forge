---
skill: subagent-creator
version: 2
---

# Assessment: subagent-creator

## 테스트 입력

- input_1: "Create a code review subagent that checks for security issues and best practices after code changes"
- input_2: "Create a documentation writer subagent that generates markdown docs from source code"
- input_3: "Create a test runner subagent that runs the test suite and reports failures with context"

## 평가 기준 (Yes/No)

1. 에이전트 정의 존재: YAML frontmatter가 코드블록 안에 포함되어 있거나, 에이전트 파일이 생성/이미 존재한다는 안내가 있는가?
2. 이름과 역할 명시: 에이전트 이름과 역할(무엇을 하는 에이전트인지)이 출력에 명확히 설명되어 있는가?
3. 자동 실행 조건: "proactively", "after", "when", "Use" 등 에이전트가 언제 실행되는지가 언급되어 있거나, 기존 에이전트의 용도/기능 설명이 포함되어 있는가?
4. 저장 경로 안내: `.claude/agents/` 또는 `~/.claude/agents/` 경로가 출력에 언급되어 있는가?
5. 구현 완료 또는 가이드: 에이전트 파일이 실제 생성되었거나, 기존 에이전트가 존재한다는 안내가 있거나, 생성 방법이 구체적으로 안내되어 있는가?

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상
