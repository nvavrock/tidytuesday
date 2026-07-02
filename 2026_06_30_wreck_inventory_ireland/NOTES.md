# Briefing notes — Wreck Inventory of Ireland (Week 26 · 2026-06-30)

Plain-language guide for sharing this project with people who are not data scientists.

**Full report:** [analysis.html](analysis.html) (static charts; same PNGs as `output/`)  
**Data source:** [TidyTuesday](https://github.com/rfordatascience/tidytuesday/tree/main/data/2026/2026-06-30) · National Monuments Service WIID · curated by Cormac Monaghan

---

## What this project is about

The **Wreck Inventory of Ireland Database (WIID)** lists more than **18,000** known and potential shipwreck records in Irish waters — from prehistoric logboats to World War casualties. This analysis asks how complete the geographic record is, when wrecks cluster in time, where mapped sites lie, and what vessel types dominate the catalog.

---

## Key terms

| Term | Plain meaning |
|------|----------------|
| **WIID** | Wreck Inventory of Ireland Database — official catalog maintained by Ireland's National Monuments Service |
| **Located wreck** | Record with usable latitude/longitude (not missing or hardcoded zero) |
| **Descriptive date** | Original date text when an exact calendar year could not be assigned |
| **Classification** | Vessel type label (e.g. schooner, steamship) — often "Unknown" |

---

## Charts (what each one shows)

### `01_location_status.png`
**What:** Count of records with vs without coordinates.  
**Story:** ~80% of records have no mapped location — many wrecks are documented but not yet georeferenced.

### `02_wrecks_over_time.png`
**What:** Records per decade (1500–2020) where a year exists.  
**Story:** Peaks in the 1800s and around WWI; reflects both maritime traffic and catalog completeness.

### `03_wreck_map.png`
**What:** Cartographic map — Tailte Éireann landmask (Republic), OSNI outline (Northern Ireland), major lakes (Ree, Derg, Corrib, Neagh, etc.), wreck points.  
**Story:** Coastal clustering; inland wrecks align with mapped loughs where Natural Earth has geometry.

### `04_top_classifications.png`
**What:** Top 10 vessel type labels.  
**Story:** "Unknown" is largest; sailing ship types lead among labelled records.

---

## One-sentence elevator pitch

"Of 18,000 Irish shipwreck records, only one in five has coordinates — and the catalog peaks in the age of sail and the World Wars."

---

## How to regenerate

```r
source("run_week.R"); run_week("2026_06_30_wreck_inventory_ireland")
source("render_week.R"); render_week("2026_06_30_wreck_inventory_ireland")
```
