#' Download CRSS data files as zipped CSV or SAS files
#'
#' This function is similar to [get_fars_zip()] to download files directly from
#' the NHTSA downloads site. If `read` is `TRUE`, the function returns a list
#' containing data frames for each table available in the selected year. If
#' `geometry` is `TRUE`, the accident table is converted to an sf object.
#'
#' Zipped CSV files are converted to parquet files and cached in a folder
#' named after the zip file within `path` (by default, the user cache directory
#' from [tools::R_user_dir()]), and the zip and CSV files are removed unless
#' `keep_files = TRUE`. Later calls read the cached parquet files without
#' downloading the data again unless `overwrite = TRUE`.
#'
#' @param year One or more years of data from 2016 to 2024. Each year is
#'   downloaded separately and, if `read = TRUE`, returned as a list named by
#'   year. Defaults to `getOption("crashapi.year", 2024)`.
#' @param format Format of zipped data tables ('csv' or 'sas'). Default: 'csv'.
#'   `read = TRUE` and `geometry = TRUE` are only supported if format is "csv".
#' @param aux If `TRUE`, download auxiliary CRSS datasets.
#' @param read If `TRUE` (default), read the cached parquet files into a list
#'   of tables with each list item corresponding to one data file.
#' @param geometry If `TRUE`, convert the accident table to a sf object.
#' @param labels If `TRUE` (default), add a `"label"` attribute to each column
#'   with a matching variable in [fars_vars_labels]. Labels are taken from the
#'   FARS Analytical User's Manual so variables only used in CRSS are not
#'   labelled.
#' @inheritParams get_fars_zip
#' @return If `read = TRUE`, a list of data frames with one item for each
#'   table (with the accident table converted to an sf object if `geometry =
#'   TRUE`). If `read = FALSE`, the cached parquet file paths named by table (or
#'   the zip file path if `format = "sas"`) invisibly. If more than one year is
#'   provided, returns a list named by year.
#' @rdname get_crss_zip
#' @export
#' @importFrom glue glue
#' @importFrom cli cli_bullets cli_progress_along
#' @importFrom utils unzip
#' @importFrom rlang check_installed
#' @importFrom stats setNames
get_crss_zip <- function(
  year = getOption("crashapi.year", 2024),
  format = "csv",
  path = NULL,
  aux = FALSE,
  read = TRUE,
  geometry = FALSE,
  overwrite = FALSE,
  keep_files = FALSE,
  labels = TRUE
) {
  year <- validate_year(year = year, year_range = c(2016, 2024))

  if (length(year) > 1) {
    year <- unique(year)
    crash_data <- rlang::set_names(
      map(
        year,
        function(y) {
          get_crss_zip(
            year = y,
            format = format,
            path = path,
            aux = aux,
            read = read,
            geometry = geometry,
            overwrite = overwrite,
            keep_files = keep_files,
            labels = labels
          )
        }
      ),
      year
    )

    if (!read) {
      return(invisible(crash_data))
    }

    return(crash_data)
  }

  format <- match.arg(format, c("csv", "sas"))

  if (isTRUE(read) && format != "csv") {
    cli_abort(
      c(
        "{.code read = TRUE} is only supported when {.code format = \"csv\"}.",
        "i" = "Set {.code read = FALSE} to download SAS files without reading them."
      )
    )
  }

  auxiliary <- ""

  if (isTRUE(aux)) {
    auxiliary <- "Auxiliary"
  }

  filename <- glue::glue("CRSS{year}{auxiliary}{toupper(format)}.zip")

  url <-
    glue::glue(
      "https://static.nhtsa.gov/nhtsa/downloads/CRSS/{year}/{filename}"
    )

  get_zip_tables(
    dataset = "CRSS",
    year = year,
    url = url,
    filename = filename,
    format = format,
    path = path,
    read = read,
    geometry = geometry,
    overwrite = overwrite,
    keep_files = keep_files,
    labels = labels
  )
}
