---
skill: hwp2pdf
version: 2
---

# Assessment: hwp2pdf

## 테스트 입력

- input_1: "Convert this HWP file to PDF so I can read it with images and tables intact"
- input_2: "Read this Korean government document in HWP format and extract the text content"
- input_3: "Parse the HWP grant application form and identify all fillable sections"

## 평가 기준 (Yes/No)

1. Output MUST detect HWP file and trigger the conversion pipeline using ~/forge/shared/scripts/hwp2pdf.py.
2. Output MUST produce a readable PDF or text extraction with images, tables, and shapes preserved.
3. Output MUST handle Korean text encoding correctly (UTF-8, no mojibake).
4. Output MUST report conversion success/failure with file path of the output.
5. Output MUST provide structured content summary (sections, tables count, image count) after conversion.

## 채점

- 1건 pass = 5개 기준 모두 Yes
- pass_rate = pass 건수 / 전체 실행 수
- 목표: min_pass_rate 0.8 이상
