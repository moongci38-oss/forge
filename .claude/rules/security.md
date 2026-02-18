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

### Brave Search API
- 무료 플랜: 2,000 쿼리/월
- Rate limit 모니터링: 과도한 루프 검색 금지

### 외부 서비스 연동 시
- API 키는 환경변수로만 관리
- 하드코딩 절대 금지
- 로그 파일에 민감 정보 포함 금지
