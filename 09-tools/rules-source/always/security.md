---
title: "보안 체크리스트"
id: security-rules
impact: CRITICAL
scope: [always, cowork]
tags: [security, sensitive, access-control]
section: core
audience: all
impactDescription: "미준수 시 API 키 유출, 민감 재무/법무 데이터 노출 위험. 복구 불가능한 보안 사고 발생 가능"
enforcement: rigid
---

# 보안 체크리스트

## 민감 정보 보호

### 절대 커밋 금지
- `.env`, `.env.local`, `.env.production`
- `credentials.json`, `secrets.yaml`
- API 키, 토큰, 패스워드
- `06-finance/*` (재무 데이터)
- `07-legal/*` (법무 문서)
- `08-admin/*` (경영관리 민감 문서)

### .gitignore 필수 항목
```
.env
.env.local
*.key
*.pem
credentials.json
secrets/
06-finance/
07-legal/
08-admin/finances/
08-admin/freelancers/
```

## 파일 접근 제한

### Claude Code 읽기 금지 영역
- `06-finance/` (재무 데이터)
- `07-legal/` (법무 문서)
- `08-admin/insurance/`, `08-admin/freelancers/` (민감 행정 문서)
- `.ssh/`, `.aws/` (인증 정보)
- `.env*` 파일 (환경 변수)

## MCP 보안

### MCP 서버 설정 경로

Claude Code가 인식하는 MCP 설정 파일은 **2곳뿐**이다:

| 경로 | Scope | 설정 방법 |
|------|-------|----------|
| `프로젝트루트/.mcp.json` | project | `claude mcp add {name} --scope project` |
| `~/.claude.json` 내 mcpServers | user (전역) | `claude mcp add {name} --scope user` |

**Claude Code가 무시하는 경로:**
- `~/.claude/.mcp.json` — 이 경로는 인식되지 않는다
- `~/.claude/settings.json` — MCP 서버를 지원하지 않는다

**Scope 결정 기준:**
- 특정 프로젝트 전용 (DB, Redis 등) → `--scope project`
- 멀티 프로젝트 공용 (stitch, nanobanana 등) → `--scope user`

### Filesystem MCP
- Business 워크스페이스 범위 내에서만 동작
- `06-finance/`, `07-legal/`, `08-admin/` 민감 파일 접근 요청 시 거부

### 외부 서비스 연동 시
- API 키는 환경변수로만 관리
- 하드코딩 절대 금지
- 로그 파일에 민감 정보 포함 금지

## Do

- `.gitignore`에 `.env`, `credentials.json`, `secrets/`, `06-finance/`, `07-legal/` 경로를 포함한다
- API 키와 토큰은 환경변수로만 관리한다
- 06-08 폴더 내 파일 접근 요청 시 즉시 거부하고 이유를 안내한다

## Don't

- `.env`, `credentials.json` 등 민감 파일을 커밋하지 않는다
- 코드에 API 키, 토큰, 패스워드를 하드코딩하지 않는다
- 로그 파일에 민감 정보를 포함하지 않는다
- `~/.claude/.mcp.json`에 MCP 서버를 설정하지 않는다 (Claude Code 미인식 경로)

## AI 행동 규칙

1. `06-finance/`, `07-legal/`, `08-admin/` 경로의 파일 접근 요청 시 즉시 거부한다
2. 하드코딩된 시크릿 발견 시 환경변수로 이동을 안내한다
3. 커밋 전 민감 파일 포함 여부를 확인한다

## Iron Laws

- **IRON-1**: 민감 정보(.env, credentials, API 키)를 절대 커밋하지 않는다
- **IRON-2**: 06-finance/, 07-legal/, 08-admin/ 내용을 외부로 출력하지 않는다
- **IRON-3**: 하드코딩된 시크릿을 코드에 포함하지 않는다

## Rationalization Table

| 합리화 (Thought) | 현실 (Reality) |
|-------------------|---------------|
| "테스트 환경이니까 실제 API 키를 사용해도 괜찮다" | 테스트 환경의 키도 유출 시 프로덕션 접근 경로가 된다. 항상 별도 테스트 키를 사용한다 |
| "로컬에서만 쓸 건데 커밋해도 되겠지" | Git 히스토리에 영구 기록된다. force push로도 완전 삭제 불가. 처음부터 .gitignore에 포함한다 |
| "이 파일은 민감하지 않은 것 같다" | 확실하지 않으면 민감하다고 가정한다. 06-08 폴더 내 파일은 내용 무관하게 보호 대상이다 |

## Red Flags

- "임시로만 이 키를 여기에..." → STOP. 환경변수로 이동한다
- "이 폴더는 괜찮겠지..." → STOP. 06-08 폴더인지 확인한다
- "로그에 잠깐 찍어보고 지우면..." → STOP. 로그에 민감 정보를 절대 포함하지 않는다
- "~/.claude/ 안에 .mcp.json 넣으면..." → STOP. 프로젝트루트/.mcp.json 또는 `claude mcp add --scope user`를 사용한다
