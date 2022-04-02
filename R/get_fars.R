#' @title Get Fatality Analysis Reporting System (FARS) data with the FARS API
#' @description This function provides a convenient interface for accessing FARS
#'   data or data summaries using a range of criteria. The `api` parameter
#'   allows you to call one of the following functions to access DOT NHTSA’s
#'   Crash API:
#'
#'   - `get_fars_crash_list` returns a list of fatal crashes that have occurred
#'   in multiple states in one or more years.
#'   - `get_fars_crash_details` returns a details of a fatal crash that has
#'   occurred in a state for a single year.
#'   - `get_fars_crashes` a list of fatal crashes by location that have occurred
#'   throughout U.S.
#'   - `get_fars_summary` provides a count of injury severity that have occurred
#'   throughout U.S. including count of fatalities and crashes.
#'   - `get_fars_year` provides one of 20 FARS data tables for a single year.
#'   Supports downloading to a CSV or JSON file.
#'
#'   Both `get_fars_crash_list` and `get_fars_crashes` limit the returned data to
#'   5000 records so consider limiting the range of years requested if data
#'   exceeds that threshold.
#'
#'   This package also enables access to the FARS data available through the
#'   NHTSA data downloads server in a zip format. Set `api` to "zip" or use the
#'   `get_fars_zip` function to download this data.
#'
#' @param year numeric vector. Year or range with start and end year. If `api`
#'   is "details", "year dataset", or "zip" (or using the
#'   `get_fars_crash_details`, `get_fars_year`, or `get_fars_zip` functions), a
#'   single year is required. All other `api` options support a range with the
#'   minimum value is used as a start year and the maximum value used as a end
#'   year. Most `api` options support the years from 2010 to 2019. "year
#'   dataset" only supports 2010 to 2017 and "zip" supports 1975 to 2019.
#'   `start_year` and `end_year` are ignored if `year` is not NULL.
#' @param api character. API function to use. Supported values include
#'   "crashes", "cases", "state list", "summary count", "year dataset", and
#'   "zip". Default: "crashes".
#' @param start_year Start year for crash reports.
#' @param end_year End year for crash reports.
#' @param state Required. State name, abbreviation, or FIPS number.
#'   `get_fars_crash_list` supports multiple states.
#' @param county  County name or FIPS number. Required for `get_fars_crashes`.
#' @param geometry If TRUE, return sf object. Optional for `get_fars_crashes`.
#' @param crs Coordinate reference system to return for `get_fars_crashes` if
#'   `geometry` is TRUE.
#' @param type Name of the dataset or data file to download when using the "year
#'   dataset" api or `get_fars_year`. Supported values include "ACCIDENT",
#'   "CEVENT", "DAMAGE", "DISTRACT", "DRIMPAIR", "FACTOR", "MANEUVER",
#'   "NMCRASH", "NMIMPAIR", "NMPRIOR", "PARKWORK", "PBTYPE", "PERSON",
#'   "SAFETYEQ", "VEHICLE", "VEVENT VINDECODE", "VINDERIVED", "VIOLATION",
#'   "VISION", and "VSOE". Lowercase or mixed case values are permitted.
#' @param cases One or more FARS case numbers. Required if `api` is "cases" or
#'   using `get_fars_cases`. Multiple case numbers can be provided.
#' @param details Type of detailed crash data to return (either "events" or
#'   "vehicles"). If TRUE for `get_fars` or `get_fars_crashes`, detailed case
#'   data (excluding event and vehicle data) is attached to the returned crash
#'   data. If NULL for `get_fars_cases`, events and vehicle data are excluded
#'   from the returned case data. returned by `get_fars_cases`. Optional for
#'   `get_fars_crash_details`. Default: NULL for `get_fars_cases`; FALSE for
#'   `get_fars` and `get_fars_crashes`.
#' @param vehicles numeric vector with the minimum and maximum number of
#'   vehicles, e.g. c(1, 2) for minimum of 1 vehicle and maximum of 2. Required
#'   for `get_fars_crash_list`.
#' @param pr logical. If TRUE, download zip file with FARS data for Puerto Rico.
#'   No Puerto Rico data available for years 1975-1977. Default: FALSE for
#'   `get_fars_zip` only.
#' @param format Default "json". "csv" is supported when using the "year
#'   dataset" api. "sas" is supporting for the "zip" api.
#' @param path File path used if download is TRUE.
#' @param download logical. If TRUE and the `api` is "year dataset" or "zip",
#'   download the data to a file. Default FALSE.
#' @param progress_bar If TRUE, display a progress bar when downloading detailed
#'   data with `get_fars_cases()` or another function that calls this function.
#'   Default TRUE.
#' @rdname get_fars
#' @export
#' @md
#' @importFrom jsonlite read_json
get_fars <- function(year = 2019,
                     state,
                     county = NULL,
                     api = c("crashes", "cases", "state list", "summary count", "year dataset", "zip"),
                     type,
                     details = FALSE,
                     geometry = FALSE,
                     crs = 4326,
                     cases,
                     vehicles,
                     format = "json",
                     pr,
                     path = NULL,
                     download = FALSE) {
  if (!missing(cases)) {
    api <- "cases"
  } else if (!missing(vehicles)) {
    api <- "state list"
  } else if (!missing(type)) {
    api <- "year dataset"
  } else if (!missing(pr)) {
    api <- "zip"
  }

  api <- match.arg(api)

  switch(api,
    "crashes" =
      get_fars_crashes(
        year = year,
        state = state,
        county = county,
        details = details,
        geometry = geometry,
        crs = crs
      ),
    "cases" =
      get_fars_cases(
        year = year,
        state = state,
        cases = cases,
        geometry = geometry,
        crs = crs,
        details = details
      ),
    "state list" =
      get_fars_crash_list(
        year = year,
        state = state,
        vehicles = vehicles
      ),
    "summary count" =
      get_fars_summary(
        year = year,
        state = state
      ),
    "year dataset" =
      get_fars_year(
        year = year,
        type = type,
        format = format,
        download = download
      ),
    "zip" =
      get_fars_zip(
        year = year,
        path = path,
        format = format,
        pr = pr
      )
  )
}

