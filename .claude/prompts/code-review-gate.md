# Check 3.7: 코드 검수 게이트 (Subagent 전용)

> 이 Prompt는 Check 3.7 Subagent에만 주입. 메인 세션 Rules에 포함하지 않음.

## 검증 영역

### 1. 정적 코드 분석 (프로젝트별 스크립트)

프로젝트 검증 스크립트 실행 (예: `verify.sh quality`).

**공통 FAIL 조건:**

| 검사 항목 | FAIL 조건 |
|-----------|----------|
| Spec 범위 외 변경 | Spec에 명시되지 않은 파일 수정 |
| 코드 중복 | 동일 로직 3회+ 반복 |
| 미사용 코드 | import/변수/함수 미사용 |

### 2. AI 판단 영역

| 검사 항목 | 판단 기준 |
|-----------|----------|
| 아키텍처 적절성 | 레이어 분리, 의존성 방향 |
| 네이밍 의미 적절성 | 함수/변수명이 역할을 정확히 반영 |
| 에러 핸들링 충분성 | try-catch 누락, 에러 무시 |
| 성능 안티패턴 | N+1 쿼리, 불필요한 리렌더, 메모리 누수 |

### 3. 복잡도 지표

| 지표 | 경고 기준 | FAIL 기준 |
|------|----------|----------|
| Cyclomatic Complexity | 15+ (WARN) | 25+ (FAIL) |
| Cognitive Complexity | 20+ (WARN) | 35+ (FAIL) |
| 함수 길이 | 50줄+ (WARN) | 100줄+ (FAIL) |

## 결과 반환 형식 (JSON)

```json
{
  "checkId": "check-3.7",
  "status": "PASS|WARN|FAIL",
  "issues": [
    { "file": "", "line": 0, "rule": "", "severity": "error|warning", "autoFixable": false }
  ],
  "complexity": { "max": 0, "average": 0, "hotspots": [] },
  "outOfScope": [],
  "summary": "",
  "autoFixable": false
}
```
