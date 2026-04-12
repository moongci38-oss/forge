#!/usr/bin/env python3
"""
segment_button.py — rembg SAM 기반 버튼/컴포넌트 추출

Usage:
  python3 segment_button.py --image <원본> --bbox L T R B --output <출력>
  python3 segment_button.py --image <원본> --bbox L T R B --output <출력> --shape trapezoid

Shape 모드:
  auto       — 컨투어 형태 자동 감지 (기본)
  trapezoid  — 4점 사다리꼴 강제 (바닥 연장 포함, baduki 스타일 버튼)
  contour    — SAM 알파 그대로 사용 (원형/비정형 유지)

파이프라인:
  1. bbox 크롭 (margin)
  2. 2x 업스케일 → rembg SAM 배경 제거
  3. shape 모드에 따라 마스크 생성
  4. 안티앨리어싱 + 타이트 트림

의존성: pip install rembg opencv-python-headless
"""

import argparse
import math
import sys
import numpy as np
import cv2
from PIL import Image, ImageFilter


def detect_shape(contour, mask_shape) -> str:
    """컨투어 형태 자동 감지: 'trapezoid' 또는 'contour'."""
    area = cv2.contourArea(contour)
    perimeter = cv2.arcLength(contour, True)
    if area < 50 or perimeter < 10:
        return "contour"

    circularity = 4 * math.pi * area / (perimeter * perimeter)
    if circularity > 0.75:
        return "contour"  # 원/둥근 사각 → 알파 유지

    approx = cv2.approxPolyDP(contour, 0.02 * perimeter, True)
    if len(approx) != 4:
        return "contour"  # 4점으로 단순화 안 됨 → 비정형

    pts = approx.reshape(-1, 2)
    x, y, w, h = cv2.boundingRect(contour)
    if w < h * 1.2:
        return "contour"  # 가로로 넓지 않으면 사다리꼴 가정 부적합

    rect_fill = area / (w * h)
    if rect_fill < 0.7:
        return "contour"

    return "trapezoid"


def mask_trapezoid(contour, crop_w, crop_h, bot_margin) -> np.ndarray:
    """4점 사다리꼴 피팅 + 바닥 연장. baduki 스타일 버튼 전용."""
    epsilon = 0.02 * cv2.arcLength(contour, True)
    approx = cv2.approxPolyDP(contour, epsilon, True)
    pts = approx.reshape(-1, 2)

    sorted_by_y = pts[pts[:, 1].argsort()]
    top_pts = sorted_by_y[:2]
    bot_pts = sorted_by_y[-2:]

    top_left = top_pts[top_pts[:, 0].argsort()][0]
    top_right = top_pts[top_pts[:, 0].argsort()][1]
    bot_left_orig = bot_pts[bot_pts[:, 0].argsort()][0]
    bot_right_orig = bot_pts[bot_pts[:, 0].argsort()][1]

    bot_y = min(int(max(bot_left_orig[1], bot_right_orig[1])) + bot_margin, crop_h - 1)

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
    print(f"사다리꼴: {final_poly.tolist()}")

    mask = np.zeros((crop_h, crop_w), dtype=np.uint8)
    cv2.fillPoly(mask, [final_poly], 255)
    return mask


def mask_contour(contour, sam_alpha, crop_w, crop_h) -> np.ndarray:
    """SAM 알파를 컨투어 내부로만 클리핑. 원형/비정형 유지."""
    mask = np.zeros((crop_h, crop_w), dtype=np.uint8)
    cv2.drawContours(mask, [contour], -1, 255, thickness=cv2.FILLED)
    # SAM의 원본 알파 그라디언트를 컨투어 내부에서 보존
    clipped = np.where(mask > 0, sam_alpha, 0).astype(np.uint8)
    print(f"컨투어 모드: {len(contour)}점, 알파 보존")
    return clipped


def run_sam(img):
    """rembg SAM 세그멘테이션 — 트라페조이드 모드 회귀 호환용."""
    from rembg import remove, new_session
    crop_w, crop_h = img.size
    upscaled = img.resize((crop_w * 2, crop_h * 2), Image.LANCZOS)
    result = remove(upscaled, session=new_session("sam")).resize((crop_w, crop_h), Image.LANCZOS)
    return np.array(result)[:, :, 3]


def run_border_segment(img, border_px=6, threshold_scale=2.5) -> np.ndarray:
    """테두리 색을 배경으로 샘플링 → LAB 거리 기반 전경 분리.
    다색 객체도 배경과 충분히 다르면 모두 전경으로 포함.
    """
    arr = np.array(img)
    h, w = arr.shape[:2]
    lab = cv2.cvtColor(arr, cv2.COLOR_RGB2LAB).astype(np.float32)

    # 테두리 픽셀 샘플링 (배경으로 간주)
    b = border_px
    border_pixels = np.vstack([
        lab[:b, :].reshape(-1, 3),
        lab[-b:, :].reshape(-1, 3),
        lab[:, :b].reshape(-1, 3),
        lab[:, -b:].reshape(-1, 3),
    ])
    bg_mean = border_pixels.mean(axis=0)
    bg_std = border_pixels.std(axis=0) + 1e-5

    # 각 픽셀의 배경 mean으로부터 정규화된 거리
    diff = (lab - bg_mean) / bg_std
    dist = np.sqrt((diff ** 2).sum(axis=2))
    # 거리 > threshold_scale → 전경
    mask = (dist > threshold_scale).astype(np.uint8) * 255

    # 모폴로지: 구멍 메우기 + 작은 노이즈 제거
    kernel = np.ones((5, 5), np.uint8)
    mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel, iterations=2)
    mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel, iterations=1)

    # 중심점이 포함된 컨투어만 유지 (다른 객체 배제)
    cx, cy = w // 2, h // 2
    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    if not contours:
        return mask
    target = None
    for c in sorted(contours, key=cv2.contourArea, reverse=True):
        if cv2.pointPolygonTest(c, (cx, cy), False) >= 0:
            target = c
            break
    if target is None:
        target = max(contours, key=cv2.contourArea)
    # 타겟 컨투어 내부를 모두 채움 (내부 구멍 포함)
    final = np.zeros_like(mask)
    cv2.drawContours(final, [target], -1, 255, thickness=cv2.FILLED)
    return final


