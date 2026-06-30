# Angle 2: Scripture citations in the two flagship encyclicals

plot_scripture_testament <- function(scripture_references) {
  by_testament <- scripture_references |>
    dplyr::count(pope, testament, name = "n")

  by_testament |>
    ggplot2::ggplot(ggplot2::aes(x = pope, y = n, fill = testament)) +
    ggplot2::geom_col(position = "dodge", width = 0.65, alpha = 0.92) +
    ggplot2::geom_text(
      ggplot2::aes(label = n, y = n),
      position = ggplot2::position_dodge(width = 0.65),
      vjust = 1.35,
      size = 3.5,
      fontface = "bold",
      color = "gray20",
      show.legend = FALSE
    ) +
    ggplot2::scale_fill_manual(
      values = c("Old Testament" = "#56B4E9", "New Testament" = "#E69F00"),
      name = NULL
    ) +
    ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = c(0, 0.08))) +
    ggplot2::labs(
      title = "Leo XIV cites more Old Testament books than Leo XIII",
      subtitle = "Biblical citations in Rerum Novarum (1891) vs Magnifica Humanitas (2026)",
      x = NULL,
      y = "Citation count",
      caption = DATA_SOURCE_CAPTION
    ) +
    tt_theme() +
    ggplot2::theme(legend.position = "bottom")
}

plot_scripture_books <- function(scripture_references, top_n = 5) {
  top_books <- scripture_references |>
    dplyr::count(pope, book, name = "n") |>
    dplyr::group_by(pope) |>
    dplyr::slice_max(n, n = top_n, with_ties = FALSE) |>
    dplyr::ungroup() |>
    dplyr::group_by(pope) |>
    dplyr::mutate(book = forcats::fct_reorder(book, n)) |>
    dplyr::ungroup()

  top_books |>
    ggplot2::ggplot(ggplot2::aes(x = n, y = book, fill = pope)) +
    ggplot2::geom_col(alpha = 0.92, width = 0.75, show.legend = FALSE) +
    ggplot2::geom_text(
      ggplot2::aes(x = n, label = n),
      hjust = 1.05,
      size = 3.2,
      fontface = "bold",
      color = "white"
    ) +
    ggplot2::facet_wrap(~ pope, scales = "free_y") +
    ggplot2::scale_fill_manual(values = POPE_COLORS) +
    ggplot2::scale_x_continuous(expand = ggplot2::expansion(mult = c(0, 0.06))) +
    ggplot2::labs(
      title = paste("Most cited books of the Bible (top", top_n, "per pope)"),
      subtitle = "RN citations partly manual; MH citations regex-extracted from text",
      x = "Citations",
      y = NULL,
      caption = DATA_SOURCE_CAPTION
    ) +
    tt_theme()
}

summarise_scripture <- function(scripture_references) {
  scripture_references |>
    dplyr::count(pope, testament, book, name = "n") |>
    dplyr::arrange(pope, dplyr::desc(n))
}
