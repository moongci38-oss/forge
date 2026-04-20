# 세션 인수인계 — Karpathy Wiki 정렬 + 레거시 바둑이 복구 + Telegram Workspace 분리

**세션 기간**: 2026-04-13 21:19 ~ 2026-04-14 11:50 KST (약 14.5시간, 다중 서브태스크)
**세션 슬러그**: `2026-04-14-1200`
**선행 세션**: `2026-04-13-1630-harness-hook-session-id-fix.md` (하네스 관측성 버그 수정)

---

## 1. 이번 세션의 실제 목적

선행 세션 인수인계 문서는 "D/E/Z 드라이브 10년 아카이브 이주"가 차기 작업으로 예정되어 있었다. 이번 세션은 그 작업을 포함해 **연속적으로 스코프가 확장되면서 6개 대형 작업을 동시 수행**했다:

1. **D/E 10년 아카이브 카탈로그화** (원래 계획)
2. **Karpathy LLM Wiki 철학 정렬** (사용자가 gist 공유)
3. **169 Raw → 33 wiki 노트 대량 큐레이션** (Karpathy 패턴 실천)
4. **고포류 레거시 프로젝트 발견 + pingame 파트너십 정리**
5. **레거시 바둑이 Node.js 서버 로컬 복구 시도 (Option A)**
6. **Telegram Workspace 분리 (Option B)** — Forge와 격리된 독립 도메인

세션이 길고 다층적인 이유: 사용자의 Karpathy gist 공유가 중간에 들어와 vault 전체 재구성 트리거 → 레거시 바둑이 연결 → pingame 실제 개발 계획 확인 → 로컬 복구 시도 → Telegram 분리 요청 순으로 연쇄 확장.

---

## 2. 완료된 작업 (커밋된 것)

### 2.1 D/E 10년 아카이브 카탈로그 (forge 3ae43f4)

- **결과**: 56 클러스터 OK + 5 timeout, 166k 파일, 507GB 카탈로그화
- **위치**: `forge-outputs/20-wiki/30-archive/` (67 카드) + LightRAG archive context (66 docs 임베딩)
- **핵심 파일**:
  - `forge/shared/scripts/archive-indexer.py` (scan/scan-one 서브커맨드)
  - `forge/shared/scripts/archive-shallow-scan.sh` (drvfs 9P hang 회피 depth-1)
  - `forge/shared/scripts/archive-deep-orchestrate.sh` (per-cluster 5min timeout)
  - `forge/shared/scripts/archive-cards.py` (deep-*.jsonl → vault 카드)
  - `forge/shared/scripts/archive-exclusions.txt` (제외 패턴)
- **timeout 5건 (수동 처리 가능)**: D 드라이브 nox/workspace, E 드라이브 new_workspace/portfolio_project/workspace
- **exclude 추가됨**: 사용자 요청으로 `*영화*`, `*드라마*`, `동영상_자동화_자료` 패턴
- **자연어 검증**: "2021년 FX 프로젝트 어디?" → `/mnt/d/fx` 정확 응답

### 2.2 Karpathy LLM Wiki 철학 정렬 (forge-vault 4324df0)

사용자가 2개 참조 공유:
- https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f (원본 철학)
- https://github.com/citizendev9c/yt-assets/tree/main/automation/claude-code/llmwiki-26-04-11 (한국어 구현 가이드)

