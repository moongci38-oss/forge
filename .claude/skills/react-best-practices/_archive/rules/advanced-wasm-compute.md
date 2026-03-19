---
title: "WASM으로 CPU 집약 연산 오프로드"
id: advanced-wasm-compute
impact: LOW
category: advanced-patterns
impactDescription: "JavaScript 대비 10-100x 연산 속도 — 이미지/데이터 처리"
tags: [react, performance, wasm, webassembly, computation]
---

# WASM으로 CPU 집약 연산 오프로드

> 이미지 처리, 데이터 압축, 암호화 등 CPU 집약 연산은 WebAssembly(WASM)로 구현하여 JavaScript 대비 10-100배 빠른 실행 속도를 달성한다.

## Incorrect

```tsx
// Before: JavaScript로 이미지 처리 — 느리고 메인 스레드 블로킹
'use client';

import { useState, useCallback } from 'react';

function ImageEditor({ imageData }: { imageData: ImageData }) {
  const [processed, setProcessed] = useState<ImageData | null>(null);

  const applyGrayscale = useCallback(() => {
    // JavaScript로 픽셀 단위 처리 — 1920x1080 이미지 기준 500ms+
    const { data, width, height } = imageData;
    const output = new Uint8ClampedArray(data.length);

    for (let i = 0; i < data.length; i += 4) {
      // 각 픽셀의 RGB → 그레이스케일 변환
      const gray = data[i] * 0.299 + data[i + 1] * 0.587 + data[i + 2] * 0.114;
      output[i] = gray;     // R
      output[i + 1] = gray; // G
      output[i + 2] = gray; // B
      output[i + 3] = data[i + 3]; // A
    }
    // 2,073,600 픽셀 × 4채널 = 8,294,400번 연산 — JS에서 매우 느림

    setProcessed(new ImageData(output, width, height));
  }, [imageData]);

  // 블러 필터 — 더 심각한 성능 문제
  const applyBlur = useCallback(() => {
    const { data, width, height } = imageData;
    const output = new Uint8ClampedArray(data.length);
    const kernelSize = 5;

    // O(width × height × kernelSize²) — 1080p에서 5초+
    for (let y = 0; y < height; y++) {
      for (let x = 0; x < width; x++) {
        let r = 0, g = 0, b = 0, count = 0;
        for (let ky = -kernelSize; ky <= kernelSize; ky++) {
          for (let kx = -kernelSize; kx <= kernelSize; kx++) {
            const px = Math.min(Math.max(x + kx, 0), width - 1);
            const py = Math.min(Math.max(y + ky, 0), height - 1);
            const idx = (py * width + px) * 4;
            r += data[idx];
            g += data[idx + 1];
            b += data[idx + 2];
            count++;
          }
        }
        const idx = (y * width + x) * 4;
        output[idx] = r / count;
        output[idx + 1] = g / count;
        output[idx + 2] = b / count;
        output[idx + 3] = data[idx + 3];
      }
    }

    setProcessed(new ImageData(output, width, height));
  }, [imageData]);

  return (
    <div>
      <button onClick={applyGrayscale}>그레이스케일</button>
      <button onClick={applyBlur}>블러</button>
    </div>
  );
}
```

## Correct

```tsx
// After: WASM + Web Worker로 이미지 처리 — 10-100x 빠름
// lib/wasm-loader.ts

let wasmModule: WebAssembly.Module | null = null;

export async function loadImageWasm(): Promise<ImageWasmExports> {
  if (!wasmModule) {
    // WASM 바이너리를 한 번 로드 후 캐싱
    const response = await fetch('/wasm/image-processor.wasm');
    const buffer = await response.arrayBuffer();
    wasmModule = await WebAssembly.compile(buffer);
  }

  const instance = await WebAssembly.instantiate(wasmModule, {
    env: {
      memory: new WebAssembly.Memory({ initial: 256, maximum: 512 }),
    },
  });

  return instance.exports as ImageWasmExports;
}

interface ImageWasmExports {
  memory: WebAssembly.Memory;
  grayscale: (ptr: number, length: number) => void;
  blur: (ptr: number, width: number, height: number, radius: number) => void;
  malloc: (size: number) => number;
  free: (ptr: number) => void;
}
```

