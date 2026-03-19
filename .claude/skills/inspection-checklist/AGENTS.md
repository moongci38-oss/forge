# inspection-checklist

> PR 생성 전 최종 검수 체크리스트. Phase 4 직전 사용.

## CRITICAL (항상 적용)

- **Check 3 통과**: build + test + lint + type-check 모두 PASS여야 한다.
- **Check 3.5 통과**: 모든 High FR 구현 + 테스트 매핑 완료.
- **에러 삼킴 금지**: catch 블록에서 에러를 무시하는 코드 없음 (api-error-swallow).
- **순환 의존성 없음**: 모듈 간 순환 import 없음 (arch-circular-dep).
- **레이어 침범 없음**: 하위→상위 방향 import 없음 (arch-layer-violation).
- **비동기 경합 없음**: cleanup 누락, 경합 조건 없음 (logic-race-condition).

## HIGH (우선 검토)

- **보안**: 입력 검증 (XSS/SQLi 방지), 인증/인가 로직 검증, 민감 데이터 노출 없음.
- **UI 품질** (FE 변경 시): 반응형 확인, 접근성 AA, `prefers-reduced-motion` 대응.
- **Conventional Commits**: 커밋 메시지 형식 준수.
- **Walkthrough 존재**: feat/* 브랜치는 Walkthrough 필수.
