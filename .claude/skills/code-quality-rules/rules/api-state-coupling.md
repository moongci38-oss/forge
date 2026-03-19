---
id: api-state-coupling
title: "과도한 Context/전역 상태 의존 금지"
severity: warning
category: api
---

# 과도한 Context/전역 상태 의존 금지

## 문제
Props 대신 Context로 모든 데이터를 전달하면 컴포넌트 재사용성이 떨어지고, Context 값 변경 시 모든 소비자가 리렌더된다. 테스트 시 Provider 래핑이 필수가 되어 테스트 복잡도도 증가한다.

## 감지 패턴
- 하나의 컴포넌트에서 3개 이상의 `useContext` 호출
- leaf 컴포넌트(children 없는 UI 컴포넌트)에서 전역 상태 직접 접근
- props가 0~1개인 컴포넌트가 Context에서 4개 이상의 값을 추출

## Bad Example
```typescript
// BAD: leaf 컴포넌트가 여러 Context에 직접 의존
function UserAvatar() {
  const { user } = useContext(AuthContext);
  const { theme } = useContext(ThemeContext);
  const { locale } = useContext(I18nContext);
  const { isOnline } = useContext(NetworkContext);

  return (
    <img
      src={user.avatar}
      className={theme === 'dark' ? 'avatar-dark' : 'avatar-light'}
      alt={locale === 'ko' ? '프로필' : 'Profile'}
      style={{ opacity: isOnline ? 1 : 0.5 }}
    />
  );
}
```

## Good Example
```typescript
// GOOD: props로 필요한 데이터만 받음 - 재사용 가능, 테스트 용이
interface UserAvatarProps {
  src: string;
  alt: string;
  isOnline?: boolean;
  className?: string;
}

function UserAvatar({ src, alt, isOnline = true, className }: UserAvatarProps) {
  return (
    <img
      src={src}
      className={className}
      alt={alt}
      style={{ opacity: isOnline ? 1 : 0.5 }}
    />
  );
}

// Context 소비는 컨테이너/페이지 레벨에서
function UserAvatarContainer() {
  const { user } = useAuth();
  const { isOnline } = useNetwork();

  return <UserAvatar src={user.avatar} alt="프로필" isOnline={isOnline} />;
}
```

## 검증 방법
1. leaf 컴포넌트(children prop 미사용, JSX만 반환)를 식별한다
2. 해당 컴포넌트 내 `useContext`, `useStore`, 전역 상태 hook 호출 수를 센다
3. 3개 이상이면 WARNING으로 판정하고 container/presentational 분리를 권장한다
4. props로 전달 가능한 값을 Context에서 가져오는 경우를 식별한다
