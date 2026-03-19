---
id: arch-circular-dep
title: "모듈 간 순환 import 금지"
severity: critical
category: arch
---

# 모듈 간 순환 import 금지

## 문제
모듈 A가 B를 import하고 B가 A를 import하면 순환 의존성이 발생한다. 번들러에 따라 런타임에 `undefined` import가 되거나, 초기화 순서 문제로 예측 불가능한 버그가 발생한다. 모듈 분리와 테스트도 불가능해진다.

## 감지 패턴
- 모듈 A에서 B를 import하고, B에서 A를 import하는 양방향 의존
- 3개 이상 모듈의 순환 고리 (A -> B -> C -> A)
- barrel file(index.ts)을 통한 간접 순환
- 같은 도메인 내 서비스 간 상호 import

## Bad Example
```typescript
// services/user.service.ts
import { OrderService } from './order.service'; // A -> B

export class UserService {
  constructor(private orderService: OrderService) {}

  async deleteUser(userId: string) {
    await this.orderService.cancelAllOrders(userId);
    // ...
  }
}

// services/order.service.ts
import { UserService } from './user.service'; // B -> A (순환!)

export class OrderService {
  constructor(private userService: UserService) {}

  async createOrder(userId: string) {
    const user = await this.userService.findById(userId);
    // ...
  }
}
```

## Good Example
```typescript
// GOOD: 공통 인터페이스로 의존성 역전
// interfaces/user.interface.ts
export interface IUserProvider {
  findById(userId: string): Promise<User>;
}

// services/order.service.ts
import { IUserProvider } from '../interfaces/user.interface';

export class OrderService {
  constructor(private userProvider: IUserProvider) {}

  async createOrder(userId: string) {
    const user = await this.userProvider.findById(userId);
    // ...
  }
}

// services/user.service.ts
import { OrderService } from './order.service';
import { IUserProvider } from '../interfaces/user.interface';

export class UserService implements IUserProvider {
  constructor(private orderService: OrderService) {}

  async findById(userId: string): Promise<User> { /* ... */ }

  async deleteUser(userId: string) {
    await this.orderService.cancelAllOrders(userId);
  }
}
```

## 검증 방법
1. 변경된 파일의 import 그래프를 추적한다 (import -> 해당 모듈의 import -> ...)
2. 추적 중 이미 방문한 모듈이 다시 나타나면 순환으로 판정한다
3. barrel file(index.ts) 경유 import도 최종 소스까지 추적한다
4. 순환이 발견되면 CRITICAL FAIL - 인터페이스 분리 또는 제3 모듈 추출을 권장한다