#' @rdname get_fars
#' @aliases get_fars_crashes
#' @export
#' @importFrom usethis ui_stop
#' @importFrom overedge df_to_sf
get_fars_crashes <- function(year = NULL,
                             start_year,
                             end_year,
                             state,
                             county = NULL,
                             details = FALSE,
                             geometry = FALSE,
                             crs = 4326) {
  year <- validate_year(year, start_year = start_year, end_year = end_year)
  fips <- lookup_fips(state, county, list = TRUE)

  if (is.null(county)) {
    usethis::ui_stop("A valid county name or FIPS is required to crash data with locations.")
  }

  crash_df <-
    read_crashapi(
      data = "crashes",
      type = "GetCrashesByLocation",
      fromCaseYear = min(year),
      toCaseYear = max(year),
      state = fips$state,
      county = fips$county,
      format = "json"
    )

  if (details) {
    # FIXME: This could break for multi year searches.
    cases_df <- get_fars_cases(year = year, state = state, cases = crash_df$ST_CASE, details = NULL, geometry = FALSE)
    cases_df <-
      subset(
        cases_df,
        select = -c(STATENAME, VE_FORMS, TWAY_ID, TWAY_ID2, LONGITUD, LATITUDE, FATALS, CITY, CITYNAME, COUNTY, COUNTYNAME)
      )

    crash_df <- dplyr::left_join(crash_df, cases_df, by = c("ST_CASE", "CaseYear"))
  }

  if (geometry) {
    crash_df <- overedge::df_to_sf(
      x = crash_df,
      coords = c("LONGITUD", "LATITUDE"),
      crs = crs
    )
  }

  crash_df <- format_crashes(crash_df, details = details)

  crash_df
}

