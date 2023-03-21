#' Title
#'
#' @param aoi
#'
#' @return
#' @export
#'
#' @examples
eng_search <- function(aoi){

  aoi <- wk::as_wkt(aoi)

  job <- create_rest_api_job(aoi)

  sub_job <- submit_rest_api_job(job$jobId)

  job_results <- request_api_job_results(job$jobId)

  url_df <- tabulise_api_response(job_results$data)

  gbl_catalog(gbl_tab = url_df,
              aoi = aoi,
              date_time = job_results$completedTimestamp)
}
