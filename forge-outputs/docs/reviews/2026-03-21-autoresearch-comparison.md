# AutoResearch 비교 분석 리포트
> 분석 영상 2편 | 작성일: 2026-03-21

## 영상 목록

| # | 제목 | 채널 | 게시일 | 조회수 |
|:-:|------|------|--------|------:|
| 1 | 클로드 코드 + 오토리서치 = 자기 개선 AI입니다 | Tech Bridge | 2026-03-15 | 3.6K |
| 2 | Claude Code 스킬을 직접 고치지 마세요. Autoresearch가 대신 해줍니다 | Tech Bridge | 2026-03-16 | 2.3K |

## 핵심 개념: Karpathy AutoResearch 패턴

Andrej Karpathy가 공개한 오픈소스 레포(github.com/karpathy/autoresearch)에서 시작.
핵심 원리: **측정 가능한 지표 + 수정 가능한 대상 + 자동 반복 → 자율 개선 루프**

### 영상 1 관점: 비즈니스 지표 자동 최적화
- 콜드 이메일 답장률을 지표로 삼아 AI가 카피 변형 → 배포 → 평가 루프
- GitHub Actions 크론(4시간)으로 24/7 자동 실행
- 결과: 1.5% → 2%+ 답장률 (12회 반복)

### 영상 2 관점: Claude Code 스킬 자동 개선
- 스킬 출력을 Yes/No 이진 Eval로 채점
- 에이전트가 프롬프트를 자율 수정 → 재평가 → 개선 루프
- 결과: 다이어그램 스킬 32/40 → 39/40, 웹사이트 1100ms → 67ms

---

## 우리 시스템 현황 대비 비교 매트릭스

| 영상 제안/패턴 | 우리 현황 | 갭 | 영향도 | 난이도 |
|--------------|---------|:--:|:----:|:----:|
| 스킬 Eval 체계 (Yes/No 이진) | **미적용** — 스킬 품질 측정 체계 없음 | 스킬 41개 중 어느 것도 품질 메트릭이 없음 | H | M |
| 스킬 자율 개선 루프 (AutoResearch) | **미적용** — manage-skills.sh에 eval 없음 | 스킬 개선이 100% 수동 | H | M |
| 비즈니스 지표 A/B 테스트 자동화 | **미적용** — 뉴스레터/콘텐츠 최적화 수동 | 지표 수집 인프라 미구축 | M | H |
| Lighthouse 성능 자동 최적화 루프 | **부분 적용** — MCP 연결됨, 자동 루프 없음 | 수동 감사만 가능, 자동 반복 없음 | M | L |
| 리서치 로그 자산화 | **부분 적용** — daily/weekly 리포트 축적 중 | 이전 분석→다음 분석 피드백 루프 없음 | L | M |
| 비용 상한선/자동 종료 | **미적용** — 루프 비용 통제 메커니즘 없음 | 자율 루프 도입 시 필수 선행 | H | L |
| 평가자-생성자 모델 분리 | **미적용** — 동일 모델이 생성+평가 | Eval 신뢰성 저하 위험 | M | L |
| GitHub/GitLab CI 기반 AutoResearch 크론 | **부분 적용** — weekly-report CI 있으나 AutoResearch 루프 없음 | CI 인프라는 있으나 루프 로직 없음 | M | M |

---

## 영상 간 합의점과 분기점

### 합의점 (두 영상 모두 동의)
1. **측정 가능한 지표가 핵심** — 지표 없이는 자동화 무의미
2. **이진(Yes/No) 평가가 리커트 척도보다 안정적** — 분산 최소화
3. **인간보다 속도에서 우위** — 개별 판단 품질이 아니라 반복 횟수가 성과 결정
4. **비용 통제 필수** — 무한 루프는 API 비용 폭발 위험

### 분기점
| 주제 | 영상 1 | 영상 2 |
|------|--------|--------|
| **적용 초점** | 비즈니스 지표 (이메일 답장률) | 개발 도구 (스킬 프롬프트) |
| **측정 방법** | 외부 API (Instantly) | 내부 Eval (Claude 비전 채점) |
| **자동화 수단** | GitHub Actions 크론 | 로컬 반복 루프 |
| **리서치 로그** | 언급 없음 | 핵심 자산으로 강조 |

---

## 웹 리서치 보강

| 주제 | 출처 | 핵심 인사이트 | 영상과의 관계 |
|------|------|-------------|:-----------:|
| Karpathy AutoResearch 원본 | [GitHub](https://github.com/karpathy/autoresearch) | 700+ 실험, 2일만에 NanoGPT val_bpb 개선. 핵심: spec-driven, metric-gated, agent-executed iteration | 일치 — 두 영상의 이론적 기반 |
| uditgoenka/autoresearch 플러그인 | [GitHub](https://github.com/uditgoenka/autoresearch) | Claude Code 플러그인화. 8단계 루프 + Guard 안전장치 + crash recovery + TSV 로그 | 보완 — 영상보다 체계적인 구현 |
| Fortune 기사: 'The Karpathy Loop' | [Fortune](https://fortune.com/2026/03/17/andrej-karpathy-loop-autonomous-ai-agents-future/) | 700 experiments in 2 days, 11% speedup 달성. "Where AI is heading" | 일치 — 규모와 속도의 실증 |
| MindStudio: Binary Eval Assertions | [MindStudio](https://www.mindstudio.ai/blog/claude-code-autoresearch-self-improving-skills) | 30-50 반복/8시간, 40-50% → 75-85% pass rate. 비용 $1.50-$4.50/overnight | 일치 — 비용 효율성 확인 |
| New Stack: autoresearch-agents 파생 | [The New Stack](https://thenewstack.io/karpathy-autonomous-experiment-loop/) | agent.py를 editable asset으로, run_eval.py+dataset.json을 fixed로 분리하는 아키텍처 | 보완 — 에이전트 최적화 전용 변형 |
| Reddit: 수렴 한계 | [Reddit](https://www.reddit.com/r/singularity/comments/1roo6v0/) | "각 실행이 제로에서 시작" — context window 한계. val_bpb로 검증하므로 암기 불가 | 반박 — 영상 2의 "리서치 로그 자산" 주장에 한계 제시 |

---

*작성: 2026-03-21*