#' @rdname get_fars
#' @aliases get_fars_cases get_fars_crash_details
#' @export
#' @importFrom usethis ui_stop ui_info
#' @importFrom progress progress_bar
#' @importFrom purrr map_dfr
get_fars_cases <- function(year = 2019,
                           state,
                           cases,
                           details = NULL,
                           geometry = FALSE,
                           crs = 4326,
                           progress_bar = TRUE) {
  year <- validate_year(year)
  state_fips <- lookup_fips(state)

  if (missing(cases)) {
    usethis::ui_stop("A valid FARS case number is required to access detailed crash data.")
  }

  n_cases <- length(cases)
  progress_bar <- progress_bar && (n_cases > 4)

  read_crash_result_set <- function(x) {
    results <- read_crashapi(
      type = "GetCaseDetails",
      stateCase = x,
      caseYear = year,
      state = state_fips,
      results = TRUE,
      format = "json"
    )

    if (n_cases > 5) {
      pb$tick(tokens = list(case = x))
    }
    results[["CrashResultSet"]]
  }


  if (progress_bar) {
    usethis::ui_info("Downloading case data for {state} crashes.")
    pb <-
      progress::progress_bar$new(
        format = "  downloading case :case [:bar] :percent in :elapsed",
        total = n_cases
      )
  }

  crash_df <-
    purrr::map_dfr(
      as.list(cases),
      ~ read_crash_result_set(.x)
    )

  if (is.null(details)) {
    crash_df <-
      subset(
        crash_df,
        select = !(names(crash_df) %in% c("CEvents", "Vehicles"))
      )
    if (geometry) {
      df_to_sf(crash_df, longitude = "LONGITUD", latitude = "LATITUDE")
    } else {
      crash_df
    }
  } else {
    details <- match.arg(details, c("events", "vehicles"))

    if (details == "events") {
      crash_df[, "CEvents"][[1]]
    } else if (details == "vehicles") {
      crash_df[, "Vehicles"][[1]]
    }
  }
}

#' @rdname get_fars
#' @aliases get_fars_crash_list
#' @export
get_fars_crash_list <- function(year = NULL,
                                start_year,
                                end_year,
                                state,
                                vehicles = c(1, 50)) {
  year <- validate_year(year, start_year = start_year, end_year = end_year)

  states_fips <-
    paste0(lookup_fips(state, several.ok = TRUE), collapse = ",")

  read_api("/crashes/?states={states_fips}&fromYear={min(year)}&toYear={max(year)}&minNumOfVehicles={min(vehicles)}&maxNumOfVehicles={max(vehicles)}")
}

#' @rdname get_fars
#' @aliases get_fars_summary
#' @export
get_fars_summary <- function(year = NULL,
                             start_year,
                             end_year,
                             state) {
  year <- validate_year(year, start_year = start_year, end_year = end_year)
  state_fips <- lookup_fips(state)

  summary <-
    read_crashapi(
      data = "analytics",
      type = "GetInjurySeverityCounts",
      fromCaseYear = min(year),
      toCaseYear = max(year),
      state = state_fips
    )

  return(summary)
}

#' @rdname get_fars
#' @export
#' @importFrom utils download.file
#' @importFrom jsonlite read_json
#' @importFrom readr read_csv
#' @importFrom stringr str_to_sentence
get_fars_year <- function(year = 2017,
                          type = "accident",
                          format = "json",
                          path = NULL,
                          download = FALSE) {
  year <- validate_year(year, year_range = c(2010, 2017))
  type <- match.arg(toupper(type), c("ACCIDENT", "CEVENT", "DAMAGE", "DISTRACT", "DRIMPAIR", "FACTOR", "MANEUVER", "NMCRASH", "NMIMPAIR", "NMPRIOR", "PARKWORK", "PBTYPE", "PERSON", "SAFETYEQ", "VEHICLE", "VEVENT VINDECODE", "VINDERIVED", "VIOLATION", "VISION", "VSOE"))
  format <- match.arg(format, c("json", "csv"))

  url <- read_crashapi(
    data = "FARSData",
    type = "GetFARSData",
    dataset = stringr::str_to_sentence(type),
    caseYear = year,
    format = format,
    results = FALSE
  )

  if (download) {
    filename <- paste0(year, "_", type, ".", format)

    if (!is.null(path)) {
      filename <- file.path(path, filename)
    }

    utils::download.file(
      url = url,
      destfile = filename,
      method = "auto"
    )
  } else {
    if (format == "json") {
      jsonlite::read_json(url, simplifyVector = TRUE)[["Results"]][[1]]
    } else if (format == "csv") {
      readr::read_csv(url)
    }
  }
}

