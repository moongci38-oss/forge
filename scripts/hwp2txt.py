#!/usr/bin/env python3
"""HWP → 텍스트/PDF 변환 스크립트

Usage:
    python3 hwp2txt.py <input.hwp>                    # → 같은 폴더에 .txt 생성
    python3 hwp2txt.py <input.hwp> -o /output/dir/    # → 지정 폴더에 .txt 생성
    python3 hwp2txt.py <input.hwp> --pdf               # → .txt + .pdf 생성
    python3 hwp2txt.py <folder/>                       # → 폴더 내 모든 .hwp 일괄 변환
    python3 hwp2txt.py <folder/> --pdf                 # → 폴더 내 모든 .hwp → txt + pdf
"""

import argparse
import os
import subprocess
import sys
import tempfile
from pathlib import Path


def hwp_to_text_pyhwp(hwp_path: Path) -> str:
    """pyhwp(hwp5txt)로 텍스트 추출 — 1차 시도"""
    try:
        result = subprocess.run(
            ["hwp5txt", str(hwp_path)],
            capture_output=True, text=True, timeout=30
        )
        if result.returncode == 0 and result.stdout.strip():
            return result.stdout
    except (subprocess.TimeoutExpired, FileNotFoundError):
        pass
    return ""


def hwp_to_text_libreoffice(hwp_path: Path, output_dir: Path) -> str:
    """LibreOffice로 변환 후 텍스트 추출 — 2차 폴백"""
    try:
        with tempfile.TemporaryDirectory() as tmpdir:
            subprocess.run(
                [
                    "libreoffice", "--headless", "--convert-to", "txt:Text",
                    "--outdir", tmpdir, str(hwp_path)
                ],
                capture_output=True, timeout=60
            )
            txt_file = Path(tmpdir) / (hwp_path.stem + ".txt")
            if txt_file.exists():
                return txt_file.read_text(encoding="utf-8", errors="replace")
    except (subprocess.TimeoutExpired, FileNotFoundError):
        pass
    return ""


def hwp_to_pdf_libreoffice(hwp_path: Path, output_dir: Path) -> Path | None:
    """LibreOffice로 PDF 변환"""
    try:
        subprocess.run(
            [
                "libreoffice", "--headless", "--convert-to", "pdf",
                "--outdir", str(output_dir), str(hwp_path)
            ],
            capture_output=True, timeout=120
        )
        pdf_path = output_dir / (hwp_path.stem + ".pdf")
        if pdf_path.exists():
            return pdf_path
    except (subprocess.TimeoutExpired, FileNotFoundError):
        pass
    return None


def convert_hwp(hwp_path: Path, output_dir: Path, make_pdf: bool = False) -> dict:
    """단일 HWP 파일 변환"""
    result = {"input": str(hwp_path), "txt": None, "pdf": None, "method": None, "chars": 0}

    # 1차: pyhwp
    text = hwp_to_text_pyhwp(hwp_path)
    if text:
        result["method"] = "pyhwp"
    else:
        # 2차: LibreOffice
        text = hwp_to_text_libreoffice(hwp_path, output_dir)
        if text:
            result["method"] = "libreoffice"

    # 텍스트 저장
    if text:
        txt_path = output_dir / (hwp_path.stem + ".txt")
        txt_path.write_text(text, encoding="utf-8")
        result["txt"] = str(txt_path)
        result["chars"] = len(text)

    # PDF 변환
    if make_pdf:
        pdf_path = hwp_to_pdf_libreoffice(hwp_path, output_dir)
        if pdf_path:
            result["pdf"] = str(pdf_path)

    return result


def main():
    parser = argparse.ArgumentParser(description="HWP → 텍스트/PDF 변환")
    parser.add_argument("input", help="HWP 파일 또는 폴더 경로")
    parser.add_argument("-o", "--output", help="출력 폴더 (기본: 입력과 같은 폴더)")
    parser.add_argument("--pdf", action="store_true", help="PDF도 함께 생성")
    args = parser.parse_args()

    input_path = Path(args.input).resolve()

    # 입력이 폴더면 내부 .hwp 전체
    if input_path.is_dir():
        hwp_files = sorted(input_path.glob("**/*.hwp"))
        hwp_files = [f for f in hwp_files if not f.name.endswith(":Zone.Identifier")]
    elif input_path.is_file() and input_path.suffix.lower() == ".hwp":
        hwp_files = [input_path]
    else:
        print(f"오류: {input_path} 는 HWP 파일이 아닙니다.", file=sys.stderr)
        sys.exit(1)

    if not hwp_files:
        print("변환할 HWP 파일이 없습니다.", file=sys.stderr)
        sys.exit(1)

    output_dir = Path(args.output).resolve() if args.output else input_path if input_path.is_dir() else input_path.parent
    output_dir.mkdir(parents=True, exist_ok=True)

    print(f"HWP 변환 시작: {len(hwp_files)}개 파일 → {output_dir}")
    print("-" * 60)

    success = 0
    for hwp in hwp_files:
        result = convert_hwp(hwp, output_dir, make_pdf=args.pdf)
        if result["txt"]:
            success += 1
            print(f"  ✅ {hwp.name} → {result['chars']:,}자 ({result['method']})")
            if result["pdf"]:
                print(f"     📄 PDF: {result['pdf']}")
        else:
            print(f"  ❌ {hwp.name} — 변환 실패")

    print("-" * 60)
    print(f"완료: {success}/{len(hwp_files)} 성공")


if __name__ == "__main__":
    main()
