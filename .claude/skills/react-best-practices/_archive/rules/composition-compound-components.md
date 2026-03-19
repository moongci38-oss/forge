---
title: "Compound Component 패턴으로 유연한 API"
id: composition-compound-components
impact: HIGH
category: composition-patterns
impactDescription: "Boolean prop 지옥 제거 — 컴포넌트 API 명확성 + 확장성 향상"
tags: [react, patterns, compound-components, composition, api-design]
---

# Compound Component 패턴으로 유연한 API

> Boolean prop이 5개 이상인 컴포넌트는 Compound Component 패턴으로 분리하여 유연하고 명확한 API를 제공한다.

## Incorrect

```tsx
// Before: Boolean prop 지옥 — 조합 폭발 + 의미 불명확
'use client';

interface ModalProps {
  isOpen: boolean;
  onClose: () => void;
  title?: string;
  showHeader?: boolean;
  showFooter?: boolean;
  showCloseButton?: boolean;
  closable?: boolean;
  animated?: boolean;
  fullWidth?: boolean;
  centered?: boolean;
  size?: 'sm' | 'md' | 'lg';
  overlay?: boolean;
  overlayClickClose?: boolean;
  children: React.ReactNode;
  footerContent?: React.ReactNode;
  headerExtra?: React.ReactNode;
  confirmText?: string;
  cancelText?: string;
  onConfirm?: () => void;
  onCancel?: () => void;
  confirmLoading?: boolean;
  confirmDisabled?: boolean;
  // props가 20개 이상 — 어떤 조합이 유효한지 불명확
}

// 사용 시: prop 의미를 외워야 함
<Modal
  isOpen={open}
  onClose={close}
  title="삭제 확인"
  showHeader={true}
  showFooter={true}
  showCloseButton={true}
  closable={true}
  animated={true}
  fullWidth={false}
  centered={true}
  size="md"
  overlay={true}
  overlayClickClose={true}
  confirmText="삭제"
  cancelText="취소"
  onConfirm={handleDelete}
  confirmLoading={isDeleting}
>
  <p>정말 삭제하시겠습니까?</p>
</Modal>
```

## Correct

```tsx
// After: Compound Component 패턴 — 명확한 구조 + 유연한 합성
'use client';

import {
  createContext,
  useContext,
  useState,
  useCallback,
  type ReactNode,
} from 'react';

// Modal 내부 상태 공유 Context
interface ModalContextValue {
  isOpen: boolean;
  onClose: () => void;
}

const ModalContext = createContext<ModalContextValue | null>(null);

function useModalContext() {
  const ctx = useContext(ModalContext);
  if (!ctx) throw new Error('Modal 컴포넌트 내부에서만 사용 가능');
  return ctx;
}

// Root 컴포넌트
interface ModalRootProps {
  isOpen: boolean;
  onClose: () => void;
  children: ReactNode;
  size?: 'sm' | 'md' | 'lg';
}

function ModalRoot({ isOpen, onClose, children, size = 'md' }: ModalRootProps) {
  if (!isOpen) return null;

  const sizeClass = { sm: 'max-w-sm', md: 'max-w-md', lg: 'max-w-lg' }[size];

  return (
    <ModalContext.Provider value={{ isOpen, onClose }}>
      <div className="fixed inset-0 z-50 flex items-center justify-center">
        <div className="fixed inset-0 bg-black/50" onClick={onClose} />
        <div className={`relative z-10 rounded-lg bg-white p-6 ${sizeClass}`}>
          {children}
        </div>
      </div>
    </ModalContext.Provider>
  );
}

// 서브 컴포넌트들
function ModalHeader({ children }: { children: ReactNode }) {
  const { onClose } = useModalContext();
  return (
    <div className="flex items-center justify-between border-b pb-4">
      <h2 className="text-lg font-semibold">{children}</h2>
      <button onClick={onClose} aria-label="닫기">
        &times;
      </button>
    </div>
  );
}

function ModalBody({ children }: { children: ReactNode }) {
  return <div className="py-4">{children}</div>;
}

function ModalFooter({ children }: { children: ReactNode }) {
  return (
    <div className="flex justify-end gap-2 border-t pt-4">{children}</div>
  );
}

function ModalClose({ children }: { children: ReactNode }) {
  const { onClose } = useModalContext();
  return <span onClick={onClose}>{children}</span>;
}

// Compound Component 조립
const Modal = Object.assign(ModalRoot, {
  Header: ModalHeader,
  Body: ModalBody,
  Footer: ModalFooter,
  Close: ModalClose,
});

export { Modal };
```

```tsx
// 사용: 구조가 명확하고 커스터마이징이 자유로움
'use client';

import { useState } from 'react';
import { Modal } from '@/components/Modal';

function DeleteConfirmDialog() {
  const [open, setOpen] = useState(false);
  const [isDeleting, setIsDeleting] = useState(false);

  return (
    <>
      <button onClick={() => setOpen(true)}>삭제</button>

      {/* 구조가 JSX로 표현됨 — 어떤 UI가 렌더링되는지 한눈에 파악 */}
      <Modal isOpen={open} onClose={() => setOpen(false)} size="sm">
        <Modal.Header>삭제 확인</Modal.Header>
        <Modal.Body>
          <p>정말 삭제하시겠습니까?</p>
          <p className="text-sm text-gray-500">이 작업은 되돌릴 수 없습니다.</p>
        </Modal.Body>
        <Modal.Footer>
          <Modal.Close>
            <button className="rounded px-4 py-2">취소</button>
          </Modal.Close>
          <button
            onClick={async () => {
              setIsDeleting(true);
              await handleDelete();
              setOpen(false);
            }}
            disabled={isDeleting}
            className="rounded bg-red-500 px-4 py-2 text-white"
          >
            {isDeleting ? '삭제 중...' : '삭제'}
          </button>
        </Modal.Footer>
      </Modal>
    </>
  );
}

// 커스텀 변형: Footer 없는 알림 모달
function AlertDialog({ message }: { message: string }) {
  const [open, setOpen] = useState(true);

  return (
    <Modal isOpen={open} onClose={() => setOpen(false)}>
      <Modal.Header>알림</Modal.Header>
      <Modal.Body>
        <p>{message}</p>
      </Modal.Body>
      {/* Footer 없이도 동작 — 유연한 합성 */}
    </Modal>
  );
}
```

## Why

Boolean prop이 많은 컴포넌트는 "설정 객체(configuration object)" 패턴에 빠진다. 어떤 prop 조합이 유효한지 알기 어렵고, 새 기능 추가마다 prop이 늘어나 인터페이스가 비대해진다. Compound Component 패턴은 컴포넌트의 구조를 JSX로 표현하여 사용자가 필요한 부분만 조립할 수 있게 한다.

**정량적 효과:**
- Props 수: 20+ boolean → 각 서브컴포넌트 2-3개 명확한 props
- 타입 안전성: 불가능한 prop 조합 컴파일 타임에 방지
- 확장성: 새 서브컴포넌트 추가만으로 기능 확장 — 기존 API 변경 불필요
- 문서화: JSX 구조 자체가 사용법 문서 역할

**적용 기준:** Boolean prop이 5개 이상이거나, 렌더링 구조가 가변적인 컴포넌트에 적합. 단순한 컴포넌트에는 과도할 수 있다.

## References

- [React: Compound Components Pattern](https://react.dev/learn/passing-data-deeply-with-context)
- [Kent C. Dodds: Compound Components](https://kentcdodds.com/blog/compound-components-with-react-hooks)
- [Radix UI: Compound Components](https://www.radix-ui.com/primitives/docs/overview/introduction)
