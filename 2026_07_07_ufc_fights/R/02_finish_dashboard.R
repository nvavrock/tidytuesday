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
    class = "finish-donut"
  )
}

donut_gray_btn <- function(id, label) {
  htmltools::tags$button(
    type = "button",
    id = id,
    class = "donut-gray-btn btn-pill",
    label
  )
}

build_weight_class_modal <- function() {
  scales <- weight_class_scales()
  render_table <- function(rows) {
  htmltools::tags$table(
      class = "wc-modal-table",
      htmltools::tags$thead(
        htmltools::tags$tr(
          htmltools::tags$th("Division"),
          htmltools::tags$th("Limit")
        )
      ),
      htmltools::tags$tbody(
        lapply(seq_len(nrow(rows)), function(i) {
          label <- if (rows$gender[i] == "Women") {
            paste0("Women's ", rows$division[i])
          } else {
            rows$division[i]
          }
          htmltools::tags$tr(
            htmltools::tags$td(label),
            htmltools::tags$td(paste0("\u2264 ", rows$limit_lb[i], " lb"))
          )
        })
      )
    )
  }

  htmltools::tagList(
    htmltools::tags$div(
      id = "weight-class-modal",
      class = "wc-modal",
      `aria-hidden` = "true",
      htmltools::tags$div(class = "wc-modal-backdrop", `data-close-modal` = "true"),
      htmltools::tags$div(
        class = "wc-modal-panel",
        role = "dialog",
        `aria-modal` = "true",
        `aria-labelledby` = "weight-class-modal-title",
        htmltools::tags$button(
          type = "button",
          class = "wc-modal-close",
          `aria-label` = "Close",
          "\u00d7"
        ),
        htmltools::tags$h2(id = "weight-class-modal-title", "UFC weight class limits"),
        htmltools::tags$p(
          class = "wc-modal-note",
          "Upper limits in pounds. Catch, super heavyweight, and open-weight bouts are excluded."
        ),
        htmltools::tags$h3(class = "wc-modal-section", "Men"),
        render_table(dplyr::filter(scales, gender == "Men")),
        htmltools::tags$h3(class = "wc-modal-section", "Women"),
        render_table(dplyr::filter(scales, gender == "Women"))
      )
    )
  )
}

