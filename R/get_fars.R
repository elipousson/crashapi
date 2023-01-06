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
#'   Both `get_fars_crash_list` and `get_fars_crashes` limit the returned data
#'   to 5000 records so consider limiting the range of years requested if data
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
#'   year. Most `api` options support the years from 2010 through the most
#'   recent year of release. "year dataset" only supports 2010 to 2017 and "zip"
#'   supports 1975 to 2020. `start_year` and `end_year` are ignored if `year` is
#'   not `NULL`.
#' @param api character. API function to use. Supported values include
#'   "crashes", "cases", "state list", "summary count", "year dataset", and
#'   "zip". Default: "crashes".
#' @param start_year Start year for crash reports.
#' @param end_year End year for crash reports.
#' @param state Required. State name, abbreviation, or FIPS number.
#'   `get_fars_crash_list` supports multiple states.
#' @param county  County name or FIPS number. Required for `get_fars_crashes`.
#' @param geometry If `TRUE`, return sf object. Optional for `get_fars_crashes`.
#' @param crs Coordinate reference system to return for `get_fars_crashes` if
#'   `geometry` is `TRUE`.
#' @param type Name of the dataset or data file to download when using the "year
#'   dataset" api or `get_fars_year`. Supported values include "ACCIDENT",
#'   "CEVENT", "DAMAGE", "DISTRACT", "DRIMPAIR", "FACTOR", "MANEUVER",
#'   "NMCRASH", "NMIMPAIR", "NMPRIOR", "PARKWORK", "PBTYPE", "PERSON",
#'   "SAFETYEQ", "VEHICLE", "VEVENT VINDECODE", "VINDERIVED", "VIOLATION",
#'   "VISION", and "VSOE". Lowercase or mixed case values are permitted.
#' @param cases One or more FARS case numbers. Required if `api` is "cases" or
#'   using `get_fars_cases`. Multiple case numbers can be provided.
#' @param details Type of detailed crash data to return (either "events" or
#'   "vehicles"). If `TRUE` for `get_fars` or `get_fars_crashes`, detailed case
#'   data (excluding event and vehicle data) is attached to the returned crash
#'   data. If `NULL` for `get_fars_cases`, events and vehicle data are excluded
#'   from the returned case data. returned by `get_fars_cases`. Optional for
#'   `get_fars_crash_details`. Default: `NULL` for `get_fars_cases`; `FALSE` for
#'   `get_fars` and `get_fars_crashes`.
#' @param vehicles numeric vector with the minimum and maximum number of
#'   vehicles, e.g. c(1, 2) for minimum of 1 vehicle and maximum of 2. Required
#'   for `get_fars_crash_list`.
#' @param pr logical. If `TRUE`, download zip file with FARS data for Puerto
#'   Rico. No Puerto Rico data available for years 1975-1977. Default: `FALSE`
#'   for `get_fars_zip` only.
#' @param format Default "json". "csv" is supported when using the "year
#'   dataset" api. "sas" is supporting for the "zip" api.
#' @param path File path used if download is `TRUE`.
#' @param download logical. If `TRUE` and the `api` is "year dataset" or "zip",
#'   download the data to a file. Default `FALSE`.
#' @rdname get_fars
#' @examples
#'
#' head(get_fars_crashes(state = "MD", county = "Baltimore city"), 5)
#'
#' get_fars_cases(state = "MD", cases = "240274")
#'
#' get_fars_crash_list(state = "MD", vehicles = 5)
#'
#' get_fars_summary(state = "MD")
#'
#' head(get_fars_year(state = "MD", type = "PERSON"), 5)
#'
#' @export
#' @md
get_fars <- function(year = 2020,
                     state,
                     county = NULL,
                     api = c(
                       "crashes", "cases", "state list",
                       "summary count", "year dataset", "zip"
                     ),
                     type,
                     details = FALSE,
                     geometry = FALSE,
                     crs = NULL,
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
        state = state,
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
#' @importFrom cli cli_abort
get_fars_crashes <- function(year = 2020,
                             start_year,
                             end_year = NULL,
                             state,
                             county,
                             details = FALSE,
                             geometry = FALSE,
                             crs = NULL) {
  year <- validate_year(year, start_year = start_year, end_year = end_year)

  if ((max(year) - min(year)) > 4) {
    cli::cli_inform(
      c(
        "!" = "Use longer year ranges with caution.",
        "i" = "The Get Crashes By Location API endpoint used by
        {.fn get_fars_crashes} limits responses to a maximum of 5000 records."
      )
    )
  }

  if (missing(county) | is.null(county)) {
    cli::cli_abort(
      "{.arg county} must be a valid county name or FIPS code."
    )
  }

  fips <- lookup_fips(state, county, list = TRUE)

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
    cases_df <-
      get_fars_cases(
        year = year,
        state = state,
        cases = crash_df$ST_CASE,
        details = NULL,
        geometry = FALSE
      )

    cases_df <-
      subset(
        cases_df,
        select = -c(
          STATENAME, VE_FORMS, TWAY_ID, TWAY_ID2, LONGITUD, LATITUDE,
          FATALS, CITY, CITYNAME, COUNTY, COUNTYNAME
        )
      )

    crash_df <-
      dplyr::left_join(crash_df, cases_df, by = c("ST_CASE", "CaseYear"))
  }

  if (geometry) {
    crash_df <-
      df_to_sf(
        x = crash_df,
        crs = crs
      )
  }

  format_crashes(crash_df, details = details)
}

