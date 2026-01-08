// Some definitions presupposed by pandoc's typst output.
#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.abs
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == str {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == content {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subrefnumbering: "1a",
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => numbering(subrefnumbering, n-super, quartosubfloatcounter.get().first() + 1))
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => block({
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          })

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != str {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let children = old_title_block.body.body.children
  let old_title = if children.len() == 1 {
    children.at(0)  // no icon: title at index 0
  } else {
    children.at(1)  // with icon: title at index 1
  }

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block,
    block_with_new_content(
      old_title_block.body,
      if children.len() == 1 {
        new_title  // no icon: just the title
      } else {
        children.at(0) + new_title  // with icon: preserve icon block + new title
      }))

  block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black, body_background_color: white) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color,
        width: 100%,
        inset: 8pt)[#if icon != none [#text(icon_color, weight: 900)[#icon] ]#title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: body_background_color, width: 100%, inset: 8pt, body))
      }
    )
}



#let article(
  title: none,
  subtitle: none,
  authors: none,
  date: none,
  abstract: none,
  abstract-title: none,
  cols: 1,
  lang: "en",
  region: "US",
  font: "libertinus serif",
  fontsize: 11pt,
  title-size: 1.5em,
  subtitle-size: 1.25em,
  heading-family: "libertinus serif",
  heading-weight: "bold",
  heading-style: "normal",
  heading-color: black,
  heading-line-height: 0.65em,
  sectionnumbering: none,
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  doc,
) = {
  set par(justify: true)
  set text(lang: lang,
           region: region,
           font: font,
           size: fontsize)
  set heading(numbering: sectionnumbering)
  if title != none {
    align(center)[#block(inset: 2em)[
      #set par(leading: heading-line-height)
      #if (heading-family != none or heading-weight != "bold" or heading-style != "normal"
           or heading-color != black) {
        set text(font: heading-family, weight: heading-weight, style: heading-style, fill: heading-color)
        text(size: title-size)[#title]
        if subtitle != none {
          parbreak()
          text(size: subtitle-size)[#subtitle]
        }
      } else {
        text(weight: "bold", size: title-size)[#title]
        if subtitle != none {
          parbreak()
          text(weight: "bold", size: subtitle-size)[#subtitle]
        }
      }
    ]]
  }

  if authors != none {
    let count = authors.len()
    let ncols = calc.min(count, 3)
    grid(
      columns: (1fr,) * ncols,
      row-gutter: 1.5em,
      ..authors.map(author =>
          align(center)[
            #author.name \
            #author.affiliation \
            #author.email
          ]
      )
    )
  }

  if date != none {
    align(center)[#block(inset: 1em)[
      #date
    ]]
  }

  if abstract != none {
    block(inset: 2em)[
    #text(weight: "semibold")[#abstract-title] #h(1em) #abstract
    ]
  }

  if toc {
    let title = if toc_title == none {
      auto
    } else {
      toc_title
    }
    block(above: 0em, below: 2em)[
    #outline(
      title: toc_title,
      depth: toc_depth,
      indent: toc_indent
    );
    ]
  }

  if cols == 1 {
    doc
  } else {
    columns(cols, doc)
  }
}

#set table(
  inset: 6pt,
  stroke: none
)

#set page(
  paper: "us-letter",
  margin: (x: 1.25in, y: 1.25in),
  numbering: "1",
)

#show: doc => article(
  subtitle: [Thesis Defense Robin P. van de Water],
  toc_title: [Table of contents],
  toc_depth: 3,
  cols: 1,
  doc,
)

= Hello, There
<hello-there>
This presentation will show you examples of what you can do with Quarto and #link("https://revealjs.com")[Reveal.js];, including

- Presenting code and LaTeX equations
- Including computations in slide output
- Image, video, and iframe backgrounds
- Fancy transitions and animations
- Activating scroll view.

…and much more

= Pretty Code
<pretty-code>
- Over 20 syntax highlighting themes available
- Default theme optimized for accessibility

```r
# Define a server for the Shiny app
function(input, output) {
  
  # Fill in the spot we created for a plot
  output$phonePlot <- renderPlot({
    # Render a barplot
  })
}
```

