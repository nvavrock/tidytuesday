# Angle 4: Paragraph-level similarity between the two encyclicals

cosine_similarity <- function(a, b) {
  sum(a * b) / (sqrt(sum(a^2)) * sqrt(sum(b^2)))
}

compute_paragraph_similarity <- function(encyclicals, tokens, top_k = 10) {
  tfidf_wide <- build_tfidf_matrix(tokens)
  meta <- encyclicals |>
    dplyr::select(doc_id, encyclical, pope, paragraph, word_count)

  tfidf_mat <- tfidf_wide |>
    tibble::column_to_rownames("doc_id") |>
    as.matrix()

  rn_ids <- meta |>
    dplyr::filter(encyclical == "Rerum Novarum") |>
    dplyr::pull(doc_id)

  mh_ids <- meta |>
    dplyr::filter(encyclical == "Magnifica Humanitas") |>
    dplyr::pull(doc_id)

  rn_mat <- tfidf_mat[rn_ids, , drop = FALSE]
  mh_mat <- tfidf_mat[mh_ids, , drop = FALSE]

  pairs <- expand.grid(
    mh_doc = mh_ids,
    rn_doc = rn_ids,
    stringsAsFactors = FALSE
  ) |>
    dplyr::rowwise() |>
    dplyr::mutate(
      similarity = cosine_similarity(
        mh_mat[mh_doc, ],
        rn_mat[rn_doc, ]
      )
    ) |>
    dplyr::ungroup()

  best <- pairs |>
    dplyr::group_by(mh_doc) |>
    dplyr::slice_max(similarity, n = 1, with_ties = FALSE) |>
    dplyr::ungroup() |>
    dplyr::slice_max(similarity, n = top_k) |>
    dplyr::left_join(
      meta |> dplyr::rename(mh_paragraph = paragraph),
      by = c("mh_doc" = "doc_id")
    ) |>
    dplyr::left_join(
      meta |>
        dplyr::select(doc_id, rn_paragraph = paragraph),
      by = c("rn_doc" = "doc_id")
    ) |>
    dplyr::mutate(
      label = paste0("MH ¶", mh_paragraph, " → RN ¶", rn_paragraph)
    )

  best
}

plot_text_similarity <- function(similarity_df) {
  plot_data <- similarity_df |>
    dplyr::mutate(
      label = forcats::fct_reorder(
        paste0("¶", mh_paragraph, " → ¶", rn_paragraph),
        similarity
      )
    )

  plot_data |>
    ggplot2::ggplot(ggplot2::aes(x = similarity, y = label, color = similarity)) +
    ggplot2::geom_segment(
      ggplot2::aes(x = 0, xend = similarity, y = label, yend = label),
      color = "gray80",
      linewidth = 0.9,
      show.legend = FALSE
    ) +
    ggplot2::geom_point(size = 4) +
    ggplot2::geom_text(
      ggplot2::aes(x = similarity * 0.92, label = sprintf("%.2f", similarity)),
      hjust = 1,
      size = 3.2,
      fontface = "bold",
      color = "gray20",
      show.legend = FALSE
    ) +
    ggplot2::scale_color_gradient(
      low = "#FEE0C7",
      high = ENCYCLICAL_COLORS[["Magnifica Humanitas"]],
      guide = "none"
    ) +
    ggplot2::scale_x_continuous(
      limits = c(0, NA),
      expand = ggplot2::expansion(mult = c(0, 0.08))
    ) +
    ggplot2::labs(
      title = "Several MH paragraphs echo RN on dignity and social order",
      subtitle = "Top TF-IDF cosine matches (paragraph level); scores stay modest — shared vocabulary, not direct quotes",
      x = "Similarity score",
      y = NULL,
      caption = DATA_SOURCE_CAPTION
    ) +
    tt_theme()
}

summarise_text_similarity <- function(similarity_df) {
  similarity_df |>
    dplyr::select(
      mh_paragraph,
      rn_paragraph,
      similarity,
      word_count
    ) |>
    dplyr::arrange(dplyr::desc(similarity))
}
