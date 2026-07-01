# Briefing notes — Papal Encyclicals (Week 25 · 2026-06-23)

Plain-language guide for sharing this project with people who are not data scientists.

**Full report:** [analysis.html](analysis.html) (static charts; same PNGs as `output/`)  
**Data source:** [TidyTuesday](https://github.com/rfordatascience/tidytuesday/tree/main/data/2026/2026-06-23) · Vatican.va · curated by Tony Galvan

---

## What this project is about

Pope Leo XIII wrote *Rerum Novarum* in **1891** about workers’ rights during the Industrial Revolution. Pope Leo XIV wrote *Magnifica Humanitas* in **2026** about human dignity in the age of AI. This analysis compares those two encyclicals — plus a catalog of **213 papal encyclicals from 1878–2026** — to see how Catholic social teaching language and papal output have changed over 135 years.

An **encyclical** is a formal letter from a Pope to the whole Church on an important topic. It is one of the most authoritative forms of papal teaching.

---

## Key terms

| Term | Plain meaning |
|------|----------------|
| **Encyclical** | A major papal letter on doctrine or social issues |
| **Paragraph (¶)** | One numbered section of an encyclical — our text data is split at this level |
| **Log-odds ratio** | A way to find words that appear much more often in one document than the other |
| **TF-IDF** | Weights words that are distinctive to a paragraph, not just common everywhere |
| **Cosine similarity** | A score (0–1) for how alike two paragraphs are by shared vocabulary; higher = more similar wording |
| **Lasso classifier** | A simple machine-learning model that tries to guess which Pope wrote a paragraph from word counts |
| **Hold-out accuracy** | How often the model is right on paragraphs it was not trained on |
| **Old / New Testament** | The two main parts of the Bible; citations show which scripture each Pope emphasizes |

---

## Charts (what each one shows)

### `01_encyclical_output_over_time.png`
**What:** How many encyclicals were published each year since 1878.  
**Story:** Output was highest in the late 1800s and early 1900s. Orange bars mark the two encyclicals we study (1891 and 2026); *Rerum Novarum* and *Magnifica Humanitas* are labeled in bold italic beside the dashed lines.  
**Caveat:** Y-axis uses whole-number ticks (0, 2, 4, 8) up to 10. Modern Popes also teach through speeches, tweets, and other formats not in this catalog.

### `02_encyclicals_per_pope.png`
**What:** Total encyclicals per Pope (top 12).  
**Story:** Leo XIII wrote **86**; Francis wrote **4** in this list — papal communication has diversified, not necessarily stopped.

### `03_scripture_testament.png`
**What:** Count of Bible citations, split Old vs New Testament, for each Pope’s flagship encyclical.  
**Story:** Compares which half of the Bible each text draws on.

### `04_scripture_books.png`
**What:** Most-cited books of the Bible (top 5 per Pope).  
**Story:** Shows concrete examples (e.g. Matthew, Genesis). RN citations were partly hand-mapped; MH citations were extracted by regex.

### `05_vocabulary_contrast.png`
**What:** Words that are statistically more common in one encyclical than the other.  
**Story:** *Rerum Novarum* leans industrial/labor language; *Magnifica Humanitas* leans technology/AI language.

### `05b_theme_words.png`
**What:** Counts for a small hand-picked word list (labor, dignity, technology, etc.).  
**Story:** Quick narrative check — technology/AI terms appear only in the 2026 text.

### `06_text_similarity.png`
**What:** Which paragraphs of the 2026 encyclical are most word-similar to paragraphs in the 1891 encyclical.  
**Story:** Suggests intellectual echoes, not proof of direct copying. Scores around **0.10–0.14** are modest.

### `07_classifier_coefficients.png`
**What:** Which words push the model toward Leo XIII vs Leo XIV.  
**Story:** The model often beats a naive baseline, but it picks up **topic words** (factory vs AI), not a hidden “writing fingerprint.” Treat as exploratory.

---

## One-sentence elevator pitch

“We compared the Pope’s 1891 letter on industrial workers to his 2026 letter on AI — and measured how papal encyclical output, Bible citations, and vocabulary changed across 135 years.”

---

## Files to share

| Audience | Send them |
|----------|-----------|
| Quick overview | This `NOTES.md` |
| Full walkthrough | `analysis.html` |
| Social / slides | PNGs in `output/` |

---

## How to regenerate

Run charts first, then render the HTML report (same PNGs appear in `analysis.html`):

```r
source("run_week.R"); run_week("2026_06_23_papal_encyclicals")
source("render_week.R"); render_week("2026_06_23_papal_encyclicals")
```
