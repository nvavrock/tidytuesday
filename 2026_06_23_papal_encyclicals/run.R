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

p_output_time <- plot_encyclical_output_over_time(papal_encyclicals)
p_output_pope <- plot_encyclicals_per_pope(papal_encyclicals)
p_scripture_testament <- plot_scripture_testament(scripture_references)
p_scripture_books <- plot_scripture_books(scripture_references)
p_vocabulary <- plot_vocabulary_contrast(tokens)
p_theme_words <- plot_theme_words(tokens)
similarity <- compute_paragraph_similarity(encyclicals, tokens)
p_similarity <- plot_text_similarity(similarity)
classifier <- fit_pope_classifier(encyclicals, tokens)
p_classifier <- plot_classifier_coefficients(classifier)

ggsave("output/01_encyclical_output_over_time.png", p_output_time, width = 10, height = 6, dpi = 300)
ggsave("output/02_encyclicals_per_pope.png", p_output_pope, width = 9, height = 6.5, dpi = 300)
ggsave("output/03_scripture_testament.png", p_scripture_testament, width = 8, height = 5.5, dpi = 300)
ggsave("output/04_scripture_books.png", p_scripture_books, width = 9, height = 6, dpi = 300)
ggsave("output/05_vocabulary_contrast.png", p_vocabulary, width = 10, height = 6, dpi = 300)
ggsave("output/05b_theme_words.png", p_theme_words, width = 9, height = 4.5, dpi = 300)
ggsave("output/06_text_similarity.png", p_similarity, width = 9, height = 6.5, dpi = 300)
ggsave("output/07_classifier_coefficients.png", p_classifier, width = 10, height = 8, dpi = 300)

output_summary <- summarise_encyclical_output(papal_encyclicals)
similarity_summary <- summarise_text_similarity(similarity)
classifier_summary <- summarise_classifier(classifier)
theme_summary <- summarise_theme_words(tokens)

readr::write_csv(output_summary, "output/encyclical_output_summary.csv")
readr::write_csv(similarity_summary, "output/similarity_summary.csv")
readr::write_csv(classifier_summary, "output/classifier_summary.csv")
readr::write_csv(theme_summary, "output/theme_words_summary.csv")

cat("\n=== Encyclicals per pope (top 5) ===\n")
print(head(output_summary, 5))

cat("\n=== Top paragraph similarities ===\n")
print(similarity_summary)

cat("\n=== Classifier ===\n")
print(classifier_summary)

cat("\n=== Theme word counts ===\n")
print(theme_summary)

cat("\nPlots saved to output/\n")
