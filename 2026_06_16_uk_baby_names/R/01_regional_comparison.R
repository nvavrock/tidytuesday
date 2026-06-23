# Angle 1: Regional comparison of top baby names
# Compares name rankings across England & Wales, Scotland, and Northern Ireland.

plot_regional_top_names <- function(names, year = 2024, top_n = 10) {
  top_names <- names |>
    dplyr::filter(Year == year, !is.na(Rank), !is.na(Number)) |>
    dplyr::group_by(region, Sex) |>
    dplyr::slice_min(Rank, n = top_n, with_ties = FALSE) |>
    dplyr::mutate(
      Name = forcats::fct_reorder(Name, Number),
      hover = paste0(
        "<b>", Name, "</b><br>",
        region, " · ", Sex, "<br>",
        "Count: ", scales::comma(Number), "<br>",
        "Rank: ", Rank
      )
    ) |>
    dplyr::ungroup()

  top_names |>
    ggplot2::ggplot(
      ggplot2::aes(
        x = Number,
        y = Name,
        fill = Sex,
        text = hover
      )
    ) +
    ggplot2::geom_col() +
    ggplot2::facet_grid(Sex ~ region, scales = "free") +
    ggplot2::scale_x_continuous(labels = scales::comma) +
    ggplot2::scale_fill_manual(values = SEX_COLORS) +
    ggplot2::labs(
      title = paste("Top", top_n, "baby names by UK region,", year),
      subtitle = paste(
        "Bar length = babies given the name in that region;",
        "each column has its own scale (regions differ in population)"
      ),
      x = "Babies given the name",
      y = NULL,
      fill = NULL,
      caption = DATA_SOURCE_CAPTION
    ) +
    tt_theme() +
    ggplot2::theme(
      legend.position = "none",
      panel.spacing.x = grid::unit(1.4, "cm"),
      panel.spacing.y = grid::unit(0.6, "cm"),
      axis.text.x = ggplot2::element_text(margin = ggplot2::margin(t = 4))
    )
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
        dplyr::select(region, Sex, Name, Rank, Number),
      by = c("Sex", "Name")
    ) |>
    dplyr::mutate(
      regions_in_top = factor(regions_in_top, levels = c(2, 3)),
      hover = paste0(
        "<b>", Name, "</b><br>",
        region, " · ", Sex, "<br>",
        "Rank: ", Rank,
        dplyr::if_else(
          !is.na(Number),
          paste0("<br>Count: ", scales::comma(Number)),
          ""
        ),
        "<br>In ", regions_in_top, " regional top-", top_n, " lists"
      )
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
      ggplot2::aes(
        x = region,
        y = reorder(Name, Rank),
        fill = regions_in_top,
        text = hover
      )
    ) +
    ggplot2::geom_tile(color = "white") +
    ggplot2::geom_text(ggplot2::aes(label = Rank), size = 3, color = "grey15") +
    ggplot2::facet_wrap(~ Sex, scales = "free_y") +
    ggplot2::scale_fill_manual(
      "Regions\nin top 10",
      values = c("2" = "#deebf7", "3" = "#08519c"),
      labels = c("2" = "2 regions", "3" = "All 3 regions")
    ) +
    ggplot2::labs(
      title = paste("Names appearing in multiple regional top", top_n, "lists,", year),
      subtitle = "Tile labels = rank in that region; fill = how many regional top-10 lists include the name",
      x = NULL,
      y = NULL,
      caption = DATA_SOURCE_CAPTION
    ) +
    tt_theme() +
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
