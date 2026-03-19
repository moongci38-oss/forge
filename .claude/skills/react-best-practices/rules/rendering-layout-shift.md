---
title: "CLS 방지 — 이미지/광고에 사전 크기 지정"
id: rendering-layout-shift
impact: MEDIUM
category: rendering-performance
impactDescription: "CLS < 0.1 — 사용자 불편 제거, Core Web Vitals 통과"
tags: [react, nextjs, performance, cls, core-web-vitals, layout]
---

# CLS 방지 — 이미지/광고에 사전 크기 지정

> 이미지, 광고, 동적 콘텐츠가 로드되면서 기존 콘텐츠를 밀어내는 레이아웃 시프트(CLS)는 사용자 경험을 크게 해친다. 모든 동적 요소에 사전 크기를 지정하면 CLS를 0에 가깝게 유지할 수 있다.

## Incorrect

```tsx
// Before: 크기 미지정 — 이미지 로드 시 레이아웃 시프트 발생
function BlogPost({ post }: { post: Post }) {
  return (
    <article>
      <h1 className="text-3xl font-bold">{post.title}</h1>
      {/* width/height 없음 — 이미지 로드 전 높이 0, 로드 후 높이 확보 → CLS */}
      <img src={post.coverImage} alt={post.title} className="w-full" />
      <p className="mt-4">{post.content}</p>
    </article>
  );
}

// 동적 콘텐츠 높이 미예약 — 데이터 도착 시 레이아웃 밀림
function UserProfile({ userId }: { userId: string }) {
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    fetchUser(userId).then(setUser);
  }, [userId]);

  // 로딩 중: 아무것도 표시 안 함 → 로드 완료: 프로필 카드 삽입 → 아래 콘텐츠 밀림
  if (!user) return null;

  return (
    <div className="p-6 bg-white rounded-lg shadow">
      <img src={user.avatar} alt={user.name} className="w-20 h-20 rounded-full" />
      <h2>{user.name}</h2>
      <p>{user.bio}</p>
    </div>
  );
}

// 폰트 로드 시 텍스트 크기 변경 — CLS 발생
function PageTitle({ title }: { title: string }) {
  return (
    // 웹 폰트 로드 전: 시스템 폰트(작은 크기) → 로드 후: 웹 폰트(큰 크기) → 아래 밀림
    <h1 style={{ fontFamily: '"Custom Font", sans-serif' }}>{title}</h1>
  );
}
```

## Correct

```tsx
// After: 모든 동적 요소에 사전 크기 지정
import Image from 'next/image';

function BlogPost({ post }: { post: Post }) {
  return (
    <article>
      <h1 className="text-3xl font-bold">{post.title}</h1>
      {/* next/image — width/height 필수 또는 fill + 부모 크기 */}
      <div className="relative w-full aspect-[16/9]">
        <Image
          src={post.coverImage}
          alt={post.title}
          fill
          sizes="(min-width: 768px) 720px, 100vw"
          className="object-cover rounded-lg"
          priority // above-the-fold 이미지
        />
      </div>
      <p className="mt-4">{post.content}</p>
    </article>
  );
}

// 동적 콘텐츠 — min-height로 공간 예약
function UserProfile({ userId }: { userId: string }) {
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    fetchUser(userId).then(setUser);
  }, [userId]);

  return (
    // 로딩 중에도 동일한 높이 유지 — CLS 방지
    <div className="min-h-[200px] p-6 bg-white rounded-lg shadow">
      {user ? (
        <>
          <Image
            src={user.avatar}
            alt={user.name}
            width={80}
            height={80}
            className="rounded-full"
          />
          <h2 className="mt-2 text-xl font-bold">{user.name}</h2>
          <p className="text-gray-600">{user.bio}</p>
        </>
      ) : (
        // 스켈레톤 — 실제 콘텐츠와 동일한 레이아웃
        <div>
          <div className="w-20 h-20 bg-gray-200 rounded-full animate-pulse" />
          <div className="h-6 w-32 bg-gray-200 rounded animate-pulse mt-2" />
          <div className="h-4 w-48 bg-gray-200 rounded animate-pulse mt-2" />
        </div>
      )}
    </div>
  );
}
```

```tsx
// 광고/임베드 슬롯 — 사전 크기 예약
function AdSlot({ adId, width, height }: { adId: string; width: number; height: number }) {
  return (
    // 광고 로드 전에도 정확한 크기가 확보됨
    <div
      className="bg-gray-100 flex items-center justify-center"
      style={{
        width: `${width}px`,
        height: `${height}px`,
        aspectRatio: `${width}/${height}`,
      }}
    >
      <AdComponent adId={adId} />
    </div>
  );
}

// 동적 리스트 — 아이템 삽입 시 CLS 방지
function NotificationBanner() {
  const [banners, setBanners] = useState<Banner[]>([]);

  return (
    // 배너 영역 사전 예약 — 배너 추가/제거 시 아래 콘텐츠 밀림 방지
    <div
      className="overflow-hidden transition-all duration-300"
      style={{
        // 배너가 있으면 높이 확보, 없으면 0 — transition으로 부드럽게
        maxHeight: banners.length > 0 ? '80px' : '0px',
      }}
    >
      {banners.map((banner) => (
        <div key={banner.id} className="h-[80px] p-4 bg-blue-50">
          {banner.message}
        </div>
      ))}
    </div>
  );
}
```

## Why

Cumulative Layout Shift(CLS)는 Core Web Vitals 3대 지표 중 하나로, 페이지 로드 중 발생하는 예기치 않은 레이아웃 이동을 측정한다.

CLS 발생 원인:
1. **크기 미지정 이미지/비디오**: 로드 전 높이 0 → 로드 후 높이 확보
2. **동적 콘텐츠 삽입**: 광고, 배너, 알림이 기존 콘텐츠 위에 삽입
3. **웹 폰트 FOUT**: 시스템 폰트 → 웹 폰트 전환 시 글자 크기 변경
4. **비동기 데이터 로드**: 데이터 도착 후 콘텐츠 삽입

방지 전략:
- **이미지**: `width`/`height` 속성 또는 `aspect-ratio`로 공간 예약
- **동적 콘텐츠**: `min-height`로 최소 높이 확보 + 스켈레톤 UI
- **폰트**: `next/font` + `size-adjust`로 폰트 크기 차이 보정
- **광고/임베드**: 정해진 크기의 컨테이너에 배치

**정량적 효과:**
- CLS 스코어: 0.25+ (불량) → 0.1 이하 (양호) — Core Web Vitals "Good" 달성
- Google 검색 순위에 영향 (Core Web Vitals는 순위 신호)
- 사용자가 읽는 도중 버튼이 밀리는 "잘못된 클릭" 방지
- 모바일에서 특히 체감 — 작은 화면에서 CLS 영향이 더 크다

## References

- [Web.dev — Cumulative Layout Shift (CLS)](https://web.dev/articles/cls)
- [Web.dev — Optimize CLS](https://web.dev/articles/optimize-cls)
- [Next.js Image — Required Props](https://nextjs.org/docs/app/api-reference/components/image#required-props)
