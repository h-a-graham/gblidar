
api_headers <- function(include_anm=FALSE){
  h <- c(
    `User-Agent` = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:103.0) Gecko/20100101 Firefox/103.0',
    `Accept` = '*/*',
    `Accept-Language` = 'en-US,en;q=0.5',
    `Accept-Encoding` = 'gzip, deflate, br',
    `Connection` = 'keep-alive',
    `Referer` = 'https://environment.data.gov.uk/DefraDataDownload/?Mode=survey',
    `Sec-Fetch-Dest` = 'empty',
    `Sec-Fetch-Mode` = 'cors',
    `Sec-Fetch-Site` = 'same-origin'
  )
  if (isTRUE(include_anm)){
    h <- c(h,
           `If-None-Match` = 'cad21b43')
  }
  return(h)
}

get_api_results <- function(job_id, headers, params, cookies){
  function() {httr::GET(url =
              paste0('https://environment.data.gov.uk/arcgis/rest/services/gp/DataDownload/GPServer/DataDownload/jobs/',
                     job_id),
            httr::add_headers(.headers=headers),
            query = params, httr::set_cookies(.cookies = cookies))}
}


api_cookies <- function(){
  c('AGS_ROLES' = '"419jqfa+uOZgYod4xPOQ8Q=="')
}


create_rest_api_job <- function(aoi){
  # make request with polygon

  headers <- api_headers(include_anm=TRUE)

  # insert polygons into params
  params = list(
    `f` = 'json',
    `SourceToken` = '',
    `OutputFormat` = '0',
    `RequestMode` = 'SURVEY',
    `AOI` = json_geoms(aoi)
  )

  res <-
    httr::GET(url =
                'https://environment.data.gov.uk/arcgis/rest/services/gp/DataDownload/GPServer/DataDownload/submitJob',
              httr::add_headers(.headers=headers), query = params)

  if (isTRUE(httr::http_error(res))){
    cli::cli_abort("Error when submitting polygon extent.")
  }

  httr::content(res,as="parsed")
}


submit_rest_api_job <- function(job_id){
  # submit queries until results
  params = list(
    `f` = 'json',
    `dojo.preventCache` = '1662031406539'
  )

  get_results <- get_api_results(job_id, api_headers(), params, api_cookies())



  sp1 <- cli::make_spinner()
  fun_with_spinner <- function() {
    res <- get_results()

    jsonRespParsed <- httr::content(res,as="parsed")

    while (jsonRespParsed$jobStatus %in% c("esriJobSubmitted", 'esriJobExecuting')) {
      sp1$spin()
      Sys.sleep(0.5)
      res <- get_results()
      jsonRespParsed <- httr::content(res,as="parsed")
    }
    sp1$finish()

    job_status <- jsonRespParsed$jobStatus
    cli::cli_inform(
      c("i" = 'ESRI REST API request status: "{job_status}"'))
    return(jsonRespParsed)
  }
  fun_with_spinner()


  # message(jsonRespParsed$jobStatus)
}

request_api_job_results <- function(job_id){
  params = list(
    `f` = 'json',
    `dojo.preventCache` = '1662033674668'
  )

  get_result <- get_api_results(paste0(job_id, '/results/OutputResult'),
                                api_headers(),
                                params,
                                api_cookies())

  res <- get_result()
  if (isTRUE(httr::http_error(res))){
    cli::cli_abort("Error when requesting API results.")
  }
  jsonRespParsed<-httr::content(res,as="parsed")


  jsonlite::fromJSON(jsonRespParsed$value$url)
}


tabulise_api_response <- function(job_data){
  urls <- tibble::tibble(job_data)


  y <- tidyr::unnest(urls, cols = c(years)) |>
    tidyr::unnest(cols = c(resolutions)) |>
    tidyr::unnest(cols = c(tiles))

  .cols <- colnames(y)[! colnames(y) %in% c("url")]

  dplyr::group_by(y, productName, resolutionName, year) |>
    dplyr::reframe(urls = list(url))

}

