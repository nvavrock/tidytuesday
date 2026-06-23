# Angle 2: Name uniqueness — are boys' or girls' names more diverse?
# Uses distinct-name share and top-100 concentration by region and year.

compute_uniqueness <- function(names) {
  names |>
    dplyr::filter(!is.na(Number), Number > 0) |>
    dplyr::group_by(region, Year, Sex) |>
    dplyr::summarise(
      total_births = sum(Number),
      distinct_names = dplyr::n_distinct(Name),
      births_outside_top100 = sum(Number[Rank > 100 | is.na(Rank)]),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      names_per_1000_births = distinct_names / total_births * 1000,
      pct_outside_top100 = births_outside_top100 / total_births * 100
    )
}

plot_uniqueness_over_time <- function(uniqueness) {
  uniqueness |>
    dplyr::mutate(
      hover = paste0(
        region, "<br>",
        Year, " · ", Sex, "<br>",
        round(names_per_1000_births, 1), " distinct names per 1,000 births"
      )
    ) |>
    ggplot2::ggplot(
      ggplot2::aes(
        x = Year,
        y = names_per_1000_births,
        color = Sex,
        group = Sex,
        text = hover
      )
    ) +
    ggplot2::geom_line(linewidth = 0.8) +
    ggplot2::facet_wrap(~ region, scales = "free_y") +
    ggplot2::scale_color_manual(values = SEX_COLORS) +
    ggplot2::labs(
      title = "Baby name diversity over time",
      subtitle = "Higher values = more distinct names per 1,000 births",
      x = NULL,
      y = "Distinct names per 1,000 births",
      color = NULL,
      caption = DATA_SOURCE_CAPTION
    ) +
    tt_theme() +
    ggplot2::theme(legend.position = "bottom")
}

plot_uniqueness_by_sex <- function(uniqueness, recent_years = 10, interactive = FALSE) {
  max_year <- max(uniqueness$Year, na.rm = TRUE)
  recent <- uniqueness |>
    dplyr::filter(Year >= max_year - recent_years + 1) |>
    dplyr::mutate(
      hover = paste0(
        region, ", ", Year, "<br>",
        Sex, "<br>",
        round(pct_outside_top100, 1), "% of births outside top 100"
      )
    )

  p <- recent |>
    ggplot2::ggplot(
      ggplot2::aes(
        x = Sex,
        y = pct_outside_top100,
        text = hover
      )
    )

  if (interactive) {
    p <- p +
      ggplot2::geom_boxplot(
        fill = "grey85",
        color = "grey50",
        outlier.shape = NA,
        alpha = 0.5,
        width = 0.5
      ) +
      ggplot2::geom_jitter(
        ggplot2::aes(color = region),
        width = 0.12,
        size = 2,
        alpha = 0.85
      )
  } else {
    p <- p +
      ggplot2::geom_boxplot(
        ggplot2::aes(fill = Sex),
        outlier.shape = NA,
        alpha = 0.35,
        width = 0.5
      ) +
      ggplot2::geom_jitter(
        ggplot2::aes(color = region),
        width = 0.12,
        size = 2,
        alpha = 0.85
      ) +
      ggplot2::scale_fill_manual(values = SEX_COLORS)
  }

  p +
    ggplot2::scale_color_manual(values = REGION_COLORS) +
    ggplot2::labs(
      title = paste(
        "Share of births with names outside the top 100",
        paste0("(", max_year - recent_years + 1, "-", max_year, ")")
      ),
      subtitle = "Hover points for region and year; box shows the 10-year distribution",
      x = NULL,
      y = "% of births outside top 100",
      color = "Region",
      caption = DATA_SOURCE_CAPTION
    ) +
    tt_theme() +
    ggplot2::theme(legend.position = "bottom", legend.box = "vertical")
}

summarise_uniqueness <- function(uniqueness) {
  max_year <- max(uniqueness$Year, na.rm = TRUE)

  uniqueness |>
    dplyr::filter(Year == max_year) |>
    dplyr::group_by(Sex) |>
    dplyr::summarise(
      avg_distinct_per_1000 = mean(names_per_1000_births),
      avg_pct_outside_top100 = mean(pct_outside_top100),
      .groups = "drop"
    ) |>
    dplyr::arrange(dplyr::desc(avg_distinct_per_1000))
}
