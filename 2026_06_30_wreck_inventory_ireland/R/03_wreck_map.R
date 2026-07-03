# Angle 3: Cartographic map — OSi landmask (Republic), OSNI outline (NI), lakes, wreck points

MAP_VIEW_XLIM <- c(-11.2, -5.0)
MAP_VIEW_YLIM <- c(51.2, 55.8)
MAP_OCEAN_FILL <- "#B8DCF0"
MAP_WATER_FILL <- "#B8DCF0"
IRELAND_FLAG_COLORS <- c(
  green = "#169B62",
  white = "#FFFFFF",
  orange = "#FF883E"
)

MAP_NI_FILL <- "#D8D8D8"
MAP_BORDER_COLOR <- "#6B8FA3"
MAP_COAST_STROKE <- "#5A5A5A"
MAP_WRECK_COLOR <- "#1B2A4A"

MAP_CITIES <- tibble::tibble(
  city = c("Dublin", "Cork"),
  longitude = c(-6.26, -8.47),
  latitude = c(53.35, 51.90),
  label_x = c(-6.65, -8.7),
  label_y = c(53.23, 52.06),
  color = c("#B83230", "#1D6FA3")
)

MAP_REGION_LABEL_COLOR <- "gray30"

MAP_REGION_LABELS <- tibble::tibble(
  region = c("REPUBLIC OF IRELAND", "NORTHERN IRELAND"),
  label_x = c(-8, -6.5),
  label_y = c(53.75, 54.55)
)

BASEMAP_ROI_FILE <- "osi_landmask.geojson"
BASEMAP_NI_FILE <- "osni_outline.geojson"

LAKE_GEOJSON_FILES <- c(
  "ne_10m_lakes_europe.geojson",
  "ne_10m_lakes.geojson"
)

map_view_bbox <- function() {
  sf::st_as_sfc(
    sf::st_bbox(
      c(
        xmin = MAP_VIEW_XLIM[[1]],
        ymin = MAP_VIEW_YLIM[[1]],
        xmax = MAP_VIEW_XLIM[[2]],
        ymax = MAP_VIEW_YLIM[[2]]
      ),
      crs = 4326
    )
  )
}

lake_in_map_view <- function(lake_row) {
  bbox <- sf::st_bbox(lake_row)
  bbox[["xmin"]] <= MAP_VIEW_XLIM[[2]] &&
    bbox[["xmax"]] >= MAP_VIEW_XLIM[[1]] &&
    bbox[["ymin"]] <= MAP_VIEW_YLIM[[2]] &&
    bbox[["ymax"]] >= MAP_VIEW_YLIM[[1]]
}

fetch_map_lakes <- function(data_dir = "data") {
  sf::sf_use_s2(FALSE)

  lakes <- purrr::map(
    file.path(data_dir, LAKE_GEOJSON_FILES),
    function(path) {
      if (!file.exists(path)) {
        return(NULL)
      }
      sf::st_read(path, quiet = TRUE)
    }
  ) |>
    purrr::compact() |>
    dplyr::bind_rows()

  if (nrow(lakes) == 0) {
    return(NULL)
  }

  in_view <- vapply(
    seq_len(nrow(lakes)),
    function(i) lake_in_map_view(lakes[i, ]),
    logical(1)
  )

  lakes |>
    dplyr::filter(in_view) |>
    dplyr::filter(!is.na(name)) |>
    dplyr::distinct(name, .keep_all = TRUE)
}

load_republic_land <- function(data_dir = "data") {
  path <- file.path(data_dir, BASEMAP_ROI_FILE)
  if (!file.exists(path)) {
    return(NULL)
  }

  land <- sf::st_read(path, quiet = TRUE)
  if (sf::st_crs(land)$epsg != 4326) {
    land <- sf::st_transform(land, 4326)
  }
  land
}

load_northern_ireland_land <- function(data_dir = "data") {
  path <- file.path(data_dir, BASEMAP_NI_FILE)
  if (!file.exists(path)) {
    return(NULL)
  }

  ni <- sf::st_read(path, quiet = TRUE)
  if (nrow(ni) > 1) {
    ni <- sf::st_sf(geometry = sf::st_union(sf::st_geometry(ni)))
  }
  if (sf::st_crs(ni)$epsg != 4326) {
    ni <- sf::st_transform(ni, 4326)
  }
  ni
}

republic_tricolor_sf <- function(republic) {
  bbox <- sf::st_bbox(republic)
  xmin <- bbox[["xmin"]]
  xmax <- bbox[["xmax"]]
  ymin <- bbox[["ymin"]]
  ymax <- bbox[["ymax"]]
  third <- (xmax - xmin) / 3

  make_strip <- function(x0, x1) {
    sf::st_as_sfc(
      sf::st_bbox(
        c(xmin = x0, ymin = ymin, xmax = x1, ymax = ymax),
        crs = sf::st_crs(republic)
      )
    )
  }

  flag_strip <- function(x0, x1, label) {
    sf::st_sf(
      stripe = label,
      geometry = sf::st_intersection(
        sf::st_geometry(republic),
        make_strip(x0, x1)
      )
    )
  }

  dplyr::bind_rows(
    flag_strip(xmin, xmin + third, "green"),
    flag_strip(xmin + third, xmin + 2 * third, "white"),
    flag_strip(xmin + 2 * third, xmax, "orange")
  )
}

