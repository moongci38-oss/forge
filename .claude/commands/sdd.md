---
description: "Spec-Driven Development — 기획서+세부계획서 기반 Spec 작성 → 구현 → 검증"
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Agent, Task
argument-hint: <기능 설명> [--spec <spec-path>] [--plan <plan-path>]
model: sonnet
---
> **⚠️ 실행 모드 확인**: 이 커맨드는 쓰기 모드에서만 정상 동작합니다. Plan mode 감지 시 즉시 [STOP] — "Escape로 plan mode 해제 후 재실행하세요. 내부 [STOP] 게이트가 승인 지점입니다."


# /sdd — Spec-Driven Development 파이프라인

**전제조건**: 기획서(PRD/GDD)와 세부계획서(개발계획서)가 이미 존재해야 한다.
기획이 없으면 `/forge`를 사용한다.

SDD 파이프라인: Spec이 Single Source of Truth.
Spec 없이 구현 금지. 구현 후 Spec과 1:1 대조 검증 필수.

## 사용법

```
/sdd <기능 설명>                                  # 단일 기능 모드
/sdd --spec .specify/specs/2026-04-03-auth.md     # 기존 Spec으로 바로 구현
/sdd --plan forge-outputs/docs/planning/active/   # 계획서 경로 명시
/sdd --bulk [<forge-context-path>]                # ⭐ 일괄 모드 (forge-outputs 기반)
```

## 모드 구분

| 모드 | 진입 시점 | 입력 | 출력 |
|------|---------|------|------|
| 단일 (default) | 1 기능 추가 | 기능 설명 (자유 텍스트) | Spec 1개 |
| `--spec` | Spec 이미 작성됨 | Spec 파일 경로 | 구현 직행 |
| `--plan` | 계획서 별도 위치 | 계획서 폴더 경로 | Spec 1개 |
| **`--bulk`** | **forge-outputs Phase 4 완료 후 코드 repo 첫 진입** | **forge-context (PRD+architecture+db+api+pages+plan)** | **Spec N개 (그룹별)** |

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
5. **L4 컨텍스트 로드 (선택)**: 현재 작업 디렉토리를 프로젝트 루트로 간주하여 `.claude/reference/` 확인
   - `codebase-analysis.md` 있으면 Read → 아키텍처·의존성 파악 후 Spec 작성 시 활용
   - `spec-context.md` 있으면 Read → 도메인 컨텍스트 반영
   - 없으면 스킵 후 출력: "`.claude/reference/` 없음 — `codebase-analyzer` 실행 권장"

### Phase 1. Spec 존재 확인

1. `.specify/specs/` 디렉토리에서 관련 Spec 검색 (Grep/Glob)
2. **Spec 있음** → Phase 3으로 이동
3. **Spec 없음** → Phase 2로 이동

---

### Phase 2. Spec 작성 [STOP — Human 승인 후 Phase 3 진행]

#### 2.A — 단일 모드 (default / `--plan`)

`spec-writer` 에이전트를 스폰하여 Spec 초안을 작성한다.

```
Agent: spec-writer
Input: <기능 설명>
Output: .specify/specs/YYYY-MM-DD-{feature}.md
```

Spec 작성 완료 후 **Opus Advisor 검토 (1회)**: Spec 초안 + 기능 설명만 전달.
> "이 Spec의 설계 결정에서 가장 위험한 갭 또는 scope creep 가능성 1~2개만 지적하라." (응답 400토큰 이내)
Opus 피드백을 Spec에 반영 후 **[STOP]**: Human이 Spec을 검토·수정 후 승인.
승인 없이 Phase 3 진입 금지.

**Spec 크기 가드레일** (승인 전 확인):
- 1 Spec = 1 Feature (단일 책임)
- 적정 크기: 5~8 SP
- 12 SP 초과 시 분리 필수

#### 2.B — 일괄 모드 (`--bulk`) ⭐

