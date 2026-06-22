# Angle 3: The Bridgerton trend
# Tracks Daphne, Eloise, and Penelope rank changes over time.

BRIDGERTON_NAMES <- c("Daphne", "Eloise", "Penelope")

BRIDGERTON_NAME_COLORS <- c(
  Daphne = "#0072B2",
  Eloise = "#D55E00",
  Penelope = "#009E73"
)

plot_bridgerton_trend <- function(names) {
  bridgerton <- names |>
    dplyr::filter(
      Name %in% BRIDGERTON_NAMES,
      Sex == "Girl",
      !is.na(Rank)
    )

  labels <- bridgerton |>
    dplyr::group_by(region, Name) |>
    dplyr::slice_max(Year, n = 1, with_ties = FALSE) |>
    dplyr::ungroup()

  bridgerton |>
    ggplot2::ggplot(
      ggplot2::aes(x = Year, y = Rank, color = Name, group = Name)
    ) +
    ggplot2::geom_line(linewidth = 0.9) +
    ggplot2::geom_point(size = 1.8) +
    ggrepel::geom_text_repel(
      data = labels,
      ggplot2::aes(label = Name),
      size = 3,
      show.legend = FALSE,
      min.segment.length = 0,
      box.padding = 0.3,
      point.padding = 0.2
    ) +
    ggplot2::facet_wrap(~ region, ncol = 1, scales = "free_x") +
    ggplot2::scale_y_reverse(breaks = scales::pretty_breaks(n = 8)) +
    ggplot2::scale_color_manual(values = BRIDGERTON_NAME_COLORS) +
    ggplot2::labs(
      title = "The Bridgerton effect on UK baby names",
      subtitle = "Lower rank = more popular. Scotland 2025: Penelope 71st, Eloise 91st, Daphne 172nd",
      x = NULL,
      y = "Rank (1 = most popular)",
      color = "Name",
      caption = DATA_SOURCE_CAPTION
    ) +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(legend.position = "bottom")
}

plot_bridgerton_2024_2025 <- function(names) {
  bridgerton <- names |>
    dplyr::filter(
      Name %in% BRIDGERTON_NAMES,
      Sex == "Girl",
      Year %in% c(2024, 2025),
      !is.na(Rank)
    ) |>
    dplyr::mutate(Year = factor(Year, levels = c(2024, 2025)))

  if (nrow(bridgerton) == 0) {
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

  bridgerton |>
    ggplot2::ggplot(
      ggplot2::aes(x = Year, y = Rank, color = region, group = region)
    ) +
    ggplot2::geom_point(size = 3) +
    ggplot2::geom_line(linewidth = 0.9) +
    ggplot2::facet_wrap(~ Name, ncol = 1) +
    ggplot2::scale_y_reverse() +
    ggplot2::scale_color_manual(values = REGION_COLORS) +
    ggplot2::labs(
      title = "Bridgerton names: 2024 vs 2025 rank change",
      subtitle = "Downward slope = more popular (lower rank is better)",
      x = NULL,
      y = "Rank",
      color = "Region",
      caption = DATA_SOURCE_CAPTION
    ) +
    ggplot2::theme_minimal(base_size = 11) +
    ggplot2::theme(legend.position = "bottom")
}

summarise_bridgerton <- function(names) {
  names |>
    dplyr::filter(
      Name %in% BRIDGERTON_NAMES,
      Sex == "Girl",
      Year %in% c(2024, 2025),
      !is.na(Rank)
    ) |>
    dplyr::select(region, Year, Name, Rank, Number) |>
    dplyr::arrange(region, Name, Year)
}
