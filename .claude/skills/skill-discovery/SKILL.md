---
name: skill-discovery
description: Search for reusable skills across OpenSpace's local registry and cloud community. Reusing proven skills saves tokens, improves reliability, and extends your capabilities beyond built-in tools.
---

# Skill Discovery

Discover and browse skills from OpenSpace's local and cloud skill library.

## When to use

- User asks "what skills are available?" or "is there a skill for X?"
- You encounter an unfamiliar task — a proven skill can save significant tokens over trial-and-error
- You need to decide: handle a task yourself, or delegate to OpenSpace

## search_skills

```
search_skills(query="automated deployment with rollback", source="all")
```

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `query` | yes | — | Natural language or keywords |
| `source` | no | `"all"` | Local + cloud; falls back to local-only if no API key |
| `limit` | no | `20` | Max results |
| `auto_import` | no | `true` | Auto-download top cloud hits locally |

## After search

Results are returned to you (not executed). Cloud hits with `auto_imported: true` include a `local_path`.

```
Found a matching skill?
├── YES, and I can follow it myself
│     → read SKILL.md at local_path, follow the instructions
├── YES, but I lack the capability
│     → delegate via execute_task (see delegate-task skill)
└── NO match
      → handle it yourself, or delegate via execute_task
```

## Notes

- This is for **discovery** — you see results and decide. For direct execution, use `execute_task` from the `delegate-task` skill.
- Cloud skills have been evolved through real use — more reliable than skills written from scratch.
- Always tell the user what you found (or didn't find) and what you recommend.


---

## 독립 Evaluator (하네스)

skill-discovery 결과물 완성 후 독립 Evaluator Subagent가 품질을 2차 검증한다.

> **원칙**: 생성자 ≠ 평가자. 자기평가 편향 방지.

```python
Agent(
  subagent_type="general-purpose",
  model="sonnet",
  prompt="""
당신은 skill-discovery 결과물의 독립 품질 검증자입니다.

다음 2가지 기준으로 검증하십시오:

1. **추천 스킬 실존 여부**: 추천된 스킬 이름이 `~/.claude/skills/` 경로에 실제로 존재하는 디렉토리인지 확인. 존재하지 않는 스킬명을 추천한 경우 FAIL. 추천 결과에 `local_path`가 제공됐다면 해당 경로의 SKILL.md 파일이 실제로 존재하는지 확인.

2. **사용자 의도 매칭 정확성**: 사용자의 원래 쿼리/의도와 추천된 스킬의 description이 실제로 일치하는지 확인. 예: 사용자가 "게임 에셋 생성" 요청 시 `writing-plans` 스킬이 추천되는 경우 FAIL. 추천 사유가 명시됐는지 확인. 의도와 동떨어진 추천은 FAIL.

판정: PASS(기준 충족) / FAIL(재작업 필요)
피드백 형식: [추천 스킬명] — [이유] → [올바른 스킬 또는 수정 방법]
"""
)
```

피드백 루프:
- PASS → 파이프라인 계속
- FAIL → 재작업 후 1회 재실행. 2회 연속 FAIL 시 [STOP] Human 에스컬레이션
