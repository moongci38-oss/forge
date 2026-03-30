---
name: learn
description: 프로젝트별 세션 간 학습을 축적·검색·활용하는 스킬. "이전에 이 패턴으로 해결했다"를 AI가 기억. learnings.jsonl에 저장하여 다음 세션에서 자동 참조.
user-invocable: true
context: fork
model: haiku
---

# Learn — 프로젝트별 학습 축적

세션 간 프로젝트 학습을 jsonl 파일에 축적하고, 이후 세션에서 자동 참조한다.
Auto Memory(워크스페이스 레벨)를 보완하는 프로젝트 레벨 학습 시스템.

## Auto Memory vs Learn

| | Auto Memory | Learn |
|---|---|---|
| 범위 | 워크스페이스 전체 | 프로젝트별 |
| 내용 | 사용자 프로필, 피드백, 규칙 | 기술 패턴, 버그 해결, 설정 발견 |
| 형식 | 개별 .md 파일 | 단일 .jsonl (append-only) |
| 접근 | MEMORY.md 인덱스 | /learn 검색 |

## 저장 위치

```
{프로젝트 루트}/.claude/learnings.jsonl
```

예:
- `~/forge/.claude/learnings.jsonl`
- `~/forge-outputs/09-grants/kocca/2026-문화체육관광RD-스타트업혁신성장/.claude/learnings.jsonl`

## 사용법

### 학습 저장
```
/learn save "HWP 파일은 hwp2pdf로 변환 후 Read해야 함. 직접 Read하면 바이너리 깨짐"
/learn save "grants-write에서 작성요령 span 태그를 삭제하면 검수 FAIL — 절대 삭제 금지"
/learn save "FAISS 인덱스는 개별 노드 삭제 미지원 → 삭제된 파일 있으면 전체 재빌드"
```

### 학습 검색
```
/learn search "HWP"
/learn search "FAISS 삭제"
```

### 학습 목록
```
/learn list           # 최근 10개
/learn list --all     # 전체
```

### 학습 내보내기
```
/learn export         # 마크다운으로 출력
```

## 워크플로우

### 저장 (save)
```bash
# learnings.jsonl에 1줄 append
echo '{"ts":"2026-03-30T08:00:00Z","content":"학습 내용","tags":["tag1"],"session":"세션ID"}' >> .claude/learnings.jsonl
```

### 검색 (search)
```bash
# jsonl에서 키워드 검색
grep -i "검색어" .claude/learnings.jsonl | python3 -c "
import sys, json
for line in sys.stdin:
    entry = json.loads(line)
    print(f'[{entry[\"ts\"][:10]}] {entry[\"content\"]}')"
```

### 자동 참조
세션 시작 시 현재 프로젝트의 learnings.jsonl이 있으면 최근 20개를 컨텍스트에 로드한다.

## AI 행동 규칙

1. 새로운 패턴/해결법을 발견하면 "이걸 /learn에 저장할까요?" 제안
2. 같은 실수를 반복하면 learnings를 검색하여 이전 해결법 참조
3. 저장 시 tags를 자동 추출 (기술명, 스킬명, 파일 유형 등)
4. 세션 시작 시 learnings.jsonl이 있으면 최근 항목 자동 로드
5. 학습 내용이 Auto Memory에 더 적합하면 (사용자 피드백, 행동 규칙) Auto Memory에 저장
