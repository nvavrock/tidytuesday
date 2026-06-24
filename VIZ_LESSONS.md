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

---

## 2026-06-23 — Animation, interactivity, and legend fixes

**Context:** `2026_06_16_uk_baby_names` — bar chart race, plotly HTML report, overlap heatmap legend.

### Bar chart race (gganimate)

- Top-N race: map **rank to fixed y slots** (`slot = top_n + 1 - Rank`) so bars slide between positions; `transition_time(Year)`.
- Scope one region for a clean series (England & Wales 1996–2024).
- **gifski** `anim_save()` expects **pixels**: `width = width_in * dpi`, not inches.

### ggplotly gotchas (interactive HTML)

- `ggplotly()` on faceted `geom_line()` can insert `null` between groups → invisible lines. Fix: explicit `group = Sex` (or colour variable) and strip `NA`/`null` from plotly trace data in `as_interactive()`.
- Custom tooltips: build a `hover` string column, `aes(text = hover)`, then `ggplotly(..., tooltip = "text")`.
- Skip `ggrepel` when converting to plotly (`interactive = TRUE`); use hover instead.
- Static PNGs for LinkedIn stay ggplot-only; interactivity is for `analysis.html` only.

### Facet layout and labels

- When `facet_grid(..., scales = "free")` panels sit side by side, widen `panel.spacing.x` so x-axis labels do not run together (e.g. `6,000` + `0` → `6,0000`).
- Label the count axis explicitly (`x = "Babies given the name"`) when bars show raw registration counts.

### Discrete fill on heatmaps

**Symptom:** `scale_fill_gradient()` on integer counts (e.g. 2 vs 3 regions) shows a continuous legend (2.00, 2.25, …) that implies false precision.

**Fix:** `factor()` the count and use `scale_fill_manual()` with one level per value:

```r
mutate(regions_in_top = factor(regions_in_top, levels = c(2, 3))) +
scale_fill_manual(
  "Regions in top 10",
  values = c("2" = "#deebf7", "3" = "#08519c"),
  labels = c("2" = "2 regions", "3" = "All 3 regions")
)
```

### Shared theme

- `tt_theme()` in `load_data.R`: bold `plot.title` and facet strip text across all week plots.

### Worked examples in this repo

| Lesson | File |
|--------|------|
| Bar chart race | `2026_06_16_uk_baby_names/R/04_top10_race.R` |
| plotly wrapper + bold theme | `2026_06_16_uk_baby_names/R/load_data.R` |
| Discrete overlap heatmap legend | `2026_06_16_uk_baby_names/R/01_regional_comparison.R` |

---

## 2026-06-24 — Plotly PNG export, boxplot legend, LinkedIn carousel

**Context:** `2026_06_16_uk_baby_names` — export interactive uniqueness chart to PNG for LinkedIn; fix plotly region legend on boxplot + jitter.

### Static PNG from a plotly-ready ggplot (`save_interactive_png`)

**Problem:** `04_uniqueness_by_sex.png` needs jitter tooltips and region colors like the HTML report, but LinkedIn cannot embed plotly.

**Pattern:** render ggplot → `as_interactive()` → `htmlwidgets::saveWidget()` → `webshot2::webshot()` to PNG.

```r
save_interactive_png <- function(plot, path, width = 960, height = 720, zoom = 2) {
  if (!requireNamespace("webshot2", quietly = TRUE) ||
      !requireNamespace("htmlwidgets", quietly = TRUE)) {
    ggplot2::ggsave(path, plot, width = width / 150, height = height / 150, dpi = 150)
    return(invisible(path))
  }
  px <- as_interactive(plot) |> plotly::config(displayModeBar = FALSE)
  tmp <- tempfile("plotly_widget_"); dir.create(tmp)
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)
  htmlwidgets::saveWidget(px, file.path(tmp, "chart.html"), selfcontained = FALSE)
  webshot2::webshot(file.path(tmp, "chart.html"), path,
                    vwidth = width, vheight = height, zoom = zoom)
}
```

- Add **webshot2** to `install_packages.R`; needs a headless browser (Chromium via webshot2).
- Fallback to plain `ggsave()` when webshot2 is missing — chart still exports, without plotly polish.
- Use in `run.R` only for charts that benefit from plotly (e.g. jitter hover); keep other slides as ggplot `ggsave()`.

### ggplotly: boxplot + jitter legend

**Symptoms:** duplicate legend entries; box traces labeled "1", "2"; region names buried in trace names like `"1, England & Wales"`.

**Fixes in `as_interactive()`:**

1. **Hide box from legend:** `if (trace$type == "box") trace$showlegend <- FALSE`
2. **Parse region from jitter trace names:** if `grepl(",", trace$name)`, set `trace$name` to text after the comma and set `trace$legendgroup`
3. **Dedupe legend:** track `shown_legend_groups`; set `showlegend = FALSE` on duplicate groups
4. **Strip NA/null** from scatter trace `x`, `y`, `text` after `ggplotly()` — prevents invisible points
5. **Layout:** `legend = list(orientation = "v", x = 1.02, xanchor = "left")` plus `plot.margin` right padding (~80pt) so legend is not clipped in PNG

**ggplot side:** neutral grey `geom_boxplot(fill = "grey85")` + `geom_jitter(aes(color = region, text = hover))` — sex shown on x-axis, region on color, not fill.

### LinkedIn carousel (static export)

- **One headline per slide.** Three angles (regional, uniqueness, Bridgerton) = three slides; do not expect readers to find a second story (e.g. regional bands in jitter) unless the caption says so.
- **Faceted bars with `scales = "free"`:** bar length is only comparable within a panel — say so in post text and alt text.
- **Boxplot + jitter on a phone:** legend and overlapping points are cramped without hover; for feed-only posts consider dodged bars or `facet_wrap(~ region)`.
- **Sparse line panels:** when one region lacks 2025 data, a **slope chart** (2024 vs 2025 ranks) tells the YoY story more directly than three line facets.
- **Copy:** lead with one surprising number (e.g. #1 name); quantify each takeaway; invite criticism in one line if you want comments.
- **Split audiences:** carousel = static highlights; GitHub Pages / `analysis.html` = hover, overlap heatmap, extra charts.

### Diversity metric (for tooltips and captions)

- `% outside top 100` = `sum(Number[Rank > 100 | is.na(Rank)]) / sum(Number)` per **region × year × sex**.
- Rankings are **per region per year**, not pooled UK-wide.
- `names_per_1000_births` = `n_distinct(Name) / total_births * 1000` — different lens than top-100 concentration.

### Worked examples in this repo

| Lesson | File |
|--------|------|
| `save_interactive_png` + `as_interactive` legend fix | `2026_06_16_uk_baby_names/R/load_data.R` |
| Boxplot + jitter uniqueness chart | `2026_06_16_uk_baby_names/R/02_name_uniqueness.R` |
| LinkedIn post draft + alt text | `2026_06_16_uk_baby_names/LINKEDIN.md` |
