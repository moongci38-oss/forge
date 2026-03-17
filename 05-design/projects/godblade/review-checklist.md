# GodBlade 뽑기 시스템 — Human Review Checklist

> Diamond Architecture 리소스 파이프라인 진행 중 Human 확인이 필요한 항목 목록.
> 확인 완료 시 상태를 업데이트한다.

---

## P0: Style Guide (수렴)

| # | 확인 항목 | 파일 경로 | 상태 |
|:-:|---------|----------|:----:|
| 1 | 컬러 팔레트 9색 + 등급별 4색 적합성 | `05-design/projects/godblade/style-guide.md` §1 | ⬜ |
| 2 | 아트 스타일 키워드 적합성 | `05-design/projects/godblade/style-guide.md` §2 | ⬜ |
| 3 | AI 프롬프트 가이드 (필수/금지 키워드) | `05-design/projects/godblade/style-guide.md` §6 | ⬜ |

## P1: Art Direction Brief (수렴)

| # | 확인 항목 | 파일 경로 | 상태 |
|:-:|---------|----------|:----:|
| 4 | 감성 키워드 3개 방향성 | `05-design/projects/godblade/art-direction-brief.md` §1 | ⬜ |
| 5 | 안티패턴 5개 적절성 | `05-design/projects/godblade/art-direction-brief.md` §2 | ⬜ |
| 6 | 무드보드 레퍼런스 5개 | `05-design/projects/godblade/art-direction-brief.md` §3 | ⬜ |
| 7 | 차별화 포인트 | `05-design/projects/godblade/art-direction-brief.md` §4 | ⬜ |

## P2: 프로토타입 (확산) — [STOP] 1장씩 순차 확인

| # | 시안 | 파일 경로 | 확인 포인트 | 상태 |
|:-:|------|----------|-----------|:----:|
| 8 | 상자 개봉 연출 컨셉 | `_assets/p2-01-chest-opening-concept.png` | 던전 분위기, 상자 디자인, 금빛 이펙트, 시안 룬 | ⬜ |
| 9 | 카드 10장 그리드 | `_assets/p2-02-card-grid.png` | 2x5 배치, 카드 뒷면, 제단 위 배치 | ⬜ |
| 10 | 짝 맞추기 이펙트 | `_assets/p2-03-pair-match.png` | 번개 연결, 등급별 RGB 글로우 | ⬜ |
| 11 | 결과 화면 (당첨/꽝) | `_assets/p2-04-result.png` | 금빛 폭발(당첨), 연기+텍스트(꽝) | ⬜ |
| 12 | 마을 하단 UI | `_assets/p2-05-village-ui.png` | 좌6+우2 버튼 v0.2 레이아웃 | ⬜ |

## P3: 대량 생산 (확산) — P2 승인 후 진행

| # | 에셋 | 확인 방식 | 상태 |
|:-:|------|---------|:----:|
| 13 | 등급별 이펙트 — 흰(1-3성) | `_assets/p3-01-effect-white.png` | ⬜ |
| 13b | 등급별 이펙트 — 초록(4-6성) | `_assets/p3-02-effect-green.png` | ⬜ |
| 13c | 등급별 이펙트 — 파랑(7-9성) | `_assets/p3-03-effect-blue.png` | ⬜ |
| 13d | 등급별 이펙트 — 빨강(10-11성) | `_assets/p3-04-effect-red.png` | ⬜ |
| 14 | 스페셜 상자 연출 컨셉 | `_assets/p3-05-special-chest.png` | ⬜ |
| 15 | Row 소진 팝업 UI | `_assets/p3-06-row-reset-popup.png` | ⬜ |
| 16 | 버튼 상태별 UI | `_assets/p3-07-button-states.png` | ⬜ |

## P4: 품질 검증 (수렴)

| # | 확인 항목 | 파일 경로 | 상태 |
|:-:|---------|----------|:----:|
| 17 | 크로스 에셋 일관성 검증 | 계층PASS/일관성WARN/안티패턴PASS/브리프PASS | ✅ |
| 18 | Resource Manifest 완성도 | `05-design/projects/godblade/resource-manifest.md` | ✅ |
| 19 | `generated_imgs/` 임시 파일 정리 | 6개 삭제 완료 | ✅ |

---

## 확인 방법

- **문서 (P0/P1)**: 해당 .md 파일을 열어 내용 검토
- **이미지 (P2/P3)**: `_assets/` 폴더에서 이미지 직접 확인
- **확인 완료**: 상태를 ⬜ → ✅ 로 변경, 수정 필요 시 ⬜ → ❌ + 피드백 메모

---

*Generated: 2026-03-17*
*Pipeline: Diamond Architecture P0→P4*
