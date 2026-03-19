# Promptfoo Agent Eval Suite

Business Workspace의 핵심 에이전트/스킬 품질을 정량 평가하는 테스트 스위트.

## 평가 대상

| Agent/Skill | 테스트 수 | 검증 항목 |
|-------------|:--------:|----------|
| **code-reviewer** | 3 | 보안 이슈 탐지, 로직 에러 탐지, 오탐 방지 |
| **daily-system-review** | 3 | Critical 알림 정확도, 소스 신뢰도 구분, 실행 가능한 권고 |

## 실행 방법

```bash
cd 09-tools/promptfoo

# 설치 (최초 1회)
npm install -g promptfoo
# 또는
npx promptfoo@latest eval

# 평가 실행
npx promptfoo eval

# 결과 확인 (웹 UI)
npx promptfoo view

# 특정 시나리오만 실행
npx promptfoo eval --filter-description "Code Reviewer"
npx promptfoo eval --filter-description "Daily System Review"
```

## 환경 변수

```bash
# Anthropic API 키 (필수)
export ANTHROPIC_API_KEY=sk-ant-...
```

## 파일 구조

```
09-tools/promptfoo/
├── promptfooconfig.yaml          # 메인 설정 (providers, prompts, scenarios)
├── datasets/
│   ├── code-reviewer-tests.yaml  # code-reviewer 테스트 케이스
│   └── daily-system-review-tests.yaml  # daily-system-review 테스트 케이스
└── README.md
```

## Assertion 유형

| 유형 | 용도 |
|------|------|
| `contains` / `icontains` | 특정 키워드 포함 여부 (빠른 패턴 매칭) |
| `not-contains` / `not-icontains` | 특정 키워드 미포함 (오탐/과대 평가 방지) |
| `llm-rubric` | LLM이 응답 품질을 시맨틱 평가 (정성 검증) |

## 테스트 케이스 추가

`datasets/` 내 YAML 파일에 항목을 추가한다:

```yaml
- description: "테스트 설명"
  vars:
    input_var: |
      테스트 입력 데이터
  assert:
    - type: contains
      value: "기대 키워드"
    - type: llm-rubric
      value: "시맨틱 평가 기준 설명"
```

## 확장 계획

추후 평가 대상 후보:
- `research-coordinator` (S1 리서치 품질)
- `prd` / `gdd-writer` (S3 기획서 품질)
- `spec-compliance-checker` (Check 3.5 정확도)
