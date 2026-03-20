---
name: audit-harness
description: >
  AI 하네스 엔지니어링 감사. CLEAR 프레임워크, 3-Layer 테스트 아키텍처, OWASP Agentic Top 10,
  가드레일 패턴, OTel GenAI 옵저버빌리티를 기준으로 측정·제어 역량을 평가한다.
argument-hint: "[target: system|{project-name}]"
user-invocable: true
---

# AI 하네스 엔지니어링 감사

> ACHCE 프레임워크 축 3: Harness
> 참조: `docs/tech/2026-03-16-5-axis-ai-analysis-framework.md`

## 인자

- `$ARGUMENTS` = 감사 대상. 미입력 시 `system` (Forge+Forge Dev).

## 대상 경로 매핑

| target | 감사 경로 |
|--------|----------|
| `system` | `~/.claude/forge/rules/` + `.claude/rules/` + `.claude/agents/` + `.claude/skills/` |
| `{project-name}` | `forge-workspace.json`에 등록된 프로젝트 경로 (`.specify/`, `apps/`, `.claude/` 등) |

## 실행 흐름

### Step 1: target 파싱

`$ARGUMENTS`가 비어 있으면 `TARGET=system`. 아니면 첫 단어를 target으로 사용.

### Step 2: axis-harness 서브에이전트 스폰

아래 JSON 구조를 반환하도록 Subagent를 스폰한다 (model: sonnet):

**에이전트 분석 항목:**

1. **검증 체인(Check Chain) 구현** 확인
   - Check 3 → 3.5 → 3.7 → 3.5T 체인 존재 여부
   - autoFix 한도(1회) 및 [STOP] 에스컬레이션 규칙 문서화
   - 순환 autoFix 카운터 관리 방식

2. **3-Layer 테스트 아키텍처** 커버리지
   - Black-box (최종 결과 평가) 존재 여부
   - Glass-box (궤적 평가) 존재 여부
   - White-box (단일 스텝 평가) 존재 여부
   - "결과 평가, 경로가 아니라" 원칙 적용 여부

3. **OWASP Agentic Top 10** 커버리지 체크
   - ASI01 Goal Hijack, ASI02 Tool Misuse, ASI03 Identity Abuse
   - ASI06 Memory Poisoning, ASI07 Insecure Inter-Agent Comm, ASI10 Rogue Agents
   - 각 항목별 대응 패턴 존재 여부

4. **가드레일 패턴** 평가
   - 5 Rail Types(Input/Dialog/Retrieval/Output/Execution) 중 구현된 레일
   - Constitutional 분류기 또는 동등 패턴 존재 여부

5. **옵저버빌리티(OTel GenAI)** 상태
   - 구조화 로깅 적용 여부 (console.log 금지 규칙 존재?)
   - requestId 추적 메커니즘
   - 성능 메트릭 수집 여부

6. **SLO 정의** 확인
   - 품질 Eval 점수 임계값 문서화 여부
   - 침묵 에러율(Silent Failure) 감지 메커니즘
   - 3단계 롤백 계획 존재 여부

**반환 JSON 형식:**

```json
{
  "axis": "harness",
  "target": "{target}",
  "score": 0-100,
  "check_chain": { "check3": true/false, "check3_5": true/false, "check3_7": true/false, "autofix_limit": true/false },
  "test_layers": { "black_box": true/false, "glass_box": true/false, "white_box": true/false },
  "owasp_coverage": { "ASI01": true/false, "ASI02": true/false, "ASI03": true/false, "ASI06": true/false, "ASI07": true/false, "ASI10": true/false },
  "guardrails": ["Input", "Output"],
  "observability": { "structured_logging": true/false, "request_id": true/false, "metrics": true/false },
  "rollback_plan": true/false,
  "issues": [
    { "severity": "CRITICAL|HIGH|MEDIUM|LOW", "finding": "...", "evidence": "파일경로:라인", "recommendation": "..." }
  ],
  "strengths": ["강점1", "강점2"],
  "summary": "2-3문장 요약"
}
```

### Step 3: 보고서 작성

Subagent 결과를 기반으로 Lead가 보고서를 작성한다.

**저장 위치:** `docs/reviews/audit/{date}-audit-harness[-{target}].md`
(`target`이 `system`이면 suffix 생략)

**보고서 형식:**

```markdown
# Harness 엔지니어링 감사 보고서

**대상**: {target} | **날짜**: {date} | **점수**: {score}/100

## Executive Summary

## 검증 체인(Check Chain) 상태

## 3-Layer 테스트 아키텍처

| 레이어 | 구현 | 비고 |
|--------|:----:|------|
| Black-box | ✅/❌ | |
| Glass-box | ✅/❌ | |
| White-box | ✅/❌ | |

## OWASP Agentic Top 10 커버리지

## 가드레일 + 옵저버빌리티 상태

## 이슈 목록
### CRITICAL
### HIGH
### MEDIUM / LOW

## 권장 액션 (우선순위순)

## 참조
- docs/tech/2026-03-16-5-axis-ai-analysis-framework.md
```

### Step 4: Notion 페이지 생성

```json
{
  "parent": { "data_source_id": "713563f9-d523-4e90-8d6f-6b0d650628ad" },
  "pages": [{
    "properties": {
      "제목": "{date} Harness 감사 [{target}]",
      "축": "Harness",
      "대상": "{target}",
      "점수": "{score}",
      "date:날짜:start": "{date}",
      "상태": "완료",
      "CRITICAL": "{CRITICAL 이슈 수}",
      "HIGH": "{HIGH 이슈 수}",
      "보고서 경로": "docs/reviews/audit/{date}-audit-harness.md"
    },
    "content": "{보고서 전체 내용}"
  }]
}
```

> Notion MCP 미연결 시 경고 출력 후 스킵 (파이프라인 중단 안 함).