build_fight_index <- function(fight_details) {
  fight_details |>
    dplyr::transmute(
      key = fight_url,
      year = as.character(year),
      fight_date = as.character(fight_date),
      event_name = as.character(event_name),
      finish_type = as.character(finish_type),
      weight_class = as.character(weight_class),
      is_womens = grepl("^Women's ", as.character(weight_class)),
      is_title_fight = is_title_fight %in% TRUE
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

outcome_column_render_js <- function() {
  colors_json <- jsonlite::toJSON(as.list(FINISH_COLORS), auto_unbox = TRUE)
  htmlwidgets::JS(sprintf(
    "function(data, type, row, meta) {
      if (type !== 'display' || !data) return data;
      var colors = %s;
      var color = colors[data] || '#6D5B4B';
      return '<span class=\"outcome-cell\">' +
        '<span class=\"outcome-dot\" style=\"background:' + color + '\"></span>' +
        data + '</span>';
    }",
    colors_json
  ))
}

dashboard_css <- function() {
  th <- DASH_THEME
  paste0(
    sprintf(
    "
      .finish-dashboard { margin: 0; }
      .finish-dashboard .filter-deck {
        background: %s;
        border: 1px solid %s;
        border-top: 3px solid %s;
        border-radius: 8px;
        padding: 1rem 1.25rem;
        margin-bottom: 1.25rem;
      }
      .finish-dashboard .filter-deck-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 1rem;
        margin-bottom: 0.75rem;
        flex-wrap: wrap;
      }
      .finish-dashboard .filter-deck-title {
        font-family: 'Barlow Condensed', sans-serif;
        font-size: 0.85rem;
        font-weight: 600;
        letter-spacing: 0.08em;
        text-transform: uppercase;
        color: %s;
        margin: 0;
      }
      .finish-dashboard .btn-clear-filters {
        background: transparent;
        border: 1px solid %s;
        color: %s;
        font-size: 0.85rem;
        padding: 0.35em 0.85em;
        min-height: 36px;
        border-radius: 4px;
        cursor: pointer;
      }
      .finish-dashboard .btn-clear-filters:hover {
        border-color: %s;
        color: %s;
      }
      .finish-dashboard .crosstalk-input { margin-bottom: 0.5em; }
      .finish-dashboard .crosstalk-input > label {
        color: %s;
        font-family: 'Barlow Condensed', sans-serif;
        font-size: 0.8rem;
        letter-spacing: 0.06em;
        text-transform: uppercase;
      }
      .finish-dashboard .selectize-control.single .selectize-input,
      .finish-dashboard .selectize-control.multi .selectize-input {
        background: %s;
        border-color: %s;
        color: %s;
      }
      .finish-dashboard .selectize-dropdown {
        background: %s;
        border-color: %s;
        color: %s;
      }
      .finish-dashboard .selectize-dropdown .option {
        color: %s;
      }
      .finish-dashboard .selectize-dropdown .active {
        background: %s;
        color: #fff;
      }
      .finish-dashboard .selectize-input .item {
        background: %s;
        border-color: %s;
        color: #fff;
      }
      .finish-dashboard .donut-hint {
        color: %s;
        font-size: 0.9rem;
        margin: 0 0 0.75em;
      }
      .finish-dashboard .filter-details {
        color: %s;
        font-size: 0.85rem;
        margin: 0 0 1em;
      }
      .finish-dashboard .filter-details summary {
        cursor: pointer;
        color: %s;
      }
      .finish-dashboard .donut-toolbar {
        display: flex;
        align-items: center;
        gap: 0.75rem;
        margin: 0 0 1em;
        flex-wrap: wrap;
      }
      .finish-dashboard .btn-primary {
        background: %s;
        border: 1px solid %s;
        color: #fff;
        font-family: 'Barlow Condensed', sans-serif;
        font-size: 0.9rem;
        font-weight: 600;
        letter-spacing: 0.04em;
        text-transform: uppercase;
        padding: 0.4em 1em;
        min-height: 36px;
        border-radius: 4px;
        cursor: pointer;
      }
      .finish-dashboard .btn-primary:hover:not(:disabled) {
        filter: brightness(1.1);
      }
      .finish-dashboard .btn-ghost {
        background: transparent;
        border: 1px solid %s;
        color: %s;
        font-family: 'Barlow Condensed', sans-serif;
        font-size: 0.9rem;
        font-weight: 600;
        letter-spacing: 0.04em;
        text-transform: uppercase;
        padding: 0.4em 1em;
        min-height: 36px;
        border-radius: 4px;
        cursor: pointer;
      }
      .finish-dashboard .btn-ghost:hover:not(:disabled) {
        border-color: %s;
        color: %s;
      }
      .finish-dashboard .btn-pill {
        background: transparent;
        border: 1px solid %s;
        color: %s;
        font-size: 0.8rem;
        padding: 0.35em 0.75em;
        min-height: 32px;
        border-radius: 999px;
        cursor: pointer;
      }
      .finish-dashboard .donut-gray-btn.is-active {
        background: %s;
        border-color: %s;
        color: #fff;
      }
      .finish-dashboard #clear-donut-selection:disabled,
      .finish-dashboard #submit-donut-selection:disabled,
      .finish-dashboard .btn-clear-filters:disabled {
        opacity: 0.45;
        cursor: default;
      }
      .finish-dashboard .donut-row {
        display: flex;
        gap: 0.75rem;
        margin-bottom: 1.25rem;
      }
      .finish-dashboard .donut-col {
        flex: 1;
        min-width: 0;
        background: %s;
        border: 1px solid %s;
        border-radius: 8px;
        padding: 0.5rem 0.25rem 0.75rem;
      }
      .finish-dashboard .finish-donut {
        width: 100%%;
        height: 380px;
        margin-top: 0.25em;
        overflow: visible;
      }
      .finish-dashboard .finish-donut .js-plotly-plot,
      .finish-dashboard .finish-donut .plot-container {
        overflow: visible !important;
      }
      .finish-dashboard .finish-donut .g-gtitle {
        transform: translateY(-5px);
      }
      .finish-dashboard .donut-gray-btn {
        display: block;
        margin: 0.5em auto 0;
      }
      .finish-dashboard #event_name .selectize-input {
        display: flex;
        flex-direction: column;
        align-items: stretch;
        height: auto;
        min-height: 38px;
      }
      .finish-dashboard #event_name .selectize-input .item {
        width: 100%%;
        max-width: 100%%;
        box-sizing: border-box;
        margin: 2px 0;
        white-space: normal;
      }
      .finish-dashboard #event_name .selectize-input > input {
        width: 100%% !important;
        order: 999;
        margin-top: 2px;
      }
      .finish-dashboard .table-panel {
        background: %s;
        border: 1px solid %s;
        border-radius: 8px;
        padding: 0.75rem;
        overflow-x: auto;
      }
      .finish-dashboard .table-panel-title {
        font-family: 'Barlow Condensed', sans-serif;
        font-size: 0.85rem;
        font-weight: 600;
        letter-spacing: 0.08em;
        text-transform: uppercase;
        color: %s;
        margin: 0 0 0.75rem;
      }
      .finish-dashboard .datatables { margin-top: 0; }
      .finish-dashboard table.dataTable {
        color: %s;
        border-color: %s !important;
      }
      .finish-dashboard table.dataTable thead th {
        background: %s !important;
        color: %s !important;
        border-color: %s !important;
        font-family: 'Barlow Condensed', sans-serif;
        font-size: 0.8rem;
        letter-spacing: 0.05em;
        text-transform: uppercase;
      }
      .finish-dashboard table.dataTable tbody tr {
        background: %s !important;
      }
      .finish-dashboard table.dataTable tbody tr:nth-child(even) {
        background: #18181C !important;
      }
      .finish-dashboard table.dataTable tbody tr:hover {
        background: #1E1E24 !important;
      }
      .finish-dashboard table.dataTable tbody td {
        border-color: %s !important;
        color: %s;
      }
      .finish-dashboard table.dataTable input,
      .finish-dashboard table.dataTable select {
        background: %s;
        border: 1px solid %s;
        color: %s;
      }
      .finish-dashboard .dataTables_info,
      .finish-dashboard .dataTables_length label,
      .finish-dashboard .dataTables_filter label {
        color: %s !important;
      }
      .finish-dashboard .dataTables_paginate .paginate_button {
        color: %s !important;
      }
      .finish-dashboard .dataTables_paginate .paginate_button.current {
        background: %s !important;
        border-color: %s !important;
        color: #fff !important;
      }
      .finish-dashboard .outcome-cell {
        display: inline-flex;
        align-items: center;
        gap: 0.4em;
      }
      .finish-dashboard .outcome-dot {
        width: 8px;
        height: 8px;
        border-radius: 50%%;
        flex-shrink: 0;
      }
      .finish-dashboard #active-count {
        display: none;
      }
    ",
    th$surface, th$border, th$accent,
    th$accent_gold,
    th$border, th$text_muted,
    th$accent, th$accent_gold,
    th$text_muted,
    th$bg, th$border, th$text,
    th$surface, th$border, th$text,
    th$text,
    th$accent,
    th$border, th$text_muted,
    th$text_muted,
    th$text_muted, th$accent_gold,
    th$accent, th$accent,
    th$border, th$text,
    th$accent, th$text,
    th$border, th$text_muted,
    th$dimmed, th$border,
    th$surface, th$border,
    th$surface, th$border,
    th$accent_gold,
    th$text, th$border,
    th$bg, th$text_muted, th$border,
    th$surface,
    th$border, th$text,
    th$bg, th$border, th$text,
    th$text_muted,
    th$text_muted,
    th$accent, th$accent
  ),
    sprintf(
      "
      .finish-dashboard .gender-toggles {
        display: inline-flex;
        align-items: center;
        gap: 0.35rem;
        margin-right: 0.25rem;
      }
      .finish-dashboard .gender-toggles-label {
        font-family: 'Barlow Condensed', sans-serif;
        font-size: 0.8rem;
        font-weight: 600;
        letter-spacing: 0.06em;
        text-transform: uppercase;
        color: %s;
        margin-right: 0.15rem;
      }
      .finish-dashboard .gender-toggle {
        background: transparent;
        border: 1px solid %s;
        color: %s;
        font-family: 'Barlow Condensed', sans-serif;
        font-size: 0.85rem;
        font-weight: 600;
        letter-spacing: 0.04em;
        text-transform: uppercase;
        padding: 0.35em 0.85em;
        min-height: 32px;
        border-radius: 999px;
        cursor: pointer;
      }
      .finish-dashboard .gender-toggle:hover:not(.is-on) {
        border-color: %s;
        color: %s;
      }
      .finish-dashboard .gender-toggle.is-on {
        background: %s;
        border-color: %s;
        color: #fff;
      }
    ",
      th$text_muted,
      th$border, th$text,
      th$accent, th$text,
      th$accent, th$accent
    )
  )
}

