## Dissertation Defense Slides (Quarto + Reveal.js)

[![Quarto](https://img.shields.io/badge/Quarto-Presentation-2E7FE8?logo=quarto&logoColor=white)](https://quarto.org/)
[![Reveal.js](https://img.shields.io/badge/Reveal.js-Slides-F2E142?logo=revealdotjs&logoColor=black)](https://revealjs.com/)
[![License](https://img.shields.io/badge/License-See%20LICENSE-6B6B6B)](LICENSE)

Public slides: https://www.rpvandewater.com/dissertation-defense/

This repository contains the source for my dissertation defense deck and supporting mini-demos, built with [Quarto](https://quarto.org/) and [Reveal.js](https://revealjs.com/). It is intended for researchers, students, and anyone interested in the work or in using Quarto for academic presentations.

### Contents

- **defense.qmd**: Main dissertation defense deck.
- **resources/**: Title slide layout, embedded assets, and helper files.
- **custom.css**: Theme overrides and deck styling.
- **extra_slides/**: Optional slides and appendices.
- **mini/**: Small Reveal.js demos and feature examples.
- **images/**: Image assets for slides and backgrounds.
- **mini/**: Mini Reveal.js demo presentations and assets.
	- Multiple `.qmd` files for specific Reveal.js features (auto-animate, fragments, zoom, etc.)
	- `images/`: Demo images (e.g., kittens)
	- `README.md`: Info about the mini demos

### Getting Started

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
        - inbuilt: 
		 `quarto render defense.qmd --to pptx`
        - via DeckTape:
		 `decktape {Address where quarto is hosted}/defense.html output.pptx`
        Then, use: https://www.adobe.com/acrobat/online/pdf-to-ppt.html to convert PDF to PPTX if needed.
	 - **PDF:**
		 `decktape {Address where quarto is hosted}/defense.html output.pdf`
	 - **Markdown:**
		 `quarto render defense.qmd --to markdown`
	 - The output file will be created in the same directory as your source.

4. **Create Your Own Slides**  
	 - Use the following YAML header in a new `.qmd` file:
		 ```yaml
		 ---
		 title: "My Presentation"
		 format: revealjs
		 ---
		 ```
	 - Write slides in markdown, separating slides with `---`

### Mini Demos

The `mini/` folder contains small, focused Reveal.js presentations showing off features like auto-animate, fragments, and zoom. See `mini/README.md` for details.

### License

See LICENSE for details.
