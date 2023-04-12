#' Load the OSGB grid.
#'
#' @return An sf object of 50km osgb grids and tilenames
#' @noRd
osgb_grid <- function(){
  sf::read_sf(system.file("bng_grids/os_bng_5km_grid.gpkg", package="gblidar"))
}
