---
name: vivint-report
description: "Generate a Vivint-branded HTML report or PDF. Applies official Vivint brand guidelines (colors, typography, layout). Outputs to a specified path."
argument-hint: "<report title> [--pdf] [--out <path>] [--type pitch|summary|data|brief]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - AskUserQuestion
---

<objective>
Generate a polished, Vivint-branded report as an HTML file and optionally export it to PDF using Chrome headless. All output must comply with Vivint brand guidelines as documented at brand.vivint.com.
</objective>

<brand_guidelines>

## Colors

### Core Palette
| Token            | Hex       | Usage                                              |
|------------------|-----------|----------------------------------------------------|
| Visionary Green  | `#096049` | Primary brand color — headlines, accents, CTAs     |
| Visionary Dark   | `#10201F` | Deep backgrounds, hero sections, high-contrast text|
| Black            | `#000000` | Body text, borders                                 |
| White            | `#FFFFFF` | Page backgrounds, reversed text                    |
| Gray 2           | `#F5F5F5` | Section backgrounds, card fills                    |
| Gray Mid         | `#707070` | Muted/secondary text, rules                        |
| Taupe (Orange 1) | `#F3EFE8` | Warm backgrounds, callout fills                    |
| Pink accent      | `#FFA8CD` | Expanded palette only — use sparingly              |

### Rules
- Visionary Green is the **signature brand color** — always present, never substituted
- Logo only appears in Black, White, Visionary Green (`#096049`), or the deeper Visionary 6 variant
- Do **not** mix color families in gradients (e.g., no Visionary + Pink gradient)
- Functional reds/yellows are reserved for alerts, alarms, and critical states only
- Taupe (`#F3EFE8`) and Black may blend with other brand colors

## Typography

### Font Family
- **Primary**: `Vivint Circular` (proprietary)
- **Fallback stack**: `'Inter', 'Helvetica Neue', Arial, system-ui, sans-serif`

Always declare: `font-family: 'Vivint Circular', 'Inter', 'Helvetica Neue', Arial, system-ui, sans-serif;`

### Weights (use intentionally — prefer Medium and Regular)
| Weight name     | CSS value |
|----------------|-----------|
| Circular Black  | 900       |
| Circular Bold   | 700       |
| Circular Medium | 500       ← primary
| Circular Regular| 400       ← primary
| Circular Light  | 300       |
| Circular Thin   | 100       |

### Typographic Hierarchy (proportional system)
| Role     | Relative size  | Style notes                         |
|----------|---------------|-------------------------------------|
| Eyebrow  | 0.25× headline | ALL CAPS, letter-spacing: 2-3px     |
| Headline | 4× eyebrow     | Bold or Black weight                |
| Subline  | 0.5× headline  | Medium weight                       |
| Body     | = eyebrow size | Regular weight, adequate line-height|

Concrete example at base 12px eyebrow:
- Eyebrow: 12px / 700 / uppercase / letter-spacing 2px
- Headline: 48px / 700–900
- Subline: 24px / 500
- Body: 14–16px / 400

### Accessibility
- Maintain adequate contrast (WCAG AA minimum)
- Never use deprecated fonts: Vivint Rounded, Vivint Sans

## Logo
- Use only approved lockups — do not recreate or modify
- Clear space: 3× height and width of the Signal House dot on all sides
- Never: alter weight/proportions, use wordmark alone, add strokes/outlines, convert to all caps, mix colors within the logo
- In reports without the actual logo asset: reserve space with a clearly labeled placeholder `[VIVINT LOGO]`

## Layout Principles
- Clean, minimal — let whitespace work
- A4 (210×297mm) for print/PDF; responsive for web
- Section headers use Eyebrow + Headline pairing
- Cards/callouts use Gray 2 or Taupe backgrounds with Visionary Green left-border accents
- No decorative gradients in professional reports unless specifically requested

</brand_guidelines>

<css_template>
The following CSS block is the canonical starting point for all Vivint-branded HTML output. Always use it as the foundation and extend only as needed for the specific report type.

