# Developer Productivity Tools (전역)

> AI 코딩 어시스턴트의 컨텍스트를 풍부하게 만드는 두 도구.
> react-grab + Sentry MCP를 Forge Dev 워크플로우에 공식 통합.

---

## react-grab

**역할**: 브라우저의 React 컴포넌트 → 파일 경로·컴포넌트 트리를 AI에 자동 전달.

### 활용 시점

| 상황 | 행동 |
|------|------|
| UI 변경 요청 (어느 파일인지 불명확) | Glob/Grep 탐색 전 react-grab 먼저 시도 |
| Phase 1에서 3회 이상 파일 탐색 예상되는 UI 작업 | react-grab 컨텍스트 수집 후 진행 |
| 특정 UI 요소의 React 구조 파악 필요 | 우클릭 → "Copy Context" |

### 워크플로우

```
1. `pnpm dev` 실행 (Next.js dev 서버)
2. 브라우저에서 수정할 컴포넌트 우클릭
3. "Copy Context" 선택
4. 복사된 컨텍스트를 Claude Code 대화에 붙여넣기
5. AI가 정확한 파일·컴포넌트 기반으로 수정
```

### AI 에이전트 행동 규칙

- UI 컴포넌트 수정 요청 시 "react-grab으로 컨텍스트를 복사해 붙여넣어 주시면 더 정확하게 수정할 수 있습니다"라고 안내한다
- react-grab 컨텍스트가 제공된 경우 Glob/Grep 파일 탐색을 스킵한다
- dev 환경에서만 동작함 (프로덕션 빌드에 포함 안 됨)

---

## Sentry MCP

**역할**: 프로덕션 에러·이슈를 AI가 Sentry에서 직접 조회·분석.

### 주요 도구 (16개 중 핵심)

| 도구 | 용도 |
|------|------|
| `list_issues` | 프로젝트 이슈 목록 조회 |
| `get_issue` | 이슈 상세 + 스택트레이스 |
| `get_issue_events` | 발생 이벤트 기록 확인 |
| `trigger_seer_analysis` | AI 근본 원인 분석 실행 |
| `get_fix_suggestions` | 수정 추천 조회 |

### Hotfix 플로우 (Sentry MCP 통합)

```
에러 보고 수신
  → Sentry MCP list_issues → 해당 에러 식별
  → get_issue → 스택트레이스 + 발생 컨텍스트 확인
  → trigger_seer_analysis → AI 근본 원인 분석
  → 분석 결과 기반 Hotfix 구현 (Forge Dev Hotfix 플로우 진입)
```

### Standard 플로우 (구현 후 검증)

- Phase 4 PR merge 완료 후 Sentry에서 신규 에러 모니터링
- 새 이슈 감지 → 즉시 Hotfix 브랜치로 대응

### 금지

- Sentry 조회 없이 에러 원인 추측으로 Hotfix 시작
- 스택트레이스 미확인 상태에서 구현 제안

---

## 두 도구 조합 워크플로우

### UI 버그 Hotfix (최적 플로우)

```
1. Sentry MCP → 에러 상세 + 발생 컴포넌트 파악
2. react-grab → 해당 컴포넌트 컨텍스트 수집
3. AI에 Sentry 에러 + react-grab 컨텍스트 동시 제공
4. 정확한 파일·라인 기반 수정 (추측 없음)
```

### 컨텍스트 풍부도 비교

| 방법 | 파일 경로 | 컴포넌트 트리 | 에러 스택 | 발생 빈도 |
|------|:--------:|:------------:|:--------:|:--------:|
| 기존 (Glob/Grep만) | △ | ✗ | ✗ | ✗ |
| react-grab 추가 | ✅ | ✅ | ✗ | ✗ |
| Sentry MCP 추가 | ✗ | ✗ | ✅ | ✅ |
| **두 도구 조합** | ✅ | ✅ | ✅ | ✅ |

---

## AI 에이전트 행동 규칙

1. UI 컴포넌트 수정 요청 시 react-grab 컨텍스트 제공을 권유한다
2. "에러/버그" 관련 Hotfix 요청 시 Sentry MCP로 이슈를 먼저 조회한다
3. Sentry MCP 미연결 상태라면 `/mcp` 명령으로 연결 상태를 확인한다
4. react-grab 컨텍스트 수신 시 별도 Glob/Grep 탐색 없이 바로 수정에 집중한다
5. 구현 완료 후 Sentry에서 신규 에러 발생 여부를 확인하도록 안내한다

---

*Last Updated: 2026-03-11*
*Portfolio 프로젝트 설치: react-grab 0.1.27 + @sentry/nextjs + @sentry/nestjs*