#block[
Learn more: #link("https://?meta:prerelease-subdomainquarto.org/docs/output-formats/html-code.html#highlighting")[Syntax Highlighting]

]
= Code Animations
<code-animations>
- Over 20 syntax highlighting themes available
- Default theme optimized for accessibility

```r
# Define a server for the Shiny app
function(input, output) {
  
  # Fill in the spot we created for a plot
  output$phonePlot <- renderPlot({
    # Render a barplot
    barplot(WorldPhones[,input$region]*1000, 
            main=input$region,
            ylab="Number of Telephones",
            xlab="Year")
  })
}
```

#block[
Learn more: #link("https://?meta:prerelease-subdomainquarto.org/docs/presentations/revealjs/advanced.html#code-animations")[Code Animations]

]
= Line Highlighting
<line-highlighting>
- Highlight specific lines for emphasis
- Incrementally highlight additional lines

```python
import numpy as np
import matplotlib.pyplot as plt

r = np.arange(0, 2, 0.01)
theta = 2 * np.pi * r
fig, ax = plt.subplots(subplot_kw={'projection': 'polar'})
ax.plot(theta, r)
ax.set_rticks([0.5, 1, 1.5, 2])
ax.grid(True)
plt.show()
```

#block[
Learn more: #link("https://?meta:prerelease-subdomainquarto.org/docs/presentations/revealjs/#line-highlighting")[Line Highlighting]

]
= Executable Code
<executable-code>
```r
library(ggplot2)
ggplot(mtcars, aes(hp, mpg, color = am)) +
  geom_point() +
  geom_smooth(formula = y ~ x, method = "loess")
```

#block[
```
Warning: The following aesthetics were dropped during statistical transformation:
colour.
ℹ This can happen when ggplot fails to infer the correct grouping structure in
  the data.
ℹ Did you forget to specify a `group` aesthetic or to convert a numerical
  variable into a factor?
```

]
#box(image("index_files/figure-typst/unnamed-chunk-1-1.svg"))

#block[
Learn more: #link("https://?meta:prerelease-subdomainquarto.org/docs/presentations/revealjs/#executable-code")[Executable Code]

]
= LaTeX Equations
<latex-equations>
#link("https://www.mathjax.org/")[MathJax] rendering of equations to HTML

#block[
#block[
```tex
\begin{gather*}
a_1=b_1+c_1\\
a_2=b_2+c_2-d_2+e_2
\end{gather*}

\begin{align}
a_{11}& =b_{11}&
  a_{12}& =b_{12}\\
a_{21}& =b_{21}&
  a_{22}& =b_{22}+c_{22}
\end{align}
```

]
#block[
]
]
#block[
Learn more: #link("https://?meta:prerelease-subdomainquarto.org/docs/authoring/markdown-basics.html#equations")[LaTeX Equations]

]
= Column Layout
<column-layout>
Arrange content into columns of varying widths:

#block[
#block[
=== Motor Trend Car Road Tests
<motor-trend-car-road-tests>
The data was extracted from the 1974 Motor Trend US magazine, and comprises fuel consumption and 10 aspects of automobile design and performance for 32 automobiles.

]
#block[
]
#block[
```r
knitr::kable(head(mtcars)[,c("mpg", "cyl", "disp", "hp", "wt")])
```

#table(
  columns: 6,
  align: (left,right,right,right,right,right,),
  table.header([], [mpg], [cyl], [disp], [hp], [wt],),
  table.hline(),
  [Mazda RX4], [21.0], [6], [160], [110], [2.620],
  [Mazda RX4 Wag], [21.0], [6], [160], [110], [2.875],
  [Datsun 710], [22.8], [4], [108], [93], [2.320],
  [Hornet 4 Drive], [21.4], [6], [258], [110], [3.215],
  [Hornet Sportabout], [18.7], [8], [360], [175], [3.440],
  [Valiant], [18.1], [6], [225], [105], [3.460],
)
]
]
#block[
Learn more: #link("https://?meta:prerelease-subdomainquarto.org/docs/presentations/revealjs/#multiple-columns")[Multiple Columns]

]
= Incremental Lists
<incremental-lists>
Lists can optionally be displayed incrementally:

#block[
- First item
- Second item
- Third item

]
. . .

Insert pauses to make other types of content display incrementally.

