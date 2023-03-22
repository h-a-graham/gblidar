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
#' @return
#' @noRd
sf_warp_util <- function(sources,
                         destination,
                         resample,
                         compression,
                         options,
                         progress,
                         ...) {

  if (is.null(destination)){
    destination <- tempfile(fileext = '.tif')
  }

  opts <- c(
    # "-te", params$extent[c(1, 3, 2, 4)],
    # "-ts", params$dimension,
    "-t_srs", "EPSG:27700",
    "-r", resample,
    "-overwrite",
    "-co", paste0("COMPRESS=", compression),
    options
  )

  sf::gdal_utils(
    util = "warp",
    source = sources,
    destination = destination,
    options = opts,
    quiet = progress
  )
  destination
}


#' merge raster assets
#'
#' uses gdal warp to merge raster assets into a single file.
#'
#' @param x A `gbl_catalog` object
#' @param destination out put destination. if NUll then a tempfile is created
#' @param resample resampling method, default near
#' @param compression the tif compression method to use - e.g. "DEFLATE" or "LZW"
#' @param options character vector with gdal options.
#' @param progress logical - should a progress bar be shown.
#'
#' @return
#' @export
#'
#' @examples
merge_assets <- function(x,
                         mask=FALSE,
                         destination=NULL,
                         resample = 'near',
                         compression="DEFLATE",
                         options=NULL,
                         progress=TRUE){

  gdal_srcs <- unlist(x$gbl_tab$gdal_urls)

  if (isTRUE(mask)){

    cutline_path <- tempfile(fileext = ".gpkg")
    sf::write_sf(x$aoi, cutline_path)
    options <- c('-cutline', cutline_path, "-crop_to_cutline", options)
  }

  sf_warp_util(sources=gdal_srcs,
               destination,
               resample,
               compression,
               options,
               !progress)
}
