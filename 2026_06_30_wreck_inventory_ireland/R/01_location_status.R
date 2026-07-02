# Angle 1: Located vs unlocated wrecks

plot_location_status <- function(wreck_inventory) {
  by_status <- wreck_inventory |>
    dplyr::count(location_status, name = "n") |>
    dplyr::mutate(
      location_status = forcats::fct_reorder(location_status, n)
    )

  by_status |>
    ggplot2::ggplot(ggplot2::aes(x = location_status, y = n, fill = location_status)) +
    ggplot2::geom_col(width = 0.65, alpha = 0.92) +
    ggplot2::geom_text(
      ggplot2::aes(label = scales::comma(n)),
      vjust = -0.25,
      size = 3.2,
      fontface = "bold",
      color = "black",
      show.legend = FALSE
    ) +
    ggplot2::scale_fill_manual(values = LOCATION_COLORS, name = NULL) +
    ggplot2::scale_y_continuous(
      labels = scales::comma,
      expand = ggplot2::expansion(mult = c(0, 0.08))
    ) +
    ggplot2::coord_cartesian(clip = "off") +
    ggplot2::labs(
      title = "Most Irish shipwreck records have no mapped location",
      subtitle = paste0(
        scales::comma(sum(by_status$n)),
        " records in WIID; hardcoded (0,0) coordinates recoded as missing"
      ),
      x = NULL,
      y = "Records",
      caption = DATA_SOURCE_CAPTION
    ) +
    tt_theme() +
    ggplot2::theme(legend.position = "none")
}
