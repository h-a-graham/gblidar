
gdal_paths_dtm_mos <- function(x){
  .tile <- stringr::str_extract(basename(x), "(?<=-)[^-.]*(?=\\.[^.]*$)")
  .model <- stringr::str_extract(basename(x), "(?<=-)[^-]+")
  .res <- stringr::str_match(basename(x), '([^-]+)(?:-[^-]+){2}$')[,2]

  paste0(paste("/vsizip//vsicurl",
               x,
               paste(.tile, .model, .res, sep="_"),
               sep="/"),
         ".tif")
}
