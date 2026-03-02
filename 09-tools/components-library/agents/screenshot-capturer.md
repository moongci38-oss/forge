---
name: screenshot-capturer
description: |
  Automated UI screenshot capture using Playwright MCP.
  Captures responsive screenshots (mobile, tablet, desktop) from running apps.
tools: mcp__playwright__browser_navigate, mcp__playwright__browser_snapshot, mcp__playwright__browser_take_screenshot, mcp__playwright__browser_resize, Read, Write
model: haiku
color: cyan
---

# Screenshot Capturer

## Capture Strategy

### Viewport Sizes
- Mobile: 375x667
- Tablet: 768x1024
- Desktop: 1920x1080

### Process
1. Navigate to URL
2. Wait for load (browser_wait_for)
3. Resize viewport
4. Take screenshot
5. Save to file

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
2. Capture all pages
3. Stop server
4. Move screenshots to output folder