```tsx
// hooks/useImageProcessor.ts — WASM + Worker 조합
'use client';

import { useEffect, useRef, useState, useCallback } from 'react';

export function useImageProcessor() {
  const wasmRef = useRef<ImageWasmExports | null>(null);
  const [ready, setReady] = useState(false);

  useEffect(() => {
    // 컴포넌트 마운트 시 WASM 사전 로드
    loadImageWasm().then((wasm) => {
      wasmRef.current = wasm;
      setReady(true);
    });
  }, []);

  const processImage = useCallback(
    async (
      imageData: ImageData,
      filter: 'grayscale' | 'blur'
    ): Promise<ImageData> => {
      const wasm = wasmRef.current;
      if (!wasm) throw new Error('WASM 미초기화');

      const { data, width, height } = imageData;
      const byteLength = data.length;

      // WASM 메모리에 이미지 데이터 복사
      const ptr = wasm.malloc(byteLength);
      const wasmMemory = new Uint8ClampedArray(
        wasm.memory.buffer,
        ptr,
        byteLength
      );
      wasmMemory.set(data);

      // WASM에서 이미지 처리 — 네이티브에 가까운 속도
      switch (filter) {
        case 'grayscale':
          wasm.grayscale(ptr, byteLength);
          break;
        case 'blur':
          wasm.blur(ptr, width, height, 5);
          break;
      }

      // 처리된 데이터를 JavaScript로 복사
      const result = new Uint8ClampedArray(byteLength);
      result.set(
        new Uint8ClampedArray(wasm.memory.buffer, ptr, byteLength)
      );

      wasm.free(ptr);
      return new ImageData(result, width, height);
    },
    []
  );

  return { ready, processImage };
}
```

```tsx
// 컴포넌트에서 WASM 이미지 처리 사용
'use client';

import { useState, useTransition } from 'react';
import { useImageProcessor } from '@/hooks/useImageProcessor';

function ImageEditor({ imageData }: { imageData: ImageData }) {
  const { ready, processImage } = useImageProcessor();
  const [processed, setProcessed] = useState<ImageData | null>(null);
  const [isPending, startTransition] = useTransition();

  const handleFilter = (filter: 'grayscale' | 'blur') => {
    startTransition(async () => {
      const result = await processImage(imageData, filter);
      setProcessed(result);
    });
  };

  return (
    <div>
      <div className="flex gap-2">
        <button onClick={() => handleFilter('grayscale')} disabled={!ready}>
          {isPending ? '처리 중...' : '그레이스케일'}
        </button>
        <button onClick={() => handleFilter('blur')} disabled={!ready}>
          {isPending ? '처리 중...' : '블러'}
        </button>
      </div>
      {processed && <canvas ref={drawToCanvas(processed)} />}
    </div>
  );
}
```

## Why

JavaScript는 인터프리터/JIT 기반으로 실행되어 수치 연산에서 네이티브 코드 대비 10-100배 느리다. WebAssembly는 바이너리 포맷으로 미리 컴파일되어 네이티브에 가까운 속도로 실행된다. 이미지 처리, 데이터 압축, 암호화, 물리 시뮬레이션 등 CPU 집약 작업에서 극적인 성능 향상을 가져온다.

**정량적 효과:**
- 1080p 그레이스케일: JS 500ms → WASM 5ms (100x 개선)
- 1080p 블러(5px): JS 5000ms → WASM 50ms (100x 개선)
- JSON 파싱(10MB): JS 200ms → WASM(simd-json) 20ms (10x 개선)
- 데이터 압축(brotli): JS 2000ms → WASM 100ms (20x 개선)

**적용 기준:** 단순 DOM 조작이나 비즈니스 로직은 JavaScript로 충분. WASM은 수백만 회 수치 연산이 필요한 작업에 적합.

## References

- [MDN: WebAssembly](https://developer.mozilla.org/en-US/docs/WebAssembly)
- [web.dev: WebAssembly](https://web.dev/articles/webassembly)
- [Rust + WASM](https://rustwasm.github.io/docs/book/)
- [wasm-pack (Rust to WASM)](https://rustwasm.github.io/wasm-pack/)
