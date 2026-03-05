# SIGIL 파이프라인 — Stage별 DoD (Definition of Done) 체크리스트

**용도**: 각 [STOP] 게이트에서 산출물 완성도를 검증하는 체크리스트
**적용**: 모든 SIGIL 프로젝트 (개발 트랙 + 콘텐츠 트랙)

> `[AI]` = AI가 자동 완료 가능 / `[Human]` = Human이 직접 실행 필수 (AI는 계획서 작성까지)

---

## S1 Research DoD

### 공통 (모든 유형)
- [ ] `[AI]` 시장 조사 보고서 작성 (TAM/SAM/SOM 포함)
- [ ] `[AI]` 경쟁사 분석 5개사 이상 (장단점 비교표)
- [ ] `[AI]` 출처 3개 이상 다중 검증 + 신뢰도 등급 표기 (High/Medium/Low)
- [ ] `[AI]` 경쟁 가설 3개 이상 수립
- [ ] `[AI]` JTBD (Jobs To Be Done) 분석 완료
- [ ] `[AI]` 산출물 경로: `{folderMap.research}/{project}/YYYY-MM-DD-s1-*.md`

### 개발 트랙 추가
- [ ] `[AI]` 기술 스택 조사 (엔진/프레임워크/인프라)
- [ ] `[AI]` 법률/규제 조사 (해당 시장)

### 콘텐츠 트랙 추가
- [ ] `[AI]` 트렌드 키워드 분석
- [ ] `[AI]` 채널 벤치마크 (상위 10개 채널)

---

## S2 Concept DoD

### 공통
- [ ] `[AI]` Lean Canvas 완성 (9개 블록)
- [ ] `[AI]` TAM/SAM/SOM 추정 완료
- [ ] `[AI]` Go/No-Go 스코어링 실행
- [ ] `[AI]` Kill Criteria 해당 사항 없음 확인

### Go/No-Go 스코어링 (80점+ = Go)

| 영역 | 가중치 | 점수 (1-100) | 가중 점수 |
|------|:-----:|:-----------:|:--------:|
| 시장 기회 | 30% | | |
| 기술 실현성 | 25% | | |
| 비즈니스 모델 | 25% | | |
| 위험 관리 | 20% | | |
| **총점** | **100%** | | **__점** |

### Kill Criteria (하나라도 해당 시 No-Go)
- [ ] TAM < $1M → ❌ Kill
- [ ] 경쟁사 70%+ 시장 점유 (진입 장벽) → ❌ Kill
- [ ] 핵심 기술 불가 (현재 기술로 구현 불가) → ❌ Kill
- [ ] 규제 장벽 (법적으로 출시 불가) → ❌ Kill

### 개발 트랙 추가
- [ ] `[AI]` 제품 컨셉 문서 (핵심 기능, 타겟, 차별점)
- [ ] `[AI]` 관리자 우선순위 결정 (서비스 > 관리자 / 관리자 ≥ 서비스 / 동등)
- [ ] `[AI]` 산출물: `{folderMap.product}/{project}/YYYY-MM-DD-s2-concept.md`

### Human 검증 항목 (AI는 계획서 작성까지)
- [ ] `[Human]` Mom Test 인터뷰 15명+ (과거 행동만 기록) — AI가 인터뷰 가이드/질문지 작성
- [ ] `[Human]` Pretotype 실행 (50명+, 20%+ 전환) — AI가 실행 계획서 작성

### 콘텐츠 트랙 추가
- [ ] `[AI]` 채널 전략 (플랫폼, 형식, 주기)
- [ ] `[AI]` 산출물: `{folderMap.content}/{project}/YYYY-MM-DD-s2-channel-strategy.md`

---

## S3 Design Document DoD

### 공통
- [ ] `[AI]` User Story 10개+ (Acceptance Criteria 포함)
- [ ] `[AI]` User Flow Diagram 완성
- [ ] `[AI]` KPI + Success Criteria 정의
- [ ] `[Human]` [STOP] 이해관계자 리뷰 + 승인

### 앱/웹 (PRD)
- [ ] `[AI]` PRD 전체 섹션 완성
- [ ] `[AI]` 기술 스택 선정 + 정당화
- [ ] `[AI]` **PPT 버전 생성** (`.pptx` 파일)
- [ ] `[AI]` 관리자 기능 포함 여부 확인 + 포함 시 관리자 섹션 작성
- [ ] `[AI]` 산출물: `{folderMap.product}/{project}/YYYY-MM-DD-s3-prd.md` + `.pptx`

### 게임 (GDD)
- [ ] `[AI]` GDD 10개 섹션 완성 (gdd-template.md 기준)
- [ ] `[AI]` 코어 루프 + 밸런싱 수치 명시
- [ ] `[AI]` **PPT 버전 생성** (`.pptx` 파일)
- [ ] `[AI]` 관리자/운영 도구 기능 포함 여부 확인
- [ ] `[AI]` 산출물: `{folderMap.product}/{project}/YYYY-MM-DD-s3-gdd.md` + `.pptx`

