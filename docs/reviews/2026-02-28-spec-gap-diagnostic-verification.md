# Spec 누락 진단 — 검증 리포트

**일자**: 2026-02-28
**검증 대상**: `site-foundation.md` (기존 Spec) vs 신규 템플릿/규칙
**목적**: P1~P7 변경이 실제로 기존 Spec의 누락을 감지할 수 있는지 역검증

---

## 검증 결과 요약

| 신규 섹션/규칙 | site-foundation에서 감지된 누락 | 판정 |
|-------------|---------------------------|:----:|
| 섹션 3 NFR 측정 기준 | NFR-001~007에 목표값/검증 방법 없음 | **감지** |
| 섹션 4 Error/Edge Path | Contact 폼 에러 흐름 미정의 | **감지** |
| 섹션 9.3 Props 인터페이스 | Header, Footer, ContactForm Props 미정의 | **감지** |
| 섹션 9.4 상태 관리 전략 | 모바일 메뉴, 폼, 스크롤 상태 분류 없음 | **감지** |
| 섹션 9.5 에러/로딩/빈 상태 | Contact 제출 중 로딩, 에러 UI 미정의 | **감지** |
| 섹션 9.7 접근성 상세 | ARIA, 포커스 관리 구체 구현 미정의 | **감지** |
| 섹션 9.8 SEO 상세 | 페이지별 메타데이터 테이블 없음 | **감지** |
| 섹션 10.4 FE 테스트 | RTL 컴포넌트 테스트 패턴 없음 | **감지** |
| 섹션 10.5 테스트 데이터 | 시딩/격리/모킹 전략 없음 | **감지** |
| spec-writer API 에러 검증 | 500 에러 응답 미정의 | **감지** |
| spec-writer 입력 검증 | 클라이언트 측 필드별 규칙 미정의 | **감지** |
| P4 완결성 체크 (FE 상태) | 로딩/에러/빈 상태 미고려 | **감지** |
| P4 완결성 체크 (입력 검증) | 필드별 검증 규칙(길이, 형식) 부분적 | **감지** |

**결과**: 13개 갭 모두 신규 템플릿/규칙으로 감지 가능 확인

---

## 상세 역검증

### 1. NFR 측정 기준 부재 (P1 섹션 3)

**현재 Spec**:
```
| NFR-001 | 반응형 | Mobile(<640px), Tablet(640-1024px), Desktop(>1024px) |
| NFR-004 | 성능 | Footer는 Server Component, Header는 Client Component (최소화) |
```

**신규 템플릿 기준으로 필요한 내용**:
```
| NFR-004 | 성능 | Header 번들 크기 | < 15KB gzipped | Lighthouse + webpack-bundle-analyzer |
```
- 기존: "성능" 목표를 정성적으로만 기술
- 신규: 측정 기준 + 목표값 + 검증 방법 필수 → 누락 감지

### 2. Error/Edge Path 부재 (P1 섹션 4)

**현재 Spec**: 와이어프레임 + 인터랙션 설명만 (Happy path 중심)

**신규 템플릿 기준으로 필요한 Error Path**:
- Contact 폼 제출 → 네트워크 에러 → 재시도 안내
- Contact 폼 제출 → Rate Limit (429) → "잠시 후 다시 시도" 메시지
- Contact 폼 제출 → 서버 에러 (500) → 일반 에러 메시지

**필요한 Edge Case**:
- 같은 이메일로 반복 제출
- 5000자 메시지 입력 중 네비게이션 이탈 시 데이터 보존
- 모바일 메뉴 열린 상태에서 뒤로가기

### 3. Props 인터페이스 부재 (P1 섹션 9.3)

**현재 Spec**: 컴포넌트 이름만 언급, Props 미정의

**필요한 Props 정의**:
```typescript
interface HeaderProps {
  className?: string;
}

interface NavLinkProps {
  href: string;
  label: string;
  isActive: boolean;
}

interface ContactFormProps {
  onSuccess?: () => void;
  onError?: (error: Error) => void;
}
```

### 4. 상태 관리 전략 부재 (P1 섹션 9.4)

**현재 Spec**: `useState (모바일 메뉴)` 언급만

**Constitution 11.1 매트릭스 기준 분류 필요**:
| 데이터 | 유형 | 관리 도구 |
|--------|------|---------|
| 모바일 메뉴 열림 | UI State | useState |
| 현재 경로 | URL State | usePathname (Next.js) |
| 폼 입력값 | Form State | react-hook-form |
| 폼 제출 결과 | Server State | React Query useMutation |
| 스크롤 위치 | UI State | useState + scroll event |
| 다크모드 | Global State | ThemeProvider (기존) |

