# Utility functions

#' Build query URL and download data from API
#' @noRd
#' @importFrom glue glue
#' @importFrom jsonlite read_json
read_api <- function(url,
                     base = "https://crashviewer.nhtsa.dot.gov/CrashAPI",
                     format = "json", results = TRUE, .envir = parent.frame()) {
  url <- paste0(base, glue::glue(url, .envir = .envir))

  if (!is.null(format)) {
    url <- glue::glue("{url}&format={format}")
  }

  if (results && (format == "json")) {
    jsonlite::read_json(url, simplifyVector = TRUE)[["Results"]][[1]]
  } else {
    url
  }
}

#' Read data from the CrashAPI using a url template
#'
#' An updated utility function using the httr2 package to read data from the
#' CrashAPI using the API URL templates listed on the NHSTA website:
#' <https://crashviewer.nhtsa.dot.gov/CrashAPI>
#'
#' @param url Base url for CrashAPI.
#' @param data Data (crashes, analytics, or fars), Default: 'crashes'
#' @param type Type of API to use, Default: `NULL`
#' @param format Format to return, Default: 'json'
#' @param results If `FALSE`, return formatted url, Default: `TRUE`
#' @param ... Additional parameters used in template (varies by type).
#' @return Data frame with requested data or a formatted url (if `results = FALSE`)
#' @export
#' @importFrom httr2 req_template request req_perform resp_body_json
read_crashapi <- function(url = "https://crashviewer.nhtsa.dot.gov",
                          data = "crashes",
                          type = NULL,
                          format = "json",
                          results = TRUE,
                          ...) {
  template <-
    switch(type,
      "GetCaseList" = "GET /CrashAPI/{data}/{type}?states={states}&fromYear={fromYear}&toYear={toYear}&minNumOfVehicles={minNumOfVehicles}&maxNumOfVehicles={maxNumOfVehicles}&format={format}",
      "GetCaseDetails" = "GET /CrashAPI/{data}/{type}?stateCase={stateCase}&caseYear={caseYear}&state={state}&format={format}",
      "GetCrashesByVehicle" = "GET /CrashAPI/{data}/{type}?make={make}&model={model}&modelyear={modelyear}&bodyType={bodyType}&fromCaseYear={fromCaseYear}&toCaseYear={toCaseYear}&state={state}&format={format}",
      "GetCrashesByPerson" = "GET /CrashAPI/{data}/{type}?age={age}&sex={sex}&seatPos={seatPos}&injurySeverity={injurySeverity}&fromCaseYear={fromCaseYear}&toCaseYear={toCaseYear}&state={state}&includeOccupants={includeOccupants}&includeNonOccupants={includeNonOccupants}&format={format}",
      "GetCrashesByLocation" = "GET /CrashAPI/{data}/{type}?fromCaseYear={fromCaseYear}&toCaseYear={toCaseYear}&state={state}&county={county}&format={format}",
      "GetInjurySeverityCounts" = "GET /CrashAPI/{data}/{type}?fromCaseYear={fromCaseYear}&toCaseYear={toCaseYear}&state={state}&format={format}",
      "GetVariables" = "GET /CrashAPI/{data}/{type}?dataYear={dataYear}&format={format}",
      "GetVariableAttributes" = "GET /CrashAPI/{data}/{type}?variable={variable}&caseYear={caseYear}&format={format}",
      "GetVariableAttributesForModel" = "GET /CrashAPI/{data}/{type}?variable={variable}&caseYear={caseYear}&make={make}&format={format}",
      "GetVariableAttributesForbodyType" = "GET /CrashAPI/{data}/{type}?variable={variable}&make={make}&model={model}&format={format}",
      "GetFARSData" = "GET /CrashAPI/{data}/{type}?dataset={dataset}&caseYear={caseYear}&format={format}"
    )

  request <- httr2::req_template(
    req = httr2::request(url),
    template = template,
    data = data,
    type = type,
    format = format,
    ...,
    .env = parent.frame()
  )

  if (results && (format == "json")) {
    data <- request |>
      httr2::req_perform() |>
      httr2::resp_body_json(check_type = FALSE, simplifyVector = TRUE)

    return(data$Results[[1]])
  } else {
    return(request$url)
  }
}

#' Validate start and end year
#' @noRd
#' @importFrom usethis ui_stop
#' @importFrom checkmate expect_integerish
validate_year <- function(year, year_range = c(2010, 2019), start_year, end_year) {
  if (is.null(year)) {
    if (!missing(start_year) | !missing(end_year)) {
      year <- c(start_year, end_year)
    } else {
      usethis::ui_stop("{usethis::ui_field('year')}, {usethis::ui_field('start_year')}, or {usethis::ui_field('end_year')} must be provided to access FARS data.")
    }
  }
  year <- as.integer(year)

  suppressMessages(
    checkmate::expect_integer(year, lower = min(year_range), upper = max(year_range))
  )

  year
}

