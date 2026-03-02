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

### Filesystem MCP
- Business 워크스페이스 범위 내에서만 동작
- `06-finance/`, `07-legal/`, `08-admin/` 민감 파일 접근 요청 시 거부

### 외부 서비스 연동 시
- API 키는 환경변수로만 관리
- 하드코딩 절대 금지
- 로그 파일에 민감 정보 포함 금지

---

## Cowork 환경 보안 (Hooks 미작동 대체)

> Cowork에서는 `.claude/hooks/` 스크립트가 실행되지 않으므로 아래 규칙으로 동일한 보호 수준을 유지한다.

### 민감 파일 접근 차단 (block-sensitive-files.sh 대체)
- `06-finance/`, `07-legal/`, `08-admin/insurance/`, `08-admin/freelancers/` 경로의 파일을 Read, Write, Edit 도구로 접근 금지
- 해당 경로가 포함된 파일 경로 요청 시 즉시 거부
- 사용자에게 "해당 파일은 직접 편집기로 관리하세요" 안내

### 파일명 규칙 강제 (require-date-prefix.sh 대체)
- `docs/` 하위 `.md` 파일 생성 시 `YYYY-MM-DD-{name}.md` 형식 필수
- 허용 형식: `YYYY-MM-DD-`, `YYYY-WW-`, `YYYY-Q{1-4}-`
- 예외 파일: CLAUDE.md, README.md, index.md, subscriptions.md, domains.md, terms-of-service.md, privacy-policy.md

### Git 안전 (no-force-push.sh 대체)
- `git push --force` / `git push -f` / `--force-with-lease` → main/master 대상 절대 금지
- feature/, fix/, hotfix/, release/, chore/, docs/ 브랜치만 force push 허용

### 세션 시작 컨텍스트 (session-context.sh 대체)
- Cowork 세션 시작 시 자동 인식할 사항:
  - Track A(제품사업) 작업 우선
  - Track B(06-finance, 07-legal, 08-admin 민감 영역) 접근 금지
  - 새 문서 파일명에 날짜 prefix 적용
  - Cowork에서는 auto memory 불가 → 기존 파일 참조로 컨텍스트 복원
