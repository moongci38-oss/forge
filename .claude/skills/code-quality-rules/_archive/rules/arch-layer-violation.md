---
id: arch-layer-violation
title: "레이어 경계 침범 금지"
severity: critical
category: arch
---

# 레이어 경계 침범 금지

## 문제
프레젠테이션 레이어에서 직접 DB/Repository에 접근하거나, API 레이어에서 UI 컴포넌트를 import하면 레이어 간 결합도가 높아진다. 변경 영향이 전 레이어로 전파되어 유지보수가 불가능해진다.

## 감지 패턴
- UI 컴포넌트(components/, pages/)에서 DB 클라이언트(prisma, typeorm, drizzle) 직접 import
- API 라우트/컨트롤러에서 React 컴포넌트 import
- 프론트엔드 코드에서 백엔드 전용 모듈(fs, child_process, database driver) import
- 서비스 레이어에서 HTTP 요청/응답 객체(req, res) 직접 접근

## Bad Example
```typescript
// BAD: React 컴포넌트에서 Prisma 직접 접근
// components/UserList.tsx
import { prisma } from '@/lib/prisma';

export default async function UserList() {
  // 프레젠테이션 레이어가 데이터 레이어에 직접 의존
  const users = await prisma.user.findMany({
    where: { isActive: true },
    include: { posts: true },
  });

  return <ul>{users.map(u => <li key={u.id}>{u.name}</li>)}</ul>;
}
```

```typescript
// BAD: 서비스에서 HTTP 객체 직접 접근
// services/user.service.ts
import { Request, Response } from 'express';

export class UserService {
  async getUser(req: Request, res: Response) {
    const user = await this.userRepo.findById(req.params.id);
    res.json(user); // 서비스가 HTTP 계층에 결합
  }
}
```

## Good Example
```typescript
// GOOD: 서비스/액션 레이어를 통해 데이터 접근
// actions/user.actions.ts (Server Action 또는 API Route)
import { userService } from '@/services/user.service';

export async function getActiveUsers() {
  return userService.findActiveUsers();
}

// components/UserList.tsx
import { getActiveUsers } from '@/actions/user.actions';

export default async function UserList() {
  const users = await getActiveUsers();
  return <ul>{users.map(u => <li key={u.id}>{u.name}</li>)}</ul>;
}
```

```typescript
// GOOD: 서비스는 순수 비즈니스 로직만 처리
// services/user.service.ts
export class UserService {
  async getUser(userId: string): Promise<User> {
    return this.userRepo.findById(userId);
  }
}

// controllers/user.controller.ts
export class UserController {
  async getUser(req: Request, res: Response) {
    const user = await this.userService.getUser(req.params.id);
    res.json(user);
  }
}
```

## 검증 방법
1. 프로젝트의 레이어 구조를 파악한다 (components, pages, services, repositories, controllers)
2. 각 레이어의 import문을 검사하여 허용되지 않은 의존 방향이 있는지 확인한다
3. 허용 규칙: UI -> Service -> Repository -> DB (단방향)
4. 역방향 import 발견 시 CRITICAL FAIL로 판정한다
