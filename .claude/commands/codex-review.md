---
description: OpenAI Codex 경유 듀얼 모델 adversarial 리뷰 (Forge Dev Check 3.7E)
argument-hint: "<파일 경로 또는 PR 번호>"
---

# /codex-review

Claude 자체 리뷰의 **동일 모델 맹점**을 보완하기 위해 OpenAI Codex로 adversarial 리뷰를 호출한다. 고위험 PR(결제·보안·멀티스레드·마이그레이션)에만 **수동** 호출하며, 매 PR 자동 실행 금지(OpenAI API 비용 통제).

**출처:** Boris Cherny 15 features (2026-04-17 분석, `/forge-outputs/01-research/articles/2026-04-17/2026-04-17-yozm-wishket-com-boris-cherny-15-claude-code-features-analysis.md`)

## 선결 조건 (최초 1회 설치)

Claude Code 세션에서:
```
/plugin marketplace add openai/codex-plugin-cc
/plugin install codex@openai-codex
/reload-plugins
/codex:setup
```
그리고 `~/forge/.env`에 `OPENAI_API_KEY` 추가.

## 사용법

```
/codex-review path/to/file.ts
/codex-review path/to/large-change.py
/codex-review PR-1234
```

## 절차

### Step 1 — 대상 확인
- 입력이 파일 경로면 해당 파일의 diff (develop 대비)
- 입력이 PR 번호면 `gh pr diff {PR}`로 diff 추출

### Step 2 — codex adversarial-review 호출
```
/codex:adversarial-review "$ARGUMENTS"
```

### Step 3 — 결과 저장
결과를 다음 경로에 저장:
```
forge-outputs/docs/reviews/{date}-codex-review-{slug}.md
```

### Step 4 — Claude 자체 리뷰와 diff
동일 파일에 대한 Claude 리뷰 결과가 이미 있다면, **차이점 섹션**을 별도 생성:
```
## Claude vs Codex Delta

### Claude가 놓친 것 (Codex만 지적)
- ...

### Codex가 놓친 것 (Claude만 지적)
- ...

### 양측 공통 지적
- ...
```

### Step 5 — Forge Dev Phase 9 게이트 연동
- Critical 수준 이슈(보안·데이터 손실·성능 리그레션)는 PR 머지 전 **반드시 해결**
- High 수준은 담당자 확인 후 재량
- Low 수준은 참고용

## 사용 기준 (비용 통제)

| 상황 | 사용 권고 |
|---|:-:|
| 결제/환불 로직 변경 | ✅ 강력 권고 |
| 인증/권한 시스템 변경 | ✅ 강력 권고 |
| 멀티스레드/동시성 로직 | ✅ 권고 |
| DB 마이그레이션 | ✅ 권고 |
| 외부 API 통합 | ⚠️ 선택 |
| UI 스타일링만 | ❌ 불필요 |
| 오타 수정 · 주석 변경 | ❌ 불필요 |

## 비용 예상

- 1회 호출당 OpenAI Codex API ~$0.05~0.30 (diff 크기별)
- 고위험 PR만 선별 호출 시 월 $5~20 수준
- 과다 사용 방지: `.env`에 `CODEX_REVIEW_DAILY_LIMIT=10` 설정 권장

## 관련

- Claude 자체 리뷰: Check 3.7Q (code-quality-rules 스킬)
- Forge Dev Phase 9 인스펙션 체크리스트
- 원본 출처: `github.com/openai/codex-plugin-cc`
