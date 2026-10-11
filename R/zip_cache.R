#' Get the directory used to cache downloaded data
#' @noRd
crashapi_cache_dir <- function() {
  getOption("crashapi.cache_dir", tools::R_user_dir("crashapi", "cache"))
}

#' Download a zip file of FARS or CRSS data and read the tables
#'
#' CSV files are converted to parquet files in a folder named after the zip
#' file within `path` and the zip and CSV files are removed unless `keep_files =
#' TRUE`. If the parquet files already exist, they are read without downloading
#' the zip file again unless `overwrite = TRUE`. SAS zip files are downloaded to
#' the same folder and are not converted or read.
#'
#' @param dataset "FARS" or "CRSS".
#' @param url URL for the zip file.
#' @param filename File name for the zip file.
#' @returns If `read = FALSE`, the zip file path (for SAS files) or a named
#'   vector of parquet file paths (invisibly). If `read = TRUE`, a named list of
#'   tables.
#' @noRd
get_zip_tables <- function(
  dataset,
  year,
  url,
  filename,
  format = "csv",
  path = NULL,
  read = TRUE,
  geometry = FALSE,
  overwrite = FALSE,
  keep_files = FALSE,
  var_labels = c("attribute", "none"),
  call = caller_env()
) {
  path <- path %||% crashapi_cache_dir()
  cache_path <- file.path(path, dataset, year, sub("[.]zip$", "", filename))
  dir.create(cache_path, recursive = TRUE, showWarnings = FALSE)

  zipfile <- file.path(cache_path, filename)

  if (format == "sas") {
    if (!file.exists(zipfile) || isTRUE(overwrite)) {
      download.file(url = url, destfile = zipfile, method = "auto", mode = "wb")
    }

    return(invisible(zipfile))
  }

  parquet_files <- list_parquet_files(cache_path)

  if (isTRUE(overwrite)) {
    unlink(parquet_files)
    parquet_files <- character(0)
  }

  if (length(parquet_files) == 0) {
    parquet_files <- zip_csv_to_parquet(
      url = url,
      zipfile = zipfile,
      cache_path = cache_path,
      overwrite = overwrite,
      keep_files = keep_files,
      call = call
    )
  }

  if (!read) {
    return(invisible(parquet_files))
  }

  crash_tables <- map(parquet_files, nanoparquet::read_parquet)

  if (geometry) {
    coords <- c("LONGITUD", "LATITUDE")
    accident <- crash_tables[["accident"]]

    if (!is.null(accident) && all(coords %in% names(accident))) {
      crash_tables[["accident"]] <- df_to_sf(accident)
    } else {
      cli::cli_warn(
        "{dataset} data for {year} doesn't include coordinate columns so
        {.code geometry = TRUE} is ignored.",
        call = call
      )
    }
  }

  if (!use_var_labels(var_labels)) {
    return(crash_tables)
  }

  Map(label_fars_vars, crash_tables, toupper(names(crash_tables)))
}

#' List parquet files in a folder named by table
#' @noRd
list_parquet_files <- function(path) {
  files <- list.files(path, pattern = "[.]parquet$", full.names = TRUE)
  rlang::set_names(files, sub("[.]parquet$", "", basename(files)))
}

#' Download a zip file and convert the CSV files to parquet files
#' @noRd
zip_csv_to_parquet <- function(
  url,
  zipfile,
  cache_path,
  overwrite = FALSE,
  keep_files = FALSE,
  call = caller_env()
) {
  rlang::check_installed("readr", call = call)

  if (!file.exists(zipfile) || isTRUE(overwrite)) {
    download.file(url = url, destfile = zipfile, method = "auto", mode = "wb")
  }

  exdir <- sub("[.]zip$", "", zipfile)
  utils::unzip(zipfile = zipfile, exdir = exdir, overwrite = TRUE)

  csv_files <- list.files(
    path = exdir,
    # Newer zip files contain a folder with the CSV files
    pattern = "[.]csv$",
    ignore.case = TRUE,
    recursive = TRUE,
    full.names = TRUE
  )

  tables <- tolower(sub("[.]csv$", "", basename(csv_files), ignore.case = TRUE))
  parquet_files <- rlang::set_names(
    file.path(cache_path, paste0(tables, ".parquet")),
    tables
  )

  for (i in cli::cli_progress_along(csv_files, "Converting CSV to parquet")) {
    crash_df <- readr::read_csv(
      file = csv_files[[i]],
      # Guess column types using all rows so types are consistent
      guess_max = 1e6,
      progress = FALSE,
      show_col_types = FALSE
    )

    # Some older CSV files include Latin-1 encoded text (e.g. MCARR_ID in
    # 2015 vehicle data)
    crash_df[] <- lapply(crash_df, fix_latin1)

    nanoparquet::write_parquet(crash_df, parquet_files[[i]])
  }

  if (!isTRUE(keep_files)) {
    unlink(c(zipfile, exdir), recursive = TRUE)
  }

  parquet_files
}

#' Convert character values that aren't valid UTF-8 from Latin-1
#' @noRd
fix_latin1 <- function(x) {
  if (!is.character(x)) {
    return(x)
  }

  invalid <- !is.na(x) & !validUTF8(x)

  if (any(invalid)) {
    x[invalid] <- iconv(x[invalid], from = "latin1", to = "UTF-8")
  }

  x
}
