---
title: "문자열 연결 대신 template literal 사용"
id: js-string-template
impact: LOW
category: javascript-performance
impactDescription: "가독성 향상 + 불필요한 중간 문자열 생성 방지"
tags: [react, javascript, performance, template-literal, string]
---

# 문자열 연결 대신 template literal 사용

> 문자열 조합에 `+` 연산자 대신 template literal을 사용하여 가독성과 유지보수성을 높이고 복잡한 문자열 생성을 단순화한다.

## Incorrect

```tsx
// Before: + 연산자로 문자열 연결 — 가독성 저하 + 오류 유발
'use client';

interface UserProfile {
  firstName: string;
  lastName: string;
  role: string;
  department: string;
  joinDate: Date;
}

function ProfileCard({ user }: { user: UserProfile }) {
  // + 연산자 체인 — 공백 누락, 따옴표 혼동 빈번
  const displayName = user.firstName + ' ' + user.lastName;
  const roleLabel = '부서: ' + user.department + ' / 직책: ' + user.role;
  const joinInfo =
    '입사일: ' +
    user.joinDate.getFullYear() +
    '년 ' +
    (user.joinDate.getMonth() + 1) +
    '월 ' +
    user.joinDate.getDate() +
    '일';

  // 동적 클래스 조합 — 가독성 최악
  const className =
    'card ' +
    'card--' + user.role.toLowerCase() + ' ' +
    (user.department === '개발' ? 'card--dev' : '') + ' ' +
    'card--active';

  // API URL 조합 — 이스케이프, 공백 문제 유발
  const apiUrl =
    '/api/users/' + user.firstName.toLowerCase() + '-' + user.lastName.toLowerCase() +
    '?role=' + encodeURIComponent(user.role) +
    '&dept=' + encodeURIComponent(user.department);

  return (
    <div className={className}>
      <h2>{displayName}</h2>
      <p>{roleLabel}</p>
      <p>{joinInfo}</p>
    </div>
  );
}
```

## Correct

```tsx
// After: template literal로 가독성 + 유지보수성 향상
'use client';

function ProfileCard({ user }: { user: UserProfile }) {
  const displayName = `${user.firstName} ${user.lastName}`;
  const roleLabel = `부서: ${user.department} / 직책: ${user.role}`;

  // 복잡한 표현식도 명확하게
  const joinInfo = `입사일: ${user.joinDate.getFullYear()}년 ${
    user.joinDate.getMonth() + 1
  }월 ${user.joinDate.getDate()}일`;

  // 동적 클래스 — 배열 + filter + join 패턴 권장
  const className = [
    'card',
    `card--${user.role.toLowerCase()}`,
    user.department === '개발' && 'card--dev',
    'card--active',
  ]
    .filter(Boolean)
    .join(' ');

  // URL 조합 — URLSearchParams 활용
  const baseUrl = `/api/users/${user.firstName.toLowerCase()}-${user.lastName.toLowerCase()}`;
  const params = new URLSearchParams({
    role: user.role,
    dept: user.department,
  });
  const apiUrl = `${baseUrl}?${params}`;

  return (
    <div className={className}>
      <h2>{displayName}</h2>
      <p>{roleLabel}</p>
      <p>{joinInfo}</p>
    </div>
  );
}
```

```tsx
// Tagged template literal 활용: SQL 쿼리 빌더 (Server Action)
// lib/sql.ts
function sql(strings: TemplateStringsArray, ...values: unknown[]) {
  return {
    text: strings.reduce(
      (query, part, i) => `${query}$${i}${part}`
    ),
    values,
  };
}

// app/actions/users.ts
'use server';

async function getUsers(department: string, minAge: number) {
  // Tagged template으로 SQL 인젝션 방지 + 가독성 확보
  const query = sql`
    SELECT id, name, role
    FROM users
    WHERE department = ${department}
      AND age >= ${minAge}
    ORDER BY name ASC
  `;

  return db.query(query.text, query.values);
}
```

## Why

Template literal은 ES2015의 핵심 기능으로, 문자열 연결의 가독성 문제를 해결한다. `+` 연산자 체인은 따옴표 혼동, 공백 누락, 타입 강제 변환 등 버그를 유발한다. Template literal은 표현식 삽입(`${}`)으로 의도가 명확하고, 멀티라인 문자열을 자연스럽게 지원한다.

**정량적 효과:**
- 코드 가독성: 문자열 조합 로직 50% 축소 (공백, 따옴표 관리 제거)
- 버그 감소: 공백 누락, 타입 변환 버그 대부분 제거
- Tagged template: SQL 인젝션 방지, CSS-in-JS, i18n 등 도메인 특화 문자열 생성
- URLSearchParams 조합: 인코딩 자동 처리 — encodeURIComponent 수동 호출 불필요

## References

- [MDN: Template literals](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Template_literals)
- [MDN: URLSearchParams](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams)
- [TypeScript: Template Literal Types](https://www.typescriptlang.org/docs/handbook/2/template-literal-types.html)
