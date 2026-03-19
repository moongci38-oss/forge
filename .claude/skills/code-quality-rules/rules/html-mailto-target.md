---
id: html-mailto-target
title: "mailto에 target='_blank' 불필요"
severity: warning
category: html
---

# mailto에 target="_blank" 불필요

## 문제
`<a href="mailto:...">` 에 `target="_blank"`를 사용하면 일부 브라우저에서 빈 탭이 생성된 후 메일 클라이언트가 열린다. mailto 링크는 OS가 메일 앱으로 라우팅하므로 target 속성이 불필요하다.

## 감지 패턴
- `<a>` 태그에 `href="mailto:"` + `target="_blank"` 동시 사용
- `<Link>` 컴포넌트에 `href="mailto:"` + `target="_blank"` 동시 사용
- `tel:` 프로토콜에도 동일한 패턴 적용

## Bad Example
```tsx
// BAD: mailto에 target="_blank" - 빈 탭 생성 후 메일 앱 열림
<a href="mailto:contact@example.com" target="_blank">
  문의하기
</a>

// BAD: tel에도 동일한 문제
<a href="tel:+821012345678" target="_blank">
  전화하기
</a>
```

## Good Example
```tsx
// GOOD: mailto는 target 없이 사용
<a href="mailto:contact@example.com">
  문의하기
</a>

// GOOD: tel도 target 없이 사용
<a href="tel:+821012345678">
  전화하기
</a>

// GOOD: 외부 URL은 target="_blank" + rel="noopener noreferrer" 사용
<a href="https://example.com" target="_blank" rel="noopener noreferrer">
  외부 링크
</a>
```

## 검증 방법
1. 프로젝트 내 `mailto:` 또는 `tel:` href를 포함하는 `<a>` 태그를 검색한다
2. 해당 태그에 `target="_blank"` 속성이 있는지 확인한다
3. 있으면 WARNING으로 판정하고 target 속성 제거를 권장한다
