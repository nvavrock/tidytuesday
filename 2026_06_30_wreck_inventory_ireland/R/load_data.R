# Load Wreck Inventory of Ireland for TidyTuesday 2026-06-30

DATA_SOURCE_CAPTION <- "Source: National Monuments Service via TidyTuesday"

LOCATION_COLORS <- c(
  "Located" = "#0072B2",
  "No coordinates" = "#CCCCCC"
)

CLASSIFICATION_COLORS <- c(
  "Schooner" = "#0072B2",
  "Steamship" = "#D55E00",
  "Brig" = "#009E73",
  "Barque" = "#CC79A7",
  "Ship" = "#56B4E9",
  "Other" = "#999999"
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

load_wreck_data <- function(data_dir = "data") {
  wreck_inventory <- readr::read_csv(
    file.path(data_dir, "wreck_inventory.csv"),
    show_col_types = FALSE
  )

  wreck_inventory |>
    dplyr::mutate(
      located = !is.na(latitude) & !is.na(longitude),
      location_status = dplyr::if_else(
        located,
        "Located",
        "No coordinates"
      ),
      decade = floor(year / 10) * 10
    )
}

download_data <- function(data_dir = "data") {
  base_url <- paste0(
    "https://raw.githubusercontent.com/rfordatascience/tidytuesday/",
    "main/data/2026/2026-06-30"
  )

  dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

  dest <- file.path(data_dir, "wreck_inventory.csv")
  if (!file.exists(dest)) {
    download.file(
      url = file.path(base_url, "wreck_inventory.csv"),
      destfile = dest,
      mode = "wb",
      quiet = TRUE
    )
  }

  invisible(dest)
}

summarise_location_status <- function(wreck_inventory) {
  wreck_inventory |>
    dplyr::count(location_status, name = "n") |>
    dplyr::mutate(
      share = n / sum(n)
    )
}

summarise_wrecks_by_decade <- function(wreck_inventory) {
  wreck_inventory |>
    dplyr::filter(!is.na(decade), decade >= 1300) |>
    dplyr::count(decade, name = "n") |>
    dplyr::arrange(decade)
}

summarise_classifications <- function(wreck_inventory, top_n = 10) {
  wreck_inventory |>
    dplyr::count(classification, sort = TRUE) |>
    dplyr::slice_head(n = top_n)
}
