#!/usr/bin/env python3
"""
match_bbox.py — /clip 이미지를 원본에서 템플릿 매칭으로 찾아 bbox 반환

Usage:
  python3 match_bbox.py --original <원본경로> --clip <클립경로>

Output (stdout):
  left,top,right,bottom
  score:<SAD점수>
"""

import argparse
import sys
import numpy as np
from PIL import Image


def find_bbox(original_path: str, clip_path: str):
    orig = np.array(Image.open(original_path).convert("RGB"), dtype=np.float32)
    clip = np.array(Image.open(clip_path).convert("RGB"), dtype=np.float32)

    oh, ow = orig.shape[:2]
    ch, cw = clip.shape[:2]

    # clip이 원본보다 크면 비율 유지 스케일 다운
    if ch > oh or cw > ow:
        scale = min(oh / ch, ow / cw) * 0.95
        new_w, new_h = int(cw * scale), int(ch * scale)
        clip = np.array(
            Image.fromarray(clip.astype(np.uint8)).resize((new_w, new_h)),
            dtype=np.float32,
        )
        ch, cw = clip.shape[:2]

    if ch > oh or cw > ow:
        print("ERROR: clip이 원본보다 큽니다", file=sys.stderr)
        sys.exit(1)

    # 슬라이딩 윈도우 SAD (Sum of Absolute Differences)
    step = max(1, min(oh, ow) // 100)
    best_score = float("inf")
    best_pos = (0, 0)

    for y in range(0, oh - ch + 1, step):
        for x in range(0, ow - cw + 1, step):
            region = orig[y : y + ch, x : x + cw]
            score = np.abs(region - clip).mean()
            if score < best_score:
                best_score = score
                best_pos = (x, y)

    # best_pos 주변 정밀 탐색 (step 범위)
    bx, by = best_pos
    for y in range(max(0, by - step), min(oh - ch + 1, by + step + 1)):
        for x in range(max(0, bx - step), min(ow - cw + 1, bx + step + 1)):
            region = orig[y : y + ch, x : x + cw]
            score = np.abs(region - clip).mean()
            if score < best_score:
                best_score = score
                best_pos = (x, y)

    left, top = best_pos
    right, bottom = left + cw, top + ch

    print(f"{left},{top},{right},{bottom}")
    print(f"score:{best_score:.2f}")


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--original", required=True)
    p.add_argument("--clip", required=True)
    args = p.parse_args()
    find_bbox(args.original, args.clip)