**vault 전체 재구성**:
- **`forge-outputs/20-wiki/CLAUDE.md` 신설** — vault-local schema. 모든 AI 세션 진입 규칙. 3-layer 정의, 카테고리 컨벤션, 페이지 템플릿, Core Operations(Ingest/Query/Lint), 승격 heuristic, 링크/금지 규칙, Growth 원칙
- **`_meta/index.md` 신설** — auto-generated content catalog (모든 노트 카테고리별 + 한 줄 요약)
- **`_meta/log.md` 신설** — 연대기 append-only (본 세션 events backfill)
- **`_meta/lint-log.md`** — wiki-sync + health lint 통합 리포트
- **`_meta/context.md` 신설** — Track A/B/C 사업 맥락 + 10 우선 도메인
- **스크립트 4개 신규** (`forge` 735e140):
  - `wiki-fix-dangling-refs.py` — curator 생성 dangling `[[YYYY-MM-DD-XXX]]` 173개를 읽기 가능한 형식으로 교체
  - `wiki-fix-inter-links.py` — slug 불일치 + 템플릿 쓰레기 + stub 노트 생성
  - `wiki-build-index.py` — index.md 자동 생성
  - `wiki-health-lint.py` — broken refs / orphans / stale stubs / growth-heavy 검진
- **cron 추가**: 매월 1일 09:00 wiki-sync-lint, 09:05 wiki-health-lint

### 2.3 169 Raw → 33 wiki 노트 대량 큐레이션 (forge-vault e138520)

3개 curator 에이전트 병렬:
- **analyses curator**: 122 영상 분석 → 23 노트 (9 concepts + 10 tools + 3 topics + 2 people)
- **daily curator**: 18 daily review → 3 노트 (ai-competitive-landscape, harness-evolution-log, daily-review-methodology)
- **weekly+projects curator**: 29 → 7 신규 + 2 업데이트 (godblade, portfolio-project 보강)

**Citizendev9c 가이드 Callout 규칙 백필** (forge-vault ec82135):
- 50개 노트 전부 H1 아래 `> [!info] 내게 어떤 의미인가` callout 삽입
- Track A 직결 8 / B 직결 3 / C 직결 14 / 복수 3 / 간접 5 / 참고 6 (정직한 평가)
- 2개 curator 에이전트 병렬 (Batch A 36 + Batch B 14)

**결과**: sync-tracking 7 → 176 ingested, lint count 169 → 0.

### 2.4 README.md 전면 재작성 (forge-vault 9062c99)

기존 초기 phase 개요를 **Karpathy 철학 + 아키텍처 + 4가지 열람 방법 + Core Operations + 현재 상태**로 재작성. 250+ lines. 새 세션 진입 시 여기부터 읽으면 됨.

### 2.5 고포류 레거시 발견 + pingame 파트너십 정리 (forge-vault fb586e9, 39827e5)

사용자 요청으로 `/mnt/d`, `/mnt/e` 전수 검색:
- **발견**: `/mnt/d/workspace/board_game/` (2022-04 동결 풀스택), `/mnt/e/document/바둑이/` (2026-04-07 pingame 활성), `/mnt/d/Moongci_Documents/한승진_홀덤`, 보드게임 인수인계 문서 (박홍연/김태훈)
- **위키 노트 생성**: `topics/legacy-gopo-projects.md`, `people/{park-hong-yeon, kim-tae-hoon, han-seung-jin, pingame}.md`
- **baduki-card-game.md 대폭 업데이트**: status "S1 완료, S2 대기" → **"S2 진행 중 — pingame 파트너십 확정, 인프라 셋업"**
- **사용자 확정 사실** (2026-04-14): pingame은 외부 업체, 본인이 개발 수행, 인프라는 본인 소유·운영, 신규 [[baduki-card-game]]와 동일 프로젝트

### 2.6 레거시 바둑이 로컬 복구 시도 — Option A (forge-vault 8a69ca9)

사용자 계획: "기존 소스로 바둑이 개발". 로컬 재가동 시도 + 검증.

**✅ 성공**:
- MySQL 8.0 root 비밀번호 설정 (`jsjy211217!@#`, localhost 한정, `auth_socket` → `caching_sha2_password`)
- 2021-02-05 덤프 import (113 테이블 + 29 프로시저, `spGetBdStaticData` 포함)
- baduggi Node.js 서버 Node 22 호환 확인 (Express 4 / Socket.IO 2 / mysql 2.18 — 컴파일 에러 0)
- MySQL 연결 성공 (`board_game` 사용자를 `mysql_native_password` 플러그인으로 변경)
- port 13306 → 3306 수정