#' @rdname get_fars
#' @aliases get_fars_cases get_fars_crash_details
#' @export
#' @importFrom cli cli_abort cli_progress_along
#' @importFrom purrr map_dfr
get_fars_cases <- function(year = 2020,
                           state,
                           cases,
                           details = NULL,
                           geometry = FALSE,
                           crs = NULL) {
  year <- validate_year(year)
  state_fips <- lookup_fips(state)

  if (missing(cases)) {
    cli::cli_abort(
      "A valid FARS case number is required to download detailed crash data."
    )
  }

  crash_df <-
    purrr::map_dfr(
      cli::cli_progress_along(cases),
      ~ read_crashapi(
        type = "GetCaseDetails",
        stateCase = as.list(cases)[[.x]],
        caseYear = year,
        state = state_fips,
        results = TRUE,
        format = "json"
      )[["CrashResultSet"]]
    )

  if (is.null(details)) {
    crash_df <-
      subset(
        crash_df,
        select = !(names(crash_df) %in% c("CEvents", "Vehicles"))
      )

    if (!geometry) {
      return(crash_df)
    }

    crash_sf <-
      df_to_sf(
        crash_df,
        crs = crs
      )

    return(crash_sf)
  }

  details <- match.arg(details, c("events", "vehicles"))

  switch(details,
    "events" = crash_df[, "CEvents"][[1]],
    "vehicles" = crash_df[, "Vehicles"][[1]]
  )
}

#' @rdname get_fars
#' @aliases get_fars_crash_list
#' @export
get_fars_crash_list <- function(year = 2020,
                                start_year,
                                end_year = NULL,
                                state,
                                vehicles = c(1, 50)) {
  year <- validate_year(year, start_year = start_year, end_year = end_year)

  states_fips <-
    paste0(lookup_fips(state, several.ok = TRUE), collapse = ",")

  crash_df <-
    read_crashapi(
      states = states_fips,
      type = "GetCaseList",
      fromYear = min(year),
      toYear = max(year),
      minNumOfVehicles = min(vehicles),
      maxNumOfVehicles = max(vehicles)
    )

  format_crashes(crash_df)
}

#' @rdname get_fars
#' @aliases get_fars_summary
#' @export
get_fars_summary <- function(year = 2020,
                             start_year,
                             end_year = NULL,
                             state) {
  year <-
    validate_year(year, start_year = start_year, end_year = end_year)

  crash_df <-
    read_crashapi(
      data = "analytics",
      type = "GetInjurySeverityCounts",
      fromCaseYear = min(year),
      toCaseYear = max(year),
      state = lookup_fips(state)
    )

  format_crashes(crash_df)
}

#' @rdname get_fars
#' @export
#' @importFrom utils download.file
#' @importFrom readr read_csv
#' @importFrom stringr str_to_sentence
#' @importFrom cli cli_warn
#' @importFrom httr2 resp_body_json req_perform request
get_fars_year <- function(year = 2020,
                          type = "accident",
                          state,
                          format = "json",
                          path = NULL,
                          geometry = FALSE,
                          crs = NULL,
                          download = FALSE) {
  year <- validate_year(year)
  state_fips <- lookup_fips(state)

  fars_tabs <- c(
    "ACCIDENT", "CEVENT", "DAMAGE", "DISTRACT", "DRIMPAIR",
    "DRUGS", "FACTOR", "MANEUVER", "NMCRASH", "NMIMPAIR",
    "NMPRIOR", "PARKWORK", "PBTYPE", "PERSON", "SAFETYEQ",
    "VEHICLE", "VEVENT", "VINDECODE", "VINDERIVED", "VIOLATION",
    "VISION", "VSOE"
  )

  # Add 2019 and 2020 onwards tables to the data
  if (min(year) >= 2019) {
    fars_tabs <- c(fars_tabs, "NMDISTRACT")
    if (min(year) >= 2020) {
      fars_tabs <- c(
        fars_tabs, "CRASHRF", "DRIVERRF", "PERSONRF", "PVEHICLESF",
        "VEHICLESF", "WEATHER"
      )
    }
  }

  type <- toupper(type)
  type <- match.arg(type, fars_tabs)
  format <- match.arg(format, c("json", "csv"))

  url <-
    read_crashapi(
      data = "FARSData",
      type = "GetFARSData",
      dataset = stringr::str_to_sentence(type),
      caseYear = year,
      FromYear = min(year),
      ToYear = max(year),
      State = state_fips,
      format = format,
      results = FALSE
    )

  if (!download) {
    if (format == "json") {
      request <-
        httr2::req_user_agent(
          httr2::request(url),
          "crashapi https://elipousson.github.io/crashapi/"
        )
    }

    crash_df <-
      switch(format,
        "json" = httr2::resp_body_json(
          httr2::req_perform(request),
          simplifyVector = TRUE,
          check_type = FALSE
        )[["Results"]][[1]],
        "csv" = readr::read_csv(url)
      )

    if (!geometry) {
      return(crash_df)
    }

    coords <- c("LONGITUD", "LATITUDE")

    if (all(coords %in% names(crash_df))) {
      crash_sf <-
        df_to_sf(
          x = crash_df,
          crs = crs
        )

      return(crash_sf)
    }

    cli::cli_warn(
      c("Coordinate columns {coords} can't be found in data of
          the type {.val {type}}.",
        "i" = "Use {.code type = 'accident'} with
          {.code geometry = 'TRUE'} to return an sf object."
      )
    )

    crash_df
  }

  filename <- paste0(min(year), "_", max(year), "_", type, ".", format)

  if (!is.null(path)) {
    filename <- file.path(path, filename)
  }

  utils::download.file(
    url = url,
    destfile = filename,
    method = "auto"
  )
}
