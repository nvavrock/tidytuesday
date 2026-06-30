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

**Context:** `2026_06_16_uk_baby_names` — plotly HTML report, overlap heatmap legend.

### ggplotly gotchas (interactive HTML)

- `ggplotly()` on faceted `geom_line()` can insert `null` between groups → invisible lines. Fix: explicit `group = Sex` (or color variable) and strip `NA`/`null` from plotly trace data in `as_interactive()`.
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

**ggplot side:** neutral gray `geom_boxplot(fill = "gray85")` + `geom_jitter(aes(color = region, text = hover))` — sex shown on x-axis, region on color, not fill.

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

---

## 2026-06-23 — Text viz and small-sample ML (Papal Encyclicals)

**Context:** `2026_06_23_papal_encyclicals` — tidytext tokenization, log-odds contrast, TF-IDF similarity, glmnet classifier on ~300 paragraphs.

### Text charts (prefer bars over word clouds)

- **Distinctive terms:** horizontal bar chart of log-odds ratio (positive = encyclical A, negative = encyclical B), not a word cloud — easier to read and label precisely.
- **Top-N limits:** cap at 10–15 terms per side; filter low-frequency words (`>= 5` total occurrences) before ranking.
- **Theme dictionary:** small hand-curated word lists (`tribble(theme, word)`) for narrative hooks; document the list in code, do not overfit with dozens of terms.

### TF-IDF paragraph similarity

- Tokenize once in `load_data.R` (`tokenize_paragraphs`); reuse for vocabulary, similarity, and classifier.
- Build document-term matrix with `bind_tf_idf()` at paragraph `doc_id` level; cosine similarity between MH and RN paragraphs.
- Scores stay modest (0.10–0.15) — frame as shared vocabulary, not semantic embeddings or direct quotation.

### Small-sample classifier caveats

- **Column name collision:** bag-of-words DTM columns can include common words like `pope` — rename label column (`pope_name`) before `inner_join()` so `select(-pope)` does not fail or drop the wrong column.
- **Honest framing:** two documents from different eras; lasso coefficients load on topic words (labor vs technology), not abstract style. Report hold-out accuracy vs majority-class baseline.
- **Scale fill labels:** if `if_else()` creates display labels like `"Leo XIV (2026)"`, manual scale names must match exactly — do not reuse short `POPE_COLORS` names without mapping.

### Static-only week

- Skip plotly/webshot2 when charts are bar/lollipop heavy; static PNGs are fine for report and LinkedIn.
- Number outputs sequentially in `output/` (`01_…` through `07_…`) plus small summary CSVs for tables in Quarto.

### Polish pass (takeaway titles + highlights)

- **Title = insight**, subtitle = scope/caveat (FT-style from Week 24).
- **Highlight key categories:** gray out "other" bars; color Leo XIII / Francis or flagship years (1891, 2026).
- **Direct labels:** `geom_text` on bar ends and lollipop scores — skip legend hunting.
- **Faceted log-odds:** split distinctive terms into two panels (`facet_wrap(~ lean, scales = "free_y")`) instead of one crowded diverging chart.
- **Export:** `dpi = 300`, slightly wider margins via shared `tt_theme(base_size = 13)`.

### Worked examples in this repo

| Lesson | File |
|--------|------|
| Tokenization + TF-IDF helpers | `2026_06_23_papal_encyclicals/R/load_data.R` |
| Log-odds vocabulary contrast | `2026_06_23_papal_encyclicals/R/03_vocabulary_evolution.R` |
| Paragraph similarity lollipop | `2026_06_23_papal_encyclicals/R/04_text_similarity.R` |
| glmnet + coefficient plot | `2026_06_23_papal_encyclicals/R/05_pope_classifier.R` |

---

## 2026-06-30 — Inside labels and week briefing notes

**Context:** Papal encyclicals polish — flagship year names clipped at plot edges; count labels floating outside bars.

### Keep labels inside the plot

**Symptom:** `annotate()` with `hjust = c(1.05, -0.05)` or `geom_text(hjust = -0.15)` pushes text past the panel; names truncate on export (e.g. “*rum Novarum*”).

**Fixes:**

- **Vertical bars:** place counts with `vjust = 1.35` on `y = n` (inside top of bar); use white text on saturated fills.
- **Horizontal bars:** `aes(x = n, label = n)` + `hjust = 1.05` (inside right end); white on highlight fills, `gray30` on gray bars.
- **Flagship annotations:** join a small data frame and use `geom_text(aes(y = pmax(n * 0.55, 0.65), ...))` centered on the bar instead of `annotate()` at the panel edge.
- **Lollipop scores:** label at `x = similarity * 0.92`, `hjust = 1`, dark text on the segment — not past the point.
- **Axis expand:** reduce outer margin (`expansion(mult = c(0, 0.06))`) once labels are inside; avoid compensating with huge right padding.

```r
geom_text(
  data = flagship,
  aes(x = year, y = pmax(n * 0.55, 0.65), label = name),
  inherit.aes = FALSE,
  hjust = 0.5, vjust = 0.5, color = "white"
)
```

### Week briefing notes (`NOTES.md`)

Each week folder should include **`NOTES.md`** — layman's briefing for non-technical readers:

1. **What this project is about** (one short paragraph)
2. **Key terms** (table)
3. **Charts** — one block per PNG: what it shows, story, caveats
4. **One-sentence elevator pitch**
5. **How to regenerate**

Copy the structure from `2026_06_16_uk_baby_names/NOTES.md` or `2026_06_23_papal_encyclicals/NOTES.md` when adding a new week.

### American English in user-facing text

- Chart titles, subtitles, `NOTES.md`, and `VIZ_LESSONS.md` prose: **American** spelling (`labor`, `color`, `gray`).
- Keep tidyverse function names (`summarise`, `color = "gray80"`) — package conventions, not copy editing.

### Worked examples in this repo

| Lesson | File |
|--------|------|
| Inside bar + flagship labels | `2026_06_23_papal_encyclicals/R/01_encyclical_output.R` |
| Week briefing template | `2026_06_23_papal_encyclicals/NOTES.md` |
| Week briefing template | `2026_06_16_uk_baby_names/NOTES.md` |
