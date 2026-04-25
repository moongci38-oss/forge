# 세션 인수인계 — 하네스 Hook session_id 수정

**세션 기간**: 2026-04-13 16:34 ~ 17:00 KST (약 30분)
**세션 슬러그**: `2026-04-13-1630`
**관련 repo**: forge (develop 브랜치)
**선행 세션**: `2026-04-13-1500-knowledge-system-phase-bcd-mobile.md` (개인 지식 체계 Phase B/C/D 완성 + Obsidian 모바일)

---

## 1. 세션 목적

하네스 관측 계층(`usage.log`)의 근본 버그 한 건을 진단하고 수정한다. 선행 세션이 기반을 닦은 상태에서, 측정 데이터가 실제로 세션 단위로 쌓이고 있지 않음을 발견했고 하네스 자체 신뢰도를 복원한 세션이다.

---

## 2. 진단 경로

### 2.1 최초 증상

`~/forge/.claude/usage.log` 확인:
- 파일 크기 1.7MB, 16096줄
- 3월 19일부터 누적, log rotation 없음
- **`grep -oP '"session":"[^"]*"' ... | sort -u`** → 유일값이 `"session":"unknown"` 단 하나

즉 선행 세션들의 모든 tool 사용 기록이 같은 "unknown" 세션으로 묶여 있어, 세션 단위 분석(budget summary, override rate, auto-learn-save)이 전부 의미를 잃은 상태였다.

### 2.2 원인 추적

`~/forge/.claude/hooks/usage-logger.sh:8` 확인:
```bash
SESSION="${CLAUDE_SESSION_ID:-unknown}"
```

`CLAUDE_SESSION_ID` 환경변수가 설정되지 않으면 unknown으로 폴백. 그런데 Claude Code의 PostToolUse/Stop hook은 실제로 **stdin JSON의 `.session_id` 필드**로 세션을 전달한다. 환경변수는 존재하지 않는다.

동일 패턴이 `agent-token-budget.sh:16`, `cleanup-agent-budget.sh:6`에도 있었음.

### 2.3 부수 발견

- Log rotation 없음 → 3월 19일부터 1.7MB까지 무한 증가
- `agent-token-budget.sh`는 stdin을 `head -c 500`으로만 읽고 있어 JSON 파싱 자체가 불가능한 구조였음

---

## 3. 수정 내용

### 3.1 `usage-logger.sh`
- stdin 전체 `HOOK_JSON`으로 받고 `jq -r '.session_id // empty'`로 우선 추출
- `CLAUDE_SESSION_ID` env fallback 유지
- **5MB 초과 시 `usage.log.1`로 회전** (보존 1세대)
- 동일 패턴으로 `.tool_name`, `.tool_input.file_path`도 jq로 추출

### 3.2 `agent-token-budget.sh`
- stdin 전체를 `HOOK_JSON`에 보관 후:
  - `.session_id` → SESSION
  - `.tool_name` → TOOL_NAME (env fallback)
  - `.tool_response // .tool_input` → RESULT (에러 감지용, `head -c 500`로 trim)
- 기존 `head -c 500` 직접 읽기 제거

### 3.3 `cleanup-agent-budget.sh`
- Stop hook은 stdin에 `{session_id, hook_event_name:"Stop", stop_hook_active}` JSON이 옴
- 이를 파싱해 SESSION 추출, env fallback 유지

### 3.4 공통 패턴

```bash
HOOK_JSON=""
if [ ! -t 0 ]; then
  HOOK_JSON=$(cat 2>/dev/null || true)
fi
SESSION=$(echo "$HOOK_JSON" | jq -r '.session_id // empty' 2>/dev/null)
[ -z "$SESSION" ] && SESSION="${CLAUDE_SESSION_ID:-unknown}"
```

---

## 4. 검증

### 4.1 시뮬레이션

```bash
echo '{"session_id":"test-sess-123","hook_event_name":"PostToolUse","tool_name":"Read","tool_input":{"file_path":"/tmp/foo.md"}}' | bash .claude/hooks/usage-logger.sh
tail -1 .claude/usage.log
# → {"ts":"2026-04-13T10:13:25Z","event":"tool_use","tool":"Read","subtype":"search","file":"/tmp/foo.md","session":"test-sess-123"}
```