#' @title Download FARS data files as zipped CSV or SAS files
#' @description This function provides an alternative to get_fars_year that downloads files directly from NHTSA FTP site.
#' @param year Year of data from 1975 to 2019, Default: 2019
#' @param format Format of zipped data tables ('csv' or 'sas'). Default: 'csv'.
#' @param path Path to download zip file with FARS tables.
#' @param pr If TRUE, download FARS data for Puerto Rico. No Puerto Rico data available for years 1975-1977. Default: FALSE
#' @return Downloads zip file with CSV or SAS tables.
#' @rdname get_fars_zip
#' @export
#' @importFrom utils URLencode
#' @importFrom glue glue
get_fars_zip <- function(year = 2019,
                         format = "csv",
                         path = NULL,
                         pr = FALSE) {
  year <- validate_year(year = year, year_range = c(1975:2019))
  format <- match.arg(format, c("csv", "sas"))

  if (pr) {
    geo <- utils::URLencode("Puerto Rico")
  } else {
    geo <- "National"
  }

  filename <- glue::glue("FARS{year}{geo}{toupper(format)}.zip")

  url <-
    read_api(
      url = "{year}/{geo}/{filename}",
      base = "https://www.nhtsa.gov/file-downloads?p=nhtsa/downloads/FARS/",
      format = NULL,
      results = FALSE
    )

  if (!is.null(path)) {
    filename <- file.path(path, filename)
  }

  download.file(
    url = url,
    destfile = filename,
    method = "auto"
  )
}




#' @rdname get_fars_crash_persons
#' @title Get Crashes By Occupant
#' @description This function returns a list of fatal crashes by occupant
#'   that have occurred throughout United States.
#'
#' @inheritParams get_fars
#' @param year numeric vector. Year or range with start and end year. 2010 to 2019 supported.
#' @param state Required. State name, abbreviation, or FIPS number.
#' @param age numeric
#' @param sex Options "m", "f", "male", "female", "unknown", "not reported."
#' @param seat Seat position
#' @param injury Options "unknown", "not reported", "died prior", "injured",
#'   "fatal", "suspected serious", "suspected minor", "possible", "no apparent"
#' @param occupants Include vehicle occupants in query; defaults to `TRUE`
#' @param nonoccupants Include non-occupants in query; defaults to `TRUE`
#' @export
#' @importFrom glue glue
get_fars_crash_persons <- function(year = NULL,
                                   start_year,
                                   end_year,
                                   state,
                                   age = NULL,
                                   sex = NULL,
                                   seat,
                                   injury,
                                   occupants = TRUE,
                                   nonoccupants = TRUE) {
  year <- validate_year(year, start_year = start_year, end_year = end_year)
  state_fips <- lookup_fips(state)

  if (is.character(seat)) {
    front <- grepl("front", seat)
    second <- grepl("second", seat)
    third <- grepl("third", seat)
    fourth <- grepl("fourth", seat)

    left <- grepl("left", seat)
    middle <- grepl("middle", seat)
    right <- grepl("right", seat)
    other <- grepl("other", seat)
  }

  injury <- switch(tolower(injury),
    "unknown" = 9,
    "not reported" = 9,
    "died prior" = 6,
    "injured" = 5,
    "fatal" = 4,
    "suspected serious" = 3,
    "suspected minor" = 2,
    "possible" = 1,
    "no apparent" = 0
  )

  sex <- switch(tolower(sex),
    "m" = 1,
    "male" = 1,
    "f" = 2,
    "female" = 2,
    "not reported" = 8,
    "unknown" = 9
  )

  stopifnot(
    is.numeric(age),
    is.character(sex),
    is.numeric(seat),
    is.numeric(injury)
  )

  read_crashapi(
    data = "crashes",
    type = "GetCrashesByPerson",
    age = as.integer(age),
    sex = sex,
    seatPos = as.integer(seat),
    injurySeverity = as.integer(injury),
    fromCaseYear = min(year),
    toCaseYear = max(year),
    state = state_fips,
    includeOccupants = tolower(occupants),
    includeNonOccupants = tolower(nonoccupants),
    format = "json"
  )
}


