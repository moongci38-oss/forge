# GodBlade 뽑기 시스템 — Diamond Architecture 리소스 파이프라인 실행

> 실행 완료: 2026-03-17 | Human 전체 승인 완료

## Context

GodBlade 뽑기 시스템의 UI 시안(Stitch 목업 4장 + NanoBanana 배경/일러스트 3장)이 Diamond Architecture 도입 이전에 생성되었다. 새 리소스 파이프라인(P0→P4)으로 재정비하여 **style-guide.md → art-direction-brief.md → 프로토타입 검증 → 대량 생성 → resource-manifest.md** 체계를 갖춘다.

### 현재 상태

| 에셋 | 위치 | 유형 |
|------|------|------|
| `bg-title.png` | `_assets/archive/` | NanoBanana 배경 (PPT용) |
| `bg-section.png` | `_assets/archive/` | NanoBanana 배경 (PPT용) |
| `illust-gacha.png` | `_assets/archive/` | NanoBanana 일러스트 (PPT용) |
| `gacha-cards-facedown-10slot.png` | `_assets/archive/gacha-ui-mockups/` | Stitch 목업 |
| `gacha-miss-next-time-smoke.png` | `_assets/archive/gacha-ui-mockups/` | Stitch 목업 |
| `gacha-pair-match-lightning-glow.png` | `_assets/archive/gacha-ui-mockups/` | Stitch 목업 |
| `gacha-win-acquired-golden-burst.png` | `_assets/archive/gacha-ui-mockups/` | Stitch 목업 |
| `꽝화면참고스샷.png` | dev project gacha/ | 레퍼런스 스크린샷 |

---

## 진입 시나리오 판정: **Scenario A** (기존 에셋 7개 존재)

기존 7개 에셋에서 스타일을 추출하는 P0부터 시작한다.

---

## Phase 실행 계획

### P0: 스타일 정의 (수렴)

**입력**: 기존 7개 에셋 이미지
**도구**: `/screenshot-analyze` (기존 에셋 분석) + `style-train` 스킬
**산출물**: `05-design/projects/godblade/style-guide.md`

1. 기존 7개 에셋을 `/screenshot-analyze`로 일괄 분석 — 컬러 팔레트, 아트 스타일 키워드, 일관성 패턴 추출
2. GDD 섹션 8 (연출 기획) + 스토리보드의 RGB 색상 체계 참조:
   - 1-3성: RGB 255,255,255 (흰)
   - 4-6성: RGB 146,208,80 (초록)
   - 7-9성: RGB 0,176,240 (파랑)
   - 10-11성: RGB 204,0,0 (빨강)
3. `style-guide-template.md` 기반으로 style-guide.md 작성
4. **Gate 검증**: 컬러 5색+, 아트 키워드 3개+, 일관성 패턴 정의

### P1: 방향 설정 (수렴)

**입력**: style-guide.md + GDD + 장비뽑기연출기획서_0.2.pptx + 경쟁작 레퍼런스
**도구**: `art-direction-brief-template.md` 기반 작성
**산출물**: `05-design/projects/godblade/art-direction-brief.md`

1. 감성 키워드 3개 정의 (예: "화려한 보상감", "고대 마법 분위기", "긴장감 있는 카드 오픈")
2. 안티패턴 2개+ 정의 (예: "현대적/미니멀 UI", "카툰 스타일 이펙트")
3. 무드보드 레퍼런스 3개+ 수집 (비경쟁 도메인에서)
4. 경쟁 차별화: 기존 갓검 UI 스타일 vs 신규 뽑기 스타일 포지셔닝
5. **Gate 검증**: 감성 3개, 안티패턴 2+, 무드보드 3+

### P2: 프로토타입 (확산) — [STOP] Human 피드백

**입력**: style-guide.md + art-direction-brief.md
**도구**: NanoBanana MCP (이미지 생성), Stitch MCP (UI 목업)
**산출물**: 프로토타입 3-5개

기존 4개 Stitch 목업을 **새 스타일 가이드 기준**으로 재생성:
1. **상자 개봉 연출 컨셉** — NanoBanana (줌인+광원+플래시 장면)
2. **카드 뒤집기 + 10장 그리드** — Stitch (2x5 배치, 뒷면/앞면)
3. **짝 맞추기 이펙트** — NanoBanana (번개+글로우, 등급별 RGB 적용)
4. **결과 화면 (당첨/꽝)** — Stitch (당첨 글로우 vs 꽝 단순화)
5. **마을 하단 UI** — Stitch (좌측 6버튼 + 우측 2버튼 v0.2 레이아웃)

