
json_geoms <- function(aoi){
  paste0('{"geometryType":"esriGeometryPolygon","features":[{"geometry":{"rings":',
         json_vertices(aoi),
         ',"spatialReference":{"wkid":27700,"latestWkid":27700}}}],"sr":{"wkid":27700,"latestWkid":27700}}')
}


json_vertices <- function(aoi){
  verts <- wk::wk_coords(aoi) |>
    dplyr::mutate(geom=paste0("[", x, ",", y, "]")) |>
    dplyr::group_by(ring_id) |>
    dplyr::reframe(geom=paste0( geom, collapse = ",")) |>
    dplyr::pull(geom)

  vert.leng <- length(verts)

  json_coords <- verts |>
    sapply( function(x) paste0("[[", x, "]]"), USE.NAMES = FALSE) |>
    paste(collapse=", ")

  ifelse(vert.leng > 1, paste0("[", json_coords, "]"),
                         json_coords)
}
