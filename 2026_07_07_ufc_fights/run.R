# Run UFC fight data analysis (TidyTuesday 2026-07-07)
# Usage: source("run.R") from this folder, or source("run_week.R") from project root

source("../install_packages.R")

library(tidyverse)

source("R/load_data.R")
source("R/01_fights_over_time.R")
source("R/02_finish_mix.R")
source("R/03_reach_advantage.R")
source("R/04_weight_classes.R")
source("R/save_plots.R")

dir.create("output", showWarnings = FALSE)

if (!file.exists("data/ufc_fights.csv") ||
    !file.exists("data/ultimate_ufc_dataset.csv")) {
  message("Downloading data...")
  download_data()
}

fights <- load_fight_data()
ultimate <- load_ultimate_data()
results <- save_week_plots(fights, ultimate)

cat("\n=== Fights by year (recent) ===\n")
print(results$year_summary |> dplyr::slice_tail(n = 5))

cat("\n=== Finish mix (2024) ===\n")
print(
  results$finish_summary |>
    dplyr::filter(year == 2024) |>
    dplyr::select(finish_type, n, share)
)

cat("\n=== Reach advantage ===\n")
print(results$reach_summary |> dplyr::filter(longer_wins))

cat("\n=== Top weight classes ===\n")
print(results$class_summary)

cat("\nPlots saved to output/\n")
