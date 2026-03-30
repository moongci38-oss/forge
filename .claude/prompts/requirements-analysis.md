# Phase 1.5 실행 가이드

## 개요
기획서/계획서의 요구사항을 인터랙티브 Q&A로 명확화 후, JSON 트레이서빌리티 매트릭스를 생성한다.

## 단계별 실행

### Step 1: 기획서 읽기
지정된 기획서/계획서를 Read 도구로 전체 읽기.

### Step 2: 불명확점 식별
"결과물에 영향을 미치는 불명확점만" 질문 목록 작성.
- 수용 기준 없는 FR
- 상충하는 요구사항
- 측정 기준 없는 NFR

### Step 3: 질문 수 판정
| 0개 | → Step 5 (Q&A 스킵) |
| 1~5개 | → Step 4 (Q&A 진행) |
| 6개+ | → [STOP] 기획서 반려 |

### Step 4: Q&A 실행
질문을 번호 매기고 한 번에 Human에게 제시.
답변을 session-state의 qaHistory에 기록.

### Step 5: 매트릭스 생성

프로젝트별 추출 스크립트 실행 (예: `node scripts/extract-requirements.mjs <doc>`).
- 성공 → `.specify/traceability/{name}-matrix.json` 생성
- 실패 → AI 추출 모드 → [STOP] Human 확인

### Step 6: 체크포인트
```bash
node ~/.claude/scripts/session-state.mjs checkpoint --phase phase1.5_complete
```
