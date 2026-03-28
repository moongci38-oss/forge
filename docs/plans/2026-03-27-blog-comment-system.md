# Blog Comment System Implementation Plan

**Goal:** Build a nested comment system for a blog where users can post, reply (max depth 3), edit, and delete their own comments.

**Architecture:** REST API using Express.js + PostgreSQL (adjacency list model for nesting). Comments store `parent_id` (nullable FK to self) and `depth` (0–2). Depth is enforced at the DB constraint level AND the API layer. Ownership checks run before any mutating operation. Soft delete (deleted_at) preserves thread structure.

**Tech Stack:** Node.js, Express, PostgreSQL (pg/node-postgres), Jest, Supertest

---

## Prerequisites

```bash
npm install express pg express-validator
npm install --save-dev jest supertest
```

PostgreSQL schema migration runner assumed (e.g. `psql -f migration.sql` or your existing migration tool).

---

## Task 1: Database Schema

**Files:**
- Create: `migrations/003_create_comments.sql`

**Step 1: Write the migration**
```sql
-- migrations/003_create_comments.sql
CREATE TABLE comments (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id     UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  author_id   UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  parent_id   UUID REFERENCES comments(id) ON DELETE CASCADE,
  depth       SMALLINT NOT NULL DEFAULT 0,
  body        TEXT NOT NULL,
  deleted_at  TIMESTAMPTZ,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT depth_max_2 CHECK (depth BETWEEN 0 AND 2)
);

CREATE INDEX idx_comments_post_id   ON comments(post_id);
CREATE INDEX idx_comments_parent_id ON comments(parent_id);
```

**Step 2: Apply migration**
```bash
psql $DATABASE_URL -f migrations/003_create_comments.sql
# Expected: CREATE TABLE / CREATE INDEX (no errors)
```

**Step 3: Verify constraint works**
```sql
-- Should fail:
INSERT INTO comments (post_id, author_id, depth, body)
VALUES ('...', '...', 3, 'too deep');
-- Expected: ERROR: new row violates check constraint "depth_max_2"
```

**Step 4: Commit**
```bash
git add migrations/003_create_comments.sql
git commit -m "chore: add comments table migration (max depth 2)"
```

---

## Task 2: Comment Repository

**Files:**
- Create: `src/comments/comment.repository.js`
- Test:   `src/comments/__tests__/comment.repository.test.js`

**Step 1: Write the failing tests**
```js
// src/comments/__tests__/comment.repository.test.js
const db = require('../../db');
const repo = require('../comment.repository');

beforeAll(() => db.migrate());
afterEach(() => db.query('TRUNCATE comments CASCADE'));
afterAll(() => db.end());

describe('create', () => {
  it('creates a root comment (depth 0)', async () => {
    const c = await repo.create({ postId: POST_ID, authorId: USER_ID, parentId: null, body: 'hi' });
    expect(c.depth).toBe(0);
    expect(c.parent_id).toBeNull();
  });

  it('sets depth = parent.depth + 1', async () => {
    const root  = await repo.create({ postId: POST_ID, authorId: USER_ID, parentId: null, body: 'root' });
    const child = await repo.create({ postId: POST_ID, authorId: USER_ID, parentId: root.id, body: 'child' });
    expect(child.depth).toBe(1);
  });

  it('rejects depth > 2 at DB level', async () => {
    const root  = await repo.create({ postId: POST_ID, authorId: USER_ID, parentId: null,   body: 'a' });
    const d1    = await repo.create({ postId: POST_ID, authorId: USER_ID, parentId: root.id, body: 'b' });
    const d2    = await repo.create({ postId: POST_ID, authorId: USER_ID, parentId: d1.id,   body: 'c' });
    await expect(
      repo.create({ postId: POST_ID, authorId: USER_ID, parentId: d2.id, body: 'd' })
    ).rejects.toThrow('depth_max_2');
  });
});

describe('findByPost', () => {
  it('returns all non-deleted comments for a post', async () => {
    await repo.create({ postId: POST_ID, authorId: USER_ID, parentId: null, body: 'visible' });
    const deleted = await repo.create({ postId: POST_ID, authorId: USER_ID, parentId: null, body: 'gone' });
    await repo.softDelete(deleted.id);

    const results = await repo.findByPost(POST_ID);
    expect(results).toHaveLength(1);
    expect(results[0].body).toBe('visible');
  });
});

describe('update', () => {
  it('updates body and updated_at', async () => {
    const c = await repo.create({ postId: POST_ID, authorId: USER_ID, parentId: null, body: 'old' });
    const updated = await repo.update(c.id, 'new');
    expect(updated.body).toBe('new');
    expect(updated.updated_at > c.updated_at).toBe(true);
  });
});

describe('softDelete', () => {
  it('sets deleted_at without removing the row', async () => {
    const c = await repo.create({ postId: POST_ID, authorId: USER_ID, parentId: null, body: 'hi' });
    await repo.softDelete(c.id);
    const row = await db.query('SELECT * FROM comments WHERE id=$1', [c.id]);
    expect(row.rows[0].deleted_at).not.toBeNull();
  });
});
```

