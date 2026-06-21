# Angle 3: The Bridgerton trend
# Tracks Daphne, Eloise, and Penelope rank changes over time.

BRIDGERTON_NAMES <- c("Daphne", "Eloise", "Penelope")

plot_bridgerton_trend <- function(names) {
  bridgerton <- names |>
    dplyr::filter(
      Name %in% BRIDGERTON_NAMES,
      Sex == "Girl",
      !is.na(Rank)
    )

  bridgerton |>
    ggplot2::ggplot(
      ggplot2::aes(x = Year, y = Rank, color = Name, group = Name)
    ) +
    ggplot2::geom_line(linewidth = 0.9) +
    ggplot2::geom_point(size = 1.8) +
    ggplot2::facet_wrap(~ region, ncol = 1, scales = "free_x") +
    ggplot2::scale_y_reverse(breaks = scales::pretty_breaks(n = 8)) +
    ggplot2::scale_color_manual(
      values = c(
        Daphne = "#7b3294",
        Eloise = "#c2a5cf",
        Penelope = "#008837"
      )
    ) +
    ggplot2::labs(
      title = "The Bridgerton effect on UK baby names",
      subtitle = "Lower rank = more popular. Scotland 2025: Penelope 71st, Eloise 91st, Daphne 172nd",
      x = NULL,
      y = "Rank (1 = most popular)",
      color = "Name"
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
    dplyr::mutate(Year = factor(Year))

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
      ggplot2::aes(x = Year, y = Rank, fill = Name)
    ) +
    ggplot2::geom_col(position = "dodge", width = 0.65) +
    ggplot2::facet_grid(Name ~ region, scales = "free_y") +
    ggplot2::scale_y_reverse() +
    ggplot2::scale_fill_manual(
      values = c(
        Daphne = "#7b3294",
        Eloise = "#c2a5cf",
        Penelope = "#008837"
      )
    ) +
    ggplot2::labs(
      title = "Bridgerton names: 2024 vs 2025 rank",
      subtitle = "Lower bars = more popular (rank 1 is best)",
      x = NULL,
      y = "Rank",
      fill = NULL
    ) +
    ggplot2::theme_minimal(base_size = 11) +
    ggplot2::theme(legend.position = "none")
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
