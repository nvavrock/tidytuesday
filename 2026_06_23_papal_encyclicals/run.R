# Run Papal Encyclicals analysis (TidyTuesday 2026-06-23)
# Usage: source("run.R") from this folder, or source("run_week.R") from project root

source("../install_packages.R")

library(tidyverse)
library(tidytext)

source("R/load_data.R")
source("R/01_encyclical_output.R")
source("R/02_scripture_emphasis.R")
source("R/03_vocabulary_evolution.R")
source("R/04_text_similarity.R")
source("R/05_pope_classifier.R")
source("R/save_plots.R")

dir.create("output", showWarnings = FALSE)

if (!file.exists("data/encyclicals.csv")) {
  message("Downloading data...")
  download_data()
}

data <- load_encyclical_data()
encyclicals <- data$encyclicals
papal_encyclicals <- data$papal_encyclicals
scripture_references <- data$scripture_references

tokens <- tokenize_paragraphs(encyclicals)

results <- save_week_plots(
  papal_encyclicals,
  scripture_references,
  tokens,
  encyclicals
)

cat("\n=== Encyclicals per pope (top 5) ===\n")
print(head(results$output_summary, 5))

cat("\n=== Top paragraph similarities ===\n")
print(results$similarity_summary)

cat("\n=== Classifier ===\n")
print(results$classifier_summary)

cat("\n=== Theme word counts ===\n")
print(results$theme_summary)

cat("\nPlots saved to output/\n")
