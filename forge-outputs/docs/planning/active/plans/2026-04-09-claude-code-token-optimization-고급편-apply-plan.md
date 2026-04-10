# 적용 계획서: Claude Code 고급 토큰 절약 기법
> 영상 출처: 캐슬 AI — 클로드 코드 토큰 절약 3부 고급편 (https://youtu.be/EAysy2jly18)
> 작성일: 2026-04-09 | 적용 대상: Forge 시스템

---

## 변경 이유

Claude Code 운영 비용 중 불필요한 토큰 소모 패턴 3가지가 미해결 상태:
1. 백그라운드 모델 호출 (환경변수로 즉시 차단 가능)
2. 세션 내 동일 파일 반복 읽기 (read-once 훅으로 해결)
3. 빌드/테스트 로그 전체 컨텍스트 유입 (전처리 훅으로 해결)

이 계획은 3가지 갭을 순서대로 해결한다.

---

## P0 — 즉시 적용 (오늘, 30분)

### 작업 1: 환경변수 추가
- **대상 파일**: `/home/damools/forge/.claude/settings.json`
- **변경 내용**: `env` 섹션에 `DISABLE_NON_ESSENTIAL_MODEL_CALLS: "1"` 추가
- **검증 기준**: settings.json env 섹션에 키 존재 확인
- **영향 범위**: Forge 세션 전체, 핵심 워크플로우 영향 없음

### 작업 2: 프롬프트 캐싱 상태 명시적 기록
- **대상**: settings.json env 섹션에 `DISABLE_PROMPT_CACHING: "0"` 명시 (기본값과 동일하지만 의도 명시)
- **목적**: 실수로 캐싱이 꺼지는 것을 방지. 현재 기본값 의존 상태를 명시적으로 전환

---

## P1 — 이번 주 (2~4시간)

### 작업 3: 로그 전처리 훅 자체 구현
- **대상 파일**: `/home/damools/forge/.claude/hooks/filter-log-output.sh` (신규)
- **목적**: Bash 도구 실행 결과 중 FAILED/ERROR 포함 줄만 Claude에게 전달
- **의존성**: bash, grep (외부 의존 없음)
- **settings.json 연동**: PostToolUse Bash 훅에 등록 (기존 agent-token-budget.sh와 함께)
- **검증 기준**: 테스트 실행 후 실패 항목만 출력에 포함되는지 확인
- **영향 범위**: Forge 프로젝트 빌드/테스트 실행 시

### 작업 4: read-once 훅 검토 및 도입 결정
- **검토 대상**: https://github.com/Bande-a-Bonnot/Boucle-framework/tree/main/tools/read-once
- **검토 항목**: 스크립트 내용 보안 검토, 외부 의존성 확인, TTL 설정값 검토
- **선택지 A**: 검토 통과 시 설치 후 settings.json PreToolUse 등록
- **선택지 B**: 보안 우려 시 동일 로직 자체 구현 (bash+jq)
- **검증 기준**: 세션에서 동일 파일 2회 읽기 시도 시 차단 메시지 확인
- **영향 범위**: 모든 Read 도구 호출

---

## P2 — 이번 달 (검토 후 결정)

### 작업 5: QMD 도입 검토
- **조건**: GodBlade Unity 코드베이스(.cs 파일 다수) 탐색 비용이 높다고 판단될 때
- **검토 방법**: QMD GitHub 설치 후 GodBlade 프로젝트에서 파일 탐색 토큰 before/after 비교
- **CLAUDE.md 변경**: "파일 읽기 전 항상 QMD로 먼저 검색하라" 1줄 추가 (GodBlade 전용)

### 작업 6: nano-banana MCP 도구 설명 축약
- **대상**: nano-banana MCP 서버의 도구 정의 description 필드
- **조건**: nano-banana가 직접 접근 가능한 MCP인 경우
- **영향 범위**: 모든 세션의 컨텍스트 토큰

---

## 제외 항목

| 항목 | 제외 이유 |
|------|---------|
| 역할별 에이전트 MCP 분리 | 운영 복잡도 높음 + 현재 blocking 없음. 스킬 구조로 이미 부분 대응 |
| brave-search/notion MCP 도구 설명 축약 | 외부 관리 MCP. 포크 부담 대비 효과 불명확 |
| CCUSAGE 설치 | 사용량 추적은 usage-logger.sh로 이미 처리 중 |

---

## 완료 기준

- [ ] P0-1: settings.json env에 DISABLE_NON_ESSENTIAL_MODEL_CALLS=1 추가됨
- [ ] P0-2: DISABLE_PROMPT_CACHING=0 명시됨
- [ ] P1-1: filter-log-output.sh 구현 + settings.json 등록 + 테스트 통과
- [ ] P1-2: read-once 훅 검토 완료 + 설치 또는 자체 구현 결정

---

## 참고 링크
- 분석 리포트: `forge-outputs/01-research/videos/analyses/2026-04-09-EAysy2jly18-...-analysis.md`
- 비교 분석: `forge-outputs/docs/reviews/2026-04-09-claude-code-token-optimization-고급편-comparison.md`
- read-once GitHub: https://github.com/Bande-a-Bonnot/Boucle-framework/tree/main/tools/read-once
- MCP 토큰 오버헤드: https://www.mindstudio.ai/blog/claude-code-mcp-server-token-overhead
