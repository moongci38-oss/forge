# Superpowers 플러그인 통합 분석

분석일: 2026-02-28

## 개요

Superpowers 플러그인(knowledge-work-plugins 9개 + claude-plugins-official 10개)의 심층 비교 분석 결과를 기반으로, SIGIL/Trine 파이프라인에 플러그인 스킬을 통합하는 의사결정을 기록한다.

## 비교 분석 매트릭스: 커스텀 vs 플러그인

### Trine 파이프라인 (개발 워크플로우)

| 영역 | 커스텀 자산 | 플러그인 스킬 | 판정 | 근거 |
|------|-----------|-------------|:----:|------|
| TDD | 없음 (Check 3.5T 사후 검증만) | `superpowers:test-driven-development` | **플러그인 우수** | RED→GREEN→REFACTOR 사이클 사전 예방이 사후 검증보다 효과적 |
| 서브에이전트 개발 | Lead 전체 구현 후 Check 3.7 1회 | `superpowers:subagent-driven-development` | **플러그인 우수** | 태스크별 격리 리뷰가 전체 1회 리뷰보다 결함 조기 발견에 우수 |
| 디버깅 | 프로토콜 없음 | `superpowers:systematic-debugging` | **플러그인 유일** | 4단계 디버깅 + 3회 실패 시 아키텍처 재검토 — Trine에 전무한 영역 |
| 완료 검증 | `inspection-checklist` (체크리스트 생성) | `superpowers:verification-before-completion` | **플러그인 보강** | 가정 기반이 아닌 실행 결과 기반 완료 선언 강제 |
| 코드 리뷰 수신 | 프로토콜 없음 | `superpowers:receiving-code-review` | **플러그인 유일** | 감사 금지, YAGNI 체크, 기술적 반박만 허용하는 행동 규칙 |
| 스킬 작성 | 없음 | `superpowers:writing-skills` | **플러그인 유일** | 스킬 TDD 방법론 |
| 코드 리뷰 | code-reviewer 에이전트 (Check 3.7) | `code-review` 플러그인 | **커스텀 우수** | 5-에이전트 병렬 리뷰 체계가 더 정교. 플러그인은 PR 코멘트 자동화 보조 역할 |
| 보안 검증 | `/trine-check-security` (Check 3.8) | `security-guidance` 플러그인 | **상호 보완** | 커스텀은 사후 검증, 플러그인은 사전 예방 — Defense-in-Depth |

### SIGIL 파이프라인 (기획 워크플로우)

| 영역 | 커스텀 자산 | 플러그인 스킬 | 판정 | 근거 |
|------|-----------|-------------|:----:|------|
| 시장 리서치 | research-coordinator + market-researcher | `enterprise-search` | **상호 보완** | 커스텀은 외부 검색, 플러그인은 내부 데이터 통합 |
| 데이터 분석 | 없음 | `data:data-exploration` + `data:statistical-analysis` | **플러그인 유일** | 정량 분석 도구가 커스텀에 없음 |
| PRD 작성 | `/prd` 커맨드 | `product-management:write-spec` | **커스텀 우수** | RICE + 명확도 평가 + SIGIL 통합. 플러그인의 외부 도구 pull만 보강 |
| 이해관계자 커뮤니케이션 | 없음 | `product-management:stakeholder-comms` | **플러그인 유일** | PRD 승인 후 이해관계자 업데이트 생성 |
| 배틀카드 | `/competitor` (심층 분석) | `marketing:competitive-analysis` | **커스텀 우수** | 커스텀이 더 심층적. 배틀카드 생성 기능만 보강 |
| 콘텐츠 작성 | content-planner 에이전트 | `marketing:content-creation` | **커스텀 우수** | 보도자료/케이스스터디 등 미커버 유형만 보강 |
| 로드맵 관리 | `/gtm` + `/pricing` | `product-management:roadmap-management` | **상호 보완** | RICE/ICE 자동 스코어링 보조 |
| 대시보드 | 없음 | `data:interactive-dashboard-builder` | **플러그인 유일** | HTML 대시보드 생성 기능 |

## 플러그인 활성화/비활성화 결정

### 활성화 유지 (기존)

