# Run UK Baby Names analysis (TidyTuesday 2026-06-16)
# Usage: source("run.R") from this folder, or source("run_week.R") from project root

source("../install_packages.R")

library(tidyverse)

source("R/load_data.R")
source("R/01_regional_comparison.R")
source("R/02_name_uniqueness.R")
source("R/03_bridgerton_trend.R")

dir.create("output", showWarnings = FALSE)

if (!file.exists("data/england_wales_names.csv")) {
  message("Downloading data...")
  download_data()
}

baby_names <- load_baby_names()
uniqueness <- compute_uniqueness(baby_names)

comparison_year <- min(2024, max(baby_names$Year, na.rm = TRUE))

p_top <- plot_regional_top_names(baby_names, year = comparison_year)
p_overlap <- plot_regional_overlap(baby_names, year = comparison_year)
p_unique_time <- plot_uniqueness_over_time(uniqueness)
p_unique_sex <- plot_uniqueness_by_sex(uniqueness)
p_bridgerton <- plot_bridgerton_trend(baby_names)
p_bridgerton_yoy <- plot_bridgerton_2024_2025(baby_names)

ggsave("output/01_regional_top_names.png", p_top, width = 11, height = 6, dpi = 150)
ggsave("output/02_regional_overlap.png", p_overlap, width = 9, height = 6, dpi = 150)
ggsave("output/03_uniqueness_over_time.png", p_unique_time, width = 10, height = 6, dpi = 150)
ggsave("output/04_uniqueness_by_sex.png", p_unique_sex, width = 8, height = 6, dpi = 150)
ggsave("output/05_bridgerton_trend.png", p_bridgerton, width = 9, height = 8, dpi = 150)
ggsave("output/06_bridgerton_2024_2025.png", p_bridgerton_yoy, width = 10, height = 7, dpi = 150)

regional_summary <- summarise_regional_comparison(baby_names, year = comparison_year)
uniqueness_summary <- summarise_uniqueness(uniqueness)
bridgerton_summary <- summarise_bridgerton(baby_names)

readr::write_csv(regional_summary, "output/regional_summary.csv")
readr::write_csv(uniqueness_summary, "output/uniqueness_summary.csv")
readr::write_csv(bridgerton_summary, "output/bridgerton_summary.csv")

cat("\n=== Regional top names (", comparison_year, ") ===\n", sep = "")
print(regional_summary)

cat("\n=== Uniqueness by sex (latest year) ===\n")
print(uniqueness_summary)

cat("\n=== Bridgerton ranks (2024-2025) ===\n")
print(bridgerton_summary)

cat("\nPlots saved to output/\n")
