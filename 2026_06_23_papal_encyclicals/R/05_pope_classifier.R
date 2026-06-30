# Angle 5: Classify pope from paragraph text (exploratory)

build_dtm <- function(tokens) {
  tokens |>
    dplyr::count(doc_id, word, name = "n") |>
    tidyr::pivot_wider(names_from = word, values_from = n, values_fill = 0)
}

fit_pope_classifier <- function(encyclicals, tokens, seed = 42) {
  dtm <- build_dtm(tokens)
  labels <- encyclicals |>
    dplyr::select(doc_id, pope_name = pope) |>
    dplyr::distinct()

  model_data <- dtm |>
    dplyr::inner_join(labels, by = "doc_id")

  y <- ifelse(model_data$pope_name == "Leo XIII", 0, 1)
  x <- model_data |>
    dplyr::select(-doc_id, -pope_name) |>
    as.matrix()

  set.seed(seed)
  train_idx <- sample(seq_len(nrow(x)), size = floor(0.75 * nrow(x)))

  fit <- glmnet::glmnet(
    x[train_idx, , drop = FALSE],
    y[train_idx],
    family = "binomial",
    alpha = 1
  )

  preds <- predict(fit, x[-train_idx, , drop = FALSE], type = "class", s = 0.01)
  acc <- mean(as.integer(preds) == y[-train_idx])
  baseline <- max(mean(y == 0), mean(y == 1))

  coefs <- as.matrix(coef(fit, s = 0.01))
  coef_df <- tibble::tibble(
    word = rownames(coefs)[-1],
    coefficient = as.numeric(coefs[-1, 1])
  ) |>
    dplyr::filter(coefficient != 0) |>
    dplyr::arrange(dplyr::desc(abs(coefficient)))

  list(
    fit = fit,
    accuracy = acc,
    baseline = baseline,
    n_train = length(train_idx),
    n_test = nrow(x) - length(train_idx),
    coefficients = coef_df
  )
}

plot_classifier_coefficients <- function(classifier, top_n = 10) {
  coef_plot <- classifier$coefficients |>
    dplyr::mutate(side = dplyr::if_else(coefficient > 0, "pos", "neg")) |>
    dplyr::group_by(side) |>
    dplyr::slice_max(abs(coefficient), n = top_n, with_ties = FALSE) |>
    dplyr::ungroup() |>
    dplyr::mutate(
      pope = dplyr::if_else(
        coefficient > 0,
        "Leo XIV (2026)",
        "Leo XIII (1891)"
      ),
      word = forcats::fct_reorder(word, coefficient),
      label = dplyr::if_else(
        rank(-abs(coefficient)) <= 8,
        sprintf("%.2f", coefficient),
        ""
      ),
      hjust = dplyr::if_else(coefficient > 0, -0.25, 1.25)
    )

  acc_pct <- round(classifier$accuracy * 100, 1)
  base_pct <- round(classifier$baseline * 100, 1)

  coef_plot |>
    ggplot2::ggplot(ggplot2::aes(x = coefficient, y = word, fill = pope)) +
    ggplot2::geom_col(alpha = 0.92, width = 0.75) +
    ggplot2::geom_text(
      ggplot2::aes(label = label, hjust = hjust),
      size = 2.8,
      fontface = "bold",
      color = "black",
      show.legend = FALSE
    ) +
    ggplot2::geom_vline(xintercept = 0, color = "gray50", linewidth = 0.4) +
    ggplot2::scale_x_continuous(expand = ggplot2::expansion(mult = c(0.06, 0.08))) +
    ggplot2::scale_fill_manual(
      values = c(
        "Leo XIV (2026)" = POPE_COLORS[["Leo XIV"]],
        "Leo XIII (1891)" = POPE_COLORS[["Leo XIII"]]
      ),
      name = "Predicts"
    ) +
    ggplot2::labs(
      title = paste0("Lasso separates popes at ", acc_pct, "% hold-out accuracy"),
      subtitle = paste0(
        "Baseline ", base_pct, "% — top ", top_n, " words per pope; era-specific topic words, not abstract style"
      ),
      x = "Lasso coefficient",
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

summarise_classifier <- function(classifier) {
  tibble::tibble(
    holdout_accuracy = classifier$accuracy,
    baseline_accuracy = classifier$baseline,
    n_train = classifier$n_train,
    n_test = classifier$n_test
  )
}
