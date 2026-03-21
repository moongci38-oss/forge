# Claude Code 스킬을 직접 고치지 마세요. Autoresearch가 대신 해줍니다
> Tech Bridge | 2026-03-16 | 2.3K views | 17:04
> 원본: https://youtu.be/7MaUhmZijak
> 자막: 자동 생성(API) (신뢰도 B — 한국어 모국어 채널, STT 오류 일부 존재)

---

## TL;DR
Andrej Karpathy의 Autoresearch 프레임워크를 Claude Code 스킬에 적용해 Eval(평가) 테스트 스위트를 구축하고 에이전트가 자율적으로 스킬 프롬프트를 반복 개선하게 만드는 방법을 실증한다. 핵심 결과: 다이어그램 생성 스킬 32/40 → 39/40 달성, 웹사이트 로딩 1100ms → 67ms(81.3% 개선).

---

## 카테고리
`tech/ai` · `productivity`

---

## 핵심 포인트

1. **Claude Code 스킬의 근본적 불안정성** — 스킬을 실행하면 약 70%는 정상 동작하고 30%는 예측 불가 결과가 나온다. 프롬프트 자체가 노이즈를 가진 확률 분포이기 때문이다. [🕐 00:07](https://youtu.be/7MaUhmZijak?t=7)

2. **Autoresearch의 기원: Andrej Karpathy의 GitHub 레포** — 에이전트 팀이 머신러닝 프로세스(NanoGPT 학습)를 자율 최적화하는 레포에서 출발. 핵심 파일은 `train.py`(개선 대상)와 `program.md`(에이전트 지시문) 두 개뿐이다. [🕐 00:31](https://youtu.be/7MaUhmZijak?t=31)

3. **Autoresearch의 3가지 필수 요소** — (1) 객관적 수치 지표, (2) 자동화·반복 가능한 측정 도구, (3) 변경 가능한 대상(스킬 .md 파일). 세 가지 중 하나라도 없으면 루프를 돌릴 수 없다. [🕐 03:50](https://youtu.be/7MaUhmZijak?t=230)

4. **Eval(이발) = Yes/No 이진 질문 테스트 스위트** — 스킬 출력을 채점하는 표준화 질문 세트. 발표자는 다이어그램 생성 스킬에 4가지 기준(가독성, 컬러 팔레트 준수, 선형 흐름, 번호 오류 없음)을 설정해 40점 만점 채점 체계를 구성했다. [🕐 07:07](https://youtu.be/7MaUhmZijak?t=427)

5. **리커트 척도(7점 만점) 평가는 비추천** — 각 단계의 변동성이 누적되면 전체 점수 분산이 커진다. 이진 질문으로 분산을 최소화해야 루프가 수렴한다. [🕐 14:51](https://youtu.be/7MaUhmZijak?t=891)

6. **Eval이 너무 엄격하면 테스트 해킹이 발생** — 모델이 실제 품질 개선 없이 Eval 체크포인트만 통과하는 꼼수를 찾아낸다. 내용을 모르면서 100점을 받는 학생에 비유. [🕐 15:27](https://youtu.be/7MaUhmZijak?t=927)

7. **실증 결과: 32/40 → 39/40 달성** — 테스트 당 비용 약 20센트(2초 모델 × 10개), 500번 실행 가정 시 총 10달러로 스킬 최적화 가능. 저자는 이를 "유튜브 광고 수익 대비 훌륭한 ROI"로 표현. [🕐 12:38](https://youtu.be/7MaUhmZijak?t=758)

8. **리서치 로그 자산화** — 루프 실행 중 모델이 시도한 모든 변경 목록이 누적 데이터로 남는다. 이를 차세대 모델(GPT-6, Opus 5 등)에 넘겨 이전 모델이 멈춘 지점에서 재개할 수 있다. [🕐 03:21](https://youtu.be/7MaUhmZijak?t=201)

9. **적용 범위는 스킬 이외로도 무한** — 웹사이트(Lighthouse 지표), 콜드 이메일(답장률), 랜딩 페이지 A/B, YouTube 썸네일/제목 등 "측정 가능한 모든 것"에 동일 프레임워크 적용 가능. [🕐 16:18](https://youtu.be/7MaUhmZijak?t=978)

10. **구현 스택** — Andiegravity IDE + Claude Code 확장 + Karpathy Autoresearch 레포 + Whisper Flow(음성 입력) + Claude Sonnet(비전 평가자). 평가자 모델을 생성자 모델과 분리하는 것이 핵심 아키텍처 패턴이다. [🕐 09:08](https://youtu.be/7MaUhmZijak?t=548)

---

## 비판적 분석

### 주장 1: "Eval 기반 자율 루프로 스킬을 10달러 이하로 최적화할 수 있다"
- **제시된 근거**: 다이어그램 생성 스킬 32/40 → 39/40 실증, 웹사이트 1100ms → 67ms 실증 (2가지 독립 사례)
- **근거 유형**: 경험적(발표자 본인 실행 결과) — 제3자 재현 데이터 없음
- **한계**: 초기 점수 32/40이 이미 80%라는 점에서 '개선 여지가 큰 저품질 스킬'에서의 검증이 아님. 비용 계산(테스트당 20센트 × 500회 = 100달러)이 발표 내 "약 10달러" 주장과 불일치 — 테스트 수 가정이 다를 경우 실제 비용은 더 클 수 있음
- **반론/대안**: Eval 설계 자체가 인간의 판단에 의존하므로 "잘못된 Eval → 잘못된 방향으로 최적화" 리스크가 있다. 사람이 만든 Eval의 품질이 병목.

### 주장 2: "리커트 척도보다 Yes/No 이진 Eval이 항상 우월하다"
- **제시된 근거**: "변동성이 복합적으로 누적된다" — 퍼널 비유로 설명
- **근거 유형**: 의견/직관 — 실험 비교 데이터 없음
- **한계**: 이진 Eval은 세밀한 품질 차이를 포착하지 못한다. 예를 들어 "가독성 있음(Yes)"이지만 가독성 수준이 크게 다를 수 있음. 스킬 성격에 따라 Likert가 더 적합한 경우도 있음
- **반론/대안**: Eval 유형을 단일화하기보다 이진 Eval을 베이스로 쓰되, 수렴 이후 세밀한 척도로 미세조정하는 2단계 접근이 더 안전할 수 있음.

### 주장 3: "리서치 로그 데이터가 미래 세대 AI에 넘길 수 있는 핵심 자산이 된다"
- **제시된 근거**: 없음 — 발표자의 전망
- **근거 유형**: 의견/추론
- **한계**: 현재 모델 세대 간 프롬프트 전이성(transferability)이 검증되지 않았다. 차세대 모델은 프롬프트 패턴이 변해 과거 최적화 이력이 무의미해질 수 있음
- **반론/대안**: 최적화 로그보다는 Eval 테스트 스위트 자체가 더 지속적인 자산이 될 가능성이 높다.

### 주장 4: "스킬 자동화 루프를 5분마다 돌리면 된다"
- **제시된 근거**: 발표자가 실제로 그렇게 설정했다는 언급
- **근거 유형**: 경험적(단일 사례)
- **한계**: 비용 통제 메커니즘 없이 무한 루프를 돌리면 API 비용이 예상보다 빠르게 증가할 수 있음. 5분 × 20센트 = 시간당 약 2.4달러, 주 168시간 = 약 400달러/주 규모
- **반론/대안**: 개선 임계점(예: 95% 이상) 도달 시 자동 정지하거나 예산 상한선 설정이 필요.

---

## 팩트체크 대상

- **주장**: "웹사이트 로딩 시간이 1100ms에서 67ms로 81.3% 개선됐다" | **검증 필요 이유**: 절대 수치(67ms)가 매우 낮아 실험 조건(캐시, 네트워크 환경, 측정 도구)에 따라 재현성이 다를 수 있음 | **검증 방법**: Lighthouse CLI를 동일 조건(cold cache, 3G throttle)으로 5회 이상 반복 측정해 평균값 확인

- **주장**: "2초 모델 사용 시 생성당 비용이 약 2센트" | **검증 필요 이유**: Anthropic 공식 가격표에서 Claude Haiku 3.5 기준 입력 0.8달러/MTok, 출력 4달러/MTok인데 이미지 생성 포함 시 실제 토큰 수에 따라 편차가 클 수 있음 | **검증 방법**: Claude API Usage Dashboard에서 실제 호출당 비용 직접 측정

- **주장**: "Karpathy의 Autoresearch는 NanoGPT 학습 최적화용으로 공개됐다" | **검증 필요 이유**: 자막에서 "나노프트"로 STT 오류 가능성 있음; 레포 공개 시점과 목적이 정확한지 확인 필요 | **검증 방법**: github.com/karpathy 에서 최신 레포 목록과 README 직접 확인

## 팩트체크 결과

| # | 주장 | 판정 | 근거 |
|:-:|------|:----:|------|
| 4 | "1100ms → 67ms, 81.3% 개선" | ⚠️ 부분 확인 | 80%+ Lighthouse 개선은 이론적 가능(최적화 전 미비한 사이트 기준). 단, 67ms는 매우 낮아 측정 조건(캐시, 네트워크)에 민감. 구체 재현 사례 미발견 |
| 5 | "2초 모델 생성당 약 2센트" | ✅ 확인 (과다 추정) | Haiku 3.5 실제 비용: ~0.05-0.5센트/호출. 비전 입력 포함 시에도 2센트 미만. 발표자의 2센트는 보수적 추정으로 실제보다 높음 |
| 6 | "NanoGPT 학습 최적화용" | ⚠️ 부분 확인 | 정확한 명칭은 "nanochat" (NanoGPT 아님). 목적은 "single-GPU nanochat 학습의 자동 실험 루프". STT 자막 오인식 가능성 높음. 출처: [GitHub](https://github.com/karpathy/autoresearch) |

## 웹 리서치 결과

| 주제 | 출처 | 핵심 인사이트 | 영상과의 관계 |
|------|------|-------------|:-----------:|
| Karpathy AutoResearch 원본 | [GitHub](https://github.com/karpathy/autoresearch) | nanochat val_bpb 자동 개선. train.py + program.md 구조 | 일치 — 영상의 이론적 기반 |
| uditgoenka/autoresearch 플러그인 | [GitHub](https://github.com/uditgoenka/autoresearch) | 8단계 루프: Review → Pick → Change → Commit → Verify → Keep/Revert → Log → Repeat | 보완 — 체계화된 Claude Code 통합 |
| MindStudio: Binary Eval Assertions | [MindStudio](https://www.mindstudio.ai/blog/claude-code-autoresearch-self-improving-skills) | 이진 assertion이 주관적 평가보다 안정적. 3-6개 assertion 권장 | 일치 — 영상 핵심 주장 뒷받침 |
| Claude Skills 2.0 Self-Improving | [Medium](https://medium.com/@reliabledataengineering/claude-skills-2-0-the-self-improving-ai-capabilities-that-actually-work-dc3525eb391b) | skill-creator 플러그인 + eval 기반 자동 개선 생태계 형성 중 | 보완 — 더 넓은 생태계 맥락 |
| The New Stack: autoresearch-agents | [The New Stack](https://thenewstack.io/karpathy-autonomous-experiment-loop/) | agent.py(editable) + run_eval.py(fixed) 분리 아키텍처 | 보완 — 에이전트 특화 변형 |

---

## 댓글 인사이트

댓글 수가 1건으로 통계적으로 유의미한 패턴 추출이 불가능하다.

- **유일한 댓글** (@dolljong, 좋아요 0): *"평가만 할 수 있다면 무엇이든 최적화할 수 있다!!!"* — 영상 핵심 원칙을 한 문장으로 압축한 반응. 커뮤니티의 이 아이디어에 대한 공감 신호이나 샘플이 너무 적어 대표성 없음. 영상이 최근 게시(2026-03-16)되어 댓글 축적이 아직 초기 단계임을 감안해야 한다.

---

## 설명란 자료 요약

| 링크 | 유형 | 설명 |
|------|------|------|
| https://skool.com/makerschool/about | 커뮤니티 | MakerSchool — 발표자 운영 유료 커뮤니티 |
| https://www.youtube.com/watch?v=QoQBzR1NIqI | 영상 | (설명 내 참조, 관련 Claude Code 강좌 추정) |
| https://drive.google.com/drive/folders/14nUSxV8cpi5OI2OQxhBqyeuN92ERTMX1 | Drive | Autoresearch 스킬 파일 공유 폴더 (이메일 불필요, 무료 공개) |
| https://www.youtube.com/watch?v=gcuR_-rzlDw | 영상 | (관련 선행 영상 추정) |
| https://www.youtube.com/watch?v=MxyRjL7NG18 | 영상 | (관련 선행 영상 추정) |
| https://www.youtube.com/watch?v=2GZ2SNXWK-c | 영상 | 4시간 Claude Code 전체 강좌 (발표자 언급) |

**핵심 자료**: Google Drive 폴더에 Autoresearch 스킬 파일이 무료 공개되어 있어 즉시 활용 가능.

---

## 실행 가능 항목

### Forge 파이프라인에 적용

- [ ] **스킬 Eval 스위트 표준 템플릿 작성** — `.claude/skills/{skill-name}/eval.md` 패턴으로 각 스킬에 Yes/No 이진 기준 4-8개를 정의하는 템플릿 추가
- [ ] **`manage-skills.sh`에 eval 서브커맨드 추가** — `bash manage-skills.sh eval {skill-name}` 실행 시 해당 스킬을 N회 실행 후 Eval 기준으로 채점하는 기능 구현
- [ ] **Autoresearch 루프 스크립트 구현** — `shared/scripts/autoresearch.sh {skill-name}` 명령으로 (1) 스킬 N회 실행 → (2) Eval 채점 → (3) Claude에게 프롬프트 개선 요청 → (4) 결과 저장 루프 자동화
- [ ] **구글 Drive 공유 폴더 자료 확보** — https://drive.google.com/drive/folders/14nUSxV8cpi5OI2OQxhBqyeuN92ERTMX1 에서 발표자 공개 스킬 파일 다운로드 후 `forge/shared/docs/` 에 참조 자료로 보관
- [ ] **예산 상한선 설정** — Autoresearch 루프에 `MAX_ITERATIONS`와 `MIN_SCORE_THRESHOLD` 파라미터 추가해 목표 점수 달성 시 자동 종료

### 즉시 적용 가능한 스킬 후보

- [ ] **`/game-logic-visualize` 스킬** — 다이어그램 생성 유형이 영상과 동일한 카테고리. 발표자와 동일한 4가지 기준(가독성, 컬러팔레트, 선형흐름, 번호오류)을 Eval로 설정 가능
- [ ] **`/research` 계열 스킬** — 리서치 출력 품질(출처 포함 여부, 신뢰도 등급 표기, 한국어+영어 병기)을 Eval 기준으로 설정 후 자동 개선 루프 적용
- [ ] **`/forge` 파이프라인 오케스트레이션 프롬프트** — Phase별 출력 품질을 정량화해 Eval 체계 구축

### GodBlade에 적용

- [ ] **게임 GDD 작성 스킬 Eval 구축** — 섹션 완결성, 용어 일관성, 플레이어 여정 포함 여부 등을 Yes/No 기준으로 설정

### Portfolio에 적용

- [ ] **Lighthouse 지표 기반 Autoresearch** — 발표자 사례처럼 Lighthouse MCP를 측정 도구로 사용해 웹사이트 성능 자동 최적화 루프 구성 가능 (이미 Lighthouse MCP 연결됨)

---

## 관련성

| 프로젝트 | 점수 | 이유 |
|---------|------|------|
| **Portfolio** | 4/5 | Lighthouse MCP 이미 연결됨 — 웹사이트 성능 Autoresearch를 즉시 실행 가능. 스킬 개선은 간접 적용 |
| **GodBlade** | 2/5 | 게임 스킬 품질 개선에 원칙 적용 가능하나 비주얼/게임플레이 Eval 기준 정의가 어려움 |
| **비즈니스(Forge)** | 5/5 | 핵심 타깃 영역 — Forge 파이프라인의 스킬 신뢰성 문제를 직접 해결하는 프레임워크. 콜드 이메일, 리서치 품질 등 비즈니스 산출물 전반에 적용 가능 |

---

## 핵심 인용

> "평가만 할 수 있다면, 무엇이든 최적화할 수 있다." — @dolljong (댓글, 영상 핵심 원칙 압축)

> "이 리서치 데이터 묶음이 곧 우리 시대에 가장 중요하고 가치 있는 자산 중 하나가 될 거라고 생각합니다." — 발표자 [🕐 03:37](https://youtu.be/7MaUhmZijak?t=217)

> "너무 엄격한 조건을 주면 모델이 결국 하는 건 모든 평가 포인트를 그대로 앵무새처럼 돌려주는 방법을 찾는 겁니다." — 발표자 [🕐 15:43](https://youtu.be/7MaUhmZijak?t=943)

> "Eval은 가능한 한 Yes/No 이진 질문으로 만드세요. 체인의 각 단계에서 변동성이 더해질수록 전체적으로 더 큰 변동이 생깁니다." — 발표자 [🕐 13:16](https://youtu.be/7MaUhmZijak?t=796)
