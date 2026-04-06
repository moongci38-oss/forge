# 종합 적용 계획 보고서
> 분석 영상: 하네스 공식문서 100번 읽은 것처럼 만들어드림 / 바이브코딩시대 개발 프로세스 / 클로드 skill로 pptx 자동 완성 | 작성일: 2026-04-06

## 핵심 요약
3개 영상 모두 "AI 에이전트에게 구조화된 환경(CLAUDE.md/PLAN.md/스킬)을 제공해야 한다"는 방향성을 공유한다. 우리 Forge 시스템은 이미 핵심 구조(CLAUDE.md, 스킬 50+, Notion PM)를 구현하고 있어 신규 도입보다는 **기존 하네스의 강제력 강화**가 우선 과제다.

## 영상별 주요 인사이트 종합

| 영상 | 핵심 제안 | 우리 시스템 적용 여부 |
|------|---------|:-----------------:|
| 하네스 공식문서 (캐슬 AI) | CLAUDE.md + Hooks = 실수 구조적 차단 | 부분 (CLAUDE.md ✅, Hook 제한적) |
| 바이브코딩 개발 프로세스 (김플립) | 기획서 대신 프로토타입 3일 + PLAN.md | 적용 (Forge Phase 6-12 이미 프로토타입 중심) |
| Claude PPTX 스킬 (오피스마스터) | 기존 템플릿 + 새 주제 → 80% 자동화 | 적용 (pptx skill 구현됨, 단 슬라이드 라이브러리 미구축) |

## 현재 시스템 대비 갭 분석

| 기능/패턴 | 영상 출처 | 우리 현황 | 갭 | 영향도 | 난이도 |
|----------|---------|---------|:--:|:----:|:----:|
| Hook pre-write lint/typecheck | 하네스 | cleanup hook만 존재 | Portfolio TS 개발 시 반복 타입 에러 | M | M |
| 실수 → 하네스 자동 업데이트 | 하네스 | learnings.jsonl 수동 | 규칙 승격 파이프라인 없음 | M | M |
| gate-log.md 결정 이유 기록 | 바이브코딩 | Gate 통과/실패만 기록 | 2개월 후 컨텍스트 소실 위험 | L | L |
| 슬라이드 라이브러리 분류 | PPTX | 없음 | PPT 재작업 시 템플릿 재탐색 | L | L |

## 꼭 필요한 적용 항목 (선별 기준: 영향도 High+ 또는 실현 가능성 매우 높음)

### P0 — 즉시 적용 (이번 주)

- **[Forge]** CLAUDE.md/forge-core.md에 "하네스 업데이트 프로토콜" 추가
  - 현황: 에이전트가 반복 실수를 발견해도 자동으로 규칙에 반영되지 않음
  - 변경: "동일 실수 2회 이상 발생 시 즉시 forge-core.md의 해당 섹션에 규칙 추가" 절차 명시
  - 기대 효과: 하네스가 학습하는 구조. 1시간 이내 구현 가능

- **[Forge]** gate-log.md 포맷에 "결정 이유" 필드 추가
  - 현황: Gate 통과/실패만 기록, 왜 그 결정을 했는지 미기록
  - 변경: 각 Gate 항목에 "근거 (1~2줄)" 필드 추가
  - 기대 효과: 2개월 후에도 컨텍스트 유지. 30분 이내 구현

### P1 — 단기 (이번 달)

- **[Portfolio]** 코드 저장 시 TypeScript lint Hook 설정
  - 현황: `.claude/hooks/`에 cleanup hook만 있음, 코드 품질 자동 검증 없음
  - 변경: pre-write hook으로 `tsc --noEmit` + ESLint 실행, 에러 시 Claude에 반환
  - 기대 효과: 반복 타입 에러 패턴 구조적 차단 (GTC-4: Portfolio 개발 착수 시 직접 blocking)
  - 참고: `.claude/hooks/` 기존 패턴 참조하여 구현

- **[Forge]** learnings.jsonl → forge-core.md 피드백 루프 스크립트
  - 현황: 피드백이 learnings.jsonl에만 쌓이고 CLAUDE.md 반영은 수동
  - 변경: 동일 태그가 3회 이상 등장하는 항목을 forge-core.md에 규칙으로 자동 제안하는 간단한 스크립트 작성
  - 기대 효과: 하네스 엔지니어링 핵심인 "실수 → 구조 개선" 루프 자동화

### P2 — 중기 (다음 분기)

- **[Business]** PPTX 슬라이드 라이브러리 구축
  - 현황: 보유 템플릿 파일이 있으나 슬라이드 유형 분류 없음
  - 변경: 주요 PPTX 템플릿 5~10개의 슬라이드를 파일명/유형/적합 주제/부적합 주제로 분류한 표 작성
  - 기대 효과: "이 주제에 적합한 슬라이드 추천" 자동화 가능

- **[Portfolio/GodBlade]** CI Gates 구축
  - 현황: GitHub Actions 미설정
  - 변경: 기본 PR 자동 테스트 워크플로우
  - 기대 효과: 에이전트 생성 코드의 품질 보장

## 제외 항목

| 항목 | 제외 이유 |
|------|---------|
| Linear Agent 도입 | Notion Tasks 잘 작동 중. 우리 시스템 미사용 도구 — 영향도 Low |
| Claude.ai 커스텀 스킬 업로드 방식 | 우리 pptx skill이 더 강력. 도입 필요 없음 |
| 파일시스템 레벨 에이전트 권한 제한 | 현재 보안 사고 없음. 복잡도 High 대비 효과 불명확 |
| 에이전트 보안 (프롬프트 인젝션) | 현재 외부 입력 노출 없음. 프로덕션 전 단계에서 검토 |

## 실행 체크리스트

- [x] **P0** forge-core.md에 "하네스 업데이트 프로토콜" 절차 추가 — 2026-04-06 완료
- [x] **P0** gate-log.md 포맷에 "결정 이유" 필드 추가 — 2026-04-06 완료 (`dev/templates/gate-log.md`)
- [x] **P1** Portfolio `.claude/hooks/pre-write-typecheck.sh` 작성 — 2026-04-06 완료 (settings.json 연동)
- [x] **P1** learnings.jsonl 분석 스크립트 작성 — 2026-04-06 완료 (`scripts/promote-learnings.sh`)
- [ ] **P2** PPTX 슬라이드 라이브러리 표 작성 (담당: Business, 2시간)
- [ ] **P2** GitLab CI/CD 기본 파이프라인 설정 (담당: Portfolio/GodBlade, 1일)

## 참고 영상

| 영상 | URL | 분석 파일 |
|------|-----|---------|
| 하네스 공식문서 100번 읽은 것처럼 | https://youtu.be/DrekqeDlO1w | `01-research/videos/analyses/2026-04-06-DrekqeDlO1w-...-analysis.md` |
| 바이브코딩시대 개발 프로세스 | https://youtu.be/dZG3-9lKpIA | `01-research/videos/analyses/2026-04-06-dZG3-9lKpIA-...-analysis.md` |
| Claude skill PPTX 자동 완성 | https://youtu.be/68hp8IiUXB4 | `01-research/videos/analyses/2026-04-06-68hp8IiUXB4-...-analysis.md` |
