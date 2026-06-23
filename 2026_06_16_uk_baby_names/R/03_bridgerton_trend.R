# Angle 3: The Bridgerton trend
# Tracks Daphne, Eloise, and Penelope rank changes over time.

BRIDGERTON_NAMES <- c("Daphne", "Eloise", "Penelope")

BRIDGERTON_NAME_COLORS <- c(
  Daphne = "#0072B2",
  Eloise = "#D55E00",
  Penelope = "#009E73"
)

BRIDGERTON_YOY_YEARS <- c(2024L, 2025L)

prepare_bridgerton_yoy <- function(names) {
  regions <- levels(names$region)

  grid <- tidyr::expand_grid(
    Name = BRIDGERTON_NAMES,
    region = factor(regions, levels = regions),
    Year = factor(BRIDGERTON_YOY_YEARS, levels = as.character(BRIDGERTON_YOY_YEARS))
  )

  observed <- names |>
    dplyr::filter(
      Name %in% BRIDGERTON_NAMES,
      Sex == "Girl",
      Year %in% BRIDGERTON_YOY_YEARS,
      !is.na(Rank)
    ) |>
    dplyr::mutate(Year = factor(Year, levels = as.character(BRIDGERTON_YOY_YEARS))) |>
    dplyr::select(Name, region, Year, Rank, Number)

  grid |>
    dplyr::left_join(observed, by = c("Name", "region", "Year"))
}

plot_bridgerton_trend <- function(names, interactive = FALSE, recent_years = 15) {
  bridgerton <- names |>
    dplyr::filter(
      Name %in% BRIDGERTON_NAMES,
      Sex == "Girl",
      !is.na(Rank)
    ) |>
    dplyr::group_by(region) |>
    dplyr::mutate(
      recent_max = max(
        Rank[Year >= max(Year, na.rm = TRUE) - recent_years + 1],
        na.rm = TRUE
      ),
      display_cap = recent_max * 1.25
    ) |>
    dplyr::ungroup() |>
    dplyr::mutate(
      Rank_plot = pmin(Rank, display_cap),
      hover = paste0(
        "<b>", Name, "</b><br>",
        region, "<br>",
        "Year: ", Year, "<br>",
        "Rank: ", Rank,
        dplyr::if_else(
          Rank > display_cap,
          paste0(" (shown at ", round(display_cap), " on chart)"),
          ""
        ),
        dplyr::if_else(
          !is.na(Number),
          paste0("<br>Count: ", scales::comma(Number)),
          ""
        )
      )
    )

  labels <- bridgerton |>
    dplyr::group_by(region, Name) |>
    dplyr::slice_max(Year, n = 1, with_ties = FALSE) |>
    dplyr::ungroup()

  p <- bridgerton |>
    ggplot2::ggplot(
      ggplot2::aes(
        x = Year,
        y = Rank_plot,
        color = Name,
        group = Name,
        text = hover
      )
    ) +
    ggplot2::geom_line(linewidth = 0.9) +
    ggplot2::geom_point(size = 1.8) +
    ggplot2::facet_wrap(~ region, ncol = 1, scales = "free_y") +
    ggplot2::scale_y_reverse(
      breaks = scales::pretty_breaks(n = 5),
      expand = ggplot2::expansion(mult = c(0.06, 0.04))
    ) +
    ggplot2::scale_color_manual(values = BRIDGERTON_NAME_COLORS) +
    ggplot2::labs(
      title = "The Bridgerton effect on UK baby names",
      subtitle = paste0(
        "Lower rank = more popular; y-axis scaled per region to the last ",
        recent_years, " years (very rare early ranks truncated at the panel floor)"
      ),
      x = NULL,
      y = "Rank (1 = most popular)",
      color = "Name",
      caption = DATA_SOURCE_CAPTION
    ) +
    tt_theme() +
    ggplot2::theme(
      legend.position = "bottom",
      panel.spacing.y = grid::unit(1.4, "cm"),
      strip.placement = "outside"
    )

  if (!interactive) {
    p <- p +
      ggrepel::geom_text_repel(
        data = labels,
        ggplot2::aes(label = Name, y = Rank_plot),
        size = 3,
        show.legend = FALSE,
        min.segment.length = 0,
        box.padding = 0.3,
        point.padding = 0.2
      )
  }

  p
}

