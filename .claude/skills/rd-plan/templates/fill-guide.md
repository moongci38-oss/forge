# 양식 기입 가이드 템플릿

> 기관 제공 양식의 각 필드와 마스터 문서 섹션의 1:1 매핑.
> 자동 기입 실패 시 수동 복사-붙여넣기용.

## 매핑 테이블

| 양식 필드 | 양식 위치 | 마스터 섹션 | 초안 파일 |
|----------|----------|-----------|---------|
| {field_1} | {page/slide} | {section_id} | `drafts/section-{N}.md` |
| {field_2} | {page/slide} | {section_id} | `drafts/section-{N}.md` |
| ... | ... | ... | ... |

## 기입 순서

1. 양식 파일을 열기 (HWP/DOCX/PPTX)
2. 위 매핑 테이블 순서대로 해당 초안 파일의 내용을 복사
3. 양식의 해당 필드에 붙여넣기
4. 시각화 이미지는 `assets/` 폴더에서 삽입
5. 서명/직인 추가 (대표자 확인)

## 자동 기입 스크립트

```bash
# DOCX 양식
python scripts/fill_docx.py <양식.docx> <content_dir> --output <출력.docx>

# PPTX 양식
python scripts/fill_pptx.py <양식.pptx> <content_dir> --output <출력.pptx>

# HWP 양식 (DOCX 변환 경유)
python3 scripts/office/soffice.py --headless --convert-to docx <양식.hwp>
python scripts/fill_docx.py <양식.docx> <content_dir> --output <filled.docx>
python3 scripts/office/soffice.py --headless --convert-to hwp <filled.docx>
```
