# Load papal encyclical datasets for TidyTuesday 2026-06-23

DATA_SOURCE_CAPTION <- "Source: Vatican.va via TidyTuesday"

ENCYCLICAL_COLORS <- c(
  "Rerum Novarum" = "#0072B2",
  "Magnifica Humanitas" = "#D55E00"
)

POPE_COLORS <- c(
  "Leo XIII" = "#0072B2",
  "Leo XIV" = "#D55E00"
)

POPE_HIGHLIGHT_COLORS <- c(
  "Leo XIII" = "#0072B2",
  "Francis" = "#D55E00",
  "Other" = "#CCCCCC"
)

FLAGSHIP_YEAR_COLORS <- c(
  "Flagship text" = "#D55E00",
  "Other years" = "#56B4E9"
)

tt_theme <- function(base_size = 13) {
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(
        face = "bold",
        size = ggplot2::rel(1.15),
        margin = ggplot2::margin(b = 4)
      ),
      plot.subtitle = ggplot2::element_text(
        color = "gray40",
        margin = ggplot2::margin(b = 8)
      ),
      strip.text = ggplot2::element_text(face = "bold"),
      panel.grid.minor = ggplot2::element_blank(),
      plot.margin = ggplot2::margin(12, 16, 12, 12)
    )
}

load_encyclical_data <- function(data_dir = "data") {
  encyclicals <- readr::read_csv(
    file.path(data_dir, "encyclicals.csv"),
    show_col_types = FALSE
  )

  papal_encyclicals <- readr::read_csv(
    file.path(data_dir, "papal_encyclicals.csv"),
    show_col_types = FALSE
  )

  scripture_references <- readr::read_csv(
    file.path(data_dir, "scripture_references.csv"),
    show_col_types = FALSE
  )

  list(
    encyclicals = encyclicals |>
      dplyr::mutate(
        encyclical = factor(
          encyclical,
          levels = c("Rerum Novarum", "Magnifica Humanitas")
        ),
        doc_id = paste(encyclical, paragraph, sep = "_")
      ),
    papal_encyclicals = papal_encyclicals,
    scripture_references = scripture_references |>
      dplyr::filter(!is.na(book))
  )
}

download_data <- function(data_dir = "data") {
  base_url <- paste0(
    "https://raw.githubusercontent.com/rfordatascience/tidytuesday/",
    "main/data/2026/2026-06-23"
  )

  dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

  files <- c(
    "encyclicals.csv",
    "papal_encyclicals.csv",
    "scripture_references.csv"
  )

  for (file in files) {
    dest <- file.path(data_dir, file)
    if (!file.exists(dest)) {
      download.file(
        url = file.path(base_url, file),
        destfile = dest,
        mode = "wb",
        quiet = TRUE
      )
    }
  }

  invisible(files)
}

tokenize_paragraphs <- function(encyclicals) {
  stop_words <- tidytext::get_stopwords(language = "en", source = "snowball")

  encyclicals |>
    dplyr::mutate(
      text = stringr::str_replace_all(text, "[^A-Za-z'\\s]", " ")
    ) |>
    tidytext::unnest_tokens(word, text) |>
    dplyr::anti_join(stop_words, by = "word") |>
    dplyr::filter(
      stringr::str_detect(word, "^[a-z']+$"),
      nchar(word) > 2
    )
}

build_tfidf_matrix <- function(tokens) {
  tokens |>
    dplyr::count(doc_id, word, name = "n") |>
    tidytext::bind_tf_idf(word, doc_id, n) |>
    dplyr::select(doc_id, word, tf_idf) |>
    tidyr::pivot_wider(names_from = word, values_from = tf_idf, values_fill = 0)
}
