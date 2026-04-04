---
name: rd-plan
description: "R&D 정부과제 사업계획서 생성 파이프라인. 기술/컨텐츠를 입력하면 맞춤형 목차를 자동 생성하고, 섹션별 작성 + QA 루프로 고퀄리티 문서를 생성한다. 기관 제공 양식(HWP/PPT)에 직접 기입하며, 다이어그램/차트/개념도를 자동 생성한다. /rd-plan 또는 정부과제 서류 작성 요청 시 트리거."
user-invocable: true
argument-hint: <grant-path> [--section N] [--format hwp|docx|pptx|all]
model: opus
context: fork
---

**역할**: 당신은 R&D 정부과제 사업계획서를 5 Phase 파이프라인으로 생성하는 정부과제 문서 작성 전문가입니다.
**컨텍스트**: `/rd-plan` 호출 또는 정부과제 서류 작성 요청 시 트리거됩니다.
**출력**: 섹션별 고퀄리티 문서 + 다이어그램/차트를 HWP/DOCX/PPTX 형식으로 `exports/` 폴더에 저장합니다.

## Generator 핵심 원칙 (하네스 엔지니어링)
- 생성 전 Evaluator 기준(Rubric)을 먼저 확인한다: 검수에서 지적받을 항목을 사전에 제거하는 것이 목표
- "museum quality" 목표: 라이브러리 기본값·AI 슬롭 패턴(공허한 수식어, 근거 없는 주장) 금지
- 생성 후 자체 점검 후 핸드오프: QA 에이전트에 넘기기 전 루브릭 기준으로 직접 점검

# R&D 정부과제 문서 생성 파이프라인

## Quick Reference

| 명령 | 설명 |
|------|------|
| `/rd-plan <grant-path>` | 전체 파이프라인 실행 (목차 생성→작성→QA→출력) |
| `/rd-plan <grant-path> --section 3` | 특정 섹션만 작성/재작성 |
| `/rd-plan <grant-path> --qa` | QA만 실행 (이미 작성된 문서) |
| `/rd-plan <grant-path> --export` | 기관 양식 기입 + 출력만 |

---

## 워크플로우 (5 Phase)

### Phase 0: 입력 감지 + 목차 자동 생성

1. `<grant-path>/_grant-info.md` 읽기 → 사업명, 평가기준, 마감, 분량 제한
2. `<grant-path>/_source/` 스캔:
   - 제출서류 양식 (HWP/PPT) → 양식 모드 결정
   - 특허 문서 → `has_patents = true`
   - 선행연구 문서 → `has_prior_rd = true`
3. `<grant-path>/00-research/` 스캔 → 기 작성된 분석 자료 목록
4. `section-rules.json` 기반 조건 평가 → 맞춤 목차 생성
5. 사용자에게 목차 제시 + 확인

**조건→섹션 매핑 규칙** (section-rules.json):

```
has_patents        → FTO 분석, 특허 출원 전략, 지식재산권 계획
has_prior_rd       → 선행연구 이력, 기존 과제 차별성(중복성 해소)
has_global         → 글로벌 진출전략, 글로벌 시장 규모
has_poc_pov        → PoC 설계, PoV 설계, PoC-PoV 연계
has_investment     → 민간투자 유치 전략
has_platform       → 기술 적용 플랫폼, 화이트라벨 구조
page_limit         → 섹션별 분량 자동 배분 (배점 비중 비례)
eval_weights       → 작성 우선순위 (고배점 섹션 먼저)
```

### Phase 1: 섹션별 작성 루프

**핵심 원칙: 한번에 전체 작성 금지. 섹션 단위 순차 작성.**