ireland_map_layers <- function(data_dir = "data") {
  sf::sf_use_s2(FALSE)

  republic <- load_republic_land(data_dir)

  list(
    republic = republic,
    republic_tricolor = if (is.null(republic)) NULL else republic_tricolor_sf(republic),
    northern_ireland = load_northern_ireland_land(data_dir),
    lakes = fetch_map_lakes(data_dir)
  )
}

plot_wreck_map <- function(wreck_inventory, data_dir = "data") {
  located <- wreck_inventory |>
    dplyr::filter(located)

  layers <- ireland_map_layers(data_dir = data_dir)

  if (is.null(layers$republic) || is.null(layers$northern_ireland)) {
    stop(
      "Basemap files missing. Run download_data() to fetch ",
      BASEMAP_ROI_FILE, " and ", BASEMAP_NI_FILE, "."
    )
  }

  p <- ggplot2::ggplot() +
    ggplot2::geom_sf(
      data = layers$northern_ireland,
      fill = MAP_NI_FILL,
      color = NA
    ) +
    ggplot2::geom_sf(
      data = layers$republic_tricolor,
      ggplot2::aes(fill = stripe),
      color = NA
    ) +
    ggplot2::scale_fill_manual(
      values = IRELAND_FLAG_COLORS,
      guide = "none"
    )

  if (!is.null(layers$lakes) && nrow(layers$lakes) > 0) {
    p <- p +
      ggplot2::geom_sf(
        data = layers$lakes,
        fill = MAP_WATER_FILL,
        color = "#8CBAD4",
        linewidth = 0.15
      )
  }

  p +
    ggplot2::geom_sf(
      data = layers$republic,
      fill = NA,
      color = MAP_COAST_STROKE,
      linewidth = 0.35
    ) +
    ggplot2::geom_sf(
      data = layers$northern_ireland,
      fill = NA,
      color = MAP_BORDER_COLOR,
      linewidth = 0.55
    ) +
    ggplot2::geom_point(
      data = located,
      ggplot2::aes(x = longitude, y = latitude),
      inherit.aes = FALSE,
      color = MAP_WRECK_COLOR,
      alpha = 0.5,
      size = 0.9
    ) +
    ggplot2::geom_point(
      data = MAP_CITIES,
      ggplot2::aes(x = longitude, y = latitude, color = city),
      inherit.aes = FALSE,
      size = 2.2
    ) +
    ggplot2::scale_color_manual(
      values = stats::setNames(MAP_CITIES$color, MAP_CITIES$city),
      guide = "none"
    ) +
    ggplot2::annotate(
      "text",
      x = MAP_CITIES$label_x,
      y = MAP_CITIES$label_y,
      label = MAP_CITIES$city,
      size = 4.5,
      color = MAP_CITIES$color,
      fontface = "bold"
    ) +
    ggplot2::annotate(
      "text",
      x = MAP_REGION_LABELS$label_x,
      y = MAP_REGION_LABELS$label_y,
      label = MAP_REGION_LABELS$region,
      size = 3.9,
      color = MAP_REGION_LABEL_COLOR,
      fontface = "bold"
    ) +
    ggplot2::coord_sf(
      xlim = MAP_VIEW_XLIM,
      ylim = MAP_VIEW_YLIM,
      expand = FALSE,
      crs = sf::st_crs(4326),
      datum = sf::st_crs(4326)
    ) +
    ggplot2::labs(
      title = paste0(
        "Known wreck sites cluster along\n",
        "Ireland's coasts and inland waters"
      ),
      subtitle = paste0(
        scales::comma(nrow(located)), " located records\n",
        "Irish tricolor (Republic) · Tailte Éireann & OSNI land\n",
        "Lakes: Natural Earth 1:10m"
      ),
      x = NULL,
      y = NULL,
      caption = paste0(
        DATA_SOURCE_CAPTION,
        "\nBasemap: Tailte Éireann & OSNI open data (CC BY / OGL)"
      )
    ) +
    tt_theme() +
    ggplot2::theme(
      panel.background = ggplot2::element_rect(fill = MAP_OCEAN_FILL, color = NA),
      panel.grid.major = ggplot2::element_line(color = "#FFFFFF", linewidth = 0.2),
      panel.grid.minor = ggplot2::element_blank(),
      axis.text = ggplot2::element_text(size = 8, color = "gray35"),
      axis.ticks = ggplot2::element_line(color = "gray50", linewidth = 0.3),
      plot.caption = ggplot2::element_text(
        hjust = 0,
        color = "gray40",
        size = ggplot2::rel(0.78),
        lineheight = 1.25,
        margin = ggplot2::margin(t = 10)
      ),
      plot.subtitle = ggplot2::element_text(
        color = "gray40",
        size = ggplot2::rel(0.88),
        lineheight = 1.3,
        margin = ggplot2::margin(b = 6)
      ),
      plot.title = ggplot2::element_text(
        lineheight = 1.15,
        margin = ggplot2::margin(b = 4)
      ),
      plot.margin = ggplot2::margin(12, 16, 18, 12)
    )
}

