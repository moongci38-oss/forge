# Email Notification System Implementation Plan

**Goal:** Add transactional email notifications — welcome on signup, password reset, and weekly digest of new posts.

**Architecture:** A standalone `EmailService` class wraps Nodemailer with an SMTP transport. HTML templates live in `src/email/templates/` as Handlebars files. A weekly digest cron job (`node-cron`) queries the DB for posts published in the last 7 days and fans out emails to all subscribers. Each trigger (signup, reset, digest) calls `EmailService` directly — no queue required for this scope.

**Tech Stack:** Node.js, Express, Nodemailer, Handlebars (`handlebars`), `node-cron`, Jest, `nodemailer-mock`

---

## Prerequisites

```
npm install nodemailer handlebars node-cron
npm install --save-dev nodemailer-mock
```

Environment variables required (`.env`):
```
SMTP_HOST=smtp.example.com
SMTP_PORT=587
SMTP_USER=noreply@example.com
SMTP_PASS=secret
EMAIL_FROM="My App <noreply@example.com>"
APP_BASE_URL=https://app.example.com
```

---

### Task 1: EmailService skeleton

**Files:**
- Create: `src/email/EmailService.js`
- Create: `src/email/EmailService.test.js`

**Step 1: Write the failing test**
```js
// src/email/EmailService.test.js
const { createTransport } = require('nodemailer-mock');
const EmailService = require('./EmailService');

describe('EmailService', () => {
  let service;
  beforeEach(() => {
    const transport = createTransport();
    service = new EmailService(transport);
  });

  it('sends an email with the provided to/subject/html', async () => {
    await service.send({ to: 'a@b.com', subject: 'Hi', html: '<p>Hi</p>' });
    const sent = require('nodemailer-mock').mock.getSentMail();
    expect(sent).toHaveLength(1);
    expect(sent[0].to).toBe('a@b.com');
    expect(sent[0].subject).toBe('Hi');
  });
});
```

**Step 2: Run test to verify it fails**
```
npx jest src/email/EmailService.test.js
# Expected: FAIL (EmailService not found)
```

**Step 3: Write minimal implementation**
```js
// src/email/EmailService.js
class EmailService {
  constructor(transport) {
    this.transport = transport;
    this.from = process.env.EMAIL_FROM;
  }

  async send({ to, subject, html }) {
    return this.transport.sendMail({ from: this.from, to, subject, html });
  }
}

module.exports = EmailService;
```

**Step 4: Run test to verify it passes**
```
npx jest src/email/EmailService.test.js
# Expected: PASS
```

**Step 5: Commit**
```
git add src/email/
git commit -m "feat: add EmailService skeleton with send()"
```

---

### Task 2: HTML template renderer

**Files:**
- Create: `src/email/renderTemplate.js`
- Create: `src/email/renderTemplate.test.js`
- Create: `src/email/templates/welcome.hbs`
- Create: `src/email/templates/password-reset.hbs`
- Create: `src/email/templates/weekly-digest.hbs`

**Step 1: Write the failing test**
```js
// src/email/renderTemplate.test.js
const renderTemplate = require('./renderTemplate');

it('renders welcome template with user name', async () => {
  const html = await renderTemplate('welcome', { name: 'Alice' });
  expect(html).toContain('Alice');
  expect(html).toMatch(/<html/i);
});

it('renders password-reset template with reset URL', async () => {
  const html = await renderTemplate('password-reset', { resetUrl: 'https://example.com/reset/abc' });
  expect(html).toContain('https://example.com/reset/abc');
});

it('renders weekly-digest template with posts array', async () => {
  const posts = [{ title: 'Post One', url: 'https://example.com/1' }];
  const html = await renderTemplate('weekly-digest', { posts });
  expect(html).toContain('Post One');
  expect(html).toContain('https://example.com/1');
});
```

**Step 2: Run test to verify it fails**
```
npx jest src/email/renderTemplate.test.js
# Expected: FAIL
```

**Step 3: Write renderer and templates**
```js
// src/email/renderTemplate.js
const fs = require('fs/promises');
const path = require('path');
const Handlebars = require('handlebars');

async function renderTemplate(name, context) {
  const filePath = path.join(__dirname, 'templates', `${name}.hbs`);
  const source = await fs.readFile(filePath, 'utf8');
  return Handlebars.compile(source)(context);
}

module.exports = renderTemplate;
```

```hbs
{{! src/email/templates/welcome.hbs }}
<html><body>
  <h1>Welcome, {{name}}!</h1>
  <p>Thanks for signing up. <a href="{{appUrl}}">Visit the app</a></p>
</body></html>
```