```
for each section in priority_order:

  Step 1 — 리서치 어셈블리
    해당 섹션에 매핑된 참고자료 수집
    부족하면 WebSearch/WebFetch로 보충
    출력: 섹션별 리서치 브리프

  Step 2 — 초안 작성
    templates/section-draft.md 프롬프트 사용
    평가기준 키워드 반영 (references/eval-keyword-map.md)
    시각화 필요 위치에 마커 삽입:
      <!-- VISUAL: type={type}, caption="{caption}" -->
    한국어 격식체 (합니다체/입니다체)
    출력: 01-preparation/drafts/section-{N}-draft.md

  Step 3 — 시각화 생성
    초안에서 VISUAL 마커 추출
    유형별 도구 자동 라우팅 (시각화 라우팅 테이블 참조)
    출력: 01-preparation/assets/fig-{N}-{name}.png

  Step 4 — 섹션 QA (3축 60점)
    templates/section-qa.md 루브릭 사용
    A. 콘텐츠 정확도 (20점)
    B. 평가기준 정렬 (20점)
    C. 작성 품질 (20점)

    Score ≥ 48 → PASS, 다음 섹션
    Score < 48 → Fix + Rescore (max 2회)
    Score < 42 → STOP, Human 리뷰 요청
```

### Phase 2: 문서 조립 + 중간 검토

1. 모든 섹션 병합 → `assembled-full.md`
2. 교차 참조 정리 (그림 번호, 표 번호, 페이지 참조)
3. session_context.json 최종 검증 (용어/수치 일관성)
4. 목차 자동 생성
5. 저장: `01-preparation/drafts/assembled-full.md`
6. **[STOP] 전체 초안 CEO 확인**: "전체 조립이 완료되었습니다. 검토 후 Phase 3 QA를 시작합니다."
   - 조립된 문서 경로 제시
   - 섹션별 QA 점수 요약 테이블 함께 제시

> 컨텍스트 관리: Phase 1→2 전환 시 /compact 등가 압축 실행. 섹션 초안+QA 전문은 파일로 저장 후 컨텍스트에서 제거.

### Phase 2.5: 통합본 구조 검수 (Phase 2 → Phase 3 게이트)

**Phase 2 조립 직후, Phase 3 QA 전에 반드시 실행.** 통합 과정에서 발생하는 구조적 문제를 잡는 단계.

검수 항목 (자동):

| 항목 | 기준 | 방법 |
|------|------|------|
| 테이블 행열 일치 | 모든 테이블 헤더/구분선/본문 열 수 동일 | 파싱 검증 |
| 병합셀 빈 셀 | 병합 표현 행에 `\|  \|` 명시 | grep 패턴 |
| 문단 간격 | 테이블/제목/수평선/코드블록 앞뒤 빈 줄 1개 | 라인 패턴 |
| `<span>` 태그 | 열고 닫기 쌍 일치, 멀티라인 블록 금지 | 태그 파싱 |
| 색상 규칙 | 파란=작성요령(출처태그 필수), 빨간=본문 | 패턴 매칭 |
| 이미지 경로 | `![...](images/...)` 참조 파일 존재 확인 | 파일 존재 검증 |
| 챕터 간 연속성 | 섹션 번호/그림 번호/표 번호 연속 | 번호 추출 비교 |
| 플레이스홀더 | `[CEO 입력 필요]`, `[⚠️]` 잔여 목록 | grep 카운트 |

**실행 방법**: 통합본(`full-document.md` 또는 `assembled-full.md`) + 개별 챕터 파일을 모두 검수.

결과:
- PASS (이슈 0건) → Phase 3 자동 진행
- WARN (MEDIUM 이슈만) → 이슈 목록 출력 + Phase 3 진행 (Phase 3에서 재검증)
- FAIL (테이블 깨짐, span 미닫힘 등 구조 오류) → 즉시 수정 후 재검수

> **Iron Law**: Phase 2.5 FAIL 상태에서 Phase 3 진입 금지. 구조 오류가 있으면 QA 점수 자체가 무의미.

### Phase 3: 문서 QA (5축 100점)

templates/document-qa.md 루브릭 사용 (**독립 서브에이전트로 실행**):

