---
description: "진행 중인 지원사업 상태 조회"
allowed-tools: Read, Glob, Grep
model: haiku
---

# /grants-status — 지원사업 현황

## 워크플로우

1. `forge-outputs/09-grants/` 하위 모든 기관/사업 폴더 스캔
2. 각 사업의 `_grant-info.md` 읽기
3. 상태 요약 테이블 출력:

| 기관 | 사업명 | 단계 | 접수마감 | 비고 |
|------|--------|------|---------|------|
| KOCCA | AI콘텐츠제작지원-협력형 | GR-1 | 2026.4.2 | |

4. 마감 임박(7일 이내) 사업은 경고 표시
5. `_archive/` 폴더는 제외 (완료/탈락)
