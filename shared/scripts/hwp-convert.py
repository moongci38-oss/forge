#!/usr/bin/env python3
"""Forge 전역 HWP 변환 도구

HWP → TXT(텍스트) + HTML(이미지/도형/표 100% 포함) 변환.
원본 폴더 구조를 유지하며 _converted/ 하위에 저장.

출력 구조:
  _converted/
  ├── {파일명}.txt          ← 텍스트 전용 (빠른 검색용)
  └── {파일명}/
      ├── index.xhtml       ← HTML 본문 (이미지/표/도형 포함)
      ├── styles.css
      └── bindata/          ← 추출된 이미지 (png/bmp)

Usage:
    python3 hwp-convert.py file.hwp              # 단일 파일
    python3 hwp-convert.py folder/               # 폴더 일괄
    python3 hwp-convert.py folder/ --text-only   # 텍스트만
    python3 hwp-convert.py folder/ --cleanup     # 산재 .txt 정리
"""

import argparse
import subprocess
import sys
from pathlib import Path


def hwp_to_text(hwp_path: Path) -> str:
    """HWP → 텍스트. pyhwp 우선, LibreOffice 폴백."""
    try:
        result = subprocess.run(
            ["hwp5txt", str(hwp_path)],
            capture_output=True, text=True, timeout=30
        )
        if result.returncode == 0 and result.stdout.strip():
            return result.stdout
    except (subprocess.TimeoutExpired, FileNotFoundError):
        pass

    try:
        import tempfile
        with tempfile.TemporaryDirectory() as tmpdir:
            subprocess.run(
                ["libreoffice", "--headless", "--convert-to", "txt:Text",
                 "--outdir", tmpdir, str(hwp_path)],
                capture_output=True, timeout=60
            )
            txt_file = Path(tmpdir) / (hwp_path.stem + ".txt")
            if txt_file.exists():
                return txt_file.read_text(encoding="utf-8", errors="replace")
    except (subprocess.TimeoutExpired, FileNotFoundError):
        pass
    return ""


def hwp_to_html(hwp_path: Path, output_dir: Path) -> dict | None:
    """HWP → HTML + 이미지 (hwp5html). 이미지/도형/표 100% 보존."""
    html_dir = output_dir / hwp_path.stem
    try:
        result = subprocess.run(
            ["hwp5html", "--output", str(html_dir), str(hwp_path)],
            capture_output=True, text=True, timeout=60
        )
        index = html_dir / "index.xhtml"
        if index.exists():
            images = list((html_dir / "bindata").glob("*")) if (html_dir / "bindata").exists() else []
            return {
                "html_dir": str(html_dir),
                "index": str(index),
                "images": len(images)
            }
    except (subprocess.TimeoutExpired, FileNotFoundError):
        pass
    return None


def get_output_dir(hwp_path: Path, base_input: Path, base_output: Path) -> Path:
    """원본 폴더 구조 유지."""
    if base_input.is_file():
        return base_output
    try:
        relative = hwp_path.parent.relative_to(base_input)
        return base_output / relative
    except ValueError:
        return base_output


def convert_file(hwp_path: Path, output_dir: Path, text_only: bool = False) -> dict:
    """단일 HWP 변환."""
    result = {"input": str(hwp_path), "txt": None, "html": None, "images": 0, "chars": 0, "error": None}
    output_dir.mkdir(parents=True, exist_ok=True)

    # 텍스트 추출
    text = hwp_to_text(hwp_path)
    if text:
        txt_path = output_dir / (hwp_path.stem + ".txt")
        txt_path.write_text(text, encoding="utf-8")
        result["txt"] = str(txt_path)
        result["chars"] = len(text)
    else:
        result["error"] = "텍스트 추출 실패"

    # HTML + 이미지 변환
    if not text_only:
        html_result = hwp_to_html(hwp_path, output_dir)
        if html_result:
            result["html"] = html_result["html_dir"]
            result["images"] = html_result["images"]

    return result


def cleanup_scattered(folder: Path) -> int:
    """이전 산재 변환 파일 정리."""
    removed = 0
    for txt in folder.rglob("*.txt"):
        if "_converted" in txt.parts:
            continue
        if txt.with_suffix(".hwp").exists():
            txt.unlink()
            removed += 1
    return removed


def collect_hwp(input_path: Path) -> list[Path]:
    """HWP 파일 수집."""
    if input_path.is_file() and input_path.suffix.lower() == ".hwp":
        return [input_path]
    if input_path.is_dir():
        files = sorted(input_path.rglob("*.hwp"))
        return [f for f in files if ":Zone.Identifier" not in f.name and "_converted" not in f.parts]
    return []


def main():
    parser = argparse.ArgumentParser(
        description="Forge HWP 변환 — TXT + HTML(이미지/도형 100%)",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument("input", help="HWP 파일 또는 폴더")
    parser.add_argument("-o", "--output", help="출력 폴더 (기본: {input}/_converted/)")
    parser.add_argument("--text-only", action="store_true", help="HTML 생략, 텍스트만")
    parser.add_argument("--cleanup", action="store_true", help="산재 변환 파일 정리")
    args = parser.parse_args()

    input_path = Path(args.input).resolve()
    if not input_path.exists():
        print(f"오류: {input_path} 없음", file=sys.stderr)
        sys.exit(1)

    if args.cleanup:
        target = input_path if input_path.is_dir() else input_path.parent
        removed = cleanup_scattered(target)
        print(f"정리: {removed}개 산재 .txt 삭제")

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

    mode = "TXT" if args.text_only else "TXT + HTML(이미지)"
    print(f"HWP 변환 ({mode}): {len(hwp_files)}개 → {base_output}/")
    print("-" * 60)

    txt_ok, html_ok, total_images = 0, 0, 0
    for hwp in hwp_files:
        out_dir = get_output_dir(hwp, input_path, base_output)
        r = convert_file(hwp, out_dir, text_only=args.text_only)

        parts = []
        if r["txt"]:
            txt_ok += 1
            parts.append(f"{r['chars']:,}자")
        if r["html"]:
            html_ok += 1
            total_images += r["images"]
            parts.append(f"HTML+이미지 {r['images']}개")

        if parts:
            print(f"  ✅ {hwp.name} → {' | '.join(parts)}")
        else:
            print(f"  ❌ {hwp.name} — {r['error']}")

    print("-" * 60)
    print(f"완료: TXT {txt_ok}/{len(hwp_files)} | HTML {html_ok}/{len(hwp_files)} | 이미지 총 {total_images}개")
    print(f"출력: {base_output}/")


if __name__ == "__main__":
    main()