#block[
Learn more: #link("https://?meta:prerelease-subdomainquarto.org/docs/presentations/revealjs/#incremental-lists")[Incremental Lists]

]
= Fragments
<fragments>
Incremental text display and animation with fragments:

#block[
Fade in

]
#block[
Slide up while fading in

]
#block[
Slide left while fading in

]
#block[
Fade in then semi out

]
. . .

#block[
Strike

]
#block[
Highlight red

]
#block[
Learn more: #link("https://?meta:prerelease-subdomainquarto.org/docs/presentations/revealjs/advanced.html#fragments")[Fragments]

]
= Slide Backgrounds
<slide-backgrounds>
Set the `background` attribute on a slide to change the background color (all CSS color formats are supported).

Different background transitions are available via the `background-transition` option.

#block[
Learn more: #link("https://?meta:prerelease-subdomainquarto.org/docs/presentations/revealjs/#color-backgrounds")[Slide Backgrounds]

]
= Media Backgrounds
<media-backgrounds>
You can also use the following as a slide background:

- An image: `background-image`

- A video: `background-video`

- An iframe: `background-iframe`

#block[
Learn more: #link("https://?meta:prerelease-subdomainquarto.org/docs/presentations/revealjs/#image-backgrounds")[Media Backgrounds]

]
= Absolute Position
<absolute-position>
Position images or other elements at precise locations

#box(image("mini/images/kitten-400-350.jpeg", height: 4.16667in, width: 4.16667in))

#box(image("mini/images/kitten-450-250.jpeg", width: 4.6875in))

#box(image("mini/images/kitten-300-200.jpeg", width: 3.125in))

#block[
Learn more: #link("https://?meta:prerelease-subdomainquarto.org/docs/presentations/revealjs/advanced.html#absolute-position")[Absolute Position]

]
= Auto-Animate
<auto-animate>
Automatically animate matching elements across slides with Auto-Animate.

#block[
#block[
]
#block[
]
#block[
]
]
#block[
Learn more: #link("https://?meta:prerelease-subdomainquarto.org/docs/presentations/revealjs/advanced.html#auto-animate")[Auto-Animate]

]
= Auto-Animate
<auto-animate-1>
Automatically animate matching elements across slides with Auto-Animate.

#block[
#block[
]
#block[
]
#block[
]
]
#block[
Learn more: #link("https://?meta:prerelease-subdomainquarto.org/docs/presentations/revealjs/advanced.html#auto-animate")[Auto-Animate]

]
= Slide Transitions
<slide-transitions>
The next few slides will transition using the `slide` transition

#table(
  columns: (14.29%, 85.71%),
  align: (auto,auto,),
  table.header([Transition], [Description],),
  table.hline(),
  [`none`], [No transition (default, switch instantly)],
  [`fade`], [Cross fade],
  [`slide`], [Slide horizontally],
  [`convex`], [Slide at a convex angle],
  [`concave`], [Slide at a concave angle],
  [`zoom`], [Scale the incoming slide so it grows in from the center of the screen.],
)
#block[
Learn more: #link("https://?meta:prerelease-subdomainquarto.org/docs/presentations/revealjs/advanced.html#slide-transitions")[Slide Transitions]

]
= Tabsets
<tabsets>
== Plot
```r
library(ggplot2)
ggplot(mtcars, aes(hp, mpg, color = am)) +
  geom_point() +
  geom_smooth(formula = y ~ x, method = "loess")
```

#block[
```
Warning: The following aesthetics were dropped during statistical transformation:
colour.
ℹ This can happen when ggplot fails to infer the correct grouping structure in
  the data.
ℹ Did you forget to specify a `group` aesthetic or to convert a numerical
  variable into a factor?
```

]
#box(image("index_files/figure-typst/unnamed-chunk-3-1.svg"))

== Data
```r
knitr::kable(mtcars)
```

