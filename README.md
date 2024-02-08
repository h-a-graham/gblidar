
<!-- README.md is generated from README.Rmd. Please edit that file -->

# gblidar

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

# To Do List:

  - [x] Added options for merging rasters and exporting as SpatRaster,
    stars of character.
  - [x] Generic merge for all rasters in gbl\_catalog.
  - [ ] Add special functions for hitting the WCS data to get faster
    access to large composite areas.
  - [ ] chunk large requested areas to prevent exceeding the EA API
    limit.
  - [ ] Add Scottish Data
  - [ ] Add Welsh Data
  - [ ] Write Tests

**Scottish and Welsh Data are yet to be added as the tricky thing to get
right is the English ESRI API stuff - once this is stable we can slot
the other nations in with relative ease I hope**

## Installation

You can install the development version of gblidar from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pkg_install("h-a-graham/gblidar")
```

## Example

This is a super quick demo

``` r
library(gblidar)
library(sf)
#> Linking to GEOS 3.12.1, GDAL 3.6.4, PROJ 9.1.1; sf_use_s2() is TRUE
#> WARNING: different compile-time and runtime versions for GEOS found:
#> Linked against: 3.12.1-CAPI-1.18.1 compiled against: 3.11.1-CAPI-1.17.1
#> It is probably a good idea to reinstall sf, and maybe rgeos and rgdal too
if (rlang::is_installed("terra")) {
  library(terra)
  options(gblidar.out_raster_type = "SpatRaster")
}
#> terra 1.7.50
#> WARNING: different compile-time and run-time versions of GEOS
#> Compiled with:3.11.1-CAPI-1.17.1
#>  Running with:3.12.1-CAPI-1.18.1
#> 
#> You should reinstall package 'terra'

scafell_box <- st_point(c(321633, 507181)) |>
  st_buffer(2000) |>
  st_sfc() |>
  st_set_crs(27700)

scafell_catalog <- eng_search(scafell_box)

print(scafell_catalog)
#> Data Catalog
#> # A tibble: 28 × 5
#>    product                                   resolution  year filenames urls  
#>    <chr>                                          <dbl> <int> <list>    <list>
#>  1 LIDAR Composite DTM                                1  2022 <chr [9]> <chr> 
#>  2 LIDAR Composite DTM                                2  2022 <chr [9]> <chr> 
#>  3 LIDAR Composite First Return DSM                   1  2022 <chr [9]> <chr> 
#>  4 LIDAR Composite First Return DSM                   2  2022 <chr [9]> <chr> 
#>  5 LIDAR Composite Last Return DSM                    1  2022 <chr [9]> <chr> 
#>  6 LIDAR Composite Last Return DSM                    2  2022 <chr [9]> <chr> 
#>  7 LIDAR Point Cloud                                 NA  2008 <chr [1]> <chr> 
#>  8 LIDAR Point Cloud                                 NA  2009 <chr [8]> <chr> 
#>  9 LIDAR Tiles DSM                                    1  2007 <chr [2]> <chr> 
#> 10 LIDAR Tiles DSM                                    1  2008 <chr [3]> <chr> 
#> 11 LIDAR Tiles DSM                                    1  2009 <chr [8]> <chr> 
#> 12 LIDAR Tiles DSM                                    2  2000 <chr [2]> <chr> 
#> 13 LIDAR Tiles DTM                                    1  2007 <chr [2]> <chr> 
#> 14 LIDAR Tiles DTM                                    1  2008 <chr [3]> <chr> 
#> 15 LIDAR Tiles DTM                                    1  2009 <chr [8]> <chr> 
#> 16 LIDAR Tiles DTM                                    2  2000 <chr [2]> <chr> 
#> 17 National LIDAR Programme DSM                       1  2019 <chr [7]> <chr> 
#> 18 National LIDAR Programme DSM                       1  2021 <chr [2]> <chr> 
#> 19 National LIDAR Programme DTM                       1  2019 <chr [7]> <chr> 
#> 20 National LIDAR Programme DTM                       1  2021 <chr [2]> <chr> 
#> 21 National LIDAR Programme First Return DSM          1  2019 <chr [7]> <chr> 
#> 22 National LIDAR Programme First Return DSM          1  2021 <chr [2]> <chr> 
#> 23 National LIDAR Programme Intensity                 1  2019 <chr [7]> <chr> 
#> 24 National LIDAR Programme Intensity                 1  2021 <chr [2]> <chr> 
#> 25 National LIDAR Programme Point Cloud               1  2019 <chr [7]> <chr> 
#> 26 National LIDAR Programme Point Cloud               1  2021 <chr [2]> <chr> 
#> 27 National LIDAR Programme VOM                       1  2019 <chr [7]> <chr> 
#> 28 National LIDAR Programme VOM                       1  2021 <chr [2]> <chr>
#> AOI Geometry
#> Geometry set for 1 feature 
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 319633 ymin: 505181 xmax: 323633 ymax: 509181
#> Projected CRS: OSGB36 / British National Grid
#> POLYGON ((323633 507181, 323630.3 507076.3, 323...
#> Tile Names
#> [1] "NY10NE" "NY20NW"

DTM_catalog <- scafell_catalog |>
  filter_catalog(
    product == "LIDAR Composite DTM",
    resolution == 2,
    year == 2022
  )

print(DTM_catalog)
#> Data Catalog
#> # A tibble: 1 × 5
#>   product             resolution  year filenames urls     
#>   <chr>                    <dbl> <int> <list>    <list>   
#> 1 LIDAR Composite DTM          2  2022 <chr [9]> <chr [9]>
#> AOI Geometry
#> Geometry set for 1 feature 
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 319633 ymin: 505181 xmax: 323633 ymax: 509181
#> Projected CRS: OSGB36 / British National Grid
#> POLYGON ((323633 507181, 323630.3 507076.3, 323...
#> Tile Names
#> [1] "NY10NE" "NY20NW"

scafell_raster <- merge_assets(DTM_catalog, mask = TRUE)

plot(scafell_raster, col = grDevices::hcl.colors(50, palette = "Sunset"))
```

<img src="man/figures/README-example-1.png" width="100%" />

…
