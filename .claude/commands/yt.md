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
cd /home/damools/business/scripts/yt-analyzer && python3 yt-analyzer.py $ARGUMENTS
```

실행 결과에서 JSON 파일 경로를 확인합니다.

### Step 2: AI 분석

생성된 JSON 파일을 읽고 아래 항목을 분석합니다:

1. **TL;DR**: 1-2문장 핵심 요약 (한국어)
2. **카테고리**: tech/ai, tech/web, tech/gamedev, business/startup, business/marketing, productivity
3. **핵심 포인트**: 5-10개, 타임스탬프 링크 포함
   - 형식: `N. **포인트** [🕐 MM:SS](https://youtu.be/{video_id}?t={seconds})`
4. **실행 가능 항목**: 바로 적용할 수 있는 행동 체크리스트
5. **관련성 평가**:
   - Portfolio (Next.js + NestJS): 1-5점 + 이유
   - GodBlade (Unity 게임): 1-5점 + 이유
   - 비즈니스: 1-5점 + 이유
6. **핵심 인용**: 발표자의 중요 발언 (원문 + 번역)

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
> {channel} | {published} | {view_count} | {duration}
> 원본: https://youtu.be/{video_id}

## TL;DR
(1-2문장)

## 카테고리
{category} | #{tags}

## 핵심 포인트
1. **포인트** [🕐 MM:SS](url?t=seconds)
...

## 실행 가능 항목
- [ ] 항목

## 관련성
- **Portfolio**: N/5 — 이유
- **GodBlade**: N/5 — 이유
- **비즈니스**: N/5 — 이유

## 핵심 인용
> "원문" — 발표자
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
    "relevance": { "portfolio": 4, "godblade": 1, "business": 3 },
    "status": "pending",
    "has_comparison": true,
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

## 주의사항

- 영어 트랜스크립트 → 핵심 포인트는 한국어 번역
- 타임스탬프는 반드시 클릭 가능한 YouTube 링크
- 자동 생성 자막(is_generated_subtitle: true) 시 정확도 주의
- 30분+ 영상은 섹션별 분석
- `--urls`, `--search`, `--playlist` 옵션도 그대로 전달 가능
- Notion DB 등록 실패 시 Tier 2 Fallback으로 진행 (파이프라인 중단 안 함)
