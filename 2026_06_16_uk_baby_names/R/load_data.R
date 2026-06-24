# Load and combine UK baby name datasets for TidyTuesday 2026-06-16

DATA_SOURCE_CAPTION <- "Source: ONS, NISRA, National Records of Scotland via TidyTuesday"

SEX_COLORS <- c(Boy = "#0072B2", Girl = "#D55E00")
REGION_COLORS <- c(
  "England & Wales" = "#009E73",
  Scotland = "#CC79A7",
  "Northern Ireland" = "#E69F00"
)

tt_theme <- function(base_size = 12) {
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold"),
      strip.text = ggplot2::element_text(face = "bold")
    )
}

as_interactive <- function(plot) {
  if (!requireNamespace("plotly", quietly = TRUE)) {
    return(plot)
  }

  px <- plotly::ggplotly(plot, tooltip = "text")

  px$x$data <- lapply(px$x$data, function(trace) {
    if (identical(trace$type, "box")) {
      trace$showlegend <- FALSE
      return(trace)
    }

    if (!identical(trace$type, "scatter") || is.null(trace$x)) {
      return(trace)
    }

    trace_name <- if (is.null(trace$name)) "" else as.character(trace$name)
    if (grepl(",", trace_name, fixed = TRUE)) {
      region_label <- trimws(sub(".*,", "", trace_name))
      trace$name <- region_label
      trace$legendgroup <- region_label
    }

    x <- trace$x
    y <- trace$y
    if (is.list(x)) {
      x <- unlist(x)
    }
    if (is.list(y)) {
      y <- unlist(y)
    }
    keep <- !is.na(x) & !is.na(y)

    if (any(!keep)) {
      trace$x <- x[keep]
      trace$y <- y[keep]
      if (!is.null(trace$text)) {
        trace$text <- unlist(trace$text)[keep]
      }
    }

    trace_mode <- if (is.null(trace$mode)) "" else trace$mode
    if (grepl("lines", trace_mode, fixed = TRUE) && length(trace$x) > 0) {
      trace$mode <- "lines+markers"
      trace$marker <- list(size = 4)
    }

    trace
  })

  shown_legend_groups <- character(0)
  for (i in seq_along(px$x$data)) {
    trace <- px$x$data[[i]]
    group <- trace$legendgroup
    if (!is.null(group) && nzchar(group)) {
      if (group %in% shown_legend_groups) {
        trace$showlegend <- FALSE
      } else {
        trace$showlegend <- TRUE
        shown_legend_groups <- c(shown_legend_groups, group)
      }
      px$x$data[[i]] <- trace
    }
  }

  px |>
    plotly::layout(
      hovermode = "closest",
      legend = list(
        orientation = "v",
        x = 1.02,
        y = 1,
        xanchor = "left",
        yanchor = "top"
      )
    )
}

save_interactive_png <- function(
    plot,
    path,
    width = 960,
    height = 720,
    zoom = 2
) {
  if (
    !requireNamespace("webshot2", quietly = TRUE) ||
      !requireNamespace("htmlwidgets", quietly = TRUE)
  ) {
    ggplot2::ggsave(
      path,
      plot,
      width = width / 150,
      height = height / 150,
      dpi = 150
    )
    return(invisible(path))
  }

  px <- as_interactive(plot) |>
    plotly::config(displayModeBar = FALSE, displaylogo = FALSE)

  tmp_dir <- tempfile(pattern = "plotly_widget_")
  dir.create(tmp_dir)
  on.exit(unlink(tmp_dir, recursive = TRUE), add = TRUE)

  html_path <- file.path(tmp_dir, "chart.html")
  htmlwidgets::saveWidget(px, html_path, selfcontained = FALSE)
  webshot2::webshot(
    html_path,
    path,
    vwidth = width,
    vheight = height,
    zoom = zoom
  )
  invisible(path)
}

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
