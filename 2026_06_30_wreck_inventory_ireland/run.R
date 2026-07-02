# Run Wreck Inventory of Ireland analysis (TidyTuesday 2026-06-30)
# Usage: source("run.R") from this folder, or source("run_week.R") from project root

source("../install_packages.R")

library(tidyverse)

source("R/load_data.R")
source("R/01_location_status.R")
source("R/02_wrecks_over_time.R")
source("R/03_wreck_map.R")
source("R/04_classification.R")
source("R/save_plots.R")

dir.create("output", showWarnings = FALSE)

if (!file.exists("data/wreck_inventory.csv") ||
    !file.exists("data/ne_10m_lakes.geojson") ||
    !file.exists("data/osi_landmask.geojson") ||
    !file.exists("data/osni_outline.geojson")) {
  message("Downloading data...")
  download_data()
}

wreck_inventory <- load_wreck_data()
results <- save_week_plots(wreck_inventory)

cat("\n=== Location status ===\n")
print(results$location_summary)

cat("\n=== Peak decades ===\n")
print(results$decade_summary |> dplyr::slice_max(n, n = 5))

cat("\n=== Top classifications ===\n")
print(results$classification_summary)

cat("\nPlots saved to output/\n")
