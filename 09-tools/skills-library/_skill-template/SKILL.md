---
# ─── Skill Metadata ──────────────────────────────────
# CSO Rule 1: name = primary search token (핵심 키워드를 이름에)
# CSO Rule 2: description = AI가 판단하는 연관성 텍스트 (구체적 행동/도메인 명시)
# CSO Rule 3: 동의어/대체 표현을 description에 포함
# CSO Rule 4: 과도한 키워드 스터핑 회피 — 자연스러운 문장으로
name: {skill-name}
description: "{이 스킬이 하는 일을 1-2문장으로. CSO Rule 2-3 적용}"
version: "1.0.0"
author: "{작성자}"
category: "{development|business-marketing|ai-research|security|content}"
domain: "{세부 도메인 (예: nextjs, nestjs, ux-research, market-analysis)}"
updated: "YYYY-MM-DD"
# enforcement: rigid — 이 스킬의 규칙을 정확히 따라야 함
# enforcement: flexible — 원칙을 적용하되 상황에 맞게 조정 가능
enforcement: {rigid|flexible}
---

# {Skill Name}

> {스킬의 핵심 가치를 1-2줄로. 무엇을 달성하는가?}

## 핵심 원칙

1. **{원칙 1}**: {설명}
2. **{원칙 2}**: {설명}
3. **{원칙 3}**: {설명}

## 규칙/가이드라인

### {카테고리 1}

- **{규칙 ID}**: {규칙 설명}
  - {세부 사항 또는 예시}

### {카테고리 2}

- **{규칙 ID}**: {규칙 설명}

## Examples

<good>
{이 스킬을 올바르게 적용한 사례}
</good>

<bad>
{이 스킬을 잘못 적용한 사례}
</bad>

<!-- ═══════════════════════════════════════════════════════
     아래 섹션은 enforcement: rigid 스킬에 권장.
     ═══════════════════════════════════════════════════════ -->

## Rationalization Table

| 합리화 (Thought) | 현실 (Reality) |
|-------------------|---------------|
| "{스킬 규칙을 어기려는 합리화}" | {반박} |

## Red Flags

- "..."이라는 생각이 들면 → STOP. {올바른 행동}
