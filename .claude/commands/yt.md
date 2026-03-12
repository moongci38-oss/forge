---
description: YouTube 영상 URL을 받아 트랜스크립트 추출 + AI 분석을 한 번에 수행
argument-hint: <YouTube-URL> [--format summary|timeline|mindmap|full|blog]
allowed-tools: Read, Write, Bash, Glob, Grep
---

당신은 YouTube 영상 콘텐츠 분석 전문가입니다.

## 입력

$ARGUMENTS

## 수행 절차

### Step 1: 트랜스크립트 추출

아래 명령으로 영상 메타데이터와 트랜스크립트를 추출합니다:

```bash
python3 scripts/yt-analyzer/yt-analyzer.py $ARGUMENTS
```

실행 결과에서 JSON 파일 경로를 확인합니다.

### Step 2: AI 분석

생성된 JSON 파일을 읽고 아래 항목을 분석합니다:

1. **TL;DR**: 1-2문장 핵심 요약 (한국어)
2. **카테고리**: tech/ai, tech/web, tech/gamedev, business/startup, business/marketing, productivity
3. **핵심 포인트**: 5-10개, 타임스탬프 링크 포함
   - 형식: `N. **포인트** [🕐 MM:SS](https://youtu.be/{video_id}?t={seconds})`
4. **비판적 분석**: 영상 핵심 주장 3-5개에 대해 근거/한계/반론 분석
   - 각 주장: 주장 → 제시된 근거 (실증/경험/의견) → 한계 → 반론/대안
   - 과장/편향이 있다면 명시
5. **팩트체크 대상**: 검증이 필요한 핵심 주장 3개 식별
   - 형식: `- **주장**: "..." | **검증 필요 이유**: ... | **검증 방법**: ...`
   - 수치적 주장, 인과관계 주장, 비교 주장 우선
6. **실행 가능 항목**: 우리 시스템(Business/Portfolio/GodBlade)에 구체적으로 적용 가능한 행동 체크리스트
7. **시스템 적용 맥락**: 우리 시스템과의 갭 분석 테이블
   - 영상 제안 vs 현재 상태 (이미 적용/부분 적용/미적용) vs 구체적 갭 vs 우선순위 (P0/P1/P2)
8. **관련성 평가**:
   - Portfolio (Next.js + NestJS): 1-5점 + 이유
   - GodBlade (Unity 게임): 1-5점 + 이유
   - 비즈니스: 1-5점 + 이유
9. **핵심 인용**: 발표자의 중요 발언 (원문 + 번역)
10. **추가 리서치 필요**: 더 조사할 주제 (구체적 검색 키워드 포함)

### Step 2.5: 팩트체크 (자동)

Step 2에서 식별된 "팩트체크 대상" 3개를 검증합니다:

1. `fact-checker` 에이전트(Haiku)를 스폰하여 각 주장을 WebSearch로 검증
2. 검증 결과를 `-analysis.md`의 "팩트체크 결과" 섹션에 추가
3. 검증 불가 항목은 `[미검증]` 태그로 명시

**팩트체크 결과 형식:**
```markdown
## 팩트체크 결과

| # | 주장 | 판정 | 근거 |
|:-:|------|:----:|------|
| 1 | "..." | ✅ 확인 / ⚠️ 부분 확인 / ❌ 반박 / ❓ 미검증 | 출처 + 요약 |
```

> 비기술 영상이거나 검증 대상이 명확히 없는 경우 Step 2.5를 스킵할 수 있습니다.

### Step 2.7: 자막 신뢰도 표기

JSON의 `is_generated_subtitle` 필드를 기반으로 자막 신뢰도 등급을 결정합니다:

| 등급 | 기준 | 표기 |
|------|------|------|
| **High** | 수동 자막 (is_generated: false) | `자막: 수동 (신뢰도 High)` |
| **Medium** | 자동 자막 + 일반 회화 | `자막: 자동생성 (신뢰도 Medium)` |
| **Low** | 자동 자막 + 기술 전문용어 다수 | `자막: 자동생성 (신뢰도 Low) — 고유명사 오인식 주의` |

Low 등급 시 분석 하단에 오인식 가능 용어 목록을 추가합니다.

### Step 3: 리포트 저장

분석 결과를 `01-research/videos/analyses/` 폴더에 저장합니다.
파일명: JSON 파일의 `.json` → `-analysis.md`

### Step 4: 비교 분석 & 적용 계획서 (기술 영상인 경우)

카테고리가 `tech/*` 또는 `productivity`인 경우, 추가로 2개 문서를 생성합니다.

#### 4-1. 비교 분석 리포트

영상에서 소개하는 기술/패턴/도구를 우리 시스템과 1:1 비교 분석합니다.