**Step 2: Run tests — verify they fail**
```bash
npx jest comment.repository --no-coverage
# Expected: all tests FAIL (module not found)
```

**Step 3: Implement the repository**
```js
// src/comments/comment.repository.js
const db = require('../db');

async function create({ postId, authorId, parentId, body }) {
  let depth = 0;
  if (parentId) {
    const { rows } = await db.query('SELECT depth FROM comments WHERE id=$1', [parentId]);
    if (!rows[0]) throw new Error('Parent comment not found');
    depth = rows[0].depth + 1;
  }
  const { rows } = await db.query(
    `INSERT INTO comments (post_id, author_id, parent_id, depth, body)
     VALUES ($1,$2,$3,$4,$5) RETURNING *`,
    [postId, authorId, parentId, depth, body]
  );
  return rows[0];
}

async function findByPost(postId) {
  const { rows } = await db.query(
    `SELECT * FROM comments
     WHERE post_id=$1 AND deleted_at IS NULL
     ORDER BY created_at ASC`,
    [postId]
  );
  return rows;
}

async function findById(id) {
  const { rows } = await db.query('SELECT * FROM comments WHERE id=$1', [id]);
  return rows[0] ?? null;
}

async function update(id, body) {
  const { rows } = await db.query(
    `UPDATE comments SET body=$2, updated_at=NOW() WHERE id=$1 RETURNING *`,
    [id, body]
  );
  return rows[0];
}

async function softDelete(id) {
  await db.query(
    `UPDATE comments SET deleted_at=NOW() WHERE id=$1`,
    [id]
  );
}

module.exports = { create, findByPost, findById, update, softDelete };
```

**Step 4: Run tests — verify they pass**
```bash
npx jest comment.repository --no-coverage
# Expected: 6 tests passed
```

**Step 5: Commit**
```bash
git add src/comments/
git commit -m "feat: comment repository with soft delete and depth tracking"
```

---

## Task 3: Comment Service (business rules)

**Files:**
- Create: `src/comments/comment.service.js`
- Test:   `src/comments/__tests__/comment.service.test.js`

