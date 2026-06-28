# LinkedIn post draft — TidyTuesday UK Baby Names

**Strategy:** Carousel of 3 chart images (one per takeaway) + link to the **interactive** Quarto report (hover for exact counts/ranks). LinkedIn cannot embed plotly inside the post — the link is where readers explore.

**Interactive report:** https://nvavrock.github.io/tidytuesday/2026_06_16_uk_baby_names/analysis.html

---

## Post text (copy below)

This week I joined #TidyTuesday and explored UK baby names across England & Wales, Scotland, and Northern Ireland.

Three things stood out (swipe the carousel):

1. **Regional comparison** — Boys' top names (Noah, Oliver, Muhammad) overlap more across regions than girls' names, which vary more by country.

2. **Name uniqueness** — Girls' names are consistently more diverse: a larger share of births use names outside the top 100.

3. **The Bridgerton effect** — In Scotland, Daphne rose from 476th to 172nd, Eloise from 124th to 91st, and Penelope from 81st to 71st between 2024 and 2025. Pop culture shows up in the data.

All criticism welcome — charts, copy, or angles I should have explored.

**Interactive report** (hover charts for exact values): https://nvavrock.github.io/tidytuesday/2026_06_16_uk_baby_names/analysis.html

Code: https://github.com/nvavrock/tidytuesday/tree/main/2026_06_16_uk_baby_names

Data: TidyTuesday / ONS, NISRA, National Records of Scotland  
https://github.com/rfordatascience/tidytuesday/tree/main/data/2026/2026-06-16

#TidyTuesday #RStats #DataViz #DataScience

---

## Carousel images (attach in this order)

| Slide | File | Matches takeaway |
|-------|------|------------------|
| 1 | `output/01_regional_top_names.png` | Regional comparison |
| 2 | `output/04_uniqueness_by_sex.png` | Name uniqueness |
| 3 | `output/05_bridgerton_trend.png` | Bridgerton effect |

**Optional 4th slide:** `output/06_bridgerton_2024_2025.png` (2024 vs 2025 rank change; missing-data notes in caption).

Before posting, confirm PNGs match the report:

```r
source("run_week.R"); run_week("2026_06_16_uk_baby_names")
source("render_week.R"); render_week("2026_06_16_uk_baby_names")
```

---

## Alt text (LinkedIn image description — one per slide)

**Slide 1 — Regional comparison:**  
Horizontal bar charts showing the top 10 baby names for boys and girls in England & Wales, Scotland, and Northern Ireland in 2024. Bar length is the count of babies given each name; each region uses its own scale.

**Slide 2 — Name uniqueness:**  
Box plot of the share of births with names outside the top 100, by sex, with points coloured by UK region (2016–2025). Girls consistently have a higher share of less common names.

**Slide 3 — Bridgerton trend:**  
Line charts of baby name rank over time for Daphne, Eloise, and Penelope in England & Wales, Scotland, and Northern Ireland. Lower rank means more popular; Scotland shows a sharp rise around 2025.

**Optional slide 4 — Bridgerton 2024 vs 2025:**  
Slope chart comparing name rank in 2024 and 2025 by region. Downward lines mean a name became more popular.

---

## Before posting

- [x] Push project to public GitHub repo
- [x] Host interactive report on GitHub Pages
- [x] Set report URL in post text
- [x] Upload carousel slides 1–3 from `output/` (in order above)
- [x] Paste alt text for each slide in LinkedIn's image description field
- [x] Post published on LinkedIn
- [ ] Optional: comment on the [TidyTuesday LinkedIn announcement](https://www.linkedin.com/in/lgibson7/) — skipped

---

## Note

Share findings on **social media** with `#TidyTuesday`, not as a pull request to the official dataset repo. Credit ONS, NISRA, and National Records of Scotland via [TidyTuesday](https://tidytues.day).
