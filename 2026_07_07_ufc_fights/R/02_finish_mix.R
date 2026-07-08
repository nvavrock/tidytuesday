# Angle 2: How fight outcomes have shifted over time

plot_finish_mix <- function(fights) {
  by_year <- summarise_finish_by_year(fights) |>
    dplyr::filter(year >= 2000)

  by_year |>
    ggplot2::ggplot(
      ggplot2::aes(x = year, y = share, fill = finish_type)
    ) +
    ggplot2::geom_col(width = 0.9, alpha = 0.92) +
    ggplot2::scale_fill_manual(values = FINISH_COLORS, name = "Outcome") +
    ggplot2::scale_y_continuous(
      labels = scales::percent_format(accuracy = 1),
      expand = ggplot2::expansion(mult = c(0, 0.02))
    ) +
    ggplot2::scale_x_continuous(breaks = seq(2000, 2026, by = 4)) +
    ggplot2::labs(
      title = "Decisions take a larger share of outcomes\nin modern UFC cards",
      subtitle = "Stacked share of finish type by year (2000–2026)",
      x = NULL,
      y = "Share of fights",
      caption = DATA_SOURCE_CAPTION
    ) +
    tt_theme() +
    ggplot2::theme(legend.position = "bottom")
}
