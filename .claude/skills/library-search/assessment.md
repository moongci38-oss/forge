---
skill: library-search
version: 2
---

# Assessment: library-search

## 테스트 입력

- input_1: "Search for warrior sprite assets in the Prefab Visual Library before generating new ones"
- input_2: "Find UI button templates matching fantasy RPG style — check library first"
- input_3: "Search library for fire/explosion VFX particle effects and cross-reference Inspector Reference if found"

## 평가 기준 (Yes/No)

1. Output MUST load _metadata.json and display a ranked results table with 에셋명, 경로, quality score, and 태그.
2. Output MUST classify results into branches (완전 매칭 / 부분 매칭 / 매칭 없음) with recommended action and MCP savings estimate.
3. Output MUST include Inspector Reference cross-reference (Step 6) for UI/연출/이펙트 matches or explicitly skip if none.
4. Output MUST state _metadata.json update plan (usage_count, last_used) for selected assets.
5. Output MUST confirm GitLab team sharing context (library is a separate repo, team members access via git pull).

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상
