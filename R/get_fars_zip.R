#' Download FARS data files as zipped CSV or SAS files
#'
#' This function provides an alternative to [get_fars_year()] that downloads
#' files directly from the NHTSA downloads site. If `read` is `TRUE`, the
#' function returns a list containing data frames for each table available in
#' the selected year. If `geometry` is `TRUE`, the accident table is converted
#' to an sf object.
#'
#' Zipped CSV files are converted to parquet files and cached in a folder
#' named after the zip file within `path` (by default, the user cache directory
#' from [tools::R_user_dir()]), and the zip and CSV files are removed unless
#' `keep_files = TRUE`. Later calls read the cached parquet files without
#' downloading the data again unless `overwrite = TRUE`.
#'
#' @param year One or more years of data from 1975 to 2024. Each year is
#'   downloaded separately and, if `read = TRUE`, returned as a list named by
#'   year. Defaults to `getOption("crashapi.year", 2024)`.
#' @param format Format of zipped data tables ('csv' or 'sas'). Default: 'csv'.
#'   `read = TRUE` and `geometry = TRUE` are only supported if format is "csv".
#' @param path Directory for downloaded and cached files. If `NULL` (default),
#'   uses `getOption("crashapi.cache_dir")` or the user cache directory from
#'   `tools::R_user_dir("crashapi", "cache")`.
#' @param pr If `TRUE`, download FARS data for Puerto Rico. Puerto Rico data is
#'   available for 1978 and from 1980 onwards. Default: `FALSE`
#' @param aux If `TRUE` and year is 1982 or later, download auxiliary
#'   FARS datasets that "contain data derived from the regular FARS/GES
#'   variables using NCSA analytical data classifications." In 2010, the NHTSA
#'   explained: "These classifications are widely used in NCSA publications and
#'   research. Many definitions such as "speeding-related" or "distracted
#'   driving" comprise a combination of variables whose names or attributes have
#'   changed over time. The derived variables in the auxiliary files incorporate
#'   these nuances, thus simplifying the use of standard classifications in any
#'   traffic safety research." Learn more from the FARS and GES Auxiliary
#'   Datasets Q & A:
#'   <https://crashstats.nhtsa.dot.gov/Api/Public/ViewPublication/811364>
#' @param read If `TRUE` (default), read the cached parquet files into a list
#'   of tables with each list item corresponding to one data file.
#' @param geometry If `TRUE`, convert the accident table to a sf object.
#' @param overwrite If `TRUE`, download the data and replace any cached files.
#'   Default: `FALSE`
#' @param keep_files If `TRUE`, keep the downloaded zip file and the extracted
#'   CSV files in the cache folder. Default: `FALSE`
#' @return If `read = TRUE`, a list of data frames with one item for each
#'   table (with the accident table converted to an sf object if `geometry =
#'   TRUE`). If `read = FALSE`, the cached parquet file paths named by table (or
#'   the zip file path if `format = "sas"`) invisibly. If more than one year is
#'   provided, returns a list named by year.
#' @inheritParams format_crashes
#' @rdname get_fars_zip
#' @export
#' @importFrom utils URLencode unzip
#' @importFrom glue glue
#' @importFrom cli cli_bullets cli_progress_along
#' @importFrom rlang check_installed
#' @importFrom stats setNames
get_fars_zip <- function(
  year = getOption("crashapi.year", 2024),
  format = "csv",
  path = NULL,
  pr = FALSE,
  aux = FALSE,
  read = TRUE,
  geometry = FALSE,
  overwrite = FALSE,
  keep_files = FALSE,
  var_labels = c("attribute", "none")
) {
  year <- validate_year(year = year, year_range = c(1975, 2024))

  if (length(year) > 1) {
    year <- unique(year)
    crash_data <- rlang::set_names(
      map(
        year,
        function(y) {
          get_fars_zip(
            year = y,
            format = format,
            path = path,
            pr = pr,
            aux = aux,
            read = read,
            geometry = geometry,
            overwrite = overwrite,
            keep_files = keep_files,
            var_labels = var_labels
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
  folder <- "National"
  scope <- "National"

  if (isTRUE(pr)) {
    if (year < 1978 || year == 1979) {
      cli_abort(
        c(
          "Puerto Rico data is not available for {year}.",
          "i" = "Puerto Rico data is available for 1978 and from 1980 onwards."
        )
      )
    }

    # The Puerto Rico folder name includes a space but the file names do not
    folder <- utils::URLencode("Puerto Rico")
    scope <- "PuertoRico"
  }

  auxiliary <- ""

  if (isTRUE(aux)) {
    if (year < 1982) {
      cli_warn(
        c(
          "Auxiliary data (when {.code aux = TRUE}) is only available from 1982
          onwards.",
          "i" = "Returning non-auxiliary data only."
        )
      )
    } else {
      auxiliary <- "Auxiliary"
    }
  }

  filename <- glue::glue("FARS{year}{scope}{auxiliary}{toupper(format)}.zip")
  remote_filename <- filename

  # The 1996 national auxiliary CSV file name is misspelled on the NHTSA site
  if (filename == "FARS1996NationalAuxiliaryCSV.zip") {
    remote_filename <- "FARS1996NationalAuxiliaryCVS.zip"
  }

  url <-
    glue::glue(
      "https://static.nhtsa.gov/nhtsa/downloads/FARS/{year}/{folder}/{remote_filename}"
    )

  get_zip_tables(
    dataset = "FARS",
    year = year,
    url = url,
    filename = filename,
    format = format,
    path = path,
    read = read,
    geometry = geometry,
    overwrite = overwrite,
    keep_files = keep_files,
    var_labels = var_labels
  )
}