#table(
  columns: (27.78%, 6.94%, 5.56%, 8.33%, 5.56%, 6.94%, 8.33%, 8.33%, 4.17%, 4.17%, 6.94%, 6.94%),
  align: (left,right,right,right,right,right,right,right,right,right,right,right,),
  table.header([], [mpg], [cyl], [disp], [hp], [drat], [wt], [qsec], [vs], [am], [gear], [carb],),
  table.hline(),
  [Mazda RX4], [21.0], [6], [160.0], [110], [3.90], [2.620], [16.46], [0], [1], [4], [4],
  [Mazda RX4 Wag], [21.0], [6], [160.0], [110], [3.90], [2.875], [17.02], [0], [1], [4], [4],
  [Datsun 710], [22.8], [4], [108.0], [93], [3.85], [2.320], [18.61], [1], [1], [4], [1],
  [Hornet 4 Drive], [21.4], [6], [258.0], [110], [3.08], [3.215], [19.44], [1], [0], [3], [1],
  [Hornet Sportabout], [18.7], [8], [360.0], [175], [3.15], [3.440], [17.02], [0], [0], [3], [2],
  [Valiant], [18.1], [6], [225.0], [105], [2.76], [3.460], [20.22], [1], [0], [3], [1],
  [Duster 360], [14.3], [8], [360.0], [245], [3.21], [3.570], [15.84], [0], [0], [3], [4],
  [Merc 240D], [24.4], [4], [146.7], [62], [3.69], [3.190], [20.00], [1], [0], [4], [2],
  [Merc 230], [22.8], [4], [140.8], [95], [3.92], [3.150], [22.90], [1], [0], [4], [2],
  [Merc 280], [19.2], [6], [167.6], [123], [3.92], [3.440], [18.30], [1], [0], [4], [4],
  [Merc 280C], [17.8], [6], [167.6], [123], [3.92], [3.440], [18.90], [1], [0], [4], [4],
  [Merc 450SE], [16.4], [8], [275.8], [180], [3.07], [4.070], [17.40], [0], [0], [3], [3],
  [Merc 450SL], [17.3], [8], [275.8], [180], [3.07], [3.730], [17.60], [0], [0], [3], [3],
  [Merc 450SLC], [15.2], [8], [275.8], [180], [3.07], [3.780], [18.00], [0], [0], [3], [3],
  [Cadillac Fleetwood], [10.4], [8], [472.0], [205], [2.93], [5.250], [17.98], [0], [0], [3], [4],
  [Lincoln Continental], [10.4], [8], [460.0], [215], [3.00], [5.424], [17.82], [0], [0], [3], [4],
  [Chrysler Imperial], [14.7], [8], [440.0], [230], [3.23], [5.345], [17.42], [0], [0], [3], [4],
  [Fiat 128], [32.4], [4], [78.7], [66], [4.08], [2.200], [19.47], [1], [1], [4], [1],
  [Honda Civic], [30.4], [4], [75.7], [52], [4.93], [1.615], [18.52], [1], [1], [4], [2],
  [Toyota Corolla], [33.9], [4], [71.1], [65], [4.22], [1.835], [19.90], [1], [1], [4], [1],
  [Toyota Corona], [21.5], [4], [120.1], [97], [3.70], [2.465], [20.01], [1], [0], [3], [1],
  [Dodge Challenger], [15.5], [8], [318.0], [150], [2.76], [3.520], [16.87], [0], [0], [3], [2],
  [AMC Javelin], [15.2], [8], [304.0], [150], [3.15], [3.435], [17.30], [0], [0], [3], [2],
  [Camaro Z28], [13.3], [8], [350.0], [245], [3.73], [3.840], [15.41], [0], [0], [3], [4],
  [Pontiac Firebird], [19.2], [8], [400.0], [175], [3.08], [3.845], [17.05], [0], [0], [3], [2],
  [Fiat X1-9], [27.3], [4], [79.0], [66], [4.08], [1.935], [18.90], [1], [1], [4], [1],
  [Porsche 914-2], [26.0], [4], [120.3], [91], [4.43], [2.140], [16.70], [0], [1], [5], [2],
  [Lotus Europa], [30.4], [4], [95.1], [113], [3.77], [1.513], [16.90], [1], [1], [5], [2],
  [Ford Pantera L], [15.8], [8], [351.0], [264], [4.22], [3.170], [14.50], [0], [1], [5], [4],
  [Ferrari Dino], [19.7], [6], [145.0], [175], [3.62], [2.770], [15.50], [0], [1], [5], [6],
  [Maserati Bora], [15.0], [8], [301.0], [335], [3.54], [3.570], [14.60], [0], [1], [5], [8],
  [Volvo 142E], [21.4], [4], [121.0], [109], [4.11], [2.780], [18.60], [1], [1], [4], [2],
)
#block[
Learn more: #link("https://?meta:prerelease-subdomainquarto.org/docs/presentations/revealjs/#tabsets")[Tabsets]

]
= Interactive Slides
<interactive-slides>
Include Jupyter widgets and htmlwidgets in your presentations

