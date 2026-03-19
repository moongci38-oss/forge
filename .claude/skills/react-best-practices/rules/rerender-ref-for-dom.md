---
title: "DOM 접근은 ref 사용 — state로 DOM 제어 금지"
id: rerender-ref-for-dom
impact: MEDIUM
category: rerender-optimization
impactDescription: "DOM 접근을 위한 불필요한 리렌더 제거 — focus, scroll 등 즉시 실행"
tags: [react, nextjs, performance, rerender, useRef, dom]
---

# DOM 접근은 ref 사용 — state로 DOM 제어 금지

> focus, scroll, 측정(getBoundingClientRect) 등 DOM API를 사용해야 할 때, state로 관리하면 불필요한 리렌더가 발생한다. useRef로 직접 DOM에 접근하면 리렌더 없이 즉시 실행된다.

## Incorrect

```tsx
// Before: state로 DOM 제어 — 불필요한 리렌더 발생
function SearchForm() {
  const [inputValue, setInputValue] = useState('');
  const [shouldFocus, setShouldFocus] = useState(false);

  // shouldFocus 상태 변경 → 리렌더 → useEffect 실행 → focus
  // 리렌더가 중간에 끼어들어 불필요한 비용 발생
  useEffect(() => {
    if (shouldFocus) {
      const input = document.querySelector<HTMLInputElement>('#search-input');
      input?.focus();
      setShouldFocus(false); // 또 리렌더 발생
    }
  }, [shouldFocus]);

  const handleButtonClick = () => {
    setShouldFocus(true); // 렌더 1: shouldFocus=true
    // useEffect → focus → setShouldFocus(false) → 렌더 2: shouldFocus=false
    // 총 2회 불필요한 리렌더
  };

  return (
    <div>
      <input
        id="search-input"
        value={inputValue}
        onChange={(e) => setInputValue(e.target.value)}
      />
      <button onClick={handleButtonClick}>검색창 포커스</button>
    </div>
  );
}
```

```tsx
// Before: 스크롤 위치를 state로 추적 — 스크롤할 때마다 리렌더
function VideoPlayer() {
  const [videoElement, setVideoElement] = useState<HTMLVideoElement | null>(null);
  const [currentTime, setCurrentTime] = useState(0);
  const [duration, setDuration] = useState(0);

  useEffect(() => {
    if (!videoElement) return;
    const handleTimeUpdate = () => setCurrentTime(videoElement.currentTime);
    const handleLoaded = () => setDuration(videoElement.duration);
    videoElement.addEventListener('timeupdate', handleTimeUpdate);
    videoElement.addEventListener('loadedmetadata', handleLoaded);
    return () => {
      videoElement.removeEventListener('timeupdate', handleTimeUpdate);
      videoElement.removeEventListener('loadedmetadata', handleLoaded);
    };
  }, [videoElement]);

  // 비디오 재생 중 초당 ~4회 리렌더 (timeupdate 이벤트)
  return (
    <div>
      <video ref={setVideoElement} src="/video.mp4" />
      <ProgressBar current={currentTime} total={duration} />
      <HeavyCommentSection />  {/* 매번 같이 리렌더됨 */}
    </div>
  );
}
```

## Correct

```tsx
// After: useRef로 직접 DOM 접근 — 리렌더 없이 즉시 실행
function SearchForm() {
  const [inputValue, setInputValue] = useState('');
  const inputRef = useRef<HTMLInputElement>(null);

  const handleButtonClick = () => {
    // ref를 통해 직접 DOM 접근 — 리렌더 없이 즉시 focus
    inputRef.current?.focus();
  };

  return (
    <div>
      <input
        ref={inputRef}
        value={inputValue}
        onChange={(e) => setInputValue(e.target.value)}
      />
      <button onClick={handleButtonClick}>검색창 포커스</button>
    </div>
  );
}
```

```tsx
// After: 빈번한 DOM 값은 ref로 추적, 표시할 때만 state 업데이트
function VideoPlayer() {
  const videoRef = useRef<HTMLVideoElement>(null);
  const progressRef = useRef<HTMLDivElement>(null);
  const animationFrameRef = useRef<number>(0);

  useEffect(() => {
    const video = videoRef.current;
    if (!video) return;

    // requestAnimationFrame으로 프로그레스바 직접 업데이트 — 리렌더 제로
    const updateProgress = () => {
      if (progressRef.current && video.duration) {
        const percent = (video.currentTime / video.duration) * 100;
        progressRef.current.style.width = `${percent}%`;
      }
      animationFrameRef.current = requestAnimationFrame(updateProgress);
    };

    video.addEventListener('play', () => {
      animationFrameRef.current = requestAnimationFrame(updateProgress);
    });
    video.addEventListener('pause', () => {
      cancelAnimationFrame(animationFrameRef.current);
    });

    return () => cancelAnimationFrame(animationFrameRef.current);
  }, []);

  return (
    <div>
      <video ref={videoRef} src="/video.mp4" />
      <div className="progress-bar">
        <div ref={progressRef} className="progress-fill" />
      </div>
      <HeavyCommentSection />  {/* 리렌더되지 않음 */}
    </div>
  );
}
```

## Why

React의 state 업데이트는 항상 리렌더를 트리거한다. DOM 조작(focus, scroll, 애니메이션)은 리렌더와 무관한 명령형(imperative) 작업이므로, state를 거치면 불필요한 렌더 사이클이 발생한다.

`useRef`는 `.current`를 변경해도 리렌더를 트리거하지 않는다. DOM 노드에 ref를 연결하면 `ref.current`로 직접 접근할 수 있다.

**정량적 효과:**
- focus/scroll 작업: state 기반 2회 리렌더 → ref 기반 0회 리렌더
- 비디오 프로그레스바: 초당 ~4회 리렌더 + 하위 트리 전체 리렌더 → 0회 리렌더 (DOM 직접 업데이트)
- `document.querySelector` 사용 제거 — 타입 안전한 ref 접근
- 이벤트 리스너 정리(cleanup)가 자연스러움

## References

- [React 공식 문서 — useRef](https://react.dev/reference/react/useRef)
- [React 공식 문서 — Manipulating the DOM with Refs](https://react.dev/learn/manipulating-the-dom-with-refs)
- [React 공식 문서 — Referencing values with Refs](https://react.dev/learn/referencing-values-with-refs)
