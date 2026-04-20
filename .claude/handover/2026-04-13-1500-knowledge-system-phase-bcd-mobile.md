# 세션 인수인계 — 개인 지식 체계 Phase B/C/D 완성 + Obsidian 모바일

**세션 기간**: 2026-04-13 09:59 ~ 15:30 KST (약 5.5시간)
**세션 슬러그**: `2026-04-13-1500`
**관련 repo**: forge, forge-vault (신규), godblade-client (보조)
**선행 세션**: `2026-04-12-2000-system-audit-ci-knowledge-system.md` (개인 지식 체계 Phase A 완료)

---

## 1. 세션 목적

1. 선행 세션에서 미완료였던 **개인 지식 체계 Phase B/C/D** 완성 (Karpathy 3-layer Wiki)
2. **Obsidian 모바일 셋업** (iOS Git 플러그인 기반)
3. 작업 중 발견된 **알려진 한계와 부수 버그** 정리

---

## 2. 수행 작업 (6 트랙)

### Track A — Phase B: LightRAG wiki context + 자동 재인덱싱

**목표**: 20-wiki 노트가 LightRAG 그래프 검색에 들어가도록.

- `shared/scripts/lightrag-pilot.py`에 `wiki` context 추가
  - `WIKI_PILOT_DIR`/`WIKI_WORKING_DIR`/`WIKI_DIR` 경로 정의
  - `collect_wiki_docs()` — `_meta/reviews/` 제외, min length 100자
  - `cmd_index()` / arg parser에 `wiki` 분기 + `weekly|grants|wiki` 검증
- 첫 인덱싱: 4개 노트 → LightRAG 그래프 22 엔티티 추출 (44.7s)
- hybrid 쿼리 정상 동작 검증 (9.13s)
- `shared/scripts/wiki-sync.sh` 확장:
  - rsync `--itemize-changes`로 .md 신규/변경 감지
  - 30s 디바운스 → LightRAG `index --context wiki` 자동 트리거
  - PENDING_FLAG mtime 보존으로 편집 중 반복 인덱싱 방지
- `.claude/skills/rag-search/SKILL.md`에 워크스페이스 RAG vs LightRAG 비교표 + LightRAG 컨텍스트 3종(wiki/grants/weekly) 사용 가이드 추가

**관련 커밋**: `403cb70`, `47dfba6`

### Track B — Phase C: `/wiki-sync` 스킬 + 첫 회차 실행

**목표**: Raw layer(01-research) → Wiki layer(20-wiki) 추출 워크플로우 자동화.

- skill-creator 사용해 `.claude/skills/wiki-sync/SKILL.md` 신규 작성
- 5단계 워크플로우: Scan → Read → Match → Propose [STOP] → Apply
- 핵심 원칙: **Human 승인 게이트 없이 wiki 자동 변경 금지** (rubber-stamp 방지)
- `.claude/commands/wiki-sync.md` 슬래시 커맨드 신규
- skill validator PASS

**첫 회차 실행 (3 raw → 1 update + 3 new)**:
1. 2026-04-12 Gemma 4 영상 → `concepts/karpathy-llm-wiki.md` 섹션 추가 + `tools/obsidian.md` + `tools/gemma-4.md` 신규
2. 2026-04-09 클로드 코드 사내 운영 → `concepts/ai-native-company.md` 신규 + karpathy-llm-wiki 크로스링크
3. 2026-04-04 영상 100% 자동화 → `ai-native-company.md` "부록: 유사 사례" 섹션만 추가 (신호 약함)
- 트래킹: `_meta/sync-tracking.json` (7 ingested)
- MOC.md 갱신 (신규 노트 인덱싱)

**관련 커밋**: `9f1a734`

### Track C — Phase D: `wiki_search` MCP 도구

**목표**: forge-tools MCP 서버에서 LightRAG wiki context를 cloud agent가 호출 가능하게.

- `shared/mcp/forge-tools-server.py`에 `wiki_search(query, mode)` 신규
  - LightRAG `--context wiki` 호출, mode = local/global/hybrid
  - `rag_search` 설명 보강 (워크스페이스 RAG vs LightRAG 차이)
  - `ALLOWED_SCRIPTS`에 `lightrag-pilot.py`, `wiki-sync.sh` 화이트리스트 추가
