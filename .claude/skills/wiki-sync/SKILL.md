---
name: wiki-sync
description: Karpathy 3-layer 개인 지식 체계의 Raw → Wiki 추출 워크플로우. forge-outputs의 Raw 레이어(01-research/, daily-system-review/, weekly-research/, videos/, yt 분석)에서 아직 위키화되지 않은 신규 문서를 스캔하고, 기존 wiki 노트와 매칭하여 업데이트 또는 신규 생성을 제안하며, Human 승인 루프를 통해 forge-outputs/20-wiki/에 반영한다. /wiki-sync, "위키 동기화", "raw to wiki", "20-wiki 업데이트" 요청 시 트리거. Phase C 지식 체계 워크플로우.
---

# Wiki Sync — Raw to Wiki Extraction Workflow

## Overview

Karpathy 3-layer 패턴(Raw → Wiki → Meta) 중 **Raw → Wiki 변환을 Human-in-the-loop**로 수행한다. AI는 신규 Raw 문서를 스캔하고, 기존 Wiki 노트와 비교해서 어디에 어떤 내용을 추가/통합할지 제안한다. Human이 승인한 변경만 실제로 적용된다.

## Layer 정의

| Layer | 위치 | 역할 | 누가 채우나 |
|-------|------|------|-----------|
| **Raw** | `forge-outputs/01-research/`, `forge-outputs/01-research/videos/analyses/`, `forge-outputs/01-research/daily/`, `forge-outputs/01-research/weekly/` | 원본·로그 (불변) | 자동 파이프라인 (`/yt`, `/daily-analyze`, `/weekly-research` 등) |
| **Wiki** | `forge-outputs/20-wiki/topics/`, `concepts/`, `tools/`, `people/` | 주제 영구 노트 (1주제 = 1문서) | AI 제안 + Human 승인 (이 스킬) |
| **Meta** | `forge-outputs/20-wiki/_meta/MOC.md`, `_meta/questions.md`, `_meta/hubs/`, `_meta/reviews/` | 허브·질문·회고 | Human 주도 (AI는 보조) |

원칙: **Wiki 노트는 AI가 마음대로 쓰지 않는다.** 모든 변경은 Human 승인 필수.

## Workflow (6 Steps)

### Step 1 — Scan: 미반영 Raw 문서 식별

```bash
# 1.1 트래킹 파일 확인 (없으면 빈 set으로 시작)
TRACKING=~/forge-outputs/20-wiki/_meta/sync-tracking.json
[ -f "$TRACKING" ] || echo '{"ingested": []}' > "$TRACKING"

# 1.2 Raw 후보 디렉토리 (최근 30일 우선)
RAW_DIRS=(
  ~/forge-outputs/01-research/videos/analyses
  ~/forge-outputs/01-research/daily
  ~/forge-outputs/01-research/weekly
  ~/forge-outputs/01-research/projects
  ~/forge-outputs/01-research/articles
)
```

Glob으로 `*.md` 파일 목록을 얻고, `sync-tracking.json`의 `ingested` 배열에 없는 항목만 후보로 남긴다. 한 회 처리량은 **10개**로 제한.

### Step 2 — Read: Raw 문서 핵심 추출

각 후보 문서를 Read해서 다음을 추출한다:

- **핵심 개념** (3~5개): 등장 인물, 도구, 개념, 패턴
- **인사이트** (1~3개): 새로 발견한 사실/관점/주장
- **출처 메타**: 파일 경로, 작성일

이 단계의 출력은 메모리에만 둔다 (파일 X).

### Step 3 — Match: 기존 Wiki 노트와 매핑

`forge-outputs/20-wiki/` 트리를 Glob으로 스캔해서 기존 노트 목록을 얻는다. 각 핵심 개념에 대해:

| 매칭 결과 | 액션 |
|----------|------|
| **존재 (정확 일치)** | UPDATE 후보 — 기존 노트에 새 인사이트 추가 제안 |
| **유사 노트 존재** | UPDATE 후보 (병합 제안) 또는 NEW 후보 (분리 권장) |
| **존재 안 함** | NEW 후보 — 신규 노트 생성 제안 |

매칭 정확도가 의심스러우면 `/rag-search "{개념}" --context wiki`를 호출해서 의미 검색으로 보강한다.

### Step 3.5 — AI 매칭 품질 사전 평가 (신규)

Human 게이트(Step 4) 전에 AI가 각 매칭 제안의 신뢰도를 자체 평가한다.

**신뢰도 등급 기준**:

