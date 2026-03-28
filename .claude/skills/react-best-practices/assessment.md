---
skill: react-best-practices
version: 1
---

# Assessment: react-best-practices

## 테스트 입력

- input_1: "Review: useEffect(() => { fetch('/api/data').then(setData) }, []) in a Server Component"
- input_2: "Review: const items = data.filter(x => x.active).map(x => <Item key={x.id} {...x} />) inside render without memo"
- input_3: "Review: import moment from 'moment' in a Next.js page component"

## 평가 기준 (Yes/No)

1. 이슈 식별: 출력이 코드 조각의 구체적인 성능 문제를 정확히 식별하는가? (예: input_1 → useEffect/fetch는 Server Component에서 사용 불가, input_2 → 매 렌더마다 재계산, input_3 → moment 번들 크기 문제)
2. 룰 참조: 출력이 관련 룰 ID(예: `async-defer-await`, `bundle-dynamic-import`) 또는 카테고리명(예: Eliminating Waterfalls, Bundle Size Optimization)을 1개 이상 명시하는가?
3. 수정 코드 제시: 출력이 문제를 해결하는 구체적인 수정 코드 예제(Before/After 또는 corrected snippet)를 포함하는가?
4. 성능 영향 설명: 출력이 해당 문제가 성능에 미치는 영향을 설명하는가? (예: 번들 크기 증가, 불필요한 리렌더, 워터폴 발생 등)
5. React/Next.js 개념 언급: 출력이 관련 개념(RSC, Server Component, bundle size, memoization, tree-shaking, useMemo/useCallback, App Router 등)을 1개 이상 언급하는가?

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상 달성