page_css <- function() {
  th <- DASH_THEME
  sprintf(
    "
      body {
        font-family: system-ui, -apple-system, sans-serif;
        max-width: 1400px;
        margin: 0 auto;
        padding: 1.5em;
        color: %s;
        background: %s;
      }
      h1 {
        font-family: 'Barlow Condensed', sans-serif;
        font-size: 2.25rem;
        font-weight: 700;
        letter-spacing: 0.02em;
        text-transform: uppercase;
        margin-bottom: 0.15em;
        color: #F5F5F5;
      }
      .page-subtitle {
        color: %s;
        margin: 0 0 1.25em;
        font-size: 0.95rem;
      }
      .page-caption {
        color: %s;
        margin-top: 1.5em;
      }
      .hero-stats {
        display: flex;
        gap: 0.75rem;
        flex-wrap: wrap;
        margin-bottom: 1.5rem;
      }
      .stat-chip {
        background: %s;
        border: 1px solid %s;
        border-left: 3px solid %s;
        border-radius: 6px;
        padding: 0.65rem 1rem;
        min-width: 120px;
      }
      .stat-chip:nth-child(2) { border-left-color: %s; }
      .stat-chip:nth-child(3) { border-left-color: %s; }
      .stat-chip:nth-child(4) { border-left-color: %s; }
      .stat-label {
        display: block;
        font-family: 'Barlow Condensed', sans-serif;
        font-size: 0.75rem;
        font-weight: 600;
        letter-spacing: 0.08em;
        text-transform: uppercase;
        color: %s;
        margin-bottom: 0.15em;
      }
      .stat-value {
        display: block;
        font-family: 'Barlow Condensed', sans-serif;
        font-size: 1.5rem;
        font-weight: 700;
        color: #F5F5F5;
        line-height: 1.1;
      }
      .filter-deck-actions {
        display: flex;
        align-items: center;
        gap: 0.5rem;
        flex-wrap: wrap;
      }
      .btn-weight-limits {
        background: transparent;
        border: 1px solid %s;
        color: %s;
        font-family: 'Barlow Condensed', sans-serif;
        font-size: 0.85rem;
        font-weight: 600;
        letter-spacing: 0.04em;
        text-transform: uppercase;
        padding: 0.35em 0.85em;
        min-height: 36px;
        border-radius: 4px;
        cursor: pointer;
      }
      .btn-weight-limits:hover {
        border-color: %s;
        color: %s;
      }
      .wc-modal {
        display: none;
        position: fixed;
        inset: 0;
        z-index: 1000;
        align-items: center;
        justify-content: center;
        padding: 1rem;
      }
      .wc-modal.is-open {
        display: flex;
      }
      .wc-modal-backdrop {
        position: absolute;
        inset: 0;
        background: rgba(0, 0, 0, 0.72);
      }
      .wc-modal-panel {
        position: relative;
        width: min(100%%, 520px);
        max-height: min(88vh, 720px);
        overflow: auto;
        background: %s;
        border: 1px solid %s;
        border-top: 3px solid %s;
        border-radius: 8px;
        padding: 1.25rem 1.35rem 1.5rem;
        color: %s;
        box-shadow: 0 18px 48px rgba(0, 0, 0, 0.45);
      }
      .wc-modal-panel h2 {
        font-family: 'Barlow Condensed', sans-serif;
        font-size: 1.35rem;
        font-weight: 700;
        letter-spacing: 0.04em;
        text-transform: uppercase;
        margin: 0 2rem 0.35rem 0;
        color: #F5F5F5;
      }
      .wc-modal-section {
        font-family: 'Barlow Condensed', sans-serif;
        font-size: 0.95rem;
        font-weight: 600;
        letter-spacing: 0.06em;
        text-transform: uppercase;
        color: %s;
        margin: 1rem 0 0.45rem;
      }
      .wc-modal-note {
        color: %s;
        font-size: 0.85rem;
        margin: 0 0 0.5rem;
      }
      .wc-modal-close {
        position: absolute;
        top: 0.65rem;
        right: 0.75rem;
        border: 0;
        background: transparent;
        color: %s;
        font-size: 1.75rem;
        line-height: 1;
        cursor: pointer;
        padding: 0.15rem 0.35rem;
      }
      .wc-modal-close:hover {
        color: #F5F5F5;
      }
      .wc-modal-table {
        width: 100%%;
        border-collapse: collapse;
        font-size: 0.92rem;
      }
      .wc-modal-table th,
      .wc-modal-table td {
        padding: 0.45rem 0.55rem;
        border-bottom: 1px solid %s;
        text-align: left;
      }
      .wc-modal-table th {
        font-family: 'Barlow Condensed', sans-serif;
        font-size: 0.78rem;
        font-weight: 600;
        letter-spacing: 0.06em;
        text-transform: uppercase;
        color: %s;
      }
      .wc-modal-table tr:last-child td {
        border-bottom: 0;
      }
    ",
    th$text, th$bg,
    th$text_muted,
    th$text_muted,
    th$surface, th$border, th$accent,
    FINISH_COLORS[["KO/TKO"]],
    FINISH_COLORS[["Submission"]],
    FINISH_COLORS[["Decision"]],
    th$text_muted,
    th$border, th$text,
    th$accent, th$text,
    th$surface, th$border, th$accent, th$text,
    th$accent_gold,
    th$text_muted,
    th$text_muted,
    th$border,
    th$text_muted
  )
}

