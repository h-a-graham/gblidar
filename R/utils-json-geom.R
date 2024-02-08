eng_json_geoms <- function(aoi) {
  aoi <- wk::wk_coords(aoi) |>
    dplyr::mutate(dplyr::across(dplyr::everything(), \(x) round(x, 3)))

  # Create a list of paired vectors
  paired_vectors <- mapply(c, aoi$x, aoi$y, SIMPLIFY = FALSE)

  # Install and load the jsonlite package

  # Create a list
  list(
    coordinates = list(paired_vectors),
    type = "Polygon"
  ) |>
    jsonlite::toJSON(auto_unbox = TRUE)
}
