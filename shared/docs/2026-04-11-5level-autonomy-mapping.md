# 5-Level Autonomy 매핑 — Forge AI 시스템

> 작성일: 2026-04-11 | 참조: ACHCE Human-AI 축 감사 (#4 HIGH 이슈 해소)
> 출처: CLEAR/TCMM(Trust Calibration & Management Model) 프레임워크 기반

---

## 개요

Forge 시스템에서 AI가 자율적으로 수행할 수 있는 작업의 범위를 명확히 정의한다.
작업 유형별로 L0~L4 중 하나의 자율성 레벨을 할당하여 AI-Human 경계를 명시한다.

**원칙**: 레벨이 높을수록 AI 자율 범위가 넓고, Human 개입이 줄어든다.

---

## 5-Level 정의

| 레벨 | 이름 | 설명 | Human 역할 |
|:----:|------|------|-----------|
| **L0** | Human-Initiated | AI는 정보 제공만. 모든 실행은 Human이 수동으로 | 결정 + 실행 |
| **L1** | AI-Assisted | AI가 초안/계획 제안, Human이 검토 후 실행 승인 | 검토 + 승인 |
| **L2** | Human-Supervised | AI가 실행하되, 각 단계에서 [STOP] 게이트로 승인 | 게이트 승인 |
| **L3** | AI-Delegated | AI가 자율 실행, 완료 후 Human에게 결과 보고 | 결과 검토 |
| **L4** | Fully Autonomous | AI가 완전 자율 실행, 예외 상황만 에스컬레이션 | 예외 처리 |

---

## 작업 유형별 자율성 레벨

### 파일/코드 작업

| 작업 | 레벨 | 근거 |
|------|:----:|------|
| 파일 읽기, 검색 | **L4** | 비가역적 영향 없음 |
| 파일 생성 (새 파일) | **L3** | 가역적, 완료 후 보고 |
| 파일 수정 (기존 파일) | **L3** | git으로 복구 가능 |
| 파일 삭제 | **L1** | 비가역적 위험, 명시 요청 필요 |
| 보안 설정 파일 수정 (.env, .claude.json 등) | **L1** | 민감 영역, 승인 필수 |

### Git 작업

| 작업 | 레벨 | 근거 |
|------|:----:|------|
| git status / diff / log | **L4** | 읽기 전용 |
| git add + commit | **L3** | 로컬 변경, 가역적 |
| git push (develop) | **L3** | feedback_git_auto_push 규칙: allow |
| git push (main) | **L2** | 보호 브랜치, 결과 공유 |
| git force push | **L1** | 이력 파괴 위험, 명시 요청 필수 |
| PR 생성 | **L3** | 공개 가시적이나 삭제 가능 |
| PR merge | **L3** | feedback_pr_auto_merge: CI PASS + 코멘트 0건 조건 충족 시 |

### 외부 서비스 / 인프라

| 작업 | 레벨 | 근거 |
|------|:----:|------|
| 웹 검색 / 문서 읽기 | **L4** | 읽기 전용 |
| Telegram 메시지 전송 | **L3** | 사용자 승인 채널 내 |
| Notion 페이지 생성/수정 | **L3** | 가역적, Human override 우선 |
| 외부 API 호출 (GET) | **L3** | 부작용 없는 조회 |
| 외부 API 호출 (POST/PUT) | **L2** | 외부 시스템 상태 변경 |
| Google Drive 업로드 | **L1** | feedback_no_auto_drive_upload 규칙 |
| 서버 명령 실행 (SSH) | **L1** | 원격 시스템 부작용 |
| 프로세스 종료 / 재시작 | **L2** | 서비스 영향 |

### 파이프라인 / 스킬

| 작업 | 레벨 | 근거 |
|------|:----:|------|
| 리서치 / 분석 | **L4** | 읽기/계산, 부작용 없음 |
| 문서 초안 작성 | **L3** | forge-outputs에 저장 |
| Spec 작성 | **L2** | [STOP] 게이트 필수 (Phase 3→4→5) |
| 코드 구현 (Spec 존재) | **L3** | Spec 기반 자율 구현 |
| 코드 구현 (Spec 없음) | **L2** | 계획 승인 후 실행 |
| 배포 / 릴리즈 | **L1** | 프로덕션 영향, 명시 승인 |
| 정부과제 본문 수정 | **L2** | feedback_grants_write_order 검수 단계 필수 |
| 시스템 감사 실행 | **L4** | 읽기 + 분석만 |

### 민감/금지 영역

| 작업 | 레벨 | 근거 |
|------|:----:|------|
| 06-finance / 07-legal 접근 | **L0** | forge-core.md 읽기 금지 영역 |
| .env 직접 읽기/수정 | **L0** | 보안 규칙 |
| git history 재작성 | **L1** | 비가역적, 명시 요청 + 확인 필수 |
| 크리덴셜 / 시크릿 커밋 | **L0** | 절대 금지 |

---

## 에스컬레이션 트리거 (L3→L2 강제 하향)

아래 조건 발생 시 자율 실행 중단 후 Human 확인:

1. **비가역성**: 삭제, force push, 외부 서비스 영구 변경
2. **범위 초과**: 요청 범위를 넘는 수정 발생 시
3. **불확실성**: 작업 성공 여부 판단 불가 시
4. **보안 경계**: 민감 파일/영역 접근 필요 시
5. **이전 실패**: 동일 작업 2회 이상 실패 시

---

## Forge 시스템 현황 (2026-04-11)

- **pipeline.md 게이트**: 44개 [STOP] (L2 강제 적용) + 7개 [AUTO-PASS] (L3 허용)
- **autoplan 강제 게이트**: Spec 없는 구현 요청 시 L2 자동 적용
- **feedback_autonomous_execution.md**: 명시적 승인/삭제 외 자동 실행 (L3 기본)
- **Override Rate 추적**: 미구현 (P1 작업 대기)

---

## 참조

- `forge/.claude/rules/forge-core.md` §보안
- `forge/pipeline.md` §Iron Laws, §[STOP] 게이트
- `~/.claude/projects/*/memory/feedback_autonomous_execution.md`
- `~/.claude/projects/*/memory/feedback_git_auto_push.md`
- ACHCE 감사 보고서: `forge/docs/reviews/audit/2026-04-11-system-audit.md`