- forge-mcp 서비스 재시작 → daily v10, weekly v8 갱신
- engraph MCP 실험은 미진행 (wiki_search 경로로 충족, 인수인계의 "or" 대안)

**관련 커밋**: `cd4454c` (이후 `e7c9641`로 forge-outputs/ 잘못 커밋 부분 정리)

### Track D — dev 프로젝트 wiki 노트

**목표**: 개발 프로젝트 컨텍스트도 Wiki Layer에 정리해서 모바일/크로스 프로젝트에서 참조.

- `topics/portfolio-project.md` — Next.js 16 + NestJS 10 + PostgreSQL 16 풀스택, 모노레포 구조, 모델 라우팅, CI/CD 2종, 흔한 함정
- `topics/godblade.md` — C# 게임 서버 분산 아키텍처(REST + TCP 8개 서버), Unity 클라이언트, 의존성 순서, LFS 워크플로우(오늘 셋업분 반영)

forge-outputs는 git 외부라 commit은 안 들어가지만, 양방향 sync로 vault + LightRAG 양쪽 모두 반영됨.

### Track E — Obsidian 모바일 셋업

**목표**: iOS에서 forge-vault를 모바일 vault로 동기화.

- 옵션 분석: 4가지 (Obsidian Sync 유료 / Git 플러그인 / iCloud / Self-hosted) 중 **Git 플러그인** 채택
- `/mnt/e/forge-vault` git init + `main` 브랜치 + .gitignore (`.obsidian/workspace*`, cache, .trash 제외)
- 신규 GitHub repo 생성: **https://github.com/moongci38-oss/forge-vault** (private)
- 첫 커밋 `a0912e5` push
- `wiki-sync.sh`에 **vault auto-push 통합** (5분 디바운스, LightRAG 30s와 별도 PENDING_FLAG)
  - `git status --porcelain` 검사로 no-op 방지
  - 자동 commit 메시지: `auto-sync: YYYY-MM-DD HH:MM:SS`
- iOS Obsidian 셋업 진행 가이드:
  1. PAT 발급 (또는 `gh auth token` 재사용) — `.env`의 GITHUB_TOKEN과 다를 수 있음 (오늘 사례)
  2. Play/App Store에서 Obsidian 설치
  3. 빈 vault 생성 (Sync 결제 함정 회피)
  4. Community Plugin "Obsidian Git" (작성자: Vinzent03) 설치
  5. Authentication: username + PAT
  6. 명령 팔레트 → Clone an existing remote repo → URL/directory/depth 입력
- Clone 검증: 13파일 5폴더 정상 표시 ✓
- auto-push 검증: `8d205a6` 등 수회 자동 commit 성공

**관련 커밋**: `c4e1206`

### Track F — 부수 정리 (3건)

#### F-1. yt-analyzer 경로 계산 버그

- **증상**: `~/forge/forge-outputs/`라는 잘못된 디렉토리가 forge-core.md 규칙(`forge-outputs/는 forge/의 형제 폴더`)을 위반하며 자동 생성되어 있음
- **근본 원인**: `shared/scripts/yt-analyzer/config.py:7`의 `Path(__file__).resolve().parent.parent.parent` (3단계만 위로) → `FORGE_DIR=/home/damools/forge/shared` (잘못, 4단계 필요)
- `FORGE_DIR.parent / "forge-outputs"` → `/home/damools/forge/forge-outputs` (위반)
- **수정**: `parents[3]` (4단계) + 절대경로 검증 가드 + `FORGE_OUTPUTS_DEFAULT` 변수 분리
- **검증**: FORGE_DIR=`/home/damools/forge`, OUTPUT_DIR=`/home/damools/forge-outputs/01-research/videos` ✓
- **주의**: yt-analyzer는 forge `.gitignore`에 personal-only 등록 → 이 수정은 **로컬 only**, 다른 머신은 별도 적용 필요

#### F-2. forge-outputs/ 잘못 커밋 + 정리