```css
/* ── VIVINT BRAND CSS TEMPLATE ── */
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;700;900&display=swap');

*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

:root {
  --viv-green:    #096049;
  --viv-dark:     #10201F;
  --viv-black:    #000000;
  --viv-white:    #FFFFFF;
  --viv-gray-2:   #F5F5F5;
  --viv-gray-mid: #707070;
  --viv-taupe:    #F3EFE8;
  --viv-pink:     #FFA8CD;
  --font:         'Vivint Circular', 'Inter', 'Helvetica Neue', Arial, system-ui, sans-serif;
}

html { font-size: 16px; }
body {
  font-family: var(--font);
  color: var(--viv-black);
  background: var(--viv-white);
  line-height: 1.6;
}

/* Page sizing for PDF */
.page {
  width: 210mm;
  min-height: 297mm;
  margin: 0 auto;
  padding: 16mm 18mm 14mm;
  page-break-after: always;
  position: relative;
}
.page:last-child { page-break-after: auto; }

@page { size: A4; margin: 0; }
@media print {
  body { background: white; }
  .page { height: 297mm; overflow: hidden; box-shadow: none; }
}

/* ── Typography ── */
.eyebrow {
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 2.5px;
  text-transform: uppercase;
  color: var(--viv-green);
  margin-bottom: 8px;
}
h1 { font-size: 48px; font-weight: 900; line-height: 1.1; }
h2 { font-size: 28px; font-weight: 700; line-height: 1.2; }
h3 { font-size: 18px; font-weight: 500; }
.subline { font-size: 20px; font-weight: 500; color: var(--viv-gray-mid); line-height: 1.4; }
p  { font-size: 14px; font-weight: 400; line-height: 1.65; color: var(--viv-black); }

/* ── Cover / Hero ── */
.cover {
  background: var(--viv-dark);
  color: var(--viv-white);
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
  padding: 18mm;
}
.cover .eyebrow { color: var(--viv-green); }
.cover h1       { color: var(--viv-white); }
.cover .subline { color: rgba(255,255,255,0.7); }

/* ── Section / Card patterns ── */
.section-card {
  background: var(--viv-gray-2);
  border-left: 4px solid var(--viv-green);
  border-radius: 4px;
  padding: 16px 20px;
  margin-bottom: 14px;
}
.callout-taupe {
  background: var(--viv-taupe);
  border-left: 4px solid var(--viv-green);
  border-radius: 4px;
  padding: 14px 18px;
}
.callout-green {
  background: var(--viv-green);
  color: var(--viv-white);
  border-radius: 4px;
  padding: 14px 18px;
}

/* ── Logo placeholder ── */
.logo-placeholder {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border: 1.5px solid currentColor;
  border-radius: 3px;
  padding: 6px 14px;
  font-size: 10px;
  font-weight: 700;
  letter-spacing: 1.5px;
  text-transform: uppercase;
  opacity: 0.5;
}

/* ── Footer ── */
.page-footer {
  position: absolute;
  bottom: 10mm;
  left: 18mm;
  right: 18mm;
  display: flex;
  justify-content: space-between;
  font-size: 10px;
  color: var(--viv-gray-mid);
  border-top: 1px solid var(--viv-gray-2);
  padding-top: 6px;
}
```
</css_template>

<report_types>

### pitch
Executive-facing, 5–7 pages. Sections: Cover, Problem, Solution, Benefits by Role, Rollout/Timeline, Ask.
Cover: dark (`var(--viv-dark)`) background, white text, Visionary Green eyebrow.
Body pages: white background, green accent elements.

### summary
1–3 pages. High-level status update or project summary. 
Cover: white with Visionary Green headline rule. Dense data + prose mix.

### data
Dashboard/metrics style, multiple pages. Emphasizes stat cards, tables, and charts.
Heavy use of Gray 2 for card backgrounds, Visionary Green for positive/primary metrics.

### brief
Single-page memo format. No cover. Eyebrow + H2 at top, body text, a callout block, footer.

</report_types>

<process>

## Step 1 — Parse arguments
- Extract report title from $ARGUMENTS
- Detect `--pdf` flag (default: HTML only)
- Detect `--out <path>` (default: `./output/<slugified-title>.html`)
- Detect `--type` (default: `pitch`)
- If key details are missing and cannot be inferred, ask ONE clarifying question before proceeding

## Step 2 — Gather content
- Read any files the user has provided or referenced
- If the user provided content/data, use it verbatim — do not invent facts or data
- If illustrating a structure with placeholder content, label it explicitly as `[PLACEHOLDER — replace with actual content]`
- **Never fabricate statistics, quotes, names, or attributions**

## Step 3 — Generate HTML
- Start from the CSS template above
- Apply the correct report type structure
- Use the brand color tokens (`var(--viv-green)` etc.) — never hardcode colors that deviate from the palette
- Include `<div class="logo-placeholder">Vivint Logo</div>` wherever the Vivint logo would appear
- Include a page footer on every page with the report title and page number
- Ensure all pages use the `.page` class with correct padding

## Step 4 — Write output file
- Write to the `--out` path (create directory if needed)
- Confirm the file path to the user

## Step 5 — PDF export (if `--pdf`)
```bash
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless=new \
  --disable-gpu \
  --no-sandbox \
  --print-to-pdf="<output_path>.pdf" \
  --print-to-pdf-no-header-footer \
  "file://<absolute_html_path>" 2>&1 | grep -v "ERROR\|Trying\|task_policy"
```
- Confirm bytes written
- Report both HTML and PDF paths to the user

</process>

<quality_checks>
Before writing the output file, verify:
- [ ] Only approved brand colors used (no off-palette hex values)
- [ ] Font stack includes Vivint Circular as first value
- [ ] No fabricated quotes, statistics, or attributions — placeholders are clearly labeled
- [ ] Logo appears only as a placeholder unless user provided actual asset path
- [ ] Every page has `.page` class, page footer, and page-break-after
- [ ] Contrast between text and background is visually adequate
</quality_checks>

<notes>
- The Vivint Circular font is proprietary and may not be available in all environments. The Inter fallback renders nearly identically for report purposes.
- Exact Vivint Visionary 1–6 hex values beyond #096049 are not publicly documented. Use #096049 for Visionary Green. For lighter/darker variants, use opacity adjustments (`rgba(9,96,73,0.15)` for tints) rather than guessing intermediate values.
- Functional reds/yellows (alerts, alarms) are intentionally absent from this template — add only if the report content genuinely requires status/alert UI.
- When in doubt on a brand decision, err toward more white space and less color rather than over-applying green.
</notes>
