
#' Download CRSS data files as zipped CSV or SAS files
#'
#' This function is similar to [get_fars_zip()] to download
#' files directly from NHTSA FTP site. If read is `TRUE`, the function reads a
#' list containing data frames for each table available in the selected year. If
#' geo is `TRUE`, the accident table is converted to an sf object.
#'
#' @param year Year of data from 2016 to 2020, Default: 2020
#' @param format Format of zipped data tables ('csv' or 'sas'). Default: 'csv'.
#'   unzip and geo options are only supported if format is "csv".
#' @param aux If `TRUE`, download auxiliary
#'   CRSS datasets .
#' @param read If `TRUE`, unzip the downloaded file and read CSV files into a
#'   list of tables with each list item corresponding to one CSV file.
#' @param geometry If `TRUE`, convert the accident table to a sf object.
#' @inheritParams get_fars_zip
#' @return Downloads zip file with CSV or SAS tables and returns `NULL` invisibly
#'   or returns a list of data frames (if geo is `FALSE`), or returns a list of
#'   data frames with the accident table converted to a sf object.
#' @rdname get_crss_zip
#' @export
#' @importFrom utils URLencode
#' @importFrom glue glue
#' @importFrom stats setNames
get_crss_zip <- function(year = 2020,
                         format = "csv",
                         path = NULL,
                         aux = FALSE,
                         read = TRUE,
                         geometry = FALSE,
                         overwrite = FALSE) {
  year <- validate_year(year = year, year_range = c(2016:2020))
  format <- match.arg(format, c("csv", "sas"))

  auxiliary <- ""

  if (aux) {
    auxiliary <- "Auxiliary"
  }

  filename <-
    glue::glue("CRSS{year}{auxiliary}{toupper(format)}.zip")

  url <-
    glue::glue(
      "https://static.nhtsa.gov/nhtsa/downloads/CRSS/{year}/{filename}"
    )

  if (is.null(path)) {
    path <- getwd() # tempdir() # gsub("//", "/", tempdir())
  }

  destfile <- file.path(path, filename)

  if (file.exists(destfile) & !overwrite) {
    cli::cli_abort(
      c("File {.file {filename}} exists at {.path {path}}.",
        "i" = "Set {.code overwrite = TRUE} to overwrite existing file.")
    )
  }

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
