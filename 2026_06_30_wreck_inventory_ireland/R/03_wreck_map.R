# Angle 3: Map of located wrecks around Ireland

plot_wreck_map <- function(wreck_inventory) {
  located <- wreck_inventory |>
    dplyr::filter(located)

  located |>
    ggplot2::ggplot(ggplot2::aes(x = longitude, y = latitude)) +
    ggplot2::geom_point(
      color = "#0072B2",
      alpha = 0.35,
      size = 0.9
    ) +
    ggplot2::coord_fixed(
      xlim = c(-11.2, -5.0),
      ylim = c(51.2, 55.8),
      expand = FALSE
    ) +
    ggplot2::labs(
      title = "Known wreck sites cluster along Ireland's coasts",
      subtitle = paste0(
        scales::comma(nrow(located)),
        " records with coordinates (~",
        round(100 * nrow(located) / nrow(wreck_inventory), 1),
        "% of catalog)"
      ),
      x = "Longitude",
      y = "Latitude",
      caption = DATA_SOURCE_CAPTION
    ) +
    tt_theme() +
    ggplot2::theme(
      panel.grid.major = ggplot2::element_line(color = "gray90")
    )
}