- 이전 커밋(`cd4454c`)에서 실수로 `~/forge/forge-outputs/` 하위 파일들이 forge git에 들어감 (`git add forge-outputs` CWD 트랩)
- `git rm -r --cached forge-outputs` + `.gitignore`에 `/forge-outputs/` 추가 (`e7c9641`)
- 디스크 파일 처리: unique 파일만 `~/forge-outputs/`로 mv, 중복 4개 삭제, `~/forge/forge-outputs/` 디렉토리 자체 사라짐

#### F-3. LightRAG mtime 추적

- **문제 발견**: `/wiki-sync` Step 5에서 `karpathy-llm-wiki.md`를 2회 업데이트했지만 LightRAG가 path 기반 추적이라 새 섹션을 그래프에 반영 안 함
- **해결**: `indexed.json` 스키마를 `["path"]` (set) → `{"path": mtime}` (dict)로 변경
  - 구버전 자동 마이그레이션 (mtime=0)
  - mtime + 1초 마진(rsync 시간차 흡수) 비교
  - 신규/수정 분리 분류 + `(new)`/`(modified)` 라벨
- **검증**: README.md 1줄 추가 → "1개 수정 문서 재인덱싱" 정상 트리거, 그래프 56→107→221 노드 증분
- **알려진 후속 한계**: LightRAG `ainsert`는 콘텐츠 해시 dedup → 동일 내용 재삽입 무시. 깔끔한 해결은 `adelete_by_doc_id()` + insert 패턴 (다음 개선)

**관련 커밋**: `0a867e5`

---

## 3. 전체 커밋 타임라인 (forge develop)

| 순서 | 커밋 | 설명 |
|:----:|------|------|
| 1 | `6b45016` | docs(readme): Managed Agents 섹션 확장 — MCP 14종 도구 + 운영 제약 |
| 2 | `66b4152` | chore: .gitlab-ci.yml 삭제 + README MCP Servers에 forge-tools 추가 |
| 3 | `403cb70` | feat(wiki): Obsidian vault 양방향 동기화 + LightRAG wiki context (Phase B) |
| 4 | `47dfba6` | feat(wiki): wiki-sync 자동 재인덱싱 + rag-search LightRAG 통합 가이드 |
| 5 | `9f1a734` | feat(skill): /wiki-sync — Raw → Wiki 추출 워크플로우 (Phase C) |
| 6 | `cd4454c` | feat(mcp): forge-tools에 wiki_search 도구 추가 (Phase D) — 일부 잘못 커밋 |
| 7 | `e7c9641` | revert: forge-outputs/ 잘못 커밋 정리 + .gitignore 추가 |
| 8 | `c4e1206` | feat(wiki-sync): vault → GitHub 자동 push (5분 디바운스) |
| 9 | `0a867e5` | feat(lightrag): mtime 추적 — 수정된 wiki 노트 자동 재인덱싱 |

**forge-vault repo (신규)**:
| 커밋 | 설명 |
|------|------|
| `a0912e5` | Initial vault commit — wiki + concepts + tools + topics |
| `6415634` | auto-sync: 2026-04-13 13:41:07 (auto-push 첫 검증) |
| `8d205a6` | auto-sync: 2026-04-13 15:13:54 (실 운영 동작) |

---

## 4. 신규 아키텍처 컴포넌트

### 4.1 LightRAG wiki context

- 위치: `shared/lightrag-wiki-data/index/` (gitignored)
- 스키마: `indexed.json` = `{path: mtime}` (구버전 list 자동 마이그레이션)
- 호출: `python3 ~/forge/shared/scripts/lightrag-pilot.py query "..." hybrid --context wiki`

### 4.2 wiki-sync.sh (양방향 sync + 디바운스 인덱싱 + 자동 push)

- 위치: `shared/scripts/wiki-sync.sh`
- 동작:
  ```
  vault ↔ forge-outputs/20-wiki  (rsync --update, 5초 폴링)
       ↓ 30초 무변경
  LightRAG --context wiki 재인덱싱
       ↓ 5분 무변경
  vault git add+commit+push (forge-vault main)
  ```