build_finish_dashboard <- function(fights, min_year = NULL, ultimate = NULL) {
  year_floor <- if (is.null(min_year)) {
    min(fights$year, na.rm = TRUE)
  } else {
    min_year
  }

  fight_details <- fights |>
    attach_title_bouts(ultimate = ultimate) |>
    prepare_fight_details(min_year = year_floor)

  year_levels <- sort(unique(fight_details$year), decreasing = TRUE)

  fight_index_rows <- build_fight_index(fight_details)

  fight_details <- fight_details |>
    dplyr::mutate(
      year = factor(
        as.character(year),
        levels = as.character(year_levels),
        ordered = TRUE
      ),
      event_display = paste0(
        as.character(event_name),
        " (",
        as.character(fight_date),
        ")"
      ),
      loser = dplyr::case_when(
        !is.na(winner) & winner == f1_name ~ f2_name,
        !is.na(winner) & winner == f2_name ~ f1_name,
        TRUE ~ NA_character_
      )
    ) |>
    dplyr::select(
      fight_url,
      fight_date,
      year,
      event_name,
      event_display,
      winner,
      loser,
      weight_class,
      finish_type,
      method,
      judging_details,
      round,
      time,
      location,
      referee,
      stats_link
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
    class = "cell-border stripe hover row-border",
    colnames = c(
      "URL key" = "fight_url",
      "Date" = "fight_date",
      "Year" = "year",
      "Event key" = "event_name",
      "Event" = "event_display",
      "Winner" = "winner",
      "Loser" = "loser",
      "Division" = "weight_class",
      "Outcome" = "finish_type",
      "Method" = "method",
      "Judging" = "judging_details",
      "Round" = "round",
      "Time" = "time",
      "Location" = "location",
      "Referee" = "referee",
      "Link" = "stats_link"
    ),
    options = list(
      pageLength = 15,
      scrollX = TRUE,
      scroller = TRUE,
      scrollY = 420,
      deferRender = TRUE,
      columnDefs = list(
        list(visible = FALSE, targets = c(0, 1, 2, 3)),
        list(
          targets = 8L,
          render = outcome_column_render_js()
        )
      )
    )
  )

  htmltools::tagList(
    htmltools::tags$script(
      id = "fight-index",
      type = "application/json",
      htmltools::HTML(jsonlite::toJSON(fight_index_rows, dataframe = "rows"))
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
    htmltools::tags$script(
      id = "dash-theme",
      type = "application/json",
      htmltools::HTML(jsonlite::toJSON(DASH_THEME, auto_unbox = TRUE))
    ),
    htmltools::tags$style(htmltools::HTML(dashboard_css())),
    htmltools::tags$div(
      class = "finish-dashboard",
      htmltools::tags$div(
        class = "filter-deck",
        htmltools::tags$div(
          class = "filter-deck-header",
          htmltools::tags$p(class = "filter-deck-title", "Filters"),
          htmltools::tags$div(
            class = "filter-deck-actions",
            htmltools::tags$button(
              type = "button",
              id = "open-weight-class-scales",
              class = "btn-weight-limits",
              "Weight limits"
            ),
            htmltools::tags$button(
              type = "button",
              id = "clear-external-filters",
              class = "btn-clear-filters",
              "Clear filters"
            )
          )
        ),
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
        )
      ),
      htmltools::tags$p(
        class = "donut-hint",
        "Click donut slices to filter — charts and table update together."
      ),
      htmltools::tags$details(
        class = "filter-details",
        htmltools::tags$summary("How filtering works"),
        htmltools::tags$p(
          "Multi-select within one donut (Qlik-style): click to toggle slices; double-click to clear. ",
          "Selected slices stay full color; others dim. ",
          "Apply slices rescales each donut to the selection (100%). ",
          "Use Men / Women toggles to include or exclude each gender from division donuts and the fight log. ",
          "Title fights limits the dashboard to championship bouts only."
        )
      ),
      htmltools::tags$div(
        class = "donut-toolbar",
        htmltools::tags$div(
          class = "gender-toggles",
          htmltools::tags$span(class = "gender-toggles-label", "Show"),
          htmltools::tags$button(
            type = "button",
            id = "toggle-men",
            class = "gender-toggle is-on",
            `aria-pressed` = "true",
            "Men"
          ),
          htmltools::tags$button(
            type = "button",
            id = "toggle-women",
            class = "gender-toggle is-on",
            `aria-pressed` = "true",
            "Women"
          ),
          htmltools::tags$button(
            type = "button",
            id = "toggle-title-fights",
            class = "gender-toggle",
            `aria-pressed` = "false",
            "Title fights"
          )
        ),
        htmltools::tags$div(
          id = "active-count",
          "Active fights: (loading...)"
        ),
        htmltools::tags$button(
          type = "button",
          id = "submit-donut-selection",
          class = "btn-primary",
          disabled = TRUE,
          "Apply slices"
        ),
        htmltools::tags$button(
          type = "button",
          id = "clear-donut-selection",
          class = "btn-ghost",
          disabled = TRUE,
          "Reset slices"
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
          donut_mount("donut-men")
        ),
        htmltools::tags$div(
          id = "donut-women-wrap",
          class = "donut-col donut-col-women",
          donut_mount("donut-women")
        )
      ),
      htmltools::tags$div(
        class = "table-panel",
        htmltools::tags$p(class = "table-panel-title", "Fight log"),
        table
      )
    )
  )
}

