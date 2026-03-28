---
skill: code-quality-rules
version: 2
test-method: indirect-via-prompt
---

# Assessment: code-quality-rules

> 레퍼런스 스킬이므로 `/code-quality-rules` 직접 호출 불가.
> "code-quality-rules 기준으로 리뷰해줘" 프롬프트로 간접 검증한다.

## 테스트 입력

- input_1: "code-quality-rules 스킬의 10개 룰 기준으로 이 코드를 리뷰해줘:\n```tsx\nimport { useEffect, useState } from 'react';\nexport function UserProfile({ id }: { id: string }) {\n  const [user, setUser] = useState(null);\n  useEffect(() => {\n    fetch(`/api/users/${id}`).then(res => res.json()).then(data => setUser(data));\n  }, [id]);\n  return <div onClick={() => window.location.href='/home'}>{user?.name}</div>;\n}\n```"
- input_2: "code-quality-rules 스킬의 10개 룰 기준으로 이 코드를 리뷰해줘:\n```ts\nasync function updateUser(req: Request) {\n  try {\n    const result = await db.users.update(req.body);\n    await fetch('/api/audit-log', { method: 'POST', body: JSON.stringify(result) });\n    return result;\n  } catch (e) {\n    console.log(e);\n    return null;\n  }\n}\n```"
- input_3: "code-quality-rules 스킬의 10개 룰 기준으로 이 코드를 리뷰해줘:\n```tsx\nimport { useContext } from 'react';\nimport { AuthContext } from './auth';\nimport { ThemeContext } from './theme';\nimport { CartContext } from './cart';\nimport { NotificationContext } from './notifications';\nexport function Header() {\n  const auth = useContext(AuthContext);\n  const theme = useContext(ThemeContext);\n  const cart = useContext(CartContext);\n  const notif = useContext(NotificationContext);\n  return <a><button onClick={() => auth.logout()}>Logout</button></a>;\n}\n```"

## 평가 기준 (Yes/No)

1. 이슈 감지: 출력에 최소 1개 이상의 코드 품질 이슈가 구체적으로 지적되어 있는가?
2. 룰 이름 또는 카테고리 언급: 이슈 설명에 룰 이름(예: error-swallow, race-condition, cleanup) 또는 카테고리(security, logic, ux, architecture, api, html)가 명시되어 있는가?
3. 심각도 구분: critical/warning 또는 이에 준하는 우선순위/심각도 구분이 있는가?
4. 수정 제안: 감지된 이슈에 대해 구체적인 수정 방향(예: AbortController 추가, button 태그로 변경, re-throw)이 제시되어 있는가?
5. 구조화 출력: 결과가 JSON, 테이블, 또는 번호/불릿 리스트로 구조화되어 정리되어 있는가?

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상
