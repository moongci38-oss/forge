# Code Quality Rules (Semantic)

> Hook이 잡지 못하는 시맨틱 코드 품질 이슈 10룰. Check 3.7Q에서 로드.

## CRITICAL (자동 FAIL)
- api-error-swallow: catch에서 에러 삼킴 금지 (re-throw 또는 사용자 알림 필수)
- arch-circular-dep: 모듈 간 순환 import 금지
- arch-layer-violation: 레이어 경계 침범 금지 (UI->DB, API->컴포넌트)
- logic-race-condition: 비동기 cleanup 없이 언마운트 시 상태 업데이트 금지

## WARNING (CONDITIONAL)
- api-unnecessary-call: mutation 후 불필요 refetch -> invalidateQueries 사용
- api-state-coupling: 과도한 Context 의존 -> props/composition 우선
- html-mailto-target: mailto에 target="_blank" 불필요
- html-button-in-anchor: a 태그 내 button 중첩 금지
- logic-redundant-mutation: 동일 상태 연속 덮어쓰기 -> 단일 업데이트
- logic-missing-cleanup: useEffect cleanup 필수 (구독, 타이머, 이벤트)
