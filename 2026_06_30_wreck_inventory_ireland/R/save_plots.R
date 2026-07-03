# Build plots, save PNGs to output/, return summary tables

save_week_plots <- function(wreck_inventory, output_dir = "output") {
  dir.create(output_dir, showWarnings = FALSE)

  p_location <- plot_location_status(wreck_inventory)
  p_time <- plot_wrecks_over_time(wreck_inventory)
  p_map <- plot_wreck_map(wreck_inventory)
  p_class <- plot_top_classifications(wreck_inventory)

  ggsave(
    file.path(output_dir, "01_location_status.png"),
    p_location,
    width = 8,
    height = 5.5,
    dpi = 300
  )
  ggsave(
    file.path(output_dir, "02_wrecks_over_time.png"),
    p_time,
    width = 10,
    height = 5.5,
    dpi = 300
  )
  ggsave(
    file.path(output_dir, "03_wreck_map.png"),
    p_map,
    width = 8,
    height = 7,
    dpi = 300
  )

  wreck_map_widget <- plot_wreck_map_interactive(wreck_inventory)
  widget_dir <- file.path(output_dir, "_widget")
  dir.create(widget_dir, showWarnings = FALSE, recursive = TRUE)
  htmlwidgets::saveWidget(
    wreck_map_widget,
    file = file.path(widget_dir, "wreck_map.html"),
    selfcontained = FALSE
  )
  ggsave(
    file.path(output_dir, "04_top_classifications.png"),
    p_class,
    width = 9,
    height = 6,
    dpi = 300
  )

  location_summary <- summarise_location_status(wreck_inventory)
  decade_summary <- summarise_wrecks_by_decade(wreck_inventory)
  classification_summary <- summarise_classifications(wreck_inventory)

  readr::write_csv(location_summary, file.path(output_dir, "location_summary.csv"))
  readr::write_csv(decade_summary, file.path(output_dir, "decade_summary.csv"))
  readr::write_csv(classification_summary, file.path(output_dir, "classification_summary.csv"))

  invisible(
    list(
      location_summary = location_summary,
      decade_summary = decade_summary,
      classification_summary = classification_summary
    )
  )
}
