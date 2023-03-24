## code to prepare `osgb_grid` dataset goes here
#make the os nat grid.

library(sf)
library(mapview)
library(ggplot2)
library(dplyr)

make_sf_box <- function(ll, ur, crs=st_crs(27700)){
  ll <- st_point(ll)
  ur <- st_point(ur)

  st_sfc(c(ll, ur)) |>
    st_bbox() |>
    st_as_sfc() |>
    st_set_crs(crs)
}

make_sf_grd <- function(ll, ur, .dist, crs=st_crs(27700)){
  make_sf_box(ll, ur, crs)|>
    st_make_grid(.dist) |>
    st_set_crs(crs) |>
    st_as_sf() |>
    rename(geometry=x)
}

make_osgb_grid <- function(){
  suppressMessages({
    suppressWarnings({osgb_ext <- make_sf_grd(c(0, 0), c(7e5, 13e5), 1e5)

    hnsot_ext <- make_sf_grd(c(0, 0), c(10e5, 15e5), 5e5) |>
      mutate(reg_code= c("S", "T", "N", "O", "H", "J"))


    let_rev <- rev(letters[!letters == "i"]) |>
      split(rep(1:5, rep(5, 5))) |>
      lapply(function(x) rev(x)) |>
      unlist() |>
      toupper()

    km100_grd <- make_sf_grd(c(0, 0), c(10e5, 15e5), 1e5) |>
      st_join(hnsot_ext, largest=TRUE) |>
      group_by(reg_code) |>
      mutate(cell_code = let_rev,
             tile_name_100km = paste0(reg_code, cell_code)) |>
      dplyr::filter(st_covered_by(geometry, make_sf_box(c(0, 0), c(7e5, 13e5)), sparse = FALSE)[,1])

    km50grd <- make_sf_grd(c(0, 0), c(7e5, 13e5), 5e4) |>
      st_join(km100_grd, largest=TRUE) |>
      group_by(tile_name_100km) |>
      mutate(tile_name50km = paste0(tile_name_100km, c("SW", "SE", "NW", "NE"))) |>
      ungroup() |>
      select(tile_name_100km, tile_name50km)
    st_geometry(km50grd) <- "geometry"})
  })
  return(km50grd)
}

osgb_grid <- make_osgb_grid()

usethis::use_directory("inst/osgb_grid")
write_sf(osgb_grid, "inst/osgb_grid/osgb_grid.gpkg")

# usethis::use_data(osgb_grid, overwrite = TRUE, internal = TRUE)
