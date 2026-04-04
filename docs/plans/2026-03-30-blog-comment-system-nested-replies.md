# Blog Comment System with Nested Replies — Implementation Plan

**Goal:** Build a comment system where authenticated users can post comments, reply to comments (max depth 3), and edit or delete their own comments.

**Architecture:** Adjacency-list model — each comment row stores a `parent_id` (null for top-level) and a `depth` integer enforced at the service layer. The API is REST; the frontend renders a recursive tree component. Depth guard lives in the service, not the DB, so it is easy to unit-test.

**Tech Stack:** Node.js, NestJS, TypeORM, PostgreSQL, Jest (unit + e2e), class-validator, Supertest

---

## Prerequisites / Reading

- `src/auth/jwt.strategy.ts` — understand how `req.user` is shaped (you'll need `user.id`).
- `src/users/user.entity.ts` — check the `id` field type (UUID vs integer).
- `src/app.module.ts` — where to register the new module.
- `ormconfig.ts` or `data-source.ts` — migration runner config.
- `.env.test` — test DB connection string.

---

### Task 1: Comment Entity and Database Migration

**Files:**
- Create: `src/comments/entities/comment.entity.ts`
- Create: `src/comments/migrations/YYYYMMDDHHMMSS-CreateComments.ts`

**Step 1: Write the failing test**

Create `tests/unit/comments/comment.entity.spec.ts`:

```ts
import { Comment } from '../../../src/comments/entities/comment.entity';

describe('Comment entity shape', () => {
  it('has required columns', () => {
    const c = new Comment();
    expect(c).toHaveProperty('id');
    expect(c).toHaveProperty('body');
    expect(c).toHaveProperty('authorId');
    expect(c).toHaveProperty('postId');
    expect(c).toHaveProperty('parentId');
    expect(c).toHaveProperty('depth');
  });

  it('defaults depth to 0', () => {
    const c = new Comment();
    expect(c.depth).toBe(0);
  });
});
```

**Step 2: Run test to verify it fails**

```bash
npx jest tests/unit/comments/comment.entity.spec.ts --no-coverage
# Expected: FAIL — Comment cannot be imported
```

**Step 3: Write minimal implementation**

`src/comments/entities/comment.entity.ts`:

```ts
import {
  Entity, PrimaryGeneratedColumn, Column,
  CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn,
} from 'typeorm';

@Entity('comments')
export class Comment {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'text' })
  body: string;

  @Column({ type: 'uuid' })
  authorId: string;

  @Column({ type: 'uuid' })
  postId: string;

  @Column({ type: 'uuid', nullable: true, default: null })
  parentId: string | null;

  @Column({ type: 'smallint', default: 0 })
  depth: number;

  @Column({ default: false })
  deleted: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
```

Generate and write migration:

```bash
npx typeorm migration:generate src/comments/migrations/CreateComments -d data-source.ts
```

Verify the generated SQL has: `parent_id UUID REFERENCES comments(id)`, `depth SMALLINT NOT NULL DEFAULT 0`, `deleted BOOLEAN NOT NULL DEFAULT false`.

**Step 4: Run test to verify it passes**

```bash
npx jest tests/unit/comments/comment.entity.spec.ts --no-coverage
# Expected: PASS
```

**Step 5: Run migration on test DB, then commit**

```bash
NODE_ENV=test npx typeorm migration:run -d data-source.ts
git add src/comments/entities/comment.entity.ts src/comments/migrations/
git commit -m "feat(comments): add Comment entity and migration"
```

---

### Task 2: CommentService — Create Comment (top-level and reply)

**Files:**
- Create: `src/comments/comment.service.ts`
- Create: `tests/unit/comments/comment.service.spec.ts`

**Step 1: Write the failing tests**

`tests/unit/comments/comment.service.spec.ts`:

```ts
import { CommentService } from '../../../src/comments/comment.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Comment } from '../../../src/comments/entities/comment.entity';
import { Test } from '@nestjs/testing';
import { BadRequestException, NotFoundException } from '@nestjs/common';

const mockRepo = () => ({
  save: jest.fn(),
  findOne: jest.fn(),
  update: jest.fn(),
  findAndCount: jest.fn(),
});

describe('CommentService.create', () => {
  let service: CommentService;
  let repo: ReturnType<typeof mockRepo>;

  beforeEach(async () => {
    const mod = await Test.createTestingModule({
      providers: [
        CommentService,
        { provide: getRepositoryToken(Comment), useFactory: mockRepo },
      ],
    }).compile();
    service = mod.get(CommentService);
    repo = mod.get(getRepositoryToken(Comment));
  });

  it('creates a top-level comment with depth 0', async () => {
    repo.save.mockResolvedValue({ id: 'c1', depth: 0, parentId: null });
    const result = await service.create({ body: 'Hello', postId: 'p1', parentId: null }, 'user1');
    expect(result.depth).toBe(0);
    expect(result.parentId).toBeNull();
  });

  it('creates a reply at parent depth + 1', async () => {
    repo.findOne.mockResolvedValue({ id: 'parent1', depth: 1, deleted: false });
    repo.save.mockResolvedValue({ id: 'c2', depth: 2, parentId: 'parent1' });
    const result = await service.create({ body: 'Reply', postId: 'p1', parentId: 'parent1' }, 'user1');
    expect(result.depth).toBe(2);
  });

  it('rejects reply when parent depth is already 2 (would exceed max depth 3)', async () => {
    repo.findOne.mockResolvedValue({ id: 'deep', depth: 2, deleted: false });
    await expect(
      service.create({ body: 'Too deep', postId: 'p1', parentId: 'deep' }, 'user1'),
    ).rejects.toThrow(BadRequestException);
  });

  it('throws NotFoundException when parent does not exist', async () => {
    repo.findOne.mockResolvedValue(null);
    await expect(
      service.create({ body: 'Orphan', postId: 'p1', parentId: 'ghost' }, 'user1'),
    ).rejects.toThrow(NotFoundException);
  });
});
```

**Step 2: Run to verify failure**

```bash
npx jest tests/unit/comments/comment.service.spec.ts --no-coverage
# Expected: FAIL — CommentService not found
```

**Step 3: Write minimal implementation**

`src/comments/comment.service.ts`:

```ts
import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Comment } from './entities/comment.entity';

const MAX_DEPTH = 2; // parent depth cap; child will be depth+1 = 3 max

export interface CreateCommentDto {
  body: string;
  postId: string;
  parentId: string | null;
}

@Injectable()
export class CommentService {
  constructor(
    @InjectRepository(Comment)
    private readonly repo: Repository<Comment>,
  ) {}

  async create(dto: CreateCommentDto, authorId: string): Promise<Comment> {
    let depth = 0;

    if (dto.parentId) {
      const parent = await this.repo.findOne({ where: { id: dto.parentId } });
      if (!parent) throw new NotFoundException('Parent comment not found');
      if (parent.deleted) throw new BadRequestException('Cannot reply to a deleted comment');
      if (parent.depth >= MAX_DEPTH) {
        throw new BadRequestException('Maximum reply depth (3) exceeded');
      }
      depth = parent.depth + 1;
    }

    return this.repo.save({
      body: dto.body,
      postId: dto.postId,
      authorId,
      parentId: dto.parentId ?? null,
      depth,
    });
  }
}
```

**Step 4: Run test to verify it passes**

```bash
npx jest tests/unit/comments/comment.service.spec.ts --no-coverage
# Expected: PASS (4 tests)
```

**Step 5: Commit**

```bash
git add src/comments/comment.service.ts tests/unit/comments/comment.service.spec.ts
git commit -m "feat(comments): CommentService.create with depth guard"
```

---

### Task 3: CommentService — Edit and Delete (ownership guard)

**Files:**
- Modify: `src/comments/comment.service.ts`
- Modify: `tests/unit/comments/comment.service.spec.ts`

**Step 1: Add failing tests for edit and delete**

Append to the `describe` block in `tests/unit/comments/comment.service.spec.ts`:

```ts
describe('CommentService.update', () => {
  it('updates body when caller is the author', async () => {
    repo.findOne.mockResolvedValue({ id: 'c1', authorId: 'user1', deleted: false });
    repo.save.mockResolvedValue({ id: 'c1', body: 'Edited', authorId: 'user1' });
    const result = await service.update('c1', { body: 'Edited' }, 'user1');
    expect(result.body).toBe('Edited');
  });

  it('throws ForbiddenException when caller is not the author', async () => {
    repo.findOne.mockResolvedValue({ id: 'c1', authorId: 'user1', deleted: false });
    await expect(service.update('c1', { body: 'Hack' }, 'user2'))
      .rejects.toThrow(); // ForbiddenException
  });

  it('throws NotFoundException when comment does not exist', async () => {
    repo.findOne.mockResolvedValue(null);
    await expect(service.update('ghost', { body: 'x' }, 'user1'))
      .rejects.toThrow(NotFoundException);
  });
});

describe('CommentService.softDelete', () => {
  it('soft-deletes when caller is the author', async () => {
    repo.findOne.mockResolvedValue({ id: 'c1', authorId: 'user1', deleted: false });
    repo.save.mockResolvedValue({ id: 'c1', deleted: true });
    const result = await service.softDelete('c1', 'user1');
    expect(result.deleted).toBe(true);
  });

  it('throws ForbiddenException when caller is not the author', async () => {
    repo.findOne.mockResolvedValue({ id: 'c1', authorId: 'user1', deleted: false });
    await expect(service.softDelete('c1', 'intruder')).rejects.toThrow();
  });
});
```

**Step 2: Run to verify failure**

```bash
npx jest tests/unit/comments/comment.service.spec.ts --no-coverage
# Expected: FAIL — update and softDelete are not methods
```

**Step 3: Add methods to CommentService**

Append to `src/comments/comment.service.ts` (inside the class):

```ts
import { ForbiddenException } from '@nestjs/common'; // add to existing import

async update(id: string, dto: { body: string }, callerId: string): Promise<Comment> {
  const comment = await this.repo.findOne({ where: { id } });
  if (!comment) throw new NotFoundException('Comment not found');
  if (comment.authorId !== callerId) throw new ForbiddenException('Not your comment');
  comment.body = dto.body;
  return this.repo.save(comment);
}

async softDelete(id: string, callerId: string): Promise<Comment> {
  const comment = await this.repo.findOne({ where: { id } });
  if (!comment) throw new NotFoundException('Comment not found');
  if (comment.authorId !== callerId) throw new ForbiddenException('Not your comment');
  comment.deleted = true;
  comment.body = '[deleted]';
  return this.repo.save(comment);
}
```

**Step 4: Run all service tests**

```bash
npx jest tests/unit/comments/comment.service.spec.ts --no-coverage
# Expected: PASS (9 tests)
```

**Step 5: Commit**

```bash
git add src/comments/comment.service.ts tests/unit/comments/comment.service.spec.ts
git commit -m "feat(comments): edit and soft-delete with ownership guard"
```

---

### Task 4: CommentController and Module wiring

**Files:**
- Create: `src/comments/comment.controller.ts`
- Create: `src/comments/comment.module.ts`
- Modify: `src/app.module.ts`

**Step 1: Write the failing e2e test skeleton**

Create `tests/e2e/comments/comments.e2e-spec.ts`:

```ts
import * as request from 'supertest';
import { Test } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import { AppModule } from '../../../src/app.module';

describe('Comments API (e2e)', () => {
  let app: INestApplication;
  let token: string; // obtain by calling POST /auth/login in beforeAll

  beforeAll(async () => {
    const mod = await Test.createTestingModule({ imports: [AppModule] }).compile();
    app = mod.createNestApplication();
    app.useGlobalPipes(new ValidationPipe({ whitelist: true }));
    await app.init();

    // Authenticate — adjust to your auth endpoint
    const res = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ email: 'test@example.com', password: 'password' });
    token = res.body.access_token;
  });

  afterAll(() => app.close());

  it('POST /comments → 201 creates top-level comment', async () => {
    const res = await request(app.getHttpServer())
      .post('/comments')
      .set('Authorization', `Bearer ${token}`)
      .send({ body: 'Hello world', postId: 'some-post-uuid', parentId: null });
    expect(res.status).toBe(201);
    expect(res.body.depth).toBe(0);
    expect(res.body.id).toBeDefined();
  });

  it('POST /comments → 400 when body is empty', async () => {
    const res = await request(app.getHttpServer())
      .post('/comments')
      .set('Authorization', `Bearer ${token}`)
      .send({ body: '', postId: 'some-post-uuid', parentId: null });
    expect(res.status).toBe(400);
  });

  it('PATCH /comments/:id → 200 edits own comment', async () => {
    // Create first
    const create = await request(app.getHttpServer())
      .post('/comments')
      .set('Authorization', `Bearer ${token}`)
      .send({ body: 'Original', postId: 'some-post-uuid', parentId: null });
    const id = create.body.id;

    const res = await request(app.getHttpServer())
      .patch(`/comments/${id}`)
      .set('Authorization', `Bearer ${token}`)
      .send({ body: 'Edited' });
    expect(res.status).toBe(200);
    expect(res.body.body).toBe('Edited');
  });

  it('DELETE /comments/:id → 200 soft-deletes own comment', async () => {
    const create = await request(app.getHttpServer())
      .post('/comments')
      .set('Authorization', `Bearer ${token}`)
      .send({ body: 'To delete', postId: 'some-post-uuid', parentId: null });
    const id = create.body.id;

    const res = await request(app.getHttpServer())
      .delete(`/comments/${id}`)
      .set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(200);
    expect(res.body.deleted).toBe(true);
  });
});
```

**Step 2: Run to verify failure**

```bash
npx jest tests/e2e/comments/comments.e2e-spec.ts --no-coverage
# Expected: FAIL — module not registered / routes not found
```

**Step 3: Create controller and module**

`src/comments/comment.controller.ts`:

```ts
import {
  Body, Controller, Delete, Param, Patch, Post, Req, UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CommentService, CreateCommentDto } from './comment.service';
import { IsNotEmpty, IsOptional, IsString, IsUUID, MinLength } from 'class-validator';

class CreateCommentBody implements CreateCommentDto {
  @IsString() @MinLength(1) body: string;
  @IsUUID() postId: string;
  @IsOptional() @IsUUID() parentId: string | null;
}

class UpdateCommentBody {
  @IsString() @MinLength(1) body: string;
}

@UseGuards(JwtAuthGuard)
@Controller('comments')
export class CommentController {
  constructor(private readonly service: CommentService) {}

  @Post()
  create(@Body() dto: CreateCommentBody, @Req() req) {
    return this.service.create(dto, req.user.id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: UpdateCommentBody, @Req() req) {
    return this.service.update(id, dto, req.user.id);
  }

  @Delete(':id')
  remove(@Param('id') id: string, @Req() req) {
    return this.service.softDelete(id, req.user.id);
  }
}
```

`src/comments/comment.module.ts`:

```ts
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Comment } from './entities/comment.entity';
import { CommentService } from './comment.service';
import { CommentController } from './comment.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Comment])],
  providers: [CommentService],
  controllers: [CommentController],
})
export class CommentModule {}
```

Add `CommentModule` to `src/app.module.ts` imports array.

**Step 4: Run e2e tests**

```bash
npx jest tests/e2e/comments/comments.e2e-spec.ts --no-coverage
# Expected: PASS (4 tests) — adjust auth seed if needed
```

**Step 5: Commit**

```bash
git add src/comments/ tests/e2e/comments/
git commit -m "feat(comments): CommentController + CommentModule wired into AppModule"
```

---

### Task 5: GET /comments — Fetch thread as nested tree

**Files:**
- Modify: `src/comments/comment.service.ts`
- Modify: `src/comments/comment.controller.ts`
- Create: `tests/unit/comments/comment.tree.spec.ts`

**Step 1: Write the failing unit test for tree builder**

`tests/unit/comments/comment.tree.spec.ts`:

```ts
import { buildTree } from '../../../src/comments/comment.service';

describe('buildTree', () => {
  const flat = [
    { id: 'a', parentId: null, depth: 0, body: 'root', deleted: false },
    { id: 'b', parentId: 'a', depth: 1, body: 'child', deleted: false },
    { id: 'c', parentId: 'b', depth: 2, body: 'grandchild', deleted: false },
    { id: 'd', parentId: 'c', depth: 3, body: 'great', deleted: false },
  ];

  it('nests comments by parentId', () => {
    const tree = buildTree(flat as any);
    expect(tree).toHaveLength(1);
    expect(tree[0].id).toBe('a');
    expect(tree[0].replies[0].id).toBe('b');
    expect(tree[0].replies[0].replies[0].id).toBe('c');
  });

  it('replaces deleted body with placeholder', () => {
    const withDeleted = [{ id: 'x', parentId: null, depth: 0, body: '[deleted]', deleted: true }];
    const tree = buildTree(withDeleted as any);
    expect(tree[0].body).toBe('[deleted]');
  });
});
```

**Step 2: Run to verify failure**

```bash
npx jest tests/unit/comments/comment.tree.spec.ts --no-coverage
# Expected: FAIL — buildTree is not exported
```

**Step 3: Export buildTree and add findByPost to service**

Add to `src/comments/comment.service.ts`:

```ts
export type CommentNode = Comment & { replies: CommentNode[] };

export function buildTree(flat: Comment[]): CommentNode[] {
  const map = new Map<string, CommentNode>();
  const roots: CommentNode[] = [];

  for (const c of flat) {
    map.set(c.id, { ...c, replies: [] });
  }
  for (const node of map.values()) {
    if (node.parentId && map.has(node.parentId)) {
      map.get(node.parentId)!.replies.push(node);
    } else {
      roots.push(node);
    }
  }
  return roots;
}

async findByPost(postId: string): Promise<CommentNode[]> {
  const flat = await this.repo.find({ where: { postId }, order: { createdAt: 'ASC' } });
  return buildTree(flat);
}
```

Add GET endpoint to `src/comments/comment.controller.ts`:

```ts
import { Get, Query } from '@nestjs/common'; // add to existing import

@Get()
findByPost(@Query('postId') postId: string) {
  return this.service.findByPost(postId);
}
```

Note: this endpoint is public (no `@UseGuards`) — move it above the class-level guard if needed, or create a separate public controller.

**Step 4: Run all comment tests**

```bash
npx jest tests/unit/comments/ tests/e2e/comments/ --no-coverage
# Expected: PASS (all)
```

**Step 5: Commit**

```bash
git add src/comments/ tests/unit/comments/comment.tree.spec.ts
git commit -m "feat(comments): GET /comments?postId= returns nested reply tree"
```

---

### Task 6: Input validation DTOs with class-validator

**Files:**
- Create: `src/comments/dto/create-comment.dto.ts`
- Create: `src/comments/dto/update-comment.dto.ts`
- Modify: `src/comments/comment.controller.ts`

**Step 1: Write the failing validation test**

Append to `tests/e2e/comments/comments.e2e-spec.ts`:

```ts
it('POST /comments → 400 when postId is not a UUID', async () => {
  const res = await request(app.getHttpServer())
    .post('/comments')
    .set('Authorization', `Bearer ${token}`)
    .send({ body: 'Valid body', postId: 'not-a-uuid', parentId: null });
  expect(res.status).toBe(400);
});

it('PATCH /comments/:id → 400 when body is only whitespace', async () => {
  const res = await request(app.getHttpServer())
    .patch('/comments/some-id')
    .set('Authorization', `Bearer ${token}`)
    .send({ body: '   ' });
  expect(res.status).toBe(400);
});
```

**Step 2: Run to verify failure**

```bash
npx jest tests/e2e/comments/comments.e2e-spec.ts --no-coverage
# Expected: FAIL — validation may be too loose
```

**Step 3: Extract and tighten DTOs**

`src/comments/dto/create-comment.dto.ts`:

```ts
import { IsNotEmpty, IsOptional, IsString, IsUUID, MinLength, MaxLength } from 'class-validator';
import { Transform } from 'class-transformer';

export class CreateCommentDto {
  @IsString()
  @IsNotEmpty()
  @MinLength(1)
  @MaxLength(5000)
  @Transform(({ value }) => value?.trim())
  body: string;

  @IsUUID()
  postId: string;

  @IsOptional()
  @IsUUID()
  parentId: string | null = null;
}
```

`src/comments/dto/update-comment.dto.ts`:

```ts
import { IsNotEmpty, IsString, MaxLength, MinLength } from 'class-validator';
import { Transform } from 'class-transformer';

export class UpdateCommentDto {
  @IsString()
  @IsNotEmpty()
  @MinLength(1)
  @MaxLength(5000)
  @Transform(({ value }) => value?.trim())
  body: string;
}
```

Update `comment.controller.ts` to use the new DTOs (replace inline class bodies). Ensure the app bootstrap in `main.ts` includes `app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }))`.

**Step 4: Run full test suite**

```bash
npx jest tests/ --no-coverage
# Expected: PASS (all)
```

**Step 5: Commit**

```bash
git add src/comments/dto/ src/comments/comment.controller.ts
git commit -m "feat(comments): extract and tighten validation DTOs"
```

---

## Done Criteria

- [ ] `npx jest tests/unit/comments/ --no-coverage` → all green
- [ ] `npx jest tests/e2e/comments/ --no-coverage` → all green
- [ ] `POST /comments` with `parentId` at depth 2 returns `400`
- [ ] `PATCH /comments/:id` by non-owner returns `403`
- [ ] `DELETE /comments/:id` soft-deletes; reply chain still visible with `[deleted]` placeholder
- [ ] `GET /comments?postId=X` returns nested tree, max 3 levels deep
