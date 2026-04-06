# GodBlade 컨텍스트 최적화 계획

> 작성일: 2026-04-06
> 목표: GodBlade 작업 시 컨텍스트 소모를 줄여 세션 내 유효 작업량을 2배 이상 확보

---

## 현황 분석

| 컨텍스트 소모 원인 | 비중(추정) | 대응 |
|-------------------|:---------:|------|
| C# 파일 전체 Read | 30% | 핵심 파일 맵 + 부분 Read |
| Unity MCP 대량 응답 | 25% | MCP 호출 최소화 규칙 (적용 완료) |
| 의존성 탐색 Grep 반복 | 20% | 파일 맵으로 타겟 축소 |
| rules 파일 세션 로딩 | 15% | 경량화 + on-demand 전환 |
| PGE 3-에이전트 중복 | 10% | Subagent 분리로 독립 컨텍스트 |

---

## 개선 항목

### 1. CLAUDE.md 핵심 파일 맵 추가 (즉시 적용)

**현황**: 컨텍스트 네비게이션 표가 있지만 "디렉토리 → CLAUDE.md" 수준. 실제 작업 시 "이 기능은 어느 파일?"을 찾느라 Grep 반복.

**변경**: CLAUDE.md에 자주 수정하는 기능별 파일 맵 추가

```markdown
## 핵심 파일 맵 (빈번 수정 대상)

### 클라이언트 UI
| 기능 | 파일 | 의존 |
|------|------|------|
| 가챠 연출 | client/Assets/Scripts/UI/Gacha/ | DOTween, ParticleSystem |
| 장비 강화 UI | client/Assets/Scripts/UI/Forge/ | DOTween |
| 메인 HUD | client/Assets/Scripts/UI/HUD/ | EventManager |
| 전투 HUD | client/Assets/Scripts/UI/Battle/ | BattleManager |

### 서버 핵심
| 기능 | 파일 | 의존 |
|------|------|------|
| 가챠 로직 | server/EodGameServer/Gacha/ | EodDatabase |
| ...
```

→ 에이전트가 Grep 없이 바로 타겟 디렉토리로 접근. **Grep 반복 20% 절약**.

**방법**: 코드베이스 탐색 에이전트가 자주 수정되는 디렉토리를 분석 → CLAUDE.md에 표 추가
**소요**: 30분 (자동 분석 + 수동 보충)

---

### 2. rules 파일 경량화 — on-demand 전환 (즉시 적용)

**현황**: 오늘 추가한 4개 규칙이 상세해서 세션 시작 시 로딩량 증가.

```
pre-modification-analysis.md  — ~80줄
context-management.md          — ~60줄
video-reference-workflow.md    — ~90줄
pge-game-evaluator-rubric.md   — ~200줄
```

**변경**: 각 규칙의 핵심 원칙(5~10줄)만 rules/에 유지하고, 상세 내용은 on-demand 참조 파일로 분리.

```
rules/에 남는 것 (Passive):
  - 의존성 분석 4단계 → 핵심 원칙 5줄
  - 컨텍스트 관리 → 핵심 원칙 5줄
  - 영상 워크플로우 → "영상 → 명세 → 구현" 한 줄 + 참조 링크
  - PGE 루브릭 → "70점 이상 + 즉시 FAIL 없음" + 참조 링크

on-demand 참조 (.claude/reference/에 이동):
  - 각 규칙의 상세 절차/체크리스트/예시
  - 에이전트가 해당 작업 수행 시에만 Read
```

→ 세션 시작 로딩: ~430줄 → ~30줄. **rules 로딩 15% 절약**.

**소요**: 30분

---

### 3. 모델 라우팅 규칙 강화 (즉시 적용)

**현황**: model-routing.md에 일반적인 Haiku/Sonnet/Opus 분류가 있지만, 오늘 추가한 워크플로우에 맞는 구체적 라우팅이 없음.

**변경**: 신규 워크플로우별 모델 매핑 추가

