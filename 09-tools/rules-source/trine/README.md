# Trine Rules

Trine 규칙 원본은 `~/.claude/trine/rules/`에서 관리된다.

개발 프로젝트(Portfolio/GodBlade)의 `.claude/rules/`에 symlink로 연결하여 사용.

## 표준 포맷 (v1.3.0)

모든 규칙 파일은 SIGIL 동일 YAML Frontmatter를 사용한다:
- **스키마**: `09-tools/rules-source/_schema.yaml`
- **템플릿**: `09-tools/rules-source/_template.md`
- **카테고리 레지스트리**: `09-tools/rules-source/trine/_sections.md`

## 파일 목록 (11개)

| 파일 | ID | Impact | 설명 |
|------|------|:------:|------|
| trine-workflow.md | trine-workflow | HIGH | Phase 구조 + 검증 체계 + Auto-Fix + Implicit Entry |
| trine-session-state.md | trine-session-state | HIGH | 멀티세션, 체크포인트, autoFix WAL |
| trine-context-engineering.md | trine-context-engineering | HIGH | ACE-FCA + Passive/Active/Deep 3단계 로딩 |
| trine-context-management.md | trine-context-management | MEDIUM | 200K 윈도우 관리, /compact 트리거 |
| trine-requirements-analysis.md | trine-requirements-analysis | HIGH | Phase 1.5 Q&A, 도메인 완결성 |
| trine-walkthrough.md | trine-walkthrough | MEDIUM | Walkthrough 작성, Check 3.5 입력 |
| trine-progress.md | trine-progress | MEDIUM | PM 문서 자동 갱신, 외부 도구 연동 |
| trine-test-quality.md | trine-test-quality | HIGH | Check 3.5T 6축 검증 |
| trine-performance.md | trine-performance | HIGH | NestJS 백엔드 성능 7룰 |
| trine-module-dependency.md | trine-module-dependency | MEDIUM | 모듈 계층, 순환 의존성 방지 |
| trine-playground.md | trine-playground | LOW | 3개 템플릿 Phase 매핑 |

## 스킬 (skills/)

| 스킬 | 상태 | 설명 |
|------|:----:|------|
| react-best-practices | ✅ 완성 | React/Next.js 성능 57+8룰 전체, 3단계 점진적 로딩 |

## 로딩 전략

| 단계 | 시점 | 토큰 | 내용 |
|:----:|------|:----:|------|
| Passive | 항상 | ~750 | AGENTS.md (CRITICAL/HIGH 원라이너) |
| Active | 스킬 호출 시 | ~1,500 | SKILL.md (인덱스 + 카테고리 요약) |
| Deep | Check 시 | ~200/룰 | 개별 룰 (파일 라우팅 기반 선택 로드) |

## 변경 이력

- **v1.3.0** (2026-03-02): 표준 포맷 전환 (frontmatter), Passive/Active/Deep 로딩, react-best-practices 스킬 65룰 완성, Check 3.6 UI/UX +6카테고리
- **v1.2.0**: 멀티세션, Implicit Entry, Playground 연동
