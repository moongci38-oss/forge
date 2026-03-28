#!/usr/bin/env python3
"""
md-to-docx.py — Markdown → DOCX 프로그래매틱 변환 스크립트
pandoc 블랙박스 변환 대신 python-docx로 요소별 직접 빌드.

사용법:
  python3 md-to-docx.py input.md output.docx
  python3 md-to-docx.py --dir /path/to/full-text/  # 폴더 내 모든 .md 변환

특징:
  - 색상 span (red/blue) → RGBColor 직접 매핑
  - 이미지 ![](path) → InlineShape 바이너리 임베딩
  - 표 → Table 객체 직접 생성
  - 제목 ##/###/#### → Heading 1/2/3
  - 한글 폰트: Pretendard (w:eastAsia 명시)
  - --- → 페이지 브레이크
"""

import re
import sys
import os
from pathlib import Path

from docx import Document
from docx.shared import Pt, Inches, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml.ns import qn


# ─── 폰트 설정 ───

FONT_TITLE = "Pretendard"
FONT_BODY = "Pretendard"
FONT_TABLE = "KoPub돋움체 Medium"
FONT_FALLBACK = "Noto Sans KR"

TITLE_SIZE = Pt(18)
H1_SIZE = Pt(16)
H2_SIZE = Pt(14)
H3_SIZE = Pt(12)
BODY_SIZE = Pt(11)
TABLE_SIZE = Pt(10)
CAPTION_SIZE = Pt(9)


def set_font(run, font_name=FONT_BODY, size=BODY_SIZE, bold=False, color=None):
    """run에 폰트, 크기, 색상을 설정한다. w:eastAsia로 한글 폰트를 명시."""
    run.font.name = font_name
    run.font.size = size
    run.bold = bold
    rpr = run._element.get_or_add_rPr()
    rfonts = rpr.find(qn("w:rFonts"))
    if rfonts is None:
        rfonts = run._element.makeelement(qn("w:rFonts"), {})
        rpr.insert(0, rfonts)
    rfonts.set(qn("w:eastAsia"), font_name)
    rfonts.set(qn("w:ascii"), font_name)
    rfonts.set(qn("w:hAnsi"), font_name)
    if color:
        run.font.color.rgb = color


def set_style_defaults(doc):
    """문서 기본 스타일을 Pretendard로 설정."""
    style = doc.styles["Normal"]
    style.font.name = FONT_BODY
    style.font.size = BODY_SIZE
    style.paragraph_format.space_after = Pt(6)
    style.paragraph_format.line_spacing = 1.5
    rpr = style.element.get_or_add_rPr()
    rfonts = rpr.find(qn("w:rFonts"))
    if rfonts is None:
        rfonts = style.element.makeelement(qn("w:rFonts"), {})
        rpr.insert(0, rfonts)
    rfonts.set(qn("w:eastAsia"), FONT_BODY)

    for level, (hsize, hbold) in enumerate(
        [(H1_SIZE, True), (H2_SIZE, True), (H3_SIZE, True)], start=1
    ):
        hstyle_name = f"Heading {level}"
        if hstyle_name in doc.styles:
            hs = doc.styles[hstyle_name]
            hs.font.name = FONT_TITLE
            hs.font.size = hsize
            hs.font.bold = hbold
            hrpr = hs.element.get_or_add_rPr()
            hrf = hrpr.find(qn("w:rFonts"))
            if hrf is None:
                hrf = hs.element.makeelement(qn("w:rFonts"), {})
                hrpr.insert(0, hrf)
            hrf.set(qn("w:eastAsia"), FONT_TITLE)


# ─── 색상 파싱 ───

COLOR_MAP = {
    "red": RGBColor(0xFF, 0x00, 0x00),
    "blue": RGBColor(0x00, 0x62, 0xB8),
    "#ff0000": RGBColor(0xFF, 0x00, 0x00),
    "#0062b8": RGBColor(0x00, 0x62, 0xB8),
}

