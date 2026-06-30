# Briefing notes — UK Baby Names (Week 24 · 2026-06-16)

Plain-language guide for sharing this project with people who are not data scientists.

**Interactive report:** [analysis.html](analysis.html)  
**Data source:** [TidyTuesday](https://github.com/rfordatascience/tidytuesday/tree/main/data/2026/2026-06-16) · ONS, NISRA, National Records of Scotland

---

## What this project is about

Every year, UK governments record baby names from birth registrations. This analysis looks at **England & Wales**, **Scotland**, and **Northern Ireland** to answer three questions: Do the most popular names differ by country? Are parents choosing more unique names over time? Did *Bridgerton* character names rise after the show aired?

---

## Key terms

| Term | Plain meaning |
|------|----------------|
| **Rank** | Position in the popularity list (1 = most common that year in that region). Lower rank = more popular |
| **Top 100** | The 100 most common names in a region for a given year |
| **Distinct names per 1,000 births** | How many different names appear per 1,000 babies — higher = more naming diversity |
| **% outside top 100** | Share of babies given a name that was *not* in the top 100 — higher = less concentration on blockbuster names |
| **Facet / panel** | A small sub-chart for one group (e.g. one region or sex) |
| **Slope chart** | Dots for two years connected by a line — good for before/after rank changes |
| **Box plot** | Shows the typical range and spread of a metric; dots show individual years or regions |

---

## Charts (what each one shows)

### `01_regional_top_names.png`
**What:** Top 10 boy and girl names in each UK region for 2024 (horizontal bars).  
**Story:** Boys’ lists overlap more (Muhammad, Noah, Oliver); girls’ names vary more by country.  
**Caveat:** Each region has its own bar scale — compare lengths only within a panel, not across regions.

### `02_regional_overlap.png`
**What:** Heatmap of names that appear in multiple regions’ top 10.  
**Story:** Names like Olivia show up in more than one region’s elite list.

### `03_uniqueness_over_time.png`
**What:** Line trends for naming diversity by sex and region.  
**Story:** Girls’ names have become more diverse over time by several measures.

### `04_uniqueness_by_sex.png`
**What:** Box plot of “% outside top 100” by sex, with dots for each region/year.  
**Story:** Girls consistently show a higher share of less common names than boys.

### `05_bridgerton_trend.png`
**What:** Rank over time for Daphne, Eloise, and Penelope (Bridgerton characters).  
**Story:** Scotland shows sharp rank jumps around 2024–2025 for Daphne and Eloise.

### `06_bridgerton_2024_2025.png`
**What:** Slope chart comparing 2024 vs 2025 rank by region for those three names.  
**Story:** Downward lines = name became more popular (rank number got smaller).

---

## One-sentence elevator pitch

“We mapped the most popular baby names across three UK countries, tracked whether parents are picking rarer names, and checked whether Bridgerton boosted Daphne, Eloise, and Penelope.”

---

## Files to share

| Audience | Send them |
|----------|-----------|
| Quick overview | This `NOTES.md` |
| Full walkthrough | `analysis.html` (hover for exact counts) |
| Social / slides | PNGs in `output/` · draft copy in `LINKEDIN.md` |

---

## How to regenerate

```r
source("run_week.R"); run_week("2026_06_16_uk_baby_names")
source("render_week.R"); render_week("2026_06_16_uk_baby_names")
```
