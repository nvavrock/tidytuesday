# Angle 2: Interactive finish mix dashboard (standalone HTML app)

division_donut_colors <- function(divisions) {
  divisions <- as.character(divisions)
  stats::setNames(
    WEIGHT_CLASS_PALETTE[
      (seq_along(divisions) - 1) %% length(WEIGHT_CLASS_PALETTE) + 1
    ],
    divisions
  )
}

donut_mount <- function(id) {
  htmltools::tags$div(
    id = id,
    class = "finish-donut",
    style = "width:100%;height:340px;"
  )
}

donut_gray_btn <- function(id, label) {
  htmltools::tags$button(
    type = "button",
    id = id,
    class = "donut-gray-btn",
    label
  )
}

build_fight_index <- function(fight_details) {
  fight_details |>
    dplyr::transmute(
      key = fight_url,
      finish_type = as.character(finish_type),
      weight_class = as.character(weight_class),
      is_womens = grepl("^Women's ", as.character(weight_class))
    )
}

build_division_colors <- function(fight_details) {
  men_levels <- MENS_WEIGHT_CLASS_LEVELS[
    MENS_WEIGHT_CLASS_LEVELS %in% as.character(fight_details$weight_class)
  ]
  women_levels <- WOMENS_DIVISION_LABELS[
    paste0("Women's ", WOMENS_DIVISION_LABELS) %in%
      as.character(fight_details$weight_class)
  ]

  list(
    men_order = unname(men_levels),
    women_order = unname(women_levels),
    men = as.list(division_donut_colors(men_levels)),
    women = as.list(division_donut_colors(women_levels))
  )
}

build_finish_dashboard <- function(fights, min_year = NULL) {
  year_floor <- if (is.null(min_year)) {
    min(fights$year, na.rm = TRUE)
  } else {
    min_year
  }

  fight_details <- prepare_fight_details(fights, min_year = year_floor)

  year_levels <- sort(unique(fight_details$year), decreasing = TRUE)

  fight_details <- fight_details |>
    dplyr::mutate(
      year = factor(
        as.character(year),
        levels = as.character(year_levels),
        ordered = TRUE
      )
    )

  shared <- crosstalk::SharedData$new(
    fight_details,
    key = ~fight_url,
    group = "finish_dash"
  )

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
      "Link" = "stats_link"
    ),
    options = list(
      pageLength = 15,
      scrollX = TRUE,
      scroller = TRUE,
      scrollY = 420,
      deferRender = TRUE,
      columnDefs = list(
        list(visible = FALSE, targets = 0)
      )
    )
  )

  htmltools::tagList(
    htmltools::tags$script(
      id = "fight-index",
      type = "application/json",
      htmltools::HTML(jsonlite::toJSON(build_fight_index(fight_details), dataframe = "rows"))
    ),
    htmltools::tags$script(
      id = "finish-colors",
      type = "application/json",
      htmltools::HTML(jsonlite::toJSON(as.list(FINISH_COLORS), auto_unbox = TRUE))
    ),
    htmltools::tags$script(
      id = "division-colors",
      type = "application/json",
      htmltools::HTML(
        jsonlite::toJSON(build_division_colors(fight_details), auto_unbox = TRUE)
      )
    ),
    htmltools::tags$style(htmltools::HTML("
      .finish-dashboard { margin: 1.25em 0 2em; }
      .finish-dashboard .crosstalk-input { margin-bottom: 0.75em; }
      .finish-dashboard .datatables { margin-top: 0.5em; }
      .finish-dashboard .event-filter .selectize-control {
        min-width: 100%;
      }
      .finish-dashboard .finish-donut {
        margin-top: 0.5em;
      }
      .finish-dashboard .donut-hint {
        color: #666;
        font-size: 0.9rem;
        margin: 0.25em 0 0.75em;
      }
      .finish-dashboard .donut-row {
        display: flex;
        gap: 0;
      }
      .finish-dashboard .donut-col {
        flex: 1;
        min-width: 0;
      }
      .finish-dashboard .donut-gray-btn {
        display: block;
        margin: 0.35em auto 0;
        font-size: 0.85rem;
        padding: 0.2em 0.6em;
        cursor: pointer;
      }
      .finish-dashboard .donut-gray-btn.is-active {
        background: #374151;
        color: #fff;
        border-color: #374151;
      }
      .finish-dashboard #clear-donut-selection:disabled,
      .finish-dashboard #submit-donut-selection:disabled {
        opacity: 0.45;
        cursor: default;
      }
    ")),
    htmltools::tags$div(
      class = "finish-dashboard",
      crosstalk::bscols(
        widths = c(4, 8),
        crosstalk::filter_select(
          "year_pick",
          "Years",
          shared,
          ~year,
          multiple = TRUE
        ),
        crosstalk::filter_select(
          "event_name",
          "Event",
          shared,
          ~event_name,
          multiple = TRUE
        )
      ),
      htmltools::tags$p(
        class = "donut-hint",
        "Click slices to select (Qlik-style: multi-select within one donut). Click again to toggle off; double-click to clear. Selected slices stay full color; others turn gray. Press Submit selection to rescale each donut to selected slices only (100%)."
      ),
      htmltools::tags$div(
        style = "display:flex;align-items:center;gap:1rem;margin:0 0 0.75em;flex-wrap:wrap;",
        htmltools::tags$div(
          id = "active-count",
          style = "color:#666;font-size:0.9rem;",
          "Active fights: (loading...)"
        ),
        htmltools::tags$button(
          type = "button",
          id = "submit-donut-selection",
          style = "font-size:0.85rem;padding:0.2em 0.6em;cursor:pointer;",
          disabled = TRUE,
          "Submit selection"
        ),
        htmltools::tags$button(
          type = "button",
          id = "clear-donut-selection",
          style = "font-size:0.85rem;padding:0.2em 0.6em;cursor:pointer;",
          disabled = TRUE,
          "Clear donut selection"
        )
      ),
      htmltools::tags$div(
        class = "donut-row",
        htmltools::tags$div(
          class = "donut-col",
          donut_mount("donut-outcome")
        ),
        htmltools::tags$div(
          class = "donut-col",
          donut_mount("donut-men"),
          donut_gray_btn("gray-out-donut-men", "Gray out men's")
        ),
        htmltools::tags$div(
          id = "donut-women-wrap",
          class = "donut-col donut-col-women",
          donut_mount("donut-women"),
          donut_gray_btn("gray-out-donut-women", "Gray out women's")
        )
      ),
      table
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
  dir.create(lib_dir, recursive = TRUE, showWarnings = FALSE)

  js_src <- "R/finish_dashboard_donut.js"

  plotly_deps <- htmltools::findDependencies(
    plotly::plot_ly(
      labels = "KO/TKO",
      values = 1,
      type = "pie"
    )
  )

  dashboard_body <- build_finish_dashboard(fights, min_year = 2020)

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
          "Filter by year, event, outcome, and division — or click a donut slice. The charts and fight table update together."
        ),
        dashboard_body,
        htmltools::tags$p(
          htmltools::tags$small(DATA_SOURCE_CAPTION)
        ),
        htmltools::tags$script(src = paste0(lib_dir_name, "/finish_dashboard_donut.js"))
      )
    ),
    plotly_deps,
    append = FALSE
  )

  htmltools::save_html(page, file = output_path, libdir = lib_dir_name)
  file.copy(js_src, file.path(lib_dir, "finish_dashboard_donut.js"), overwrite = TRUE)

  invisible(normalizePath(output_path, winslash = "/"))
}