SPAN_RE = re.compile(
    r'<span\s+style="color:\s*([^";]+)[^"]*"[^>]*>(.*?)</span>', re.DOTALL
)
BOLD_RE = re.compile(r"\*\*(.+?)\*\*")
IMG_RE = re.compile(r"!\[([^\]]*)\]\(([^)]+)\)")
HEADING_RE = re.compile(r"^(#{1,4})\s+(.+)$")
HR_RE = re.compile(r"^---+\s*$")
TABLE_SEP_RE = re.compile(r"^\|[\s\-:|]+\|$")
TABLE_ROW_RE = re.compile(r"^\|(.+)\|$")
COMMENT_RE = re.compile(r"<!--.*?-->", re.DOTALL)
BLOCKQUOTE_RE = re.compile(r"^>\s*(.*)$")


def parse_color(color_str):
    """색상 문자열을 RGBColor로 변환."""
    color_str = color_str.strip().lower()
    return COLOR_MAP.get(color_str)


def add_rich_text(paragraph, text, base_font=FONT_BODY, base_size=BODY_SIZE):
    """텍스트에서 span(색상), **bold**, ![](이미지)를 파싱하여 run으로 추가."""
    # 주석 제거
    text = COMMENT_RE.sub("", text)

    # span 처리
    pos = 0
    for m in SPAN_RE.finditer(text):
        # span 이전 텍스트
        before = text[pos : m.start()]
        if before:
            _add_formatted_runs(paragraph, before, base_font, base_size)
        # span 내부 텍스트 (색상 적용)
        color = parse_color(m.group(1))
        inner = m.group(2)
        # inner에서 **bold** 처리
        _add_formatted_runs(paragraph, inner, base_font, base_size, color=color)
        pos = m.end()

    # 남은 텍스트
    remaining = text[pos:]
    if remaining:
        _add_formatted_runs(paragraph, remaining, base_font, base_size)


def _add_formatted_runs(paragraph, text, font_name, font_size, color=None):
    """**bold** 마크다운을 파싱하여 run으로 추가."""
    pos = 0
    for m in BOLD_RE.finditer(text):
        before = text[pos : m.start()]
        if before:
            run = paragraph.add_run(before)
            set_font(run, font_name, font_size, color=color)
        bold_text = m.group(1)
        run = paragraph.add_run(bold_text)
        set_font(run, font_name, font_size, bold=True, color=color)
        pos = m.end()
    remaining = text[pos:]
    if remaining:
        run = paragraph.add_run(remaining)
        set_font(run, font_name, font_size, color=color)


def add_image(doc, img_path, base_dir):
    """이미지를 InlineShape로 삽입. 파일 없으면 플레이스홀더 텍스트."""
    full_path = Path(base_dir) / img_path
    if full_path.exists():
        doc.add_picture(str(full_path), width=Inches(5.5))
    else:
        p = doc.add_paragraph()
        run = p.add_run(f"[이미지 플레이스홀더: {img_path}]")
        set_font(run, color=RGBColor(0x99, 0x99, 0x99))
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER


def add_table(doc, rows):
    """마크다운 파이프 테이블을 docx Table로 변환."""
    if len(rows) < 2:
        return
    # 헤더
    headers = [c.strip() for c in rows[0].split("|") if c.strip()]
    # 구분선 스킵 (rows[1])
    data_rows = []
    for r in rows[2:]:
        cells = [c.strip() for c in r.split("|") if c.strip()]
        data_rows.append(cells)

    ncols = len(headers)
    table = doc.add_table(rows=1 + len(data_rows), cols=ncols)
    table.style = "Table Grid"

    # 헤더 행
    for i, h in enumerate(headers):
        cell = table.rows[0].cells[i]
        cell.text = ""
        p = cell.paragraphs[0]
        run = p.add_run(re.sub(r"\*\*(.+?)\*\*", r"\1", h))
        set_font(run, FONT_TABLE, TABLE_SIZE, bold=True)
        # 헤더 배경색
        shading = cell._element.get_or_add_tcPr()
        shd = shading.makeelement(
            qn("w:shd"),
            {qn("w:fill"): "0062B8", qn("w:val"): "clear"},
        )
        shading.append(shd)
        run.font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)

    # 데이터 행
    for ri, row_data in enumerate(data_rows):
        for ci in range(min(len(row_data), ncols)):
            cell = table.rows[ri + 1].cells[ci]
            cell.text = ""
            p = cell.paragraphs[0]
            cell_text = re.sub(r"\*\*(.+?)\*\*", r"\1", row_data[ci])
            # span 색상 제거 (표 안에서는 단순 텍스트)
            cell_text = SPAN_RE.sub(r"\2", cell_text)
            run = p.add_run(cell_text)
            set_font(run, FONT_TABLE, TABLE_SIZE)
            # 교차 행 배경
            if ri % 2 == 1:
                shading = cell._element.get_or_add_tcPr()
                shd = shading.makeelement(
                    qn("w:shd"),
                    {qn("w:fill"): "FAFAFA", qn("w:val"): "clear"},
                )
                shading.append(shd)


