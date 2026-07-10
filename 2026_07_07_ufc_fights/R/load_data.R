# Load UFC fight data for TidyTuesday 2026-07-07

DATA_SOURCE_CAPTION <- "Source: fightr / UFCStats via TidyTuesday"

FINISH_COLORS <- c(
  "KO/TKO" = "#E10600",
  "Submission" = "#4A6FA5",
  "Decision" = "#8B9CB3",
  "Other" = "#6D5B4B"
)

DASH_THEME <- list(
  bg = "#0B0B0D",
  surface = "#141418",
  text = "#E5E5E5",
  text_muted = "#A1A1AA",
  accent = "#C8102E",
  accent_gold = "#C9A227",
  border = "#2A2A30",
  dimmed = "#25252D"
)

WEIGHT_CLASS_PALETTE <- c(
  "#E10600", "#4A6FA5", "#C9A227", "#9B59B6", "#2ECC71",
  "#E67E22", "#1ABC9C", "#E84393", "#3498DB", "#6B7280"
)

WEIGHT_CLASS_LEVELS <- c(
  "Flyweight",
  "Bantamweight",
  "Featherweight",
  "Lightweight",
  "Welterweight",
  "Middleweight",
  "Light Heavyweight",
  "Heavyweight",
  "Women's Strawweight",
  "Women's Flyweight",
  "Women's Bantamweight",
  "Women's Featherweight",
  "Catch Weight",
  "Super Heavyweight",
  "Open Weight"
)

MENS_WEIGHT_CLASS_LEVELS <- c(
  "Flyweight",
  "Bantamweight",
  "Featherweight",
  "Lightweight",
  "Welterweight",
  "Middleweight",
  "Light Heavyweight",
  "Heavyweight",
  "Catch Weight",
  "Super Heavyweight",
  "Open Weight"
)

WOMENS_WEIGHT_CLASS_LEVELS <- c(
  "Women's Strawweight",
  "Women's Flyweight",
  "Women's Bantamweight",
  "Women's Featherweight"
)

WOMENS_DIVISION_LABELS <- c(
  "Strawweight",
  "Flyweight",
  "Bantamweight",
  "Featherweight"
)

weight_class_scales <- function() {
  tibble::tibble(
    division = c(
      "Flyweight",
      "Bantamweight",
      "Featherweight",
      "Lightweight",
      "Welterweight",
      "Middleweight",
      "Light Heavyweight",
      "Heavyweight",
      "Strawweight",
      "Flyweight",
      "Bantamweight",
      "Featherweight"
    ),
    gender = c(rep("Men", 8L), rep("Women", 4L)),
    limit_lb = c(125L, 135L, 145L, 155L, 170L, 185L, 205L, 265L, 115L, 125L, 135L, 145L)
  )
}

weight_class_scales_table <- function() {
  weight_class_scales() |>
    dplyr::mutate(
      division = dplyr::if_else(
        gender == "Women",
        paste0("Women's ", division),
        division
      ),
      `Weight limit` = paste0("\u2264 ", limit_lb, " lb")
    ) |>
    dplyr::select(Division = division, Gender = gender, `Weight limit`)
}

is_womens_division <- function(weight_class) {
  grepl("^Women's ", as.character(weight_class))
}