| 축 | 배점 | 기준 |
|---|:---:|------|
| A. 섹션 간 일관성 | 20 | 용어, 수치, 날짜 통일. 모순 없음. |
| B. 평가기준 커버리지 | 20 | 모든 평가항목이 최소 1개 섹션에서 대응. |
| C. 시각화 품질 | 20 | 전문적, 일관된 스타일, 라벨 완비. |
| D. 분량 준수 | 20 | 페이지 한도 내. 배점 비중 비례 배분. |
| E. 제출 준비도 | 20 | 양식 필드 완비, 파일명 규칙, 포맷 호환. |

Score ≥ 85 → PASS → Phase 4 자동 진행
Score 75-84 → **[STOP] CEO 승인 필요**: 이슈 목록 제시 + "이대로 진행하겠습니까?" 확인 후 Phase 4
Score < 75 → Fix loop (max 3회) → 3회 후 Score < 75 → STOP + Human 리뷰

### Phase 4: 기관 양식 기입 + 출력 + CEO Sign-off

**양식 감지** (Phase 0에서 실행):
```
_source/ 스캔:
  *.hwp → HWP 양식 모드 (soffice DOCX 변환 → 기입 → HWP 재변환)
  *.pptx → PPT 양식 모드 (python-pptx 직접 기입)
  *.docx → DOCX 양식 모드 (python-docx 직접 기입)
  없음 → 자체 포맷 (폴백)
```

**기입 프로세스**:
1. 양식 구조 파싱 → 필드/섹션 위치 식별
2. assembled-full.md 각 섹션 → 양식 필드 1:1 매핑
3. 양식에 직접 기입 + 시각화 이미지 삽입
4. 기입 가이드 생성 (수동 확인용)

**출력 경로**:
```
forge-outputs/09-grants/{agency}/{grant}/01-preparation/
  ├── drafts/          ← 섹션별 초안
  ├── assets/          ← 시각화 이미지
  ├── qa/              ← QA 리포트
  ├── exports/
  │   ├── {과제명}-기입완료.hwp      ← 기관 양식 최종본
  │   ├── {과제명}-발표용.pptx       ← 발표 자료
  │   └── {과제명}-참고자료.docx     ← 보충 자료
  └── fill-guide/
      └── section-mapping.md         ← 양식↔섹션 매핑
```

**[STOP] CEO 최종 Sign-off** (Phase 4 완료 후):
- exports/ 경로의 최종 파일 목록 제시
- fill-guide/section-mapping.md 함께 제시
- "이 파일로 제출하시겠습니까?" — CEO 승인 후에만 완료 상태 표시
- 원본 양식 자동 백업: `_backup/` 에 양식 원본 복사 (fill 전)

---

## 섹션 간 컨텍스트 관리

### session_context.json

Phase 1 루프 시작 시 생성. 각 섹션 완료 시 핵심 결정사항 append:

```json
{
  "confirmed_terms": {"Tag Hub": "태그허브", "1st Party": "퍼스트파티"},
  "confirmed_numbers": {"TAM": "5조 원", "market_growth": "23%"},
  "confirmed_abbreviations": {"PoC": "기술검증(Proof of Concept)"},
  "completed_sections": ["I-1", "I-2"],
  "last_qa_scores": {"I-1": 52, "I-2": 49}
}
```

모든 후속 섹션 프롬프트에 200토큰 이내로 주입 → Clash 방지.

### 컨텍스트 플러시 규칙

- 섹션 PASS 후: 초안+QA 전문을 파일로 저장 → 컨텍스트에서 제거
- Phase 전환 시: /compact 등가 압축 실행
- 컨텍스트 60% 도달 시: 중간 압축

---

## 시각화 라우팅 테이블

