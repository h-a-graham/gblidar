#' Easy Warp using sf::gdalutils
#'
#' stable and supports >memory rasters and cutline feature.

#'
#' @param sources list of raster sources.
#' @param destination out put destination. if NUll then a tempfile is created
#' @param resample resampling method, default near
#' @param compression the tif compression method to use - e.g. "DEFLATE" or "LZW"
#' @param options character vector with gdal options.
#' @param progress logical - should a progress bar be shown.
#' @param ... Not used.
#'
#' @return A raster file path.
#' @noRd
sf_warp_util <- function(sources,
                         destination,
                         resample,
                         compression,
                         nodata,
                         options,
                         progress,
                         ...) {

  if (is.null(destination)){
    destination <- tempfile(fileext = '.tif')
  }

  opts <- c(
    "-t_srs", "EPSG:27700",
    "-r", resample,
    "-overwrite",
    "-co", paste0("COMPRESS=", compression),
    options
  )

  if (!is.null(nodata)){
    opts <- c(opts, "-dstnodata", nodata)
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

