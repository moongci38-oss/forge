---
title: "모듈 의존성 규칙"
id: forge-module-dependency
impact: MEDIUM
scope: [forge]
tags: [module, dependency, nestjs, circular, layer, barrel-export]
requires: []
section: forge-quality
audience: dev
impactDescription: "미준수 시 순환 의존성으로 런타임 에러, 역방향 의존으로 아키텍처 붕괴, forwardRef 남용으로 유지보수성 저하"
enforcement: flexible
---

# Forge Dev Module Dependency Rules

> 모듈 간 의존성 방향을 검증하여 순환 의존성과 잘못된 의존 방향을 사전 차단한다.
> Check 3.7 (code-reviewer)이 이 규칙을 검증한다.

## 의존성 방향 원칙

```text
[필수] 상위 모듈 → 하위 모듈 방향으로만 의존
[금지] 순환 의존 (A → B → A)
[금지] 기능 모듈 → 인프라 모듈 역방향 의존
```

## NestJS 모듈 의존성 계층

```text
Layer 3 (Feature):  modules/estimates, modules/chat, modules/contact
                         ↓ (의존 가능)
Layer 2 (Domain):   modules/users, modules/auth
                         ↓ (의존 가능)
Layer 1 (Infra):    common/*, config/*, shared/*
```

- Layer 3 → Layer 2 의존: 허용
- Layer 3 → Layer 1 의존: 허용
- Layer 2 → Layer 1 의존: 허용
- Layer 1 → Layer 2/3 의존: **금지** (역방향)
- Layer 3 ↔ Layer 3 상호 의존: **경고** (forwardRef 필요 시 설계 재검토 권장)

## 검증 패턴

### 순환 의존성 감지

```text
[FAIL] Module A imports Module B, Module B imports Module A
[WARN] forwardRef() 사용 — 설계 재검토 권장
```

- `forwardRef()`는 순환 의존성의 증상이므로, 사용 시 경고
- 해결: 공통 인터페이스를 Layer 1로 추출하거나 이벤트 기반 통신으로 전환

### 잘못된 Import 방향

```text
[FAIL] common/* 또는 config/*에서 modules/* import
[FAIL] packages/shared/*에서 apps/* import
[WARN] 기능 모듈 간 직접 Service import (이벤트 기반 권장)
```

### Barrel Export 검증

```text
[권장] 각 모듈의 index.ts로 공개 API 관리
[경고] 모듈 내부 파일을 외부에서 직접 import (캡슐화 위반)
```

## AI 에이전트 행동 규칙

1. **Check 3.7**: Module import 패턴을 정적 분석하여 위 규칙 검증
2. **Backend Teammate**: 새 모듈 생성 시 의존성 계층 준수
3. **Lead**: forwardRef 사용 발견 시 설계 대안 제시
