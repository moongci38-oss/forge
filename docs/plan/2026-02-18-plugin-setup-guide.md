# Cowork Plugin 설치 가이드

**작성일**: 2026-02-18
**참조**: `docs/tech/Claude Code CLI 플러그인 시스템과 Cowork 양방향 상호운용성 기술 백서.md`

---

## 마켓플레이스 등록 (1회만)

```bash
# anthropics/knowledge-work-plugins 마켓플레이스 추가
claude plugin marketplace add anthropics/knowledge-work-plugins
```

---

## Phase 1: 즉시 설치 (4개)

```bash
# 06-project-management: 태스크, 캘린더, Notion/Slack 연동
claude plugin install productivity@knowledge-work-plugins --scope project

# 03-product-planning: 스펙, 로드맵, Figma/Linear 연동
claude plugin install product-management@knowledge-work-plugins --scope project

# 04-marketing: 콘텐츠, 캠페인, HubSpot/Ahrefs/Canva 연동
claude plugin install marketing@knowledge-work-plugins --scope project

# 전체: 크로스 폴더 통합 검색 (Slack, Notion, Jira 등)
claude plugin install enterprise-search@knowledge-work-plugins --scope project
```

---

## Phase 2: 데이터/재무/법무 (신중한 검토 후)

```bash
# 01-research, 02-business-strategy: SQL, 통계 분석
claude plugin install data@knowledge-work-plugins --scope project

# 07-operations/finances: 재무제표, 분개 (로컬 스코프 권장)
claude plugin install finance@knowledge-work-plugins --scope local

# 07-operations/legal: 계약 리뷰, NDA (로컬 스코프 권장)
claude plugin install legal@knowledge-work-plugins --scope local
```

> ⚠️ `finance`, `legal` 플러그인은 `--scope local`로 설치하면 `.claude/settings.local.json`에 저장되어 git 추적 대상에서 제외됩니다.

---

## Phase 3: 필요 시

```bash
# 04-marketing: 프로스펙트, 파이프라인 관리
claude plugin install sales@knowledge-work-plugins --scope project

# 04-marketing: 고객 대응, 티켓 분류
claude plugin install customer-support@knowledge-work-plugins --scope project

# 커스텀 플러그인 생성/편집 도우미
claude plugin install cowork-plugin-management@knowledge-work-plugins --scope project
```

---

## 설치 현황 확인

```bash
# 설치된 플러그인 목록
claude plugin list

# 마켓플레이스 목록
claude plugin marketplace list

# 특정 플러그인 활성화/비활성화
claude plugin enable productivity
claude plugin disable productivity
```

---

## 스코프 결정 기준

| 상황 | 스코프 | 저장 위치 |
|------|--------|---------|
| 팀/프로젝트 공유 필요 | `--scope project` | `.claude/settings.json` (git 추적) |
| 머신별 개인 설정, 민감 데이터 연동 | `--scope local` | `.claude/settings.local.json` (gitignore) |
| 개인 환경 전반 | `--scope user` (기본) | `~/.claude/settings.json` |

---

## 플러그인 구조 참고 (커스텀 플러그인 생성 시)

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json      # 필수: name 필드만 있으면 됨
├── commands/            # 슬래시 커맨드
├── agents/              # 서브에이전트
├── skills/              # SKILL.md + YAML 프론트매터
├── hooks/
│   └── hooks.json       # PreToolUse, PostToolUse, UserPromptSubmit 등
└── .mcp.json            # MCP 서버 정의
```

**로컬 테스트**:
```bash
claude --plugin-dir ./my-plugin
```

---

*출처: anthropics/knowledge-work-plugins, Claude Code CLI 백서 (2026-02)*