def convert_md_to_docx(md_path, docx_path):
    """단일 md 파일을 docx로 변환."""
    md_path = Path(md_path)
    base_dir = md_path.parent

    with open(md_path, "r", encoding="utf-8") as f:
        lines = f.readlines()

    doc = Document()
    set_style_defaults(doc)

    i = 0
    table_buffer = []
    in_table = False

    while i < len(lines):
        line = lines[i].rstrip("\n")

        # 빈 줄
        if not line.strip():
            if in_table and table_buffer:
                add_table(doc, table_buffer)
                table_buffer = []
                in_table = False
            i += 1
            continue

        # 테이블 행
        if TABLE_ROW_RE.match(line):
            if TABLE_SEP_RE.match(line):
                # 구분선
                table_buffer.append(line)
            else:
                table_buffer.append(line)
            in_table = True
            i += 1
            continue
        elif in_table and table_buffer:
            add_table(doc, table_buffer)
            table_buffer = []
            in_table = False

        # 수평선 → 페이지 브레이크
        if HR_RE.match(line):
            doc.add_page_break()
            i += 1
            continue

        # 주석 전용 줄
        if line.strip().startswith("<!--") and line.strip().endswith("-->"):
            i += 1
            continue

        # 제목
        hm = HEADING_RE.match(line)
        if hm:
            level = len(hm.group(1))
            title_text = hm.group(2).strip()
            # 마크다운 볼드 제거
            title_text = re.sub(r"\*\*(.+?)\*\*", r"\1", title_text)
            # span 제거 (제목에서는 색상 무시)
            title_text = SPAN_RE.sub(r"\2", title_text)
            heading_level = min(level, 3)
            h = doc.add_heading(title_text, level=heading_level)
            for run in h.runs:
                set_font(
                    run,
                    FONT_TITLE,
                    [TITLE_SIZE, H1_SIZE, H2_SIZE, H3_SIZE][heading_level],
                    bold=True,
                )
            i += 1
            continue

        # 이미지
        img_m = IMG_RE.search(line)
        if img_m and line.strip().startswith("!"):
            add_image(doc, img_m.group(2), base_dir)
            # 캡션
            if img_m.group(1):
                cap = doc.add_paragraph()
                run = cap.add_run(img_m.group(1))
                set_font(run, size=CAPTION_SIZE, color=RGBColor(0x8E, 0x8E, 0x8E))
                cap.alignment = WD_ALIGN_PARAGRAPH.CENTER
            i += 1
            continue

        # 블록인용
        bq_m = BLOCKQUOTE_RE.match(line)
        if bq_m:
            p = doc.add_paragraph()
            p.paragraph_format.left_indent = Inches(0.5)
            add_rich_text(p, bq_m.group(1), base_size=Pt(10))
            i += 1
            continue

        # 일반 텍스트
        p = doc.add_paragraph()
        add_rich_text(p, line)
        i += 1

    # 남은 테이블 버퍼
    if table_buffer:
        add_table(doc, table_buffer)

    doc.save(str(docx_path))
    print(f"✅ {md_path.name} → {Path(docx_path).name}")


def main():
    if len(sys.argv) < 2:
        print("사용법: python3 md-to-docx.py input.md [output.docx]")
        print("        python3 md-to-docx.py --dir /path/to/folder/")
        sys.exit(1)

    if sys.argv[1] == "--dir":
        folder = Path(sys.argv[2])
        for md_file in sorted(folder.glob("chapter*.md")):
            docx_file = md_file.with_suffix(".docx")
            convert_md_to_docx(md_file, docx_file)
    else:
        md_file = sys.argv[1]
        docx_file = sys.argv[2] if len(sys.argv) > 2 else md_file.replace(".md", ".docx")
        convert_md_to_docx(md_file, docx_file)


if __name__ == "__main__":
    main()