**Step 1: Write the failing tests**
```js
// src/comments/__tests__/comment.service.test.js
const service = require('../comment.service');
const repo    = require('../comment.repository');

jest.mock('../comment.repository');

const USER_A = 'user-a';
const USER_B = 'user-b';

afterEach(() => jest.resetAllMocks());

describe('addComment', () => {
  it('creates a root comment when parentId is null', async () => {
    repo.create.mockResolvedValue({ id: '1', depth: 0 });
    const result = await service.addComment({ postId: 'p1', authorId: USER_A, parentId: null, body: 'hi' });
    expect(repo.create).toHaveBeenCalledWith({ postId: 'p1', authorId: USER_A, parentId: null, body: 'hi' });
    expect(result.depth).toBe(0);
  });

  it('rejects depth > 2 before hitting the DB', async () => {
    repo.findById.mockResolvedValue({ id: 'parent', depth: 2 });
    await expect(
      service.addComment({ postId: 'p1', authorId: USER_A, parentId: 'parent', body: 'too deep' })
    ).rejects.toThrow('Maximum reply depth (3) exceeded');
    expect(repo.create).not.toHaveBeenCalled();
  });
});

describe('editComment', () => {
  it('updates body when caller is the author', async () => {
    repo.findById.mockResolvedValue({ id: '1', author_id: USER_A, deleted_at: null });
    repo.update.mockResolvedValue({ id: '1', body: 'edited' });
    await service.editComment({ commentId: '1', requesterId: USER_A, newBody: 'edited' });
    expect(repo.update).toHaveBeenCalledWith('1', 'edited');
  });

  it('throws 403 when caller is NOT the author', async () => {
    repo.findById.mockResolvedValue({ id: '1', author_id: USER_A, deleted_at: null });
    await expect(
      service.editComment({ commentId: '1', requesterId: USER_B, newBody: 'hack' })
    ).rejects.toMatchObject({ status: 403 });
    expect(repo.update).not.toHaveBeenCalled();
  });

  it('throws 404 on deleted comment', async () => {
    repo.findById.mockResolvedValue({ id: '1', author_id: USER_A, deleted_at: new Date() });
    await expect(
      service.editComment({ commentId: '1', requesterId: USER_A, newBody: 'x' })
    ).rejects.toMatchObject({ status: 404 });
  });
});

describe('deleteComment', () => {
  it('soft-deletes when caller is the author', async () => {
    repo.findById.mockResolvedValue({ id: '1', author_id: USER_A, deleted_at: null });
    await service.deleteComment({ commentId: '1', requesterId: USER_A });
    expect(repo.softDelete).toHaveBeenCalledWith('1');
  });

  it('throws 403 when caller is NOT the author', async () => {
    repo.findById.mockResolvedValue({ id: '1', author_id: USER_A, deleted_at: null });
    await expect(
      service.deleteComment({ commentId: '1', requesterId: USER_B })
    ).rejects.toMatchObject({ status: 403 });
  });
});
```

**Step 2: Run tests — verify they fail**
```bash
npx jest comment.service --no-coverage
# Expected: FAIL (module not found)
```

**Step 3: Implement the service**
```js
// src/comments/comment.service.js
const repo = require('./comment.repository');

function httpError(status, message) {
  const e = new Error(message);
  e.status = status;
  return e;
}

async function addComment({ postId, authorId, parentId, body }) {
  if (parentId) {
    const parent = await repo.findById(parentId);
    if (!parent) throw httpError(404, 'Parent comment not found');
    if (parent.depth >= 2) throw new Error('Maximum reply depth (3) exceeded');
  }
  return repo.create({ postId, authorId, parentId, body });
}

async function getComments(postId) {
  return repo.findByPost(postId);
}

async function editComment({ commentId, requesterId, newBody }) {
  const comment = await repo.findById(commentId);
  if (!comment || comment.deleted_at) throw httpError(404, 'Comment not found');
  if (comment.author_id !== requesterId)  throw httpError(403, 'Not your comment');
  return repo.update(commentId, newBody);
}

async function deleteComment({ commentId, requesterId }) {
  const comment = await repo.findById(commentId);
  if (!comment || comment.deleted_at) throw httpError(404, 'Comment not found');
  if (comment.author_id !== requesterId)  throw httpError(403, 'Not your comment');
  return repo.softDelete(commentId);
}

module.exports = { addComment, getComments, editComment, deleteComment };
```

**Step 4: Run tests — verify they pass**
```bash
npx jest comment.service --no-coverage
# Expected: 7 tests passed
```

**Step 5: Commit**
```bash
git add src/comments/comment.service.js src/comments/__tests__/comment.service.test.js
git commit -m "feat: comment service with depth guard and ownership checks"
```

---

## Task 4: HTTP Router

**Files:**
- Create: `src/comments/comment.router.js`
- Test:   `src/comments/__tests__/comment.router.test.js`