def segment(image_path, output_path, bbox=None, margin=3, bot_margin=8, shape="auto"):
    full_img = Image.open(image_path).convert("RGB")
    print(f"이미지: {full_img.size[0]}x{full_img.size[1]}")

    if bbox:
        left, top, right, bottom = bbox
        w, h = full_img.size
        # 표준 크롭 (trapezoid 호환)
        l = max(0, left - margin)
        t = max(0, top - margin)
        r = min(w, right + margin + 20)
        b = min(h, bottom + margin)
        img = full_img.crop((l, t, r, b))
    else:
        img = full_img
    crop_w, crop_h = img.size
    print(f"크롭: {crop_w}x{crop_h}")

    # 1차: SAM 시도 (기존 v5 호환)
    sam_alpha = run_sam(img)
    mask_bin = (sam_alpha > 30).astype(np.uint8) * 255
    sam_coverage = (mask_bin > 0).sum() / mask_bin.size

    # SAM 품질 체크 — 너무 적거나 너무 많으면 border-segment 폴백
    fallback = False
    if sam_coverage < 0.10 or sam_coverage > 0.90:
        fallback = True
        print(f"⚠️  SAM 커버리지 이상 ({sam_coverage:.2f}) — border-segment 폴백")
    else:
        # 중심점 가드
        contours, _ = cv2.findContours(mask_bin, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        if contours:
            main_check = max(contours, key=cv2.contourArea)
            cx, cy = crop_w // 2, crop_h // 2
            if cv2.pointPolygonTest(main_check, (cx, cy), False) < 0:
                fallback = True
                print(f"⚠️  SAM 중심점 이탈 — border-segment 폴백")

    if fallback and bbox:
        # 더 넓은 bg 여유로 재크롭 후 border-segment
        bg_pad = 40
        l2 = max(0, left - bg_pad)
        t2 = max(0, top - bg_pad)
        r2 = min(w, right + bg_pad)
        b2 = min(h, bottom + bg_pad)
        img = full_img.crop((l2, t2, r2, b2))
        crop_w, crop_h = img.size
        actual_pad = min(left - l2, top - t2, r2 - right, b2 - bottom, bg_pad)
        mask_bin = run_border_segment(img, border_px=max(6, actual_pad - 2))
        sam_alpha = mask_bin
        print(f"border-segment 폴백: {crop_w}x{crop_h}")

    # 가장 큰 컨투어
    contours, _ = cv2.findContours(mask_bin, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    contours = sorted(contours, key=cv2.contourArea, reverse=True)
    if not contours:
        print("ERROR: 컨투어 없음", file=sys.stderr)
        sys.exit(1)
    main = contours[0]

    # 컨투어가 크롭의 90% 초과 — 배경 전체를 잡음, 반전 시도
    if cv2.contourArea(main) > 0.9 * crop_w * crop_h:
        print("⚠️  컨투어가 전체 크롭 차지 — 마스크 반전 시도", file=sys.stderr)
        mask_bin = 255 - mask_bin
        contours, _ = cv2.findContours(mask_bin, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        contours = sorted(contours, key=cv2.contourArea, reverse=True)
        if contours:
            main = contours[0]

    cx, cy = crop_w // 2, crop_h // 2
    if cv2.pointPolygonTest(main, (cx, cy), False) < 0:
        print(f"⚠️  경고: 중심점이 마스크 밖 — bbox를 더 타이트하게 조정 필요", file=sys.stderr)

    if shape == "auto":
        shape = detect_shape(main, (crop_h, crop_w))
        print(f"자동 감지: {shape}")

    if shape == "trapezoid":
        alpha = mask_trapezoid(main, crop_w, crop_h, bot_margin)
    else:
        alpha = mask_contour(main, sam_alpha, crop_w, crop_h)

    # 안티앨리어싱
    mask_pil = Image.fromarray(alpha, "L").filter(ImageFilter.GaussianBlur(radius=0.7))
    alpha = np.array(mask_pil)

    crop_arr = np.array(img)
    rgba = np.zeros((crop_h, crop_w, 4), dtype=np.uint8)
    rgba[:, :, :3] = crop_arr
    rgba[:, :, 3] = alpha

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
    p.add_argument("--image", required=True)
    p.add_argument("--bbox", nargs=4, type=int)
    p.add_argument("--output", required=True)
    p.add_argument("--margin", type=int, default=3)
    p.add_argument("--bot-margin", type=int, default=8, help="trapezoid 모드 전용 바닥 연장")
    p.add_argument("--shape", choices=["auto", "trapezoid", "contour"], default="auto")
    args = p.parse_args()
    bbox = tuple(args.bbox) if args.bbox else None
    segment(args.image, args.output, bbox, args.margin, args.bot_margin, args.shape)
