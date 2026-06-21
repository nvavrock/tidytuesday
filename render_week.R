# Render a week's Quarto report from the project root
# Usage: source("render_week.R"); render_week("2026_06_16_uk_baby_names")

find_quarto_bin <- function() {
  env_path <- Sys.getenv("QUARTO_PATH", unset = "")
  if (nzchar(env_path) && file.exists(env_path)) {
    return(normalizePath(env_path, winslash = "/", mustWork = FALSE))
  }

  candidates <- c(
    "C:/Program Files/RStudio/resources/app/bin/quarto/bin/quarto.exe",
    "C:/Program Files/RStudio/resources/app/bin/quarto/bin/quarto.cmd",
    Sys.which("quarto")
  )

  for (path in candidates) {
    if (nzchar(path) && file.exists(path)) {
      return(normalizePath(path, winslash = "/", mustWork = FALSE))
    }
  }

  stop("Quarto CLI not found. Set QUARTO_PATH or install Quarto.")
}

is_wsl_path <- function(path) {
  grepl("wsl\\.localhost", path, ignore.case = TRUE)
}

copy_week_to_temp <- function(project_root, week_dir) {
  temp_root <- file.path(
    Sys.getenv("TEMP", unset = tempdir()),
    paste0("tidytuesday_render_", format(Sys.time(), "%Y%m%d%H%M%S"))
  )
  temp_week <- file.path(temp_root, week_dir)

  dir.create(temp_week, recursive = TRUE, showWarnings = FALSE)
  file.copy(file.path(project_root, "install_packages.R"), temp_root, overwrite = TRUE)

  week_src <- file.path(project_root, week_dir)
  copied <- file.copy(week_src, temp_root, recursive = TRUE, overwrite = TRUE)
  if (!copied) {
    stop("Failed to copy week folder to temp: ", week_src)
  }

  list(
    temp_root = temp_root,
    temp_week = temp_week,
    qmd_path = file.path(temp_week, "analysis.qmd")
  )
}

copy_render_outputs <- function(temp_week, dest_week) {
  for (item in c("analysis.html", "analysis_files")) {
    src <- file.path(temp_week, item)
    if (!file.exists(src)) {
      next
    }

    dest <- file.path(dest_week, item)
    if (dir.exists(src)) {
      if (dir.exists(dest)) {
        unlink(dest, recursive = TRUE)
      }
      file.copy(src, dest_week, recursive = TRUE, overwrite = TRUE)
    } else {
      file.copy(src, dest, overwrite = TRUE)
    }
  }
}

render_week <- function(week_dir = "2026_06_16_uk_baby_names") {
  if (!requireNamespace("quarto", quietly = TRUE)) {
    install.packages("quarto", repos = "https://cloud.r-project.org")
  }

  project_root <- if (file.exists("tidytuesday.Rproj")) {
    normalizePath(".", winslash = "/", mustWork = FALSE)
  } else {
    stop("Run from the tidytuesday project root.")
  }

  dest_week <- file.path(project_root, week_dir)
  qmd_src <- file.path(dest_week, "analysis.qmd")
  if (!file.exists(qmd_src)) {
    stop("No analysis.qmd found at ", qmd_src)
  }

  quarto_cache <- file.path(project_root, ".quarto")
  if (dir.exists(quarto_cache)) {
    unlink(quarto_cache, recursive = TRUE)
  }

  Sys.setenv(QUARTO_PATH = find_quarto_bin())

  temp <- NULL
  qmd_path <- qmd_src

  if (is_wsl_path(project_root)) {
    message("WSL path detected — rendering via Windows temp copy...")
    temp <- copy_week_to_temp(project_root, week_dir)
    qmd_path <- temp$qmd_path
    Sys.setenv(
      TT_WEEK_DIR = temp$temp_week,
      TT_PROJECT_ROOT = temp$temp_root
    )
  }

  on.exit({
    Sys.unsetenv("TT_WEEK_DIR")
    Sys.unsetenv("TT_PROJECT_ROOT")
    if (!is.null(temp) && dir.exists(temp$temp_root)) {
      unlink(temp$temp_root, recursive = TRUE)
    }
  }, add = TRUE)

  if (!file.exists(qmd_path)) {
    stop("No analysis.qmd found at ", qmd_path)
  }

  quarto::quarto_render(
    input = qmd_path,
    output_format = "html",
    quiet = FALSE
  )

  if (!is.null(temp)) {
    copy_render_outputs(temp$temp_week, dest_week)
    message("Copied rendered output back to ", dest_week)
  }

  invisible(file.path(dest_week, "analysis.html"))
}