```hbs
{{! src/email/templates/password-reset.hbs }}
<html><body>
  <h1>Reset your password</h1>
  <p>Click the link below. It expires in 1 hour.</p>
  <a href="{{resetUrl}}">Reset password</a>
</body></html>
```

```hbs
{{! src/email/templates/weekly-digest.hbs }}
<html><body>
  <h1>This week's new posts</h1>
  <ul>
    {{#each posts}}
      <li><a href="{{this.url}}">{{this.title}}</a></li>
    {{/each}}
  </ul>
</body></html>
```

**Step 4: Run test to verify it passes**
```
npx jest src/email/renderTemplate.test.js
# Expected: PASS
```

**Step 5: Commit**
```
git add src/email/
git commit -m "feat: add Handlebars template renderer + 3 email templates"
```

---

### Task 3: Welcome email on signup

**Files:**
- Modify: `src/auth/authService.js` (or wherever signup logic lives)
- Modify: `src/auth/authService.test.js`

**Step 1: Write the failing test**

Find the test for your signup function and add:
```js
// In authService.test.js (add to existing signup describe block)
const EmailService = require('../email/EmailService');
jest.mock('../email/EmailService');

it('sends welcome email after successful signup', async () => {
  const sendMock = jest.fn().mockResolvedValue({});
  EmailService.mockImplementation(() => ({ send: sendMock }));

  await authService.signup({ email: 'user@example.com', password: 'pass123' });

  expect(sendMock).toHaveBeenCalledWith(
    expect.objectContaining({
      to: 'user@example.com',
      subject: expect.stringContaining('Welcome'),
    })
  );
});
```

**Step 2: Run test to verify it fails**
```
npx jest src/auth/authService.test.js
# Expected: FAIL (sendMock not called)
```

**Step 3: Add email call in signup**

In `authService.js`, after persisting the new user:
```js
const renderTemplate = require('../email/renderTemplate');
const EmailService = require('../email/EmailService');

// after user created:
const html = await renderTemplate('welcome', {
  name: newUser.name || newUser.email,
  appUrl: process.env.APP_BASE_URL,
});
await emailService.send({ to: newUser.email, subject: 'Welcome to the app!', html });
```

**Step 4: Run test to verify it passes**
```
npx jest src/auth/authService.test.js
# Expected: PASS
```

**Step 5: Commit**
```
git add src/auth/
git commit -m "feat: send welcome email on signup"
```

---

### Task 4: Password reset email

**Files:**
- Modify: `src/auth/authService.js`
- Modify: `src/auth/authService.test.js`

**Step 1: Write the failing test**
```js
it('sends password-reset email with signed reset URL', async () => {
  await authService.requestPasswordReset('user@example.com');

  expect(sendMock).toHaveBeenCalledWith(
    expect.objectContaining({
      to: 'user@example.com',
      subject: expect.stringContaining('reset'),
      html: expect.stringContaining(`${process.env.APP_BASE_URL}/reset`),
    })
  );
});
```

**Step 2: Run test to verify it fails**
```
npx jest src/auth/authService.test.js --testNamePattern="password-reset"
# Expected: FAIL
```

**Step 3: Implement `requestPasswordReset`**
```js
async function requestPasswordReset(email) {
  const user = await UserRepo.findByEmail(email);
  if (!user) return; // silent — don't leak account existence

  const token = crypto.randomBytes(32).toString('hex');
  const expires = Date.now() + 60 * 60 * 1000; // 1 hour
  await UserRepo.saveResetToken(user.id, token, expires);

  const resetUrl = `${process.env.APP_BASE_URL}/reset/${token}`;
  const html = await renderTemplate('password-reset', { resetUrl });
  await emailService.send({ to: user.email, subject: 'Password reset request', html });
}
```

**Step 4: Run test to verify it passes**
```
npx jest src/auth/authService.test.js
# Expected: PASS (all auth tests)
```

**Step 5: Commit**
```
git add src/auth/
git commit -m "feat: send password reset email with signed token"
```

---

### Task 5: Weekly digest cron job

**Files:**
- Create: `src/email/weeklyDigest.js`
- Create: `src/email/weeklyDigest.test.js`
- Modify: `src/server.js` (register cron on startup)

