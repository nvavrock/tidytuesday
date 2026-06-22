# Angle 1: Regional comparison of top baby names
# Compares name rankings across England & Wales, Scotland, and Northern Ireland.

plot_regional_top_names <- function(names, year = 2024, top_n = 10) {
  top_names <- names |>
    dplyr::filter(Year == year, !is.na(Rank), !is.na(Number)) |>
    dplyr::group_by(region, Sex) |>
    dplyr::slice_min(Rank, n = top_n, with_ties = FALSE) |>
    dplyr::mutate(Name = forcats::fct_reorder(Name, Number)) |>
    dplyr::ungroup()

  top_names |>
    ggplot2::ggplot(
      ggplot2::aes(
        x = Number,
        y = Name,
        fill = Sex
      )
    ) +
    ggplot2::geom_col() +
    ggplot2::facet_grid(Sex ~ region, scales = "free") +
    ggplot2::scale_x_continuous(labels = scales::comma) +
    ggplot2::scale_fill_manual(values = SEX_COLORS) +
    ggplot2::labs(
      title = paste("Top", top_n, "baby names by UK region,", year),
      subtitle = "England & Wales data ends in 2024; Scotland and NI include 2025 in other charts",
      x = NULL,
      y = NULL,
      fill = NULL,
      caption = DATA_SOURCE_CAPTION
    ) +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(legend.position = "none")
}

plot_regional_overlap <- function(names, year = 2024, top_n = 10) {
  top_by_region <- names |>
    dplyr::filter(Year == year, !is.na(Rank)) |>
    dplyr::group_by(region, Sex) |>
    dplyr::slice_min(Rank, n = top_n, with_ties = FALSE) |>
    dplyr::ungroup()

  overlap <- top_by_region |>
    dplyr::count(Sex, Name, name = "regions_in_top") |>
    dplyr::filter(regions_in_top >= 2) |>
    dplyr::left_join(
      top_by_region |>
        dplyr::select(region, Sex, Name, Rank),
      by = c("Sex", "Name")
    )

  if (nrow(overlap) == 0) {
    return(
      ggplot2::ggplot() +
        ggplot2::annotate(
          "text",
          x = 0.5,
          y = 0.5,
          label = paste("No names shared in top", top_n, "across 2+ regions in", year)
        ) +
        ggplot2::theme_void()
    )
  }

  overlap |>
    ggplot2::ggplot(
      ggplot2::aes(x = region, y = reorder(Name, Rank), fill = regions_in_top)
    ) +
    ggplot2::geom_tile(color = "white") +
    ggplot2::geom_text(ggplot2::aes(label = Rank), size = 3, color = "grey15") +
    ggplot2::facet_wrap(~ Sex, scales = "free_y") +
    ggplot2::scale_fill_gradient(
      "Regions\nin top 10",
      low = "#deebf7",
      high = "#08519c"
    ) +
    ggplot2::labs(
      title = paste("Names appearing in multiple regional top", top_n, "lists,", year),
      subtitle = "Tile labels show rank within each region (1 = most popular)",
      x = NULL,
      y = NULL,
      caption = DATA_SOURCE_CAPTION
    ) +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(legend.position = "bottom")
}

summarise_regional_comparison <- function(names, year = 2024, top_n = 10) {
  names |>
    dplyr::filter(Year == year, !is.na(Rank)) |>
    dplyr::group_by(region, Sex) |>
    dplyr::slice_min(Rank, n = top_n, with_ties = FALSE) |>
    dplyr::summarise(
      top_name = Name[which.min(Rank)],
      top_count = Number[which.min(Rank)],
      .groups = "drop"
    )
}
