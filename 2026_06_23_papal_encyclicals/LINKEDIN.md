# LinkedIn post draft — TidyTuesday Papal Encyclicals

**Strategy:** Carousel of 3 chart images (one per takeaway) + link to the **static** Quarto report (same PNGs as `output/`). LinkedIn cannot embed the full report — the link is where readers explore all eight charts.

**Report:** https://nvavrock.github.io/tidytuesday/2026_06_23_papal_encyclicals/analysis.html

---

## Post text (copy below)

This week I joined #TidyTuesday and compared two papal encyclicals that bookend 135 years of technological change: Pope Leo XIII's *Rerum Novarum* (1891, the Industrial Revolution) and Pope Leo XIV's *Magnifica Humanitas* (2026, the AI era).

Three things stood out (swipe the carousel):

1. **Encyclical output over time** — Volume peaked in the late 19th century; Leo XIII alone wrote 86. Orange bars mark the two texts we study. Modern popes also teach through speeches and other formats not in this catalog.

2. **Vocabulary shift** — *Rerum Novarum* leans industrial and labor language; *Magnifica Humanitas* brings in technology, digital, and intelligence. Catholic social teaching vocabulary tracks the era.

3. **Theme words** — A hand-picked word list shows technology and AI terms appear only in the 2026 text, while dignity and labor language spans both.

All criticism welcome — charts, copy, or angles I should have explored.

**Full report** (eight charts + tables): https://nvavrock.github.io/tidytuesday/2026_06_23_papal_encyclicals/analysis.html

Code: https://github.com/nvavrock/tidytuesday/tree/main/2026_06_23_papal_encyclicals

Data: Vatican.va via TidyTuesday; curated by Tony Galvan  
https://github.com/rfordatascience/tidytuesday/tree/main/data/2026/2026-06-23

#TidyTuesday #RStats #DataViz #DataScience

---

## Carousel images (attach in this order)

| Slide | File | Matches takeaway |
|-------|------|------------------|
| 1 | `output/01_encyclical_output_over_time.png` | Encyclical output over time |
| 2 | `output/05_vocabulary_contrast.png` | Vocabulary shift (log-odds) |
| 3 | `output/05b_theme_words.png` | Theme word counts |

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

- [ ] Push project to public GitHub repo
- [ ] Host report on GitHub Pages; confirm URL loads
- [ ] Upload carousel slides 1–3 from `output/` (in order above)
- [ ] Paste alt text for each slide in LinkedIn's image description field
- [ ] Post published on LinkedIn
- [ ] Optional: comment on the [TidyTuesday LinkedIn announcement](https://www.linkedin.com/in/lgibson7/) with your report link

---

## Note

Share findings on **social media** with `#TidyTuesday`, not as a pull request to the official dataset repo. Credit [Vatican.va](https://www.vatican.va) and Tony Galvan via [TidyTuesday](https://tidytues.day).
