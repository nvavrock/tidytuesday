# LinkedIn — UFC Athletes and Fight Data (Week 27 · 2026-07-07)

Draft post for sharing the interactive finish dashboard and static report.

---

## Post copy

Week 27 #TidyTuesday: UFC fight data — I cared less about card volume and more about **how fights end**, and whether **reach** shows up in results the way it feels on the mat.

Background (honest): I've trained  **jiu-jitsu, wrestling, and boxing**, nothing worth about at all. I was average and was never the guy people asked for fight advice. But you still learn that **reach matters** when someone with longer arms is in your space. I **barely watch UFC cards**, so this week was less "fan take" and more "does the data back up something I felt on the mat?"

One pattern that stood out in the static **finish mix** chart: the **decision share has grown** over time (especially in recent years), while KOs and subs are still there but no longer dominate the way they did in earlier eras. The sport has gotten **more technical**: better defense, layering of wrestling and BJJ, safer striking entries, deeper rosters. That shows up as more fights going the distance, not necessarily "boring," just harder to finish. 

**Main artifact — interactive finish dashboard**  
[https://nvavrock.github.io/tidytuesday/2026_07_07_ufc_fights/output/_widget/finish_dashboard.html](https://nvavrock.github.io/tidytuesday/2026_07_07_ufc_fights/output/_widget/finish_dashboard.html)

Filter by **year**, **event**, **outcome**, and **division** with linked donuts + a searchable fight table (2020–2026, through **2026-06-27**). Multi-select slices with the tables and charts stay in sync. This is the piece I'd actually use to **dial into** a year or event and see whether that decision-heavy pattern holds.

**Stack**  
R + tidyverse · Crosstalk · plotly · custom JS (slice selection, year↔event sync) · DT · htmltools standalone HTML · Quarto report for the angle charts. Data: `{fightr}` / TidyTuesday UFCStats.

**Reach (what I expected)**  
Longer-reach fighter wins **~59%** of bouts where reach differs. Helpful edge, not deterministic.

**Static report** (finish mix over time, reach, weight classes, etc.):  
[https://nvavrock.github.io/tidytuesday/2026_07_07_ufc_fights/analysis.html](https://nvavrock.github.io/tidytuesday/2026_07_07_ufc_fights/analysis.html)

#TidyTuesday #RStats #DataViz — credit Benjamin Smith / [TidyTuesday 2026-07-07](https://github.com/rfordatascience/tidytuesday/tree/main/data/2026/2026-07-07).

**Criticism welcome!** If you open the dashboard: filter flow, donut interaction, table density, visual hierarchy, mobile — what's confusing, what's missing, what would you cut? I'd rather hear that than praise.

---



## Images (carousel)

Upload as a **4-slide carousel**. Post link in the body still points to the live interactive dashboard (slides 3–4).

### Slide 1 — finish dashboard (donuts + filters)

**File:** `output/05_finish_dashboard_donuts.png` (same as `report-figures/05_finish_dashboard_donuts.png`)

Screenshot of the **Finish breakdown** app with filters applied (example: 2020–2024, lightweight + light heavyweight selected). Hero KPIs, year/event filters, and linked outcome + division donuts.

**Alt text:** Dark-themed UFC finish dashboard with 397 active fights filtered to 2020–2024. Outcome donut shows decisions ~70%, submissions ~28%; men's divisions split lightweight vs light heavyweight; women's division donut visible with strawweight, featherweight, bantamweight, and flyweight slices.

### Slide 2 — finish dashboard (fight log)

**File:** `output/06_finish_dashboard_table.png` (same as `report-figures/06_finish_dashboard_table.png`)

Same filter state with the scrollable **Fight log** table: event, winner, loser, division, outcome, method, and judging details — shows how donut selections drill into individual bouts.

**Alt text:** UFC finish dashboard fight log table beneath three donuts. Rows list events, winners and losers, divisions, outcomes (decision vs submission), methods (e.g. unanimous decision, rear naked choke), and judges; outcome donut shows 397 fights with ~70% decisions.

### Slide 3— finish mix

**File:** `output/02_finish_mix.png` (same as `report-figures/02_finish_mix.png`)

Stacked share of finish type by year (2000–2026). Pairs with the “more technical → more decisions” paragraph in the post.

**Alt text:** Stacked bar chart of UFC finish types by year. The decision band grows as a share of outcomes from the 2000s through 2026; KO/TKO and submission shares remain substantial but no longer dominate recent years.

### Slide 4 — reach advantage

**File:** `output/03_reach_advantage.png` (same as `report-figures/03_reach_advantage.png`)

Win rate when one fighter has longer reach (excluding equal reach). Pairs with the **Reach (what I expected)** paragraph.

**Alt text:** Bar chart of win share when the longer-reach fighter has the reach advantage, split by red vs blue corner. Longer reach wins roughly 44–59% of bouts where reach differs — an edge, not a lock.

---



## Links


| What                         | URL                                                                                                                                                                                                    |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Interactive dashboard (lead) | [https://nvavrock.github.io/tidytuesday/2026_07_07_ufc_fights/output/_widget/finish_dashboard.html](https://nvavrock.github.io/tidytuesday/2026_07_07_ufc_fights/output/_widget/finish_dashboard.html) |
| Quarto report                | [https://nvavrock.github.io/tidytuesday/2026_07_07_ufc_fights/analysis.html](https://nvavrock.github.io/tidytuesday/2026_07_07_ufc_fights/analysis.html)                                               |
| Week folder (GitHub)         | [https://github.com/nvavrock/tidytuesday/tree/main/2026_07_07_ufc_fights](https://github.com/nvavrock/tidytuesday/tree/main/2026_07_07_ufc_fights)                                                     |
| TidyTuesday dataset          | [https://github.com/rfordatascience/tidytuesday/tree/main/data/2026/2026-07-07](https://github.com/rfordatascience/tidytuesday/tree/main/data/2026/2026-07-07)                                         |
| `{fightr}`                   | [https://github.com/benyamindsmith/fightr](https://github.com/benyamindsmith/fightr)                                                                                                                   |
| LinkedIn preview refresh     | [https://www.linkedin.com/post-inspector/](https://www.linkedin.com/post-inspector/)                                                                                                                   |


---



## Note

Share findings on **social media** with `#TidyTuesday`, not as a pull request to the official dataset repo. Credit Benjamin Smith and UFCStats via [TidyTuesday](https://tidytues.day). Confirm GitHub Pages serves `output/_widget/finish_dashboard.html` before posting.