### 콘텐츠 (대본/구성안)
- [ ] `[AI]` 콘텐츠 유형별 대본 완성
- [ ] `[AI]` SEO 메타데이터 포함
- [ ] `[AI]` 산출물: `{folderMap.content}/{project}/YYYY-MM-DD-s3-script.md`

---

## S4 Planning Package DoD (개발 트랙)

### 7대 산출물 완성 확인
- [ ] `[AI]` **상세 기획서**: 화면별 동작 + 데이터 흐름 완성
- [ ] `[AI]` **사이트맵**: 계층 구조 + 네비게이션 흐름 완성
- [ ] `[AI]` **로드맵**: Now/Next/Later + RICE 우선순위 완성
- [ ] `[AI]` **상세 개발 계획**: 기술 스택 + C4 아키텍처 + ADR + **Trine 세션 로드맵** 완성
- [ ] `[AI]` **WBS**: Story Point 기반 작업 분해 완성
- [ ] `[AI]` **UI/UX 기획서**: 와이어프레임 + 컴포넌트 스펙 + 인터랙션 패턴 완성
- [ ] `[AI]` **테스트 전략서**: 테스트 계층/비율, FE/BE 도구, 시딩 전략, 커버리지 목표 완성

### 모바일 UI/UX 완성 확인
- [ ] `[AI]` 모바일 네비게이션 패턴 결정 + 선택 근거 명시
- [ ] `[AI]` 주요 화면 모바일 와이어프레임 포함 (데스크톱+모바일 병기)
- [ ] `[AI]` 터치 인터랙션 정의 (제스처 목록 + 터치 타겟 48x48dp 이상)
- [ ] `[AI]` 제스처에 버튼 대체 수단 제공 (WCAG 2.5.1)
- [ ] `[AI]` Safe Area 대응 명시 (iOS notch/Home Indicator, Android system bars)
- [ ] `[AI]` 모바일 폼 키보드 타입(`inputMode`) 지정 (폼 화면 해당 시)

### 관리자 산출물 (해당 시)
- [ ] `[AI]` 관리자 상세 기획서 완성
- [ ] `[AI]` 관리자 사이트맵 완성
- [ ] `[AI]` 관리자 UI/UX 기획서 완성
- [ ] `[AI]` 로드맵/개발 계획/WBS에 관리자 기능 통합 반영

### Trine 세션 로드맵 확인
- [ ] `[AI]` 세션별 범위 정의 (기능 단위)
- [ ] `[AI]` 세션별 Spec/Plan/Task 문서명 명시 (프로젝트 네이밍 규칙 준수)
- [ ] `[AI]` 관리자 세션 포함 (해당 시)

### Trine 연동 확인
- [ ] `[AI]` 기획 패키지 → Trine Phase 1 입력으로 사용 가능
- [ ] `[AI]` S3 기획서 → Trine Phase 1.5/2 입력으로 사용 가능
- [ ] `[Human]` [STOP] 승인 후 Trine 세션 시작 안내

---

## S4 Production Guide DoD (콘텐츠 트랙)

### 유튜브/롱폼
- [ ] `[AI]` 제작 가이드 완성 (촬영 체크리스트 + 편집 지침)
- [ ] `[AI]` SEO 전략 완성 (키워드 + 메타데이터)
- [ ] `[AI]` 썸네일 가이드 완성
- [ ] `[AI]` 배포 캘린더 완성
- [ ] `[AI]` 산출물: `{folderMap.content}/{project}/YYYY-MM-DD-s4-production-guide.md`

### 쇼폼
- [ ] `[AI]` 배포 캘린더 완성
- [ ] `[AI]` 해시태그 전략 완성
- [ ] `[AI]` 산출물: `{folderMap.content}/{project}/YYYY-MM-DD-s4-deployment-calendar.md`

---

## 게이트 로그

각 [STOP] 게이트 통과 시 프로젝트 폴더의 `gate-log.md`에 자동 기록한다.

| 기록 항목 | 설명 |
|---------|------|
| Stage | S1 / S2 / S3 / S4 |
| 결과 | ✅ PASS / 🔄 수정 후 통과 / ❌ 반려 |
| 일자 | YYYY-MM-DD |
| 조건 | 충족된 DoD 요약 또는 Go/No-Go 점수 |
| 비고 | 수정 횟수, 특이사항, Human 코멘트 |

---

## 사용법

1. 각 [STOP] 게이트 진입 전 해당 Stage DoD를 점검한다
2. `[AI]` 항목은 AI가 자동 검증, `[Human]` 항목은 Human 확인 필요
3. 체크리스트 항목을 모두 충족해야 게이트 통과 (`[Human]` 항목은 계획서 작성 완료로 갈음 가능)
4. 미충족 항목이 있으면 해당 Stage 재작업
5. Go/No-Go는 S2 게이트에서만 실행 (S1은 리뷰, S3/S4는 품질 검증)
6. 게이트 통과 시 gate-log.md에 결과를 기록한다
