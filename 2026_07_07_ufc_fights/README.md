# UFC Athletes and Fight Data — TidyTuesday 2026-07-07

Week 27 analysis: UFC bout outcomes, schedule growth, and physical edges.

## Run

From project root:

```r
source("run_week.R")
run_week("2026_07_07_ufc_fights")
```

Or from this folder:

```r
source("../install_packages.R")
source("run.R")
```

## Report

Open [analysis.html](analysis.html) in a browser, or render from project root:

```r
source("render_week.R")
render_week("2026_07_07_ufc_fights")
```

The HTML report embeds static PNGs from `output/`. Run `run_week()` before `render_week()` when charts change.

## Outputs

- `output/` — 4 charts + 4 summary CSVs (300 dpi PNGs for LinkedIn and slides)
- `output/_widget/finish_dashboard.html` — standalone interactive finish-mix dashboard (year, event, outcome, division filters; donut + fight table). Open in a browser after `run_week()`.
- `analysis.qmd` / `analysis.html` — static report
- `NOTES.md` — plain-language briefing for sharing

## Data

Official dataset: https://github.com/rfordatascience/tidytuesday/tree/main/data/2026/2026-07-07

- `data/ufc_fights.csv` — UFCStats bout records (committed)
- `data/ultimate_ufc_dataset.csv` — merged fight/athlete features fetched by `download_data()` on first run (Kaggle / fightr)
