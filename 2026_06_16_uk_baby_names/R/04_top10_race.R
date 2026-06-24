# Angle 4: England & Wales top-10 bar chart race (1996–2024)

prepare_ew_top10_race <- function(
    names,
    year_min = 1996,
    year_max = 2024,
    top_n = 10
) {
  names |>
    dplyr::filter(
      region == "England & Wales",
      Year >= year_min,
      Year <= year_max,
      !is.na(Rank),
      !is.na(Number)
    ) |>
    dplyr::group_by(Year, Sex) |>
    dplyr::slice_min(Rank, n = top_n, with_ties = FALSE) |>
    dplyr::mutate(slot = top_n + 1L - Rank) |>
    dplyr::ungroup()
}

race_name_palette <- function(race_data) {
  all_names <- sort(unique(race_data$Name))
  n <- length(all_names)
  base <- c(
    "#0072B2", "#D55E00", "#009E73", "#CC79A7", "#E69F00",
    "#56B4E9", "#F0E442", "#999999", "#882255", "#661100",
    "#332288", "#44AA99", "#117733", "#AA4499", "#DDCC77"
  )
  cols <- grDevices::colorRampPalette(base)(n)
  stats::setNames(cols, all_names)
}

plot_ew_top10_race <- function(
    names,
    year_min = 1996,
    year_max = 2024,
    top_n = 10
) {
  race_data <- prepare_ew_top10_race(names, year_min, year_max, top_n)
  palette <- race_name_palette(race_data)

  race_data |>
    dplyr::group_by(Year, Sex) |>
    dplyr::mutate(name_x = -0.04 * max(Number)) |>
    dplyr::ungroup() |>
    ggplot2::ggplot(
      ggplot2::aes(
        x = Number,
        y = slot,
        fill = Name
      )
    ) +
    ggplot2::geom_col(width = 0.85) +
    ggplot2::geom_text(
      ggplot2::aes(
        label = Name,
        x = name_x
      ),
      hjust = 1,
      size = 3.2,
      color = "grey10"
    ) +
    ggplot2::geom_text(
      ggplot2::aes(
        label = scales::comma(Number),
        x = Number
      ),
      hjust = -0.08,
      size = 3,
      color = "grey20"
    ) +
    ggplot2::facet_wrap(~ Sex, ncol = 2) +
    ggplot2::scale_fill_manual(values = palette, guide = "none") +
    ggplot2::scale_x_continuous(
      labels = scales::comma,
      expand = ggplot2::expansion(mult = c(0.05, 0.18))
    ) +
    ggplot2::scale_y_continuous(
      breaks = seq_len(top_n),
      labels = top_n:1,
      expand = ggplot2::expansion(mult = c(0.02, 0.02))
    ) +
    ggplot2::labs(
      title = paste0(
        "Top ", top_n, " baby names in England & Wales, {frame_time}"
      ),
      subtitle = paste0(year_min, "–", year_max, " · rank 1 at top"),
      x = "Babies given the name",
      y = "Rank",
      caption = "Source: ONS via TidyTuesday"
    ) +
    tt_theme() +
    ggplot2::theme(
      panel.grid.major.y = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank()
    ) +
    gganimate::transition_time(Year) +
    gganimate::ease_aes("linear")
}

save_ew_top10_race <- function(
    anim,
    path = "output/07_top10_race.gif",
    width = 11,
    height = 7,
    dpi = 120,
    fps = 8,
    duration = 14
) {
  gganimate::anim_save(
    filename = path,
    animation = anim,
    width = width * dpi,
    height = height * dpi,
    dpi = dpi,
    fps = fps,
    duration = duration,
    renderer = gganimate::gifski_renderer()
  )
  invisible(path)
}