session_id, tool_name, file_path 모두 정확히 추출됨.

### 4.2 실제 hook 발효 확인

수정 직후 `.claude/agent-budget/` 디렉토리에 UUID 형식 파일(`b477cce4-b668-4fef-97ef-5de41d939a3c.count`)이 생성된 것을 확인. 이는 실제로 Claude Code가 hook을 새 로직으로 호출하면서 진짜 session_id를 카운트 파일명에 사용 중임을 의미.

### 4.3 cleanup

```bash
echo '{"session_id":"test-sess-456","hook_event_name":"Stop"}' | bash .claude/hooks/cleanup-agent-budget.sh
# → usage.log에 {"ts":..., "event":"session_budget_summary", "session":"test-sess-456", "total_tool_calls":1, "total_errors":0}
```

요약 레코드의 session 필드도 정상.

---

## 5. 커밋

| 커밋 | 설명 |
|------|------|
| `9767d4e` | fix(hooks): stdin Hook JSON에서 session_id 추출 + usage.log 회전 |

푸시 완료: `0a867e5..9767d4e develop -> develop`

변경 파일 3개, +39 -11 lines.

---

## 6. 영향

이 수정 전까지 다음 하네스 구성요소가 전부 unknown 세션으로 합쳐져 무력화 상태였다:

- `session_budget_summary` (cleanup-agent-budget.sh) — 세션 종료 시 총 tool 호출/에러 요약
- `track-override-rate.sh` — Human override 비율 집계 (5-Level Autonomy 레벨 조정 근거)
- `auto-learn-save.sh` — 세션 활동 기반 learnings.jsonl 자동 저장
- `agent-token-budget.sh` 예산 카운트 자체도 session 파일 단위라 전부 `unknown.count`에 누적되어 다음 세션으로 오염 전파

이제부터는:
- 세션별 실제 UUID로 budget 추적
- override/rubber-stamp rate가 세션 단위로 집계됨 → 5-Level Autonomy 승격/강등 판단 데이터 신뢰 가능
- 5MB 초과 시 자연 회전되어 분석 속도 저하 방지

---

## 7. 관련 아티팩트

- Memory: `~/.claude/projects/-home-damools-forge/memory/project_harness_hook_fix_apr13.md`
- Learning: `~/forge/.claude/learnings.jsonl` (2026-04-13T16:45:00Z 엔트리)
- 커밋: `9767d4e`

---

## 8. 다음 작업 프리뷰 — D/E(/Z) 10년 아카이브 → Obsidian 이주

다음 세션에서 착수 예정. 구조 합의는 완료, 실행은 시작 전.

### 8.1 현황
- `/mnt/d`: flat 구조, ~18GB+, 10년치 낱개 pdf/xls/pptx + DUMP*.tmp + Moongci_Documents/ + bit_coin/ + eth/ + fx/ 등
- `/mnt/e`: 상대적 정돈 — `portfolio_project/` (10+ 프로젝트 폴더), `new_workspace/god_Sword`, `workspace/`, `spring_work/`, `document/`, `나의창업아이템/`, `정부지원/`, `디자인논문자료/`, `계약서/`
- `/mnt/z`: WSL 마운트 안 됨 → Step 0에서 사용자 확인 필요

### 8.2 설계 원칙 (Archive-First, Wiki-Promote)

**원본을 vault에 복사하지 않는다.** forge-vault는 GitHub 양방향 sync가 걸려 있어 10년치 원본 복사 시 repo 폭발. 대신 vault에는 **색인 카드(.md)만 쓴다**.

신설 구조:
```
forge-vault/
  30-archive/
    d/
      projects/        ← .git 보유 또는 package.json/pom.xml/*.sln 등
      documents/       ← pdf/docx/pptx/hwp/xlsx 클러스터
      media/           ← 이미지/영상/psd/ai
      _orphan/
    e/ (동일)
    z/ (Step 0 후)
    _meta/
      scan-log.json
      promotion-queue.md
      exclusions.txt   ← DUMP*.tmp, pagefile.sys, $RECYCLE.BIN, System Volume Information, node_modules, .git 내부 등
```

