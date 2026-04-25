# 5-Level Autonomy 작업 매핑

> Forge 파이프라인에서 작업 유형별로 허용되는 자율성 레벨과 Human 감독 지점을 정의한다.
> 5-Level 프레임워크: L1 관찰자 → L5 완전 자율
> 참조: `pipeline.md` §Iron Laws, `forge-core.md` §커맨드 실행 모드

## 레벨 정의

| Level | 이름 | 정의 | Human 개입 |
|:-----:|------|------|------------|
| L1 | Observer | AI는 정보만 제공, 결정/실행은 Human | 모든 결정·실행 |
| L2 | Assistant | AI가 제안, Human이 승인 후 실행 | 모든 실행 지점 |
| L3 | Collaborator | AI가 실행, 주요 결정은 [STOP] 게이트 | 게이트 지점만 |
| L4 | Delegate | AI가 자율 실행, Human은 샘플 검토 | 주기적 샘플링 |
| L5 | Autonomous | AI가 완전 자율, Human은 예외 보고만 수신 | 예외 발생 시 |

## 작업 유형별 매핑

### 개발 작업 (Forge Dev Phase 6~12)

| 작업 | Level | 근거 | Human 개입 |
|------|:----:|------|-----------|
| Spec 작성 (Phase 7) | L2 | 구현 범위 확정은 비가역 | Spec 승인 [STOP] |
| 코드 구현 (Phase 8) | L3 | Spec 기준 구현은 예측 가능 | Check 6~6.8 게이트 |
| 테스트 작성 | L4 | TDD 패턴 일상화 | 샘플 검토 (PR 리뷰) |
| verify.sh/빌드 실행 | L5 | 결과 이진 판정 | 실패 시만 |
| 코드 리뷰 (AI, Check 6.7) | L3 | 최종 결정권은 Human | [STOP] 승인 |
| PR 생성 | L3 | MERGE-IRON-1 적용 | feature→develop 자동, release→main 승인 |
| develop → staging merge | L3 | 환경 전환 | auto-merge=true 시 CI 자동 |
| staging → main merge | L2 | 프로덕션 영향 | Human 승인 필수 (Check 9.5) |
| 프로덕션 배포 | L3 | 자동 배포 + 모니터링 | 배포 실패 시 [STOP] |
| 롤백 (L1 Quick Revert) | L2 | 비가역 아님이나 긴급 | Human 트리거 필수 |
| 롤백 (L2/L3) | L1 | 프로덕션 데이터 영향 | Human 모든 단계 결정 |

### 기획 작업 (Forge S1~S5)

| 작업 | Level | 근거 | Human 개입 |
|------|:----:|------|-----------|
| Phase 1 리서치 | L4 | 정보 수집은 되돌리기 쉬움 | 결과 검토만 (AUTO-PASS) |
| Phase 2 컨셉 5축 | L2 | 비전·전략 직결 | 모든 축 Human 확정 [STOP] |
| Phase 3 기획서 | L3 | 에이전트 회의 후 [STOP] | 승인 [STOP] |
| Phase 4 기획 패키지 Wave 1~3 | L3 | 3종 산출물 자동 생성 | Wave 2B Don't 위반 시만 [STOP] |
| Phase 4 Wave 4 최종본 | L2 | 외부 공유용 | Human 최종 확정 |
| Phase 5 Handoff | L5 | 기계적 파일 이동 | 예외 발생 시만 |

### 정부과제 (Forge GR-1~6)

| 작업 | Level | 근거 | Human 개입 |
|------|:----:|------|-----------|
| GR-1 공고 분석 | L4 | 자격 요건 자동 판정 | 부적격 시만 보고 |
| GR-2 전략·Go/No-Go | L2 | 투자 결정 | Human 최종 결정 [STOP] |
| GR-3 서류 작성 | L3 | 에이전트 팀 작성 후 검수 | 방향성 확정 + 검수 피드백 [STOP] |
| GR-4 제출 패키지 | L2 | 제출 직전 | Human 최종 확인 [STOP] |
| GR-5 제출 | L1 | 외부 시스템 연동 | Human 직접 제출 |
| GR-6 수행 관리 | L3 | 주기적 리포팅 | 분기 체크포인트 |

### 보안·인프라 작업

| 작업 | Level | 근거 |
|------|:----:|------|
| Dependency 설치 (`npm/pip install`) | L3 | ASI-03 typosquatting 차단 후 진행 |
| 파일 삭제 (`rm`, `git clean`) | L2 | 비가역 |
| `git push` (feature 브랜치) | L4 | 되돌리기 가능 (force-push 금지) |
| `git push --force` | L1 | 거의 비가역 | 금지 |
| main 직접 커밋 | L1 | Iron Law로 금지 |
| 민감 파일 접근 (.env, credentials) | L1 | block-sensitive-files.sh 차단 |
| Hook 설정 수정 (`settings.json`) | L2 | 시스템 동작 변경 |
| MCP 서버 추가 | L2 | 외부 연동 |

## 에스컬레이션 규칙

AI가 L3 이상에서 작업 중 다음 상황 발생 시 반드시 Human에게 에스컬레이션:

1. **예상치 못한 상태**: 파일/브랜치/설정이 기대와 다름 → 조사 후 보고
2. **재시도 한도 초과**: Check 체인 2회 auto-fix 실패
3. **Kill 메트릭 초과**: 토큰 예산, 실행 시간 제한 도달
4. **보안 경고**: security.log에 BLOCK/WARN 기록
5. **Iron Law 위반 가능성**: 특히 MERGE-IRON, SECURITY-IRON

## 레벨 상승 조건

작업별 Level은 고정이 아니다. 다음 조건 충족 시 승격 가능:

- **테스트 커버리지 + 실행 통계**: 100회 이상 L3 성공 + 에러율 < 1% → L4 상승
- **Human override rate**: 최근 30일 rubber-stamp rate < 10% → 게이트 간소화 검토
- **프로젝트 성숙도**: Constitution 체계 완비 + Spec 준수율 > 90% → L4 default 허용

## 레벨 강등 조건

- **거부/수정 빈도 증가**: Human override rate > 30% → L2로 강등
- **보안 사고**: 1회 발생 → 관련 작업 L2로 강등 (재감사 후 복원)
- **Iron Law 위반**: 즉시 L1 강등 + post-mortem

## 참조

- `pipeline.md` §Iron Laws, §8-Check 체인
- `forge-core.md` §커맨드 실행 모드, §병렬 실행
- `.claude/hooks/gate-approval-tracker.sh` (Rubber-Stamp 감지)
- `.claude/hooks/track-override-rate.sh` (Override Rate 집계)

---

*Last Updated: 2026-04-12 (system-audit P2-15)*
