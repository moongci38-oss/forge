# File Upload Service Implementation Plan

**Goal:** Build an image upload service that accepts jpg/png/webp files (max 5MB), resizes them to thumbnail/medium/large, stores them in S3, and returns CDN URLs.

**Architecture:** Multipart form upload endpoint validates file type and size, then uses Sharp to produce 3 resized variants in parallel, uploads all variants to S3 under a UUID-keyed prefix, and returns a JSON response with 3 CDN URLs. No database required — S3 key structure encodes all metadata.

**Tech Stack:** Node.js, TypeScript, Express, Multer (multipart parsing), Sharp (image resizing), AWS SDK v3 S3 client, Jest + Supertest (testing)

---

## Size Definitions

| Variant    | Width | Height | Fit     |
|------------|-------|--------|---------|
| thumbnail  | 150   | 150    | cover   |
| medium     | 800   | 600    | inside  |
| large      | 1920  | 1080   | inside  |

S3 key pattern: `uploads/{uuid}/{variant}.{ext}`
CDN URL pattern: `https://{CDN_DOMAIN}/uploads/{uuid}/{variant}.{ext}`

---

### Task 1: Project Scaffold

**Files:**
- Create: `src/config.ts`
- Create: `src/index.ts`
- Create: `package.json` (if starting fresh)
- Create: `tsconfig.json`

**Step 1: Install dependencies**
```bash
npm init -y
npm install express multer @aws-sdk/client-s3 sharp uuid
npm install -D typescript ts-node @types/node @types/express @types/multer @types/sharp @types/uuid jest ts-jest supertest @types/supertest @types/jest
npx tsc --init
```

**Step 2: Write `src/config.ts`**
```typescript
export const config = {
  port: Number(process.env.PORT) || 3000,
  aws: {
    region: process.env.AWS_REGION!,
    bucket: process.env.AWS_S3_BUCKET!,
    cdnDomain: process.env.CDN_DOMAIN!,
  },
  upload: {
    maxBytes: 5 * 1024 * 1024, // 5 MB
    allowedMimeTypes: ['image/jpeg', 'image/png', 'image/webp'] as const,
  },
  sizes: {
    thumbnail: { width: 150, height: 150, fit: 'cover' as const },
    medium:    { width: 800, height: 600, fit: 'inside' as const },
    large:     { width: 1920, height: 1080, fit: 'inside' as const },
  },
};

export type SizeName = keyof typeof config.sizes;
```

**Step 3: Write minimal `src/index.ts`**
```typescript
import express from 'express';
import { config } from './config';

const app = express();

app.get('/health', (_req, res) => res.json({ ok: true }));

app.listen(config.port, () => {
  console.log(`Listening on :${config.port}`);
});

export { app };
```

**Step 4: Commit**
```bash
git add -A && git commit -m "chore: project scaffold"
```

---

### Task 2: Validation Middleware

**Files:**
- Create: `src/middleware/validateUpload.ts`
- Create: `src/middleware/validateUpload.test.ts`

**Step 1: Write the failing test**
```typescript
// src/middleware/validateUpload.test.ts
import request from 'supertest';
import express from 'express';
import multer from 'multer';
import { validateUpload } from './validateUpload';

const app = express();
const upload = multer({ storage: multer.memoryStorage() });
app.post('/test', upload.single('file'), validateUpload, (_req, res) => res.json({ ok: true }));

describe('validateUpload middleware', () => {
  it('rejects missing file', async () => {
    const res = await request(app).post('/test');
    expect(res.status).toBe(400);
    expect(res.body.error).toMatch(/file required/i);
  });

  it('rejects unsupported mime type', async () => {
    const res = await request(app)
      .post('/test')
      .attach('file', Buffer.from('data'), { filename: 'doc.pdf', contentType: 'application/pdf' });
    expect(res.status).toBe(415);
    expect(res.body.error).toMatch(/unsupported/i);
  });

  it('rejects file over 5MB', async () => {
    const big = Buffer.alloc(6 * 1024 * 1024);
    const res = await request(app)
      .post('/test')
      .attach('file', big, { filename: 'big.jpg', contentType: 'image/jpeg' });
    expect(res.status).toBe(413);
    expect(res.body.error).toMatch(/too large/i);
  });

  it('passes valid jpeg under 5MB', async () => {
    const small = Buffer.alloc(1024);
    const res = await request(app)
      .post('/test')
      .attach('file', small, { filename: 'photo.jpg', contentType: 'image/jpeg' });
    expect(res.status).toBe(200);
  });
});
```

**Step 2: Run test to verify it fails**
```bash
npx jest validateUpload --no-coverage
# Expected: all tests fail (validateUpload does not exist yet)
```

