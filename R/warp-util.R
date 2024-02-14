#' Easy Warp using sf::gdalutils
#'
#' stable and supports >memory rasters and cutline feature.

#'
#' @param sources list of raster sources.
#' @param destination out put destination. if NUll then a tempfile is created
#' @param resample resampling method, default near
#' @param compression the tif compression method to use -
#' e.g. "DEFLATE" or "LZW"
#' @param options character vector with gdal options.
#' @param progress logical - should a progress bar be shown.
#' @param ... Not used.
#'
#' @return A raster file path.
#' @noRd
sf_warp_util <- function(
    sources,
    destination,
    resample,
    compression,
    nodata,
    options,
    progress,
    extent = NULL,
    dimension = NULL,
    ...) {
  if (is.null(destination)) {
    destination <- tempfile(fileext = ".tif")
  }

  opts <- c(
    "-t_srs", "EPSG:27700",
    "-r", resample,
    "-overwrite",
    "-co", paste0("COMPRESS=", compression),
    options
  )

  if (!is.null(nodata)) {
    opts <- c(opts, "-dstnodata", nodata)
  }

  if (!is.null(extent)) {
    opts <- c(opts, "-te", extent[c(1, 2, 3, 4)])
  }

  if (!is.null(dimension)) {
    opts <- c(opts, "-ts", dimension)
  }


  sf::gdal_utils(
    util = "warp",
    source = sources,
    destination = destination,
    options = opts,
    quiet = progress
  )
  destination
}


#' Round to nearest value
#'
#' A literal copy of `plyr::round_any()`
#'
#' @param x numeric
#' @param accuracy numeric. Target multiple to round to.
#' @param f function. Default is `round`
#'
#' @return numeric
#' @noRd
round_nearest <- function(x, accuracy, f = round) {
  f(x / accuracy) * accuracy
}

#' round a bbox to desired interval
#'
#' @param .box numeric. Bounding box.
#' @param .res  numeric. Desired resolution.
#'
#' @return vector with bbox dims
#' @noRd
round_bbox <- function(.box, .res) {
  big <- round_nearest(.box[c(2, 4)], .res, f = ceiling)
  small <- round_nearest(.box[c(1, 3)], .res, f = floor)
  c(small[1], big[1], small[2], big[2])
}

#' get the target x y dimensions from bbox and desired res.
#'
#' @param .box numeric. Bounding box.
#' @param .res numeric. Desired resolution.
#'
#' @return numeric vector xy dims
#' @noRd
dims_from_box <- function(.box, .res) {
  x <- .box[3] - .box[1]
  y <- .box[4] - .box[2]
  c(x, y) / .res
}
