# 리소스 매니페스트 — GodBlade 뽑기 시스템

> 프로젝트에서 AI로 생성/관리하는 모든 에셋의 추적 문서.
> 에셋 추가/수정 시 이 매니페스트를 업데이트한다.

## 메타데이터

| 항목 | 값 |
|------|-----|
| 프로젝트 | GodBlade 뽑기 시스템 (NewGachaPattern) |
| 스타일 가이드 | `05-design/projects/godblade/style-guide.md` |
| Art Direction Brief | `05-design/projects/godblade/art-direction-brief.md` |
| LoRA 모델 | 없음 (P3 이후 검토) |
| 최종 업데이트 | 2026-03-17 |

## 에셋 목록

### P2 프로토타입 (채택본 — 1차 FLUX)

| # | 에셋명 | 유형 | 도구 | 시드 | 프롬프트 (요약) | 버전 | 경로 | 상태 |
|:-:|--------|------|------|:----:|---------------|:----:|------|:----:|
| 1 | chest-opening-concept | bg/fx | FLUX 1.1 Pro | 15356 | 상자 개봉 + 금빛 폭발 + 시안 룬 + 파란 횃불 | v1 | `_assets/p2-01-chest-opening-concept.png` | ⬜ |
| 2 | card-grid | ui | FLUX 1.1 Pro | 50198 | 카드 10장 뒤집기 전 + 2x5 배치 + 제단 | v1 | `_assets/p2-02-card-grid.png` | ⬜ |
| 3 | pair-match | fx | FLUX 1.1 Pro | — | 짝 맞추기 번개 + 쌍검 글로우 | v1 | `_assets/p2-03-pair-match.png` | ⬜ |
| 4 | result | ui/fx | FLUX 1.1 Pro | — | 당첨 결과 + 금빛 폭발 + 보라 검 카드 | v1 | `_assets/p2-04-result.png` | ⬜ |
| 5 | village-ui | ui | FLUX 1.1 Pro | 28048 | 마을 하단 UI + 8버튼 + 캐릭터 | v1 | `_assets/p2-05-village-ui.png` | ⬜ |

### P3 대량 생산

| # | 에셋명 | 유형 | 도구 | 프롬프트 (요약) | 버전 | 경로 | 상태 |
|:-:|--------|------|------|---------------|:----:|------|:----:|
| 6 | effect-white | fx | Gemini 3 Pro | 1-3성 흰색 번개 + 글로우 | v1 | `_assets/p3-01-effect-white.png` | ⬜ |
| 7 | effect-green | fx | Gemini 3 Pro | 4-6성 초록 번개 + 글로우 | v1 | `_assets/p3-02-effect-green.png` | ⬜ |
| 8 | effect-blue | fx | Gemini 3 Pro | 7-9성 파랑 번개 + 글로우 | v1 | `_assets/p3-03-effect-blue.png` | ⬜ |
| 9 | effect-red | fx | Gemini 3 Pro | 10-11성 빨강 번개 + 글로우 | v1 | `_assets/p3-04-effect-red.png` | ⬜ |
| 10 | special-chest | bg/fx | Gemini 3 Pro | 소프트 피티 스페셜 상자 | v1 | `_assets/p3-05-special-chest.png` | ⬜ |
| 11 | row-reset-popup | ui/fx | Gemini 3 Pro | Row 소진 새 패턴 시작 팝업 | v1 | `_assets/p3-06-row-reset-popup.png` | ⬜ |
| 12 | button-states | ui | Gemini 3 Pro | 한번더/상점가기/모두열기 3상태 | v1 | `_assets/p3-07-button-states.png` | ⬜ |

### P2 프로토타입 (대안본 — Gemini, _archive/)

| # | 에셋명 | 도구 | 경로 | 비고 |
|:-:|--------|------|------|------|
| 1 | chest-opening-concept | Gemini 3 Pro | `_assets/p2-01-chest-opening-concept-gemini.png` | 스타일라이즈드 감성 강점 |
| 2 | card-grid | Gemini 3 Pro | `_assets/p2-02-card-grid-gemini.png` | 용 엠블럼 카드 뒷면 |
| 3 | pair-match | Gemini 3 Pro | `_assets/p2-03-pair-match-gemini.png` | 픽셀아트 아이템 + 번개 |
| 4 | result | Gemini 3 Pro | `_assets/p2-04-result-gemini.png` | "획득!" 텍스트 + 보라 검 |
| 5 | village-ui | Gemini 3 Pro | `_assets/p2-05-village-ui-gemini.png` | 캐릭터 + 7버튼 |

### P2 프로토타입 (대안본 — FLUX v2)

| # | 에셋명 | 도구 | 시드 | 경로 | 비고 |
|:-:|--------|------|:----:|------|------|
| 2 | card-grid | FLUX 1.1 Pro | 14367 | `_assets/p2-02-card-grid-v2.png` | 퀄리티 저하 |
| 4 | result | FLUX 1.1 Pro | 36068 | `_assets/p2-04-result-v2.png` | 퀄리티 저하 |
| 5 | village-ui | FLUX 1.1 Pro | 35966 | `_assets/p2-05-village-ui-v2.png` | 퀄리티 저하 |

### 기존 에셋 (Diamond 이전)

| # | 에셋명 | 유형 | 도구 | 경로 | 상태 |
|:-:|--------|------|------|------|:----:|
| 6 | bg-title | bg | NanoBanana | `_assets/bg-title.png` | ✅ |
| 7 | bg-section | bg | NanoBanana | `_assets/bg-section.png` | ✅ |
| 8 | illust-gacha | illust | NanoBanana | `_assets/illust-gacha.png` | ✅ |
| 9 | gacha-cards-facedown | ui | Stitch | `_assets/gacha-ui-mockups/gacha-cards-facedown-10slot.png` | ✅ |
| 10 | gacha-miss | ui | Stitch | `_assets/gacha-ui-mockups/gacha-miss-next-time-smoke.png` | ✅ |
| 11 | gacha-pair-match | ui | Stitch | `_assets/gacha-ui-mockups/gacha-pair-match-lightning-glow.png` | ✅ |
| 12 | gacha-win | ui | Stitch | `_assets/gacha-ui-mockups/gacha-win-acquired-golden-burst.png` | ✅ |

### 상태 정의

| 상태 | 의미 |
|:----:|------|
| ✅ | 확정 (Human 승인 완료) |
| ⬜ | 검토 대기 |
| 🔄 | 수정 중 (피드백 반영 대기) |
| ❌ | 폐기 (대체 에셋으로 교체됨) |

## 시드 블랙리스트

| 도구 | 시드 | 프롬프트 요약 | 사유 |
|------|:----:|-------------|------|
| FLUX | 14367 | card grid v2 | 퀄리티 저하 |
| FLUX | 36068 | result v2 | 퀄리티 저하 |
| FLUX | 35966 | village-ui v2 | 퀄리티 저하 |

## 일관성 검증 이력

| 날짜 | 검증 범위 | 결과 | 불일치 항목 | 조치 |
|------|----------|:----:|-----------|------|
| 2026-03-17 | P2+P3 전체 (12장) | WARN | P2(FLUX)↔P3(Gemini) 아트 스타일 미세 차이 | 시안 용도로 허용. 실제 구현은 Unity 코드 에셋으로 별도 제작 |

## 버전 히스토리

| 버전 | 날짜 | 변경 내용 |
|:----:|------|----------|
| v1 | 2026-03-17 | P2 프로토타입 5장 생성 (FLUX 채택, Gemini/v2 대안 보존) |

---

*스타일 가이드 버전: 2026-03-17*
