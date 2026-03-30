# 공식 문서 작성 파이프라인 (전역)

> 정부과제 계획서, 제안서, IR 덱, 기획서 등 공식 문서 작성 시 적용.
> 시각화 도구 선택은 docs-visualization.md 참조.

## 파이프라인 구조

Phase 0: 디자인 디렉션 → Phase 1~N: 본문 작성 → Phase Q: 품질 검증 → Phase F: 포맷 변환

### Phase 0: 디자인 디렉션 (본문 작성 전 필수)

진입 시나리오 판별:
  A. 기존 에셋 있음 → /style-train Mode A (스타일 추출) → P0
  B. 신규, 레퍼런스 있음 → P1 (Art Direction Brief)
  C. 백지 시작 → 벤치마크 → P1

0-1. 기존 스타일 추출
  → /style-train Mode A (보유 에셋에서 추출)
  → 산출물: 기존 시각 언어 분석

0-2. 업계 벤치마크 (WebSearch + WebFetch + /screenshot-analyze)
  → 소스: 보유 IR/제안서 + 웹 우수사례 + 디자인 트렌드
  → 산출물: 벤치마크 분석 리포트

0-3. style-guide.md 작성
  → 템플릿: planning/templates/style-guide-template.md
  → 기존 정체성 계승 + 업계 최고 수준 업그레이드
  → 디자인 토큰: shared/design-tokens/instagram-default.json 기반

0-4. art-direction-brief.md 작성
  → 템플릿: planning/templates/art-direction-brief-template.md
  → 감성 키워드 3개 + 안티패턴 + 무드보드 → AI 자율 결정 (기존 토큰 기반)

0-5. 프로토타입 3~5개 시험 생성
  → /game-asset-generate → /asset-critic → 4점+ 자동 PASS

### Phase 1~N: 본문 작성 (챕터별 순차)

작성 규칙:
  - 색상 가이드라인(파란/빨간 등) 준수 → 본문에 마킹 유지
  - 소스 문서 재사용 원칙 (기존 문서 최대 활용, 타 사업명 제거)
  - CEO/Human 필수 항목 → [CEO 입력 필요: ...] 플레이스홀더
  - 기술 정확성: context7 MCP로 프레임워크/프로토콜 스펙 검증

시각화 생성:
  1. /library-search → Prefab Visual Library 우선 탐색
  2. /game-asset-generate → 오케스트레이터 (/soul-prompt-craft + MCP 라우팅)
  3. /asset-critic → 6축 크리틱 (4점 미만 재생성)
  ※ 도구 유형 판별: docs-visualization.md 자동 라우팅

포맷 규칙 (docx 변환 대비):
  - 색상: `<span style="color:red/blue">...</span>` HTML 태그
  - 이미지: 모든 시각화 .png → `![캡션](images/filename.png)`
  - 표: 마크다운 파이프 테이블
  - 제목: ##/###/#### → Heading 1/2/3
  - 페이지 경계: --- (수평선)

### Phase Q: 품질 검증 (3단 분리) ★ Phase F 전에 반드시 완료

**Iron Law: Phase Q를 통과하지 않으면 Phase F(포맷 변환) 진입 금지.**

Q-1. 경량 자동 검증 (각 Wave 완료 직후)
  → 용어 통일: grep 금지표현 검출 (0건 필수)
  → 빨간색 매핑: I↔II 1:1 대응 확인
  → 분량 적정성: 목표 자수 ±20%
  → 시각화: /asset-critic (에셋별, 6축 평균 4.0+)

Q-2. 내용 종합 검증 (전체 본문 완성 후)
  → rd-plan QA 루브릭 5축 100점 (목표 80+)
    A. 섹션 간 일관성 (20점)
    B. 평가기준 커버리지 (20점)
    C. 시각화 품질 (20점)
    D. 분량 준수 (20점)
    E. 제출 준비도 (20점)

Q-3. 교차 검수 (Q-2와 병렬 실행)
  → Agent Teams 4팀 병렬 (논리/배점/정합성/분량)
  → CRITICAL 0건, HIGH 미해소 0건

Q-4. 수정 루프 (Q-2 + Q-3 결과 기반)
  → CRITICAL/HIGH 이슈 즉시 수정
  → 수정 후 해당 항목 재검증
  → 재검증 PASS 후에만 Phase F 진입

### Phase F: 포맷 변환 (Phase Q PASS 후에만 진입)

원칙: pandoc 블랙박스 변환 금지. python 스크립트로 요소별 프로그래매틱 빌드.

한글 폰트:
  - 제목: Pretendard Bold / 본문: Pretendard Medium / 표: KoPub돋움체
  - w:eastAsia 속성 명시 → 한글 폰트 폴백 방지
  - WSL + Windows 양쪽 설치 필수

F-1. md → docx (shared/scripts/md-to-docx.py)
  → python-docx 직접 빌드: 색상 RGBColor, 이미지 InlineShape, 표 Table 객체
  → 챕터별 분할 변환 (대용량 누락 방지)

F-2. 정합성 자동 검증 (shared/scripts/doc-conversion-verify.py)
  → md↔변환물 10항목 자동 비교 (글자수/제목수/표수/이미지수/색상수/한글깨짐/폰트/해상도)
  → 1건이라도 FAIL → 변환 재실행

## AI 행동 규칙

1. 공식 문서 작성 요청 시 style-guide.md 존재를 먼저 확인한다
2. 미존재 시 Phase 0부터 시작을 제안한다
3. 시각화 생성 전 /library-search로 기존 에셋을 먼저 탐색한다
4. MCP 직접 호출 대신 스킬 오케스트레이터를 사용한다
5. 에셋 생성 후 /asset-critic 크리틱을 반드시 실행한다
6. 기술 설명 작성 시 context7로 스펙 정확성을 검증한다
7. **Phase Q를 스킵하지 않는다 — Phase Q PASS 전에 Phase F 진입 금지**
8. **Phase Q에서 CRITICAL/HIGH 발견 시 즉시 수정 → 재검증 → PASS 후 Phase F**
9. **실행 순서: Phase 0 → 1~N → Q(검수) → Q-4(수정루프) → F(변환). 이 순서를 절대 바꾸지 않는다**

---

*Last Updated: 2026-03-27*
