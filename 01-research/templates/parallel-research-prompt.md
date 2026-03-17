# Subagent 병렬 리서치 메타프롬프트 템플릿

> **용도**: 복수의 독립 리서치 영역을 Subagent Fan-out/Fan-in으로 병렬 수행할 때 사용.
> **작성일**: 2026-03-14 | 출처: CLI-Anything/Replit Agent4/Stanford AI 논문 분석 교훈

---

## 사용 방법

1. `{TOPIC}`, `{DATE}`, `{OUTPUT_PATH}` 등 `{...}` 자리표시자를 실제 값으로 교체한다
2. 각 Subagent 블록을 Agent 도구 단일 메시지에서 병렬 호출한다
3. Wave 1 완료 후 Lead가 취합·검증한다

---

## Wave 1: 병렬 수집 (Fan-out)

### Subagent A 프롬프트 템플릿

```
당신은 {DOMAIN_A} 전문 리서처입니다.

## 목표
{RESEARCH_GOAL_A}

## 필수 소스 (WebFetch 직접 접속)
- {SOURCE_1_URL} — {SOURCE_1_DESC}
- {SOURCE_2_URL} — {SOURCE_2_DESC}

## WebSearch 키워드
- {KEYWORD_1}
- {KEYWORD_2}
- {KEYWORD_3}

## 출력 형식
- 뉴스/인사이트 5-10개 (신뢰도 등급 포함)
- 각 항목: 제목 / 출처 / 날짜 / 핵심 1줄 요약 / 우리 시스템 적용 가능성
- 신뢰도: [High] 다중 소스 확인 / [Medium] 단일 신뢰 소스 / [Low] 추정

## 저장
파일 직접 저장: `{OUTPUT_PATH_A}`
저장 완료 후 종료.
```

### Subagent B 프롬프트 템플릿

```
당신은 {DOMAIN_B} 전문 리서처입니다.

## 목표
{RESEARCH_GOAL_B}

## 필수 소스 (WebFetch 직접 접속)
- {SOURCE_B_1_URL} — {SOURCE_B_1_DESC}

## WebSearch 키워드
- {KEYWORD_B_1}
- {KEYWORD_B_2}

## 출력 형식
- 분석 결과 + 신뢰도 등급 + 출처 + 액션 아이템 3개

## 저장
파일 직접 저장: `{OUTPUT_PATH_B}`
저장 완료 후 종료.
```

### Subagent C 프롬프트 템플릿 (심층 분석용 — Sonnet 권장)

```
당신은 {DOMAIN_C} 분석가입니다.

## 목표
{ANALYSIS_GOAL_C}

## 컨텍스트 (Subagent A/B 결과 요약 — Lead가 주입)
{CONTEXT_FROM_A_B}

## 분석 프레임워크
1. 경쟁 가설 3개 수립
2. 각 가설에 대해 증거/반증 수집
3. 가장 강한 가설 1개 선정 (근거 명시)

## 출력 형식
- 가설 비교표 (마크다운 테이블)
- 최종 결론 + 신뢰도
- 우리 시스템 갭 분석 (적용됨/부분/미적용 + 우선순위)

## 저장
파일 직접 저장: `{OUTPUT_PATH_C}`
저장 완료 후 종료.
```

---

## Wave 2: Lead 취합 (Fan-in)

```
Wave 1 완료 후:
1. {OUTPUT_PATH_A}, {OUTPUT_PATH_B}, {OUTPUT_PATH_C} 파일 존재 확인
2. 누락 시 해당 Subagent 재스폰
3. 3개 결과를 통합하여 종합 인사이트 도출:
   - 공통 테마 (2개 이상 Subagent가 언급한 트렌드)
   - 분기점 (Subagent 간 시각 차이)
   - 우리 시스템 갭 통합 (중복 제거)
   - P0/P1/P2 우선순위 액션 3-5개
4. 종합 보고서 저장: `{SUMMARY_OUTPUT_PATH}`
```

---

## 실제 사용 예시 — AI 인프라 리서치

### Wave 1 병렬 스폰 예시

```python
# Subagent A: GPU/하드웨어 트렌드
agent_a = Agent(
    model="haiku",
    subagent_type="general-purpose",
    prompt="""..."""  # 위 Subagent A 템플릿 채운 버전
)

# Subagent B: AI 모델 경쟁/벤치마크
agent_b = Agent(
    model="haiku",
    subagent_type="general-purpose",
    prompt="""..."""
)

# Subagent C: 비즈니스 임플리케이션 (Sonnet)
agent_c = Agent(
    model="sonnet",
    subagent_type="general-purpose",
    prompt="""..."""
)

# 동시 스폰 (의존성 없음)
run_parallel([agent_a, agent_b, agent_c])
```

---

## 권장 모델 매핑

| Subagent 역할 | 권장 모델 | 이유 |
|-------------|:--------:|------|
| 검색/수집 (WebSearch 위주) | **Haiku 4.5** | 비용 효율, 충분한 검색 능력 |
| 심층 분석 + 비교 | **Sonnet 4.6** | 복잡한 추론, 가설 비교 |
| 전략적 종합 (Lead) | **Sonnet 4.6 / Opus 4.6** | 아키텍처 판단 |

---

## 파일 소유권 선언 (병렬 충돌 방지)

```
## 병렬 실행 파일 소유권
- Subagent A: {OUTPUT_PATH_A} (전용)
- Subagent B: {OUTPUT_PATH_B} (전용)
- Subagent C: {OUTPUT_PATH_C} (전용)
- Lead: {SUMMARY_OUTPUT_PATH} (취합 완료 후)
- 공유 파일 수정: Lead만 허용
```

---

## 신뢰도 등급 기준 (전 Subagent 공통)

| 등급 | 기준 | 표기 |
|------|------|------|
| **High** | 다중 소스 일관 확인 + 1차 소스(공식 문서/논문) | `[신뢰도: High]` |
| **Medium** | 단일 신뢰 소스 또는 2개 부분 일치 | `[신뢰도: Medium]` |
| **Low** | 단일 비공식 소스 또는 AI 추정 | `[신뢰도: Low]` |

---

*Created: 2026-03-14 | 출처: YT 4-video 비교 분석 교훈*
