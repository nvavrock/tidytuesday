# Contributing

This is a personal TidyTuesday analysis repo. These guidelines apply to human and LLM-assisted contributions. They are adapted from [Jellyfin's LLM contribution policy](https://jellyfin.org/docs/general/contributing/llm) to fit a small R/Quarto project.

LLM assistance is fine. Committing unreviewed model output is not.

## Code contributions

### Focused changes

- Keep commits and pull requests scoped to one purpose. If a change targets week X, do not also refactor unrelated week Y or shared helpers unless that is explicitly part of the task.
- Avoid drive-by edits (formatting churn, unrelated renames, incidental "while I'm here" changes). These are a common sign of overly broad prompts.
- Prefer several small, reviewable commits over one large diff. Squashing may happen after review.

### Quality and hygiene

- Match existing project style: tidyverse pipelines, week folders, `run.R` / `analysis.qmd` patterns, minimal comments.
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

## Sharing analyses publicly

When posting charts or write-ups (LinkedIn, blog, etc.):

- Credit [TidyTuesday](https://tidytues.day) and the original data sources for each week.
- Respect dataset and project licenses; do not copy third-party code or data without attribution.
- If a published artifact was primarily LLM-generated (code, prose, or both), say so. Secondary LLM help (formatting, draft text) is worth mentioning when it is material.

This repo is not a marketplace for third-party tools; the notes above apply to how work derived from or related to this project is shared, not to policing what others build elsewhere.