### 5. 에러/로딩/빈 상태 UI 부재 (P1 섹션 9.5)

**현재 Spec**: "성공 시 확인 메시지" + "에러 메시지 표시"만 (구체적 UI 미정의)

**필요한 3-State 정의**:
| 화면 | 로딩 | 빈 상태 | 에러 |
|------|------|--------|------|
| Contact 폼 제출 | 버튼 Spinner + disabled | — | 인라인 에러 + 재시도 |
| About 경력 타임라인 | Skeleton 4줄 | "경력 정보 준비 중" | 재로드 버튼 |

---

## 변경 효과 수치

| 지표 | 변경 전 | 변경 후 |
|------|:------:|:------:|
| 베이스 템플릿 프론트엔드 항목 | 2개 | **9개** |
| 베이스 템플릿 테스트 항목 | 3개 | **5개** |
| spec-writer 검증 항목 | 3개 | **6카테고리** |
| Constitution 크로스커팅 섹션 | 0개 | **4개** (상태/S-C/에러/훅) |
| Constitution 운영 섹션 | 0개 | **5개** (마이그레이션/캐싱/로깅/환경/헬스) |
| S4 기획 패키지 산출물 | 6개 | **7개** (테스트 전략서 추가) |
| Phase 1.5 완결성 체크 | 0개 | **6개** 도메인 체크리스트 |
| Playground→Spec 연결 | 없음 | **4단계 워크플로우** |

---

## 변경된 파일 목록

| # | 파일 | 변경 유형 | 우선순위 |
|:-:|------|---------|:-------:|
| 1 | `~/.claude/trine/templates/spec-template-base.md` | 섹션 3/4/9/10 확장 | P1 |
| 2 | `~/.claude/trine/agents/spec-writer-base.md` | 검증+스킬참조 추가 | P2 |
| 3 | Portfolio `.specify/constitution.md` | 섹션 11 크로스커팅 + 섹션 12 운영 추가 | P3+P7 |
| 4 | Portfolio `.specify/templates/spec-template.md` | 베이스 반영 + 프로젝트 특화 | P3b |
| 5 | `~/.claude/rules/trine-requirements-analysis.md` | 완결성 체크리스트 추가 | P4 |
| 6 | `09-tools/templates/planning-package-template.md` | 테스트 전략서 섹션 추가 | P5 |
| 7 | `.claude/rules/sigil-pipeline.md` | S4 산출물에 테스트 전략서 등록 | P5 |
| 8 | `~/.claude/rules/trine-playground.md` | Spec 반영 흐름 추가 | P6 |

---

## 4축 역검증 (심화)

> 4개 검증 축을 병렬 실행하여 site-foundation.md의 누락을 신규 시스템이 감지하는지 확인.

### 축 1. P1 spec-template-base 검증 (17개 항목)

| # | 항목 | 결과 | 세부 |
|:-:|------|:----:|------|
| 1 | 섹션 3 NFR 측정 기준 | **FAIL** | NFR-001~007 목표값/검증 방법 없음 |
| 2 | 섹션 4.1 Happy Path | PASS | 기본 사용자 플로우 존재 |
| 3 | 섹션 4.2 Error Path | **FAIL** | Contact 폼 에러 흐름 미구조화 |
| 4 | 섹션 4.3 Edge Case | **FAIL** | 엣지 케이스 섹션 없음 |
| 5 | 섹션 9.1 페이지/화면 목록 | PASS | 라우트 매핑 존재 |
| 6 | 섹션 9.2 컴포넌트 계층 | **FAIL** | 컴포넌트 트리 구조 없음 |
| 7 | 섹션 9.3 Props 인터페이스 | **FAIL** | Props 인터페이스 0건 |
| 8 | 섹션 9.4 상태 관리 전략 | **FAIL** | Server/Client/UI 분류 없음 |
| 9 | 섹션 9.5 에러/로딩/빈 상태 | **FAIL** | 3-State UI 정의 전무 |
| 10 | 섹션 9.6 반응형 동작 | PASS | breakpoint별 레이아웃 명시 |
| 11 | 섹션 9.7 접근성 요구사항 | **FAIL** | WCAG 목표만, ARIA/포커스 구체 구현 없음 |
| 12 | 섹션 9.8 SEO 요구사항 | **FAIL** | 페이지별 메타데이터 테이블 없음 |
| 13 | 섹션 9.9 인터랙션/애니메이션 | **FAIL** | hover/transition 패턴 미정의 |
| 14 | 섹션 10.1 단위 테스트 시나리오 | **FAIL** | 제목만 존재, 구체적 케이스 0건 |
| 15 | 섹션 10.2 통합 테스트 시나리오 | **FAIL** | API 정상/에러 응답 시나리오 없음 |
| 16 | 섹션 10.4 프론트엔드 테스트 | **FAIL** | RTL/MSW/jest-axe 패턴 없음 |
| 17 | 섹션 10.5 테스트 데이터 전략 | **FAIL** | 시딩/격리/모킹 전략 없음 |

