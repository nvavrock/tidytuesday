# Build plots, save PNGs to output/, return summary tables

save_week_plots <- function(fights, ultimate, output_dir = "output") {
  dir.create(output_dir, showWarnings = FALSE)

  p_time <- plot_fights_over_time(fights)
  p_finish <- plot_finish_mix(fights)
  p_reach <- plot_reach_advantage(ultimate)
  p_class <- plot_weight_classes(fights)

  ggsave(
    file.path(output_dir, "01_fights_over_time.png"),
    p_time,
    width = 10,
    height = 5.5,
    dpi = 300
  )
  ggsave(
    file.path(output_dir, "02_finish_mix.png"),
    p_finish,
    width = 10,
    height = 5.5,
    dpi = 300
  )
  ggsave(
    file.path(output_dir, "03_reach_advantage.png"),
    p_reach,
    width = 8,
    height = 5.5,
    dpi = 300
  )
  ggsave(
    file.path(output_dir, "04_weight_classes.png"),
    p_class,
    width = 9,
    height = 6,
    dpi = 300
  )

  year_summary <- summarise_fights_by_year(fights)
  finish_summary <- summarise_finish_by_year(fights)
  reach_summary <- summarise_reach_advantage(ultimate)
  class_summary <- summarise_weight_classes(fights)

  readr::write_csv(year_summary, file.path(output_dir, "year_summary.csv"))
  readr::write_csv(finish_summary, file.path(output_dir, "finish_summary.csv"))
  readr::write_csv(reach_summary, file.path(output_dir, "reach_summary.csv"))
  readr::write_csv(class_summary, file.path(output_dir, "class_summary.csv"))

  report_dir <- "report-figures"
  dir.create(report_dir, showWarnings = FALSE, recursive = TRUE)
  report_pngs <- list.files(output_dir, pattern = "^0[1-4].*\\.png$", full.names = TRUE)
  invisible(file.copy(report_pngs, file.path(report_dir, basename(report_pngs)), overwrite = TRUE))

  invisible(
    list(
      year_summary = year_summary,
      finish_summary = finish_summary,
      reach_summary = reach_summary,
      class_summary = class_summary
    )
  )
}
