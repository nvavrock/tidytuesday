# Angle 3: Cartographic map — OSi landmask (Republic), OSNI outline (NI), lakes, wreck points

MAP_VIEW_XLIM <- c(-11.2, -5.0)
MAP_VIEW_YLIM <- c(51.2, 55.8)
MAP_OCEAN_FILL <- "#B8DCF0"
MAP_WATER_FILL <- "#B8DCF0"
MAP_ROI_FILL <- "#F4E4C1"
MAP_NI_FILL <- "#D8D8D8"
MAP_BORDER_COLOR <- "#6B8FA3"
MAP_COAST_STROKE <- "#5A5A5A"

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

ireland_map_layers <- function(data_dir = "data") {
  sf::sf_use_s2(FALSE)

  list(
    republic = load_republic_land(data_dir),
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
      data = layers$republic,
      fill = MAP_ROI_FILL,
      color = NA
    ) +
    ggplot2::geom_sf(
      data = layers$northern_ireland,
      fill = MAP_NI_FILL,
      color = NA
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
      color = "#1B2A4A",
      alpha = 0.5,
      size = 0.9
    ) +
    ggplot2::annotate(
      "text",
      x = -6.15,
      y = 53.38,
      label = "Dublin",
      size = 3,
      color = "gray30"
    ) +
    ggplot2::annotate(
      "text",
      x = -8.7,
      y = 51.92,
      label = "Cork",
      size = 3,
      color = "gray30"
    ) +
    ggplot2::annotate(
      "text",
      x = -7.8,
      y = 53.55,
      label = "REPUBLIC OF IRELAND",
      size = 2.6,
      color = "gray35",
      fontface = "bold"
    ) +
    ggplot2::annotate(
      "text",
      x = -7.15,
      y = 54.55,
      label = "NORTHERN IRELAND",
      size = 2.6,
      color = "gray40",
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
      title = "Known wreck sites cluster along Ireland's coasts",
      subtitle = paste0(
        scales::comma(nrow(located)),
        " located records · Tailte Éireann & OSNI land · lakes Natural Earth 1:10m"
      ),
      x = NULL,
      y = NULL,
      caption = paste0(
        DATA_SOURCE_CAPTION,
        " · Basemap: Tailte Éireann & OSNI open data (CC BY / OGL)"
      )
    ) +
    tt_theme() +
    ggplot2::theme(
      panel.background = ggplot2::element_rect(fill = MAP_OCEAN_FILL, color = NA),
      panel.grid.major = ggplot2::element_line(color = "#FFFFFF", linewidth = 0.2),
      panel.grid.minor = ggplot2::element_blank(),
      axis.text = ggplot2::element_text(size = 8, color = "gray35"),
      axis.ticks = ggplot2::element_line(color = "gray50", linewidth = 0.3)
    )
}
