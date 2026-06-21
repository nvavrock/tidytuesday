# Path helpers for WSL + Windows RStudio

tt_fix_path <- function(path) {
  if (is.null(path) || is.na(path) || !nzchar(path)) {
    return(path)
  }

  if (.Platform$OS.type == "windows" && grepl("^/home/", path)) {
    path <- sub("^/home/", "//wsl.localhost/Ubuntu/home/", path)
  }

  normalizePath(path, winslash = "/", mustWork = FALSE)
}

tt_week_dir <- function(week_name = "2026_06_16_uk_baby_names", raw_input = NULL) {
  if (is.null(raw_input)) {
    raw_input <- tryCatch(knitr::current_input(dir = TRUE), error = function(e) NULL)
  }

  candidates <- c(
    tt_fix_path(raw_input),
    if (file.exists("R/load_data.R")) tt_fix_path("."),
    tt_fix_path(week_name),
    tt_fix_path(file.path("..", week_name)),
    tt_fix_path(file.path(getwd(), week_name))
  )

  for (candidate in candidates) {
    if (is.null(candidate) || !nzchar(candidate)) {
      next
    }

    fixed <- tt_fix_path(candidate)
    if (file.exists(file.path(fixed, "R/load_data.R"))) {
      return(fixed)
    }
  }

  stop("Could not find week folder: ", week_name)
}

tt_project_root <- function(week_dir) {
  tt_fix_path(file.path(week_dir, ".."))
}
