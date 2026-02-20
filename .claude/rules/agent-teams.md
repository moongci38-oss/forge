# Agent Teams 규칙

> Opus 4.6+ 실험적 기능. `settings.json`의 `env`에 활성화됨.
> 상세 가이드: `docs/tech/Opus_4_6_신기능_심층_가이드_추가_섹션.md`

---

## 핵심 원칙

병렬 처리가 가능한 작업은 Agent Teams 사용을 우선 검토한다.

실행 계획 수립 시 가장 먼저 아래를 판단한다:
1. 이 작업을 독립적인 서브태스크 2개 이상으로 나눌 수 있는가?
2. 그렇다면 → Agent Teams 설계
3. 그렇지 않다면 → 단일 순차 실행

---

## 활성화 요건

- **환경변수**: `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` (settings.json env에 설정됨)
- **터미널**: tmux 필수 — VS Code 통합 터미널 미지원
  ```bash
  # WSL Ubuntu-22.04 (tmux 3.2a 설치됨)
  wsl -d Ubuntu-22.04
  tmux new-session -s agent-team
  claude  # 환경변수 자동 적용
  ```

---

## Task 도구 vs Agent Teams

| 상황 | 선택 |
|------|------|
| 독립 서브태스크 2개 이상 | **Agent Teams** (우선 검토) |
| 단일 순차 작업 | Task 도구 또는 직접 실행 |
| 프로덕션 크리티컬 (롤백 필요) | Agent Teams + Watchdog 패턴 |

---

## 4대 오케스트레이션 패턴

| 패턴 | 사용 시점 | 예시 |
|------|----------|------|
| **Fan-out/Fan-in** | 독립적 병렬 작업 | 멀티 프로젝트 분석, 다국어 처리 |
| **Pipeline** | 순차 의존성 | 리서치→기획→마케팅→콘텐츠 |
| **Competing Hypotheses** | 최적 해법 탐색 | 전략 A/B/C 비교, 성능 최적화 |
| **Watchdog** | 안전성 중요 변경 | 대규모 배포, 운영 변경 |

---

## 파일 소유권 규칙 (동시 편집 충돌 방지)

태스크 시작 전 영역 분리를 반드시 선언한다:

```
## Agent Teams 파일 소유권 (태스크별 선언)
- Teammate A: 01-research/** (리서치 담당)
- Teammate B: 02-product/**  (기획 담당)
- 공유 파일 (CLAUDE.md, settings.*): Lead만 수정
- 동시 수정 금지: .env, settings.json, .gitignore
```

---

## 모델 계층화 (비용 60-70% 절감)

```
Lead (오케스트레이터)    → Opus 4.6   — 계획·판단·종합
구현/작성 Teammate      → Sonnet 4.6 — 문서 작성, 분석
탐색/검색 Teammate      → Haiku 4.5  — 검색, 파일 읽기
```

---

## 주요 제약사항

| 제약 | 워크어라운드 |
|------|------------|
| 세션 재개 불가 | Git commit으로 중간 상태 영속화 |
| VS Code 터미널 미지원 | Windows Terminal + WSL tmux |
| 팀 중첩 불가 | SDK 외부 오케스트레이션 |
| 동일 파일 동시 편집 충돌 | 파일 소유권 규칙 필수 선언 |