#block[
Learn more: #link("https://?meta:prerelease-subdomainquarto.org/docs/interactive/widgets/jupyter.html")[Jupyter widgets];, #link("https://?meta:prerelease-subdomainquarto.org/docs/interactive/widgets/htmlwidgets.html")[htmlwidgets]

]
= Interactive Slides
<interactive-slides-1>
Turn presentations into applications with Observable and Shiny. Use component layout to position inputs and outputs.

#block[
```r
ojs_define(actors = data.frame(
  x = rnorm(100),
  y = rnorm(100)
))
```

]
```{ojs}
//| panel: sidebar
viewof talentWeight = Inputs.range([-2, 2], { value: 0.7, step: 0.01, label: "talent weight" })
viewof looksWeight = Inputs.range([-2, 2], { value: 0.7, step: 0.01, label: "looks weight" })
viewof minimum = Inputs.range([-2, 2], { value: 1, step: 0.01, label: "min fame" })
```

```{ojs}
//| panel: fill
import { plotActors } from './actors.js';
plotActors(actors, talentWeight, looksWeight, minimum)
```

#block[
Learn more: #link("https://?meta:prerelease-subdomainquarto.org/docs/interactive/ojs/")[Observable];, #link("https://?meta:prerelease-subdomainquarto.org/docs/interactive/shiny/")[Shiny];, #link("https://?meta:prerelease-subdomainquarto.org/docs/interactive/layout.html")[Component Layout]

]
= Preview Links
<preview-links>
Navigate to hyperlinks without disrupting the flow of your presentation.

Use the `preview-links` option to open links in an iframe on top of your slides. Try clicking the link below for a demonstration:

#block[
#link("https://matplotlib.org/")[Matplotlib: Visualization with Python]

]
#block[
Learn more: #link("https://?meta:prerelease-subdomainquarto.org/docs/presentations/revealjs/presenting.html#preview-links")[Preview Links]

]
= Themes
<themes>
10 Built-in Themes (or #link("https://?meta:prerelease-subdomainquarto.org/docs/presentations/revealjs/themes.html#creating-themes")[create your own];)

#grid(
columns: (1fr, 1fr), gutter: 1em, rows: 1,
  rect(stroke: none, width: 100%)[
#box(image("images/moon.png", width: 100.0%))

],
  rect(stroke: none, width: 100%)[
#box(image("images/sky.png", width: 100.0%))

],
)
#block[
Learn more: #link("https://?meta:prerelease-subdomainquarto.org/docs/presentations/revealjs/themes.html")[Themes]

]
= Easy Navigation
<easy-navigation>
#block[
Quickly jump to other parts of your presentation

]
#grid(
columns: (1fr, 20fr), gutter: 1em, rows: 1,
  rect(stroke: none, width: 100%)[
#box(image("images/presentation-menu.png", width: 0.42708in))

],
  rect(stroke: none, width: 100%)[
Toggle the slide menu with the menu button (bottom left of slide) to go to other slides and access presentation tools.

],
)
You can also press `m` to toggle the menu open and closed.

You can also press `g` to toggle 'Jump To Slide' modal box to quickly go to one of your slide using its number or id.