**Step 3: Write `src/middleware/validateUpload.ts`**
```typescript
import { Request, Response, NextFunction } from 'express';
import { config } from '../config';

export function validateUpload(req: Request, res: Response, next: NextFunction) {
  if (!req.file) {
    res.status(400).json({ error: 'File required' });
    return;
  }

  if (!(config.upload.allowedMimeTypes as readonly string[]).includes(req.file.mimetype)) {
    res.status(415).json({ error: `Unsupported type: ${req.file.mimetype}` });
    return;
  }

  if (req.file.size > config.upload.maxBytes) {
    res.status(413).json({ error: 'File too large (max 5 MB)' });
    return;
  }

  next();
}
```

**Step 4: Run test to verify it passes**
```bash
npx jest validateUpload --no-coverage
# Expected: 4 passing
```

**Step 5: Commit**
```bash
git add -A && git commit -m "feat: upload validation middleware"
```

---

### Task 3: Image Resizer

**Files:**
- Create: `src/services/resizer.ts`
- Create: `src/services/resizer.test.ts`
- Create: `test-fixtures/sample.jpg` (one-time setup)

**Step 1: Generate test fixture**
```bash
mkdir -p test-fixtures
node -e "
const sharp = require('sharp');
sharp({ create: { width: 400, height: 300, channels: 3, background: { r: 100, g: 150, b: 200 } } })
  .jpeg().toFile('test-fixtures/sample.jpg');
"
```

**Step 2: Write the failing test**
```typescript
// src/services/resizer.test.ts
import * as fs from 'fs';
import * as path from 'path';
import sharp from 'sharp';
import { resizeAll } from './resizer';

const samplePath = path.resolve(__dirname, '../../test-fixtures/sample.jpg');

describe('resizeAll', () => {
  let sampleBuffer: Buffer;

  beforeAll(() => {
    sampleBuffer = fs.readFileSync(samplePath);
  });

  it('returns buffers for all 3 sizes', async () => {
    const result = await resizeAll(sampleBuffer, 'image/jpeg');
    expect(Object.keys(result).sort()).toEqual(['large', 'medium', 'thumbnail']);
    for (const buf of Object.values(result)) {
      expect(buf.length).toBeGreaterThan(0);
    }
  });

  it('thumbnail is ≤ 150×150', async () => {
    const result = await resizeAll(sampleBuffer, 'image/jpeg');
    const meta = await sharp(result.thumbnail).metadata();
    expect(meta.width).toBeLessThanOrEqual(150);
    expect(meta.height).toBeLessThanOrEqual(150);
  });

  it('preserves webp format', async () => {
    const webpBuf = await sharp(sampleBuffer).webp().toBuffer();
    const result = await resizeAll(webpBuf, 'image/webp');
    const meta = await sharp(result.medium).metadata();
    expect(meta.format).toBe('webp');
  });
});
```

**Step 3: Run test to verify it fails**
```bash
npx jest resizer --no-coverage
# Expected: all tests fail
```

**Step 4: Write `src/services/resizer.ts`**
```typescript
import sharp, { FitEnum } from 'sharp';
import { config, SizeName } from '../config';

const MIME_TO_FORMAT: Record<string, keyof sharp.FormatEnum> = {
  'image/jpeg': 'jpeg',
  'image/png':  'png',
  'image/webp': 'webp',
};

export async function resizeAll(
  input: Buffer,
  mimeType: string,
): Promise<Record<SizeName, Buffer>> {
  const format = MIME_TO_FORMAT[mimeType] ?? 'jpeg';

  const entries = await Promise.all(
    (Object.entries(config.sizes) as [SizeName, typeof config.sizes[SizeName]][]).map(
      async ([name, dims]) => {
        const buf = await sharp(input)
          .resize(dims.width, dims.height, { fit: dims.fit as keyof FitEnum })
          .toFormat(format)
          .toBuffer();
        return [name, buf] as const;
      },
    ),
  );

  return Object.fromEntries(entries) as Record<SizeName, Buffer>;
}
```

**Step 5: Run test to verify it passes**
```bash
npx jest resizer --no-coverage
# Expected: 3 passing
```

**Step 6: Commit**
```bash
git add -A && git commit -m "feat: image resize service"
```

---

### Task 4: S3 Uploader

**Files:**
- Create: `src/services/s3Uploader.ts`
- Create: `src/services/s3Uploader.test.ts`

> Tests mock the S3 client — no real AWS calls needed.