- 자동 시작: `~/.bashrc`에 `tmux new-session -d -s wiki-sync ...` 등록 (forge-mcp 패턴과 동일)
- 로그: `/tmp/wiki-sync.log`, `/tmp/wiki-index.log`, `/tmp/wiki-push.log`

### 4.3 forge-vault GitHub repo

- URL: https://github.com/moongci38-oss/forge-vault (private)
- 로컬: `/mnt/e/forge-vault/` (Windows 네이티브 NTFS — WSL 마운트 시 fs.watch EISDIR 우회)
- 모바일 동기화: iOS Obsidian Git 플러그인 (PAT 인증)
- 자동 push: PC wiki-sync.sh 5분 디바운스가 처리

### 4.4 wiki_search MCP 도구

- 위치: `shared/mcp/forge-tools-server.py` `wiki_search()` 함수
- 호출: `mcp__forge-tools__wiki_search(query, mode)`
- LightRAG-pilot script 위임, ALLOWED_SCRIPTS 확장 필요했음

### 4.5 /wiki-sync 스킬 + 슬래시 커맨드

- 스킬: `.claude/skills/wiki-sync/SKILL.md`
- 커맨드: `.claude/commands/wiki-sync.md`
- 모델: sonnet
- 워크플로우: 5 Steps (Scan → Read → Match → Propose [STOP] → Apply)

---

## 5. 미해결 / 후속 과제

### 즉시 영향 있음

1. **LightRAG ainsert 콘텐츠 해시 dedup** — 수정된 노트의 graph 갱신이 best-effort. 깔끔한 해결: `adelete_by_doc_id()` + insert 2단계 패턴. mtime 추적은 이미 완비됨.
2. **yt-analyzer config.py 수정 전파** — gitignored라 local only. 다른 머신(예: 클라우드 Managed Agent)에서 `/yt` 호출 시 동일 버그 발생 가능. forge-tools-server.py 같은 절대경로 처리로 우회 검토 또는 personal gitignore 해제 검토.

### 중기

3. **engraph MCP 실험** (Phase D 대안 경로) — wiki_search MCP로 충족됐지만 별개 가치 가능성. 미진행.
4. **Notion 모바일 인증** — 폰에서 OAuth 콜백 URL 접근 불가, 데스크톱 재시도 필요 (선행 세션 미해결).
5. **forge staging auto-merge 검증** — develop 최신으로 reset 후 정상 흐름 미확인 (선행 세션 미해결).
6. **Anthropic Tier 업그레이드 검토** — 현재 Tier 1, 팀 확장 시 Tier 2+ 필요 (선행 세션 미해결).

### 장기

7. **iOS Obsidian Git 한계** — isomorphic-git 기반이라 PC보다 느림(2~5분 clone). 대규모 작업 시 PC가 주, 모바일은 읽기 위주가 현실적.

---

## 6. 다음 세션 진입점 체크리스트

다음 세션 시작 시:

1. **이 파일 읽기**: `~/forge-outputs/docs/handover/2026-04-13-1500-knowledge-system-phase-bcd-mobile.md`
2. **선행 세션 참조**: `2026-04-12-2000-system-audit-ci-knowledge-system.md` (Phase A 컨텍스트)
3. **MEMORY.md 신규/갱신 항목 확인**:
   - `[개인 지식 체계 (Phase A~D)]` (갱신, 기존 phase_a → complete로 리네임됨)
   - `[Obsidian Vault 동기화]` (신규)
   - `[LightRAG wiki context]` (신규)
   - `[상대경로 금지]` (신규 feedback)
4. **wiki-sync 세션 확인**: `tmux ls | grep wiki-sync` — WSL 재시작 후 자동 시작되어야 함
5. **forge-vault 상태 확인**: `cd /mnt/e/forge-vault && git status` — 모바일 변경 pending 있는지

---

## 7. 핵심 파일 경로 맵

