#' Search the Environment Agency LiDAR/Geo API for data in England.
#'
#' @param aoi A spatial area to request: Can be any of the following classes:
#' sf, sfc or character. When a character is provided it must be a gdal readable
#' spatial vector file format.
#'
#' @return An object of class `gbl_catalog`
#' @export
#'
#' @examples
#' scafell_box <- sf::st_point(c(321633, 507181)) |>
#'   sf::st_buffer(100) |>
#'   sf::st_sfc() |>
#'   sf::st_set_crs(27700)
#' scafell_catalog <- eng_search(scafell_box)
#' print(scafell_catalog)
eng_search <- function(aoi) {
  checkmate::assert_multi_class(aoi, c("sf", "sfc_POLYGON", "character"))
  if (inherits(aoi, "character")) aoi <- sf::read_sf(aoi)
  eng_url <- eng_api_endpoint()
  search_aoi <- bng_tile_intersect(aoi)
  post_aoi <- eng_post_feature(search_aoi)

  eng_post <- httr::POST(
    eng_url,
    httr::add_headers(.headers = eng_api_headers()),
    body = eng_json_geoms(post_aoi)
  )

  response <- httr::content(eng_post, "text")

  url_df <- eng_tab_response(response)

  gbl_catalog(
    gbl_tab = url_df,
    aoi = aoi,
    date_time = Sys.time(),
    search_aoi = search_aoi
  )
}

# place holder
wales_search <- function(aoi) {
  cli::cli_abort("Nothing to see here... yet.")
}

# place holder
scot_search <- function(aoi) {
  cli::cli_abort("Nothing to see here... yet.")
}

# pseudo code definitely not working yet.
gb_search <- function(aoi) {
  ws <- wales_search()
  ss <- scot_search()
  es <- eng_search()

  url_df <- bind_rows(ws, ss, es)
}
