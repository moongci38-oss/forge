#!/usr/bin/env python3
"""
segment_button.py — rembg SAM + 다각형 피팅 기반 버튼 추출

Usage:
  python3 segment_button.py --image <원본이미지> --bbox L T R B --output <출력경로>
  python3 segment_button.py --image <크롭이미지> --output <출력경로>

파이프라인:
  1. bbox 크롭 (margin 추가)
  2. 2x 업스케일 → rembg SAM 배경 제거
  3. SAM 마스크 컨투어 → 다각형 피팅 (직선 엣지)
  4. 하단 연장 (다크 베이스 포함) + 안티앨리어싱
  5. 원본 픽셀 + 깨끗한 마스크 합성 → 타이트 트림

의존성: pip install rembg opencv-python-headless
"""

import argparse
import sys
import numpy as np
import cv2
from PIL import Image, ImageFilter


def segment_button(image_path: str, output_path: str, bbox: tuple = None, margin: int = 3, bot_margin: int = 8):
    from rembg import remove, new_session

    # 1. 이미지 로드 + 크롭
    img = Image.open(image_path).convert("RGB")
    print(f"이미지: {img.size[0]}x{img.size[1]}")

    if bbox:
        left, top, right, bottom = bbox
        w, h = img.size
        left = max(0, left - margin)
        top = max(0, top - margin)
        right = min(w, right + margin + 20)  # 우측 여유 더 넓게
        bottom = min(h, bottom + margin)
        img = img.crop((left, top, right, bottom))
        print(f"크롭: ({left},{top})→({right},{bottom}) = {img.size[0]}x{img.size[1]}")

    crop_w, crop_h = img.size

    # 2. 2x 업스케일 → rembg SAM
    upscaled = img.resize((crop_w * 2, crop_h * 2), Image.LANCZOS)
    session = new_session("sam")
    result = remove(upscaled, session=session)
    result_down = result.resize((crop_w, crop_h), Image.LANCZOS)
    print("rembg SAM 완료")

    # 3. SAM 마스크 → 컨투어 → 다각형 피팅
    arr = np.array(result_down)
    mask_bin = (arr[:, :, 3] > 30).astype(np.uint8) * 255
    contours, _ = cv2.findContours(mask_bin, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    contours = sorted(contours, key=cv2.contourArea, reverse=True)

    if not contours:
        print("ERROR: 컨투어 없음", file=sys.stderr)
        sys.exit(1)

    main = contours[0]
    epsilon = 0.02 * cv2.arcLength(main, True)
    approx = cv2.approxPolyDP(main, epsilon, True)
    pts = approx.reshape(-1, 2)
    print(f"다각형: {len(main)}점 → {len(pts)}점 피팅")

    # 4. 상단/하단 꼭짓점 분리 + 하단 연장
    sorted_by_y = pts[pts[:, 1].argsort()]
    top_pts = sorted_by_y[:2]
    bot_pts = sorted_by_y[-2:]

    top_left = top_pts[top_pts[:, 0].argsort()][0]
    top_right = top_pts[top_pts[:, 0].argsort()][1]
    bot_left_orig = bot_pts[bot_pts[:, 0].argsort()][0]
    bot_right_orig = bot_pts[bot_pts[:, 0].argsort()][1]

    bot_y = min(int(max(bot_left_orig[1], bot_right_orig[1])) + bot_margin, crop_h - 1)

    # 대각선 기울기 유지하면서 하단 연장
    def extend_x(top_pt, bot_pt, target_y):
        if bot_pt[1] == top_pt[1]:
            return int(bot_pt[0])
        slope = (bot_pt[0] - top_pt[0]) / (bot_pt[1] - top_pt[1])
        return int(top_pt[0] + slope * (target_y - top_pt[1]))

    new_bl_x = extend_x(top_left, bot_left_orig, bot_y)
    new_br_x = extend_x(top_right, bot_right_orig, bot_y)

    final_poly = np.array([
        [top_left[0], top_left[1]],
        [top_right[0], top_right[1]],
        [new_br_x, bot_y],
        [new_bl_x, bot_y],
    ], dtype=np.int32)
    print(f"최종 다각형: {final_poly.tolist()}")

    # 5. 깨끗한 마스크 + 안티앨리어싱
    clean_mask = np.zeros((crop_h, crop_w), dtype=np.uint8)
    cv2.fillPoly(clean_mask, [final_poly], 255)
    mask_pil = Image.fromarray(clean_mask, "L").filter(ImageFilter.GaussianBlur(radius=0.7))
    alpha = np.array(mask_pil)

    # 6. 원본 픽셀 + 마스크 합성
    crop_arr = np.array(img)
    rgba = np.zeros((crop_h, crop_w, 4), dtype=np.uint8)
    rgba[:, :, :3] = crop_arr
    rgba[:, :, 3] = alpha

    # 7. 타이트 트림
    trim = alpha > 5
    rows = np.any(trim, axis=1)
    cols = np.any(trim, axis=0)
    if not rows.any():
        print("ERROR: 추출된 픽셀 없음", file=sys.stderr)
        sys.exit(1)

    t, b = np.where(rows)[0][[0, -1]]
    l, r = np.where(cols)[0][[0, -1]]
    trimmed = Image.fromarray(rgba[t:b + 1, l:r + 1], "RGBA")
    trimmed.save(output_path)
    print(f"저장: {trimmed.size[0]}x{trimmed.size[1]} → {output_path}")


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--image", required=True, help="원본 이미지 경로")
    p.add_argument("--bbox", nargs=4, type=int, help="left top right bottom (선택)")
    p.add_argument("--output", required=True, help="출력 PNG 경로")
    p.add_argument("--margin", type=int, default=3, help="bbox 상단/좌우 여유 (기본: 3)")
    p.add_argument("--bot-margin", type=int, default=8, help="SAM 하단 연장 픽셀 (기본: 8)")
    args = p.parse_args()
    bbox = tuple(args.bbox) if args.bbox else None
    segment_button(args.image, args.output, bbox, args.margin, args.bot_margin)
