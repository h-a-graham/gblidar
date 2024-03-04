#' Convert a raster to a specific class
#' @param rc character. The class in which to return the raster. can be any of
#' "character" (in which case the file path is returned - the default),
#' "SpatRaster", or "stars".
#' @param src character. The file path of the raster.
#' @return A raster object of the specified class.
#' @noRd
#'
return_as_raster_class <- function(rc, src) {
  switch(rc,
    character = src,
    SpatRaster = terra::rast(src),
    stars = stars::read_stars(src)
  )
}
