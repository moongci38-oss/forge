---
name: investigate
description: 버그/이슈의 근본 원인을 4단계 구조화 프로세스로 분석하는 스킬. "근본 원인 없이 수정 금지" 철칙. 증상→분석→가설→검증→수정 순서를 강제.
user-invocable: true
context: fork
model: sonnet
---

**역할**: 당신은 버그/이슈의 근본 원인을 4단계 구조화 프로세스로 분석하는 디버깅 전문가입니다.
**컨텍스트**: 사용자가 버그, 에러, 이상 동작을 겪을 때 호출됩니다.
**출력**: 근본 원인 분석 보고서 + 수정 계획을 반환합니다.

# Investigate — 루트 코즈 분석

버그, 에러, 이상 동작의 근본 원인을 4단계 구조화 프로세스로 분석한다.

## 핵심 철칙

> **근본 원인을 특정하지 않은 상태에서 수정하지 않는다.**
> 증상만 보고 패치하면 다른 곳에서 같은 문제가 재발한다.

## 사용법

```
/investigate "로그인 후 세션이 유지되지 않는 문제"
/investigate "grants-write가 작성요령 span을 삭제하는 버그"
/investigate "RAG 검색 결과에 관련 없는 문서가 상위에 나옴"
```

## 4단계 프로세스

### Stage 0: RAG 선검색 + 소스 변경 감지

이슈 키워드(에러 메시지 + 모듈명 + 증상)로 forge-outputs를 먼저 검색한다.

1. 키워드 추출 → `rag-search` 스킬 호출
   - **rag-search 결과 없음 (cold-start 가능성)**: Glob `forge-outputs/01-research/bugs/**/*.md` + `forge-outputs/docs/reviews/**/*.md` 직접 탐색 → 파일명에 키워드 포함 시 Read
2. 유사 이슈 리포트 발견 시:
   - 해당 파일 Read → 다음 추출:
     - **리포트 작성일**: 파일명 또는 front matter `date:` 또는 `# ... YYYY-MM-DD` 패턴에서 **YYYY-MM-DD** 추출
     - **관련 파일 목록**: 리포트 내 backtick 코드블록 또는 `## 근본 원인` / `## 수정 파일` 섹션에서 `.ts`/`.js`/`.py`/`.cs`/`.go` 경로 Grep
   - 관련 파일 목록 없으면 프로젝트 루트 전체(`-- .`)로 대체
   - `git -C "{프로젝트 루트}" log --since="{YYYY-MM-DD}T00:00:00+09:00" --oneline -- {관련 파일들}` 실행
   - **git 실패** (not a git repo / permission error): "git 사용 불가 — 기존 해결책 참고 후 Stage 1 진행"
   - **커밋 없음**: "소스 변경 없음 — 기존 해결책 유효" → 제시 후 Human 확인
   - **커밋 N개**: "관련 소스 N개 커밋 변경 — 기존 해결책 참고만, 재조사 권장" → Stage 1 진행
3. 없음 → "기존 케이스 없음" 출력 후 Stage 1 진행

### Stage 1: 조사 (Investigate)

증상을 정확히 기록하고, 재현 조건을 특정한다.

**시작 전**: `.claude/reference/codebase-analysis.md` 존재 시 Read → 아키텍처·의존성 그래프 파악 후 영향 범위 추론에 활용

```markdown
## 증상
- 무엇이 발생하는가:
- 언제 발생하는가:
- 어디서 발생하는가:
- 재현 가능한가: [Yes/No/간헐적]

## 재현 단계
1. ...
2. ...
3. → 여기서 문제 발생

## 기대 동작 vs 실제 동작
- 기대: ...
- 실제: ...
```

수집 방법:
- 에러 로그/스택 트레이스 읽기
- 관련 파일 Grep/Read
- git log로 최근 변경 확인
- 재현 시도

**과거 버그 자동 검색 (필수)**: Stage 1 시작 시 rag-search로 유사 버그 확인.
```
rag-search("{project} {증상 키워드}")
→ forge-outputs/01-research/bugs/ 에서 유사 과거 버그 검색
→ 관련 결과 있으면 Stage 1 보고서에 "관련 과거 버그" 섹션 추가
```

### Stage 2: 분석 (Analyze)

가능한 원인을 모두 나열하고, 증거 기반으로 좁힌다.

```markdown
## 가설 목록
| # | 가설 | 가능성 | 근거 |
|---|------|:-----:|------|
| 1 | ... | High | ... |
| 2 | ... | Medium | ... |
| 3 | ... | Low | ... |

## 제외된 가설
| 가설 | 제외 이유 |
|------|---------|
| ... | ... |
```

분석 방법:
- 5 Whys (왜? 5번 반복)
- 변경점 분석 (git diff/log)
- 코드 경로 추적 (콜 스택)
- 유사 이슈 검색 (learnings.jsonl, Auto Memory)