**Step 1: Write the failing tests**
```js
// src/comments/__tests__/comment.router.test.js
const request  = require('supertest');
const express  = require('express');
const router   = require('../comment.router');
const service  = require('../comment.service');

jest.mock('../comment.service');

// Simulate auth middleware: req.user = { id: 'user-a' }
const app = express();
app.use(express.json());
app.use((req, _res, next) => { req.user = { id: 'user-a' }; next(); });
app.use('/posts/:postId/comments', router);

afterEach(() => jest.resetAllMocks());

it('POST /posts/:postId/comments — 201 on valid body', async () => {
  service.addComment.mockResolvedValue({ id: '1', body: 'hi', depth: 0 });
  const res = await request(app)
    .post('/posts/p1/comments')
    .send({ body: 'hi' });
  expect(res.status).toBe(201);
  expect(res.body.id).toBe('1');
});

it('POST — 400 when body is empty', async () => {
  const res = await request(app)
    .post('/posts/p1/comments')
    .send({ body: '' });
  expect(res.status).toBe(400);
});

it('GET /posts/:postId/comments — 200 with array', async () => {
  service.getComments.mockResolvedValue([{ id: '1' }]);
  const res = await request(app).get('/posts/p1/comments');
  expect(res.status).toBe(200);
  expect(Array.isArray(res.body)).toBe(true);
});

it('PATCH /posts/:postId/comments/:commentId — 200 on success', async () => {
  service.editComment.mockResolvedValue({ id: '1', body: 'edited' });
  const res = await request(app)
    .patch('/posts/p1/comments/1')
    .send({ body: 'edited' });
  expect(res.status).toBe(200);
});

it('PATCH — 403 propagated from service', async () => {
  const err = new Error('Not your comment'); err.status = 403;
  service.editComment.mockRejectedValue(err);
  const res = await request(app)
    .patch('/posts/p1/comments/1')
    .send({ body: 'hack' });
  expect(res.status).toBe(403);
});

it('DELETE /posts/:postId/comments/:commentId — 204 on success', async () => {
  service.deleteComment.mockResolvedValue();
  const res = await request(app).delete('/posts/p1/comments/1');
  expect(res.status).toBe(204);
});
```

**Step 2: Run tests — verify they fail**
```bash
npx jest comment.router --no-coverage
# Expected: FAIL (module not found)
```

**Step 3: Implement the router**
```js
// src/comments/comment.router.js
const { Router }   = require('express');
const { body, validationResult } = require('express-validator');
const service      = require('./comment.service');

const router = Router({ mergeParams: true });

const validateBody = [
  body('body').trim().notEmpty().withMessage('body is required'),
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });
    next();
  },
];

// GET /posts/:postId/comments
router.get('/', async (req, res, next) => {
  try {
    const comments = await service.getComments(req.params.postId);
    res.json(comments);
  } catch (e) { next(e); }
});

// POST /posts/:postId/comments
router.post('/', validateBody, async (req, res, next) => {
  try {
    const comment = await service.addComment({
      postId:   req.params.postId,
      authorId: req.user.id,
      parentId: req.body.parentId ?? null,
      body:     req.body.body,
    });
    res.status(201).json(comment);
  } catch (e) { next(e); }
});

// PATCH /posts/:postId/comments/:commentId
router.patch('/:commentId', validateBody, async (req, res, next) => {
  try {
    const comment = await service.editComment({
      commentId:   req.params.commentId,
      requesterId: req.user.id,
      newBody:     req.body.body,
    });
    res.json(comment);
  } catch (e) { next(e); }
});

// DELETE /posts/:postId/comments/:commentId
router.delete('/:commentId', async (req, res, next) => {
  try {
    await service.deleteComment({
      commentId:   req.params.commentId,
      requesterId: req.user.id,
    });
    res.status(204).end();
  } catch (e) { next(e); }
});

module.exports = router;
```

**Step 4: Wire the error handler in `app.js` (if not present)**
```js
// In app.js — add after all routes
app.use((err, req, res, _next) => {
  const status = err.status ?? 500;
  res.status(status).json({ error: err.message });
});
```

**Step 5: Mount the router in `app.js`**
```js
const commentRouter = require('./comments/comment.router');
app.use('/posts/:postId/comments', commentRouter);
```

**Step 6: Run tests — verify they pass**
```bash
npx jest comment.router --no-coverage
# Expected: 6 tests passed
```

**Step 7: Commit**
```bash
git add src/comments/comment.router.js src/comments/__tests__/comment.router.test.js
git commit -m "feat: comment HTTP router with input validation and error propagation"
```

---

## Task 5: Integration Test (happy path + depth guard)

**Files:**
- Test: `src/comments/__tests__/comment.integration.test.js`