dashboard_og_tags <- function() {
  base <- "https://nvavrock.github.io/tidytuesday/2026_07_07_ufc_fights"
  htmltools::tagList(
    htmltools::tags$meta(
      name = "description",
      content = paste(
        "Interactive UFC finish dashboard: filter by year, event, outcome,",
        "division, Men/Women, and title fights. Linked donuts and fight log."
      )
    ),
    htmltools::tags$meta(property = "og:type", content = "website"),
    htmltools::tags$meta(property = "og:title", content = "UFC finish breakdown"),
    htmltools::tags$meta(
      property = "og:description",
      content = paste(
        "Filter UFC finishes by year, event, outcome, division, Men/Women,",
        "and title fights. Linked donuts and searchable fight log, 2020–2026."
      )
    ),
    htmltools::tags$meta(
      property = "og:url",
      content = paste0(base, "/output/_widget/finish_dashboard.html")
    ),
    htmltools::tags$meta(
      property = "og:image",
      content = paste0(base, "/output/05_finish_dashboard_donuts.png")
    ),
    htmltools::tags$meta(property = "og:image:width", content = "1500"),
    htmltools::tags$meta(property = "og:image:height", content = "900"),
    htmltools::tags$meta(name = "twitter:card", content = "summary_large_image"),
    htmltools::tags$meta(property = "twitter:title", content = "UFC finish breakdown"),
    htmltools::tags$meta(
      property = "twitter:description",
      content = "Interactive UFC finish dashboard with Men/Women and title-fight filters."
    ),
    htmltools::tags$meta(
      property = "twitter:image",
      content = paste0(base, "/output/05_finish_dashboard_donuts.png")
    )
  )
}

