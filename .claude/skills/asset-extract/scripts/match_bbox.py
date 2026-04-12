#!/usr/bin/env python3
"""
match_bbox.py — /clip 이미지를 원본에서 멀티스케일 템플릿 매칭으로 찾아 bbox 반환

Usage:
  python3 match_bbox.py --original <원본경로> --clip <클립경로>

Output (stdout):
  left,top,right,bottom
  score:<1-NCC, 0=완벽매칭 1=불일치>
  scale:<매칭에 사용된 clip 스케일>

알고리즘:
  1. clip을 여러 스케일(0.3~2.0)로 리사이즈하며 cv2.matchTemplate (TM_CCOEFF_NORMED)
  2. 각 스케일의 최고 매칭 점수 추적
  3. 가장 높은 NCC 점수의 스케일+위치를 반환
  4. NCC는 scale/crop/약간의 색상 변화에 SAD보다 훨씬 강건함

의존성: opencv-python-headless
"""

import argparse
import sys
import cv2
import numpy as np
from PIL import Image


def find_bbox(original_path: str, clip_path: str):
    orig = np.array(Image.open(original_path).convert("RGB"))
    clip = np.array(Image.open(clip_path).convert("RGB"))

    oh, ow = orig.shape[:2]
    orig_gray = cv2.cvtColor(orig, cv2.COLOR_RGB2GRAY)
    clip_gray = cv2.cvtColor(clip, cv2.COLOR_RGB2GRAY)

    best = {"score": -1.0, "pos": (0, 0), "scale": 1.0, "size": clip_gray.shape}

    # 최소 템플릿 크기 — 작은 템플릿은 NCC false positive가 잦아서 제외
    # 원본 짧은 변의 3% 또는 60px 중 큰 값
    min_dim = max(60, min(oh, ow) // 33)

    # 멀티스케일: 작은 스케일부터 큰 스케일까지
    scales = [0.25, 0.35, 0.5, 0.7, 0.85, 1.0, 1.2, 1.5, 2.0, 2.7, 3.5, 4.5, 6.0]
    for s in scales:
        ch0, cw0 = clip_gray.shape
        ch, cw = int(ch0 * s), int(cw0 * s)
        if min(ch, cw) < min_dim or ch >= oh or cw >= ow:
            continue
        resized = cv2.resize(clip_gray, (cw, ch), interpolation=cv2.INTER_AREA if s < 1 else cv2.INTER_CUBIC)
        result = cv2.matchTemplate(orig_gray, resized, cv2.TM_CCOEFF_NORMED)
        _, max_val, _, max_loc = cv2.minMaxLoc(result)
        if max_val > best["score"]:
            best["score"] = max_val
            best["pos"] = max_loc
            best["scale"] = s
            best["size"] = (ch, cw)

    left, top = best["pos"]
    ch, cw = best["size"]
    right, bottom = left + cw, top + ch
    # SAD 호환 점수(낮을수록 좋음)로 변환 — 1 - NCC
    score = 1.0 - best["score"]

    print(f"{left},{top},{right},{bottom}")
    print(f"score:{score:.3f}")
    print(f"scale:{best['scale']:.2f}")


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--original", required=True)
    p.add_argument("--clip", required=True)
    args = p.parse_args()
    find_bbox(args.original, args.clip)
