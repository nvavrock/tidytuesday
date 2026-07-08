# Angle 3: Does reach advantage predict wins?

plot_reach_advantage <- function(ultimate) {
  reach_summary <- summarise_reach_advantage(ultimate) |>
    dplyr::filter(longer_wins)

  reach_summary |>
    ggplot2::ggplot(
      ggplot2::aes(
        x = longer_corner,
        y = share,
        fill = longer_corner
      )
    ) +
    ggplot2::geom_col(width = 0.55, alpha = 0.92) +
    ggplot2::geom_text(
      ggplot2::aes(label = scales::percent(share, accuracy = 0.1)),
      vjust = -0.25,
      size = 3.4,
      fontface = "bold",
      show.legend = FALSE
    ) +
    ggplot2::scale_fill_manual(
      values = c(Red = "#C8102E", Blue = "#1D4E89"),
      guide = "none"
    ) +
    ggplot2::scale_y_continuous(
      labels = scales::percent_format(accuracy = 1),
      limits = c(0, 0.72),
      expand = ggplot2::expansion(mult = c(0, 0.05))
    ) +
    ggplot2::labs(
      title = "The longer-reach fighter wins more often,\nbut the edge is modest",
      subtitle = paste0(
        "Share of fights won by the fighter with longer reach ",
        "(reach_dif = Blue − Red; excludes equal reach)"
      ),
      x = "Fighter with reach advantage",
      y = "Win rate",
      caption = DATA_SOURCE_CAPTION
    ) +
    tt_theme()
}
