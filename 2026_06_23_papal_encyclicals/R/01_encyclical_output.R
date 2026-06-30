# Angle 1: Encyclical output over time (1878–2026 catalog)

plot_encyclical_output_over_time <- function(papal_encyclicals) {
  flagship_years <- c(1891L, 2026L)

  by_year <- papal_encyclicals |>
    dplyr::count(year, name = "n") |>
    dplyr::mutate(
      year_type = dplyr::if_else(
        year %in% flagship_years,
        "Flagship text",
        "Other years"
      )
    )

  y_max <- max(by_year$n)

  flagship <- by_year |>
    dplyr::filter(year %in% flagship_years) |>
    dplyr::mutate(
      name = dplyr::case_when(
        year == 1891L ~ "Rerum Novarum",
        year == 2026L ~ "Magnifica Humanitas"
      ),
      name_color = dplyr::case_when(
        year == 1891L ~ ENCYCLICAL_COLORS[["Rerum Novarum"]],
        year == 2026L ~ ENCYCLICAL_COLORS[["Magnifica Humanitas"]]
      ),
      label_x = dplyr::case_when(
        year == 1891L ~ year + 1.5,
        year == 2026L ~ year - 1.5
      ),
      label_hjust = dplyr::case_when(
        year == 1891L ~ 0,
        year == 2026L ~ 1
      ),
      label_y = n + y_max * 0.06
    )

  by_year |>
    ggplot2::ggplot(ggplot2::aes(x = year, y = n, fill = year_type)) +
    ggplot2::geom_col(width = 1, alpha = 0.92) +
    ggplot2::geom_vline(
      xintercept = flagship_years,
      linetype = "dashed",
      color = "gray30",
      linewidth = 0.5
    ) +
    ggplot2::geom_text(
      data = flagship,
      ggplot2::aes(x = year, y = n, label = n),
      inherit.aes = FALSE,
      vjust = -0.25,
      size = 3.2,
      fontface = "bold",
      color = "black",
      show.legend = FALSE
    ) +
    ggplot2::geom_text(
      data = flagship,
      ggplot2::aes(x = label_x, y = label_y, label = name, color = name_color, hjust = label_hjust),
      inherit.aes = FALSE,
      vjust = 0,
      size = 2.8,
      fontface = "italic",
      lineheight = 0.9,
      show.legend = FALSE
    ) +
    ggplot2::scale_color_identity() +
    ggplot2::scale_fill_manual(values = FLAGSHIP_YEAR_COLORS, name = NULL) +
    ggplot2::scale_x_continuous(
      breaks = seq(1880, 2020, by = 20),
      limits = c(1876, 2028),
      expand = ggplot2::expansion(mult = c(0.01, 0.01))
    ) +
    ggplot2::scale_y_continuous(
      limits = c(0, y_max * 1.2),
      expand = ggplot2::expansion(mult = c(0, 0))
    ) +
    ggplot2::coord_cartesian(clip = "off") +
    ggplot2::labs(
      title = "Encyclical output peaked in the late 19th century",
      subtitle = "213 encyclicals in catalog, 1878–2026; orange bars mark this week's two flagship texts",
      x = NULL,
      y = "Encyclicals published",
      caption = DATA_SOURCE_CAPTION
    ) +
    tt_theme() +
    ggplot2::theme(
      legend.position = "bottom",
      plot.margin = ggplot2::margin(12, 16, 12, 12)
    )
}

plot_encyclicals_per_pope <- function(papal_encyclicals, top_n = 12) {
  by_pope <- papal_encyclicals |>
    dplyr::count(pope, name = "n") |>
    dplyr::slice_max(n, n = top_n) |>
    dplyr::mutate(
      highlight = dplyr::case_when(
        pope == "Leo XIII" ~ "Leo XIII",
        pope == "Francis" ~ "Francis",
        TRUE ~ "Other"
      ),
      pope = forcats::fct_reorder(pope, n)
    )

  by_pope |>
    ggplot2::ggplot(ggplot2::aes(x = n, y = pope, fill = highlight)) +
    ggplot2::geom_col(alpha = 0.92, width = 0.75) +
    ggplot2::geom_text(
      ggplot2::aes(x = n, label = n),
      hjust = -0.25,
      size = 3.2,
      fontface = "bold",
      color = "black",
      show.legend = FALSE
    ) +
    ggplot2::scale_fill_manual(values = POPE_HIGHLIGHT_COLORS, name = NULL) +
    ggplot2::scale_x_continuous(
      breaks = scales::breaks_pretty(),
      expand = ggplot2::expansion(mult = c(0, 0.08))
    ) +
    ggplot2::labs(
      title = "Leo XIII wrote 86 encyclicals; Francis wrote 4",
      subtitle = paste(
        "Top", top_n, "popes in catalog — modern popes also use apostolic exhortations and social media"
      ),
      x = "Encyclicals in catalog",
      y = NULL,
      caption = DATA_SOURCE_CAPTION
    ) +
    tt_theme() +
    ggplot2::coord_cartesian(clip = "off") +
    ggplot2::theme(
      legend.position = "bottom",
      plot.margin = ggplot2::margin(12, 24, 12, 12)
    )
}

summarise_encyclical_output <- function(papal_encyclicals) {
  papal_encyclicals |>
    dplyr::count(pope, name = "encyclicals") |>
    dplyr::arrange(dplyr::desc(encyclicals))
}