```
# 신규 스크립트
forge/shared/scripts/wiki-sync.sh                   ← 양방향 + 디바운스 + auto-push
forge/shared/scripts/lightrag-pilot.py              ← wiki context 추가, mtime 추적
forge/shared/scripts/yt-analyzer/config.py          ← parents[3] 버그 수정 (local only)

# 신규 스킬 / 커맨드
forge/.claude/skills/wiki-sync/SKILL.md             ← Phase C Raw→Wiki 워크플로우
forge/.claude/commands/wiki-sync.md                 ← /wiki-sync 슬래시
forge/.claude/skills/rag-search/SKILL.md            ← LightRAG 통합 가이드 추가

# MCP
forge/shared/mcp/forge-tools-server.py              ← wiki_search 도구 + ALLOWED_SCRIPTS 확장

# 인프라 설정
~/.bashrc                                            ← wiki-sync tmux 자동 시작
forge/.gitignore                                     ← /forge-outputs/, lightrag-*-data/

# Wiki 노트 (forge-outputs/20-wiki/)
concepts/karpathy-llm-wiki.md                       ← 2회 업데이트 (LightRAG vs LLM Wiki + Gemma 4 미채택)
concepts/ai-native-company.md                       ← 신규 (Compound + 트리아지 + 멘탈 모델 + 노정호 부록)
tools/obsidian.md                                   ← 신규 (vault 위치 + WSL 한계 + 동기화 흐름)
tools/gemma-4.md                                    ← 신규 (스펙 + 미채택 이유 + 모니터링)
topics/portfolio-project.md                         ← 신규 (Next.js+NestJS 풀스택 정리)
topics/godblade.md                                  ← 신규 (C# 분산 + Unity + LFS 워크플로우)
_meta/MOC.md                                        ← 갱신 (신규 노트 인덱싱)
_meta/sync-tracking.json                            ← 신규 (7 ingested)

# 신규 외부 repo
github.com/moongci38-oss/forge-vault (private)      ← Obsidian vault GitHub mirror
/mnt/e/forge-vault/                                  ← Windows 네이티브 vault

# 보조 작업 (godblade-client)
god_Sword/src/client/.gitattributes                 ← LFS 추적 규칙
god_Sword/src/client/.gitignore                     ← GraphicResource 외부 보유
god_Sword/src/client/README.md                      ← 팀 온보딩 가이드 (LFS 포함)
```

---

## 8. 새 규칙 / 컨벤션 (오늘 추가)

- **forge `.gitignore` 확장**: `/forge-outputs/`, `shared/lightrag-{pilot,grants,wiki}-data/`
- **vault `.gitignore`**: `.obsidian/workspace*`, cache, .trash, OS 파일
- **상대경로 금지**: 스크립트는 항상 `Path(__file__).resolve().parents[N]` 또는 환경변수 + 절대경로 검증. CWD 상대경로(`forge-outputs/...`) 사용 시 잘못된 위치에 디렉토리 자동 생성 위험 (오늘 사례).
- **wiki-sync 디바운스 분리**: 재인덱싱은 30s, 자동 push는 5분 (커밋 스팸 방지).
- **wiki 변경 = Human 승인 필수**: `/wiki-sync` 스킬은 Step 4 [STOP] 게이트 강제, AI 자동 wiki 수정 금지.
- **iOS 모바일 동기화 = Git 플러그인 only**: Obsidian Sync(유료) 함정 회피 안내 필수.

---

## 9. 메트릭

| 항목 | 수치 |
|------|------|
| 세션 길이 | ~5.5h (비공식 측정) |
| forge develop 커밋 | 9 |
| forge-vault 커밋 | 3 (1 init + 2 auto-sync) |
| 신규 wiki 노트 | 5 (concepts 1 + tools 2 + topics 2) |
| 갱신 wiki 노트 | 1 (karpathy-llm-wiki, 2회) |
| LightRAG 그래프 노드 | 56 → 221 (+165) |
| 발견/수정한 버그 | 3 (yt-analyzer 경로 + LightRAG path-only + .env 토큰 mismatch) |

---

*작성자: Claude Opus 4.6 (1M context)*
*작성일: 2026-04-13 KST*
*세션 스타일: Phase B/C/D 일거 완성 + 모바일 셋업 + 부수 정리 멀티 트랙*
