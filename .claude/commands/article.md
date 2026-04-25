---
description: "웹 기사 URL 심층 분석 — 본문 추출 + 내부 링크 파고들기 + 시스템 비교 + 적용 계획서 생성 (Agent Teams 4-Wave)"
argument-hint: <article-URL> [--deep] [--skip-research]
allowed-tools: Read, Write, Bash, Glob, Grep, WebFetch, WebSearch, mcp__brave-search__brave_web_search, Agent
model: sonnet
---

# /article — 웹 기사 심층 분석 파이프라인

**ARGUMENTS**: $ARGUMENTS

`article` 스킬을 실행하여 입력된 URL(들)을 분석한다. 스킬 본체는 `~/.claude/skills/article/SKILL.md`에 정의되어 있으며, 이 커맨드는 얇은 진입점 래퍼다.

## 실행

`article` 스킬을 즉시 호출하고, `$ARGUMENTS`를 스킬 입력으로 전달한다.

## 사용 예시

```
/article https://news.hada.io/topic?id=28491
/article https://news.hada.io/topic?id=28491 --deep
/article https://techcrunch.com/2026/04/14/foo https://www.theverge.com/bar
```

## 산출물

- `~/forge-outputs/01-research/articles/{YYYY-MM-DD}/{date}-{domain}-{slug}-analysis.md`
- `~/forge-outputs/docs/reviews/{date}-{slug}-comparison.md` (tech 카테고리만)
- `~/forge-outputs/docs/planning/active/plans/{date}-{slug}-apply-plan.md` (tech 카테고리만)

추후 `/wiki-sync`로 Obsidian vault에 반영.