**❌ 치명적 차단**:
- `pg_ai_baduggi_config` AI 튜닝 데이터 **16행 누락** (40/56)
- 서버 `assert(7 === size())` 실패 → 완전 재가동 불가
- 누락 데이터는 어느 .sql 파일에도 존재 안 함 (덤프 외부 수정 추정)

**⚠️ BTC/가상화폐 리스크 발견**:
- `batting_day_info`, `btc_last_price*`, `pg_cron_wallet_block_check` (47K 행)
- 신규 baduki의 "사행성 아님" 전제와 **정면 충돌**
- 이식 시 전면 제거 필수

**판정**: Option A "재가동" 중단. **추출·이식 모드**로 전환. `~/workspace/gopo-recovery/` 작업 디렉토리 보존 — 다음 세션 S2 개발 시 부분 재활용.

### 2.7 Telegram Workspace 분리 (telegram-workspace 5022c72 로컬)

**근거**: Forge와 Telegram은 도메인 분리 필요 (토큰 낭비 + 컨텍스트 혼탁 + 보안 경계).

**구조**:
- `~/workspace/telegram-workspace/` 신규 git repo
- `CLAUDE.md` (schema), `.claude/settings.json`, `.claude/skills/{tg-reply, tg-broadcast, tg-access}`
- `bot/{config.json, allowlist.json, inbox, approved, templates/}` — allowlist/inbox/approved는 MCP 플러그인 호환 위해 `~/.claude/channels/telegram/`로 심볼릭 링크
- `.env` (mode 600) — 2 bot 토큰 통합 (plugin-telegram + forge-agent-server)
- `agent-server/README.md` — 향후 FORGE_AGENT_SERVER_BOT_* 스크립트 이동 placeholder
- 메모리 격리: `~/.claude/projects/-home-damools-workspace-telegram-workspace/memory/` (3건: tone 선호, Notion 자동 스킵, 모호한 답도 자율 실행)
- **원격 없음** (credentials 유출 리스크 관리)

### 2.8 P2 적용 (이전 /yt 추천)

- **P2-1**: `wiki-sync-lint.py` + 매월 1일 09:00 cron — 169 pending 감지
- **P2-2**: `forge-outputs/20-wiki/_clipper/` 폴더 + `_meta/web-clipper-integration.md` 평가 문서

---

## 3. Git 커밋 요약

| Repo | 커밋 | 내용 |
|---|---|---|
| **forge** | `9767d4e` → `39a468e` develop | 하네스 hook + archive 스크립트 + wiki-sync-lint + 4 wiki 유지보수 스크립트 + learnings |
| **forge-outputs** | ... → `93c7471` develop | 30-archive-meta + 누적 grants/videos 정리 |
| **forge-vault** | `a0912e5` → `8a69ca9` main | 20-wiki 전면 재구성 (50 → 55 노트, Karpathy 정렬, 고포류, pingame) |
| **telegram-workspace** (신규) | `5022c72` main (로컬) | 독립 워크스페이스 첫 커밋 |

---

## 4. 현재 상태 스냅샷

### 4.1 Wiki (forge-vault)

- **55 노트** (concepts 18 / tools 18 / topics 12 / people 7)
- **15 stub** (growth seeds)
- 내부 링크: 172+
- **Broken / Orphan / Dangling: 0 / 0 / 0** (100% healthy)
- LightRAG `wiki` + `archive` context 모두 활성

### 4.2 로컬 MySQL (복구 작업 산물)

