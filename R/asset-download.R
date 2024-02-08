#' Download gblidar assets
#'
#' Download all assets present in a `gbl_catalog` object. This is basically just
#' a wrapper around `curl::multi_download`.
#'
#' @param x A `gbl_catalog` object.
#' @param target_dir The parent directory declaring where files should be
#' downloaded
#' @param resume if the file already exists, resume the download. Note that
#' this may change server responses, see details.
#' @param progress logical. If TRUE a download progress is printed.
#' @param timeout numeric. Default is Inf i.e. download will continue until
#' completion.
#'
#' @return The function returns a data frame with one row for each downloaded
#' file and the following columns:
#'
#' * success if the HTTP request was successfully performed, regardless of the
#' response status code. This is FALSE in case of a network error, or in case
#' you tried to resume from a server that did not support this. A value of NA
#' means the download was interrupted while in progress.
#'
#' * status_code the HTTP status code from the request. A successful download is
#' usually 200 for full requests or 206 for resumed requests. Anything else
#' could indicate that the downloaded file contains an error page instead of
#' the requested content.
#'
#' * resumefrom the file size before the request, in case a download was resumed.
#'
#' * url final url (after redirects) of the request.
#'
#' * destfile downloaded file on disk.
#'
#' * error if success == FALSE this column contains an error message.
#'
#' * type the Content-Type response header value.
#'
#' * modified the Last-Modified response header value.
#'
#' *time total elapsed download time for this file in seconds.
#'
#' * headers vector with http response headers for the request.
#'
#' * save_location the detination that the file is saved in.
#' @export
#'
#' @examples
asset_download <- function(x, target_dir, resume = FALSE,
                           progress = TRUE, timeout = Inf) {
  dl_files <- gbl_urls(x)
  file_names <- gbl_paths(x)

  if (!dir.exists(target_dir)) dir.create(target_dir, recursive = TRUE)

  dl_paths <- file.path(target_dir, file_names)


  curl::multi_download(dl_files, dl_paths,
    progress = progress,
    timeout = timeout
  ) |>
    dplyr::mutate(save_location = dl_paths)
}
