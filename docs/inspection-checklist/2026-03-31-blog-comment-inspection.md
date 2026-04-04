# 최종 검수 체크리스트 (Final Inspection Checklist)

## 프로젝트 정보
- **프로젝트**: Forge (Blog Comment System with Nested Replies)
- **세션**: CLI Session (2026-03-31)
- **현재 브랜치**: develop
- **대상**: PR 생성 직전 최종 검수

---

## 결과 요약

| 영역 | 상태 | 상세 |
|------|:----:|------|
| 빌드/테스트 (Check 3) | ⏳ | 실행 대기 (코드 구현 단계 중) |
| Spec 추적성 (Check 3.5) | ⏳ | 실행 대기 (코드 구현 단계 중) |
| UI/품질 (Check 3.6) | ✅ | N/A — Backend NestJS API (프론트엔드 변경 없음) |
| 코드 리뷰 (Check 3.7) | ⏳ | 실행 대기 (코드 구현 단계 중) |
| 보안 (Check 3.8) | ⏳ | 실행 대기 (코드 구현 단계 중) |
| 문서/PR 준비 | ✅ | 완료 — Plan 문서 작성됨 |

---

## 1. 빌드/테스트 (Check 3) — 상태: ⏳ 대기

### 필수 검증 항목

- [ ] `verify.sh code` 통과 (빌드 성공)
  - NestJS 컴파일 에러 없음
  - TypeScript 타입 체크 통과

- [ ] `verify.sh test` 통과 (테스트)
  - 단위 테스트: `tests/unit/comments/` 전체 PASS
  - E2E 테스트: `tests/e2e/comments.e2e.spec.ts` 전체 PASS
  - 커버리지 요구사항: 80% 이상

- [ ] `verify.sh lint` 통과
  - ESLint 규칙 준수
  - Prettier 포맷팅 적용

- [ ] 타입 체크: `tsc --noEmit`
  - 모든 타입 오류 해결

- [ ] 신규 경고 없음
  - Console 경고 제거
  - Deprecation 경고 해결

---

## 2. Spec 추적성 (Check 3.5) — 상태: ⏳ 대기

### Plan 문서 요구사항
✅ **현재 상태**: `docs/plans/2026-03-30-blog-comment-system-nested-replies.md` 작성됨

### 필수 매핑 항목

- [ ] **Comment Entity**
  - [ ] id (UUID, PK)
  - [ ] body (text)
  - [ ] authorId (UUID, FK)
  - [ ] postId (UUID, FK)
  - [ ] parentId (UUID, nullable)
  - [ ] depth (integer, 0-3)
  - [ ] createdAt, updatedAt (timestamps)

- [ ] **CommentsService** (비즈니스 로직)
  - [ ] `create(postId, authorId, body, parentId?)` → Comment (depth 검증 포함)
  - [ ] `findByPostId(postId, depth=null)` → Comment[] (재귀적 트리)
  - [ ] `update(id, authorId, body)` → Comment (소유자 검증)
  - [ ] `delete(id, authorId)` → void (소유자 검증)
  - [ ] 깊이 제한: `MAX_DEPTH = 3` 강제

- [ ] **CommentsController** (REST API)
  - [ ] `POST /posts/:postId/comments` (생성)
  - [ ] `GET /posts/:postId/comments` (조회, 재귀 트리)
  - [ ] `PATCH /comments/:id` (수정)
  - [ ] `DELETE /comments/:id` (삭제)

- [ ] **데이터베이스 마이그레이션**
  - [ ] TypeORM migration 파일 생성 (`src/database/migrations/`)
  - [ ] comments 테이블 구조 일치
  - [ ] FK 제약 조건 정의 (posts, users)
  - [ ] 인덱스: postId, authorId, parentId

- [ ] **테스트 매핑**
  - [ ] 단위 테스트: Entity, Service, Controller
  - [ ] E2E 테스트: 전체 API 흐름
  - [ ] 각 요구사항당 테스트 1개 이상

---

## 3. UI/품질 (Check 3.6) — 상태: ✅ N/A

**판정**: Backend-only 변경 (NestJS API). 프론트엔드 코드 없음.

- [ ] 반응형 디자인 — **N/A** (REST API only)
- [ ] 접근성 — **N/A** (REST API only)
- [ ] Lighthouse — **N/A** (REST API only)
- [ ] Typography — **N/A** (REST API only)
- [ ] Animation — **N/A** (REST API only)
- [ ] Forms — **N/A** (REST API only)
- [ ] Dark Mode — **N/A** (REST API only)
- [ ] Navigation — **N/A** (REST API only)

---

## 4. 코드 리뷰 (Check 3.7) — 상태: ⏳ 대기

### Layer 1 — Git Hook (자동 실행)

실행 대기: 코드 구현 후 commit 시 자동 검증

- [ ] **tsc --noEmit** (pre-commit)
  - TypeScript 컴파일 에러 없음

- [ ] **ESLint** (pre-commit)
  - 코드 스타일 준수
  - 권장: `eslint --fix` 자동 적용

- [ ] **Prettier** (pre-commit)
  - 포맷팅 일관성

- [ ] **Secrets 검사** (pre-push)
  - `.env` 파일 미포함
  - DB 연결 문자열, API 키 노출 금지

- [ ] **의존성 검사** (pre-push)
  - dev/prerelease 의존성 미포함

- [ ] **JSON 무결성** (pre-push)
  - `package.json`, `tsconfig.json` 유효

- [ ] **i18n 검사** (pre-push)
  - Dead i18n 키 없음 (해당시)

