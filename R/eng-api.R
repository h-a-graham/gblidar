
eng_api_endpoint <- function() {
  "https://environment.data.gov.uk/backend/catalog/api/tiles/collections/survey/search"
}

eng_api_headers <- function() {
  c(
    "Accept" = "*/*",
    "Accept-Encoding" = "gzip, deflate, br",
    "Accept-Language" = "en-US,en;q=0.9",
    "Content-Type" = "application/geo+json",
    "Cookie" = "defra-cookie-banner-dismissed=true",
    "Origin" = "https://environment.data.gov.uk",
    "Referer" = "https://environment.data.gov.uk/survey"
  )
}

eng_tab_response <- function(eng_response) {
  get_num <- function(x) { # possibly not needed if new api has no < 1m imagery
    as.numeric(stringr::str_extract(x, "(\\d)+"))
  }

  response_df <- jsonlite::fromJSON(eng_response)$results |>
    tibble::as_tibble() |>
    tidyr::unnest(
      cols = c(product, year, resolution, tile),
      names_sep = "_"
    ) |>
    dplyr::select(
      product = product_label,
      resolution = resolution_id,
      year = year_label,
      filename = label,
      url = uri
    ) |>
    dplyr::mutate(
      url = paste0(url, "?subscription-key=public"),
      filename = paste0(filename, ".zip")
    ) |>
    dplyr::group_by(product, resolution, year) |>
    dplyr::reframe(
      filenames = list(filename),
      urls = list(url)
    ) |>
    dplyr::mutate(
      resolution =
        dplyr::case_when(
          stringr::str_detect(resolution, "CM") ~
            get_num(resolution) / 100,
          TRUE ~ get_num(resolution)
        ),
      year = as.integer(year)
    )
}

#' format the area of interest for the Environment Agency API
#' @param aoi A spatial area to request: Can be any of the following classes:
#'
eng_post_feature <- function(aoi) {
  aoi |>
    sf::st_union() |>
    sf::st_transform(4326)
}