#block[
Learn more: #link("./docs/presentations/revealjs/presenting.qmd#navigation-menu")[Navigation] / #link("./docs/presentations/revealjs/presenting.qmd#jump-to-slide")[Jump To Slide]

]
= Jump To Slide
<jump-to-slide>
#block[
Quickly jump to other parts of your presentation

]
= Chalkboard
<chalkboard>
#block[
Free form drawing and slide annotations

]
#grid(
columns: (1fr, 20fr), gutter: 1em, rows: 1,
  rect(stroke: none, width: 100%)[
#box(image("images/presentation-chalkboard.png", width: 0.42708in))

],
  rect(stroke: none, width: 100%)[
Use the chalkboard button at the bottom left of the slide to toggle the chalkboard.

],
)
#grid(
columns: (1fr, 20fr), gutter: 1em, rows: 1,
  rect(stroke: none, width: 100%)[
#box(image("images/presentation-notes-canvas.png", width: 0.42708in))

],
  rect(stroke: none, width: 100%)[
Use the notes canvas button at the bottom left of the slide to toggle drawing on top of the current slide.

],
)
You can also press `b` to toggle the chalkboard or `c` to toggle the notes canvas.

#block[
Learn more: #link("https://?meta:prerelease-subdomainquarto.org/docs/presentations/revealjs/presenting.html#chalkboard")[Chalkboard]

]
= Point of View
<point-of-view>
press `o` to toggle overview mode:

#box(image("images/overview-mode.png"))

Hold down the `Alt` (linux: `Ctrl`) and click on any element to zoom towards it---try it now on this slide.

#block[
Learn more: #link("https://?meta:prerelease-subdomainquarto.org/docs/presentations/revealjs/presenting.html#overview-mode")[Overview Mode];, #link("https://?meta:prerelease-subdomainquarto.org/docs/presentations/revealjs/presenting.html#slide-zoom")[Slide Zoom]

]
= Speaker View
<speaker-view>
press `s` (or use the tools in presentation menu #box(image("../images/navigation-menu-icon.png", height: 0.5em, width: 0.5em))) to open speaker view

#align(center)[#box(image("images/speaker-view.png", width: 8.125in))]
#block[
Learn more: #link("https://?meta:prerelease-subdomainquarto.org/docs/presentations/revealjs/presenting.html#speaker-view")[Speaker View]

]
= Scroll View
<scroll-view>
Press `r` (or use the tools in presentation menu #box(image("../images/navigation-menu-icon.png", height: 0.5em, width: 0.5em))) to open scroll view

Try it now on this slide --- You'll see a scroll bar on the right and you can scroll down the presentation using your mouse.

Scroll view behavior can be configured using `scroll-view` configuration.

#block[
Learn more: #link("https://?meta:prerelease-subdomainquarto.org/docs/presentations/revealjs/presenting.html#scroll-view")[Scroll View]

]
= Authoring Tools
<authoring-tools>
Live side-by-side preview for any notebook or text editor including Jupyter and VS Code

#block[
#block[
#box(image("images/jupyter-edit.png"))

]
#block[
#box(image("images/jupyter-preview.png"))

]
]
#block[
Learn more: #link("https://?meta:prerelease-subdomainquarto.org/docs/tools/jupyter-lab.html")[Jupyter];, #link("https://?meta:prerelease-subdomainquarto.org/docs/tools/vscode.html")[VS Code];, #link("https://?meta:prerelease-subdomainquarto.org/docs/tools/text-editors.html")[Text Editors]

]
= Authoring Tools
<authoring-tools-1>
RStudio includes an integrated presentation preview pane

#box(image("images/rstudio.png", width: 9.375in))

#block[
Learn more: #link("https://?meta:prerelease-subdomainquarto.org/docs/tools/rstudio.html")[RStudio]

]
= And More…
<and-more>
- #link("https://?meta:prerelease-subdomainquarto.org/docs/presentations/revealjs/advanced.html#touch-navigation")[Touch] optimized (presentations look great on mobile, swipe to navigate slides)
- #link("https://?meta:prerelease-subdomainquarto.org/docs/presentations/revealjs/#footer-logo")[Footer & Logo] (optionally specify custom footer per-slide or hide global footer)
- #link("https://?meta:prerelease-subdomainquarto.org/docs/presentations/revealjs/presenting.html#auto-slide")[Auto-Slide] (step through slides automatically, without any user input)
- #link("https://?meta:prerelease-subdomainquarto.org/docs/presentations/revealjs/presenting.html#multiplex")[Multiplex] (allows your audience to follow the slides of the presentation you are controlling on their own phone, tablet or laptop).

#block[
Learn more: #link("https://?meta:prerelease-subdomainquarto.org/docs/presentations/revealjs/")[Quarto Presentations]

]




