# Run a TidyTuesday week from the project root
# Usage: source("run_week.R"); run_week("2026_06_16_uk_baby_names")

run_week <- function(week_dir = "2026_06_16_uk_baby_names") {
  if (!dir.exists(week_dir)) {
    stop("Week folder not found: ", week_dir)
  }

  original_wd <- getwd()
  on.exit(setwd(original_wd), add = TRUE)

  setwd(week_dir)
  source("run.R")

  cat(
    "\nNext — interactive HTML (from project root, not this folder):\n",
    "  source(\"render_week.R\")\n",
    "  render_week(\"", week_dir, "\")\n",
    sep = ""
  )
}
