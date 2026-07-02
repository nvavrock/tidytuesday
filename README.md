# TidyTuesday

Personal R analysis projects for the weekly [#TidyTuesday](https://tidytues.day) social data project.

Official datasets: [rfordatascience/tidytuesday](https://github.com/rfordatascience/tidytuesday)

## Quick start

1. Open `tidytuesday.Rproj` in RStudio.
2. Install packages once:

```r
source("install_packages.R")
```

3. Run a week:

```r
source("run_week.R")
run_week("2026_06_30_wreck_inventory_ireland")   # or other week folders below
```

4. Render the report:

```r
source("render_week.R")
render_week("2026_06_23_papal_encyclicals")
```

Or open that week's `analysis.qmd` and click **Render** in RStudio.

After chart changes, run both `run_week()` (updates `output/` PNGs) and `render_week()` (updates `analysis.html`). UK week uses plotly in HTML; papal and wreck weeks embed static PNGs.

## Weeks

| Date | Topic | Folder | HTML report |
|------|-------|--------|-------------|
| 2026-06-16 | UK Baby Names | [2026_06_16_uk_baby_names/](2026_06_16_uk_baby_names/) | Interactive (plotly) |
| 2026-06-23 | Papal Encyclicals | [2026_06_23_papal_encyclicals/](2026_06_23_papal_encyclicals/) | Static PNG embeds |
| 2026-06-30 | Wreck Inventory of Ireland | [2026_06_30_wreck_inventory_ireland/](2026_06_30_wreck_inventory_ireland/) | Static PNG embeds |

## Project layout

```
tidytuesday/
├── tidytuesday.Rproj
├── install_packages.R       # shared packages
├── run_week.R               # run any week folder
├── render_week.R            # render Quarto report for a week
├── 2026_06_16_uk_baby_names/
│   ├── run.R
│   ├── analysis.qmd
│   ├── NOTES.md
│   ├── data/
│   ├── output/
│   └── R/
├── 2026_06_23_papal_encyclicals/
│   ├── run.R
│   ├── analysis.qmd
│   ├── NOTES.md
│   ├── data/
│   ├── output/
│   └── R/
└── 2026_06_30_wreck_inventory_ireland/
    ├── run.R
    ├── analysis.qmd
    ├── NOTES.md
    ├── data/
    ├── output/
    └── R/
```

Add future weeks as sibling folders (e.g. `2026_06_23_next_topic/`). Each week should include **`NOTES.md`** — a plain-language briefing (what the project is, chart guide, key terms). See an existing week folder for the template.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution and LLM-assisted editing guidelines.

## Citation

```bibtex
@misc{tidytuesday,
  title = {Tidy Tuesday: A weekly social data project},
  author = {Data Science Learning Community},
  url = {https://tidytues.day},
  year = {2024}
}
```