```markdown
## 신규 워크플로우 라우팅

| 작업 | 모델 | 이유 |
|------|------|------|
| 의존성 분석 (pre-modification) Step 1~3 | Haiku | Grep + Read만, 판단 불필요 |
| 의존성 분석 Step 4 (수정 전략 수립) | Sonnet | 판단 필요 |
| 영상 명세 작성 (video-reference) Step 2 | Sonnet | 수치 변환 판단 |
| PGE Generator | Sonnet | 코드 구현 |
| PGE Evaluator | Haiku | 체크리스트 O/X 판정만 |
| current-analysis.md 작성 | Haiku | 검색 결과 정리만 |
```

→ 의존성 분석 + PGE Evaluator를 Haiku로 전환하면 **비용 3~5배 절약 + 속도 2배**.

**소요**: 15분 (model-routing.md 수정)

---

### 4. 자주 쓰는 코드 패턴 스니펫 (즉시 적용)

**현황**: DOTween 시퀀스, ParticleSystem 초기화, UI 이벤트 패턴을 매번 처음부터 작성.

**변경**: `.claude/reference/code-snippets.md`에 GodBlade 프로젝트의 표준 패턴 저장

```markdown
## DOTween 시퀀스 표준 패턴
- UI 등장 (스케일 + 페이드)
- 버튼 피드백 (펀치 스케일)
- 팝업 오픈/클로즈
- OnDisable Kill 패턴

## ParticleSystem 표준 패턴
- 이펙트 재생 + 풀 반환
- 등급별 색상 분기

## UI 이벤트 표준 패턴
- 버튼 리스너 등록/해제
- 스크롤 아이템 바인딩
```

→ 에이전트가 패턴 참조 후 수정만 하면 됨. 코드 생성 컨텍스트 절약.

**방법**: 기존 코드에서 자주 반복되는 패턴을 Grep으로 추출 → 스니펫 문서화
**소요**: 1시간 (코드베이스 분석 필요)

---

### 5. Subagent 분석-구현 분리 워크플로우 (즉시 적용)

**현황**: 하나의 에이전트가 분석 → 구현 → 검증을 모두 수행. 분석만으로 컨텍스트 50% 소모.

**변경**: `.claude/rules/`에 분석-구현 분리 워크플로우 추가

```
[Step 1] 분석 Subagent (Haiku)
  - 의존성 분석 4단계 실행
  - 결과를 .claude/state/current-analysis.md에 저장
  - 컨텍스트 사용 후 종료 (해제됨)

[Step 2] 구현 Subagent (Sonnet)
  - current-analysis.md만 읽고 시작 (깨끗한 컨텍스트)
  - 코드 수정 + 빌드 체크
  - 결과를 state/에 저장

[Step 3] 검증 Subagent (Haiku)
  - PGE 루브릭 기반 체크리스트 평가
  - PASS/FAIL 판정
```

→ 각 단계가 독립 컨텍스트. **분석 50% 소모 문제 해결**.

**소요**: 30분 (규칙 파일 작성)

---

## 실행 로드맵

```
즉시 적용 (오늘):
  ├─ 2. rules 경량화 (30분) — 가장 효과 큼
  ├─ 3. 모델 라우팅 강화 (15분)
  └─ 5. Subagent 분석-구현 분리 (30분)

코드베이스 분석 후 (다음 GodBlade 세션):
  ├─ 1. CLAUDE.md 핵심 파일 맵 (30분, 코드 탐색 필요)
  └─ 4. 코드 패턴 스니펫 (1시간, 코드 탐색 필요)
```

## 예상 효과

| 항목 | 컨텍스트 절약 | 비용 절약 | 속도 향상 |
|------|:-----------:|:--------:|:--------:|
| 1. 파일 맵 | 20% | - | Grep 생략 |
| 2. rules 경량화 | 15% | - | 세션 시작 빨라짐 |
| 3. 모델 라우팅 | - | 3~5배 | 2배 (Haiku) |
| 4. 코드 스니펫 | 10% | - | 패턴 재사용 |
| 5. Subagent 분리 | 50%* | - | 단계별 독립 |

*분석 단계의 컨텍스트가 구현 단계로 이월되지 않음

**종합**: 현재 대비 세션 내 유효 작업량 **2~3배 증가** 예상