normalize_weight_class <- function(weight_class) {
  dplyr::case_when(
    is.na(weight_class) ~ NA_character_,
    weight_class %in% WEIGHT_CLASS_LEVELS ~ weight_class,
    grepl("Women's Strawweight", weight_class, fixed = TRUE) ~ "Women's Strawweight",
    grepl("Women's Flyweight", weight_class, fixed = TRUE) ~ "Women's Flyweight",
    grepl("Women's Bantamweight", weight_class, fixed = TRUE) ~ "Women's Bantamweight",
    grepl("Women's Featherweight", weight_class, fixed = TRUE) ~ "Women's Featherweight",
    grepl("Light Heavyweight", weight_class, fixed = TRUE) ~ "Light Heavyweight",
    grepl("Super Heavyweight", weight_class, fixed = TRUE) ~ "Super Heavyweight",
    grepl("Catch Weight", weight_class, fixed = TRUE) ~ "Catch Weight",
    grepl("Open Weight", weight_class, fixed = TRUE) ~ "Open Weight",
    grepl("Flyweight", weight_class, fixed = TRUE) ~ "Flyweight",
    grepl("Bantamweight", weight_class, fixed = TRUE) ~ "Bantamweight",
    grepl("Featherweight", weight_class, fixed = TRUE) ~ "Featherweight",
    grepl("Lightweight", weight_class, fixed = TRUE) ~ "Lightweight",
    grepl("Welterweight", weight_class, fixed = TRUE) ~ "Welterweight",
    grepl("Middleweight", weight_class, fixed = TRUE) ~ "Middleweight",
    grepl("Heavyweight", weight_class, fixed = TRUE) ~ "Heavyweight",
    TRUE ~ NA_character_
  )
}

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

event_levels_by_date_outcome <- function(fights) {
  fights |>
    dplyr::mutate(
      finish_rank = match(as.character(finish_type), names(FINISH_COLORS))
    ) |>
    dplyr::group_by(event_name) |>
    dplyr::summarise(
      event_date = max(fight_date, na.rm = TRUE),
      min_finish_rank = min(finish_rank, na.rm = TRUE),
      .groups = "drop"
    ) |>
    dplyr::arrange(
      dplyr::desc(event_date),
      min_finish_rank,
      event_name
    ) |>
    dplyr::pull(event_name)
}

sort_fights_by_date_outcome <- function(fights) {
  fights |>
    dplyr::arrange(dplyr::desc(fight_date), finish_type)
}

attach_title_bouts <- function(fights, ultimate = NULL) {
  if (is.null(ultimate)) {
    ultimate <- load_ultimate_data()
  }

  title_lookup <- ultimate |>
    dplyr::mutate(
      fight_date = as.Date(date),
      pair = paste(
        pmin(r_fighter, b_fighter),
        pmax(r_fighter, b_fighter),
        sep = "|"
      ),
      is_title_fight = title_bout %in% TRUE
    ) |>
    dplyr::distinct(fight_date, pair, .keep_all = TRUE) |>
    dplyr::select(fight_date, pair, is_title_fight)

  fights |>
    dplyr::mutate(
      fight_date = as.Date(date),
      pair = paste(
        pmin(f1_name, f2_name),
        pmax(f1_name, f2_name),
        sep = "|"
      )
    ) |>
    dplyr::left_join(title_lookup, by = c("fight_date", "pair")) |>
    dplyr::mutate(is_title_fight = is_title_fight %in% TRUE) |>
    dplyr::select(-pair)
}

prepare_fight_details <- function(fights, min_year = 2000) {
  prepared <- fights |>
    dplyr::filter(
      !is.na(year),
      year >= min_year,
      !is.na(finish_type)
    ) |>
    dplyr::mutate(
      winner = dplyr::case_when(
        f1_result == "W" ~ f1_name,
        f2_result == "W" ~ f2_name,
        TRUE ~ NA_character_
      ),
      finish_type = factor(
        finish_type,
        levels = names(FINISH_COLORS)
      ),
      stats_link = sprintf(
        '<a href="%s" target="_blank" rel="noopener">UFCStats</a>',
        fight_url
      ),
      weight_class = normalize_weight_class(weight_class),
      is_title_fight = is_title_fight %in% TRUE
    )

  prepared |>
    dplyr::filter(!is.na(weight_class)) |>
    dplyr::mutate(
      event_name = factor(
        event_name,
        levels = event_levels_by_date_outcome(prepared)
      ),
      weight_class = factor(
        weight_class,
        levels = WEIGHT_CLASS_LEVELS
      )
    ) |>
    dplyr::select(
      fight_url,
      fight_date,
      year,
      event_name,
      f1_name,
      f2_name,
      winner,
      weight_class,
      is_title_fight,
      finish_type,
      method,
      round,
      time,
      location,
      referee,
      judging_details,
      stats_link
    ) |>
    sort_fights_by_date_outcome()
}
