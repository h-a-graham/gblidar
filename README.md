
<!-- README.md is generated from README.Rmd. Please edit that file -->

# gblidar

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

## Installation

You can install the development version of gblidar from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("h-a-graham/gblidar")
```

## Example

This is a super quick demo

``` r
library(gblidar)
library(sf)
#> Linking to GEOS 3.11.1, GDAL 3.6.2, PROJ 9.1.1; sf_use_s2() is TRUE

scafell_box <- st_point(c(321633 , 507181))  |>
  st_buffer(2000, endCapStyle = "SQUARE")  |>
  st_sfc() |>
  st_set_crs(27700)

scafell_catalog <- eng_search(scafell_box)
#> ℹ ESRI REST API request status: "esriJobSucceeded"

print(scafell_catalog)
#> Data Catalog
#> # A tibble: 21 × 5
#>    product                                   resolution  year urls   gdal_urls
#>    <chr>                                          <dbl> <int> <list> <list>   
#>  1 LIDAR Composite DTM                                1  2020 <chr>  <chr [2]>
#>  2 LIDAR Composite DTM                                1  2022 <chr>  <chr [2]>
#>  3 LIDAR Composite DTM                                2  2020 <chr>  <chr [2]>
#>  4 LIDAR Composite DTM                                2  2022 <chr>  <chr [2]>
#>  5 LIDAR Composite First Return DSM                   1  2020 <chr>  <chr [2]>
#>  6 LIDAR Composite First Return DSM                   1  2022 <chr>  <chr [2]>
#>  7 LIDAR Composite First Return DSM                   2  2020 <chr>  <chr [2]>
#>  8 LIDAR Composite First Return DSM                   2  2022 <chr>  <chr [2]>
#>  9 LIDAR Composite Last Return DSM                    1  2020 <chr>  <chr [2]>
#> 10 LIDAR Composite Last Return DSM                    1  2022 <chr>  <chr [2]>
#> 11 LIDAR Composite Last Return DSM                    2  2020 <chr>  <chr [2]>
#> 12 LIDAR Composite Last Return DSM                    2  2022 <chr>  <chr [2]>
#> 13 LIDAR Point Cloud                                 NA  2009 <chr>  <chr [2]>
#> 14 LIDAR Tiles DSM                                    1  2009 <chr>  <chr [2]>
#> 15 LIDAR Tiles DTM                                    1  2009 <chr>  <chr [2]>
#> 16 National LIDAR Programme DSM                       1  2019 <chr>  <chr [2]>
#> 17 National LIDAR Programme DTM                       1  2019 <chr>  <chr [2]>
#> 18 National LIDAR Programme First Return DSM          1  2019 <chr>  <chr [2]>
#> 19 National LIDAR Programme Intensity                 1  2019 <chr>  <chr [2]>
#> 20 National LIDAR Programme Point Cloud               1  2019 <chr>  <chr [2]>
#> 21 National LIDAR Programme VOM                       1  2019 <chr>  <chr [2]>
#> AOI Geometry
#> Geometry set for 1 feature 
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 319633 ymin: 505181 xmax: 323633 ymax: 509181
#> Projected CRS: OSGB36 / British National Grid
#> POLYGON ((323633 509181, 323633 505181, 319633 ...

DTM_catalog <- scafell_catalog |>
  filter_catalog(product == "LIDAR Composite DTM",
                 resolution == 2,
                 year == 2022)

print(DTM_catalog)
#> Data Catalog
#> # A tibble: 1 × 5
#>   product             resolution  year urls      gdal_urls
#>   <chr>                    <dbl> <int> <list>    <list>   
#> 1 LIDAR Composite DTM          2  2022 <chr [2]> <chr [2]>
#> AOI Geometry
#> Geometry set for 1 feature 
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 319633 ymin: 505181 xmax: 323633 ymax: 509181
#> Projected CRS: OSGB36 / British National Grid
#> POLYGON ((323633 509181, 323633 505181, 319633 ...

scafell_raster <- merge_assets(DTM_catalog, mask=TRUE)
#> 0...10...20...30...40...50...60...70...80...90...100 - done.

if (rlang::is_installed("terra")){
  library(terra)
  scafell <- rast(scafell_raster)
  plot(scafell, col=grDevices::hcl.colors(50, palette = "Sunset"))
}
#> terra 1.7.3
```

<img src="man/figures/README-example-1.png" width="100%" />

…
