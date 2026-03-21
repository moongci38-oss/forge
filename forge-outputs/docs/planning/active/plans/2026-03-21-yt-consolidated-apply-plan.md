# 종합 적용 계획 보고서
> 분석 영상: "클로드 코드 + 오토리서치 = 자기 개선 AI입니다", "Claude Code 스킬을 직접 고치지 마세요. Autoresearch가 대신 해줍니다" | 작성일: 2026-03-21

## 핵심 요약

두 영상은 Karpathy의 AutoResearch 패턴을 Claude Code 스킬과 비즈니스 지표에 적용하는 방법을 실증한다. 핵심 원리는 **"측정 가능한 지표 + 이진 Eval + 자율 반복 루프 = 자동 개선"**이다. 우리 시스템은 41개 스킬과 자동 리서치 파이프라인을 보유하고 있으나, **스킬 품질 측정 체계(Eval)가 전무하여** 개선이 100% 수동에 의존하는 것이 핵심 갭이다.

## 영상별 주요 인사이트 종합

| 영상 | 핵심 제안 | 우리 시스템 적용 여부 |
|------|---------|:-----------------:|
| 영상 1: 오토리서치 = 자기 개선 AI | 비즈니스 지표(이메일 답장률) 자동 A/B 최적화, GitHub Actions 크론, 오케스트레이터-서브에이전트 구조 | 미적용 |
| 영상 2: 스킬을 직접 고치지 마세요 | Claude Code 스킬 Eval 체계(Yes/No 이진), 자율 개선 루프, 평가자-생성자 모델 분리, 리서치 로그 자산화 | 미적용 |

## 현재 시스템 대비 갭 분석

| 기능/패턴 | 영상 출처 | 우리 현황 | 갭 | 영향도 | 난이도 |
|----------|---------|---------|:--:|:----:|:----:|
| 스킬 Eval 체계 | 영상 2 | 41개 스킬 중 Eval 0개 | 스킬 품질 정량화 불가 | H | M |
| 스킬 자율 개선 루프 | 영상 1+2 | 수동 개선만 가능 | 자동 반복 최적화 불가 | H | M |
| 비용 상한선/자동 종료 | 영상 1+2 | 루프 비용 통제 없음 | 루프 도입 시 필수 선행 | H | L |
| 평가자-생성자 모델 분리 | 영상 2 | 단일 모델 사용 | Eval 신뢰성 저하 | M | L |
| 비즈니스 지표 자동 A/B | 영상 1 | 미구축 | 지표 수집 인프라 필요 | M | H |
| Lighthouse 자동 최적화 | 영상 2 | MCP 연결됨, 루프 없음 | 수동 감사만 가능 | M | L |
| 리서치 로그 피드백 루프 | 영상 2 | daily/weekly 축적 중, 피드백 없음 | 이전 분석이 다음에 반영 안 됨 | L | M |

## 꼭 필요한 적용 항목 (GTC-4 통과 항목만)

### P0 — 즉시 적용 (이번 주)

> GTC-4 검증: 현재 스킬 41개의 품질 편차(~30% 비정상 출력)가 실제 작업 효율을 저하시키고 있음 — P0 정당화됨

- **[Forge]** 스킬 Eval 템플릿 표준 생성: `.claude/skills/{skill-name}/eval.md` 패턴으로 Yes/No 이진 기준 4-6개를 정의하는 표준 템플릿 추가. 우선 대상 3개 스킬 선정:
  - `/game-logic-visualize` (다이어그램 생성 — 영상 2와 동일 카테고리)
  - `/daily-system-review` (리서치 출력 품질)
  - `/frontend-design` (UI 코드 품질)
- **기대 효과**: 스킬 품질을 정량적으로 측정 가능해짐 → 개선 방향 객관화

### P1 — 단기 (이번 달)

> GTC-4 검증: 스킬 수동 개선 비용이 높아 자율 루프의 ROI가 명확함. Eval 체계(P0) 완료 후 진행 가능 — P1 정당화됨

- **[Forge]** `manage-skills.sh eval {skill-name}` 서브커맨드 구현: 스킬을 N회 실행 → eval.md 기준으로 채점 → pass rate 출력. 채점 모델은 Haiku(비용 절감, 평가자-생성자 분리)
  - 현재 문제: 스킬 품질이 100% 직감 판단
  - 변경: 정량적 pass rate 기반 품질 관리
  - 기대 효과: "이 스킬은 75% pass rate" 같은 객관적 기준선 확보