plot_bridgerton_2024_2025 <- function(names, rank_cap = 600) {
  bridgerton <- prepare_bridgerton_yoy(names) |>
    dplyr::mutate(
      Rank_plot = dplyr::if_else(is.na(Rank), NA_real_, pmin(Rank, rank_cap)),
      hover = dplyr::if_else(
        is.na(Rank),
        NA_character_,
        paste0(
          "<b>", Name, "</b><br>",
          region, "<br>",
          "Year: ", Year, "<br>",
          "Rank: ", Rank,
          dplyr::if_else(
            Rank > rank_cap,
            paste0(" (shown at ", rank_cap, " on chart)"),
            ""
          ),
          dplyr::if_else(
            !is.na(Number),
            paste0("<br>Count: ", scales::comma(Number)),
            ""
          )
        )
      )
    )

  if (!any(!is.na(bridgerton$Rank))) {
    return(
      ggplot2::ggplot() +
        ggplot2::annotate(
          "text",
          x = 0.5,
          y = 0.5,
          label = "No 2024-2025 Bridgerton name data available"
        ) +
        ggplot2::theme_void()
    )
  }

  line_data <- bridgerton |>
    dplyr::filter(!is.na(Rank)) |>
    dplyr::group_by(Name, region) |>
    dplyr::filter(dplyr::n() == 2) |>
    dplyr::ungroup()

  missing_notes <- bridgerton |>
    dplyr::filter(is.na(Rank)) |>
    dplyr::mutate(
      note = dplyr::if_else(
        region == "Northern Ireland" & Name == "Daphne" & Year == "2024",
        "Northern Ireland · Daphne · 2024: no rank (below publication threshold)",
        paste0(region, " · ", Name, " · ", Year, ": no data")
      )
    ) |>
    dplyr::arrange(Name, region, Year)

  missing_caption <- if (nrow(missing_notes) > 0) {
    paste0(
      "Missing data: ",
      paste(missing_notes$note, collapse = "; ")
    )
  } else {
    NULL
  }

  plot_caption <- paste(
    c(missing_caption, DATA_SOURCE_CAPTION),
    collapse = "\n\n"
  )

  point_data <- bridgerton |>
    dplyr::filter(!is.na(Rank))

  point_data |>
    ggplot2::ggplot(
      ggplot2::aes(
        x = Year,
        y = Rank_plot,
        color = region,
        group = region,
        text = hover
      )
    ) +
    ggplot2::geom_line(
      data = line_data,
      linewidth = 0.9
    ) +
    ggplot2::geom_point(size = 2) +
    ggplot2::facet_wrap(~ Name, ncol = 1, scales = "free_y") +
    ggplot2::scale_y_reverse(
      breaks = scales::pretty_breaks(n = 6),
      expand = ggplot2::expansion(mult = c(0.08, 0.05))
    ) +
    ggplot2::scale_color_manual(values = REGION_COLORS) +
    ggplot2::scale_x_discrete(expand = ggplot2::expansion(add = 0.25)) +
    ggplot2::labs(
      title = "Bridgerton names: 2024 vs 2025 rank change",
      subtitle = "Downward slope = more popular (lower rank is better)",
      x = NULL,
      y = "Rank (1 = most popular)",
      color = "Region",
      caption = plot_caption
    ) +
    tt_theme() +
    ggplot2::theme(
      legend.position = "bottom",
      panel.spacing.y = grid::unit(1.4, "cm"),
      strip.placement = "outside",
      plot.caption = ggplot2::element_text(
        size = 9,
        color = "grey30",
        hjust = 0,
        lineheight = 1.25,
        margin = ggplot2::margin(t = 10)
      )
    )
}

summarise_bridgerton <- function(names) {
  names |>
    dplyr::filter(
      Name %in% BRIDGERTON_NAMES,
      Sex == "Girl",
      Year %in% BRIDGERTON_YOY_YEARS,
      !is.na(Rank)
    ) |>
    dplyr::select(region, Year, Name, Rank, Number) |>
    dplyr::arrange(region, Name, Year)
}