save_finish_dashboard <- function(
    fights,
    ultimate = NULL,
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

  dashboard_body <- build_finish_dashboard(
    fights,
    min_year = 2020,
    ultimate = ultimate
  )

  page <- htmltools::attachDependencies(
    htmltools::tags$html(
      htmltools::tags$head(
        htmltools::tags$meta(charset = "utf-8"),
        htmltools::tags$title("UFC finish breakdown"),
        htmltools::tags$meta(
          name = "viewport",
          content = "width=device-width, initial-scale=1"
        ),
        htmltools::tags$link(
          rel = "stylesheet",
          href = "https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@400;600;700&display=swap"
        ),
        dashboard_og_tags(),
        htmltools::tags$style(htmltools::HTML(page_css()))
      ),
      htmltools::tags$body(
        htmltools::tags$h1("Finish breakdown"),
        htmltools::tags$p(
          class = "page-subtitle",
          "2020–2026 (through 2026-06-27) · year, event, outcome, division, Men/Women, title fights"
        ),
        htmltools::tags$div(
          id = "hero-stats",
          class = "hero-stats",
          htmltools::tags$div(
            class = "stat-chip",
            htmltools::tags$span(class = "stat-label", "Active fights"),
            htmltools::tags$span(id = "stat-fights", class = "stat-value", "—")
          ),
          htmltools::tags$div(
            class = "stat-chip",
            htmltools::tags$span(class = "stat-label", "KO/TKO"),
            htmltools::tags$span(id = "stat-ko", class = "stat-value", "—")
          ),
          htmltools::tags$div(
            class = "stat-chip",
            htmltools::tags$span(class = "stat-label", "Submission"),
            htmltools::tags$span(id = "stat-sub", class = "stat-value", "—")
          ),
          htmltools::tags$div(
            class = "stat-chip",
            htmltools::tags$span(class = "stat-label", "Decision"),
            htmltools::tags$span(id = "stat-dec", class = "stat-value", "—")
          )
        ),
        dashboard_body,
        build_weight_class_modal(),
        htmltools::tags$p(
          class = "page-caption",
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