- **[Forge]** AutoResearch 루프 스크립트 최소 구현: `shared/scripts/skill-autoresearch.sh {skill-name} --iterations N --budget $MAX`
  - (1) eval 실행 → (2) 실패 패턴 분석 → (3) 프롬프트 개선안 생성 → (4) 재평가
  - 비용 상한선 + 목표 점수 도달 시 자동 종료 필수
  - 기대 효과: 밤새 스킬 최적화 → 아침에 개선된 스킬 사용

- **[Portfolio]** Lighthouse 자동 최적화 PoC: Portfolio 프로젝트에서 Lighthouse MCP(이미 연결됨) 기반 성능 자동 반복 최적화 PoC
  - 현재 문제: 수동 감사만 가능
  - 변경: 성능 점수를 지표로 자동 코드 수정 → 재측정 루프
  - 기대 효과: 영상 2의 1100ms→67ms 사례 재현 가능성 검증

### P2 — 중기 (다음 분기)

- **[Forge]** GitLab CI 기반 스킬 자동 개선 크론: `.gitlab-ci.yml`에 주간 스킬 Eval + 자동 개선 stage 추가
  - 매주 핵심 스킬 3-5개를 자동 평가 → pass rate 하락 감지 → 자동 개선 루프 실행
- **[비즈니스]** 뉴스레터/콘텐츠 지표 기반 A/B 테스트 자동화: 오픈율, CTR 등 수집 인프라 구축 후 AutoResearch 패턴 적용
- **[Forge]** 리서치 로그 피드백 루프: daily/weekly 분석 결과가 다음 분석에 컨텍스트로 전달되는 메커니즘

## 제외 항목 (이유 포함)

| 항목 | 제외 이유 |
|------|---------|
| GodBlade 게임 내 지표 기반 AutoResearch | 게임 내 측정 인프라 미구축 + 피드백 루프 지연 (수 주) → 현재 단계에서 ROI 불명확 |
| 콜드 이메일 답장률 자동화 (영상 1 핵심 사례) | Instantly API 미사용 + 콜드 이메일 비즈니스 모델 해당 없음 |
| Whisper Flow 음성 프롬프팅 | 생산성 도구이나 현재 워크플로에 병목이 아님 (GTC-4 미통과) |
| Google Drive 자료 다운로드 | 우리 시스템에 직접 적용할 파일이 아닌 참고용 — 필요 시 확인 수준 |

## 실행 체크리스트

- [ ] **P0-1**: 스킬 Eval 템플릿 표준 설계 (eval.md 포맷, Yes/No 기준 4-6개)
- [ ] **P0-2**: `/game-logic-visualize` Eval 작성 + 기준선 측정
- [ ] **P0-3**: `/daily-system-review` Eval 작성 + 기준선 측정
- [ ] **P0-4**: `/frontend-design` Eval 작성 + 기준선 측정
- [ ] **P1-1**: `manage-skills.sh eval` 서브커맨드 구현
- [ ] **P1-2**: `skill-autoresearch.sh` 최소 루프 구현
- [ ] **P1-3**: Portfolio Lighthouse 자동 최적화 PoC

## 비용 추정

| 항목 | 예상 비용 |
|------|---------|
| Eval 1회 실행 (Haiku 채점) | ~$0.02/테스트 케이스 |
| AutoResearch 50회 루프 (스킬 1개) | ~$5-15 |
| 주간 핵심 스킬 3개 자동 Eval | ~$3-5/주 |
| Lighthouse 최적화 PoC (20 iteration) | ~$2-5 |

## 참고 영상

| 영상 | URL | 분석 파일 |
|------|-----|---------|
| 클로드 코드 + 오토리서치 = 자기 개선 AI입니다 | https://youtu.be/HaAZu5lUkWI | `01-research/videos/analyses/2026-03-21-HaAZu5lUkWI-analysis.md` |
| Claude Code 스킬을 직접 고치지 마세요 | https://youtu.be/7MaUhmZijak | `01-research/videos/analyses/2026-03-21-7MaUhmZijak-analysis.md` |

## 참고 리소스

| 리소스 | URL | 비고 |
|--------|-----|------|
| Karpathy autoresearch (원본) | https://github.com/karpathy/autoresearch | 700+ 실험, NanoGPT 최적화 |
| uditgoenka/autoresearch (Claude Code 플러그인) | https://github.com/uditgoenka/autoresearch | 8단계 루프 + Guard + crash recovery |
| Orchestra Research AI Skills | https://github.com/Orchestra-Research/AI-Research-SKILLs | 2-loop architecture (inner+outer) |
| MindStudio: Binary Eval Guide | https://www.mindstudio.ai/blog/claude-code-autoresearch-self-improving-skills | 실전 구현 가이드 |

---

*작성: 2026-03-21 | GTC-4 적용 완료*
