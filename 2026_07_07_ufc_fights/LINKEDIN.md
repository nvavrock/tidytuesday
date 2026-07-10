# LinkedIn — UFC Athletes and Fight Data (Week 27 · 2026-07-07)

Draft post for sharing the interactive finish dashboard and static report.

---

## Post copy

Week 27 #TidyTuesday: UFC fight data — I cared less about card volume and more about **how fights end**, and whether **reach** shows up in results the way it feels on the mat.

Background (honest): I've dabbled in **jiu-jitsu, wrestling, and boxing** — nothing worth bragging about on LinkedIn; I was never the guy people asked for fight advice. But you still learn that **reach matters** when someone with longer arms is in your space. I **barely watch UFC cards**, so this week was less "fan take" and more "does the data back up something I felt on the mat?"

One pattern that stood out in the static **finish mix** chart: the **decision share has grown** over time (especially in recent years), while KOs and subs are still there but no longer dominate the way they did in earlier eras. My read — and I'm open to pushback — is that the sport has gotten **more technical**: better defense, layering of wrestling and BJJ, safer striking entries, deeper rosters. That shows up as more fights going the distance, not necessarily "boring," just harder to finish. (Descriptive only — rules, judging, and data capture all moved too.)

**Main artifact — interactive finish dashboard**  
https://nvavrock.github.io/tidytuesday/2026_07_07_ufc_fights/output/_widget/finish_dashboard.html

Filter by **year**, **event**, **outcome**, and **division** with linked donuts + a searchable fight table (2020–2026, through **2026-06-27**). Multi-select slices Qlik-style; table and charts stay in sync. This is the piece I'd actually use to **dial into** a year or event and see whether that decision-heavy pattern holds.

**Stack**  
R + tidyverse · Crosstalk · plotly · custom JS (slice selection, year↔event sync) · DT · htmltools standalone HTML · Quarto report for the angle charts. Data: `{fightr}` / TidyTuesday UFCStats.

**Reach (what I expected)**  
Longer-reach fighter wins **~44–59%** of bouts where reach differs (`reach_dif` = Blue − Red) — corner matters in this sample. Helpful edge, not deterministic.

**Static report** (finish mix over time, reach, weight classes, etc.):  
https://nvavrock.github.io/tidytuesday/2026_07_07_ufc_fights/analysis.html

#TidyTuesday #RStats #DataViz — credit Benjamin Smith / [TidyTuesday 2026-07-07](https://github.com/rfordatascience/tidytuesday/tree/main/data/2026/2026-07-07).

**Criticism welcome** — Is the "more technical → more decisions" take fair, or am I overfitting a narrative to a stacked bar chart? Dashboard UX, reach framing, anything that overclaims — tell me what you'd cut.

---

## Image

**File to upload:** `output/02_finish_mix.png` (same as `report-figures/02_finish_mix.png`)

Stacked share of finish type by year (2000–2026). Use as the post image; link in the post body goes to the interactive dashboard.

### Alt text

Stacked bar chart of UFC finish types by year. The gray decision band grows as a share of outcomes from the 2000s through 2026; KO/TKO and submission shares remain substantial but no longer dominate recent years.

---

## Links

| What | URL |
|------|-----|
| Interactive dashboard (lead) | https://nvavrock.github.io/tidytuesday/2026_07_07_ufc_fights/output/_widget/finish_dashboard.html |
| Quarto report | https://nvavrock.github.io/tidytuesday/2026_07_07_ufc_fights/analysis.html |
| TidyTuesday dataset | https://github.com/rfordatascience/tidytuesday/tree/main/data/2026/2026-07-07 |
| `{fightr}` | https://github.com/benyamindsmith/fightr |

---

## Note

Share findings on **social media** with `#TidyTuesday`, not as a pull request to the official dataset repo. Credit Benjamin Smith and UFCStats via [TidyTuesday](https://tidytues.day). Confirm GitHub Pages serves `output/_widget/finish_dashboard.html` before posting.
