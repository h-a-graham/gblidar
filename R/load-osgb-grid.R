#' Load the OSGB grid.
#'
#' @return An sf object of 50km osgb grids and tilenames
#' @noRd
osgb_grid <- function(){
  sf::read_sf(system.file("osgb_grid/osgb_grid.gpkg", package="gblidar"))
}
