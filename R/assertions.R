assert_aoi <- function(x){
  checkmate::assert(checkmate::check_class(x, c("sf")),
                    checkmate::check_class(x, c("sfc")),
                    checkmate::check_class(x, c("character")))

  if (is.character(x)) x <- sf::read_sf(x)

  x <- x |>
    sf::st_as_sf() |>
    sf::st_transform(27700) |>
    wk::wk_flatten()

  if (nrow(x) > 1 ){
    x <- sf::st_convex_hull(sf::st_union(x))

    cli::cli_warn(c("The provided AOI has {nrow(x)} polygons. A single polygon
                    is required",
                    "i" = "The AOI has been converted to the convex hull of
                    the combined inputs.",
                    "i" = "This could result in a much larger requested area
                    than expected."))
  }

  return(sf::st_as_sfc(x))
}
