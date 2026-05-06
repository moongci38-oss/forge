# 커뮤니티 MCP Connector 도입 정책

## 필수 체크리스트 (모두 통과해야 도입)

### 1. 라이선스
- [ ] MIT / Apache 2.0 / GPL v3 확인
- [ ] 상용 제약 없음

### 2. 저장소 건강도
- [ ] GitHub 최근 활동: 최근 3개월 내 커밋 존재
- [ ] Stars ≥ 1,000 (또는 Anthropic 공식 파트너)
- [ ] 미해결 Critical 이슈 없음
- [ ] Readme 명확 + 설치 가이드 완료

### 3. 소스 코드 검토 (필수)
- [ ] 외부 URL 호출 범위 확인 (악의적 외부 통신 차단)
- [ ] 파일시스템 접근 경로 제한 확인 (~ 이상 상위 접근 방지)
- [ ] 로컬 서버 포트 바인딩만 (원격 서버 불가)
- [ ] 환경변수/API key 하드코딩 없음
- [ ] 알려진 CVE 없음 (CVE 검색: `{repo-name} CVE`)

### 4. 로컬 실행 전용
- [ ] localhost 또는 unix socket 통신만
- [ ] 포트 hardening (고정 포트 vs 동적 할당)

### 5. 성능/안정성
- [ ] 메모리 누수 테스트 결과 (issue 또는 discussion)
- [ ] 타 LLM 호환성 검증 (Claude 전용 최적화인지 확인)
- [ ] 시간초과/에러 처리 명확

## 권장 (도입 후 추가)

- [ ] 로컬 테스트: `/test-mcp` 스킬로 기본 동작 확인 (생성 예정)
- [ ] 모니터링: `~/.claude/hooks/mcp-error-monitor.sh` (MCP stderr 추적)
- [ ] 격리: Docker 컨테이너 내 실행 (선택)

## 도입 기간

| 단계 | 기간 |
|------|------|
| 정책 검토 | 2-3일 (코드 리뷰) |
| 로컬 테스트 | 1-2일 |
| 프로덕션 배포 | 진행 |
| 모니터링 | 지속 |

## 승인 절차

1. **개발자**: 위 체크리스트 작성
2. **Lead**: 코드 리뷰 확인 + 서명
3. **추적**: `docs/approvals/mcp-connectors.md`에 레코드

---

## 사례: Blender MCP (ahujasid/blender-mcp)

| 항목 | 결과 |
|------|------|
| 라이선스 | ✅ MIT |
| 저장소 | ✅ ★21.1k, 활발 유지 |
| 코드 | ⚠️ 소켓 통신 (로컬만), 파일 접근 Poly Haven/Sketchfab API 호출 |
| 보안 | ⚠️ 커뮤니티 원작 (Anthropic 공식 지원 X) → 코드 직접 리뷰 필수 |
| 승인 | ⏳ P2-2 (Blender 실험) 전 P2-3 체크리스트 완료 필수 |

---

**작성**: 2026-05-03
**참조**: RSA 2026 MCP connector 보안 경고 + Anthropic 공식 MCP 문서
