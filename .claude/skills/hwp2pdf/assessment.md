---
skill: hwp2pdf
version: 1
---

# Assessment: hwp2pdf

## 테스트 입력

- input_1: "Convert the HWP file at /tmp/test-document.hwp to PDF"
- input_2: "Transform a Korean government document (HWP format) to readable PDF"
- input_3: "Convert HWP file preserving all tables and images to PDF format"

## 평가 기준 (Yes/No)

1. HWP→PDF 변환 파이프라인(hwp5html→HTML→PDF)이 설명되어 있는가?
2. 변환 결과 저장 경로(_converted/ 또는 구체적 경로)가 명시되어 있는가?
3. 이미지/표/서식 보존 방법이 언급되어 있는가?
4. 필요한 도구(hwp5html, Playwright)가 참조되어 있는가?
5. 변환 실행 명령 또는 스크립트가 제시되어 있는가?

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상