**감지율**: 14/17 FAIL (82%) — 새 템플릿이었다면 **작성 시점에** 14개 항목을 요구

### 축 2. P2 spec-writer 6카테고리 검증

| 카테고리 | 결과 | 세부 |
|---------|:----:|------|
| FR 수용 기준 | PASS | 기본 수준 존재 |
| API 에러 응답 (4xx/5xx) | **FAIL** | 401만 부분 정의, 403/404/500 없음 |
| 프론트엔드 컴포넌트 Props | **FAIL** | Props 인터페이스 0건 정의 |
| 에러/로딩/빈 상태 UI | **FAIL** | Auth만 부분, 나머지 전무 |
| 테스트 시나리오 (3건+) | **FAIL** | 단위 테스트 제목만, 구체적 시나리오 0건 |
| 입력 검증 규칙 | **FAIL** | 필드별 타입/길이/형식 정의 없음 |

**판정**: 5/6 카테고리 FAIL → **Spec 반려** (보완 후 재제출 요구)

### 축 3. P4 도메인 완결성 체크리스트 (6개 영역)

| # | 영역 | 결과 | 세부 |
|:-:|------|:----:|------|
| 1 | CRUD 완결성 | **FAIL** | Create만 존재 (Contact), Read/Update/Delete 미정의 |
| 2 | 권한/인증 | **WARN** | 사용자 인증 있으나 관리자 RBAC 미정의 |
| 3 | 에러 시나리오 | **WARN** | Auth 에러만, 나머지 도메인 미정의 |
| 4 | 프론트엔드 상태 | **FAIL** | 로딩/에러/빈 상태 UI 전무 |
| 5 | 테스트 시나리오 | **FAIL** | 구체적 시나리오 도출 불가 수준 |
| 6 | 입력 검증 규칙 | PASS | 이메일/비밀번호 기본 규칙 존재 |

**판정**: 3 FAIL + 2 WARN → Phase 1.5에서 **추가 질문 생성** 또는 **기획서 보완 권고**

### 축 4. P3 Constitution 크로스커팅 참조

| # | Constitution 항목 | site-foundation 참조 | 결과 |
|:-:|------------------|:-----------------:|:----:|
| 1 | 11.1 상태 관리 매트릭스 | 미참조 | **FAIL** |
| 2 | 11.2 Server/Client Decision Tree | Header=Client, Footer=Server 언급 | **WARN** (부분) |
| 3 | 11.3 에러 핸들링 전략 | 미참조 | **FAIL** |
| 4 | 11.4 커스텀 훅 규칙 | 미참조 | **FAIL** |
| 5 | 12.1 DB 마이그레이션 절차 | 미참조 | **FAIL** |
| 6 | 12.2 캐싱 전략 | 미참조 | **FAIL** |
| 7 | 12.3 로깅 전략 | 미참조 | **FAIL** |
| 8 | 12.4 환경별 설정 | 미참조 | **FAIL** |
| 9 | 12.5 헬스 체크 | 미참조 | **FAIL** |

**참조율**: 1/9 부분 참조 (11%) → 새 시스템이었다면 **8개 항목이 Spec에 추가 반영** 요구

---

## 4축 종합 결론

```
기존 시스템:  site-foundation.md 작성 → Check 3.5 PASS → 구현 누락 다수 발생
새 시스템:    4개 게이트 중 4개 모두 FAIL/WARN 감지

  P1 템플릿:       14/17 항목 FAIL → 작성 시점에 프론트엔드/테스트 14개 항목 요구
  P2 spec-writer:  5/6 카테고리 FAIL → Spec 반려 (보완 후 재제출)
  P4 도메인 체크:   3 FAIL + 2 WARN → Phase 1.5에서 추가 질문/기획서 보완
  P3 Constitution: 8/9 항목 미참조 → 크로스커팅 관심사 반영 요구
```

**결론**: P1-P7 변경이 실제로 작동함을 확인. 기존에 PASS되던 Spec이 새 시스템에서는 4개 축 모두에서 감지되어, 구현 전에 Spec 보완을 강제했을 것이다.
