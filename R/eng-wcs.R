#' Web Coverage Service (WCS) endpoint retrieval
#' @param product character. The product to retrieve. Can be any of the following:
#' "fz_dsm", "dsm", "dtm", "vom".
#' @param resolution numeric. The resolution of the product. Can be 1 or 2.
#' (in meters)
#' @return object of class `eng.wcs.url` and `character`. comprising the WCS
#' endpoint URL.
#' @export
wcs_url <- function(
    product = c("fz_dsm", "dsm", "dtm", "vom"),
    resolution = 1) {
  product <- rlang::arg_match(product)
  checkmate::assert_choice(resolution, choices = c(1, 2))

  url_base <- "WCS:https://environment.data.gov.uk/spatialdata/"
  url_suffix <- "/wcs?version=2.0.1"

  fz_dsm_base <- "lidar-composite-digital-surface-model-first-return-dsm-%sm"
  dsm_base <- "lidar-composite-digital-surface-model-last-return-dsm-%sm"
  dtm_base <- "lidar-composite-digital-terrain-model-dtm-%sm"

  prodcode <- ifelse(product == "vom",
    "vom",
    paste0(product, "_", resolution, "m")
  )

  url_product <- switch(prodcode,
    "fz_dsm_1m" = sprintf(fz_dsm_base, 1),
    "fz_dsm_2m" = sprintf(fz_dsm_base, 2),
    "dsm_1m" = sprintf(dsm_base, 1),
    "dsm_2m" = sprintf(dsm_base, 2),
    "dtm_1m" = sprintf(dtm_base, 1),
    "dtm_2m" = sprintf(dtm_base, 2),
    "vom" = "vegetation-object-model"
  )

  wcs_ep <- structure(paste0(url_base, url_product, url_suffix),
    class = c("eng.wcs.url", "character")
  )

  return(wcs_ep)
}

#' Web Coverage Service (WCS) layer retrieval
#' @param wcs_url character. The WCS endpoint URL from `wcs_url()`.
#' @return list. A list of WCS layers.
#' @export
wcs_layers <- function(wcs_url) {
  checkmate::assert_class(wcs_url, "eng.wcs.url")
  info <- sf::gdal_utils("info", wcs_url, quiet = TRUE)

  info_lines <- strsplit(info, "\n")[[1]]
  subdataset_lines <- grep("^\\s*SUBDATASET_", info_lines, value = TRUE)

  subdataset_info <- stringr::str_split(subdataset_lines, "=", n = 2) |>
    purrr::transpose()

  subdat_heads <- subdataset_info[[1]] |>
    trimws()

  subdataset_results <- subdataset_info[[2]] |>
    purrr::set_names(subdat_heads)

  # Convert the list to a dataframe
  df <- tibble::enframe(subdataset_results, name = "key", value = "value")

  # Extract the numeric part and the NAME/DESC part from the key
  df <- df |>
    dplyr::mutate(
      group = stringr::str_extract(key, "SUBDATASET_\\d+"),
      item = stringr::str_extract(key, "(NAME|DESC)$")
    ) |>
    dplyr::select(item, value, group)
  # Convert the dataframe back to a nested list
  nested_list <- split(df, df$group) |>
    purrr::map(~ tibble::deframe(dplyr::select(.x, !group)))

  wcs_names <- purrr::map_chr(
    nested_list,
    ~ stringr::str_extract(.x$DESC, "Elevation|Hillshade")
  ) |>
    unname()

  wcs_endpoints <- purrr::map(
    nested_list,
    ~ paste(wcs_url, .x$NAME, sep = ":")
  ) |>
    purrr::set_names(wcs_names)

  return(wcs_endpoints)
}

#' Get English Composite LiDAR-derived raster data fast!
#' @description This function retrieves composite raster data from the
#' Environment Agency's Web Coverage Service (WCS) for the following products:
#' "fz_dsm", "dsm", "dtm", "vom".
#' @param aoi A spatial area to request: Can be any of the following classes:
#' sf, sfc or character. When a character is provided it must be a gdal readable
#' spatial vector file format.
#' @param product character. The product to retrieve. Can be any of the
#' following: "fz_dsm", "dsm", "dtm", "vom".
#' @param product_type character. The type of product to retrieve. Can be any of
#' the following: "elevation", "hillshade".
#' @param prod_res numeric. The resolution of the product. Can be 1 or 2
#' (in meters).
#' @param mask logical. Whether to mask the raster data to the area of interest.
#' @param destination character. The destination file path for the raster data.
#' @param warp_res numeric. The resolution (in meters) of output raster data.
#' Can differ from the product resolution (although this is the default).
#' @param resample character. The resampling method to use. Can be any of the
#' following: "near", "bilinear", "cubic", "cubicspline", "lanczos", "average",
#' "rms", "mode", "max", "min", "med", "q1", "q3".
#' @param compression character. The compression method to use. Can be for
#' example: "DEFLATE" or "LZW".
#' @param nodata numeric. The nodata value to use.
#' @param options character. A character vector with gdal options.
#' @param raster_class character. The class in which to return the raster.
#' Can be any of "character" (in which case the file path is returned -
#' the default), "SpatRaster", or "stars".
#' @param progress logical. Should a progress bar be shown.
#' @return A `character` file path, `SpatRaster` or `stars` object, depending
#' on the `raster_class` argument.
#' @export
#' @examples
#'
#' search_box <- st_point(c(370126.5, 538567.1)) |>
#'   st_buffer(50) |>
#'   st_sfc() |>
#'   st_set_crs(27700)
#'
#' fz_dsm <- eng_composite(search_box, product = "fz_dsm")
#' dsm <- eng_composite(search_box, "dsm")
#' dtm <- eng_composite(search_box, "dtm")
#' vom <- eng_composite(search_box, "vom", "elevation")
#'
#' dsm_hs <- eng_composite(search_box, product = "dsm", product_type = "hillshade")
#' dtm_hs <- eng_composite(search_box, "dtm", "hillshade")
#'
eng_composite <- function(
    aoi,
    product = c("fz_dsm", "dsm", "dtm", "vom"),
    product_type = c("elevation", "hillshade"),
    prod_res = 1,
    mask = FALSE,
    destination = NULL,
    warp_res = prod_res,
    resample = c(
      "bilinear", "near", "cubic", "cubicspline", "lanczos",
      "average", "rms", "mode", "max", "min", "med", "q1", "q3"
    ),
    compression = "DEFLATE",
    nodata = NULL,
    options = NULL,
    raster_class = getOption("gblidar.out_raster_type"),
    progress = getOption("gblidar.progress")) {
  # assertions
  checkmate::assert_multi_class(aoi, c("sf", "sfc_POLYGON", "character"))
  if (inherits(aoi, "character")) aoi <- sf::read_sf(aoi)
  resample <- rlang::arg_match(resample)
  product_type <- rlang::arg_match(product_type) |>
    tools::toTitleCase()

  wcs_url <- wcs_url(product, prod_res)
  wcs_info <- wcs_layers(wcs_url)

  search_box <- aoi |>
    sf::st_union() |>
    sf::st_transform(27700) |>
    sf::st_bbox()

  box <- round_bbox(search_box, .res = warp_res)
  dims <- dims_from_box(box, .res = warp_res)

  ras.src <- sf_warp_util(
    sources = wcs_info[[product_type]],
    extent = box,
    dimension = dims,
    destination = destination,
    resample = resample,
    compression = "DEFLATE",
    nodata = NULL,
    options = NULL,
    progress = !progress
  )

  return_as_raster_class(raster_class, ras.src)
}
