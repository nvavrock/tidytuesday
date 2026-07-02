# Angle 4: Top vessel classifications

plot_top_classifications <- function(wreck_inventory, top_n = 10) {
  top <- wreck_inventory |>
    dplyr::count(classification, sort = TRUE) |>
    dplyr::slice_head(n = top_n) |>
    dplyr::mutate(
      classification = forcats::fct_reorder(classification, n),
      fill_group = dplyr::if_else(
        classification %in% names(CLASSIFICATION_COLORS),
        as.character(classification),
        "Other"
      )
    )

  top |>
    ggplot2::ggplot(ggplot2::aes(x = n, y = classification, fill = fill_group)) +
    ggplot2::geom_col(alpha = 0.92) +
    ggplot2::geom_text(
      ggplot2::aes(label = scales::comma(n)),
      hjust = -0.15,
      size = 3.2,
      fontface = "bold",
      color = "black",
      show.legend = FALSE
    ) +
    ggplot2::scale_fill_manual(values = CLASSIFICATION_COLORS, name = NULL) +
    ggplot2::scale_x_continuous(
      labels = scales::comma,
      expand = ggplot2::expansion(mult = c(0, 0.12))
    ) +
    ggplot2::coord_cartesian(clip = "off") +
    ggplot2::labs(
      title = "\"Unknown\" is the largest vessel classification",
      subtitle = paste0(
        "Top ", top_n, " classes; ",
        scales::comma(sum(wreck_inventory$classification == "Unknown", na.rm = TRUE)),
        " records lack a type label"
      ),
      x = "Records",
      y = NULL,
      caption = DATA_SOURCE_CAPTION
    ) +
    tt_theme() +
    ggplot2::theme(legend.position = "none")
}
