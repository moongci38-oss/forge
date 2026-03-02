# Trine Rules — Category Registry

> Trine 개발 파이프라인 규칙 빌드 순서 및 의존성 정의.
> 원본: `~/.claude/trine/rules/` (개발 프로젝트에 symlink 배포)

| 순서 | 카테고리 | ID | Impact | 의존성 | 설명 |
|:--:|---------|------|:------:|--------|------|
| 1 | 워크플로우 | trine-workflow | HIGH | — | Phase 구조, 검증 체계, Auto-Fix, Implicit Entry |
| 2 | 세션 상태 | trine-session-state | HIGH | trine-workflow | 멀티세션, 체크포인트, autoFix WAL |
| 3 | 컨텍스트 엔지니어링 | trine-context-engineering | HIGH | trine-workflow | ACE-FCA, Skill/Subagent 결정, Passive/Active/Deep 로딩 |
| 4 | 컨텍스트 관리 | trine-context-management | MEDIUM | trine-context-engineering | 200K 윈도우 관리, /compact 트리거 |
| 5 | 요구사항 분석 | trine-requirements-analysis | HIGH | trine-workflow | Phase 1.5 Q&A, 도메인 완결성 체크 |
| 6 | Walkthrough | trine-walkthrough | MEDIUM | trine-workflow | 구현 결과 문서화, Check 3.5 입력 |
| 7 | 진행 관리 | trine-progress | MEDIUM | trine-session-state | PM 문서 자동 갱신, 외부 도구 연동 |
| 8 | 테스트 품질 | trine-test-quality | HIGH | trine-workflow | Check 3.5T 6축 검증 |
| 9 | 백엔드 성능 | trine-performance | HIGH | — | NestJS 성능 7룰 (N+1, 페이지네이션, 인덱스 등) |
| 10 | 모듈 의존성 | trine-module-dependency | MEDIUM | — | NestJS 모듈 계층, 순환 의존성 방지 |
| 11 | Playground 연동 | trine-playground | LOW | trine-workflow | 3개 템플릿 Phase 매핑 |

## 로딩 전략

| Impact | 로딩 단계 | 토큰 |
|:------:|----------|:----:|
| HIGH | **Passive** — AGENTS.md 압축 (~750토큰, 항상 로드) | ~750 |
| MEDIUM | **Active** — 스킬 호출 시 개별 룰 로드 | ~200/룰 |
| LOW | **Deep** — Check 실행 시 해당 카테고리만 로드 | ~200/룰 |
