## code to prepare `osgb_grid` dataset goes here
library(usethis)
library(archive)
library(sf)

tf <- tempdir()

usethis::use_directory("inst/bng_grids")

all_grids <- file.path(tf,"os_bng_grids.7z")

download.file("https://github.com/OrdnanceSurvey/OS-British-National-Grids/raw/main/os_bng_grids.7z",
              all_grids)

archive_extract(all_grids, tf)

gpkg <- list.files(tf, full.names = TRUE, pattern = "\\.gpkg$")

st_layers(gpkg)

bng_5km <- read_sf(gpkg, layer="5km_grid")

write_sf(bng_5km, "inst/")

# usethis::use_data(osgb_grid, overwrite = TRUE, internal = TRUE)