forge-outputs Phase 4 완료 후 코드 repo 첫 진입 시 사용.

**입력 요구사항**:
1. `forge-context/` 심볼릭 링크 또는 명시 경로 — 다음 7 문서 포함:
   - `01-research/*-form-inventory.md` (또는 등가 리서치)
   - `03-design-doc/*-prd.md` (필수)
   - `03-design-doc/*-architecture.md` (필수)
   - `03-design-doc/*-db-schema.md` (필수)
   - `03-design-doc/*-api-spec.md` (필수)
   - `03-design-doc/*-pages.md` (UI 포함 시 필수)
   - `04-planning/*-implementation-plan.md` (필수)

2. `--bulk <path>` 인자 미지정 시 자동 감지:
   - `./forge-context/planning/`
   - `./forge-context/`
   - `./.forge-context/`
   - 없으면 [STOP]: "forge-context 경로를 명시하세요. 사용: /sdd --bulk <path>"

**일괄 모드 흐름**:

1. **계획서 읽기**: `04-planning/*-implementation-plan.md` Read → V1/V2/V3/V4 작업 그룹 추출 (예: A 인프라, B 인증, C 업로드, D AI, E 작성, F 사업비, G 변환, H 결제, I UI Shell)

2. **그룹 → Spec 매핑** (휴리스틱):
   - 1 그룹 = 1 Spec (기본)
   - 그룹 내 작업 시간 합 > 20h → 분리 검토
   - 그룹 간 의존 강한 경우 (예: H 결제 + G 변환 게이트) → 통합 검토 후 결정

3. **계획서 표시 + Human 승인 [STOP]**:
   ```
   /sdd --bulk 분석 결과:
   - V1 작업 그룹 9개 → Spec 9개 생성 예정
     - SPEC-001-{group-A-name} (작업 N개, X h)
     - SPEC-002-{group-B-name} ...
   - V2-V4 = 출시 후 별도 /sdd --bulk 호출 권고

   [STOP] 이 분할 승인하시겠습니까? (Y/N/수정)
   ```

4. **승인 후 spec-writer 병렬 스폰** (각 그룹별):
   ```
   Wave 1 (parallel): SPEC-001~004 (의존 적은 BE 그룹)
   Wave 2 (parallel): SPEC-005~009 (UI/통합 그룹)
   ```
   각 spec-writer 입력:
   - `mode: bulk`
   - `forge_context_path: <path>`
   - `group_name: A-infra` (예)
   - `group_features: [작업 ID 리스트 from implementation-plan]`
   - `output_path: .specify/specs/SPEC-NNN-{group-kebab}.md`

5. **Opus Advisor 검토**: 각 Spec별로 X. **그룹 간 일관성** 1회 검토:
   > "9 Spec 간 (1) FR ID 충돌, (2) 의존 누락, (3) 데이터 모델 불일치를 5개 이내로 지적하라." (응답 600토큰 이내)
   피드백 반영 후 [STOP]: Human이 Spec 묶음 + INDEX.md 검토 → 승인.

6. **INDEX.md 자동 생성** (`.specify/specs/INDEX.md`):
   - Spec 목록 + 그룹 매핑 + FR ID 범위 + 의존 그래프
   - 코드 repo 첫 진입자가 한눈에 파악 가능

**일괄 모드 가드레일**:
- 그룹 12개 초과 → 분리 강제 (V1 + V2 별도 호출 권고)
- forge-context 7 문서 중 4 문서 이상 누락 → [STOP] (Phase 4 미완)
- spec-writer 동시 스폰 ≤ 5 (token/cost 폭주 방지)

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

**웹/앱 UI 파일(.tsx/.jsx/.css/.html) 변경 포함 시 추가 체크:**
- `shared/design-tokens/design-rules.md` Read → 섹션 타입 준수, 금지사항 7개, 카드 구조, 간격 시스템 검증
- 위반 항목 발견 시 WARN으로 기록 (블로킹 아님, 수정 권고)

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