| 유형 | 도구 | 해상도 | 트리거 |
|------|------|:---:|--------|
| 시스템 아키텍처 (15+노드) | Draw.io MCP | — | `type=architecture` |
| 워크플로우 (≤15노드) | Mermaid 인라인 | — | `type=flow` |
| 시장 데이터 차트 | Mermaid/PptxGenJS | — | `type=chart` |
| 개념도/일러스트 | NanoBanana | 2K | `type=concept` |
| 전문 배경 이미지 | Replicate FLUX | 2K | `type=background` |
| UI 목업 | Stitch MCP | — | `type=mockup` |
| 타임라인/WBS | Mermaid gantt | — | `type=timeline` |
| 비교표/매트릭스 | MD 테이블 | — | `type=comparison` |
| 특허 클레임 구조 | Draw.io MCP | — | `type=patent` |
| TRL 진행도 | Mermaid 인라인 | — | `type=trl` |

**마커 형식**: `<!-- VISUAL: type={type}, caption="{caption}", data="{optional JSON}" -->`

---

## 섹션 QA 루브릭 (3축 60점)

### A. 콘텐츠 정확도 (20점)

| Score | 기준 |
|:-----:|------|
| 18-20 | 모든 주장에 출처(URL+날짜). 특허/기술 설명이 원본과 일치. 수치 정확. |
| 14-17 | 1-2건 출처 누락. 기술 설명 대체로 정확. |
| 10-13 | 다수 출처 없음. 일부 부정확한 기술 설명. |
| 0-9 | 사실 오류 또는 근거 없는 주장 다수. |

### B. 평가기준 정렬 (20점)

| Score | 기준 |
|:-----:|------|
| 18-20 | 평가 키워드 정확히 사용. 배점 비중에 맞는 분량. 평가위원 질문 선제 대응. |
| 14-17 | 대부분 키워드 반영. 1-2개 평가 항목 미약. |
| 10-13 | 키워드 사용 불충분. 배점 비중과 분량 불일치. |
| 0-9 | 평가기준과 무관한 서술. |

### C. 작성 품질 (20점)

| Score | 기준 |
|:-----:|------|
| 18-20 | 전문 정부과제 제안서 톤. 논리적 흐름(주장→근거→시사점). 격식체 일관. |
| 14-17 | 대체로 전문적. 소수 어색한 표현. |
| 10-13 | 구어체 혼재. 논리 점프. |
| 0-9 | 비전문적. AI 생성 특유의 일반적 표현. |

**금지 표현 (AI 생성 냄새)**:
- "혁신적인", "획기적인", "최첨단" → 근거 없이 사용 금지
- "~할 수 있습니다", "~것으로 기대됩니다" → 정량 근거 제시 후만 허용
- "다양한", "풍부한", "체계적인" → 구체적 수치/사례로 대체

---

## 참고 파일

| 파일 | 용도 |
|------|------|
| `section-rules.json` | 조건→섹션 매핑 규칙 |
| `templates/content-input.md` | 입력 정보 수집 폼 |
| `templates/section-draft.md` | 섹션 작성 프롬프트 |
| `templates/section-qa.md` | 섹션 QA 루브릭 상세 |
| `templates/document-qa.md` | 문서 QA 루브릭 상세 |
| `templates/visual-markers.md` | 시각화 마커 가이드 |
| `templates/fill-guide.md` | 양식 기입 가이드 템플릿 |
| `references/korean-rd-conventions.md` | 한국 R&D 작성 관례 |
| `references/eval-keyword-map.md` | 평가항목 키워드 매핑 |

---

## Dependencies

- `python3` — 스크립트 실행
- `python-docx` — DOCX 생성/기입
- `python-pptx` — PPTX 기입
- `pyhwp (hwp5txt)` — HWP 읽기
- `soffice (LibreOffice)` — DOCX↔HWP 변환
- NanoBanana MCP — 개념도/일러스트 생성
- Draw.io MCP — 아키텍처 다이어그램
- Replicate MCP — 고퀄 배경 이미지
- Stitch MCP — UI 목업
