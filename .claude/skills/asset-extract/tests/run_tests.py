#!/usr/bin/env python3
"""
asset-extract 테스트 배터리 러너.

Usage:
  python3 run_tests.py --all
  python3 run_tests.py --fixture baduki_low_baduk
  python3 run_tests.py --all --debug   # SAM mask + contour 시각화 저장

fixture JSON 스키마:
  {
    "name": "baduki_low_baduk",
    "image": "/abs/path/screenshot.jpeg",
    "bbox": [155, 110, 420, 191],
    "margin": 3,
    "bot_margin": 8,
    "expected": {
      "size_range": [[220, 250], [50, 70]],
      "alpha_coverage_min": 0.5,
      "tags": ["trapezoid", "dark-base-same-bg"]
    }
  }
"""

import argparse
import json
import subprocess
import sys
import time
from pathlib import Path

import numpy as np
from PIL import Image

TESTS_DIR = Path(__file__).resolve().parent
FIXTURES_DIR = TESTS_DIR / "fixtures"
DEBUG_DIR = TESTS_DIR / "debug"
GOLDEN_DIR = TESTS_DIR / "golden"
SEGMENT_SCRIPT = TESTS_DIR.parent / "scripts" / "segment_button.py"

GOLDEN_HASH_THRESHOLD = 8  # phash hamming distance; >8 = visually different


def load_fixture(path: Path) -> dict:
    data = json.loads(path.read_text())
    data.setdefault("name", path.stem)
    data.setdefault("margin", 3)
    data.setdefault("bot_margin", 8)
    data.setdefault("expected", {})
    return data


def measure(png_path: Path) -> dict:
    import imagehash
    img = Image.open(png_path).convert("RGBA")
    arr = np.array(img)
    alpha = arr[:, :, 3]
    total = alpha.size
    opaque = int((alpha > 5).sum())
    rgb_for_hash = Image.new("RGB", img.size, (0, 0, 0))
    rgb_for_hash.paste(img, mask=img.split()[3])
    return {
        "width": img.size[0],
        "height": img.size[1],
        "alpha_coverage": opaque / total if total else 0.0,
        "phash": str(imagehash.phash(rgb_for_hash)),
    }


def compare_golden(name: str, measured_phash: str) -> tuple[str, int | None]:
    """Returns (status, distance). status in {GOLDEN_OK, GOLDEN_MISMATCH, NO_GOLDEN}."""
    import imagehash
    golden_path = GOLDEN_DIR / f"{name}.png"
    if not golden_path.exists():
        return ("NO_GOLDEN", None)
    golden_img = Image.open(golden_path).convert("RGBA")
    golden_rgb = Image.new("RGB", golden_img.size, (0, 0, 0))
    golden_rgb.paste(golden_img, mask=golden_img.split()[3])
    golden_hash = imagehash.phash(golden_rgb)
    measured_hash = imagehash.hex_to_hash(measured_phash)
    distance = golden_hash - measured_hash
    return ("GOLDEN_OK" if distance <= GOLDEN_HASH_THRESHOLD else "GOLDEN_MISMATCH", distance)


def in_range(value, lo, hi):
    return lo <= value <= hi


def evaluate(name: str, measured: dict, expected: dict) -> tuple[str, list[str]]:
    """Returns (verdict, reasons). verdict in {PASS, FAIL, REVIEW}."""
    reasons = []
    sr = expected.get("size_range")
    if sr:
        (wlo, whi), (hlo, hhi) = sr
        if not in_range(measured["width"], wlo, whi):
            reasons.append(f"BBOX_MISMATCH width={measured['width']} not in [{wlo},{whi}]")
        if not in_range(measured["height"], hlo, hhi):
            reasons.append(f"BBOX_MISMATCH height={measured['height']} not in [{hlo},{hhi}]")
    cmin = expected.get("alpha_coverage_min")
    if cmin is not None and measured["alpha_coverage"] < cmin:
        reasons.append(
            f"LOW_ALPHA_COVERAGE {measured['alpha_coverage']:.2f} < {cmin}"
        )

    golden_status, distance = compare_golden(name, measured["phash"])
    measured["golden_status"] = golden_status
    measured["golden_distance"] = distance

    if golden_status == "GOLDEN_MISMATCH":
        reasons.append(f"GOLDEN_MISMATCH phash distance={distance} > {GOLDEN_HASH_THRESHOLD}")
        return ("FAIL", reasons)

    if reasons:
        return ("FAIL", reasons)

    if golden_status == "NO_GOLDEN":
        return ("REVIEW", ["VISUAL_REVIEW_NEEDED no golden frozen yet"])

    return ("PASS", [])


def run_one(fx: dict, debug: bool) -> dict:
    name = fx["name"]
    out_dir = TESTS_DIR / "output"
    out_dir.mkdir(exist_ok=True)
    out_path = out_dir / f"{name}.png"

    cmd = [
        sys.executable,
        str(SEGMENT_SCRIPT),
        "--image", fx["image"],
        "--output", str(out_path),
        "--margin", str(fx["margin"]),
        "--bot-margin", str(fx["bot_margin"]),
    ]
    if "bbox" in fx and fx["bbox"]:
        cmd += ["--bbox", *map(str, fx["bbox"])]

    t0 = time.time()
    proc = subprocess.run(cmd, capture_output=True, text=True)
    elapsed = time.time() - t0

    result = {
        "name": name,
        "tags": fx.get("expected", {}).get("tags", []),
        "elapsed_s": round(elapsed, 1),
        "stdout_tail": proc.stdout.strip().splitlines()[-3:],
        "stderr": proc.stderr.strip(),
    }

    if proc.returncode != 0:
        result["verdict"] = "FAIL"
        result["reasons"] = [f"CROP_FAIL exit={proc.returncode}"]
        result["measured"] = None
        return result

    measured = measure(out_path)
    result["measured"] = measured
    verdict, reasons = evaluate(name, measured, fx.get("expected", {}))
    result["verdict"] = verdict
    result["reasons"] = reasons
    result["output"] = str(out_path)

    if debug and verdict == "FAIL":
        save_debug(fx, name)

    return result


