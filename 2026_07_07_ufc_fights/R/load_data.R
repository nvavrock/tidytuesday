# Load UFC fight data for TidyTuesday 2026-07-07

DATA_SOURCE_CAPTION <- "Source: fightr / UFCStats via TidyTuesday"

FINISH_COLORS <- c(
  "KO/TKO" = "#D55E00",
  "Submission" = "#0072B2",
  "Decision" = "#009E73",
  "Other" = "#999999"
)

WEIGHT_CLASS_PALETTE <- c(
  "#0072B2", "#D55E00", "#009E73", "#CC79A7", "#56B4E9",
  "#E69F00", "#332288", "#882255", "#44AA99", "#999999"
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

normalize_fight_method <- function(method) {
  dplyr::case_when(
    is.na(method) ~ NA_character_,
    grepl("KO/TKO|Doctor", method, ignore.case = TRUE) ~ "KO/TKO",
    grepl("Submission", method, ignore.case = TRUE) ~ "Submission",
    grepl("Decision", method, ignore.case = TRUE) ~ "Decision",
    TRUE ~ "Other"
  )
}

load_fight_data <- function(data_dir = "data") {
  fights <- readr::read_csv(
    file.path(data_dir, "ufc_fights.csv"),
    show_col_types = FALSE
  )

  fights |>
    dplyr::mutate(
      fight_date = as.Date(date),
      year = lubridate::year(fight_date),
      finish_type = normalize_fight_method(method),
      weight_class = stringr::str_remove(weight_class, " Bout$")
    )
}

load_ultimate_data <- function(data_dir = "data") {
  path <- file.path(data_dir, "ultimate_ufc_dataset.csv")
  if (!file.exists(path)) {
    stop(
      "ultimate_ufc_dataset.csv missing. Run download_data() from project root."
    )
  }

  ultimate <- readr::read_csv(path, show_col_types = FALSE)

  ultimate |>
    dplyr::mutate(
      fight_date = as.Date(date),
      year = lubridate::year(fight_date),
      finish_type = dplyr::case_when(
        finish %in% c("KO/TKO") ~ "KO/TKO",
        finish %in% c("SUB") ~ "Submission",
        finish %in% c("U-DEC", "S-DEC", "M-DEC") ~ "Decision",
        TRUE ~ "Other"
      ),
      longer_corner = dplyr::case_when(
        is.na(reach_dif) ~ NA_character_,
        reach_dif > 0 ~ "Blue",
        reach_dif < 0 ~ "Red",
        TRUE ~ "Equal"
      ),
      longer_wins = dplyr::case_when(
        is.na(reach_dif) | longer_corner == "Equal" ~ NA,
        reach_dif > 0 ~ winner == "Blue",
        reach_dif < 0 ~ winner == "Red",
        TRUE ~ NA
      )
    )
}

download_data <- function(data_dir = "data") {
  base_url <- paste0(
    "https://raw.githubusercontent.com/rfordatascience/tidytuesday/",
    "main/data/2026/2026-07-07"
  )

  remote_files <- c(
    "ufc_fights.csv" = file.path(base_url, "ufc_fights.csv"),
    "ultimate_ufc_dataset.csv" = file.path(base_url, "ultimate_ufc_dataset.csv")
  )

  dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

  for (name in names(remote_files)) {
    dest <- file.path(data_dir, name)
    if (!file.exists(dest)) {
      download.file(
        url = remote_files[[name]],
        destfile = dest,
        mode = "wb",
        quiet = TRUE
      )
    }
  }

  invisible(file.path(data_dir, "ufc_fights.csv"))
}

summarise_fights_by_year <- function(fights) {
  fights |>
    dplyr::filter(!is.na(year), year >= 1994) |>
    dplyr::count(year, name = "n") |>
    dplyr::arrange(year)
}

summarise_finish_by_year <- function(fights) {
  fights |>
    dplyr::filter(!is.na(year), !is.na(finish_type), year >= 1994) |>
    dplyr::count(year, finish_type, name = "n") |>
    dplyr::group_by(year) |>
    dplyr::mutate(share = n / sum(n)) |>
    dplyr::ungroup()
}

summarise_reach_advantage <- function(ultimate) {
  ultimate |>
    dplyr::filter(
      winner %in% c("Red", "Blue"),
      !is.na(reach_dif),
      longer_corner %in% c("Red", "Blue"),
      !is.na(longer_wins)
    ) |>
    dplyr::count(longer_corner, longer_wins, name = "n") |>
    dplyr::group_by(longer_corner) |>
    dplyr::mutate(share = n / sum(n)) |>
    dplyr::ungroup()
}

summarise_weight_classes <- function(fights, top_n = 10) {
  fights |>
    dplyr::filter(!is.na(weight_class)) |>
    dplyr::count(weight_class, sort = TRUE) |>
    dplyr::slice_head(n = top_n)
}
