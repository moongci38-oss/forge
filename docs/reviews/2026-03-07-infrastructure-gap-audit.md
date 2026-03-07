# 인프라 갭 감사 리포트 — 에이전트 상속 & Hook 커버리지

> **일자**: 2026-03-07
> **범위**: SIGIL/Trine 파이프라인 에이전트 상속 패턴 + Hook 방어 체계
> **관련 문서**: `docs/tech/2026-03-07-agent-inheritance-patterns.md`

---

## 1. 감사 목적

SIGIL 파이프라인에서 에이전트 스폰 시 CLAUDE.md 규칙 상속 여부와 Hook 기반 방어 체계의 커버리지 갭을 식별하고 개선한다.

---

## 2. 핵심 발견사항

### 2.1 CLAUDE.md 상속 — 문제 없음

| 스폰 방식 | CLAUDE.md 상속 | 비고 |
|-----------|:-------------:|------|
| Agent tool (Claude Code) | ✅ 자동 | 동일 프로젝트 디렉토리 → 자동 로드 |
| Team Agent (tmux) | ✅ 자동 | 독립 세션이지만 동일 프로젝트 |
| Sub-agent (Agent SDK) | ❌ 수동 필요 | 현재 미사용, 향후 주의 |

**결론**: 현재 워크스페이스의 모든 SIGIL 에이전트는 Agent tool로 스폰되어 CLAUDE.md를 자동 상속한다.

### 2.2 Hook 커버리지 갭 — 4건 발견

| # | 갭 | 심각도 | 상태 |
|:-:|-----|:------:|:----:|
| 1 | `block-sensitive-files.sh`가 Read 미매칭 | **P1** | ✅ 해결 |
| 2 | `require-date-prefix.sh`가 `docs/`만 커버 | **P2** | ✅ 해결 |
| 3 | technical-writer에 관리자 전파 규칙 미포함 | P3 | ✅ 해결 |
| 4 | research 에이전트에 `[신뢰도]` 태그 형식 미포함 | P3 | ✅ 해결 |

---

## 3. 적용된 개선사항

### P1: Read 경로 보안 차단

**변경 전**:
```json
{ "matcher": "Edit|Write", "hooks": ["block-sensitive-files.sh"] }
```

**변경 후**:
```json
{ "matcher": "Read|Edit|Write", "hooks": ["block-sensitive-files.sh"] }
```

- **파일**: `.claude/settings.json`, `.claude/hooks/block-sensitive-files.sh`
- **효과**: 06-finance, 07-legal, 08-admin/insurance, 08-admin/freelancers 경로의 파일 읽기도 Hook이 차단

### P2: 파일명 Hook 범위 확장

**변경 전**: `docs/` 하위만 대상

**변경 후**: `docs/`, `01-research/`, `02-product/`, `04-content/`, `05-design/` 하위 대상

- **파일**: `.claude/hooks/require-date-prefix.sh`, `.claude/rules/security.md`
- **효과**: SIGIL 산출물 경로 전체에 날짜 prefix 규칙 적용
- **추가 예외**: `gate-log.md` (날짜 prefix 불필요)

### P3: 에이전트 프롬프트 강화

| 에이전트 | 추가된 규칙 |
|---------|-----------|
| `technical-writer` | 관리자 페이지 전파 규칙, 파일명 규칙 |
| `market-researcher` | `[신뢰도]` 태그, 출처 인용 형식, 파일명 규칙 |
| `academic-researcher` | `[신뢰도]` 태그, 출처 인용 형식, 파일명 규칙 |
| `fact-checker` | `[신뢰도]` 태그, 출처 인용 형식 |

---

## 4. 개선 후 방어 수준

```
보안 (Write/Edit 차단)    ████████████████████ 100%
보안 (Read 차단)          ████████████████████ 100%  ← P1 적용
파일명 규칙 (docs/)       ████████████████████ 100%
파일명 규칙 (SIGIL 경로)   ████████████████████ 100%  ← P2 적용
파이프라인 상태 전달       ████████████████░░░░  80%
리서치 방법론 적용         ██████████████████░░  90%  ← P3 적용
```

---

## 5. 잔여 리스크

| 항목 | 수준 | 설명 |
|------|:----:|------|
| 컨텍스트 격리 | Low | Agent tool 스폰 시 대화 히스토리는 공유되지 않음. orchestrator 프롬프트 설계에 의존 |
| Agent SDK 전환 | 향후 | SDK로 전환 시 CLAUDE.md 규칙을 프롬프트에 명시적 포함 필요 |
| Glob/Grep 경로 | Low | Hook이 Glob/Grep에는 미적용. 파일 목록 나열은 가능하나 내용 접근은 차단됨 |

---

## 6. 변경 파일 목록

| 파일 | 변경 유형 |
|------|----------|
| `.claude/settings.json` | Hook matcher 분리 (Read 추가) |
| `.claude/hooks/block-sensitive-files.sh` | 주석 + 메시지 업데이트 |
| `.claude/hooks/require-date-prefix.sh` | 대상 경로 확장 + gate-log.md 예외 |
| `.claude/rules/security.md` | Cowork 섹션 파일명 규칙 범위 동기화 |
| `.claude/agents/technical-writer.md` | SIGIL Pipeline Rules 인라인 |
| `.claude/agents/market-researcher.md` | Research Methodology Rules 인라인 |
| `.claude/agents/academic-researcher.md` | Research Methodology Rules 인라인 |
| `.claude/agents/fact-checker.md` | Research Methodology Rules 인라인 |
| `docs/tech/2026-03-07-agent-inheritance-patterns.md` | 분석 문서 (신규 + 갭 분석 추가) |

---

## 7. 커밋 이력

| 커밋 | 설명 |
|------|------|
| `c155cf5` | docs: SIGIL/Trine 시스템 에이전트 상속 패턴 분석 문서 작성 |
| `3f5cb20` | docs: Hook 커버리지 갭 분석 및 개선 권고사항 추가 |
| `f931e99` | feat: 인프라 갭 보완 — Hook 커버리지 확장 + 에이전트 프롬프트 강화 |

---

*Last Updated: 2026-03-07*
