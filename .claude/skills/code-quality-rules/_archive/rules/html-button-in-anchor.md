---
id: html-button-in-anchor
title: "a 태그 내 button 중첩 금지"
severity: warning
category: html
---

# a 태그 내 button 중첩 금지

## 문제
HTML 스펙에서 `<a>` 내부에 `<button>`을 중첩하는 것은 금지되어 있다. 인터랙티브 콘텐츠 내에 인터랙티브 콘텐츠를 중첩하면 브라우저마다 다르게 동작하고, 스크린 리더가 올바르게 해석하지 못한다.

## 감지 패턴
- `<a>` 태그 내부에 `<button>` 태그가 중첩된 경우
- `<Link>` 컴포넌트 내부에 `<button>` 태그가 중첩된 경우
- `<button>` 내부에 `<a>` 태그가 중첩된 경우 (역방향도 동일)

## Bad Example
```tsx
// BAD: a 태그 안에 button 중첩 - HTML 스펙 위반
<a href="/dashboard">
  <button className="btn-primary">
    대시보드로 이동
  </button>
</a>

// BAD: Next.js Link 안에 button 중첩
<Link href="/settings">
  <button>설정</button>
</Link>

// BAD: button 안에 a 중첩 (역방향)
<button onClick={handleClick}>
  <a href="/help">도움말</a>
</button>
```

## Good Example
```tsx
// GOOD: 링크 역할이면 a 태그에 버튼 스타일 적용
<a href="/dashboard" className="btn-primary">
  대시보드로 이동
</a>

// GOOD: Next.js Link에 버튼 스타일 적용
<Link href="/settings" className="btn-secondary">
  설정
</Link>

// GOOD: 클릭 핸들러가 필요하면 button만 사용
<button onClick={() => router.push('/help')} className="btn-link">
  도움말
</button>
```

## 검증 방법
1. JSX/TSX 파일에서 `<a>` 또는 `<Link>` 컴포넌트의 children을 검사한다
2. children에 `<button>` 요소가 포함되어 있는지 확인한다
3. 역방향(button 내 a)도 동일하게 검사한다
4. 발견 시 WARNING으로 판정하고 단일 요소 + 스타일링으로 대체를 권장한다