- 순차 1장씩 생성 → Human 확인 → 다음 생성
- **Gate 검증**: Human 방향 승인, 안티패턴 0건, 스타일 일관성 PASS

### P3: 대량 생산 (확산)

**입력**: 승인된 프로토타입 스타일
**도구**: NanoBanana MCP, Stitch MCP, `game-asset-generate` 스킬
**산출물**: 전체 에셋

P2 승인 후 나머지 에셋 생성:
- 등급별 이펙트 컨셉 (4종: 흰/초록/파랑/빨강)
- 스페셜 상자 연출 컨셉 (일반 vs 스페셜 이분)
- Row 소진 팝업 UI
- "한번 더" / "모두 열기" / "상점 가기" 버튼 상태별 UI
- PPT용 배경/일러스트 갱신 (필요 시)

### P4: 품질 검증 (수렴)

**도구**: `/screenshot-analyze` (크로스 에셋 일관성), resource-manifest 작성
**산출물**: `05-design/projects/godblade/resource-manifest.md`

1. 전체 에셋 컴포지트 이미지 생성 → `/screenshot-analyze` 일관성 검증
2. 크리틱 4항목 검증: 계층/일관성/안티패턴/브리프 정렬
3. resource-manifest.md 작성 (에셋 목록, 버전, 상태, 검증 이력)
4. `generated_imgs/` 임시 파일 정리 (이동 또는 삭제)

---

## 파일 경로

| 산출물 | 경로 |
|--------|------|
| Style Guide | `05-design/projects/godblade/style-guide.md` |
| Art Direction Brief | `05-design/projects/godblade/art-direction-brief.md` |
| Resource Manifest | `05-design/projects/godblade/resource-manifest.md` |
| Review Checklist | `05-design/projects/godblade/review-checklist.md` |
| 에셋 저장 | `02-product/projects/godblade/_assets/` (기존 구조 유지) |
| 템플릿 (참조) | `09-tools/templates/style-guide-template.md` |
| 템플릿 (참조) | `09-tools/templates/art-direction-brief-template.md` |
| 템플릿 (참조) | `09-tools/templates/resource-manifest-template.md` |
| 안티패턴 (참조) | `09-tools/templates/ai-anti-patterns.md` |

---

## 3-Tier 분류 (GodBlade 뽑기)

| Tier | 에셋 | 생성 방식 |
|:----:|------|----------|
| T1 (핵심) | 없음 — 로고/캐릭터는 기존 갓검 에셋 재사용 | Human 기존 에셋 |
| T2 (주요) | 상자 개봉, 카드 그리드, 짝 맞추기, 결과 화면, 마을 UI | AI + Human 순차 승인 |
| T3 (대량) | 등급별 이펙트 변형 (4색), 버튼 상태 변형 | AI 배치 + 샘플링 |

---

## 실행 결과 요약

| Phase | 상태 | 산출물 |
|:-----:|:----:|--------|
| P0 | ✅ | style-guide.md — 9색+4등급 팔레트, 6개 아트 키워드, 프롬프트 가이드 |
| P1 | ✅ | art-direction-brief.md — 감성 3개, 안티패턴 5개, 무드보드 5개 |
| P2 | ✅ | 프로토타입 5장 (FLUX 채택, Gemini/v2 대안 _archive/ 보존) |
| P3 | ✅ | 대량 생산 7장 (등급 이펙트 4종 + 스페셜 상자 + Row 리셋 + 버튼 상태) |
| P4 | ✅ | resource-manifest.md + 일관성 검증 + generated_imgs/ 정리 |

**Human 전체 승인**: 2026-03-17 — 시안 12개 + 문서 전체 ✅

---

## 주의사항

- **Unity 코드 에셋은 대상 아님**: Particle System, Shader, NGUI 프리팹은 Trine Phase 3에서 코드로 구현. 여기서 생성하는 것은 **기획 단계 시각 레퍼런스(시안)** 이미지만
- **1장씩 순차 생성**: P2/P3에서 병렬 생성 금지. 1장 → Human 확인 → 다음 1장
- **MCP Fallback**: Stitch 실패 → NanoBanana + 수동 목업. NanoBanana 실패 → Replicate
