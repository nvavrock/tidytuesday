# Load and combine UK baby name datasets for TidyTuesday 2026-06-16

DATA_SOURCE_CAPTION <- "Source: ONS, NISRA, National Records of Scotland via TidyTuesday"

SEX_COLORS <- c(Boy = "#0072B2", Girl = "#D55E00")
REGION_COLORS <- c(
  "England & Wales" = "#009E73",
  Scotland = "#CC79A7",
  "Northern Ireland" = "#E69F00"
)

load_baby_names <- function(data_dir = "data") {
  england_wales <- readr::read_csv(
    file.path(data_dir, "england_wales_names.csv"),
    show_col_types = FALSE
  )

  ni <- readr::read_csv(
    file.path(data_dir, "ni_names.csv"),
    show_col_types = FALSE
  )

  scotland <- readr::read_csv(
    file.path(data_dir, "scotland_names.csv"),
    show_col_types = FALSE
  )

  bind_rows(
    england_wales |> dplyr::mutate(region = "England & Wales"),
    ni |> dplyr::mutate(region = "Northern Ireland"),
    scotland |> dplyr::mutate(region = "Scotland")
  ) |>
    dplyr::mutate(
      region = factor(
        region,
        levels = c("England & Wales", "Scotland", "Northern Ireland")
      ),
      Sex = dplyr::case_when(
        Sex %in% c("Boy", "Male", "M") ~ "Boy",
        Sex %in% c("Girl", "Female", "F") ~ "Girl",
        TRUE ~ Sex
      )
    )
}

download_data <- function(data_dir = "data") {
  base_url <- paste0(
    "https://raw.githubusercontent.com/rfordatascience/tidytuesday/",
    "main/data/2026/2026-06-16"
  )

  dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

  files <- c(
    "england_wales_names.csv",
    "ni_names.csv",
    "scotland_names.csv"
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