**Step 1: Write the failing test**
```typescript
// src/services/s3Uploader.test.ts
jest.mock('@aws-sdk/client-s3');

import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
import { uploadVariants } from './s3Uploader';

const mockSend = jest.fn().mockResolvedValue({});
(S3Client as jest.Mock).mockImplementation(() => ({ send: mockSend }));

describe('uploadVariants', () => {
  beforeEach(() => mockSend.mockClear());

  it('calls PutObjectCommand for each variant', async () => {
    const variants = {
      thumbnail: Buffer.from('t'),
      medium:    Buffer.from('m'),
      large:     Buffer.from('l'),
    };
    await uploadVariants('abc-uuid', variants, 'image/jpeg');
    expect(mockSend).toHaveBeenCalledTimes(3);
  });

  it('uses correct S3 key structure', async () => {
    const variants = { thumbnail: Buffer.from('t'), medium: Buffer.from('m'), large: Buffer.from('l') };
    await uploadVariants('my-uuid', variants, 'image/png');

    const keys = mockSend.mock.calls.map(
      (call: any) => (call[0] as InstanceType<typeof PutObjectCommand>).input.Key,
    );
    expect(keys).toContain('uploads/my-uuid/thumbnail.png');
    expect(keys).toContain('uploads/my-uuid/medium.png');
    expect(keys).toContain('uploads/my-uuid/large.png');
  });

  it('returns CDN URLs for all variants', async () => {
    const variants = { thumbnail: Buffer.from('t'), medium: Buffer.from('m'), large: Buffer.from('l') };
    const result = await uploadVariants('x-uuid', variants, 'image/webp');
    expect(result.thumbnail).toMatch(/x-uuid\/thumbnail\.webp$/);
    expect(result.medium).toMatch(/x-uuid\/medium\.webp$/);
    expect(result.large).toMatch(/x-uuid\/large\.webp$/);
  });
});
```

**Step 2: Run test to verify it fails**
```bash
npx jest s3Uploader --no-coverage
```

**Step 3: Write `src/services/s3Uploader.ts`**
```typescript
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
import { config, SizeName } from '../config';

const MIME_TO_EXT: Record<string, string> = {
  'image/jpeg': 'jpg',
  'image/png':  'png',
  'image/webp': 'webp',
};

const s3 = new S3Client({ region: config.aws.region });

export async function uploadVariants(
  uuid: string,
  variants: Record<SizeName, Buffer>,
  mimeType: string,
): Promise<Record<SizeName, string>> {
  const ext = MIME_TO_EXT[mimeType] ?? 'jpg';

  await Promise.all(
    (Object.entries(variants) as [SizeName, Buffer][]).map(([name, body]) =>
      s3.send(new PutObjectCommand({
        Bucket:       config.aws.bucket,
        Key:          `uploads/${uuid}/${name}.${ext}`,
        Body:         body,
        ContentType:  mimeType,
        CacheControl: 'public, max-age=31536000, immutable',
      })),
    ),
  );

  return Object.fromEntries(
    (Object.keys(variants) as SizeName[]).map((name) => [
      name,
      `https://${config.aws.cdnDomain}/uploads/${uuid}/${name}.${ext}`,
    ]),
  ) as Record<SizeName, string>;
}
```

**Step 4: Run test to verify it passes**
```bash
npx jest s3Uploader --no-coverage
# Expected: 3 passing
```

**Step 5: Commit**
```bash
git add -A && git commit -m "feat: S3 upload service"
```

---

### Task 5: Upload Route

**Files:**
- Create: `src/routes/upload.ts`
- Create: `src/routes/upload.test.ts`
- Modify: `src/index.ts`

**Step 1: Write the failing test**
```typescript
// src/routes/upload.test.ts
jest.mock('../services/resizer');
jest.mock('../services/s3Uploader');

import request from 'supertest';
import { app } from '../index';
import { resizeAll } from '../services/resizer';
import { uploadVariants } from '../services/s3Uploader';

const mockResize = resizeAll as jest.MockedFunction<typeof resizeAll>;
const mockUpload = uploadVariants as jest.MockedFunction<typeof uploadVariants>;

