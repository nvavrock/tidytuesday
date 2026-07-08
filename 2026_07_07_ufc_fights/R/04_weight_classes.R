# Angle 4: Which divisions see the most fights?

plot_weight_classes <- function(fights) {
  top_classes <- summarise_weight_classes(fights) |>
    dplyr::mutate(
      weight_class = forcats::fct_reorder(weight_class, n)
    )

  top_classes |>
    ggplot2::ggplot(ggplot2::aes(x = n, y = weight_class, fill = weight_class)) +
    ggplot2::geom_col(alpha = 0.92, show.legend = FALSE) +
    ggplot2::geom_text(
      ggplot2::aes(label = scales::comma(n)),
      hjust = -0.08,
      size = 3.2,
      fontface = "bold"
    ) +
    ggplot2::scale_fill_manual(values = WEIGHT_CLASS_PALETTE) +
    ggplot2::scale_x_continuous(
      labels = scales::comma,
      expand = ggplot2::expansion(mult = c(0, 0.12))
    ) +
    ggplot2::coord_cartesian(clip = "off") +
    ggplot2::labs(
      title = "Lightweight and welterweight lead the schedule",
      subtitle = "Top 10 divisions by bout count in UFCStats data",
      x = "Fights",
      y = NULL,
      caption = DATA_SOURCE_CAPTION
    ) +
    tt_theme()
}