- MySQL 8.0 실행 중, root 비번 `jsjy211217!@#`, bind-address 127.0.0.1
- DB: `board_game` (113 테이블 + 29 프로시저), `board_log` (빈 스키마)
- 사용자: `board_game@localhost` + `board_game@%` (`mysql_native_password`, 비번 `board_game2014!@#`)
- 작업 디렉토리: `~/workspace/gopo-recovery/`

### 4.3 Telegram Workspace

- 디렉토리: `~/workspace/telegram-workspace/` (git repo, 로컬 only)
- MCP 플러그인 경로 심볼릭 링크로 호환
- 2 bot 토큰 `.env` 통합 (gitignored)

### 4.4 Notion 자동 스킵 규칙

feedback memory 2건(forge, telegram-workspace 각각)에 저장됨. 다음 세션부터 `/yt`, `/daily-analyze`, `/weekly-analyze` 등에서 인증 실패 시 자동 Tier 2 전환.

---

## 5. 다음 세션 진입점 체크리스트

### 5.1 먼저 읽을 파일 (순서대로)

1. **이 파일** — `~/forge-outputs/docs/handover/2026-04-14-1200-...md`
2. **forge-vault README.md** — 현재 위키 상태 + Karpathy 철학 정리
3. **`forge-outputs/20-wiki/CLAUDE.md`** — vault schema
4. **`forge-outputs/20-wiki/_meta/context.md`** — Track A/B/C + 우선 도메인
5. **`forge-outputs/20-wiki/_meta/log.md`** — 최근 14시간 이벤트 타임라인

### 5.2 검증 명령 (현상 확인)

```bash
# wiki 건강도
python3 ~/forge/shared/scripts/wiki-health-lint.py
python3 ~/forge/shared/scripts/wiki-sync-lint.py

# 3 repo 상태
cd ~/forge && git log --oneline -3
cd ~/forge-outputs && git log --oneline -3
cd ~/forge-outputs/20-wiki && git log --oneline -3
cd ~/workspace/telegram-workspace && git log --oneline -3

# 로컬 MySQL board_game
mysql -u root -pjsjy211217\!@\# -e "USE board_game; SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='board_game';"

# LightRAG archive context 쿼리 테스트
python3 ~/forge/shared/scripts/lightrag-pilot.py query "바둑이 legacy 소스 어디" hybrid --context archive
```

---

## 6. 다음 세션 우선순위 작업 (계획)

### Priority 1 — baduki-card-game S2 진행 (pingame 파트너십)

**맥락**: Track A 최우선 + pingame 외부 파트너십 확정 + 레거시 자산 보유 + Option A 재가동은 실패했지만 **추출·이식 경로 확보**.

**S2 체크리스트** (`topics/baduki-card-game.md`에서):
- [ ] pingame 계약 형태·수익 분배 문서화
- [ ] pingame 담당자·의사결정자 식별
- [ ] 2026-04-07 네트워크 v1 / 서버 v2 외 추가 문서 버전 확인
- [ ] 본인 인프라 스펙·용량·비용 구조 정리
- [ ] 론칭 일정·마일스톤 합의

**기술 추출 작업**:
- [ ] 레거시 113 테이블 → 신규 범위 20~30개 선별 (BTC/가상화폐 전면 제외)
- [ ] 29 프로시저 중 `spGetJackpot`, `spUpdateBaduggiResult`, `spResetKeyGauge` 등 게임 로직 이식 방안
- [ ] 서버 스택 현대화: Express 4 → Express 5, mysql → mysql2, socket.io 2 → 4, TypeScript 도입 검토
- [ ] AI 봇 알고리즘 C# 소스에서 족보 판정/교환 휴리스틱 발췌 → Unity 6 또는 Node.js 포팅
- [ ] DB 디자인 문서 활용: `/mnt/d/workspace/board_game/document_server/ai_data/보드게임DB 및 값_2021_02_16.xlsx`

**작업 디렉토리**: `~/workspace/gopo-recovery/` (재활용 가능)

### Priority 2 — 30-archive timeout 5건 수동 스캔

