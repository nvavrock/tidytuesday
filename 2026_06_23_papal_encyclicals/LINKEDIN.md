# LinkedIn post draft — TidyTuesday Papal Encyclicals

**Post style:** Then vs now (week 2).  
**Do not reuse from:** UK baby names — numbered list, “Three things stood out”, “All criticism welcome”.

**Strategy:** Carousel of 3 chart images (one per takeaway) + link to the **static** Quarto report (same PNGs as `output/`). LinkedIn cannot embed the full report — the link is where readers explore all eight charts.

**Report:** [https://nvavrock.github.io/tidytuesday/2026_06_23_papal_encyclicals/analysis.html](https://nvavrock.github.io/tidytuesday/2026_06_23_papal_encyclicals/analysis.html)

---

## Post text (copy below)

**1891:** factories, workers, *Rerum Novarum*.  
**2026:** AI, dignity, *Magnifica Humanitas*.

Week 2 on #TidyTuesday — I text-mined both encyclicals plus a catalog of 213 papal letters since 1878. The carousel walks through output over time, a vocabulary contrast (labor/industry vs technology/intelligence), and a small theme-word check where AI terms show up only in the 2026 text.

Leo XIII alone accounts for 86 encyclicals in the catalog; Francis has 4 — modern popes teach through many channels this dataset does not capture. Worth keeping in mind when you read the charts.

Write-up (eight charts + tables): https://nvavrock.github.io/tidytuesday/2026_06_23_papal_encyclicals/analysis.html

Code: https://github.com/nvavrock/tidytuesday/tree/main/2026_06_23_papal_encyclicals

Data: Vatican.va via TidyTuesday; curated by Tony Galvan  
https://github.com/rfordatascience/tidytuesday/tree/main/data/2026/2026-06-23

#TidyTuesday #RStats #DataViz #DataScience



## Carousel images (attach in this order)


| Slide | File                                        | Matches takeaway            |
| ----- | ------------------------------------------- | --------------------------- |
| 1     | `output/01_encyclical_output_over_time.png` | Encyclical output over time |
| 2     | `output/05_vocabulary_contrast.png`         | Vocabulary shift (log-odds) |
| 3     | `output/05b_theme_words.png`                | Theme word counts           |


Before posting, confirm PNGs match the report:

```r
source("run_week.R"); run_week("2026_06_23_papal_encyclicals")
source("render_week.R"); render_week("2026_06_23_papal_encyclicals")
```

---



## Alt text (LinkedIn image description — one per slide)

**Slide 1 — Encyclical output:**  
Bar chart of papal encyclicals published per year from 1878 to 2026. Orange bars mark flagship years; burgundy and green dashed lines label *Rerum Novarum* (1891) and *Magnifica Humanitas* (2026). Output peaks in the late 1800s.

**Slide 2 — Vocabulary contrast:**  
Horizontal bar chart of log-odds word contrasts between the two encyclicals. Words to the right are more common in *Rerum Novarum* (labor, workers, industry); words to the left are more common in *Magnifica Humanitas* (technology, digital, intelligence).

**Slide 3 — Theme words:**  
Grouped bar chart of counts for hand-picked theme words (dignity, labor, technology) in each encyclical. Technology and AI terms appear only in the 2026 text.

---



## Before posting

- [x] Push project to public GitHub repo
- [x] Host report on GitHub Pages; confirm URL loads
- [x] Upload carousel slides 1–3 from `output/` (in order above)
- [x] Paste alt text for each slide in LinkedIn's image description field
- [x] Post published on LinkedIn
- [ ] Optional: comment on the [TidyTuesday LinkedIn announcement](https://www.linkedin.com/in/lgibson7/) with your report link

---



## Note

Share findings on **social media** with `#TidyTuesday`, not as a pull request to the official dataset repo. Credit [Vatican.va](https://www.vatican.va) and Tony Galvan via [TidyTuesday](https://tidytues.day).

**Voice:** First TidyTuesday post (UK baby names) used “This week I joined #TidyTuesday”. Returning weeks use “Week N on #TidyTuesday” or “This week on #TidyTuesday” — do not say you joined again.