#' @rdname get_fars_crash_vehicles
#' @title Get Crashes By Vehicle
#' @description This function returns a list of fatal crashes by vehicle type
#'   that have occurred throughout United States. The make, model, and body type
#'   must match the options returned by `fars_vars`. This function accepts named
#'   options that are converted to ID numbers for use in the API query.
#'
#' @inheritParams get_fars
#' @param year numeric vector. Year or range with start and end year. 2010 to 2019 supported.
#' @param state Required. State name, abbreviation, or FIPS number.
#' @param make Make name or ID, Required. The start_year is used to return a
#'   list of support make options. Default: NULL
#' @param model Model name or ID, Optional. Default: NULL
#' @param model_year Model year, Optional. Default: NULL
#' @param body_type Body type, Optional. `model` must be provided to use
#'   body_type parameter. Default: NULL
#' @export
#' @importFrom glue glue
get_fars_crash_vehicles <- function(year = NULL,
                                    start_year,
                                    end_year,
                                    state,
                                    make = NULL,
                                    model = NULL,
                                    model_year = 2010,
                                    body_type = NULL) {
  year <- validate_year(year, start_year = start_year, end_year = end_year)
  state_fips <- lookup_fips(state)

  make_options <- fars_vars(year = min(year), var = "make")

  if (make %in% make_options$TEXT) {
    make <- make_options[make_options$TEXT == make, ]$ID
  }

  make <- match.arg(make, make_options$ID)

  if (!is.null(model)) {
    model_options <- fars_vars(year = model_year, make = make, var = "model")

    if (model %in% model_options$MODELNAME) {
      model <- as.character(model_options[model_options$MODELNAME == model, ]$ID)
    }

    model <- match.arg(as.character(model), as.character(model_options$ID))

    if (!is.null(body_type)) {
      body_type_options <- fars_vars(year = model_year, make = make, model = model, var = "bodytype")

      if (body_type %in% body_type_options$BODY_DEF) {
        body_type <- as.character(body_type_options[body_type_options$BODY_DEF == body_type, ]$BODY_ID)
      }

      body_type <- match.arg(body_type, body_type_options$BODY_ID)
    }
  }

  read_crashapi(
    data = "crashes",
    type = "GetCrashesByVehicle",
    make = make,
    bodyType = body_type,
    model = model,
    modelyear = model_year,
    fromCaseYear = min(year),
    toCaseYear = max(year),
    state = state_fips,
    format = "json",
    results = FALSE
  )
}

#' Read FARS data from zip file
#'
#' @inheritParams get_fars_zip
#' @noRd
#' @importFrom utils URLencode unzip
#' @importFrom glue glue
#' @importFrom fs dir_ls path_file
#' @importFrom purrr map
#' @importFrom readr read_csv
#' @importFrom stats setNames
#' @importFrom stringr str_remove
read_fars_zip <- function(year,
                          type,
                          pr = FALSE,
                          filename = NULL,
                          data_dir = NULL,
                          format = "csv",
                          ask = FALSE) {
  year <- validate_year(year, year_range = c(1975:2019))

  if (pr) {
    geo <- utils::URLencode("Puerto Rico")
  } else {
    geo <- "National"
  }

  if (is.null(filename)) {
    filename <- glue::glue("FARS{year}{geo}{toupper(format)}.zip")
  }

  if (is.null(data_dir)) {
    data_dir <- tempdir()
  }

  # Unzip data to temporary directory
  utils::unzip(
    zipfile = file.path(data_dir, paste0(filename, ".zip")),
    exdir = file.path(data_dir, filename)
  )

  # Read files into list
  table_csv_list <- fs::dir_ls(file.path(data_dir, filename))

  tables <-
    purrr::map(
      table_csv_list,
      ~ readr::read_csv(.x)
    ) |>
    stats::setNames(stringr::str_remove(fs::path_file(table_csv_list), ".csv$|.CSV$"))
}
