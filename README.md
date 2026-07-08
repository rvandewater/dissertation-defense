# Dissertation Defense Slides (Quarto + Reveal.js)

[![Quarto](https://img.shields.io/badge/Quarto-Presentation-2E7FE8?logo=quarto&logoColor=white)](https://quarto.org/)
[![Reveal.js](https://img.shields.io/badge/Reveal.js-Slides-F2E142?logo=revealdotjs&logoColor=black)](https://revealjs.com/)
[![License](https://img.shields.io/badge/License-See%20LICENSE-6B6B6B)](LICENSE)

Public slides: https://www.rpvandewater.com/dissertation-defense/

This repository contains the source for my dissertation defense deck and supporting mini-demos, built with [Quarto](https://quarto.org/) and [Reveal.js](https://revealjs.com/). It is intended for researchers, students, and anyone interested in the work or in using Quarto for academic presentations.

## Customizations & Features

### Custom Slide Template

The title slide uses a custom HTML template (`resources/title-slide.html`) with:
- **Auto-animated background** with overlay opacity control
- **Embedded QR codes** linking to slides and dissertation
- **Responsive layout** with absolute positioning for consistent placement across screens
- **Data attributes** for auto-animation support (`data-id` for reveal.js auto-animate)

### Custom CSS Theme (`custom.css`)

The presentation uses an extensive custom CSS file with the following customizations:

#### Typography & Layout
- **Custom heading sizes** - Larger headings using Reveal's `--r-heading2-size`
- **Centered slides** - Full-height non-title slides for proper footnote positioning
- **Bottom-aligned footnotes** - Absolute positioning at 12px from bottom (vs default 20px)
- **Tighter spacing** - Reduced margins and padding throughout
- **Custom text sizes** - Utility classes: `.bigger-text`, `.small-text`, `.tiny-text`, `.tiniest-text`

#### Publication System
- **Color-coded pillars** - Three research pillars with distinct background/border colors:
  - Pillar 1 (blue): Multi-modal Early Warning Systems
  - Pillar 2 (green): Experiment Reproducibility  
  - Pillar 3 (orange): Foundational AI Framework
- **Publication boxes** - `.pub-box` with pillar-specific styling
- **Publication legends** - `.pub-legend` grid layout with color swatches
- **Slide cards** - `.slide-card` with rounded borders and neutral colors

#### Footer Customization
- **Section indicator** - Dynamic section title in footer via `section_indicator.js`
- **Compact footer** - Reduced font size (0.60em) with custom link styling
- **Custom links** - Neutral grey (`#6b6b6b`) for all footnote and reference links

#### Theme Options
- **Light/dark handling** - `.no-dark` class preserves original images in dark mode
- **Custom white background** - Forces `#ffffff` slide background
- **Red people slide filter** - CSS variable `--people-slide-red-filter` for tinting

### JavaScript Extensions

#### `fade_in_footnotes.js`
- **Progressive footnote display** - Footnotes fade in/out as referenced citations appear via fragments
- **500ms fade transition** - Smooth opacity transitions
- **Automatic synchronization** - Listens to Reveal's `slidechanged`, `fragmentshown`, `fragmenthidden` events

#### `section_indicator.js`
- **Dynamic section labels** - Updates footer with current section title
- **Override support** - Uses `data-section-title` or `data-section-short` attributes
- **Fallback hierarchy** - h1 → h2/h3 → section container attributes

#### `footer-section.js`
- **Alternative footer section tracking** - Shows current section title in footer
- **Event-based updates** - Triggers on slide changes

#### `actors.js`
- Custom actor/character tracking (specific implementation in project)

### Quarto Configuration (`_quarto.yml`)

```yaml
project:
  type: website
  output-dir: _site
preview:
  port: 4200
  browser: false
render:
  on-save: true
```

### Presentation Metadata (`defense.qmd` YAML Header)

```yaml
title: "Benchmark to Bedside"
subtitle: 'Building Modular Multimodal Machine Learning Infrastructure for Healthcare at Scale'

# Custom title slide background with opacity
title-slide-attributes:
  data-background-image: figures/backgrounds/cover_image_thesis_wide_multimodal.png
  data-background-size: cover
  data-background-position: center
  data-background-opacity: "0.15"

# Auto-animate settings
auto-animate-easing: ease-in-out
auto-animate-unmatched: false
auto-animate-duration: 0.8

# Theme and styling
theme: serif
fontsize: 1.5em
chalkboard: false
logo: ""
css: custom.css
footnotes-hover: true

# Custom footer
footer: <a href="...">rpvandewater.com/dissertation-defense/</a> | PhD Defense | Robin P. van de Water<span id="section-indicator" style=""></span>

# Reveal.js plugins
revealjs-plugins:
  - editable

# Filters
filters:
  - footnote-letters.lua
  - editable
```

### Variables File (`_variables.yml`)

Externalized content for easy editing:
```yaml
p1_label: "$P_1$: Incomplete patient state"
p2_label: "$P_2$: Replication crisis"
p3_label: "$P_3$: Lack of robust infrastructure"

r1_label: "$C_1$: Multi-ward Multi-modal Warning Systems"
r2_label: "$C_2$: Enabling Reproducible Prediction Experiments"
r3_label: "$C_3$: Framework for Foundational AI Research"
```

### Quarto Extensions

| Extension | Purpose | Location |
|-----------|---------|----------|
| **editable** (v4.0.0) | Editable slides in browser | `_extensions/emilhvitfeldt/editable/` |
| **simplemenu** (v2.0.0) | Custom navigation menu | `_extensions/martinomagnifico/simplemenu/` |

## Contents

- **defense.qmd**: Main dissertation defense deck.
- **resources/**: Title slide layout, embedded assets, and helper files.
- **custom.css**: Theme overrides and deck styling.
- **extra_slides/**: Optional slides and appendices.
- **mini/**: Small Reveal.js demos and feature examples.
- **images/**: Image assets for slides and backgrounds.
- **icons/**: SVG icons (78 items) for slide decoration.
- **figures/**: Generated plots and diagrams (19 items).

## Getting Started

1. **Install Quarto**  
   - macOS: `brew install quarto`  
   - Or see: https://quarto.org/docs/get-started/

2. **Render the Defense Deck**  
   - Render to HTML:  
     `quarto render defense.qmd`
   - Open the generated `defense.html` in your browser

3. **Convert to Other Formats**
   For better results with PDF and PowerPoint exports, use DeckTape: `npm install -g decktape`
   - **PowerPoint (.pptx):**
     - Inbuilt: `quarto render defense.qmd --to pptx`
     - Via DeckTape: `decktape http://localhost:4200/defense.html output.pptx`
   - **PDF:** `decktape http://localhost:4200/defense.html output.pdf`
   - **Markdown:** `quarto render defense.qmd --to markdown`

4. **Create Your Own Slides**  
   Use the following YAML header in a new `.qmd` file:
   ```yaml
   ---
   title: "My Presentation"
   format:
     revealjs:
       css: custom.css
       theme: serif
       fontsize: 1.5em
   ---
   ```

## Mini Demos

The `mini/` folder contains small, focused Reveal.js presentations showing off features like auto-animate, fragments, and zoom. See `mini/README.md` for details.

## Customization Guide

### Adding a New Research Pillar Color

1. Add CSS variables to `custom.css`:
   ```css
   --pub-p4-bg: #fff0f0;
   --pub-p4-border: #e5c5c5;
   ```

2. Create new classes:
   ```css
   .reveal .pub-list--pillar4 .pub-box {
     --pub-box-bg: var(--pub-p4-bg);
     --pub-box-border: var(--pub-p4-border);
   }
   ```

3. Add to legend:
   ```css
   .reveal .pub-legend__item--pillar4 {
     background: var(--pub-p4-bg);
     border-color: var(--pub-p4-border);
   }
   ```

### Modifying Auto-Animation

Edit these settings in `defense.qmd`:
```yaml
auto-animate-easing: ease-in-out    # Change timing function
auto-animate-duration: 0.8          # Change duration in seconds
auto-animate-unmatched: false       # Toggle unmatched element animation
```

### Customizing Footnote Behavior

Edit `fade_in_footnotes.js`:
- Change `FADE_MS = 500` to adjust transition speed
- Modify `syncCurrentSlideFootnotes()` for different visibility logic

## License

See [LICENSE](LICENSE) for details.