#' Convert data frame to sf object
#'
#' @noRd
#' @importFrom sf st_as_sf st_transform
df_to_sf <- function(x,
                     longitude = "LONGITUD",
                     latitude = "LATITUDE",
                     crs = 4326) {

  # Check that lat/lon are numeric
  if (!is.numeric(x[[longitude]])) {
    x[[longitude]] <- as.double(x[[longitude]])
    x[[latitude]] <- as.double(x[[latitude]])
  }

  # Exclude rows with missing coordinates
  x <- x[!is.na(x[longitude]), ]

  x <-
    sf::st_transform(
      sf::st_as_sf(
        x,
        coords = c(longitude, latitude),
        agr = "constant",
        crs = 4326,
        stringsAsFactors = FALSE,
        remove = FALSE
      ),
      crs
    )

  return(x)
}


#' Validate state and county name/abbreviation and convert to FIPS number
#' @noRd
lookup_fips <- function(state, county = NULL, several.ok = FALSE, list = FALSE, int = TRUE) {
  if (!several.ok) {
    state_fips <- suppressMessages(validate_state(state))
    county_fips <- suppressMessages(validate_county(state, county))
  } else {
    state_fips <- suppressMessages(vapply(state, validate_state, USE.NAMES = FALSE, FUN.VALUE = "1"))
    if (!is.null(county)) {
      county_fips <- suppressMessages(mapply(validate_county, state_fips, county, USE.NAMES = FALSE))
    } else {
      county_fips <- NULL
    }
  }

  if (int) {
    state_fips <- as.integer(state_fips)
    if (!is.null(county_fips)) {
      county_fips <- as.integer(county_fips)
    }
  }

  if (list) {
    list(
      "state" = state_fips,
      "county" = county_fips
    )
  } else if (!is.null(county_fips)) {
    county_fips
  } else {
    state_fips
  }
}

#' @noRd
#' @importFrom dplyr filter
reorder_fars_vars <- function(x) {
  # Reorder columns to match analytical manual order
  x_vars <- dplyr::filter(fars_vars_labels, name %in% names(x))
  x[, match(x_vars$name, colnames(x))]
}

#' Format crash data
#'
#' Reorder columns to match the order documented in Fatality Analysis Reporting
#' System (FARS) Analytical User's Manual, 1975-2019 and append derived columns
#' for date, time, and datetime.
#'
#' @param x Data frame with crash data.
#' @param details If `TRUE`, append date, time, datetime columns to formatted
#'   crash data; defaults to TRUE
#' @export
#' @importFrom janitor clean_names
#' @importFrom dplyr mutate
#' @importFrom stringr str_pad
#' @importFrom lubridate ymd_hm ymd
format_crashes <- function(x, details = TRUE) {

  # Reorder column names
  crash_df <- reorder_fars_vars(x)

  # Clean column names
  crash_df <- janitor::clean_names(crash_df, "snake")

  pad_hm <- function(x) {
    stringr::str_pad(x, width = 2, pad = "0")
  }

  # Append date/time columns
  if (details) {
    crash_df <-
      dplyr::mutate(
        crash_df,
        date = paste(year, month, day, sep = "-"),
        time = paste(pad_hm(hour), pad_hm(minute), sep = ":"),
        datetime = lubridate::ymd_hm(paste(date, time)),
        date = lubridate::ymd(date),
        .after = st_case
      )
  }

  crash_df
}

#' Helper function to return date added or updated for package data for documentation
#'
#' @noRd
pkg_data_date <- function(data, date = "added", format = "%B %d %Y", verbose = TRUE, pkg = "crashapi") {

  data_date <-
    pkg_data_index[pkg_data_index[["data"]] == data,][[paste0("date_", date)]]

  if (!verbose) {
    return(data_date)
  }

  data_date <-
    format(as.Date(data_date), format = format)

  glue::glue("{stringr::str_to_sentence(date)}: {data_date}")
}

utils::globalVariables(c(
  "CITY", "CITYNAME", "COUNTY", "COUNTYNAME", "FATALS", "LATITUDE", "LONGITUD", "STATENAME",
  "TWAY_ID", "TWAY_ID2", "VE_FORMS", "abb", "day", "fars_vars_labels", "get_area_crashes",
  "hour", "minute", "month", "name", "st_case", "state_abb", "statewide_yn", "time", "year"
))
