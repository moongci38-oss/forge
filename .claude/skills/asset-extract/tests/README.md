# asset-extract 테스트 하네스

> 2026-04-12 추가 | v5 회귀 방지 + 신규 fixture 검증용
> 고도화 작업 시작 전 필독: `~/forge-outputs/docs/handover/2026-04-12-asset-extract-handover.md`

## 빠른 사용

```bash
cd ~/.claude/skills/asset-extract/tests

python3 run_tests.py --all              # 모든 fixture 실행
python3 run_tests.py --fixture {name}   # 단일 케이스
python3 run_tests.py --all --debug      # 실패 시 SAM mask + contour 시각화
```

종료 코드: 모든 케이스가 PASS 또는 REVIEW면 0, FAIL 하나라도 있으면 1.

## 결과 해석

| 상태 | 의미 | 조치 |
|---|---|---|
| **PASS** | golden과 phash distance ≤ 8 | 회귀 없음. 통과 |
| **REVIEW** | golden 미생성 (`NO_GOLDEN`) | `output/{name}.png` 시각 확인 → 의도대로면 freeze |
| **FAIL** | `GOLDEN_MISMATCH` / `BBOX_MISMATCH` / `LOW_ALPHA_COVERAGE` / `CROP_FAIL` | 원인 분석 후 수정 |

### 분류 코드

- `BBOX_MISMATCH`: 출력 크기가 expected.size_range 이탈
- `LOW_ALPHA_COVERAGE`: 마스크가 너무 비어 있음 (alpha_coverage_min 미달)
- `CROP_FAIL`: SAM이 아무것도 못 잡음 (segment_button.py exit ≠ 0)
- `GOLDEN_MISMATCH`: 출력의 phash가 골든과 hamming distance > 8
- `VISUAL_REVIEW_NEEDED`: golden 미생성 — REVIEW 상태로 표시됨

## 새 케이스 추가 워크플로우

1. **fixture JSON 작성** — `fixtures/{name}.json`
   ```json
   {
     "image": "/abs/path/to/screenshot.png",
     "bbox": [left, top, right, bottom],
     "margin": 3,
     "bot_margin": 8,
     "expected": {
       "alpha_coverage_min": 0.3,
       "tags": ["trapezoid", "dark-base-same-bg"]
     }
   }
   ```
   `expected.size_range`는 처음엔 생략 권장 (golden freeze 후 측정 결과 보고 추가).

2. **첫 실행**
   ```bash
   python3 run_tests.py --fixture {name}
   ```
   결과는 REVIEW (golden 없음).

3. **시각 확인** — `output/{name}.png` 열어서 의도한 객체가 깨끗하게 추출됐는지 검토.
   - 의도한 객체가 잡혔나?
   - 인접 UI가 들어왔나?
   - 엣지가 깔끔한가?

4. **OK면 freeze**
   ```bash
   cp output/{name}.png golden/{name}.png
   ```

5. **재실행하여 PASS 확정**
   ```bash
   python3 run_tests.py --fixture {name}
   ```
   `golden_distance=0`이 나와야 함.

6. **NG면**: fixture의 bbox/margin/bot_margin 조정 → 2단계 반복. 또는 v5의 한계로 판단되면 baseline 케이스로 등록 (REVIEW 상태로 두고 향후 고도화 대상으로 표시).

## 디렉터리

```
tests/
├── run_tests.py        # 배치 러너
├── README.md           # 이 파일
├── baseline-report.md  # 2026-04-12 시점 6 케이스 검증 결과
├── fixtures/
│   ├── README.md       # 스키마 가이드
│   └── *.json          # 케이스별 입력 정의
├── output/             # 매 실행마다 덮어써짐
├── golden/             # 사람이 검증한 기준 (수동 freeze)
└── debug/              # --debug 옵션 시 SAM mask + contour 시각화
```

## 의존성

```bash
pip install imagehash                    # phash 골든 비교 (필수)
pip install rembg opencv-python-headless # segment_button.py 의존
```

`rembg`는 첫 실행 시 SAM ONNX 모델(~375MB) 자동 다운로드.

## 알려진 베이스라인 (2026-04-12)

| 케이스 | 상태 | 비고 |
|---|---|---|
| `baduki_low_baduk` | **PASS** | 유일한 검증 통과 (golden distance 0) |
| `baduki_btn_02_left_tab` | REVIEW | 시각: 빈 진청색 띠 (WRONG_OBJECT) |
| `baduki_btn_03_attendance` | REVIEW | 시각: 인접 UI 통째 (ADJACENT_UI) |
| `baduki_btn_04_video` | REVIEW | 시각: 거의 빈 영역 (WRONG_OBJECT) |
| `baduki_btn_05_settings` | REVIEW | 시각: 완전히 빈 진청 (WRONG_OBJECT) |
| `baduki_btn_06_right` | REVIEW | 시각: 다중 아이콘 함께 (ADJACENT_UI) |

5건의 REVIEW는 v5 한계로 판정됨. golden freeze 안 함 (잘못된 결과를 기준으로 굳히면 안 됨).

## 회귀 안전 규칙

- **`baduki_low_baduk`은 절대 깨뜨리지 말 것** — 모든 v5 수정의 회귀 베이스
- 코드 수정 후 `--all` PASS+REVIEW 유지가 필수 (FAIL 0건)
- golden 갱신은 의도적 시각 개선이 있을 때만, 별도 커밋으로

## 디버깅

`--debug` 플래그 사용 시 실패 케이스에 한해:
- `debug/{name}_sam_mask.png` — SAM의 raw 출력 (배경 제거 결과)
- `debug/{name}_contour.png` — approxPolyDP 결과 시각화 (녹색 컨투어 + 빨간 다각형)

이 두 이미지로 SAM이 어디까지 잡았는지, 다각형 피팅이 어디서 깨졌는지 진단 가능.
