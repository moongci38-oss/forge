# 시각화 마커 가이드

## 마커 형식

섹션 초안 작성 시, 시각화가 필요한 위치에 아래 마커를 삽입한다.

```html
<!-- VISUAL: type="{type}", caption="{한글 캡션}", data="{optional}" -->
```

## 라우팅 테이블

| type | 도구 | 해상도 | 설명 | 예시 |
|------|------|:---:|------|------|
| `architecture` | Draw.io MCP | — | 시스템 구조도 (15+노드) | 전체 플랫폼 아키텍처 |
| `flow` | Mermaid 인라인 | — | 워크플로우/시퀀스 (≤15노드) | 연구 절차, 데이터 흐름 |
| `chart` | Mermaid/PptxGenJS | — | 수치 데이터 차트 | TAM/SAM/SOM, 매출 전망 |
| `concept` | NanoBanana 2K | 2048px | 개념도/일러스트 | 핵심 기술 개념 |
| `background` | Replicate FLUX 2K | 2048px | PPTX 배경 이미지 | 타이틀/섹션 슬라이드 |
| `mockup` | Stitch MCP | — | UI 목업 | PoC 화면 설계 |
| `timeline` | Mermaid gantt | — | 타임라인/WBS/로드맵 | 4단계 로드맵, 6개월 WBS |
| `comparison` | MD 테이블 | — | 비교표/매트릭스 | 경쟁사 비교, 선행기술 대비 |
| `patent` | Draw.io MCP | — | 특허 클레임 구조 | 청구항 관계도 |
| `trl` | Mermaid 인라인 | — | TRL 진행도 | TRL3→TRL8 로드맵 |
| `pie` | Mermaid pie | — | 비율 차트 | 예산 배분, 시장 점유율 |
| `org` | Mermaid 인라인 | — | 조직도 | 연구팀 구성 |

## 마커 삽입 예시

```markdown
본 과제의 전체 시스템 아키텍처는 다음과 같다.

<!-- VISUAL: type="architecture", caption="K-스토리 IP 퍼스트파티 플랫폼 시스템 아키텍처" -->

모멘트 엔진은 4단계 파이프라인으로 구성된다.

<!-- VISUAL: type="flow", caption="모멘트 엔진 처리 파이프라인" -->

글로벌 팬덤 경제 시장 규모는 다음과 같이 성장하고 있다.

<!-- VISUAL: type="chart", caption="글로벌 팬덤 경제 TAM/SAM/SOM (단위: 억 원)", data="TAM=50000,SAM=8000,SOM=1200" -->
```

## 처리 프로세스

1. **감지**: 초안에서 `<!-- VISUAL:` 패턴 정규식 추출
2. **파싱**: type, caption, data 필드 분리
3. **라우팅**: type → 라우팅 테이블에서 도구 선택
4. **생성**: 해당 MCP 도구 호출
5. **삽입**: 마커를 이미지 참조(`![caption](assets/fig-N.png)`)로 교체
6. **QA**: 섹션 QA에서 시각화 품질 체크

## 이미지 품질 기준

| 용도 | 해상도 | 비율 |
|------|:---:|:---:|
| HWP A4 전폭 | 2K (2048x1536) | 4:3 |
| HWP A4 반폭 | 1K (1024x768) | 4:3 |
| PPTX 16:9 배경 | 2K (1920x1080) | 16:9 |
| 인라인 차트 | 1K | 가변 |

## NanoBanana 프롬프트 패턴

| 용도 | 프롬프트 패턴 |
|------|------------|
| 개념도 배경 | `"Minimal abstract gradient background for {topic}, corporate style, no text, clean professional"` |
| 기술 일러스트 | `"Flat illustration of {concept}, minimal style, {brand colors}, white background, vector art"` |
| 아이콘 세트 | `"Set of 4 flat icons for {topics}, consistent style, {color}, transparent background"` |

## MCP 폴백 테이블

| 도구 | 폴백 1 | 폴백 2 |
|------|--------|--------|
| Draw.io MCP 불가 | Mermaid graph (노드 수 무관, 계층 그룹 활용) | 텍스트 기반 ASCII 구조 |
| NanoBanana 불가 | Replicate FLUX | 플레이스홀더 텍스트 + `[이미지 추후 삽입]` |
| Replicate 불가 | NanoBanana | 플레이스홀더 |
| Stitch 불가 | 텍스트 기반 UI 레이아웃 설명 | — |

> Phase 0에서 MCP 연결 상태를 확인하고, 미연결 MCP는 폴백 도구로 자동 전환.

## Mermaid 스타일 규칙

- 노드 색상: Primary `#002060`, Secondary `#0070C0`, Accent `#00B0F0`
- 텍스트: 한글 우선, 영어 병기
- 방향: `graph LR` (가로) 또는 `graph TD` (세로) — 문맥에 따라
- 간트: `dateFormat YYYY-MM` — 월 단위
