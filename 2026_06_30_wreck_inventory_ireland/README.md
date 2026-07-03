# Wreck Inventory of Ireland — TidyTuesday 2026-06-30

Week 26 analysis: Irish shipwreck records from the WIID catalog.

## Run

From project root:

```r
source("run_week.R")
run_week("2026_06_30_wreck_inventory_ireland")
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
render_week("2026_06_30_wreck_inventory_ireland")
```

The HTML report embeds static PNGs from `output/`. Run `run_week()` before `render_week()` when charts change.

## Outputs

- `output/` — 4 charts + 3 summary CSVs (300 dpi PNGs for LinkedIn and slides); `output/_widget/wreck_map.html` is an interactive Leaflet map with wreck tooltips
- `analysis.qmd` / `analysis.html` — static report
- `NOTES.md` — plain-language briefing for sharing

## Data

Official dataset: https://github.com/rfordatascience/tidytuesday/tree/main/data/2026/2026-06-30

- `data/wreck_inventory.csv` — TidyTuesday catalog (committed)
- `data/osi_landmask.geojson`, `data/osni_outline.geojson`, `data/ne_10m_lakes*.geojson` — basemap layers fetched by `download_data()` on first run (Tailte Éireann, OSNI open data, Natural Earth)
