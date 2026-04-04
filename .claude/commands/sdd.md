---
description: "Spec-Driven Development — 기획서+세부계획서 기반 Spec 작성 → 구현 → 검증"
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Agent, Task
argument-hint: <기능 설명> [--spec <spec-path>] [--plan <plan-path>]
model: opus
---
> **⚠️ 실행 모드 확인**: 이 커맨드는 쓰기 모드에서만 정상 동작합니다. Plan mode 감지 시 즉시 [STOP] — "Escape로 plan mode 해제 후 재실행하세요. 내부 [STOP] 게이트가 승인 지점입니다."


# /sdd — Spec-Driven Development 파이프라인

**전제조건**: 기획서(PRD/GDD)와 세부계획서(개발계획서)가 이미 존재해야 한다.
기획이 없으면 `/forge`를 사용한다.

SDD 파이프라인: Spec이 Single Source of Truth.
Spec 없이 구현 금지. 구현 후 Spec과 1:1 대조 검증 필수.

## 사용법

```
/sdd <기능 설명>
/sdd --spec .specify/specs/2026-04-03-auth.md   # 기존 Spec으로 바로 구현
/sdd --plan forge-outputs/docs/planning/active/ # 계획서 경로 명시
```

## /forge vs /sdd

| | /forge | /sdd |
|--|--------|------|
| 진입 시점 | 아이디어/요구사항만 있을 때 | 기획서 + 세부계획서 완료 후 |
| 시작 Phase | Phase 1 (리서치) | Phase 6 (Spec 작성) |
| 산출물 | 기획 전체 + 개발 전체 | Spec + 구현 + 검증 |

---

## 실행 흐름

### Phase 0. 전제조건 확인 [STOP — 없으면 진행 불가]

1. 기획서(PRD/GDD) 경로 확인 — `forge-outputs/docs/planning/` 또는 `--plan` 인자
2. 세부계획서(개발계획서, 테스트전략 포함) 경로 확인
3. **둘 다 없으면 [STOP]**: "기획서와 세부계획서가 필요합니다. `/forge`로 기획부터 시작하세요."
4. 두 문서를 Read하여 구현 범위와 요구사항 파악

### Phase 1. Spec 존재 확인

1. `.specify/specs/` 디렉토리에서 관련 Spec 검색 (Grep/Glob)
2. **Spec 있음** → Phase 3으로 이동
3. **Spec 없음** → Phase 2로 이동

---

### Phase 2. Spec 작성 [STOP — Human 승인 후 Phase 3 진행]

`spec-writer` 에이전트를 스폰하여 Spec 초안을 작성한다.

```
Agent: spec-writer
Input: <기능 설명>
Output: .specify/specs/YYYY-MM-DD-{feature}.md
```

Spec 작성 완료 후 **[STOP]**: Human이 Spec을 검토·수정 후 승인.
승인 없이 Phase 3 진입 금지.

**Spec 크기 가드레일** (승인 전 확인):
- 1 Spec = 1 Feature (단일 책임)
- 적정 크기: 5~8 SP
- 12 SP 초과 시 분리 필수

---

### Phase 3. 구현 (Generator)

Spec을 Single Source of Truth로 삼아 구현한다.

**구현 전 반드시 확인:**
1. Spec의 기능 요구사항(FR) 목록 추출
2. 각 FR에 대응하는 구현 계획 수립
3. Spec에 없는 기능은 구현하지 않는다 (Scope Creep 금지)

**구현 완료 기준:**
- 모든 FR 구현
- 단위 테스트 작성 (TDD)
- `verify.sh` 또는 `npm test` PASS

---

### Phase 3. 검증 (Evaluator)

#### Check A. 빌드·테스트·린트

```bash
# 프로젝트 verify.sh 있으면 실행
bash verify.sh 2>/dev/null || npm test
```

FAIL → 1회 autoFix → 재실행 → FAIL → **[STOP]**

#### Check B. Spec 준수 검증

`spec-compliance-checker` 스킬을 호출하여 구현이 Spec과 일치하는지 검증한다.

```
Skill: spec-compliance-checker
Input: Spec 경로 + 구현 파일 목록
```

판정 기준:
- **PASS**: FR 전체 충족 + WARN 항목 없음
- **CONDITIONAL**: WARN 존재 → 수정 후 재검증
- **FAIL**: FR 1개라도 미충족 → Phase 3으로 복귀

#### Check C. 코드 리뷰

`code-reviewer` 에이전트 스폰 (보안/로직/UX 병렬 검토)

FAIL → 수정 → Check A 재실행

---

### Phase 4. PR 생성 + 배포

#### PR 생성

```bash
# feature/{spec-name} 브랜치 → main PR
/forge-release
```

PR 생성 후 CI 대기:
```bash
glab ci view --wait
```

CI PASS + 리뷰 0건 → 즉시 squash merge

#### 배포

```bash
/forge-deploy
```

배포 완료 후 카나리 모니터링:
```bash
/canary
```

---

### Phase 5. 완료 보고

```markdown
## SDD 완료 보고

- Spec: {spec-path}
- 구현 파일: {변경 파일 목록}
- FR 충족률: {X}/{Y} (100% 필수)
- Check A: PASS (빌드·테스트)
- Check B: PASS (spec-compliance-checker)
- Check C: PASS | CONDITIONAL (코드 리뷰)
- PR: {PR URL}
- 배포: DONE | SKIPPED
```

---

## 규칙

| 규칙 | 내용 |
|------|------|
| Spec-First | Spec 없이 Phase 3 진입 금지 |
| Human Gate | Phase 2 완료 시 [STOP] — Spec 승인 필수 |
| No Scope Creep | Spec에 없는 기능 구현 금지 |
| No Self-Eval | Generator(구현)와 Evaluator(spec-compliance)는 별도 에이전트 |
| Spec Gap | 구현 중 Spec 갭 발견 시 → 구현 중단, 갭 기록, Human 보고 |

## forge-sync 배포 대상

이 커맨드는 `forge-sync` 실행 시 `~/.claude/commands/sdd.md`에 자동 배포된다.
