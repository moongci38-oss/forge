---
description: Karpathy 3-layer 개인 지식 체계 — Raw → Wiki 추출 워크플로우 (Human 승인 루프)
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
argument-hint: [없음 또는 특정 raw 파일 경로]
model: sonnet
---

# /wiki-sync — Raw → Wiki 추출 워크플로우

`forge-outputs/01-research/`의 신규 Raw 문서를 스캔하여 `forge-outputs/20-wiki/`에 통합 제안을 생성합니다. **모든 변경은 Human 승인 후에만 적용됩니다.**

## 사용법

```
/wiki-sync                                     # 미반영 Raw 자동 스캔
/wiki-sync forge-outputs/01-research/...md     # 특정 파일 강제 처리
```

## 동작

`wiki-sync` 스킬을 호출하여 5단계 워크플로우를 실행합니다:

1. **Scan** — sync-tracking.json 기준 미반영 Raw 후보 식별 (3~5개 제한)
2. **Read** — 각 후보에서 핵심 개념·인사이트·출처 추출
3. **Match** — 기존 Wiki 노트와 매핑 (필요 시 `/rag-search --context wiki` 보강)
4. **Propose [STOP]** — UPDATE/NEW 제안을 Human에 제시, 승인 대기
5. **Apply** — 승인된 변경만 반영, sync-tracking 갱신

## 관련

- 스킬 SKILL.md: `~/forge/.claude/skills/wiki-sync/SKILL.md`
- 백그라운드 동기화: `~/forge/shared/scripts/wiki-sync.sh` (Obsidian vault ↔ forge-outputs/20-wiki)
- LightRAG wiki 인덱스: `python3 ~/forge/shared/scripts/lightrag-pilot.py index --context wiki`

> 이 커맨드는 wiki-sync.sh(파일 동기화)와 별개입니다. 같은 이름이지만 역할이 다릅니다 — 이쪽은 **지식 추출 워크플로우**, 저쪽은 **파일 동기화**.