def save_debug(fx: dict, name: str):
    """SAM 원본 마스크 + 컨투어 시각화 저장 (Step 2 분석용)."""
    try:
        from rembg import remove, new_session
        import cv2
    except ImportError as e:
        print(f"  [debug skip] {e}")
        return

    img = Image.open(fx["image"]).convert("RGB")
    if fx.get("bbox"):
        l, t, r, b = fx["bbox"]
        m = fx["margin"]
        w, h = img.size
        img = img.crop((max(0, l - m), max(0, t - m), min(w, r + m + 20), min(h, b + m)))

    cw, ch = img.size
    upscaled = img.resize((cw * 2, ch * 2), Image.LANCZOS)
    sam_out = remove(upscaled, session=new_session("sam")).resize((cw, ch), Image.LANCZOS)
    sam_out.save(DEBUG_DIR / f"{name}_sam_mask.png")

    arr = np.array(sam_out)
    mask_bin = (arr[:, :, 3] > 30).astype(np.uint8) * 255
    contours, _ = cv2.findContours(mask_bin, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    if contours:
        main = sorted(contours, key=cv2.contourArea, reverse=True)[0]
        eps = 0.02 * cv2.arcLength(main, True)
        approx = cv2.approxPolyDP(main, eps, True)
        vis = np.array(img).copy()
        cv2.drawContours(vis, [main], -1, (0, 255, 0), 1)
        cv2.drawContours(vis, [approx], -1, (255, 0, 0), 2)
        Image.fromarray(vis).save(DEBUG_DIR / f"{name}_contour.png")


def write_report(results: list[dict], path: Path):
    lines = ["# asset-extract 테스트 결과", ""]
    pass_n = sum(1 for r in results if r["verdict"] == "PASS")
    fail_n = sum(1 for r in results if r["verdict"] == "FAIL")
    review_n = sum(1 for r in results if r["verdict"] == "REVIEW")
    lines.append(f"- 총 {len(results)}개 — PASS {pass_n}, FAIL {fail_n}, REVIEW {review_n}")
    lines.append("")
    lines.append("| 케이스 | 결과 | 크기 | α커버 | golden | 시간 | 태그 | 사유 |")
    lines.append("|---|---|---|---|---|---|---|---|")
    for r in results:
        m = r.get("measured") or {}
        size = f"{m.get('width', '-')}x{m.get('height', '-')}"
        cov = f"{m.get('alpha_coverage', 0):.2f}" if m else "-"
        gs = m.get("golden_status", "-")
        gd = m.get("golden_distance")
        gcell = f"{gs}({gd})" if gd is not None else gs
        tags = ",".join(r["tags"])
        reasons = "; ".join(r["reasons"]) or "-"
        lines.append(
            f"| {r['name']} | {r['verdict']} | {size} | {cov} | {gcell} | {r['elapsed_s']}s | {tags} | {reasons} |"
        )
    lines.append("")

    fails = [r for r in results if r["verdict"] == "FAIL"]
    if fails:
        lines.append("## 실패 분류")
        from collections import Counter
        cats = Counter()
        for r in fails:
            for reason in r["reasons"]:
                cats[reason.split()[0]] += 1
        for cat, n in cats.most_common():
            lines.append(f"- **{cat}**: {n}건")

    path.write_text("\n".join(lines))
    print(f"\nReport: {path}")


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--all", action="store_true")
    p.add_argument("--fixture", help="단일 fixture 이름 (확장자 제외)")
    p.add_argument("--debug", action="store_true", help="실패 시 SAM mask/contour 저장")
    p.add_argument("--report", default=str(TESTS_DIR / "report.md"))
    args = p.parse_args()

    if args.fixture:
        fixtures = [FIXTURES_DIR / f"{args.fixture}.json"]
    elif args.all:
        fixtures = sorted(FIXTURES_DIR.glob("*.json"))
    else:
        p.error("--all 또는 --fixture 필요")

    if not fixtures:
        print("fixture 없음", file=sys.stderr)
        sys.exit(1)

    results = []
    for fp in fixtures:
        if not fp.exists():
            print(f"NOT FOUND: {fp}", file=sys.stderr)
            continue
        fx = load_fixture(fp)
        print(f"\n=== {fx['name']} ===")
        r = run_one(fx, args.debug)
        print(f"  → {r['verdict']} {r.get('measured', {})}")
        if r["reasons"]:
            for reason in r["reasons"]:
                print(f"    - {reason}")
        results.append(r)

    write_report(results, Path(args.report))
    sys.exit(0 if all(r["verdict"] in ("PASS", "REVIEW") for r in results) else 1)


if __name__ == "__main__":
    main()
