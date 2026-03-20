---
name: pptx
description: "Handles all .pptx file operations: creating presentations from scratch (PptxGenJS), editing existing files, extracting text content (markitdown), and applying professional design principles. Includes QA pipeline with 5-axis scoring rubric (target ≥90/100). Use whenever a .pptx file needs to be created, read, edited, or converted — or when user mentions deck, slides, or presentation."
license: Proprietary. LICENSE.txt has complete terms
disable-model-invocation: true
---

# PPTX Skill

## Quick Reference

| Task | Guide |
|------|-------|
| Read/analyze content | `python -m markitdown presentation.pptx` |
| Edit or create from template | Read [editing.md](editing.md) |
| Create from scratch | Read [pptxgenjs.md](pptxgenjs.md) |

---

## Reading Content

```bash
# Text extraction
python -m markitdown presentation.pptx

# Visual overview
python scripts/thumbnail.py presentation.pptx

# Raw XML
python scripts/office/unpack.py presentation.pptx unpacked/
```

---

## Editing Workflow

**Read [editing.md](editing.md) for full details.**

1. Analyze template with `thumbnail.py`
2. Unpack → manipulate slides → edit content → clean → pack

---

## Creating from Scratch

**Read [pptxgenjs.md](pptxgenjs.md) for full details.**

Use when no template or reference presentation is available.

---

## Design Principles

Three proven rules that prevent the most common slide failures:

**1. One Message Per Slide** — If you can't summarize a slide's point in one sentence, split it. Audiences read or listen, not both. (Garr Reynolds, *Presentation Zen*)

**2. Maximize Data-Ink Ratio** — On data slides, every pixel should show data. Remove gridlines, borders, legends, and decorations that don't convey information. A clean chart with 3 bars beats a decorated chart with 10. (Edward Tufte, *The Visual Display of Quantitative Information*)

**3. CRAP Check** — Before finalizing any slide, verify these four:
- **Contrast**: Is there a clear visual hierarchy? (title vs body, primary vs secondary)
- **Repetition**: Is the same motif/style used across all slides? (card style, icon treatment, colors)
- **Alignment**: Are elements on invisible grid lines, not scattered randomly?
- **Proximity**: Are related items grouped together, unrelated items separated?

