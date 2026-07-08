# Angle 1: UFC fights per year

plot_fights_over_time <- function(fights) {
  by_year <- summarise_fights_by_year(fights)

  by_year |>
    ggplot2::ggplot(ggplot2::aes(x = year, y = n)) +
    ggplot2::geom_col(fill = "#0072B2", alpha = 0.88, width = 0.85) +
    ggplot2::scale_x_continuous(breaks = seq(1994, 2026, by = 4)) +
    ggplot2::scale_y_continuous(
      labels = scales::comma,
      expand = ggplot2::expansion(mult = c(0, 0.06))
    ) +
    ggplot2::labs(
      title = "UFC card volume has climbed since the mid-2000s",
      subtitle = paste0(
        scales::comma(sum(by_year$n)),
        " bouts in UFCStats data (1994–2026)"
      ),
      x = NULL,
      y = "Fights",
      caption = DATA_SOURCE_CAPTION
    ) +
    tt_theme()
}
