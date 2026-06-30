# Build plots, save PNGs to output/, return objects needed for summary tables

save_week_plots <- function(
    papal_encyclicals,
    scripture_references,
    tokens,
    encyclicals,
    output_dir = "output") {
  dir.create(output_dir, showWarnings = FALSE)

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

  ggsave(
    file.path(output_dir, "01_encyclical_output_over_time.png"),
    p_output_time,
    width = 10,
    height = 6,
    dpi = 300
  )
  ggsave(
    file.path(output_dir, "02_encyclicals_per_pope.png"),
    p_output_pope,
    width = 9,
    height = 6.5,
    dpi = 300
  )
  ggsave(
    file.path(output_dir, "03_scripture_testament.png"),
    p_scripture_testament,
    width = 8,
    height = 5.5,
    dpi = 300
  )
  ggsave(
    file.path(output_dir, "04_scripture_books.png"),
    p_scripture_books,
    width = 9,
    height = 6,
    dpi = 300
  )
  ggsave(
    file.path(output_dir, "05_vocabulary_contrast.png"),
    p_vocabulary,
    width = 10,
    height = 6,
    dpi = 300
  )
  ggsave(
    file.path(output_dir, "05b_theme_words.png"),
    p_theme_words,
    width = 9,
    height = 4.5,
    dpi = 300
  )
  ggsave(
    file.path(output_dir, "06_text_similarity.png"),
    p_similarity,
    width = 9,
    height = 6.5,
    dpi = 300
  )
  ggsave(
    file.path(output_dir, "07_classifier_coefficients.png"),
    p_classifier,
    width = 10,
    height = 8,
    dpi = 300
  )

  output_summary <- summarise_encyclical_output(papal_encyclicals)
  similarity_summary <- summarise_text_similarity(similarity)
  classifier_summary <- summarise_classifier(classifier)
  theme_summary <- summarise_theme_words(tokens)

  readr::write_csv(output_summary, file.path(output_dir, "encyclical_output_summary.csv"))
  readr::write_csv(similarity_summary, file.path(output_dir, "similarity_summary.csv"))
  readr::write_csv(classifier_summary, file.path(output_dir, "classifier_summary.csv"))
  readr::write_csv(theme_summary, file.path(output_dir, "theme_words_summary.csv"))

  invisible(
    list(
      similarity = similarity,
      classifier = classifier,
      output_summary = output_summary,
      similarity_summary = similarity_summary,
      classifier_summary = classifier_summary,
      theme_summary = theme_summary
    )
  )
}