(Robin Williams, *The Non-Designer's Design Book* — the most widely taught design framework)

---

## Design Ideas

**Don't create boring slides.** Plain bullets on a white background won't impress anyone. Consider ideas from this list for each slide.

### Before Starting

- **Pick a bold, content-informed color palette**: The palette should feel designed for THIS topic. If swapping your colors into a completely different presentation would still "work," you haven't made specific enough choices.
- **Dominance over equality**: One color should dominate (60-70% visual weight), with 1-2 supporting tones and one sharp accent. Never give all colors equal weight.
- **Dark/light contrast**: Dark backgrounds for title + conclusion slides, light for content ("sandwich" structure). Or commit to dark throughout for a premium feel.
- **Commit to a visual motif**: Pick ONE distinctive element and repeat it — rounded image frames, icons in colored circles, thick single-side borders. Carry it across every slide.

### Color Palettes

Choose colors that match your topic — don't default to generic blue. Use these palettes as inspiration:

| Theme | Primary | Secondary | Accent |
|-------|---------|-----------|--------|
| **Midnight Executive** | `1E2761` (navy) | `CADCFC` (ice blue) | `FFFFFF` (white) |
| **Forest & Moss** | `2C5F2D` (forest) | `97BC62` (moss) | `F5F5F5` (cream) |
| **Coral Energy** | `F96167` (coral) | `F9E795` (gold) | `2F3C7E` (navy) |
| **Warm Terracotta** | `B85042` (terracotta) | `E7E8D1` (sand) | `A7BEAE` (sage) |
| **Ocean Gradient** | `065A82` (deep blue) | `1C7293` (teal) | `21295C` (midnight) |
| **Charcoal Minimal** | `36454F` (charcoal) | `F2F2F2` (off-white) | `212121` (black) |
| **Teal Trust** | `028090` (teal) | `00A896` (seafoam) | `02C39A` (mint) |
| **Berry & Cream** | `6D2E46` (berry) | `A26769` (dusty rose) | `ECE2D0` (cream) |
| **Sage Calm** | `84B59F` (sage) | `69A297` (eucalyptus) | `50808E` (slate) |
| **Cherry Bold** | `990011` (cherry) | `FCF6F5` (off-white) | `2F3C7E` (navy) |

### For Each Slide

**Every slide needs a visual element** — image, chart, icon, or shape. Text-only slides are forgettable. Use NanoBanana to generate illustrations, backgrounds, or diagrams when stock images are unavailable.

**Layout options:**
- Two-column (text left, illustration on right)
- Icon + text rows (icon in colored circle, bold header, description below)
- 2x2 or 2x3 grid (image on one side, grid of content blocks on other)
- Half-bleed image (full left or right side) with content overlay
- UI mockup showcase (Stitch-generated screen with annotation callouts)
- Variant comparison (2-3 Stitch variants in a labeled grid)

**Data display:**
- Large stat callouts (big numbers 60-72pt with small labels below)
- Comparison columns (before/after, pros/cons, side-by-side options)
- Timeline or process flow (numbered steps, arrows)

**Visual polish:**
- Icons in small colored circles next to section headers
- Italic accent text for key stats or taglines

### Typography

**Choose an interesting font pairing** — don't default to Arial. Pick a header font with personality and pair it with a clean body font.

| Header Font | Body Font |
|-------------|-----------|
| Georgia | Calibri |
| Arial Black | Arial |
| Calibri | Calibri Light |
| Cambria | Calibri |
| Trebuchet MS | Calibri |
| Impact | Arial |
| Palatino | Garamond |
| Consolas | Calibri |

| Element | Size |
|---------|------|
| Slide title | 36-44pt bold |
| Section header | 20-24pt bold |
| Body text | 14-16pt |
| Captions | 10-12pt muted |

### Spacing

- 0.5" minimum margins
- 0.3-0.5" between content blocks
- Leave breathing room—don't fill every inch

### Avoid (Common Mistakes)

- **Don't repeat the same layout** — vary columns, cards, and callouts across slides
- **Don't center body text** — left-align paragraphs and lists; center only titles
- **Don't skimp on size contrast** — titles need 36pt+ to stand out from 14-16pt body
- **Don't default to blue** — pick colors that reflect the specific topic
- **Don't mix spacing randomly** — choose 0.3" or 0.5" gaps and use consistently
- **Don't style one slide and leave the rest plain** — commit fully or keep it simple throughout
- **Don't create text-only slides** — add images, icons, charts, or visual elements; avoid plain title + bullets
- **Don't forget text box padding** — when aligning lines or shapes with text edges, set `margin: 0` on the text box or offset the shape to account for padding
- **Don't use low-contrast elements** — icons AND text need strong contrast against the background; avoid light text on light backgrounds or dark text on dark backgrounds
- **NEVER use accent lines under titles** — these are a hallmark of AI-generated slides; use whitespace or background color instead

---

## Generating Visuals with NanoBanana

When stock images are unavailable, use the NanoBanana MCP (`generate-image` skill) to create custom visuals for slides.

### Slide Type → Image Guide

| Slide Type | What to Generate | Aspect Ratio | Resolution |
|------------|-----------------|:------------:|:----------:|
| Title / Section divider | Gradient background, theme illustration | 16:9 | 2K |
| Content | Concept illustration, icon set | 1:1 or 4:3 | 1K |
| Data / Chart | Infographic-style background | 16:9 | 1K |
| Ending / CTA | Brand visual, thank-you background | 16:9 | 2K |

### Prompt Patterns

- **Background**: `"Minimal abstract gradient background for presentation slide, [color palette from Design Ideas], no text, clean professional"`
- **Illustration**: `"Flat illustration of [concept], minimal style, [brand colors], transparent background, vector art style"`
- **Icon set**: `"Set of 4 flat icons for [topics], consistent style, [color], on transparent background"`
- **Decorative**: `"Abstract geometric pattern, [colors], subtle, presentation background, no text"`

### Workflow

1. Decide color palette (see Design Ideas above)
2. Generate background images for title + section divider slides via NanoBanana
3. Generate content illustrations for key slides
4. Save images to `_assets/` folder next to the output .pptx
5. Insert into slides using `slide.background` or `slide.addImage`
6. Run QA loop to verify visual consistency

### Image Storage

Save generated images next to the output file:
```
output/
├── presentation.pptx
└── _assets/
    ├── bg-title.png
    ├── bg-section.png
    ├── illust-concept.png
    └── ...
```

Clean up `_assets/` after final .pptx is confirmed (images are embedded in the file).

---

## UI Mockups & Layout with Stitch

Use Stitch MCP to generate UI mockups and explore slide layouts.

### Use Case 1: UI Mockup Slides (PRD/GDD presentations)

When the presentation includes app/web UI concepts, generate actual screen mockups with Stitch and insert them into slides.

**Workflow:**
1. `create_project` — Create a Stitch project for the presentation
2. `generate_screen_from_text` — Generate key screens (Desktop/Mobile)
3. `generate_variants` — Create 2-3 layout/color variations for comparison slides
4. Take screenshots of the Stitch output and insert into PPT via `slide.addImage`

**Slide patterns for UI mockups:**
- **Single mockup**: Full-width or half-bleed image with annotations on the side
- **Before/After**: Two mockups side by side showing improvements
- **Variant comparison**: 2-3 mockup variants in a grid with labels (pairs well with agent meeting comparison slides)
- **Mobile + Desktop**: Side by side showing responsive design

**Device types:**
- `DESKTOP` — Dashboard, admin panel, web app screens
- `MOBILE` — Mobile app, responsive views
- `TABLET` — Tablet-optimized layouts

### Use Case 2: Slide Layout Reference

When slide layout decisions are difficult, use Stitch to quickly explore arrangements.

1. Describe the slide content to Stitch (`generate_screen_from_text` with `AGNOSTIC` device type)
2. Review the generated layout's element placement proportions
3. Translate to PptxGenJS coordinates
4. This is **reference only** — use PptxGenJS to build the actual slide

---

## QA Pipeline (Required — Score ≥ 90/100)

**Assume there are problems. Your job is to find and fix them until the score hits 90+.**

Your first render is almost never correct. The QA pipeline scores every slide, identifies failures, fixes them, and re-scores — up to 3 iterations. Do not declare success below 90 points.

### Step 1: Content QA

```bash
python -m markitdown output.pptx
```

Check for missing content, typos, wrong order.

**Check for leftover placeholder text:**

```bash
python -m markitdown output.pptx | grep -iE "xxxx|lorem|ipsum|this.*(page|slide).*layout"
```

If grep returns results, fix them before proceeding to Visual QA.

### Step 2: Visual QA Scoring

**⚠️ USE SUBAGENTS** — even for 2-3 slides. You've been staring at the code and will see what you expect, not what's there. Subagents have fresh eyes.

Convert slides to images (see [Converting to Images](#converting-to-images)), then score using the 5-axis rubric below.

#### Scoring Rubric (5 axes × 20 points = 100)

**A. Layout & Alignment (20점)**

| Score | Criteria |
|:-----:|----------|
| 18-20 | All elements aligned, consistent gaps (0.3-0.5"), no overlaps, ≥0.5" edge margins |
| 14-17 | Minor alignment issues (1-2 elements off), gaps mostly consistent |
| 10-13 | Noticeable overlaps or cramped areas, inconsistent spacing |
| 0-9 | Major overlaps, text cut off, elements colliding |

Checklist:
- No overlapping elements (text through shapes, stacked elements)
- No text overflow or cut off at edges/box boundaries
- Elements not too close (< 0.3" gaps)
- Sufficient margin from slide edges (≥ 0.5")
- Columns/grids aligned consistently
- Text boxes wide enough (no excessive wrapping)

**B. Color & Contrast (20점)**

| Score | Criteria |
|:-----:|----------|
| 18-20 | Strong text-background contrast everywhere, palette consistent, dark/light sandwich structure |
| 14-17 | Minor contrast issues (1-2 elements), palette mostly consistent |
| 10-13 | Readable but dull, some low-contrast text or icons |
| 0-9 | Text unreadable on background, random color choices |

Checklist:
- All text has strong contrast against its background
- Icons have strong contrast (dark on light, or light circle behind dark icons)
- Background images have semi-transparent overlay for text readability
- Color palette consistent across all slides
- No default blue — colors match the topic

**C. Visual Richness (20점)**

| Score | Criteria |
|:-----:|----------|
| 18-20 | Every slide has visual elements (images, charts, diagrams, shapes), NanoBanana backgrounds on title/section slides, Stitch UI mockups where applicable |
| 14-17 | Most slides have visuals, 1-2 text-heavy slides remain |
| 10-13 | Half the slides are text-only or text+bullets |
| 0-9 | Mostly text-only slides, no images or charts |

Checklist:
- Title/section slides have NanoBanana background images
- Data slides have charts (BAR/PIE/LINE) not just tables
- Process slides have flow diagrams (cards + arrows)
- App/web presentations include Stitch UI mockups
- No text-only slides (every slide has at least one visual element)
- Concept illustrations where applicable

**D. Typography (20점)**

| Score | Criteria |
|:-----:|----------|
| 18-20 | Clear size hierarchy (title 36+, body 14-16, caption 10-12), consistent font pairing, bold/accent used purposefully |
| 14-17 | Hierarchy present but minor inconsistencies (1-2 slides) |
| 10-13 | Flat hierarchy, titles don't stand out, inconsistent fonts |
| 0-9 | Single font size throughout, no hierarchy |

Checklist:
- Title ≥ 36pt bold, stands out from body text
- Body text 14-16pt, left-aligned (not centered)
- Captions/labels 10-12pt, muted color
- Consistent font pairing across all slides
- No accent lines under titles

**E. Cross-Slide Consistency (20점)**

| Score | Criteria |
|:-----:|----------|
| 18-20 | Unified visual motif repeated across slides, consistent card/shape styles, same color usage patterns |
| 14-17 | Mostly consistent, 1-2 slides deviate from the pattern |
| 10-13 | Each slide looks independently designed, no unifying motif |
| 0-9 | Random layouts, mixed styles, no coherence |

Checklist:
- Same visual motif (card style, border treatment, icon style) across slides
- Background treatment consistent (dark sandwich or all-dark)
- Same shadow/fill style for cards
- Layout variety without breaking consistency
- Slide transitions feel like one deck, not separate files

#### Critical Thinking Mandate

The scoring subagent MUST adopt an adversarial mindset. You are a **harsh design critic**, not a supportive colleague.

**Anti-Leniency Rules:**
- **Never round up.** If a slide is "almost" 18, it's 17.
- **Never give benefit of the doubt.** If you're unsure whether something is an issue, it IS an issue.
- **Compare against professional decks** (Apple keynotes, McKinsey reports, top-tier pitch decks), not against "AI-generated average."
- **18-20 means genuinely impressive** — would a professional designer approve this slide without changes? If not, cap at 17.
- **Inflation check:** If your first pass averages above 85, re-evaluate — you're probably being too generous. Recalibrate with stricter eyes.
- **Each deduction needs a reason.** Don't just score — explain WHY points were lost.

**Cognitive Biases to Guard Against:**
- **Creator bias**: "I made this so it must be good" — you didn't make it, judge it cold.
- **Effort bias**: "A lot of work went into this" — irrelevant. Judge the output, not the effort.
- **Anchoring**: Don't let the first slide's score influence the rest. Score each independently.
- **Comparison anchor**: Don't compare against the previous (worse) version. Judge against absolute standards.

#### Subagent Scoring Prompt

```
You are a harsh, professional design critic reviewing a presentation.
Score using the 5-axis rubric (each 0-20, total 100).

CRITICAL: Be adversarial. Your job is to FIND FLAWS, not to validate.
- A "decent" AI-generated deck scores 60-70.
- A "good" deck scores 75-85.
- "Excellent" (90+) means a professional designer would approve with minimal changes.
- If your average is above 85 on first pass, you are being too lenient. Re-evaluate.

For EACH slide, evaluate with specific deduction reasons:
A. Layout & Alignment: overlaps, gaps, margins, alignment
   → Deduct for: any overlap (-3), inconsistent gaps (-2), tight margins (-2), misaligned columns (-2)
B. Color & Contrast: text readability, palette consistency, icon contrast
   → Deduct for: any unreadable text (-4), inconsistent palette (-2), low-contrast icons (-2), no bg overlay on images (-3)
C. Visual Richness: images, charts, diagrams present (not just text+bullets)
   → Deduct for: text-only slide (-8), bullets without visuals (-4), no NanoBanana images on title (-3), data as table instead of chart (-3)
D. Typography: size hierarchy, font consistency, bold/accent usage
   → Deduct for: title < 36pt (-3), no size hierarchy (-4), centered body text (-2), accent lines under titles (-3)
E. Cross-Slide Consistency: unified motif, card styles, color patterns
   → Deduct for: different card styles (-3), inconsistent backgrounds (-3), no recurring motif (-4)

Output format:
| Slide | A | B | C | D | E | Total | Deduction Reasons |
|-------|---|---|---|---|---|-------|-------------------|
| 1     |   |   |   |   |   |       |                   |
| ...   |   |   |   |   |   |       |                   |
| AVG   |   |   |   |   |   | ??/100|                   |

Then answer:
1. TOP 3 most impactful fixes (each with expected score improvement)
2. Would a professional designer approve this deck? (Yes/No/With minor edits)
3. What is the single weakest slide and why?

Read and analyze these images:
1. /path/to/slide-01.jpg
2. /path/to/slide-02.jpg
...
```

### Step 3: Fix-and-Rescore Loop

```
Generate → Convert to images → Score (subagent)
    ↓
Score ≥ 90? → PASS ✅
    ↓ No
Fix top 3 issues → Re-render affected slides → Re-score
    ↓
Score ≥ 90? → PASS ✅
    ↓ No
Fix remaining issues → Re-render → Re-score (iteration 2)
    ↓
Score ≥ 90? → PASS ✅
    ↓ No
Final fix attempt → Re-render → Re-score (iteration 3, final)
    ↓
Score ≥ 85? → PASS with note ⚠️
Score < 85? → FAIL — report to Human for manual review
```

**Rules:**
- Maximum 3 fix iterations (prevent infinite loops)
- Each iteration focuses on the **top 3 highest-impact fixes** from the score report
- After fixing, only re-render and re-score **affected slides** (not the full deck)
- If score plateaus (same score twice), stop and report remaining issues
- Score ≥ 90 = PASS, 85-89 = PASS with caveats, < 85 = report to Human

### Axis-Specific Fix Strategies

| Low-Scoring Axis | Fix Strategy |
|-----------------|--------------|
| **A. Layout** | Adjust x/y/w/h coordinates, add margins, increase gaps between elements |
| **B. Color** | Add semi-transparent overlay on bg images, increase text color contrast, fix icon circles |
| **C. Visual Richness** | Add NanoBanana images, convert tables to charts (maximize data-ink ratio — remove gridlines/borders), add flow diagrams, generate Stitch mockups |
| **D. Typography** | Increase title size, enforce font pairing, add bold/color to key terms |
| **E. Consistency** | Extract common styles into variables, apply same shadow/fill/motif to all slides |

---

## Converting to Images

Convert presentations to individual slide images for visual inspection:

```bash
python scripts/office/soffice.py --headless --convert-to pdf output.pptx
pdftoppm -jpeg -r 150 output.pdf slide
```

This creates `slide-01.jpg`, `slide-02.jpg`, etc.

To re-render specific slides after fixes:

```bash
pdftoppm -jpeg -r 150 -f N -l N output.pdf slide-fixed
```

---

## Dependencies

- `pip install "markitdown[pptx]"` - text extraction
- `pip install Pillow` - thumbnail grids
- `npm install -g pptxgenjs` - creating from scratch
- LibreOffice (`soffice`) - PDF conversion (auto-configured for sandboxed environments via `scripts/office/soffice.py`)
- Poppler (`pdftoppm`) - PDF to images
