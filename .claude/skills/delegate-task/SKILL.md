---
name: delegate-task
description: Delegate tasks to OpenSpace — a full-stack autonomous worker for coding, DevOps, web research, and desktop automation, backed by an extensive MCP tool and skill library. Skills auto-improve through use, reducing token consumption over time. A cloud community lets agents share and collectively evolve reusable skills.
---

# Delegate Tasks to OpenSpace

OpenSpace is connected as an MCP server. You have 4 tools available: `execute_task`, `search_skills`, `fix_skill`, `upload_skill`.

## When to use

- **You lack the capability** — the task requires tools or capabilities beyond what you can access
- **You tried and failed** — you produced incorrect results; OpenSpace may have a tested skill for it
- **Complex multi-step task** — the task involves many steps, tools, or environments that benefit from OpenSpace's skill library and orchestration
- **User explicitly asks** — user requests delegation to OpenSpace

## Tools

### execute_task

Delegate a task to OpenSpace. It will search for relevant skills, execute, and auto-evolve skills if needed.

```
execute_task(task="Monitor Docker containers, find the highest memory one, restart it gracefully", search_scope="all")
```

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `task` | yes | — | Task instruction in natural language |
| `search_scope` | no | `"all"` | Local + cloud; falls back to local-only if no API key |
| `max_iterations` | no | `20` | Max agent iterations — increase for complex tasks, decrease for simple ones |

Check response for `evolved_skills`. If present with `upload_ready: true`, decide whether to upload (see "When to upload" below).

```json
{
  "status": "success",
  "response": "Task completed successfully",
  "evolved_skills": [
    {
      "skill_dir": "/path/to/skills/new-skill",
      "name": "new-skill",
      "origin": "captured",
      "change_summary": "Captured reusable workflow pattern",
      "upload_ready": true
    }
  ]
}
```

### search_skills

Search for available skills before deciding whether to handle a task yourself or delegate.

```
search_skills(query="docker container monitoring", source="all")
```

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `query` | yes | — | Search query (natural language or keywords) |
| `source` | no | `"all"` | Local + cloud; falls back to local-only if no API key |
| `limit` | no | `20` | Max results |
| `auto_import` | no | `true` | Auto-download top cloud skills locally |

### fix_skill

Manually fix a broken skill.

```
fix_skill(
  skill_dir="/path/to/skills/weather-api",
  direction="The API endpoint changed from v1 to v2, update all URLs and add the new 'units' parameter"
)
```

| Parameter | Required | Description |
|-----------|----------|-------------|
| `skill_dir` | yes | Path to skill directory (must contain SKILL.md) |
| `direction` | yes | What's broken and how to fix — be specific |

Response has `upload_ready: true` → decide whether to upload.

### upload_skill

Upload a skill to the cloud community. For evolved/fixed skills, metadata is pre-saved — just provide `skill_dir` and `visibility`.

```
upload_skill(
  skill_dir="/path/to/skills/weather-api",
  visibility="public"
)
```

For new skills (no auto metadata — defaults apply, but richer metadata improves discoverability):

```
upload_skill(
  skill_dir="/path/to/skills/my-new-skill",
  visibility="public",
  origin="imported",
  tags=["weather", "api"],
  created_by="my-bot",
  change_summary="Initial upload of weather API skill"
)
```

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `skill_dir` | yes | — | Path to skill directory (must contain SKILL.md) |
| `visibility` | no | `"public"` | `"public"` or `"private"` |
| `origin` | no | auto | How the skill was created |
| `parent_skill_ids` | no | auto | Parent skill IDs |
| `tags` | no | auto | Tags |
| `created_by` | no | auto | Creator |
| `change_summary` | no | auto | What changed |

### When to upload

| Situation | Action |
|-----------|--------|
| Skill was originally from the cloud | Upload back as `"public"` — return the improvement to the community |
| Fix/evolution is generally useful | Upload as `"public"` |
| Fix/evolution is project-specific | Upload as `"private"`, or skip |
| User says to share | Upload with the visibility the user wants |

## Notes

- `execute_task` may take minutes — this is expected for multi-step tasks.
- `upload_skill` requires a cloud API key; if it fails, the evolved skill is still saved locally.
- After every OpenSpace call, **tell the user** what happened: task result, any evolved skills, and your upload decision.


---

## 독립 Evaluator (하네스)

delegate-task 결과물 완성 후 독립 Evaluator Subagent가 품질을 2차 검증한다.

> **원칙**: 생성자 ≠ 평가자. 자기평가 편향 방지.

```python
Agent(
  subagent_type="general-purpose",
  model="sonnet",
  prompt="""
당신은 delegate-task 결과물의 독립 품질 검증자입니다.

다음 2가지 기준으로 검증하십시오:

1. **위임 타겟 명확성**: `execute_task` 호출 시 task 파라미터가 자연어로 명확히 작성됐는지 확인. 도구·환경·입출력 조건이 충분히 서술됐는지 확인. "이것 해줘"처럼 컨텍스트가 없는 task 명세는 FAIL. search_scope 등 관련 파라미터가 의도에 맞게 설정됐는지도 확인.

2. **성공 기준 정의**: 위임 완료 후 사용자에게 보고된 결과에 "무엇이 완료됐는지", "evolved_skills 여부와 업로드 결정"이 포함됐는지 확인. 단순 "완료됨" 응답만 있고 결과 요약·사이드 이펙트가 없는 경우 FAIL.

판정: PASS(기준 충족) / FAIL(재작업 필요)
피드백 형식: [task 파라미터 또는 결과 보고 섹션] — [이유] → [개선 방법]
"""
)
```

피드백 루프:
- PASS → 파이프라인 계속
- FAIL → 재작업 후 1회 재실행. 2회 연속 FAIL 시 [STOP] Human 에스컬레이션
