gbl_catalog <- function(gbl_tab, aoi, date_time, search_aoi, tile_names) {
  structure(
    list(
      gbl_tab = gbl_tab,
      aoi = aoi,
      date_time = date_time,
      search_aoi = search_aoi,
      tile_names = search_aoi$tile_name
    ),
    class = "gbl_catalog"
  )
}

bng_tile_intersect <- function(.aoi) {
  if (sf::st_crs(.aoi)$epsg != 27700) {
    .aoi <- sf::st_transform(.aoi, 27700)
    cli::cli_warn(c("The provided AOI was not in BNG",
      "i" = "it has been transformed to BNG (EPSG:27700)"
    ))
  }
  suppressWarnings({
    sf::st_filter(osgb_grid(), .aoi, join = sf::st_intersects)
  })
}


#' print a gbl_catalog object
#'
#' @param x
#'
#' @export
#'
#' @examples
print.gbl_catalog <- function(x) {
  message(crayon::cyan("Data Catalog"))
  print(x$gbl_tab, n = nrow(x$gbl_tab))
  message(crayon::green("AOI Geometry"))
  print(x$aoi)
  message(crayon::cyan("Tile Names"))
  print(x$tile_names)
}


#' Plot a gbl_catalog object
#'
#' @param x a gbl_catalog object
#' @export
#'
#' @examples
plot.gbl_catalog <- function(x) {
  plot(sf::st_geometry(x$search_aoi))
  plot(sf::st_geometry(x$aoi), col = "#21C6C1", add = TRUE)
}


#' filter a gbl_catalog object
#'
#' wrapper for dplyr::filter for `gbl_catalog` objects
#'
#' @param x A gbl_catalog object
#'
#' @return A filtered gbl_catalog object
#' @export
#'
#' @examples
filter_catalog <- function(x, ..., .by = NULL, .preserve = FALSE) {
  x$gbl_tab <- dplyr::filter(x$gbl_tab, ..., .by = .by, .preserve = .preserve)

  if (nrow(x$gbl_tab) == 0) {
    len <- length(rlang::enquos(...))
    cli::cli_abort(c(
      "The filtered gbl_catalog is empty.",
      "x" = "No assets match the {len} requested filter statement{?s}"
    ))
  }

  return(x)
}



#' row bind multiple gbl_catalog objects
#'
#' wrapper for dplyr::bind_rows for `gbl_catalog` objects
#'
#' @param ...gbl_catalog objects to combine
#' @param .id The name of an optional identifier column. Provide a string to
#' create an output column that identifies each input. The column will use names
#' if available, otherwise it will use positions.
#'
#' @return A filtered gbl_catalog object
#' @export
#'
#' @examples
bind_catalogs <- function(..., .id = "AOI") {
  print("lala")

  gblcs <- list(...)
  gblc_tabs <- gblcs |>
    lapply(function(x) x$gbl_tab) |>
    dplyr::bind_rows(.id = .id) |>
    dplyr::distinct()

  gblc_aois <- gblcs |>
    lapply(function(x) sf::st_as_sf(x$aoi)) |>
    dplyr::bind_rows() |>
    sf::st_as_sfc()

  gblc_dt <- gblcs |>
    lapply(function(x) x$date_time) |>
    unlist()

  gbl_catalog(gblc_tabs, aoi = gblc_aois, date_time = gblc_dt)
}


#' Return the data urls for a gbl_catalog object
#'
#' @param x A gbl_catalog object
#'
#' @return a character vector of url paths.
#' @export
#'
#' @examples
gbl_urls <- function(x) {
  unlist(x$gbl_tab$urls)
}
