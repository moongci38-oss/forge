# asset-extract test fixtures

새 케이스 추가 방법:

1. 스크린샷을 절대경로로 준비 (예: `~/forge-outputs/.../screenshot.png`)
2. `{name}.json` 작성 — 아래 스키마 참조
3. `python3 ../run_tests.py --fixture {name}` 실행 → PASS 확인
4. PASS 후 골든 스냅샷이 필요하면 출력 PNG를 `../golden/{name}.png` 로 복사

## 스키마

```json
{
  "image": "/abs/path/to/screenshot.png",
  "bbox": [left, top, right, bottom],
  "margin": 3,
  "bot_margin": 8,
  "expected": {
    "size_range": [[w_min, w_max], [h_min, h_max]],
    "alpha_coverage_min": 0.5,
    "tags": ["trapezoid", "dark-base-same-bg"]
  }
}
```

`bbox`, `margin`, `bot_margin` 미지정 시 기본값 사용.
`expected` 필드는 모두 선택 — 없으면 단지 "에러 없이 실행됨" 만 검증.

## 태그 컨벤션

- **형태**: trapezoid, rectangle, rounded, circle, icon-only
- **배경**: dark-base-same-bg, light-bg, high-contrast
- **특수**: translucent, neon-glow, gradient, adjacent-ui
