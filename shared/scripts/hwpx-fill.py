#!/usr/bin/env python3
"""
HWPX 양식 자동 채우기 도구

HWPX 양식 파일의 플레이스홀더를 실제 내용으로 치환한다.
ZIP-level XML 직접 치환 방식으로 양식 레이아웃을 100% 보존.

원본 로직: https://github.com/Canine89/gonggong_hwpxskills
포팅: Forge CLI 환경용

사용법:
  # 양식 내 텍스트 조사
  python hwpx-fill.py scan <양식.hwpx>

  # 일괄 치환 (JSON 매핑)
  python hwpx-fill.py fill <양식.hwpx> <출력.hwpx> --map '{"기존텍스트": "새텍스트"}'

  # 일괄 치환 (JSON 파일)
  python hwpx-fill.py fill <양식.hwpx> <출력.hwpx> --map-file mapping.json

  # 순차 치환
  python hwpx-fill.py fill-seq <양식.hwpx> <출력.hwpx> --old "플레이스홀더" --new '["값1","값2"]'
"""

import zipfile
import os
import sys
import json
import argparse
import shutil
import subprocess


def scan_texts(hwpx_path):
    """HWPX 양식 내 모든 텍스트를 추출하여 출력한다."""
    try:
        from hwpx import ObjectFinder
        finder = ObjectFinder(hwpx_path)
        results = finder.find_all(tag="t")
        texts = []
        for r in results:
            if r.text and r.text.strip():
                texts.append(r.text.strip())
        return texts
    except ImportError:
        # python-hwpx 없으면 ZIP에서 직접 추출
        import re
        texts = []
        with zipfile.ZipFile(hwpx_path, "r") as zf:
            for item in zf.infolist():
                if item.filename.startswith("Contents/") and item.filename.endswith(".xml"):
                    data = zf.read(item.filename).decode("utf-8")
                    for match in re.finditer(r"<(?:\w+:)?t[^>]*>([^<]+)</(?:\w+:)?t>", data):
                        text = match.group(1).strip()
                        if text:
                            texts.append(text)
        return texts


def zip_replace(src_path, dst_path, replacements):
    """HWPX ZIP 내 모든 XML에서 텍스트 일괄 치환 (표 내부 포함)."""
    tmp = dst_path + ".tmp"
    with zipfile.ZipFile(src_path, "r") as zin:
        with zipfile.ZipFile(tmp, "w", zipfile.ZIP_DEFLATED) as zout:
            for item in zin.infolist():
                data = zin.read(item.filename)
                if item.filename.startswith("Contents/") and item.filename.endswith(".xml"):
                    text = data.decode("utf-8")
                    for old, new in replacements.items():
                        text = text.replace(old, new)
                    data = text.encode("utf-8")
                zout.writestr(item, data)
    if os.path.exists(dst_path):
        os.remove(dst_path)
    os.rename(tmp, dst_path)


def zip_replace_sequential(src_path, dst_path, old, new_list):
    """section XML에서 old를 순서대로 new_list 값으로 하나씩 치환."""
    tmp = dst_path + ".tmp"
    with zipfile.ZipFile(src_path, "r") as zin:
        with zipfile.ZipFile(tmp, "w", zipfile.ZIP_DEFLATED) as zout:
            for item in zin.infolist():
                data = zin.read(item.filename)
                if "section" in item.filename and item.filename.endswith(".xml"):
                    text = data.decode("utf-8")
                    for new_val in new_list:
                        text = text.replace(old, new_val, 1)
                    data = text.encode("utf-8")
                zout.writestr(item, data)
    if os.path.exists(dst_path):
        os.remove(dst_path)
    os.rename(tmp, dst_path)


def fix_namespaces(hwpx_path):
    """네임스페이스 후처리 실행."""
    script_dir = os.path.dirname(os.path.abspath(__file__))
    fix_script = os.path.join(script_dir, "hwpx-fix-namespaces.py")
    if os.path.exists(fix_script):
        subprocess.run([sys.executable, fix_script, hwpx_path], check=True)
    else:
        print(f"Warning: {fix_script} not found, skipping namespace fix")


def main():
    parser = argparse.ArgumentParser(description="HWPX 양식 자동 채우기")
    sub = parser.add_subparsers(dest="command")

    # scan
    p_scan = sub.add_parser("scan", help="양식 내 텍스트 전수 조사")
    p_scan.add_argument("hwpx", help="HWPX 파일 경로")

    # fill (일괄 치환)
    p_fill = sub.add_parser("fill", help="일괄 치환")
    p_fill.add_argument("hwpx", help="입력 HWPX 파일")
    p_fill.add_argument("output", help="출력 HWPX 파일")
    p_fill.add_argument("--map", help="JSON 치환 매핑 (문자열)")
    p_fill.add_argument("--map-file", help="JSON 치환 매핑 (파일)")

    # fill-seq (순차 치환)
    p_seq = sub.add_parser("fill-seq", help="순차 치환")
    p_seq.add_argument("hwpx", help="입력 HWPX 파일")
    p_seq.add_argument("output", help="출력 HWPX 파일")
    p_seq.add_argument("--old", required=True, help="치환 대상 텍스트")
    p_seq.add_argument("--new", required=True, help="치환 값 JSON 배열")

    args = parser.parse_args()

    if args.command == "scan":
        texts = scan_texts(args.hwpx)
        print(f"=== {args.hwpx} 내 텍스트 ({len(texts)}개) ===")
        for i, t in enumerate(texts, 1):
            print(f"  [{i:3d}] {repr(t)}")

    elif args.command == "fill":
        if args.map:
            replacements = json.loads(args.map)
        elif args.map_file:
            with open(args.map_file, "r", encoding="utf-8") as f:
                replacements = json.load(f)
        else:
            print("Error: --map or --map-file required")
            sys.exit(1)

        shutil.copy(args.hwpx, args.output)
        zip_replace(args.output, args.output, replacements)
        fix_namespaces(args.output)
        print(f"Filled: {args.output} ({len(replacements)} replacements)")

    elif args.command == "fill-seq":
        new_list = json.loads(args.new)
        shutil.copy(args.hwpx, args.output)
        zip_replace_sequential(args.output, args.output, args.old, new_list)
        fix_namespaces(args.output)
        print(f"Sequential fill: {args.output} ({len(new_list)} values)")

    else:
        parser.print_help()


if __name__ == "__main__":
    main()
