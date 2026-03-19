---
id: logic-missing-cleanup
title: "useEffect cleanup 미반환 금지"
severity: warning
category: logic
---

# useEffect cleanup 미반환 금지

## 문제
useEffect에서 구독, 타이머, 이벤트 리스너를 등록한 후 cleanup 함수를 반환하지 않으면 컴포넌트 언마운트/리렌더 시 리소스가 해제되지 않는다. 메모리 누수, 중복 실행, 예기치 않은 동작을 유발한다.

## 감지 패턴
- `useEffect` 내에서 `addEventListener`, `subscribe`, `setInterval`, `setTimeout`, WebSocket `open` 등을 호출하면서 cleanup 함수를 반환하지 않는 경우
- `useEffect`가 함수를 반환하지만 등록한 리소스 중 일부를 해제하지 않는 경우

## Bad Example
```typescript
// BAD: 이벤트 리스너 등록 후 cleanup 없음
useEffect(() => {
  window.addEventListener('resize', handleResize);
  // cleanup 함수 미반환 - 언마운트 후에도 이벤트 계속 수신
}, []);

// BAD: setInterval cleanup 없음
useEffect(() => {
  const interval = setInterval(() => {
    fetchLatestData();
  }, 5000);
  // interval이 영원히 실행됨
}, []);

// BAD: WebSocket 연결 후 cleanup 없음
useEffect(() => {
  const ws = new WebSocket('wss://api.example.com/ws');
  ws.onmessage = (event) => {
    setMessages(prev => [...prev, JSON.parse(event.data)]);
  };
  // 연결이 닫히지 않음
}, []);
```

## Good Example
```typescript
// GOOD: 이벤트 리스너 해제
useEffect(() => {
  window.addEventListener('resize', handleResize);
  return () => window.removeEventListener('resize', handleResize);
}, []);

// GOOD: setInterval 정리
useEffect(() => {
  const interval = setInterval(() => {
    fetchLatestData();
  }, 5000);
  return () => clearInterval(interval);
}, []);

// GOOD: WebSocket 연결 정리
useEffect(() => {
  const ws = new WebSocket('wss://api.example.com/ws');
  ws.onmessage = (event) => {
    setMessages(prev => [...prev, JSON.parse(event.data)]);
  };
  return () => ws.close();
}, []);
```

## 검증 방법
1. 프로젝트 내 `useEffect` 호출을 전수 검색한다
2. 콜백 내부에서 리소스 등록 패턴(addEventListener, subscribe, setInterval, setTimeout, WebSocket, IntersectionObserver 등)이 있는지 확인한다
3. 해당 useEffect가 cleanup 함수(return () => ...)를 반환하는지 확인한다
4. 리소스 등록이 있는데 cleanup이 없으면 WARNING으로 판정한다