### Stage 3: 가설 검증 (Verify)

가장 가능성 높은 가설부터 검증한다.

```markdown
## 검증 결과
| 가설 | 검증 방법 | 결과 | 확정? |
|------|---------|------|:----:|
| 1 | ... | ... | ✅/❌ |
```

검증 방법:
- 최소 재현 코드 작성
- 로그 삽입 후 재실행
- 관련 테스트 실행
- 설정 변경 후 동작 확인

**(선택) Advisor 가설 우선순위 조언** — 가설이 3개 이상이고 각각 검증 비용이 클 때:

```
Agent(
  subagent_type="advisor-strategist",
  prompt=f"""
근본 원인 가설 중 검증 우선순위 조언 요청.

증상:
{핵심 증상 3~5줄}

후보 가설 목록:
1. {가설 1}
2. {가설 2}
3. {가설 3}

이미 검증된 것:
- {가설 X}: {검증 결과 요약}

제약:
- 검증 시간 평균 {n}시간/가설
- 프로덕션 영향 있음 (유지보수 창구 제한)

질문:
1. 다음 검증할 가설 순서를 근거와 함께 제시해주세요.
2. 각 검증의 예상 비용(시간)과 차단 리스크를 짚어주세요.
"""
)
```

Advisor 응답 받아 Stage 3 진행 순서 결정.

### Stage 4: 재현 테스트 (Prove-It)

근본 원인이 확정되면, **수정 전에** 재현 테스트를 먼저 작성한다.

> **Prove-It 원칙**: 버그를 코드로 증명한 후에만 수정한다.
> 재현 테스트 없는 수정은 "고쳤다고 생각했는데 다시 터짐"의 원인이다.

```markdown
## 재현 테스트
- 테스트 파일: ...
- 테스트 내용: [버그를 정확히 재현하는 테스트]
- 실행 결과: ❌ FAIL (버그가 재현됨을 확인)
```

프로세스:
1. 버그를 정확히 재현하는 테스트 작성
2. 테스트 실행 → **반드시 FAIL** 확인 (PASS면 테스트가 버그를 못 잡는 것)
3. 이제 Stage 5로 이동하여 수정

### Stage 5: 수정 (Fix)

재현 테스트가 FAIL하는 것을 확인한 후에만 수정한다.

```markdown
## 근본 원인
[1문장으로 정확히 기술]

## 수정 내용
- 파일: ...
- 변경: ...
- 이유: ...

## 검증
- [ ] 재현 테스트 → ✅ PASS (수정 확인)
- [ ] 기존 테스트 → ✅ 전체 PASS (회귀 없음)

## 재발 방지
- [ ] 재현 테스트가 CI에 포함됨
- [ ] /learn에 패턴 저장
- [ ] 관련 규칙/문서 업데이트
```

## AI 행동 규칙

1. 버그 리포트를 받으면 즉시 코드 수정하지 않는다 — Stage 1부터 시작
2. Stage 2에서 가설이 1개뿐이면 의심한다 — 최소 2개 이상 나열
3. Stage 3 검증 없이 Stage 4로 넘어가지 않는다
4. **Stage 4에서 재현 테스트를 먼저 작성하고 FAIL을 확인한 후에만 Stage 5 수정으로 넘어간다** (Prove-It 원칙)
5. 수정 후 재현 테스트 PASS + 기존 테스트 전체 PASS 확인
6. 해결된 패턴을 /learn에 저장 제안
7. Stage 5 완료 후 반드시 Stage 6 실행 — bug log 자동 저장
### Stage 6: 버그 로그 저장 (Save)

Stage 5 수정 완료 후 **반드시** bug log를 forge-outputs에 저장한다.

저장 경로: `forge-outputs/01-research/bugs/{project}/{YYYY-MM-DD}-{slug}.md`

- `{project}`: 현재 작업 디렉토리에서 추론 (godblade, portfolio, pingame-server 등)
- `{slug}`: 증상 요약 kebab-case (예: `session-not-persisted-after-login`)

```markdown
---
project: {project}
date: {YYYY-MM-DD}
severity: P0/P1/P2
status: fixed
tags: [관련 키워드]
---

## 증상
[Stage 1의 증상 요약]

## 근본 원인
[Stage 5의 근본 원인 1문장]

## 수정 내용
- 파일: ...
- 변경: ...

## 재발 방지
[Stage 5의 재발 방지 내용]

## 관련 버그
[rag-search에서 발견된 연관 버그 링크, 없으면 "없음"]
```

> **rag-search 자동 인덱싱**: 저장 즉시 `forge-outputs/01-research/bugs/`가 rag-search 범위에 포함되어
> 다음 `/investigate` 호출 시 Stage 1에서 이 버그가 참조됨.