wreck_hover_labels <- function(located) {
  located |>
    dplyr::mutate(
      .display_name = dplyr::coalesce(wreck_name, "Unknown wreck"),
      .display_type = dplyr::coalesce(classification, "Unknown type"),
      .display_place = dplyr::coalesce(place_of_loss, "Place unknown"),
      .year_text = dplyr::if_else(
        is.na(year),
        "",
        paste0(" · ", year)
      ),
      .id_text = dplyr::if_else(
        is.na(wreck_no),
        "",
        paste0(" (", wreck_no, ")")
      ),
      hover = paste0(
        "<b>", .display_name, "</b>", .id_text,
        "<br>", .display_type, .year_text,
        "<br>", .display_place,
        "<br>", round(latitude, 2), "°N, ", round(abs(longitude), 2), "°W"
      ),
      popup = paste0(
        hover,
        dplyr::if_else(
          is.na(description) | description == "",
          "",
          paste0("<br><br>", stringr::str_trunc(description, 280))
        )
      )
    ) |>
    dplyr::select(-.display_name, -.display_type, -.display_place, -.year_text, -.id_text)
}

plot_wreck_map_interactive <- function(wreck_inventory, data_dir = "data") {
  located <- wreck_inventory |>
    dplyr::filter(located) |>
    wreck_hover_labels()

  layers <- ireland_map_layers(data_dir = data_dir)

  if (is.null(layers$republic) || is.null(layers$northern_ireland)) {
    stop(
      "Basemap files missing. Run download_data() to fetch ",
      BASEMAP_ROI_FILE, " and ", BASEMAP_NI_FILE, "."
    )
  }

  map <- leaflet::leaflet(options = leaflet::leafletOptions(minZoom = 6, maxZoom = 12)) |>
    leaflet::fitBounds(
      lng1 = MAP_VIEW_XLIM[[1]],
      lat1 = MAP_VIEW_YLIM[[1]],
      lng2 = MAP_VIEW_XLIM[[2]],
      lat2 = MAP_VIEW_YLIM[[2]]
    ) |>
    leaflet::addRectangles(
      lng1 = MAP_VIEW_XLIM[[1]],
      lat1 = MAP_VIEW_YLIM[[1]],
      lng2 = MAP_VIEW_XLIM[[2]],
      lat2 = MAP_VIEW_YLIM[[2]],
      fillColor = MAP_OCEAN_FILL,
      fillOpacity = 1,
      color = NA,
      weight = 0,
      options = leaflet::pathOptions(pane = "tilePane")
    ) |>
    leaflet::addPolygons(
      data = layers$northern_ireland,
      fillColor = MAP_NI_FILL,
      fillOpacity = 1,
      color = MAP_BORDER_COLOR,
      weight = 1.2,
      options = leaflet::pathOptions(pane = "overlayPane")
    )

  for (stripe_name in names(IRELAND_FLAG_COLORS)) {
    stripe_layer <- layers$republic_tricolor |>
      dplyr::filter(stripe == stripe_name)
    if (nrow(stripe_layer) == 0) {
      next
    }
    map <- map |>
      leaflet::addPolygons(
        data = stripe_layer,
        fillColor = IRELAND_FLAG_COLORS[[stripe_name]],
        fillOpacity = 1,
        color = NA,
        weight = 0,
        options = leaflet::pathOptions(pane = "overlayPane")
      )
  }

  if (!is.null(layers$lakes) && nrow(layers$lakes) > 0) {
    map <- map |>
      leaflet::addPolygons(
        data = layers$lakes,
        fillColor = MAP_WATER_FILL,
        fillOpacity = 1,
        color = "#8CBAD4",
        weight = 0.5,
        options = leaflet::pathOptions(pane = "overlayPane")
      )
  }

  map |>
    leaflet::addCircleMarkers(
      data = located,
      lng = ~longitude,
      lat = ~latitude,
      radius = 4,
      stroke = FALSE,
      fillColor = MAP_WRECK_COLOR,
      fillOpacity = 0.55,
      label = ~htmltools::HTML(hover),
      popup = ~popup,
      labelOptions = leaflet::labelOptions(
        direction = "top",
        textsize = "12px",
        opacity = 0.95
      ),
      options = leaflet::markerOptions(pane = "markerPane")
    ) |>
    leaflet::addCircleMarkers(
      data = MAP_CITIES,
      lng = ~longitude,
      lat = ~latitude,
      radius = 6,
      stroke = TRUE,
      color = "#FFFFFF",
      weight = 1.5,
      fillColor = ~color,
      fillOpacity = 1,
      label = ~city,
      labelOptions = leaflet::labelOptions(
        direction = "top",
        textsize = "13px",
        opacity = 1
      )
    )
}
