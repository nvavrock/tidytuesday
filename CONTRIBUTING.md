# Contributing

This is a personal TidyTuesday analysis repo. These guidelines apply to human and LLM-assisted contributions. They are adapted from [Jellyfin's LLM contribution policy](https://jellyfin.org/docs/general/contributing/llm) to fit a small R/Quarto project.

LLM assistance is fine. Committing unreviewed model output is not.

## Code contributions

### Focused changes

- Keep commits and pull requests scoped to one purpose. If a change targets week X, do not also refactor unrelated week Y or shared helpers unless that is explicitly part of the task.
- Avoid drive-by edits (formatting churn, unrelated renames, incidental "while I'm here" changes). These are a common sign of overly broad prompts.
- Prefer several small, reviewable commits over one large diff. Squashing may happen after review.

### Quality and hygiene

- Match existing project style: tidyverse pipelines, week folders, `run.R` / `analysis.qmd` / `NOTES.md` patterns, minimal comments.
- Papal encyclicals week: `analysis.qmd` embeds PNGs from `output/` via `save_plots.R`; UK baby names week uses plotly in HTML. Run `run_week()` before `render_week()` when charts change.
- Do not leave LLM artifacts in the tree: debug logging, `#region agent log` blocks, temporary path hacks, or narrating comments that restate the code.
- Do not commit editor or LLM session files (for example `.cursor/debug*.log`, `.claude/`, local `.git_commit_msg.txt`). Project Cursor rules under `.cursor/rules/` are intentional and may be committed.

### Understand and explain your changes

- Review every line before committing. You should be able to explain what changed and why in your own words in the commit message or PR description.
- Do not paste LLM-generated PR/commit text without editing it into accurate, human context.

### Test before submitting

- From the project root in RStudio, verify affected weeks still work:

```r
source("run_week.R")
run_week("<week_folder>")

source("render_week.R")
render_week("<week_folder>")
```

- Or open that week's `analysis.qmd` and Render in RStudio.
- If you change plotting, data loading, or summaries, spot-check the outputs (`output/` and/or rendered HTML).

### Review and follow-up

- Be ready to implement review feedback yourself. If you cannot discuss or adjust the code without re-prompting an LLM blindly, the change is not ready.
- Larger features or refactors (new week layout, shared abstractions, render pipeline changes) need clear intent and understanding of the existing structure—not a vague "clean this up" pass.

### Maintainer discretion

- Changes that are too large, unfocused, or hard to review may be rejected or sent back to be split up, whether or not an LLM was involved.

### Golden rule

Do not point an LLM at the repo with a vague prompt and commit the result as-is. Use LLMs as an assistant; you remain responsible for the diff.

## Sharing analysis publicly

When posting charts or write-ups (LinkedIn, blog, etc.):

- Credit [TidyTuesday](https://tidytues.day) and the original data sources for each week.
- Respect dataset and project licenses; do not copy third-party code or data without attribution.
- If a published artifact was primarily LLM-generated (code, prose, or both), say so. Secondary LLM help (formatting, draft text) is worth mentioning when it is material.
- **LinkedIn voice:** use “This week I joined #TidyTuesday” only for your first post; later weeks use “This week on #TidyTuesday” (see week `LINKEDIN.md` files).

### LinkedIn post styles (`LINKEDIN.md`)

Each week folder may include a `LINKEDIN.md`. **Vary the Post text section** week to week — do not copy the same skeleton from a prior week.

At the top of each `LINKEDIN.md`, record:

- `**Post style:**` which archetype you used (see below)
- `**Do not reuse from:**` prior week folder(s) — phrases and structure to avoid

**Keep consistent every week:** Strategy, carousel table, alt text, checklist, credits, code/data links, hashtags.

**Rotate the body.** Pick one archetype per week:

| Style | Shape | Example opener |
|-------|--------|----------------|
| **Numbered takeaways** | 3 numbered bullets with bold labels | “Three things stood out…” (week 1 only — do not repeat) |
| **Question hook** | Question, short answer, then carousel | “Do UK regions agree on baby names?” |
| **Stat lead** | One surprising number, then context | “Leo XIII wrote **86** encyclicals. Francis: **4**…” |
| **Then vs now** | Two-era contrast, prose not a list | “**1891:** factories… **2026:** AI…” |
| **Narrative** | What you tried and what surprised you | “I started with a simple question…” |
| **Hero + teaser** | One deep finding; slides 2–3 teased | “The Bridgerton bump is real…” |
| **Tight bullets** | `•` lines, no “three things stood out” | “Week N — topic / • finding / • finding” |

**Phrases to reuse sparingly** (at most once every 3–4 posts): “Three things stood out”, “swipe the carousel”, “All criticism welcome”.

**Report CTA — vary wording:** “Interactive report”, “Full write-up”, “Eight charts here”, “Code + charts”.

**Week 3+ rotation hint:** narrative → stat lead → tight bullets → question — avoid the same list shape twice in a row.

See [`2026_06_16_uk_baby_names/LINKEDIN.md`](2026_06_16_uk_baby_names/LINKEDIN.md) (numbered takeaways) and [`2026_06_23_papal_encyclicals/LINKEDIN.md`](2026_06_23_papal_encyclicals/LINKEDIN.md) (then vs now) for examples.

This repo is not a marketplace for third-party tools; the notes above apply to how work derived from or related to this project is shared, not to policing what others build elsewhere.
