# Angle 2: Interactive finish mix dashboard (standalone HTML app)

plot_finish_donut <- function(shared, n_fights) {
  plotly::plot_ly(
    shared,
    labels = ~finish_type,
    values = ~weight,
    type = "pie",
    hole = 0.45,
    textinfo = "label+percent",
    textposition = "outside",
    sort = FALSE,
    marker = list(
      colors = unname(FINISH_COLORS),
      line = list(color = "#FFFFFF", width = 1)
    ),
    hovertemplate = "<b>%{label}</b><br>%{percent}<extra></extra>"
  ) |>
    plotly::layout(
      title = list(
        text = paste0("Finish mix<br><sup>", scales::comma(n_fights), " fights</sup>"),
        x = 0.5,
        xanchor = "center"
      ),
      showlegend = TRUE,
      legend = list(orientation = "h", y = -0.1),
      margin = list(t = 80, b = 40, l = 20, r = 20)
    ) |>
    plotly::config(displayModeBar = FALSE, displaylogo = FALSE)
}

build_finish_dashboard <- function(
    fights,
    min_year = 2000,
    max_year = 2026
) {
  fight_details <- prepare_fight_details(fights, min_year = min_year)
  n_fights <- nrow(fight_details)

  year_min <- max(min_year, min(fight_details$year, na.rm = TRUE))
  year_max <- min(max_year, max(fight_details$year, na.rm = TRUE))

  shared <- crosstalk::SharedData$new(
    fight_details,
    key = ~fight_url,
    group = "finish_dash"
  )

  donut <- plot_finish_donut(shared, n_fights)

  table <- DT::datatable(
    shared,
    escape = FALSE,
    rownames = FALSE,
    filter = "top",
    extensions = "Scroller",
    colnames = c(
      "URL key" = "fight_url",
      "Date" = "fight_date",
      "Year" = "year",
      "Event" = "event_name",
      "Fighter 1" = "f1_name",
      "Fighter 2" = "f2_name",
      "Winner" = "winner",
      "Division" = "weight_class",
      "Outcome" = "finish_type",
      "Method" = "method",
      "Round" = "round",
      "Time" = "time",
      "Location" = "location",
      "Referee" = "referee",
      "Judging" = "judging_details",
      "Link" = "stats_link",
      "Weight" = "weight"
    ),
    options = list(
      pageLength = 15,
      scrollX = TRUE,
      scroller = TRUE,
      scrollY = 420,
      deferRender = TRUE,
      columnDefs = list(
        list(visible = FALSE, targets = 0),
        list(visible = FALSE, targets = 16)
      )
    )
  )

  htmltools::tagList(
    htmltools::tags$style(htmltools::HTML("
      .finish-dashboard { margin: 1.25em 0 2em; }
      .finish-dashboard .crosstalk-input { margin-bottom: 0.75em; }
      .finish-dashboard .plotly, .finish-dashboard .datatables {
        margin-top: 0.5em;
      }
      .finish-dashboard .event-filter .selectize-control {
        min-width: 100%;
      }
    ")),
    htmltools::tags$div(
      class = "finish-dashboard",
      crosstalk::bscols(
        widths = c(3, 3, 3, 3),
        crosstalk::filter_slider(
          "year_range",
          "Year range",
          shared,
          ~year,
          min = year_min,
          max = year_max,
          step = 1,
          sep = ""
        ),
        crosstalk::filter_select(
          "year_pick",
          "Years",
          shared,
          ~year,
          multiple = TRUE
        ),
        crosstalk::filter_select(
          "finish_type",
          "Outcome",
          shared,
          ~finish_type,
          multiple = TRUE
        ),
        crosstalk::filter_select(
          "weight_class",
          "Division",
          shared,
          ~weight_class,
          multiple = TRUE
        )
      ),
      htmltools::tags$div(
        class = "event-filter",
        crosstalk::filter_select(
          "event_name",
          "Event",
          shared,
          ~event_name,
          multiple = TRUE
        )
      ),
      htmltools::tags$br(),
      crosstalk::bscols(
        widths = c(4, 8),
        donut,
        table
      )
    )
  )
}

save_finish_dashboard <- function(
    fights,
    output_path = "output/_widget/finish_dashboard.html"
) {
  widget_dir <- dirname(output_path)
  dir.create(widget_dir, recursive = TRUE, showWarnings = FALSE)

  lib_dir_name <- "finish_dashboard_files"
  lib_dir <- file.path(widget_dir, lib_dir_name)

  plotly_deps <- htmltools::findDependencies(
    plotly::plot_ly(
      labels = "KO/TKO",
      values = 1,
      type = "pie"
    )
  )

  dashboard_body <- build_finish_dashboard(fights)

  page <- htmltools::attachDependencies(
    htmltools::tags$html(
      htmltools::tags$head(
        htmltools::tags$meta(charset = "utf-8"),
        htmltools::tags$title("UFC finish mix dashboard"),
        htmltools::tags$meta(
          name = "viewport",
          content = "width=device-width, initial-scale=1"
        ),
        htmltools::tags$style(htmltools::HTML("
          body {
            font-family: system-ui, -apple-system, sans-serif;
            max-width: 1400px;
            margin: 0 auto;
            padding: 1.5em;
            color: #222;
          }
          h1 { font-size: 1.5rem; margin-bottom: 0.25em; }
          .page-subtitle { color: #666; margin: 0 0 1.5em; }
        "))
      ),
      htmltools::tags$body(
        htmltools::tags$h1("UFC finish mix"),
        htmltools::tags$p(
          class = "page-subtitle",
          "Filter by year, event, outcome, and division. The donut and fight table update together."
        ),
        dashboard_body,
        htmltools::tags$p(
          htmltools::tags$small(DATA_SOURCE_CAPTION)
        )
      )
    ),
    plotly_deps,
    append = FALSE
  )

  htmltools::save_html(page, file = output_path, libdir = lib_dir_name)
  dir.create(lib_dir, recursive = TRUE, showWarnings = FALSE)

  invisible(normalizePath(output_path, winslash = "/"))
}
