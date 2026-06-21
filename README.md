# TidyTuesday: UK Baby Names (2026-06-16)

Weekly analysis for [TidyTuesday Week 24](https://github.com/rfordatascience/tidytuesday/tree/main/data/2026/2026-06-16) — baby names across England & Wales, Scotland, and Northern Ireland.

## Open in RStudio

1. Open `tidytuesday.Rproj` in RStudio (double-click the file or **File → Open Project**).
2. Install packages once:

```r
source("install_packages.R")
```

3. Run everything:

```r
source("run_all.R")
```

   Or render the full report:

```r
quarto::quarto_render("analysis.qmd")
```

   In RStudio: open `analysis.qmd` and click **Render**.

Plots are saved to `output/`.

## Three angles explored

| Angle | Question | Output |
|-------|----------|--------|
| **Regional comparison** | How do top names differ across UK regions? | `output/01_regional_top_names.png`, `02_regional_overlap.png` |
| **Name uniqueness** | Are boys' or girls' names more unique? | `output/03_uniqueness_over_time.png`, `04_uniqueness_by_sex.png` |
| **Bridgerton trend** | Did Daphne, Eloise, and Penelope rise after the show? | `output/05_bridgerton_trend.png`, `06_bridgerton_2024_2025.png` |

## Project structure

```
tidytuesday/
├── tidytuesday.Rproj      # Open this in RStudio
├── install_packages.R     # One-time package setup
├── run_all.R              # Generate all plots + summary CSVs
├── analysis.qmd           # Full Quarto report (all three angles)
├── R/
│   ├── load_data.R
│   ├── 01_regional_comparison.R
│   ├── 02_name_uniqueness.R
│   └── 03_bridgerton_trend.R
├── data/                  # CSV files (downloaded automatically if missing)
└── output/                # Generated plots and summary tables
```

## Data sources

- [England & Wales baby names](https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/livebirths/datasets/babynamesinenglandandwalesfrom1996) (ONS)
- [Scotland baby names](https://www.nrscotland.gov.uk/publications/babies-first-names-2025/) (National Records of Scotland)
- [Northern Ireland baby names](https://www.nisra.gov.uk/publications/baby-names-2025) (NISRA)

Curated by [Nicola Rennie](https://github.com/nrennie) for TidyTuesday.

## Share on social media

Use `#TidyTuesday` and `#RStats`. Link to this repo and include alt text for charts. See `LINKEDIN.md` for a ready-to-edit post.

## Citation

```bibtex
@misc{tidytuesday,
  title = {Tidy Tuesday: A weekly social data project},
  author = {Data Science Learning Community},
  url = {https://tidytues.day},
  year = {2024}
}
```
