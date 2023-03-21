gbl_catalog <- function(gbl_tab, aoi, date_time, tile_intersect=NULL){
  structure(
    list(
    gbl_tab = gbl_tab,
    aoi = aoi,
    date_time = date_time,
    tile_intersect =tile_intersect
  ),
  class="gbl_catalog")
}

#' print a gbl_catalog object
#'
#' @param x
#'
#' @return
#' @export
#'
#' @examples
print.gbl_catalog <- function(x){
  message(crayon::cyan("Data Catalog"))
  print(x$gbl_tab, n=nrow(x$gbl_tab))
  message(crayon::green("AOI Geometry"))
  print(x$aoi)
}


#' filter a gbl_catalog object
#'
#' Provides a new method for dplyr::filter
#'
#' @param x A gbl_catalog object
#'
#' @return A filtered gbl_catalog object
#' @export
#' @importFrom dplyr filter
#'
#' @examples
filter.gbl_catalog <- function(x, ..., .by = NULL, .preserve = FALSE){
  x$gbl_tab <- dplyr::filter(x$gbl_tab, ..., .by=.by, .preserve=.preserve)
  return(x)
}
# Required to export filter, otherwise:
# Warning: declared S3 method 'filter.gbl_catalog' not found
# because of stats::filter

#' @export
#'
dplyr::filter
