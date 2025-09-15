### System Reliability and Six Sigma in R (`sigma`)

Your online textbook for learning reliability and six sigma techniques in R. These coding workshops are authored for Cornell University course SYSEN 5300 and rendered as an interactive Gitbook.

- **Live site**: [timothyfraser.com/sigma](https://www.timothyfraser.com/sigma)
- **Recommended environment**: [Posit Cloud](https://posit.cloud) for running R code hands-on
- **Course data**: [`timothyfraser/sysen`](https://github.com/timothyfraser/sysen)

---


### Purpose

- **Teach reliability and Six Sigma with code-first workshops**: each chapter mixes short narrative explanations, runnable examples, and hands-on “Learning Checks.”
- **Make applied methods accessible**: use plain language, small reproducible examples, and visual intuition.
- **Be classroom-friendly**: chapters are chunked for live instruction and self-paced study.

---

### How the book renders and deploys

- **Renderer**: `bookdown::gitbook` (HTML) defined in `_output.yml`.
- **Entry point**: `index.Rmd` with `site: bookdown::bookdown_site` and bibliography configuration.
- **Chapter order**: explicitly set in `_bookdown.yml` under `rmd_files`.
- **Output directory**: `docs/` (configured in `_bookdown.yml`) for GitHub Pages hosting.
- **Static assets**: Gitbook libraries in `assets/` (via `_output.yml: lib_dir`), custom CSS in `styles.css`.
- **Deployment**: The script `book_dev.R` renders the site and commits/pushes the result to the default branch. GitHub Pages is configured to serve from `docs/`, making the site available at `timothyfraser.com/sigma`.

Render locally (from the project root):

```r
# Install once (see Packages section below)
install.packages(c("bookdown", "tidyverse", "gert", "credentials", "knitr", "kableExtra", "broom", "ggplot2"))

# Build the Gitbook into docs/
bookdown::render_book(input = "index.Rmd", new_session = TRUE, output_format = "bookdown::gitbook")

# Optional: live preview during authoring
# bookdown::serve_book(dir = ".", output_dir = "docs", preview = TRUE)
```

Automated render-and-push (as used by the maintainer):

```r
# See book_dev.R
bookdown::render_book(input = "index.Rmd", new_session = TRUE, output_format = "bookdown::gitbook")
gert::git_add(files = dir(all.files = TRUE, recursive = TRUE))
gert::git_commit_all(message = "Update site")
gert::git_push()
```

---

### Repository layout

- **`index.Rmd`**: book front-matter, setup, and introduction.
- **`_bookdown.yml`**: chapter ordering (`rmd_files`), output directory, book filename, session behavior.
- **`_output.yml`**: output format (`bookdown::gitbook`) and Gitbook config (CSS, TOC, toolbar, fontsettings).
- **`styles.css`**: custom styles, notably Learning Check coloring via `.LC` and `#LC1…#LC10` selectors, and a small button style set.
- **`docs/`**: compiled site (do not edit by hand). Served by GitHub Pages.
- **`images/`**: figures and static images, referenced via `knitr::include_graphics()`.
- **`code/`**: auxiliary code and chapter-specific assets (e.g., `code/15_workshop/report.Rmd`).
- **`workshops/`**: supplemental workshop materials (if present for a given term).
- **`book_dev.R`**: maintainer script to render and push.
- **`book.bib`, `packages.bib`**: references and package citations.
- **`LICENSE`**: licensing information.
- **`404.html`**: custom not-found page to support GitHub Pages routing.

Chapters are organized into thematic parts using the `00_part*.Rmd` files, followed by numbered workshop chapters (e.g., `01_workshop.Rmd`, `10_workshop.Rmd`), and appendices (`99_*`). The exact order is controlled by `_bookdown.yml`.

---

### Authoring conventions (house style)

- **Tone**: friendly, encouraging, and classroom-oriented. Prefer short paragraphs, concrete examples, and bold emphasis for key ideas.
- **Headings**:
  - Top-level chapter header: `# Title`.
  - Unnumbered sections use the trailing attribute: `## Getting Started {-}`.
  - Learning Checks use: `## Learning Check N {.unnumbered .LC}`.
- **Learning Checks**: present a question, then reveal the answer with a collapsible block:

```markdown
## Learning Check 1 {.unnumbered .LC}

**Question**

Prompt text here...

<details><summary>**[View Answer!]**</summary>

Short explanation, then runnable code.

```{r}
# minimal, focused code showing the solution
```

</details>
```

- **Chunk options**: default to quiet, reproducible chunks.

```r
# In each chapter's setup chunk
knitr::opts_chunk$set(cache = FALSE, message = FALSE, warning = FALSE)
```

- **Libraries**: prefer the tidyverse for data work; call functions explicitly when name clashes (e.g., `select = dplyr::select`).
- **Graphics**: use `ggplot2` with clear labels and a clean theme (often `theme_classic(base_size = 14)`).
- **Images**: include with `knitr::include_graphics(path = "images/<file>")`; set `out.width = "100%"` and `fig.align = 'center'` when appropriate.
- **Graphics API Issues**: If you encounter "Graphics API version mismatch" errors, ensure your setup chunks use `knitr::opts_chunk$set(dev = "png")` instead of `ragg_png`. Use `png()` device directly for `ggsave()` operations to avoid `ragg` conflicts.
- **Math**: inline math with `\( ... \)`; display math with `$$ ... $$`.
- **Spacing**: use `<br>` to insert intentional white space between major blocks.
- **Linking**: prefer Markdown links with descriptive text rather than bare URLs.

---

### Adding or updating a chapter

1. Create a new `*.Rmd` with a top-level `#` title and a `setup` chunk setting your chunk defaults.
2. Place any images in `images/` and reference via `knitr::include_graphics()`.
3. If you add Learning Checks, apply the `.LC` pattern above so section coloring in `styles.css` applies.
4. Add the new file to `_bookdown.yml` under `rmd_files` in the correct position.
5. Render locally; verify the output in `docs/`.
6. Commit the source and the rebuilt `docs/` folder; push to update the live site.
7. This book gets deployed via Github Pages from the `main` branch's `docs/` folder.

---

#### R Packages

Core packages used across chapters include:

- `bookdown`, `knitr`, `rmarkdown`
- `tidyverse` (`dplyr`, `ggplot2`, etc.)
- `kableExtra`, `broom`, `magick` (varies by chapter)
- `gert`, `credentials` (for the maintainer's render-and-push workflow)
- `reticulate` (for Python integration)

Install in R:

```r
install.packages(c(
  "bookdown", "knitr", "rmarkdown", "tidyverse",
  "ggplot2", "kableExtra", "broom", "magick",
  "gert", "credentials", "reticulate"
))
```

#### Python Packages

Some chapters include Python code that requires additional packages:

- `matplotlib` - for plotting and visualization
- `pandas` - for data manipulation and analysis
- `plotnine` - Python port of ggplot2 for advanced plotting
- `dfply` - for data manipulation (similar to dplyr in R)
- `gapminder` - for gapminder dataset used in visualization examples
- `seaborn` - for color palettes
- `sympy` - for symbolic mathematics and reliability calculations

Install in Python:

```bash
pip install matplotlib pandas plotnine dfply gapminder seaborn sympy
```

Or if using a specific Python installation:

```bash
C:/Python312/python.exe -m pip install matplotlib pandas plotnine dfply gapminder sympy
```

---

### License and attribution

This project is licensed under the terms in `LICENSE`.

Please cite materials as appropriate. Bibliography files (`book.bib`, `packages.bib`) are configured in `index.Rmd` with `biblio-style: apalike` and `link-citations: yes`.

---

### Support

Questions? Reach out to maintainer Dr. Tim Fraser at `tmf77[at]cornell.edu`.
