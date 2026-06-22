# Visualization lessons (TidyTuesday)

Dated notes from chart work in this repo. Ingested by [viz-rag](https://github.com/nvavrock/viz-rag) for retrieval — add an entry when you learn something worth reusing.

**Sync to viz-rag** (from `viz-rag` repo):

```bash
python ingest/build_corpus.py
.venv\Scripts\python.exe -m rag.ingest
```

---

## 2026-06-22 — UK baby names chart polish

**Context:** `2026_06_16_uk_baby_names` — regional top names, uniqueness, Bridgerton ranks.

### Editorial (FT-style)

- Put data source in `labs(caption = ...)` on every plot, not only in body text.
- Title = takeaway; subtitle = scope, years, caveats (e.g. "England & Wales through 2024").
- Direct-label series when there are few lines (3 Bridgerton names) — use `ggrepel::geom_text_repel()` on the latest year per group.

### Color and accessibility

- Use Okabe–Ito palettes for sex and region (`SEX_COLORS`, `REGION_COLORS` in `load_data.R`).
- Do not rely on color alone when categories must be distinguished — position and labels help.

### Chart types

- **Many name labels:** horizontal bars (`aes(x = Number, y = Name)`), not vertical bars with angled text.
- **Rank over time:** `scale_y_reverse()` on rank; line + points works; endpoint labels reduce legend hunting.
- **Rank between two years:** slope chart (points + lines, color by region, `facet_wrap(~ Name)`) beats reversed-y grouped bars.
- **Rank across two dimensions:** tile heatmap with rank labels (regional overlap chart).

### ggplot faceting gotcha (regional top-10 bars)

`facet_grid` shares axis levels across panels by default.

**Symptom:** overlapping name labels on one axis; sparse bars with huge gaps; Scotland/NI bars invisible on England & Wales count scale.

**Fix:**

```r
top_names |>
  group_by(region, Sex) |>
  slice_min(Rank, n = top_n) |>
  mutate(Name = forcats::fct_reorder(Name, Number)) |>
  ungroup() |>
  ggplot(aes(x = Number, y = Name, fill = Sex)) +
  geom_col() +
  facet_grid(Sex ~ region, scales = "free") +
  scale_x_continuous(labels = scales::comma)
```

- `scales = "free"` — each panel gets its own name list **and** count range.
- Reorder **per panel** with `fct_reorder` inside `group_by`, not global `reorder()` across the dataset.
- Prefer native horizontal bars over `coord_flip()` when faceting; if you flip, free the categorical axis after the flip.

### Worked examples in this repo

| Lesson | File |
|--------|------|
| Horizontal faceted top-N bars | `2026_06_16_uk_baby_names/R/01_regional_comparison.R` |
| Captions + color constants | `2026_06_16_uk_baby_names/R/load_data.R` |
| Uniqueness time series + boxplot | `2026_06_16_uk_baby_names/R/02_name_uniqueness.R` |
| Rank trend labels + slope YoY | `2026_06_16_uk_baby_names/R/03_bridgerton_trend.R` |