| 등급 | 신뢰도 | 판단 기준 | 처리 |
|------|:------:|----------|------|
| **HIGH** | 80%+ | 개념 이름 정확 일치 + 인사이트가 명확히 새로운 사실 | `[AI 추천 자동승인]` 태그 부여 |
| **MEDIUM** | 50~80% | 유사 개념이지만 범위/의미 경계 불확실 | Human 검토 필요 표시 |
| **LOW** | 50% 미만 | 연관성 약함, 오매칭 가능성 있음 | 스킵 + `_meta/pending-review.md`에 기록 |

**신뢰도 HIGH 자동승인 조건** (모두 만족해야 함):
1. 개념 키워드가 기존 노트 제목 또는 첫 H1에 정확히 포함됨
2. 추가할 인사이트가 기존 노트에 없는 새로운 내용임 (중복 검사 Grep 실행)
3. 출처 Raw 문서의 작성 날짜가 기존 노트의 마지막 수정일보다 최신임

**--auto 모드에서의 추가 동작**:
- HIGH만 자동 처리, MEDIUM/LOW는 `pending-review.md`에 이관
- 매 실행 시 pending-review.md에 미처리 항목 누적 → 수동 모드에서 후속 처리

```
# Step 3.5 출력 예시 (Step 4 Propose 전 AI 내부 평가)
평가 결과:
  [1] UPDATE → concepts/karpathy-llm-wiki.md   신뢰도: HIGH (88%) [AI 추천 자동승인]
      근거: "Karpathy LLM Wiki" 키워드 기존 노트 H1 포함, 추가 인사이트 중복 없음
  [2] NEW → tools/gemma-4.md                   신뢰도: MEDIUM (65%)
      근거: "Gemma 4" 노트 미존재하나 tools/google-models.md와 범위 겹침 가능
  [3] UPDATE → concepts/local-llm.md           신뢰도: LOW (40%) → SKIP
      근거: Raw 문서의 해당 언급이 주제 보조적이며 인사이트 불충분
```

### Step 4 — Propose [STOP]: Human 승인 루프

각 변경 제안을 다음 형식으로 출력한다. **반드시 [STOP] 게이트로 Human 승인을 받는다.**

신뢰도 HIGH 항목에는 `[AI 추천 자동승인]` 태그를 표시하여 Human이 빠르게 판단할 수 있도록 한다.

```
═══════════════════════════════════════════
📄 Raw 문서: 2026-04-12-TNEwF_WmgO4-gemma4-second-brain-analysis.md
═══════════════════════════════════════════

🔍 추출된 핵심 개념: 3개
  1. Gemma 4 (도구)
  2. 로컬 LLM vs 클라우드 (개념)
  3. Karpathy LLM Wiki 패턴 (개념, 기존 존재)

📝 제안 변경: 2건

[1] UPDATE → concepts/karpathy-llm-wiki.md    ✅ 신뢰도 HIGH (88%) [AI 추천 자동승인]
─────────────────────────────────────
변경 유형: 섹션 추가
추가 내용:
  ## 실제 적용 사례
  - Gemma 4 로컬 LLM은 Claude 대비 효용 낮음 (VRAM 20-24GB 부담)
  - Obsidian + git 동기화 패턴이 더 실용적
  출처: [[2026-04-12-gemma4-second-brain]]

[2] NEW → tools/gemma-4.md    ⚠️ 신뢰도 MEDIUM (65%) [Human 검토 필요]
─────────────────────────────────────
새 노트 제목: Gemma 4 (Google 오픈소스 LLM)
초안 (50줄):
  # Gemma 4

  Google이 공개한 오픈소스 LLM 시리즈. ...
  [전체 내용]

═══════════════════════════════════════════
[STOP] 승인 옵션:
  a) 모두 적용 (apply all)
  b) 일부만 적용 (예: "1만 적용", "2 제외")
  c) 수정 요청 (예: "[1]의 출처 표기 수정")
  d) 거부 (skip — sync-tracking에는 기록)
═══════════════════════════════════════════
```

다중 Raw 문서가 있으면 **각 Raw 문서마다 별도 [STOP]**. 한 번에 모두 묶어 보여주지 않는다.

### Step 5 — Apply: 승인된 변경만 반영 + 트래킹 갱신

Human이 a/b/c로 승인한 변경만:

1. **UPDATE**: Edit 도구로 기존 노트에 섹션 추가 (출처 wikilink `[[...]]` 필수)
2. **NEW**: Write 도구로 새 노트 생성 (frontmatter 포함)
3. **트래킹 갱신**: `sync-tracking.json`의 `ingested` 배열에 처리한 Raw 파일 경로 추가

