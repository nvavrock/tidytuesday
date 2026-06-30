# Angle 3: Vocabulary contrast between 1891 and 2026 encyclicals

compute_log_odds <- function(tokens) {
  wide <- tokens |>
    dplyr::count(encyclical, word, name = "n") |>
    tidyr::pivot_wider(names_from = encyclical, values_from = n, values_fill = 0)

  rn_total <- sum(wide$`Rerum Novarum`)
  mh_total <- sum(wide$`Magnifica Humanitas`)

  wide |>
    dplyr::filter(`Rerum Novarum` + `Magnifica Humanitas` >= 5) |>
    dplyr::mutate(
      log_odds = log((`Rerum Novarum` + 0.5) / rn_total) -
        log((`Magnifica Humanitas` + 0.5) / mh_total)
    ) |>
    dplyr::arrange(dplyr::desc(abs(log_odds)))
}

plot_vocabulary_contrast <- function(tokens, top_n = 10) {
  contrast <- compute_log_odds(tokens) |>
    dplyr::mutate(
      lean = dplyr::if_else(
        log_odds > 0,
        "Rerum Novarum (1891)",
        "Magnifica Humanitas (2026)"
      )
    ) |>
    dplyr::group_by(lean) |>
    dplyr::slice_max(abs(log_odds), n = top_n, with_ties = FALSE) |>
    dplyr::ungroup() |>
    dplyr::group_by(lean) |>
    dplyr::mutate(word = forcats::fct_reorder(word, log_odds)) |>
    dplyr::ungroup()

  contrast |>
    ggplot2::ggplot(ggplot2::aes(x = log_odds, y = word, fill = lean)) +
    ggplot2::geom_col(alpha = 0.92, width = 0.75, show.legend = FALSE) +
    ggplot2::geom_vline(xintercept = 0, color = "gray50", linewidth = 0.4) +
    ggplot2::facet_wrap(~ lean, scales = "free_y") +
    ggplot2::scale_fill_manual(
      values = c(
        "Rerum Novarum (1891)" = ENCYCLICAL_COLORS[["Rerum Novarum"]],
        "Magnifica Humanitas (2026)" = ENCYCLICAL_COLORS[["Magnifica Humanitas"]]
      )
    ) +
    ggplot2::labs(
      title = "Industrial-era labor language vs AI-era technology language",
      subtitle = paste(
        "Log-odds ratio; top", top_n, "distinctive terms per encyclical (min 5 total occurrences)"
      ),
      x = "Log-odds (positive = more common in Rerum Novarum)",
      y = NULL,
      caption = DATA_SOURCE_CAPTION
    ) +
    tt_theme()
}

summarise_theme_words <- function(tokens) {
  themes <- tibble::tribble(
    ~theme, ~word,
    "Labor / industry", "labor",
    "Labor / industry", "work",
    "Labor / industry", "worker",
    "Labor / industry", "workers",
    "Labor / industry", "industrial",
    "Dignity / rights", "dignity",
    "Dignity / rights", "rights",
    "Dignity / rights", "human",
    "Technology / AI", "technology",
    "Technology / AI", "digital",
    "Technology / AI", "artificial",
    "Technology / AI", "intelligence",
    "Technology / AI", "machine"
  )

  tokens |>
    dplyr::inner_join(themes, by = "word") |>
    dplyr::count(encyclical, theme, name = "n") |>
    tidyr::pivot_wider(names_from = encyclical, values_from = n, values_fill = 0)
}

plot_theme_words <- function(tokens) {
  theme_data <- summarise_theme_words(tokens) |>
    tidyr::pivot_longer(
      cols = c(`Rerum Novarum`, `Magnifica Humanitas`),
      names_to = "encyclical",
      values_to = "n"
    ) |>
    dplyr::mutate(
      encyclical = factor(
        encyclical,
        levels = c("Rerum Novarum", "Magnifica Humanitas")
      ),
      theme = forcats::fct_reorder(theme, n, .fun = sum)
    )

  theme_data |>
    ggplot2::ggplot(ggplot2::aes(x = n, y = theme, fill = encyclical)) +
    ggplot2::geom_col(position = "dodge", width = 0.7, alpha = 0.92) +
    ggplot2::geom_text(
      ggplot2::aes(x = n, label = dplyr::if_else(n > 0, as.character(n), "")),
      position = ggplot2::position_dodge(width = 0.7),
      hjust = -0.25,
      size = 3.2,
      fontface = "bold",
      color = "black",
      show.legend = FALSE
    ) +
    ggplot2::scale_fill_manual(values = ENCYCLICAL_COLORS, name = NULL) +
    ggplot2::scale_x_continuous(expand = ggplot2::expansion(mult = c(0, 0.08))) +
    ggplot2::labs(
      title = "Theme words shift from labor to technology",
      subtitle = "Hand-curated dictionary: labor, dignity, and AI-related terms",
      x = "Token count",
      y = NULL,
      caption = DATA_SOURCE_CAPTION
    ) +
    tt_theme() +
    ggplot2::coord_cartesian(clip = "off") +
    ggplot2::theme(
      legend.position = "bottom",
      plot.margin = ggplot2::margin(12, 24, 12, 12)
    )
}