### Layer 2 — Agent (시맨틱 검사)

실행 대기: Check 3.7 스킬 실행 시

- [ ] **API 과다 호출 없음** (api-unnecessary-call)
  - N+1 쿼리 없음
  - 중복 API 호출 없음

- [ ] **에러 처리** (api-error-swallow) — **CRITICAL**
  - 모든 try-catch에 로깅 있음
  - 에러 삼킬 수 없음

- [ ] **Context 커플링** (api-state-coupling)
  - 과도한 전역 상태 사용 없음

- [ ] **순환 의존성** (arch-circular-dep) — **CRITICAL**
  - comments → posts (OK)
  - posts → comments (금지)

- [ ] **레이어 침범** (arch-layer-violation) — **CRITICAL**
  - Controller → Service → Entity (정확한 순서)
  - 하위 계층이 상위 계층 참조하지 않음

- [ ] **비동기 문제** (logic-race-condition, logic-missing-cleanup) — **CRITICAL**
  - 동시 요청 처리 안전성
  - 데이터베이스 트랜잭션 처리
  - 리소스 cleanup (DB 연결, 임시 파일)

- [ ] **중복 mutation 없음** (logic-redundant-mutation)
  - 같은 필드를 두 번 이상 변경하지 않음

---

## 5. 보안 (Check 3.8) — 상태: ⏳ 대기

### 필수 보안 검증

- [ ] **입력 검증**
  - [ ] `body` 필드: 비어있지 않음, 길이 제한 (예: 5000자)
  - [ ] `parentId`: 유효한 UUID 형식
  - [ ] class-validator 데코레이터 사용 (`@IsNotEmpty()`, `@IsUUID()`, `@MaxLength()`)

- [ ] **인증/인가**
  - [ ] 모든 수정/삭제 API: JWT 토큰 필수 (@UseGuards(JwtAuthGuard))
  - [ ] 수정/삭제: 본인 작성 댓글만 가능 (authorId 일치 검증)
  - [ ] 조회: 인증 불필요 (공개 API)

- [ ] **민감 데이터 노출 방지**
  - [ ] 응답에서 내부 ID 제거 (필요시)
  - [ ] 에러 메시지에서 DB 상세 정보 숨김
  - [ ] 로그에서 민감 데이터 필터링

- [ ] **의존성 취약점**
  - [ ] `npm audit` 실행 (심각한 취약점 0개)
  - [ ] 중요 의존성 최신 버전 유지

- [ ] **CORS/CSP**
  - [ ] CORS 설정: `@nestjs/common` CorsModule 적용
  - [ ] 허용 도메인 명시적 지정
  - [ ] Content-Security-Policy 헤더 고려 (해당시)

---

## 6. 문서/PR 준비 — 상태: ✅ 진행중

### 현재 완료 항목

✅ **Plan 문서**
- 파일: `docs/plans/2026-03-30-blog-comment-system-nested-replies.md`
- 내용: 구현 계획, 태스크 분해, 테스트 전략 포함
- Task 1~5 상세 정의됨

### PR 생성 전 필수 완료

- [ ] **Spec 파일 최신 상태 확인**
  - 구현 완료 후 spec과 일치 검증
  - 변경사항 있으면 spec 업데이트

- [ ] **변경사항 요약 작성**
  - PR 제목: `feat: 블로그 댓글 시스템 구현 (최대 깊이 3)`
  - PR 본문:
    ```markdown
    ## 변경사항
    - Comment 엔티티 + 마이그레이션
    - CommentsService (CRUD + 깊이 검증)
    - CommentsController (REST API 4개 엔드포인트)
    - 완전한 단위 + E2E 테스트
    - Spec 추적성 100%

    ## 테스트 실행
    ```bash
    npm run test:comments
    npm run test:e2e comments
    ```

    ## 마이그레이션
    ```bash
    npm run typeorm migration:run
    ```
    ```

- [ ] **Breaking Change 확인**
  - 예상 breaking change 없음 (신규 기능)
  - 기존 API 변경 없음

- [ ] **커밋 메시지 규칙**
  - 형식: `feat: 블로그 댓글 시스템 구현`
  - Conventional Commits 준수
  - Co-Authored-By (필요시): `Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>`

---

## 최종 판정

### 현재 상태: 🔄 구현 중

**상태**: Plan 문서 완성 → 코드 구현 중 → 검증 대기

### PR 생성 가능 조건

✅ 다음을 모두 만족해야 PR 생성 가능:

1. Check 3 (빌드/테스트) PASS
2. Check 3.5 (Spec 추적성) PASS
3. Check 3.7 (코드 리뷰 — 에러 처리 CRITICAL) PASS
4. Check 3.8 (보안) PASS
5. 문서/커밋 메시지 완성

### 다음 단계

1. **코드 구현** (현재 진행중)
   - Task 1~5 순차 완성
   - 각 Task마다 테스트 작성 (TDD)

2. **로컬 검증**
   ```bash
   npm run test:comments
   npm run test:e2e comments
   npm run lint
   npm run build
   ```

3. **최종 검수** (이 체크리스트 재실행)
   - 모든 항목 ✅ 확인

4. **PR 생성**
   ```bash
   git checkout develop
   git pull origin develop
   git push origin feature/comment-system-nested-replies
   # GitHub → Create Pull Request
   ```

---

## 이력

| 날짜 | 버전 | 내용 |
|------|------|------|
| 2026-03-31 | v1.0 | 최초 작성 (구현 전 체크리스트) |

---

**마지막 업데이트**: 2026-03-31 (자동 생성)
