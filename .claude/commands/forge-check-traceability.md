---
description: Forge Dev Check 3.5 트레이서빌리티 검수 — 독립 실행
allowed-tools: Read, Grep, Glob
model: sonnet
---

# /forge-check-traceability — 트레이서빌리티 게이트

Check 3.5 Spec 준수 검증을 독립적으로 실행합니다 (Subagent 격리).

## 입력

1. **Traceability Matrix**: `.specify/traceability/{spec-name}-matrix.json` (우선 사용)
2. **Spec 파일**: `.specify/specs/{spec-name}.md`
3. **Walkthrough 파일**: `docs/walkthroughs/{spec-name}-walkthrough.md`

## 실행

1. Traceability Matrix JSON 로드 — FR/NFR 목록 + 구현 파일 + 테스트 파일 매핑 확인
2. **파일 존재 검증**: Matrix의 `implementationFiles`, `testFiles` 경로가 실제 존재하는지 확인
3. **Spec → 코드 추적성**: 각 FR의 구현 파일에서 관련 코드(함수, 클래스, 핸들러) 존재 확인
4. **Spec → 테스트 추적성**: 각 FR의 테스트 파일에서 관련 describe/it/test 블록 존재 확인
5. **API 계약 일치**: Spec의 엔드포인트 정의와 실제 구현 (HTTP Method, 경로) 일치 확인
6. **NFR 설정 확인**: 비기능 요구사항의 설정/구현 존재 확인
7. 결과를 JSON 형식으로 반환

## Traceability Matrix 미존재 시

Matrix JSON이 없으면 Spec 파일에서 직접 FR/NFR을 추출하여 검증한다.
이 경우 정확도가 낮아지므로 `"matrixSource": "spec-extracted"` 플래그를 설정한다.

## 출력 형식 (JSON, ~500 토큰)

```json
{
  "checkId": "check-3.5",
  "status": "PASS|FAIL",
  "matrixSource": "traceability-json|spec-extracted",
  "requirements": [
    {
      "id": "FR-001",
      "description": "요구사항 설명",
      "implStatus": "found|missing",
      "implFile": "path/to/file.ts",
      "testStatus": "found|missing",
      "testFile": "path/to/test.ts"
    }
  ],
  "summary": "전체 N개, 구현 N개 (N%), 테스트 N개 (N%), 누락 N개",
  "autoFixable": false
}
```

## 판정 기준

| 판정 | 조건 | 행동 |
|------|------|------|
| **PASS** | 모든 필수(High) FR 구현 + 테스트 존재 | 통과 |
| **WARN** | Medium/Low FR 누락 | Lead에게 보고, 자동 수정 가능 |
| **FAIL** | High FR 1개+ 누락 | Lead에게 보고, 자동 수정 시도 |

## 주의사항

- 이 커맨드는 **읽기 전용** — 코드 수정은 Lead가 수행
- 결과는 반드시 JSON으로 반환 (Markdown 금지)
- raw grep/read 출력을 그대로 반환하지 않음
