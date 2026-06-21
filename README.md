# TidyTuesday

Personal R analyses for the weekly [#TidyTuesday](https://tidytues.day) social data project.

Official datasets: [rfordatascience/tidytuesday](https://github.com/rfordatascience/tidytuesday)

## RStudio (recommended)

Open the project from a **native Windows path** (not WSL):

```
C:/Users/me/Projects/tidytuesday/tidytuesday.Rproj
```

Quarto and RStudio work reliably there. You can use the **Render** button on `analysis.qmd` or run:

```r
source("render_week.R")
render_week("2026_06_16_uk_baby_names")
```

## Quick start

1. Open `tidytuesday.Rproj` in RStudio (Windows path above).
2. Install packages once:

```r
source("install_packages.R")
```

3. Run a week:

```r
source("run_week.R")
run_week("2026_06_16_uk_baby_names")
```

4. Render the report:

```r
source("render_week.R")
render_week("2026_06_16_uk_baby_names")
```

## Weeks

| Date | Topic | Folder |
|------|-------|--------|
| 2026-06-16 | UK Baby Names | [2026_06_16_uk_baby_names/](2026_06_16_uk_baby_names/) |

## Project layout

```
tidytuesday/
├── tidytuesday.Rproj
├── install_packages.R       # shared packages
├── run_week.R               # run any week folder
├── render_week.R            # render Quarto report for a week
└── 2026_06_16_uk_baby_names/
    ├── run.R
    ├── analysis.qmd
    ├── data/
    ├── output/
    └── R/
```

Add future weeks as sibling folders (e.g. `2026_06_23_next_topic/`).

## WSL copy

A mirror of this repo may exist at `\\wsl.localhost\Ubuntu\home\me\tidytuesday` for Cursor editing. **Use the Windows path for RStudio and Quarto.**

## Citation

```bibtex
@misc{tidytuesday,
  title = {Tidy Tuesday: A weekly social data project},
  author = {Data Science Learning Community},
  url = {https://tidytues.day},
  year = {2024}
}
```
