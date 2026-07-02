# Angle 2: Shipwrecks over time by decade

plot_wrecks_over_time <- function(wreck_inventory) {
  by_decade <- wreck_inventory |>
    dplyr::filter(!is.na(decade), decade >= 1500, decade <= 2020) |>
    dplyr::count(decade, name = "n")

  by_decade |>
    ggplot2::ggplot(ggplot2::aes(x = decade, y = n)) +
    ggplot2::geom_col(fill = "#0072B2", alpha = 0.88, width = 8) +
    ggplot2::geom_vline(
      xintercept = c(1910, 1940),
      linetype = "dashed",
      color = "gray40",
      linewidth = 0.4
    ) +
    ggplot2::annotate(
      "text",
      x = 1910,
      y = max(by_decade$n) * 0.92,
      label = "WWI era",
      hjust = -0.05,
      size = 3.2,
      color = "gray30"
    ) +
    ggplot2::annotate(
      "text",
      x = 1940,
      y = max(by_decade$n) * 0.78,
      label = "WWII era",
      hjust = -0.05,
      size = 3.2,
      color = "gray30"
    ) +
    ggplot2::scale_x_continuous(breaks = seq(1500, 2000, by = 100)) +
    ggplot2::scale_y_continuous(labels = scales::comma) +
    ggplot2::labs(
      title = "Recorded shipwrecks peaked in the 19th and early 20th centuries",
      subtitle = "Counts by decade where a calendar year could be assigned; dashed lines mark World War eras",
      x = "Decade",
      y = "Records",
      caption = DATA_SOURCE_CAPTION
    ) +
    tt_theme()
}
