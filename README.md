# TidyTuesday

Personal R analyses for the weekly [#TidyTuesday](https://tidytues.day) social data project.

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
run_week("2026_06_16_uk_baby_names")
```

4. Render the report:

```r
source("render_week.R")
render_week("2026_06_16_uk_baby_names")
```

Or open `2026_06_16_uk_baby_names/analysis.qmd` and click **Render** in RStudio.

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

## Visualization lessons (viz-rag)

Chart lessons from this repo feed the separate [viz-rag](https://github.com/nvavrock/viz-rag) retrieval corpus.

1. After improving charts, add a dated entry to [`VIZ_LESSONS.md`](VIZ_LESSONS.md) (what went wrong, what fixed it, link to the R file).
2. From the `viz-rag` repo, rebuild and re-embed:

```bash
python ingest/build_corpus.py
.venv\Scripts\python.exe -m rag.ingest
```

viz-rag ingests `VIZ_LESSONS.md`, week `R/*.R` plot functions, and its own `corpus/lessons/CHANGELOG.md`.

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