describe('POST /upload', () => {
  const fakeCdnUrls = {
    thumbnail: 'https://cdn.example.com/uploads/uuid/thumbnail.jpg',
    medium:    'https://cdn.example.com/uploads/uuid/medium.jpg',
    large:     'https://cdn.example.com/uploads/uuid/large.jpg',
  };

  beforeEach(() => {
    mockResize.mockResolvedValue({ thumbnail: Buffer.alloc(1), medium: Buffer.alloc(1), large: Buffer.alloc(1) });
    mockUpload.mockResolvedValue(fakeCdnUrls);
  });

  afterEach(() => jest.clearAllMocks());

  it('returns 400 with no file', async () => {
    const res = await request(app).post('/upload');
    expect(res.status).toBe(400);
  });

  it('returns 415 for pdf', async () => {
    const res = await request(app)
      .post('/upload')
      .attach('file', Buffer.alloc(100), { filename: 'a.pdf', contentType: 'application/pdf' });
    expect(res.status).toBe(415);
  });

  it('returns CDN URLs for valid jpeg', async () => {
    const res = await request(app)
      .post('/upload')
      .attach('file', Buffer.alloc(1024), { filename: 'photo.jpg', contentType: 'image/jpeg' });
    expect(res.status).toBe(200);
    expect(res.body).toMatchObject({
      urls: {
        thumbnail: expect.stringContaining('thumbnail'),
        medium:    expect.stringContaining('medium'),
        large:     expect.stringContaining('large'),
      },
    });
  });

  it('calls resize then upload in order', async () => {
    const order: string[] = [];
    mockResize.mockImplementation(async () => { order.push('resize'); return { thumbnail: Buffer.alloc(1), medium: Buffer.alloc(1), large: Buffer.alloc(1) }; });
    mockUpload.mockImplementation(async () => { order.push('upload'); return fakeCdnUrls; });

    await request(app)
      .post('/upload')
      .attach('file', Buffer.alloc(1024), { filename: 'x.jpg', contentType: 'image/jpeg' });

    expect(order).toEqual(['resize', 'upload']);
  });
});
```

**Step 2: Run test to verify it fails**
```bash
npx jest upload.test --no-coverage
```

**Step 3: Write `src/routes/upload.ts`**
```typescript
import { Router } from 'express';
import multer from 'multer';
import { v4 as uuidv4 } from 'uuid';
import { validateUpload } from '../middleware/validateUpload';
import { resizeAll } from '../services/resizer';
import { uploadVariants } from '../services/s3Uploader';

const router = Router();
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 5 * 1024 * 1024 },
});

router.post('/', upload.single('file'), validateUpload, async (req, res) => {
  try {
    const file = req.file!;
    const uuid = uuidv4();
    const variants = await resizeAll(file.buffer, file.mimetype);
    const urls = await uploadVariants(uuid, variants, file.mimetype);
    res.json({ uuid, urls });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Upload failed' });
  }
});

export { router as uploadRouter };
```

**Step 4: Register route in `src/index.ts`**
```typescript
import express from 'express';
import { config } from './config';
import { uploadRouter } from './routes/upload';

const app = express();

app.get('/health', (_req, res) => res.json({ ok: true }));
app.use('/upload', uploadRouter);

app.listen(config.port, () => {
  console.log(`Listening on :${config.port}`);
});

export { app };
```

**Step 5: Run test to verify it passes**
```bash
npx jest upload.test --no-coverage
# Expected: 4 passing
```

**Step 6: Commit**
```bash
git add -A && git commit -m "feat: POST /upload endpoint"
```

---

### Task 6: Wiring & Final Check

**Files:**
- Create: `.env.example`
- Create: `jest.config.ts`

**Step 1: Write `jest.config.ts`**
```typescript
import type { Config } from 'jest';

const config: Config = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  clearMocks: true,
};

export default config;
```

**Step 2: Write `.env.example`**
```
PORT=3000
AWS_REGION=us-east-1
AWS_S3_BUCKET=your-bucket-name
CDN_DOMAIN=cdn.yourdomain.com
```

**Step 3: Run full test suite**
```bash
npx jest --no-coverage
# Expected: 14 tests passing across 4 suites
#   validateUpload  4 passing
#   resizer         3 passing
#   s3Uploader      3 passing
#   upload route    4 passing
```

**Step 4: Commit**
```bash
git add -A && git commit -m "chore: jest config + env example"
```

---

## Manual Smoke Test (Real AWS)

```bash
# Set env vars and start
AWS_REGION=us-east-1 AWS_S3_BUCKET=my-bucket CDN_DOMAIN=cdn.example.com \
  npx ts-node src/index.ts

# In another terminal
curl -s -F "file=@/path/to/photo.jpg" http://localhost:3000/upload | jq .
# Expected:
# {
#   "uuid": "xxxxxxxx-...",
#   "urls": {
#     "thumbnail": "https://cdn.example.com/uploads/.../thumbnail.jpg",
#     "medium":    "https://cdn.example.com/uploads/.../medium.jpg",
#     "large":     "https://cdn.example.com/uploads/.../large.jpg"
#   }
# }
```

---

## Error Reference

| HTTP | Condition |
|------|-----------|
| 400  | No file attached |
| 413  | File > 5 MB |
| 415  | Not jpg/png/webp |
| 500  | Sharp or S3 failure |
