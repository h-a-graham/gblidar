.onLoad <- function(lib, pkg) {
  op <- options()
  op.gblidar <- list(
    gblidar.progress = FALSE,
    gblidar.out_raster_type = "character"
  )
  toset <- !(names(op.gblidar) %in% names(op))
  if (any(toset)) options(op.gblidar[toset])

  invisible()
}

