assert_aoi <- function(x) {
  aoi.class <- class(x)[1]
  if (!aoi.class %in% c("sf", "sfc_POLYGON", "character")) {
    cli::cli_abort(
      c("Incorrect AOI class!",
        "i" = "aoi must inherit from one of the following classes: 'sf', 'sfc' or 'character' not {aoi.class} "
      )
    )
  }

  if (is.character(x)) x <- sf::read_sf(x)

  x <- x |>
    sf::st_as_sf() |>
    sf::st_transform(27700) |>
    wk::wk_flatten()

  if (nrow(x) > 1) {
    x <- sf::st_convex_hull(sf::st_union(x))

    cli::cli_warn(c("The provided AOI has {nrow(x)} polygons. A single polygon
                    is required",
      "i" = "The AOI has been converted to the convex hull of
                    the combined inputs.",
      "i" = "This could result in a much larger requested area
                    than expected."
    ))
  }

  return(sf::st_as_sfc(x))
}


assert_no_point_cloud <- function(x) {
  if ("LIDAR Point Cloud" %in% x$gbl_tab$product) {
    cli::cli_abort({
      c("Merging Point Cloud data is not currently supported.",
        "i" = "If this was not intended, you can filter these data out with `filter_catalog()` ",
        "i" = "If you do want to merge Point Cloud data, use `asset_download()` and merge with the lidR package."
      )
    })
  }
}


assert_rast <- function(x) {
  if (length(x) != 1) {
    cli::cli_abort("raster_class must be of length 1!")
  }

  if (!x %in% c("character", "SpatRaster", "stars")) {
    cli::cli_abort(
      c("Incorrect raster_class specified!",
        "i" = "raster_class must be one of the following:
        'character', 'SpatRaster', 'stars' not {x} "
      )
    )
  }

  pkg_check <- function(x) {
    switch(x,
      character = invisible(),
      SpatRaster = check_pkgs("terra", x),
      stars = check_pkgs("stars", x)
    )
  }

  pkg_check(x)
}

check_pkgs <- function(x, obj) {
  if (isFALSE(rlang::is_installed(x))) {
    cli::cli_abort(c("The {x} package is not installed but is required when using {obj} as 'raster_class' argument.",
      "i" = "To install this package run: `install.packages('{x}')`"
    ))
  }
}