- **우리 시스템 현황 파악**: Trine rules, SIGIL rules, skills, agents, 프로젝트 코드를 읽어 관련 영역의 현재 상태를 파악
- **비교 매트릭스 작성**: 영상의 기술/패턴 vs 우리 시스템의 현재 구현 상태
- **갭 분석**: 미적용 항목, 부분 적용 항목, 이미 적용된 항목 분류
- **영향도 평가**: 각 갭의 비즈니스/기술 영향도 (High/Medium/Low)

저장: `docs/reviews/{date}-{video-slug}-comparison.md`

#### 4-2. 적용 계획서

비교 분석 결과를 기반으로 구체 적용 계획을 작성합니다.

- **P0 (즉시)**: 1시간 이내 적용 가능한 Quick Win
- **P1 (이번 주)**: 반나절~1일 작업
- **P2 (이번 달)**: 설계 변경이 필요한 중장기 항목
- 각 항목에 **영향 범위** (어떤 프로젝트/시스템), **예상 작업량**, **의존성** 명시

저장: `docs/planning/active/plans/{date}-{video-slug}-apply-plan.md`

> **비기술 영상** (business/*, 순수 마케팅 등)은 Step 4를 스킵하고 Step 3까지만 수행합니다.

## 출력 형식

```markdown
# {title}
> {channel} | {published} | {view_count} views | {duration}
> 원본: https://youtu.be/{video_id}
> 자막: {자막 유형} (신뢰도 {등급})

## TL;DR
(1-2문장)

## 카테고리
{category} | #{tags}

## 핵심 포인트
1. **포인트** [🕐 MM:SS](url?t=seconds)
...

## 비판적 분석

### 주장 1: "{핵심 주장}"
- **제시된 근거**: ...
- **근거 유형**: 실증/경험/의견
- **한계**: ...
- **반론/대안**: ...

## 팩트체크 대상
- **주장**: "..." | **검증 필요 이유**: ... | **검증 방법**: ...

## 팩트체크 결과
| # | 주장 | 판정 | 근거 |
|:-:|------|:----:|------|
| 1 | "..." | ✅/⚠️/❌/❓ | 출처 + 요약 |

## 실행 가능 항목
- [ ] 항목 (적용 대상: Portfolio/GodBlade/Business 명시)

## 시스템 적용 맥락
| 영상 제안 | 현재 상태 | 갭 | 우선순위 |
|----------|----------|-----|:--------:|
| ... | 이미 적용 / 부분 적용 / 미적용 | 구체적 갭 | P0/P1/P2 |

## 관련성
- **Portfolio**: N/5 — 이유
- **GodBlade**: N/5 — 이유
- **비즈니스**: N/5 — 이유

## 핵심 인용
> "원문" — 발표자

## 추가 리서치 필요
- 주제 (검색 키워드: `keyword1`, `keyword2`)
```

### Step 5: Notion DB 등록

모든 분석 완료 후, 결과를 Notion 데이터베이스에 등록합니다.

#### Notion DB 구조 (YouTube 리서치 트래커)

| Property | Type | 값 |
|----------|------|-----|
| 제목 | Title | 영상 제목 |
| URL | URL | `https://youtu.be/{video_id}` |
| 채널 | Text | 채널명 |
| 카테고리 | Select | tech/ai, tech/web, tech/gamedev, business/startup, business/marketing, productivity |
| 관련성 (Portfolio) | Number | 1-5 |
| 관련성 (GodBlade) | Number | 1-5 |
| 관련성 (비즈니스) | Number | 1-5 |
| 적용 상태 | Status | ⬜ 미검토 / 🔄 검토중 / ✅ 적용완료 / ❌ 미적용 |
| 비교분석 | Checkbox | Step 4 수행 여부 |
| 팩트체크 | Checkbox | Step 2.5 수행 여부 |
| 분석일 | Date | 분석 수행 날짜 |
| 분석 파일 | Text | `-analysis.md` 파일 경로 |
| 비교분석 파일 | Text | `-comparison.md` 파일 경로 (있는 경우) |
| 적용계획 파일 | Text | `-apply-plan.md` 파일 경로 (있는 경우) |
| TL;DR | Text | 1-2문장 요약 |

#### 2-Tier 등록

| Tier | 조건 | 동작 |
|:----:|------|------|
| **Tier 1** | Notion MCP 사용 가능 | Notion DB에 페이지 생성 |
| **Tier 2** | Notion MCP 미연결 | `01-research/videos/index.json`에 레코드 추가 |

**Tier 2 index.json 형식:**
```json
[
  {
    "video_id": "xxx",
    "title": "영상 제목",
    "url": "https://youtu.be/xxx",
    "channel": "채널명",
    "category": "tech/ai",
    "duration": "15:30",
    "view_count": "12.5K",
    "published": "2026-03-01",
    "relevance": { "portfolio": 4, "godblade": 1, "business": 3 },
    "status": "pending",
    "has_comparison": true,
    "has_factcheck": true,
    "analyzed_at": "2026-03-09",
    "files": {
      "analysis": "01-research/videos/analyses/xxx-analysis.md",
      "comparison": "docs/reviews/2026-03-09-xxx-comparison.md",
      "apply_plan": "docs/planning/active/plans/2026-03-09-xxx-apply-plan.md"
    },
    "tldr": "요약 내용"
  }
]
```

### Step 6: 교차 분석 (멀티 영상 시)

4개 이상 영상을 동시 분석한 경우, 자동으로 교차 분석을 수행합니다:

1. `cluster.py`로 영상 클러스터링 실행:
   ```bash
   python3 scripts/yt-analyzer/cluster.py
   ```
2. 2개 이상 영상이 포함된 클러스터에 대해 `yt-cross-analyst` 에이전트 스폰
3. 클러스터별 비교 분석 리포트 + 통합 적용 계획서 생성

> 단일 영상 분석 시 Step 6은 스킵합니다.

### Step 7: 연구 후속 (선택)

비즈니스 관련성 4점 이상 영상에 대해 `yt-research-followup` 에이전트를 스폰하여
"추가 리서치 필요" 항목을 실제로 조사합니다.

- 백그라운드에서 실행 (메인 흐름을 차단하지 않음)
- 조사 결과는 `-analysis.md`에 "추가 리서치 결과" 섹션으로 추가

> Human이 명시적으로 요청하거나, `--deep` 플래그 사용 시에만 실행합니다.

## 멀티 영상 병렬 분석 (Subagent 파이프라인)

`--playlist` 또는 `--urls`로 복수 영상이 입력된 경우, subagent 병렬 분석을 적용한다.

### 병렬 분석 흐름

```
Main Agent
├── Step 1: 전체 영상 트랜스크립트 일괄 추출
│   └── yt-analyzer.py 또는 youtube-transcript-api 직접 호출
│   └── 실패 시 Fallback: VPN 우회, Playwright, Windows Python 순차 시도
├── Step 2: 개별 JSON 파일 생성 (메타데이터 + 트랜스크립트)
│   └── /tmp/yt-transcripts/individual/{video_id}.json
├── Step 3: Subagent 병렬 분석 (최대 7개 동시)
│   ├── Subagent 1~7: 영상 A~G 분석 + analysis.md 저장 (Wave 1)
│   └── Subagent 8~N: 영상 H~N 분석 + analysis.md 저장 (Wave 2)
│   └── 에이전트 타입: yt-video-analyst (model: sonnet)
├── Step 3.5: 팩트체크 (fact-checker 에이전트, Haiku, 병렬)
├── Step 4: 비교 분석 + 적용 계획서 (tech 영상만, 순차 또는 병렬)
├── Step 5: Main Agent 취합
│   ├── index.json 레코드 일괄 생성
│   └── 종합 보고서 작성 (선택)
├── Step 6: 교차 분석 (cluster.py + yt-cross-analyst)
└── Step 7: Notion DB 등록 (Tier 1/2)
```

### Subagent 프롬프트 템플릿

각 subagent에 아래 정보를 전달한다:

```
- JSON 파일 경로: /tmp/yt-transcripts/individual/{video_id}.json
- 출력 경로: 01-research/videos/analyses/YYYY-MM-DD-{video_id}-analysis.md
- 출력 형식: /yt 스킬의 출력 형식 섹션 참조
- 에이전트 타입: yt-video-analyst
- 실행 모드: run_in_background (병렬)
```

### Wave 분할 기준

| 영상 수 | Wave 전략 |
|:-------:|----------|
| 1~3개 | 병렬 없이 순차 실행 |
| 4~7개 | 단일 Wave 병렬 |
| 8~14개 | 2 Wave (7+7) |
| 15개+ | 3+ Wave (7개 단위) |

### IP 차단 대응 (Fallback 체인)

트랜스크립트 추출 시 IP 차단(429)이 발생하면 아래 순서로 시도:

```
1. youtube-transcript-api (기본)
   ↓ 실패 시
2. VPN 연결 후 재시도 (Human에게 VPN 연결 요청)
   ↓ 실패 시
3. Windows Python (WSL→PowerShell 경유)
   ↓ 실패 시
4. yt-dlp + Chrome 쿠키 (Chrome 종료 필요)
   ↓ 실패 시
5. [STOP] Human에게 수동 자막 추출 안내
```

## 주의사항

- 영어 트랜스크립트 → 핵심 포인트는 한국어 번역
- 타임스탬프는 반드시 클릭 가능한 YouTube 링크
- 자동 생성 자막(is_generated_subtitle: true) 시 정확도 주의 + 자막 신뢰도 등급 표기
- 30분+ 영상은 섹션별 분석
- `--urls`, `--search`, `--playlist` 옵션도 그대로 전달 가능
- Notion DB 등록 실패 시 Tier 2 Fallback으로 진행 (파이프라인 중단 안 함)
- 멀티 영상 분석 시 subagent 병렬 실행으로 처리 속도 최적화
- 비판적 분석에서 영상 주장을 무비판적으로 수용하지 않는다
- 팩트체크 대상은 수치/인과관계/비교 주장을 우선 선택한다