사용자 요청 시:
- D 드라이브: `nox`, `workspace`
- E 드라이브: `new_workspace`, `portfolio_project`, `workspace`

Unity Library/Temp 등 대형 캐시 제외 경로 추가 후 `archive-indexer.py scan-one --path ...`로 하위 경로 지정 부분 스캔.

### Priority 3 — Telegram Workspace 실제 사용 검증

- Telegram에서 메시지 수신 → `tg-reply` 스킬 실제 트리거 확인
- `bot/templates/weekly-research-complete.md` 를 forge cron이 실제로 사용하도록 연동 (forge/shared/scripts/weekly-research/run.sh에서 telegram-workspace 호출 추가)
- `agent-server/` 의 forge_agent_server_bot 스크립트 1차 구축

### Priority 4 — 개인 지식 체계 지속 운영

- 월 1회 wiki-sync-lint + wiki-health-lint cron 실제 발효 확인 (다음달 1일)
- 새 Raw 유입 시 큐레이터 패턴(주제 클러스터링) 유지
- Stub 15개 → 다음 Raw 유입과 매칭되면 본격 노트로 승격

---

## 7. 주의 사항 / 남은 의문

### 7.1 pingame 관계 명확화 필요

사용자 답변: "외부업체, 개발, 본인 인프라, 동일 노선". 이걸 기반으로 위키 정리했지만 여전히 모호:
- **pingame이 퍼블리셔인가 발주처인가 공동운영자인가?**
- **수익 분배 구조는?**
- **과거 레거시 팀([[park-hong-yeon]], [[kim-tae-hoon]])과 pingame의 관계?**

다음 세션에서 사용자 확인 + baduki-card-game.md 업데이트 필수.

### 7.2 BTC/가상화폐 법률 리스크

- 레거시 DB에 BTC 거래 테이블 다수
- 신규 baduki "사행성 아님" 전제와 충돌
- **현재 로컬 MySQL board_game DB에 이 테이블들이 그대로 import되어 있음** — 스키마 이식 작업 전 반드시 제거 필수
- 게임물관리위원회 심의 직전 스캔 필수 (`wallet|btc|coin|exchange` 키워드)

### 7.3 Option A 재가동 16행 누락 데이터

"합성 데이터로 밀어붙이기"는 권장 안 함. 대신:
- 레거시 운영 DB 실제 백업 있는지 박홍연/김태훈 등 과거 팀에게 확인 가능한지?
- 아니면 재설계 시 division 개수 조정 (5 또는 7 중 택1)

### 7.4 Telegram Workspace 원격 저장소

현재 로컬 only. GitHub에 올리면 `.env` 유출 위험. 만약 원격을 원하면:
1. GitHub private repo 생성
2. `.env` 확실히 gitignored 되었는지 재확인
3. bot token이 과거 커밋에 들어갔는지 확인 (현재는 없음)

### 7.5 forge-outputs 정부과제 작업물

세션 중간에 누적된 sme-tech-rd 관련 수정·삭제를 `93c7471`로 일괄 커밋했음. 이는 이전 grants-write 세션 작업물의 정리라 내용 검증 없이 기계적 커밋. 사용자가 내용 확인 필요할 수 있음.

---

## 8. 핵심 파일 경로 맵

