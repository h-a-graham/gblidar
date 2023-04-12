#' Search the Environment Agency LiDAR/Geo API for data in England.
#'
#' @param aoi A spatial area to request: Can be any of the following classes:
#' sf, sfc or character. When a character is provided it must be a gdal readable
#' spatial vector file format.
#'
#' @return An object of class `gbl_catalog`
#' @export
#'
#' @examples
#'
#'
#'
eng_search <- function(aoi){

  aoi <- assert_aoi(aoi)

  search_aoi <- bng_tile_intersect(aoi)

  job <- create_rest_api_job(sf::st_union(search_aoi))

  sub_job <- submit_rest_api_job(job$jobId)

  job_results <- request_api_job_results(job$jobId)

  url_df <- tabulise_api_response(job_results$data)

  gbl_catalog(
    gbl_tab = url_df,
    aoi = aoi,
    date_time = job_results$completedTimestamp,
    search_aoi = search_aoi
  )
}

#place holder
wales_search <- function(aoi){
  cli::cli_abort("Nothing to see here... yet.")
}

#place holder
scot_search <- function(aoi){
  cli::cli_abort("Nothing to see here... yet.")
}

# pseudo code definitely not working yet.
gb_seach <- function(aoi){
  ws <- wales_search()
  ss <- scot_search()
  es <- eng_search()

  url_df <- bind_rows(ws, ss, es)

}
