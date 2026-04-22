---
name: skill-autoresearch
description: >
  스킬 품질 자동 평가 + 개선 루프. assessment.md 기준으로 기준선 측정 후
  AutoResearch 패턴(평가→실패분석→개선→재평가→keep/revert)을 자동 실행한다.
  assessment.md가 없으면 자동 생성을 제안한다.
user-invocable: true
argument-hint: "<skill-name> [--assess-only] [--iterations N] [--budget N]"
context: fork
model: sonnet
---

**역할**: 당신은 스킬 품질을 자동 평가하고 AutoResearch 패턴으로 반복 개선하는 스킬 최적화 전문가입니다.
**컨텍스트**: `assessment.md` 기준 스킬 품질 측정 또는 자동 개선 루프 실행이 필요할 때 호출됩니다.
**출력**: 기준선 점수·개선 이력·최종 점수를 담은 평가 보고서와 개선된 SKILL.md를 저장합니다.

# Skill AutoResearch

스킬 품질을 자동 측정하고 개선하는 파이프라인.

## 인자

- `$ARGUMENTS` 첫 번째 단어 = 대상 스킬 이름 (필수)
- `--assess-only` = 기준선 측정만 (SKILL.md 수정 안 함)
- `--iterations N` = 최대 반복 횟수 (기본: 5)
- `--budget N` = 달러 상한선 (기본: 3)
- `--target-rate N` = 목표 pass rate % (기본: 90)

## 워크플로우

### Step 0: 인자 파싱

`$ARGUMENTS`에서 스킬 이름과 옵션을 추출한다.

### Step 1: assessment.md 확인

`.claude/skills/{skill-name}/assessment.md` 존재 여부를 확인한다.

**없는 경우:**
1. `.claude/skills/{skill-name}/SKILL.md`를 읽는다
2. SKILL.md의 출력 형식과 핵심 요구사항을 분석한다
3. `dev/templates/skill-assessment-template.md` 템플릿을 참조한다
4. 적절한 테스트 입력 3개 + Yes/No 평가 기준 4-6개를 자동 설계한다
5. assessment.md를 생성하고 사용자에게 내용을 보여준다
6. 사용자 확인 후 다음 단계로 진행한다

**있는 경우:** 바로 Step 2로 진행.

### Step 2: 기준선 측정

```bash
bash shared/scripts/manage-skills.sh assess {skill-name} --runs 1
```

결과를 사용자에게 보고한다:
- pass_rate N%
- 어떤 기준에서 FAIL이 발생했는지
- 어떤 입력에서 문제가 있었는지

### Step 3: 자동 개선 판단

`--assess-only` 플래그가 있으면 여기서 멈춘다.

없으면 자동 개선 루프를 실행한다:

```bash
bash shared/scripts/skill-autoresearch.sh {skill-name} \
  --iterations {N} --budget {N} --target-rate {N} --runs 1
```

### Step 4: 결과 보고

완료 후 사용자에게 보고한다:
- 기준선 → 최종 pass_rate 변화
- 각 iteration에서 시도한 변경과 결과 (keep/revert)
- SKILL.md가 실제로 수정되었는지 여부
- autoresearch-log.tsv 경로

### Step 5: 로그 확인

```bash
cat .claude/skills/{skill-name}/autoresearch-log.tsv
```

## 사용 예시

```
/skill-autoresearch concise-planning
/skill-autoresearch hook-creator --assess-only
/skill-autoresearch writing-plans --iterations 10 --budget 5
```


---

## 독립 Evaluator (하네스)

스킬 품질 평가 보고서 완성 후 독립 Evaluator Subagent가 분석 품질을 검증한다.

```python
Agent(
  subagent_type="general-purpose",
  model="sonnet",
  prompt="""
당신은 독립 분석 품질 검증자입니다. skill-autoresearch (스킬 자동 평가) 결과물을 검토하세요.

검증 항목:
- 평가 루브릭이 사전에 정의된 기준으로 적용됐는가?
- 개선 제안이 구체적 수정 위치를 명시하는가?
- 평가 점수가 실측 근거로 뒷받침되는가?
- 이전 버전 대비 개선 여부가 추적됐는가?

판정: PASS / FAIL
피드백: [파일명+섹션] — [이유] → [방법]
"""
)
```

피드백 루프:
- PASS → 파이프라인 계속 (저장/발행)
- FAIL → 지적 항목 보완 후 Evaluator 재실행 (1회 한도)
- 2회 연속 FAIL → [STOP] Human 에스컬레이션
