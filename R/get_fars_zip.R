
#' Download FARS data files as zipped CSV or SAS files
#'
#' This function provides an alternative to [get_fars_year()] that downloads
#' files directly from NHTSA FTP site. If read is `TRUE`, the function reads a
#' list containing data frames for each table available in the selected year. If
#' geo is `TRUE`, the accident table is converted to an sf object.
#'
#' @param year Year of data from 1975 to 2020, Default: 2020
#' @param format Format of zipped data tables ('csv' or 'sas'). Default: 'csv'.
#'   unzip and geo options are only supported if format is "csv".
#' @param path Path to download zip file with FARS tables.
#' @param pr If `TRUE`, download FARS data for Puerto Rico. No Puerto Rico data
#'   available for years 1975-1977. Default: `FALSE`
#' @param aux If `TRUE` and year is after 1982, download auxiliary
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
#' @param read If `TRUE`, unzip the downloaded file and read CSV files into a
#'   list of tables with each list item corresponding to one CSV file.
#' @param geometry If `TRUE`, convert the accident table to a sf object.
#' @return Downloads zip file with CSV or SAS tables and returns `NULL` invisibly
#'   or returns a list of data frames (if geo is `FALSE`), or returns a list of
#'   data frames with the accident table converted to a sf object.
#' @rdname get_fars_zip
#' @export
#' @importFrom utils URLencode
#' @importFrom glue glue
#' @importFrom stats setNames
get_fars_zip <- function(year = 2020,
                         format = "csv",
                         path = NULL,
                         pr = FALSE,
                         aux = FALSE,
                         read = TRUE,
                         geometry = FALSE) {
  year <- validate_year(year = year, year_range = c(1975:2020))
  format <- match.arg(format, c("csv", "sas"))
  scope <- "National"

  if (pr) {
    scope <- utils::URLencode("Puerto Rico")
  }

  auxiliary <- ""

  if (aux) {
    auxiliary <- "Auxiliary"
    if (year < 1982) {
      cli_warn(
        c("Auxiliary data (when {.code aux = TRUE}) is only available for years
        after 1982.",
          "i" = "Setting {.code aux = FALSE} to return non-auxiliary data."
        )
      )
      auxiliary <- ""
    }
  }

  filename <-
    glue::glue("FARS{year}{scope}{auxiliary}{toupper(format)}.zip")

  url <-
    glue::glue(
      "https://static.nhtsa.gov/nhtsa/downloads/FARS/{year}/{scope}/{filename}"
    )

  if (is.null(path)) {
    path <- gsub("//", "/", tempdir())
  }

  destfile <- file.path(path, filename)

  download.file(
    url = url,
    destfile = destfile,
    method = "auto"
  )

  if (!read) {
    return(invisible(NULL))
  }

  exdir <-
    file.path(path, gsub("\\.zip$", "", filename))

  utils::unzip(
    zipfile = destfile,
    exdir = exdir,
    overwrite = TRUE,
    list = FALSE
  )

  files <-
    list.files(
      path = exdir,
      full.names = TRUE
    )

  stopifnot(format == "csv")

  crash_tables <-
    stats::setNames(
      purrr::map(
        cli::cli_progress_along(files, "Reading data"),
        ~ readr::read_csv(
          file = files[.x],
          progress = FALSE,
          show_col_types = FALSE
        )
      ),
      nm = tolower(gsub(".CSV", "", basename(files), ignore.case = TRUE))
    )

  if (geometry) {
    crash_tables$accident <-
      df_to_sf(crash_tables$accident)
  }

  crash_tables
}
