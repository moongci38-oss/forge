# Claude API Skill — Forge Agent 빠른 참조

**등록**: 2026-05-03  
**위치**: `/home/damools/forge/.claude/skills/claude-api/`  
**활성화**: `.mcp.json`에 등록됨 — PGE/Daily Review/Agent 자동 참조 가능  

---

## 언제 사용하나

- **API 클라이언트 자동 생성** (NestJS API, TypeScript SDK)
- **SDK 마이그레이션** (Opus 4.6 → 4.7 Breaking Changes)
- **Agent 코드 리뷰** (Python agent, TypeScript agent)
- **Prompt Caching 최적화** (비용 절감)

---

## 최신 패턴 (Opus 4.7 기준)

### 1. Adaptive Thinking (Breaking Change)

**Before** (Opus 4.6):
```python
response = client.messages.create(
  model="claude-opus-4-6",
  thinking={"type": "enabled", "budget_tokens": 5000}
)
```

**After** (Opus 4.7):
```python
response = client.messages.create(
  model="claude-opus-4-7",
  thinking="adaptive"  # 또는 "enabled" (budget_tokens는 선택)
)
```

**영향 범위**: 모든 Opus 4.7 호출 시 확인 필수

---

### 2. Prompt Caching Best Practice

**조건**: `input_tokens > 500`

**적용 방식**:
```python
response = client.messages.create(
  model="claude-opus-4-7",
  system=[
    {"type": "text", "text": system_prompt},
    {"type": "text", "text": reference_docs, 
     "cache_control": {"type": "ephemeral"}}
  ],
  messages=[...]
)
```

**캐시 타입**:
- `ephemeral`: 5분 (단일 대화, 빠른 반복)
- `long`: 1시간 (세션 기반, 문서 참조)

**무효화**: `system` 또는 `tools` 변경 시 자동 reset

**비용 효과**: 캐시 히트 시 input tokens 90% 절감 (0.1배 비용)

---

### 3. Managed Agents (Beta)

**사용 시기**: 반복 루프 + 자체 추론 필요

**예시**:
```python
# Single request: API 직접 호출
response = client.messages.create(model="...", messages=[...])

# Multi-turn loop: Managed Agent
agent = client.agents.create(model="...", tools=[...])
session = agent.sessions.create()
for turn in range(max_turns):
  response = session.messages.create(...)
```

**Forge 사용**: daily-system-review, telegram agent-server PM2 daemon

---

### 4. 제거된 파라미터 (Opus 4.7)

⚠️ **Breaking Changes**:

```python
# ❌ 금지됨
response = client.messages.create(
  model="claude-opus-4-7",
  temperature=0.7,        # 제거됨
  top_p=0.9,             # 제거됨
  top_k=40,              # 제거됨
  frequency_penalty=-1   # 제거됨
)

# ✓ 허용됨
response = client.messages.create(
  model="claude-opus-4-7",
  messages=[...]
  # temperature/top_p 사용 불가
)
```

**마이그레이션**: 기존 코드에서 제거 필수. IDE 검색으로 빠른 grep 가능.

---

### 5. 다중 언어 SDK 최신 버전

| 언어 | 최신 SDK | 예제 경로 |
|------|---------|----------|
| Python | `anthropic >= 0.38.0` | `./python/` |
| TypeScript | `@anthropic-ai/sdk >= 0.29.0` | `./typescript/` |
| Java | `com.anthropic:anthropic-sdk:0.20.0` | `./java/` |
| Go | `github.com/anthropics/anthropic-sdk-go` | `./go/` |
| Ruby | `anthropic >= 0.3.0` | `./ruby/` |
| C# | `Anthropic.SDK` | `./csharp/` |
| PHP | `anthropics/sdk` | `./php/` |
| cURL | N/A (API 직접) | `./curl/` |

---

## Forge 적용 체크리스트

### PGE Agent (API 클라이언트 생성 시)

- [ ] Opus 4.7인지 확인 (breaking changes 체크)
- [ ] input_tokens > 500이면 `cache_control` 추가
- [ ] Managed Agents 필요한지 판단
- [ ] temperature/top_p 호출 금지 (Lint 규칙)

### Daily Review (SDK 변경사항 추적)

- [ ] Anthropic 공식 뉴스 → claude-api skill 참조
- [ ] "Changelog" URL 하드코딩 제거
- [ ] 신규 모델/파라미터 발표 시 즉시 skill 문서 확인

### Code Review (PR 체크)

```bash
# Opusé 4.7 마이그레이션 감시
grep -r "temperature\|top_p\|top_k" src/ && echo "⚠️  제거된 파라미터 발견"

# Prompt Caching 누락 체크
grep -r "input_tokens.*500" src/ || echo "✓ 캐싱 전략 확인 필수"
```

---

## 참고 자료

- **공식 SKILL.md**: `/home/damools/forge/.claude/skills/claude-api/SKILL.md`
- **문서**: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/claude-api-skill
- **Blog**: https://claude.com/blog/claude-api-skill
- **Breaking Changes 전체**: https://www.anthropic.com/news/claude-opus-4-7

---

## 갱신 주기

- `claude-api skill`: GitHub `anthropics/skills` main branch 자동 추적
- 본 빠른 참조: 월 1회 또는 Breaking Changes 발표 시 (별도 공지)
- Forge `.mcp.json`: 수동 업데이트 필요 시 `/forge-onboard` 스킬 사용