각 카드 프론트매터: `source_path / drive / category / last_modified / size_bytes / git`.

### 8.3 신설 도구

- **`forge/shared/scripts/archive-indexer.py`** — 드라이브 재귀 스캔, 분류, 카드 생성, promotion-queue 자동 제안
- **`/archive-index` 스킬** — Scan → Classify → Propose [STOP] → Apply (wiki-sync 패턴 이식)

### 8.4 Iron Laws (파괴적 액션 금지)

1. 원본 이동·삭제·rename 금지 (Human 명시 시만)
2. 색인 카드(.md)만 vault에 쓰기
3. 10MB 초과 단일 파일은 링크만
4. DUMP*.tmp, pagefile.sys, $RECYCLE.BIN, System Volume Information, node_modules, .git 내부, *.zip/tar/rar 내부는 스킵
5. 카드 생성 전 [STOP] 게이트로 전체 스캔 프리뷰 승인

### 8.5 차기 세션 Step 0 (사용자 확인 필수)

1. **Z 드라이브 경로/마운트 방법** — Windows 드라이브 문자? 외장? 네트워크 마운트?
2. **"의미있는 데이터" 선별 기준**:
   - (a) 10+ 년 이력 완전 보존
   - (b) 최근 3년 + 상업적 가치만
   - (c) Git 프로젝트 + 정부지원/계약 문서 우선
3. **카드 요약 수준**:
   - (a) 파일 리스트만 (빠름)
   - (b) AI가 대표 파일 샘플링 1줄 요약 (느림, 검색성 ↑)
   - (c) LightRAG archive context 신설 (가장 무겁지만 의미 검색 가능)

---

## 9. 핵심 파일 경로 맵

```
# 수정된 파일 (이번 세션)
forge/.claude/hooks/usage-logger.sh           ← stdin .session_id + log rotation
forge/.claude/hooks/agent-token-budget.sh     ← stdin .session_id/.tool_name/.tool_response
forge/.claude/hooks/cleanup-agent-budget.sh   ← stdin .session_id

# 관련 기존 파일 (이번 세션 미수정, 참조만)
forge/.claude/hooks/track-override-rate.sh    ← 이제 정상 session으로 집계
forge/.claude/hooks/auto-learn-save.sh        ← 이제 정상 session으로 학습 저장
forge/.claude/rules/autonomy-levels.md        ← Override Rate 소비처

# 관측 데이터
forge/.claude/usage.log                        ← 현재 1.7MB, 다음 5MB 도달 시 자동 회전
forge/.claude/override-rate.log                ← untracked, 새 hook 발효 후 정상 누적 기대
forge/.claude/gate-approval.log                ← untracked
forge/.claude/security.log                    ← untracked

# 인수인계 / 학습
~/forge-outputs/docs/handover/2026-04-13-1630-harness-hook-session-id-fix.md  ← 본 문서
~/forge/.claude/learnings.jsonl               ← 2026-04-13T16:45 엔트리 append
~/.claude/projects/-home-damools-forge/memory/project_harness_hook_fix_apr13.md  ← 신규
~/.claude/projects/-home-damools-forge/memory/MEMORY.md  ← 인덱스 1줄 추가
```

---

## 10. 다음 세션 진입점 체크리스트

1. **이 파일 읽기**: `~/forge-outputs/docs/handover/2026-04-13-1630-harness-hook-session-id-fix.md`
2. **플랜 파일 읽기**: `~/.claude/plans/peppy-jumping-dragonfly.md` — D/E/Z 이주 프로젝트 전체 설계
3. **선행 세션 참조**: `2026-04-13-1500-knowledge-system-phase-bcd-mobile.md`
4. **hook 발효 검증**: `grep -v '"session":"unknown"' ~/forge/.claude/usage.log | tail -5` — 새 세션 이후 entries가 진짜 UUID로 찍히는지 확인
5. **D/E/Z Step 0 질문 수행** (§8.5) 후 archive-indexer.py 구현 시작

---

*작성자: Claude Opus 4.6 (1M context)*
*작성일: 2026-04-13 KST*
*세션 스타일: 단일 트랙 — 하네스 관측성 버그 진단 + 수정 + 인계*