**Step 1: Write the integration tests**
```js
// src/comments/__tests__/comment.integration.test.js
// Hits real DB — requires TEST_DATABASE_URL env var
const request = require('supertest');
const app     = require('../../app');          // your Express app
const db      = require('../../db');

const POST_ID = 'test-post-id';
const USER_ID = 'test-user-id';

// Override auth for tests
beforeAll(async () => {
  await db.query(`
    INSERT INTO posts (id, title) VALUES ('${POST_ID}','Test Post')
    ON CONFLICT DO NOTHING
  `);
  await db.query(`
    INSERT INTO users (id, email) VALUES ('${USER_ID}','t@t.com')
    ON CONFLICT DO NOTHING
  `);
  app.locals.testUserId = USER_ID;   // auth middleware reads this in test env
});
afterAll(() => db.end());
afterEach(() => db.query('DELETE FROM comments WHERE post_id=$1', [POST_ID]));

it('full nested thread: root → reply → deep reply → depth guard', async () => {
  // depth 0
  const r0 = await request(app).post(`/posts/${POST_ID}/comments`).send({ body: 'root' });
  expect(r0.status).toBe(201);

  // depth 1
  const r1 = await request(app).post(`/posts/${POST_ID}/comments`)
    .send({ body: 'reply', parentId: r0.body.id });
  expect(r1.status).toBe(201);
  expect(r1.body.depth).toBe(1);

  // depth 2
  const r2 = await request(app).post(`/posts/${POST_ID}/comments`)
    .send({ body: 'deep', parentId: r1.body.id });
  expect(r2.status).toBe(201);
  expect(r2.body.depth).toBe(2);

  // depth 3 → rejected
  const r3 = await request(app).post(`/posts/${POST_ID}/comments`)
    .send({ body: 'too deep', parentId: r2.body.id });
  expect(r3.status).toBe(400);
});

it('edit own comment', async () => {
  const create = await request(app).post(`/posts/${POST_ID}/comments`).send({ body: 'original' });
  const edit   = await request(app).patch(`/posts/${POST_ID}/comments/${create.body.id}`).send({ body: 'edited' });
  expect(edit.status).toBe(200);
  expect(edit.body.body).toBe('edited');
});

it('delete own comment', async () => {
  const create = await request(app).post(`/posts/${POST_ID}/comments`).send({ body: 'bye' });
  const del    = await request(app).delete(`/posts/${POST_ID}/comments/${create.body.id}`);
  expect(del.status).toBe(204);

  const list = await request(app).get(`/posts/${POST_ID}/comments`);
  expect(list.body.find(c => c.id === create.body.id)).toBeUndefined();
});
```

**Step 2: Run integration tests**
```bash
TEST_DATABASE_URL=postgres://localhost/myapp_test npx jest comment.integration --no-coverage
# Expected: 3 tests passed
```

**Step 3: Commit**
```bash
git add src/comments/__tests__/comment.integration.test.js
git commit -m "test: comment system integration tests (depth guard + CRUD)"
```

---

## Task 6: Run full test suite

**Step 1: Run all comment tests**
```bash
npx jest src/comments --coverage
# Expected: all tests pass; coverage ≥ 90% lines
```

**Step 2: Fix any failures before moving on**

**Step 3: Final commit if clean**
```bash
git add -p
git commit -m "chore: finalize comment system — all tests green"
```

---

## API Reference

| Method | Path | Auth | Body | Returns |
|--------|------|------|------|---------|
| `GET`    | `/posts/:postId/comments` | optional | — | `Comment[]` |
| `POST`   | `/posts/:postId/comments` | required | `{ body, parentId? }` | `Comment` 201 |
| `PATCH`  | `/posts/:postId/comments/:commentId` | required (owner) | `{ body }` | `Comment` 200 |
| `DELETE` | `/posts/:postId/comments/:commentId` | required (owner) | — | 204 |

**Error responses:**
- `400` — validation failure or max depth exceeded
- `403` — not the comment owner
- `404` — comment not found or already deleted

---

## Depth Enforcement: Two-Layer Defence

```
Request
  │
  ▼
service.addComment
  ├── parent.depth >= 2 → throw 400 "Maximum reply depth (3) exceeded"  ← API guard
  │
  ▼
repo.create
  └── INSERT … depth=parent.depth+1
        └── CHECK (depth BETWEEN 0 AND 2) → DB rejects depth=3          ← DB guard
```

The DB constraint is the safety net; the service check gives the clean 400 error.