| 플러그인 | 마켓플레이스 | 근거 |
|---------|------------|------|
| productivity | knowledge-work-plugins | 태스크 관리, 메모리 보조 |
| product-management | knowledge-work-plugins | stakeholder-comms, roadmap-management 보강 |
| marketing | knowledge-work-plugins | competitive-analysis 배틀카드, content-creation 보도자료 |
| enterprise-search | knowledge-work-plugins | 크로스 소스 통합 검색 (커스텀에 없음) |
| data | knowledge-work-plugins | SQL, 대시보드, 통계 분석 (커스텀에 없음) |
| sales | knowledge-work-plugins | B2B 영업 워크플로우 (필요 시) |
| customer-support | knowledge-work-plugins | KB 아티클, 티켓 트리아지 |
| playground | claude-plugins-official | Trine Phase 1/1.5/2 연동 완료 |

### 신규 활성화

| 플러그인 | 마켓플레이스 | 근거 |
|---------|------------|------|
| superpowers | claude-plugins-official | 12개 스킬 중 6개가 Trine보다 우수/유일. 명시적 호출만 사용 |
| code-review | claude-plugins-official | Check 5 이후 PR 코멘트 자동화 |
| security-guidance | claude-plugins-official | Check 3.8 예방적 보안 레이어 (Defense-in-Depth) |

### 비활성화

| 플러그인 | 마켓플레이스 | 근거 |
|---------|------------|------|
| cowork-plugin-management | knowledge-work-plugins | Cowork 환경 전용 — CLI 환경에서 불필요 |

### 비즈니스에서 비활성화 유지 (개발 프로젝트 전용)

| 플러그인 | 근거 |
|---------|------|
| frontend-design | Portfolio/GodBlade에서만 사용 |
| context7 | MCP로 이미 가용 |
| playwright | MCP로 이미 가용 |
| github | 개발 워크스페이스 전용 |
| typescript-lsp | 개발 워크스페이스 전용 |

### 미설치 판단

| 플러그인 | 근거 |
|---------|------|
| ralph-loop | Human Gate 철학과 충돌 — 무한 반복 루프가 Trine 3-Cycle 카운터 거버넌스와 양립 불가 |

## Trine 규칙 흡수 인사이트

| 대상 규칙 파일 | 흡수 내용 | 출처 스킬 |
|--------------|----------|----------|
| trine-requirements-analysis.md | Phase 1.5 Q&A "1회 1질문" 선택적 패턴 | brainstorming |
| code-reviewer-base.md | SHA 기반 diff 범위 지정 명시화 | requesting-code-review |
| agent-teams.md | 에이전트 프롬프트 설계 4원칙 (Focused/Self-contained/Specific scope/Specific output) | dispatching-parallel-agents |
| trine-pipeline.md Phase 4 | 완료 경로 4선택지 (PR/로컬 merge/유지/폐기) | finishing-a-development-branch |

## 통합 원칙

1. **플러그인 전체 활성화** — 명시적 호출만 사용, 자동 호출 없음
2. **더 나은 쪽 선택** — 커스텀과 플러그인 중복 시 품질 우수한 쪽을 파이프라인에서 호출
3. **커스텀 없는 영역 보강** — 플러그인에만 있는 기능을 파이프라인에 참조 추가
4. **파이프라인 프롬프트 수정** — 실제 호출할 플러그인 스킬을 명시적 참조로 추가

## 변경된 파일 목록

| # | 파일 | 변경 유형 |
|:-:|------|----------|
| 1 | `business/.claude/rules/sigil-pipeline.md` | S1~S4 플러그인 보강 참조 추가 |
| 2 | `~/.claude/trine/prompts/trine-pipeline.md` | superpowers 4스킬 + security-guidance + code-review + receiving-code-review |
| 3 | `business/.claude/commands/prd.md` | 외부 도구 pull 선택적 단계 |
| 4 | `business/.claude/commands/campaign.md` | 리스크 섹션 추가 |
| 5 | `business/.claude/commands/seo-audit.md` | 기술 SEO + 콘텐츠 갭 분석 섹션 |
| 6 | `business/.claude/commands/metrics-report.md` | Amplitude 연동 선택적 단계 |
| 7 | `business/.claude/commands/blog-post.md` | SEO 점수 검증 단계 |
| 8 | `business/.claude/settings.json` | superpowers/code-review/security-guidance 추가, cowork-plugin-management 제거 |
| 9 | `~/.claude/rules/trine-requirements-analysis.md` | "1회 1질문" 선택적 패턴 |
| 10 | `~/.claude/agents/code-reviewer-base.md` | SHA 기반 diff 범위 지정 |
| 11 | `business/.claude/rules/agent-teams.md` | 프롬프트 설계 4원칙 |