```bash
# 트래킹 갱신 예
python3 -c "
import json
from pathlib import Path
tracking = Path.home() / 'forge-outputs/20-wiki/_meta/sync-tracking.json'
data = json.loads(tracking.read_text())
data['ingested'].extend(['{processed_paths}'])
data['ingested'] = sorted(set(data['ingested']))
tracking.write_text(json.dumps(data, indent=2, ensure_ascii=False))
"
```

거부(d)된 항목도 `ingested`에 기록 — 다시 제안되지 않도록.

## 신규 노트 작성 규칙

- **frontmatter 필수**:
  ```yaml
  ---
  title: 노트 제목
  type: concept | tool | person | topic
  created: YYYY-MM-DD
  sources:
    - path/to/raw1.md
    - path/to/raw2.md
  ---
  ```
- **위키링크**(`[[...]]`)로 다른 노트 연결
- **출처 인용**: 본문 내 사실/주장 옆에 `(출처: [[...]])` 표기
- **언어**: 한국어 기본 (Karpathy 3-layer 원칙은 forge-outputs/20-wiki/README.md 참조)

## 자주 발생하는 판단 케이스

| 케이스 | 권장 |
|--------|------|
| Raw 1개에 핵심 개념 5개 이상 | 가장 중요한 3개만 제안, 나머지는 다음 회차 |
| 기존 노트에 정확히 같은 내용 이미 있음 | 제안 자체를 만들지 않음 (skip + tracking 기록) |
| 인사이트가 1줄 미만 | 제안 안 함 (신호 부족) |
| Raw 문서가 회고/감상 | _meta/reviews/ 후보로 분류 (자동 wiki화 안 함) |
| 동일 주제로 여러 Raw 누적 | UPDATE 후보를 1회로 묶어서 제안 |
| 신뢰도 LOW 매칭 | Step 3.5에서 즉시 스킵 + pending-review.md 기록 |

## 실행 모드

### 수동 모드 (기본)
`/wiki-sync` — Step 4 [STOP] 게이트 활성. Human 승인 후에만 적용.

### 자동 모드 (`--auto`)
`/wiki-sync --auto` — cron/CCR 원격 실행용.
- Step 3.5에서 신뢰도 **HIGH** 항목만 자동 처리 (Step 4 [STOP] 건너뜀)
- MEDIUM/LOW 항목: skip + `_meta/pending-review.md`에 기록 (다음 수동 세션에서 처리)
- 변경 사항은 git commit & push로 기록 (커밋 메시지에 처리된 Raw 목록 포함)
- 처리량: 10개 Raw/회

## AI 행동 규칙

1. **6단계 순서를 건너뛰지 않는다**. 수동 모드에서 Step 4 [STOP]은 반드시 명시적 승인을 받는다
2. **Step 3.5 신뢰도 평가는 필수**: --auto 모드에서 HIGH 외 항목을 자동 처리하면 안 된다
3. **--auto 모드**: Step 3.5 HIGH 항목만 처리, MEDIUM/LOW는 pending-review.md로
4. **출처 추적**: 모든 변경에 Raw 출처 wikilink 필수
5. **트래킹 갱신은 마지막**: Apply 완료 후에만 sync-tracking.json 갱신
6. **컨텍스트 절약**: 한 회 처리량 10개 Raw로 제한
7. **유사도 의심 시**: --auto 모드에서는 skip + pending-review.md 기록
8. **--auto 완료 후**: `git add -A && git commit -m "wiki-sync(auto): ..." && git push`

## 트래킹 파일 스키마

`forge-outputs/20-wiki/_meta/sync-tracking.json`:

```json
{
  "ingested": [
    "/home/damools/forge-outputs/01-research/videos/analyses/2026-04-12-xxx.md",
    "/home/damools/forge-outputs/01-research/daily/2026-04-12-daily.md"
  ],
  "rejected": [
    {
      "path": "...",
      "reason": "신호 부족",
      "date": "2026-04-13"
    }
  ],
  "last_run": "2026-04-13T12:35:00Z"
}
```

## 관련 파일 / 도구

- `forge-outputs/20-wiki/README.md` — Karpathy 3-layer 원칙 + 노트 작성 규칙
- `forge-outputs/20-wiki/_meta/MOC.md` — 위키 전체 허브
- `forge-outputs/20-wiki/_meta/pending-review.md` — AI가 처리 보류한 LOW 신뢰도 항목 목록
- `~/forge/shared/scripts/wiki-sync.sh` — Obsidian vault 양방향 동기화 + LightRAG 자동 재인덱싱 (이 스킬과 별개로 백그라운드 실행 중)
- `~/forge/shared/scripts/lightrag-pilot.py index --context wiki` — wiki 인덱스 재구축 (Apply 후 자동 트리거됨)
- `/rag-search --context wiki` — 위키 의미 검색 보강
