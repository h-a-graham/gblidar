#' merge raster assets
#'
#' uses gdal warp to merge raster assets into a single file.
#'
#' @param x A `gbl_catalog` object
#' @param destination out put destination. if NUll then a tempfile is created
#' @param resample resampling method, default near
#' @param compression the tif compression method to use - e.g. "DEFLATE" or "LZW"
#' @param options character vector with gdal options.
#' @param raster_class The class in which to return the raster. can be any of
#' "character" (in which case the file path is returned - the default),
#' "SpatRaster", or "stars".
#' @param progress logical - should a progress bar be shown.
#'
#' @return A raster file path
#' @export
#'
#' @examples
merge_assets <- function(x,
                         mask = FALSE,
                         destination = NULL,
                         resample = "near",
                         compression = "DEFLATE",
                         nodata = NULL,
                         options = NULL,
                         raster_class = getOption("gblidar.out_raster_type"),
                         progress = getOption("gblidar.progress")) {
  assert_no_point_cloud(x)
  assert_rast(raster_class)


  gdal_srcs <- unpack_assets(x, progress)

  if (isTRUE(mask)) {
    cutline_path <- tempfile(fileext = ".gpkg")
    sf::write_sf(x$aoi, cutline_path)
    options <- c("-cutline", cutline_path, "-crop_to_cutline", options)
  }

  ras.src <- sf_warp_util(
    sources = gdal_srcs,
    destination,
    resample,
    compression,
    nodata,
    options,
    !progress
  )

  return_as_raster_class <- function(rc, src) {
    switch(rc,
      character = src,
      SpatRaster = terra::rast(src),
      stars = stars::read_stars(src)
    )
  }

  return_as_raster_class(raster_class, ras.src)
}



#' Title
#'
#' @param x
#'
#' @return a vector of urls
unpack_assets <- function(x, progress) {
  td <- tempdir()
  assets_zipped <- asset_download(x, td, progress = progress)

  assets_zipped$save_location |>
    lapply(function(z) {
      zd <- file.path(
        dirname(z),
        tools::file_path_sans_ext(basename(z))
      )

      unzip(z, exdir = zd)
      list.files(zd,
        pattern = ".tif$",
        recursive = TRUE,
        full.names = TRUE
      )
    }) |>
    unlist()
}
