---
id: api-error-swallow
title: "catch에서 에러 삼킴 금지"
severity: critical
category: api
---

# catch에서 에러 삼킴 금지

## 문제
catch 블록에서 console.log만 하고 에러를 re-throw하지 않으면 상위 호출자가 실패를 인지하지 못한다. 사용자에게 성공으로 보이지만 실제로는 데이터가 저장되지 않는 silent failure 발생.

## 감지 패턴
- `catch` 블록에서 `console.log`/`console.error`만 호출하고 `throw`, `return`, UI 에러 표시가 없는 경우
- 빈 catch 블록 `catch (e) {}`
- catch에서 `// TODO: handle error` 주석만 있는 경우

## Bad Example
```typescript
async function saveProfile(data: ProfileData) {
  try {
    await api.updateProfile(data);
    toast.success('저장되었습니다');
  } catch (error) {
    // BAD: 에러를 삼킴 - 사용자는 저장 실패를 알 수 없음
    console.error('Failed to save:', error);
  }
}

// BAD: 빈 catch 블록
try {
  await deleteComment(id);
} catch (e) {}
```

## Good Example
```typescript
async function saveProfile(data: ProfileData) {
  try {
    await api.updateProfile(data);
    toast.success('저장되었습니다');
  } catch (error) {
    // GOOD: 사용자에게 실패를 알리고 에러를 전파
    toast.error('저장에 실패했습니다. 다시 시도해주세요.');
    throw error; // 상위 에러 바운더리에서 처리 가능
  }
}

// GOOD: 의도적 무시라면 명시적으로 표현
try {
  await deleteComment(id);
} catch (error) {
  // 이미 삭제된 댓글은 무시 (409 Conflict)
  if (!(error instanceof ApiError && error.status === 409)) {
    throw error;
  }
}
```

## 검증 방법
1. 프로젝트 내 `catch` 블록을 전수 검색한다
2. catch 내부에 `throw`, 사용자 알림(toast/alert/에러 상태), 또는 명시적 에러 전파가 있는지 확인한다
3. `console.log`/`console.error`만 있는 catch는 FAIL로 판정한다
4. 의도적 무시인 경우 조건부 re-throw와 주석이 있는지 확인한다
