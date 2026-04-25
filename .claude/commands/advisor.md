---
description: Opus를 advisor로 Sonnet/Haiku 실행자와 결합 호출 (API + advisor_20260301 tool)
argument-hint: "<task 설명> [파일 경로]"
---

# /advisor

Forge 하네스에서 **Opus advisor 패턴**을 간편히 호출하는 래퍼. 내부적으로 `shared/scripts/advisor-assist.py`를 Bash로 실행하고 결과를 받는다.

**핵심:** Executor(Sonnet/Haiku) 주도 + Opus(advisor) 판단 지점 조언 → Opus 단독 대비 30~85% 비용 절감하면서 품질 유지.

**비용:** Anthropic API 크레딧 필요 (Max 구독과 별개 과금). 월 $10~30 예상 (Tier 2 선택적 사용 시).
**출처:** 2026-04-10 Advisor 전략 상세 분석 (`forge-outputs/01-research/ai-report/2026-04-10-advisor-strategy-detailed.md`)

## 사용법 (인자 파싱)

```
/advisor <task> [input-file]
```

예시:
- `/advisor "이 계약서 을 측 리스크 3개" ./draft.md`
- `/advisor "grants 본문 전략 프레이밍 개선점" forge-outputs/09-grants/sme-tech-rd/03-core.md`
- `/advisor "이 PR의 보안 위험 감사" (파일 없으면 대화형 입력)`

## 실행 절차

### Step 1 — 인자 파싱

- `$ARGUMENTS`를 두 토큰으로 분리:
  - 첫 토큰: task 문구
  - 나머지: 입력 파일 경로 (있으면)

### Step 2 — Bash 호출

**파일 입력 있을 때:**
```bash
python3 ~/forge/shared/scripts/advisor-assist.py \
  --task "{task}" \
  --input {file} \
  --executor claude-sonnet-4-6 \
  --advisor claude-opus-4-7 \
  --max-uses 3 \
  2>/tmp/advisor-usage.log
```

**파일 없이 대화형:**
입력 내용을 사용자로부터 받아 stdin으로 전달:
```bash
cat <<EOF | python3 ~/forge/shared/scripts/advisor-assist.py --task "{task}"
{사용자 제공 내용}
EOF
```

### Step 3 — 결과 정리

1. stdout (advisor 결과)을 읽고 사용자에게 요약 제시
2. stderr (`/tmp/advisor-usage.log`)에서 비용 정보 추출 → 끝에 요약
3. 결과를 저장해야 하는 경우 저장 경로 확인 후 Write

## 사용 기준 (Tier 2 — 비용 통제)

**✅ 호출해도 되는 경우:**
- 정부과제 본문 최종 전략 검토 (제출 3일 전)
- 고위험 PR 리뷰 (결제·보안·멀티스레드)
- Spec PASS/FAIL 경계 케이스 재판정
- 중대 계약서 조항 검토 (외주·투자·M&A)
- 복잡한 아키텍처 결정 분기점

**❌ 호출하지 말 것:**
- 일상적 코드 리뷰 (Sonnet 단독으로 충분)
- 단순 오타·포매팅 수정
- 문서 초안 작성 (전략 단계 X)
- 반복 패턴 적용 작업

## 비용 예시

| 태스크 | 실행자 | 입력 | 예상 비용 |
|---|---|---|---|
| grants 전략 검토 | Sonnet | 10k 토큰 | $0.15 + advisor $0.3 = **$0.45** |
| PR 보안 감사 | Sonnet | 15k 토큰 | $0.20 + advisor $0.9 = **$1.10** |
| Spec 경계 판정 | Haiku | 3k 토큰 | $0.06 + advisor $0.6 = **$0.66** |

월 10회 사용 시: ~$7~15

## 옵션 플래그 (advisor-assist.py 직접 호출)

```bash
# Executor를 Haiku로 (더 저렴)
python3 ~/forge/shared/scripts/advisor-assist.py \
  --task "판정" --executor claude-haiku-4-5-20251001 \
  --max-uses 2

# Advisor 호출 횟수 증가 (더 많은 조언)
python3 ~/forge/shared/scripts/advisor-assist.py \
  --task "복잡한 전략 결정" --max-uses 5

# JSON 출력
python3 ~/forge/shared/scripts/advisor-assist.py \
  --task "검토" --input file.md --format json > result.json

# Dry run (API 호출 없이 요청 payload 확인)
python3 ~/forge/shared/scripts/advisor-assist.py \
  --task "test" --dry-run <<< "content"
```

## 트러블슈팅

| 증상 | 원인 | 해결 |
|---|---|---|
| `credit balance is too low` | API 크레딧 부족 | https://console.anthropic.com/settings/billing 충전 |
| `ANTHROPIC_API_KEY 미설정` | 환경변수 없음 | `source ~/forge/.env` 또는 export 직접 |
| advisor tool 응답 없음 | beta 헤더 누락 | script가 자동 설정하므로 정상 작동 예상 |
| 과다 비용 | max_uses 설정 과다 | `--max-uses 1~2`로 축소 |

## Forge 하네스 통합 예시

### 스킬에서 호출 (grants-write.md Step 7)
```markdown
### Step 7 — 최종 전략 조언 (선택, 고가치 과제만)

```bash
cat {project}/03-strategy.md | python3 ~/forge/shared/scripts/advisor-assist.py \
  --task "평가위원 관점에서 감점 요인 3가지" \
  --executor claude-sonnet-4-6 \
  --max-uses 2 \
  > {project}/.advisor-feedback.tmp
```
```

### PGE Evaluator에서 호출
```markdown
### Evaluator 보강 (경계 케이스만, 55~65점 구간)

if 점수가 58~65점 사이면:
```bash
cat work.md | python3 ~/forge/shared/scripts/advisor-assist.py \
  --task "이 결과물의 PASS/FAIL 재판정" \
  --executor claude-haiku-4-5-20251001 \
  --max-uses 2
```
```

## 관련

- 구현: `~/forge/shared/scripts/advisor-assist.py`
- 분석 원본: `forge-outputs/01-research/ai-report/2026-04-10-advisor-strategy-detailed.md`
- 적용 계획: `forge-outputs/01-research/ai-report/2026-04-10-forge-application-plan.md`
- API docs: https://docs.claude.com/en/api/messages#advisor