```
# 이번 세션 생성/수정 (forge)
forge/shared/scripts/
├── archive-indexer.py              (scan/scan-one 서브커맨드)
├── archive-shallow-scan.sh         (drvfs hang 회피)
├── archive-deep-orchestrate.sh     (per-cluster timeout)
├── archive-cards.py                (카드 생성)
├── archive-exclusions.txt          (제외 패턴 — 영화/드라마 추가됨)
├── wiki-sync-lint.py               (월 1회 cron)
├── wiki-health-lint.py             (월 1회 cron)
├── wiki-fix-dangling-refs.py       (1회성 고치기)
├── wiki-fix-inter-links.py         (1회성 고치기)
├── wiki-build-index.py             (index.md 자동 생성)
└── lightrag-pilot.py               (archive context 추가됨)

forge/.claude/
├── learnings.jsonl                 (이번 세션 7건 append)
└── (기타 hooks 기존과 동일)

# 이번 세션 생성/수정 (forge-outputs)
forge-outputs/20-wiki/
├── README.md                       (전면 재작성)
├── CLAUDE.md                       (신규 — vault schema)
├── _meta/
│   ├── context.md                  (신규 — Track A/B/C)
│   ├── index.md                    (신규 — auto-generated)
│   ├── log.md                      (신규 — 연대기)
│   ├── lint-log.md                 (신규)
│   ├── sync-tracking.json          (176 ingested)
│   └── web-clipper-integration.md  (P2-2 평가)
├── _clipper/README.md              (P2-2 신규 폴더)
├── concepts/ tools/ topics/ people/  (55 노트, 33 신규 + callout 백필)
└── 30-archive/
    ├── d/ e/                       (67 카드)
    ├── _meta/                      (scan-log, promotion-queue, exclusions)

forge-outputs/30-archive-meta/      (아카이브 스캔 산출물)
├── shallow-{d,e}.jsonl
├── deep-{d,e}.jsonl
├── deep-{d,e}-errors.jsonl
├── scan-progress-{d,e}.jsonl
└── scan-preview.md

# 이번 세션 생성 (workspace)
~/workspace/
├── gopo-recovery/                  (레거시 바둑이 복구 작업 디렉토리)
│   ├── db/board_game.sql + boad_game_2021_02_05.sql
│   ├── baduggi/                    (npm install + port 수정 완료)
│   └── matgo/                      (원본 복사본)
└── telegram-workspace/             (신규 독립 워크스페이스)
    ├── CLAUDE.md .env .gitignore
    ├── .claude/skills/{tg-reply, tg-broadcast, tg-access}/
    ├── bot/{config.json, allowlist(symlink), templates/*.md}
    └── agent-server/README.md

# 메모리 (신규/수정)
~/.claude/projects/-home-damools-forge/memory/
├── MEMORY.md                       (4건 추가)
├── project_archive_drives.md       (D/E 10년 카탈로그)
├── project_gopo_recovery_attempt.md       (신규 — 본 세션 종료 시 작성)
├── project_telegram_workspace_separation.md (신규 — 본 세션 종료 시 작성)
├── project_pingame_partnership.md  (신규 — 본 세션 종료 시 작성)
├── project_karpathy_wiki_alignment.md (신규 — 본 세션 종료 시 작성)
└── feedback_notion_auto_skip.md    (이미 추가됨)

~/.claude/projects/-home-damools-workspace-telegram-workspace/memory/
├── MEMORY.md
├── user_tone_preferences.md
├── feedback_notion_auto_skip.md
└── feedback_autonomous_on_ambiguous.md
```

---

## 9. 차기 세션 진입 프롬프트 예시

```
이전 세션 인수인계 로드해줘:
~/forge-outputs/docs/handover/2026-04-14-1200-wiki-karpathy-alignment-legacy-recovery-telegram-workspace.md

우선 Priority 1의 baduki-card-game S2 기술 추출 작업 시작하자.
먼저 113 테이블 중 BTC/가상화폐 관련 제거 + 신규 범위용 20~30개 후보 선정부터.
```

또는 Telegram 워크스페이스에서 시작하려면:

```
cd ~/workspace/telegram-workspace && claude
```

---

*작성자: Claude Opus 4.6 (1M context)*
*작성일: 2026-04-14 12:00 KST*
*세션 스타일: 다층 연쇄 — 원래 계획(아카이브)에서 시작해 Karpathy 정렬 + 레거시 발굴 + 파트너십 정리 + 로컬 복구 시도 + 도메인 분리까지 확장*