**Step 1: Write the failing test**
```js
// src/email/weeklyDigest.test.js
const { sendWeeklyDigest } = require('./weeklyDigest');
const PostRepo = require('../posts/PostRepo');
const UserRepo = require('../users/UserRepo');
const EmailService = require('./EmailService');

jest.mock('../posts/PostRepo');
jest.mock('../users/UserRepo');
jest.mock('./EmailService');

it('emails every subscriber with posts from the last 7 days', async () => {
  const sendMock = jest.fn().mockResolvedValue({});
  EmailService.mockImplementation(() => ({ send: sendMock }));

  PostRepo.findPublishedSince.mockResolvedValue([
    { title: 'New Post', url: 'https://example.com/1' },
  ]);
  UserRepo.findAllSubscribers.mockResolvedValue([
    { email: 'alice@example.com' },
    { email: 'bob@example.com' },
  ]);

  await sendWeeklyDigest();

  expect(sendMock).toHaveBeenCalledTimes(2);
  expect(sendMock).toHaveBeenCalledWith(
    expect.objectContaining({ to: 'alice@example.com' })
  );
});

it('does nothing when there are no new posts', async () => {
  PostRepo.findPublishedSince.mockResolvedValue([]);
  await sendWeeklyDigest();
  expect(sendMock).not.toHaveBeenCalled();
});
```

**Step 2: Run test to verify it fails**
```
npx jest src/email/weeklyDigest.test.js
# Expected: FAIL
```

**Step 3: Implement the digest sender**
```js
// src/email/weeklyDigest.js
const cron = require('node-cron');
const PostRepo = require('../posts/PostRepo');
const UserRepo = require('../users/UserRepo');
const renderTemplate = require('./renderTemplate');
const EmailService = require('./EmailService');
const { createTransport } = require('nodemailer');

async function sendWeeklyDigest() {
  const since = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
  const posts = await PostRepo.findPublishedSince(since);
  if (posts.length === 0) return;

  const subscribers = await UserRepo.findAllSubscribers();
  const html = await renderTemplate('weekly-digest', { posts });
  const transport = createTransport({
    host: process.env.SMTP_HOST,
    port: Number(process.env.SMTP_PORT),
    auth: { user: process.env.SMTP_USER, pass: process.env.SMTP_PASS },
  });
  const emailService = new EmailService(transport);

  await Promise.all(
    subscribers.map((user) =>
      emailService.send({ to: user.email, subject: "This week's new posts", html })
    )
  );
}

function scheduleWeeklyDigest() {
  // Every Monday at 08:00
  cron.schedule('0 8 * * 1', sendWeeklyDigest);
}

module.exports = { sendWeeklyDigest, scheduleWeeklyDigest };
```

In `src/server.js`:
```js
const { scheduleWeeklyDigest } = require('./email/weeklyDigest');
scheduleWeeklyDigest();
```

**Step 4: Run test to verify it passes**
```
npx jest src/email/weeklyDigest.test.js
# Expected: PASS
```

**Step 5: Commit**
```
git add src/email/weeklyDigest.js src/server.js
git commit -m "feat: add weekly digest cron job (every Monday 08:00)"
```

---

### Task 6: Integration smoke test (manual)

**Goal:** Verify end-to-end flow against a real SMTP sandbox (e.g. Mailtrap).

**Step 1: Configure Mailtrap credentials in `.env`**
```
SMTP_HOST=smtp.mailtrap.io
SMTP_PORT=2525
SMTP_USER=<mailtrap-user>
SMTP_PASS=<mailtrap-pass>
```

**Step 2: Trigger each email type manually**
```
# Welcome — call signup endpoint
curl -X POST http://localhost:3000/auth/signup \
  -H 'Content-Type: application/json' \
  -d '{"email":"test@example.com","password":"pass123"}'

# Password reset
curl -X POST http://localhost:3000/auth/request-reset \
  -H 'Content-Type: application/json' \
  -d '{"email":"test@example.com"}'

# Digest — invoke directly from REPL
node -e "require('./src/email/weeklyDigest').sendWeeklyDigest()"
```

**Step 3: Confirm in Mailtrap inbox**
- Welcome email with user name
- Reset email with valid `/reset/<token>` link
- Digest email listing posts published this week

**Step 4: Commit**
```
git commit -m "chore: verify email notifications via Mailtrap smoke test"
```

---

## Done Criteria

- [ ] All unit tests pass (`npx jest src/email/`)
- [ ] Welcome email sent on every signup
- [ ] Reset email contains a working token URL
- [ ] Digest skips send when no posts exist
- [ ] Mailtrap smoke test passes for all three email types
- [ ] No SMTP credentials in source control
