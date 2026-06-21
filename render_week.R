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

render_week <- function(week_dir = "2026_06_16_uk_baby_names") {
  if (!requireNamespace("quarto", quietly = TRUE)) {
    install.packages("quarto", repos = "https://cloud.r-project.org")
  }

  if (!file.exists("tidytuesday.Rproj")) {
    stop("Run from the tidytuesday project root.")
  }

  qmd_path <- file.path(week_dir, "analysis.qmd")
  if (!file.exists(qmd_path)) {
    stop("No analysis.qmd found at ", qmd_path)
  }

  Sys.setenv(QUARTO_PATH = find_quarto_bin())

  quarto::quarto_render(
    input = qmd_path,
    output_format = "html",
    quiet = FALSE
  )

  invisible(file.path(week_dir, "analysis.html"))
}
