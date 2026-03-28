#!/usr/bin/env python3
"""Forge 전역 HWP → PDF 변환 도구

hwp5html(HTML+이미지 추출) → Playwright(HTML→PDF) 파이프라인.
이미지/도형/표 레이아웃 100% 보존.

Usage:
    python3 hwp2pdf.py file.hwp                  # 단일 파일 → _converted/file.pdf
    python3 hwp2pdf.py folder/                    # 폴더 일괄
    python3 hwp2pdf.py folder/ -o /output/        # 출력 폴더 지정
"""

import argparse
import subprocess
import sys
import shutil
from pathlib import Path


def hwp_to_html(hwp_path: Path, work_dir: Path) -> Path | None:
    """HWP → HTML+이미지 (hwp5html)."""
    html_dir = work_dir / hwp_path.stem
    if html_dir.exists():
        shutil.rmtree(html_dir)
    try:
        subprocess.run(
            ["hwp5html", "--output", str(html_dir), str(hwp_path)],
            capture_output=True, timeout=60
        )
        index = html_dir / "index.xhtml"
        if index.exists():
            return index
    except (subprocess.TimeoutExpired, FileNotFoundError) as e:
        print(f"    hwp5html 실패: {e}", file=sys.stderr)
    return None


def html_to_pdf(html_path: Path, pdf_path: Path) -> bool:
    """HTML → PDF (Playwright Chromium)."""
    try:
        from playwright.sync_api import sync_playwright
        with sync_playwright() as p:
            browser = p.chromium.launch(headless=True)
            page = browser.new_page()
            page.goto(f"file://{html_path}", wait_until="networkidle")
            page.pdf(
                path=str(pdf_path),
                format="A4",
                margin={"top": "15mm", "bottom": "15mm", "left": "15mm", "right": "15mm"},
                print_background=True
            )
            browser.close()
        return pdf_path.exists()
    except Exception as e:
        print(f"    Playwright PDF 실패: {e}", file=sys.stderr)
        return False


def convert_hwp_to_pdf(hwp_path: Path, output_dir: Path) -> dict:
    """단일 HWP → PDF 변환."""
    import tempfile
    result = {"input": str(hwp_path), "pdf": None, "error": None}
    output_dir.mkdir(parents=True, exist_ok=True)

    with tempfile.TemporaryDirectory() as tmpdir:
        work_dir = Path(tmpdir)

        # Step 1: HWP → HTML
        html_index = hwp_to_html(hwp_path, work_dir)
        if not html_index:
            result["error"] = "HTML 변환 실패"
            return result

        # Step 2: HTML → PDF
        pdf_path = output_dir / (hwp_path.stem + ".pdf")
        if html_to_pdf(html_index, pdf_path):
            result["pdf"] = str(pdf_path)
        else:
            result["error"] = "PDF 변환 실패"

    return result


def get_output_dir(hwp_path: Path, base_input: Path, base_output: Path) -> Path:
    """원본 폴더 구조 유지."""
    if base_input.is_file():
        return base_output
    try:
        relative = hwp_path.parent.relative_to(base_input)
        return base_output / relative
    except ValueError:
        return base_output


def collect_hwp(input_path: Path) -> list[Path]:
    """HWP 파일 수집."""
    if input_path.is_file() and input_path.suffix.lower() == ".hwp":
        return [input_path]
    if input_path.is_dir():
        files = sorted(input_path.rglob("*.hwp"))
        return [f for f in files if ":Zone.Identifier" not in f.name and "_converted" not in f.parts]
    return []


def main():
    parser = argparse.ArgumentParser(description="Forge HWP → PDF (이미지/도형/표 100%)")
    parser.add_argument("input", help="HWP 파일 또는 폴더")
    parser.add_argument("-o", "--output", help="출력 폴더 (기본: {input}/_converted/)")
    args = parser.parse_args()

    input_path = Path(args.input).resolve()
    if not input_path.exists():
        print(f"오류: {input_path} 없음", file=sys.stderr)
        sys.exit(1)

    if args.output:
        base_output = Path(args.output).resolve()
    elif input_path.is_dir():
        base_output = input_path / "_converted"
    else:
        base_output = input_path.parent / "_converted"

    hwp_files = collect_hwp(input_path)
    if not hwp_files:
        print("변환할 HWP 없음", file=sys.stderr)
        sys.exit(1)

    print(f"HWP → PDF: {len(hwp_files)}개 → {base_output}/")
    print("-" * 60)

    success = 0
    for hwp in hwp_files:
        out_dir = get_output_dir(hwp, input_path, base_output)
        r = convert_hwp_to_pdf(hwp, out_dir)
        if r["pdf"]:
            success += 1
            size_kb = Path(r["pdf"]).stat().st_size // 1024
            print(f"  ✅ {hwp.name} → {size_kb}KB")
        else:
            print(f"  ❌ {hwp.name} — {r['error']}")

    print("-" * 60)
    print(f"완료: {success}/{len(hwp_files)} PDF 생성")


if __name__ == "__main__":
    main()
