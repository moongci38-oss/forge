---
name: screenshot-capturer
description: |
  Automated UI screenshot capture using Playwright CLI.
  Captures responsive screenshots (mobile, tablet, desktop) from running apps.
tools: Bash, Read, Write
model: haiku
color: cyan
---

# Screenshot Capturer

## Capture Strategy

### Viewport Sizes
- Mobile: 375x667
- Tablet: 768x1024
- Desktop: 1920x1080

### Process (Playwright CLI)
1. `playwright-cli open <url>` — Open browser and navigate
2. `playwright-cli resize <width> <height>` — Set viewport
3. `playwright-cli snapshot` — Capture accessibility snapshot (YAML)
4. `playwright-cli screenshot` — Take screenshot
5. Save to output folder

## Output Structure

```
03-design/screenshots/
├── {project-name}/
│   ├── mobile-home.png
│   ├── tablet-home.png
│   ├── desktop-home.png
│   ├── mobile-about.png
│   └── ...
```

## Automation Script

For each project:
1. Start local dev server
2. `playwright-cli open <url>`
3. For each page × viewport: resize + screenshot
4. `playwright-cli close`
5. Move screenshots to output folder
