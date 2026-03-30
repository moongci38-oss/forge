# Forge Planning Pipeline Rules (Passive Summary)

> 점진적 로딩: 이 파일은 Passive 요약 (~750 토큰). 상세 규칙은 스킬/파이프라인 실행 시 Deep 로딩.
> Deep 원본: `planning/rules-source/` (8개 파일)
> 통합 파이프라인: `forge/pipeline.md` (Phase 1~12)
> 수동 관리 파일 — manage-rules.sh build가 덮어쓰지 않음

---

## 파이프라인 구조 (CRITICAL)

```
Phase 1 Research → Phase 2 Concept → Phase 3 Design Doc → Phase 4 Planning Package → Phase 5 Handoff → Phase 6~12 (Dev)
  [AUTO-PASS]       [STOP]            [STOP]               [AUTO-PASS]                  [AUTO-PASS]
```

- **Hard 의존성**: Phase 3→4→5→6 순서 불변. Phase 3 없이 Phase 4 진입 금지, Phase 4 없이 Phase 5 진입 금지
- **Soft 의존성**: Phase 1→2는 기존 자료 있으면 스킵 가능
- **진입 경로**: 아이디어만(Phase 1) / 자료있음(Phase 2) / 컨셉확정(Phase 3) / 기획서있음(Phase 4) / 기획패키지있음(Phase 6)

## Iron Laws

> 전체 Iron Laws: `pipeline.md` §Iron Laws (Single Source of Truth)
> 이 파일에서는 핵심 요약만 기재. 정확한 정의는 pipeline.md 참조.

- Phase 3→4→5→6 Hard 의존성 순서 불변
- 에이전트 회의 필수, .pptx 필수, 산출물 3종 필수
- Human 수동 변경 Notion 상태 덮어쓰기 금지
- forge/에 산출물 저장 금지

## 모델 계층화

- Lead/오케스트레이션 → Opus 4.6 | 기획서/문서 작성 → Sonnet 4.6 | 리서치/검색 → Haiku 4.5

## Phase 2 핵심

- Go/No-Go 스코어링 (80+Go, 60-79조건부, <60 No-Go) + Kill Criteria 4개
- 기획 디렉션 5축 필수 (전략방향/경험원칙/범위경계/품질기준/벤치마크)
- Axis 1/3 Human 확인 없이 확정 금지

## Phase 3 핵심

- 에이전트 회의 (Competing Hypotheses) 필수 — 2-3명 독립 초안 비교
- .md + .pptx 모두 생성 필수
- Phase 2 디렉션 Don't 태그 탈락 필터 적용

## Phase 4 핵심

- 필수 산출물 3종: 상세기획서 + 개발계획(테스트전략 포함) + UI/UX기획서
- Wave 1(작성) → 2A(Spec검증) → 2B(디렉션일관성) → 3(병렬리뷰) → 4(최종본)
- Spec 크기 가드레일: 1 Spec=1 Feature, 5-8SP 적정, 12SP+ 분리 필수

## Phase 5 (Handoff)

- `forge-workspace.json`으로 경로 해석 (없으면 [STOP])
- 신규 프로젝트: scaffolding + forge-sync + git init
- 기존 프로젝트: symlink만 생성
- Handoff 문서 자동 생성 → 개발 프로젝트에 symlink → Phase 6 자동 발동
- todo.md는 실제 파일 (symlink 금지)

## Deep 로딩 라우팅

파이프라인 실행 시 (`/forge`, `/prd`, `/gdd`, `/research` 등) 해당 Phase 원본을 Read로 로드:

| 실행 컨텍스트 | Deep 로드 대상 |
|-------------|---------------|
| Phase 1 리서치 | `forge-s1-research.md` |
| Phase 2 컨셉 | `forge-s2-concept.md` |
| Phase 3 기획서 | `forge-s3-design.md` |
| Phase 4 기획패키지 | `forge-s4-planning.md` |
| Phase 5 Handoff | `forge-handoff.md` |
| 거버넌스/게이트 | `forge-governance.md` |
| 산출물 경로 | `forge-outputs.md` |
| 파이프라인 구조 | `forge-structure.md` |
| **통합 파이프라인** | `pipeline.md` (forge/ 루트) |

Deep 원본 경로: `planning/rules-source/{filename}`
