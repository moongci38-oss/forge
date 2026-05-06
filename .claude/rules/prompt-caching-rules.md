# Prompt Caching Rules

## 규칙

**입력 토큰 > 500이면 cache_control 자동 적용.**

### 캐시 타입 선택 기준

| 타입 | TTL | 선택 기준 |
|------|-----|----------|
| **ephemeral** | 5분 | 단기 반복 작업 (같은 prompt 5분 내 재사용) |
| **long** | 1시간 | 시스템 프롬프트, 롱 컨텍스트 (일정 시간 재사용 예상) |

### 구현 위치

1. **Claude SDK (Python/TypeScript)** — 직접 코드에 cache_control 붙이기
   ```python
   {
     "type": "text",
     "text": long_prompt,
     "cache_control": {"type": "ephemeral"}  # or "long"
   }
   ```

2. **Agent/Subagent prompt** — frontmatter에 `cache_control` 지정
   ```yaml
   ---
   cache_control: ephemeral
   cache_min_tokens: 500
   ---
   ```

3. **Skill 정의 (SKILL.md)** — 조건부 캐싱 패턴
   - Input > 500 시 자동 감지 및 적용
   - reference 섹션에서 외부 문서(Spec, Design Docs) 링크 → 캐시 대상 문자열로 임베드

### 비용 효율 기준 (90% 절감)

캐시 히트 시 실제 토큰 수: `(input_cache_read_tokens × 0.1) + output_tokens`

**ROI 임계값**: cache write 비용 vs 예상 히트 수

```
캐시 쓰기 (1회): input_tokens × 1.25
캐시 읽기 (N회): input_tokens × 0.1 × N

N >= 13 이면 ROI+ (1.25 / 0.1 = 12.5)
```

## Forge 적용

### 1. SDK 프로젝트 (api-*로 시작하는 코드)
- `src/claude-client.ts` 또는 `claude_client.py`에서 기본 메시지 생성 시 input > 500 체크
- 자동으로 `cache_control: "ephemeral"` 추가

### 2. Agent/Skill 프롬프트
- 과제 설명서, 긴 컨텍스트 임베드 → `cache_control: long` 선택
- 단기 프롬프트 (이번 요청만) → `cache_control: ephemeral` 또는 생략

### 3. PGE / Evaluator
- Planner 단계: system prompt 캐싱 (long)
- Generator 단계: 반복 생성 시 ephemeral
- Evaluator 단계: reference 문서 long

## 검증

**주기**: 월 1회 (cost 리뷰)

```bash
# cache 통계 (Anthropic API 대시보드)
# Usage → Cache Reads vs Cache Writes
# 목표: cache_read_tokens / (input_tokens + cache_read_tokens) > 40%
```

---

**작성**: 2026-05-03
**참조**: `/forge/docs/reference/claude-api-skill-quick-ref.md`
