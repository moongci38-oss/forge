# 스킬 작성 가이드 (Skill Authoring Guide)

> writing-skills TDD + CSO + Bulletproofing 방법론 기반.
> 신규 스킬 작성 시 이 프로세스를 따른다.

---

## 1. writing-skills TDD 프로세스

스킬을 코드처럼 TDD(Test-Driven Development)로 작성한다.

### Step 1: 시나리오 정의 (Red)

스킬 작성 **전에** 이 스킬이 해결해야 할 시나리오 3개를 먼저 정의한다.

| # | 시나리오 | 입력 (사용자 요청) | 기대 행동 (스킬 적용 시) | 금지 행동 (스킬 미적용 시) |
|:-:|---------|-----------------|---------------------|----------------------|
| 1 | {핵심 사용 사례} | "{사용자가 할 법한 요청}" | {스킬이 적용된 올바른 행동} | {스킬 없이 하는 잘못된 행동} |
| 2 | {엣지 케이스} | "{경계 조건의 요청}" | {올바른 처리} | {잘못된 처리} |
| 3 | {합리화 유도 사례} | "{규칙을 어기고 싶은 요청}" | {규칙 준수} | {합리화하여 규칙 위반} |

### Step 2: 스킬 작성 (Green)

`09-tools/skills-library/_skill-template/SKILL.md`를 복사하여 스킬을 작성한다.

- 시나리오 1의 기대 행동이 자연스럽게 유도되는지 확인
- 시나리오 2의 엣지 케이스를 커버하는 규칙이 포함되는지 확인
- 시나리오 3의 합리화를 차단하는 Rationalization Table 포함

### Step 3: 테스트 (Refactor)

서브에이전트에 스킬을 로드하고 시나리오를 실행한다.

```bash
# 서브에이전트 테스트 (향후 manage-skills.sh test 명령으로 자동화)
# 현재는 수동으로 Claude Code 서브에이전트에서 테스트
```

**성공 기준**: 3개 시나리오 모두 기대 행동 달성.

---

## 2. CSO (Claude Search Optimization) 4규칙

스킬의 발견성(discoverability)을 최적화한다. AI가 어떤 스킬을 사용할지 판단할 때 name과 description을 참조하므로, 이 두 필드가 핵심이다.

| # | 규칙 | 설명 | 예시 |
|:-:|------|------|------|
| 1 | **Name = Primary Search Token** | 핵심 키워드를 스킬 이름에 포함 | `nextjs-best-practices` (O) vs `web-framework-tips` (X) |
| 2 | **Description = 연관성 텍스트** | AI가 판단하는 도메인과 행동을 명시 | "Next.js App Router 성능 최적화, RSC 패턴, 번들 최소화 가이드" |
| 3 | **동의어 포함** | 같은 개념의 다른 표현을 description에 포함 | "PostgreSQL (Postgres, Supabase) 쿼리 최적화" |
| 4 | **스터핑 회피** | 키워드 나열이 아닌 자연스러운 문장 | 문장 형태로 구성, 무관한 키워드 제외 |

---

## 3. Bulletproofing 3단계

스킬 작성 완료 후 품질을 보증하는 3단계.

### Stage 1: Rationalization Table 추가

"AI가 이 스킬의 규칙을 어기려 할 때 어떤 합리화를 할까?"를 3-5개 예측하고 반박을 작성한다.

**작성법**:
1. 스킬의 핵심 규칙을 나열한다
2. 각 규칙에 대해 "이걸 안 해도 되는 이유"를 AI 관점에서 생각한다
3. 그 합리화가 왜 틀린지 구체적으로 반박한다

### Stage 2: Red Flags 추가

"이런 생각이 들면 STOP하라"는 경고 목록을 작성한다.

**패턴**: "{합리화 생각}" → STOP. {올바른 행동}.

### Stage 3: 서브에이전트 테스트

(선택적) 서브에이전트에 스킬을 로드하고 TDD 시나리오를 실행한다.

```bash
# 향후 자동화 예정
bash scripts/manage-skills.sh test {skill-name}
```

---

## 4. 기존 스킬 개선 체크리스트

기존 활성 스킬을 개선할 때 사용한다.

- [ ] SKILL.md frontmatter가 표준 필드를 포함하는가? (name, description, version, category, domain, enforcement)
- [ ] CSO 4규칙이 적용되었는가? (name = 핵심 키워드, description = 연관성)
- [ ] enforcement 타입이 선언되었는가? (rigid/flexible)
- [ ] rigid 스킬에 Rationalization Table과 Red Flags가 포함되었는가?
- [ ] Good/Bad 예시가 포함되었는가?

---

## 5. 스킬 관리 CLI 명령어

```bash
# 스킬 검증
bash scripts/manage-skills.sh validate              # 전체 활성 스킬 검증
bash scripts/manage-skills.sh validate {skill-name}  # 특정 스킬 검증

# 스킬 빌드 (룰 기반 스킬에 AGENTS.md 생성)
bash scripts/manage-skills.sh build {skill-name}     # 특정 스킬 빌드

# 스킬 테스트 (서브에이전트 시나리오 실행 — 향후)
bash scripts/manage-skills.sh test {skill-name}      # 서브에이전트 테스트
```

---

*Last Updated: 2026-03-02*
*Sources: Superpowers writing-skills TDD + CSO, Agent Skills validate/build pattern*
