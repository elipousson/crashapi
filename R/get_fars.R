# Utility functions
# Validate state and convert to FIPS number
state_to_fips <- function(state, several.ok = FALSE) {
  if (is.numeric(state)) {
    state <- sprintf("%02d", as.integer(state))
    state_fips <- match.arg(arg = state, choices = tigris::fips_codes[["state_code"]], several.ok = several.ok)
  } else if (is.character(state)) {
    state <- match.arg(arg = state, unique(c(tigris::fips_codes[, "state"], tigris::fips_codes[, "state_name"])), several.ok = several.ok)
    state_fips <- tigris::fips_codes[tigris::fips_codes["state_name"] == state | tigris::fips_codes["state"] == state, "state_code"] |>
      unique()
  }

  state_fips
}

# Validate county and convert to FIPS number
county_to_fips <- function(county, state) {
  state <- state_to_fips(state)

  if (is.numeric(county)) {
    county_fips <- sprintf("%03d", as.integer(county))
    county_fips <- match.arg(county_fips, tigris::fips_codes[tigris::fips_codes["state_code"] == state, "county_code"])
  } else if (is.character(county)) {
    county <- match.arg(county, tigris::fips_codes[tigris::fips_codes["state_code"] == state, "county"])
    county_fips <- tigris::fips_codes[tigris::fips_codes["county"] == county, "county_code"]
  }

  county_fips
}

# Validate start and end year
validate_year <- function(start_year, end_year) {
  if (!(is.numeric(start_year) | !is.numeric(end_year))) {
    stop("The start_year and end_year must be numeric.")
  }

  if (start_year >= 2020 | start_year <= 2009) {
    stop("The start_year and end_year must both be between 2010 and 2019.")
  }

  if (end_year >= 2020 | end_year <= 2009) {
    stop("The start_year and end_year must both be between 2010 and 2019.")
  }

  if (end_year < start_year) {
    stop("The end_year must be greater than or equal to the start_year.")
  }
}

# Build query URL
make_query <- function(x, format = "json", .envir = parent.frame()) {
  paste0("https://crashviewer.nhtsa.dot.gov/CrashAPI", glue::glue(x, .envir = .envir), glue::glue("&format={format}"))
}

# Convert data frame to sf object
data_to_sf <- function(x,
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
    sf::st_as_sf(
      x,
      coords = c(longitude, latitude),
      agr = "constant",
      crs = 4326,
      stringsAsFactors = FALSE,
      remove = FALSE
    ) |>
    sf::st_transform(crs)

  return(x)
}

#' @title Get Fatality Analysis Reporting System (FARS) data with the FARS API
#' @description These functions are currently supported.
#'   - `get_fars_crash_list` returns a list of fatal crashes that have occurred
#'   in multiple states in one or more years.
#'   - `get_fars_crashes` a list of fatal crashes by location that have occurred
#'   throughout U.S.
#'   - `get_fars_summary` provides a count of injury severity that have occurred
#'   throughout U.S. including count of fatalities and crashes.
#'   - `get_fars_year` provides one of 20 FARS data tables for a single year.
#'   Supports downloading to a CSV or JSON file.
#'
#' Both `get_fars_crash_list` and `get_fars_crashes` limit the returned data to
#' 5000 records so consider limiting the range of years requested if data
#' exceeds that threshold.
#'
#' @param start_year Required. Start year for crash reports (must be between
#'   2010 and 2019), Default: 2014
#' @param end_year Required. End year for crash reports (must be between 2010
#'   and 2019), Default: 2015
#' @param state Required. State name, abbreviation, or FIPS number.
#'   `get_fars_crash_list` supports multiple states.
#' @param county County name or FIPS number. Required for `get_fars_crashes`.
#' @param geometry If TRUE, return sf object. Optional  for `get_fars_crashes`.
#' @param crs Coordinate reference system to return for `get_fars_crashes` if
#'   geometry is TRUE
#' @param vehicles Vector with the minimum and maximum number of vehicles, e.g.
#'   c(1, 2) for minimum of 1 vehicle and maximum of 2. Required for
#'   `get_fars_crash_list`.
#' @param data data table to download with `get_fars_year`. Supported values
#'   include "ACCIDENT", "CEVENT", "DAMAGE", "DISTRACT", "DRIMPAIR", "FACTOR",
#'   "MANEUVER", "NMCRASH", "NMIMPAIR", "NMPRIOR", "PARKWORK", "PBTYPE",
#'   "PERSON", "SAFETYEQ", "VEHICLE", "VEVENT VINDECODE", "VINDERIVED",
#'   "VIOLATION", "VISION", and "VSOE".
#' @param format Default "json". "csv" is also supported.
#' @param download Default FALSE. If TRUE, download the data to a file.
#' @rdname get_fars
#' @export
#' @md
#' @importFrom jsonlite read_json
get_fars_crashes <- function(start_year = 2014,
                             end_year = 2015,
                             state = 1,
                             county = 1,
                             geometry = FALSE,
                             crs = 4326) {
  validate_year(
    start_year = start_year,
    end_year = end_year
  )

  state_fips <- state_to_fips(state) |>
    as.integer()

  county_fips <- county_to_fips(county, state) |>
    as.integer()

  query <- make_query("/crashes/GetCrashesByLocation?fromCaseYear={start_year}&toCaseYear={end_year}&state={state_fips}&county={county_fips}")

  data <- jsonlite::read_json(query, simplifyVector = TRUE)$Results[[1]]

  if (geometry) {
    data |>
      data_to_sf(
        longitude = "LONGITUD",
        latitude = "LATITUDE",
        crs = crs
      )
  } else {
    data
  }
}

#' @rdname get_fars
#' @export
#' @importFrom jsonlite read_json
get_fars_crash_list <- function(start_year = 2014,
                                end_year = 2015,
                                state = 1,
                                vehicles = c(1, 50)) {
  validate_year(
    start_year = start_year,
    end_year = end_year
  )

  states_fips <- state_to_fips(state, several.ok = TRUE) |>
    as.integer() |>
    paste0(collapse = ",")

  query <- make_query("/crashes/?states={states_fips}&fromYear={start_year}&toYear={end_year}&minNumOfVehicles={vehicles[1]}&maxNumOfVehicles={vehicles[2]}")

  jsonlite::read_json(query, simplifyVector = TRUE)$Results[[1]]
}

#' @rdname get_fars
#' @export
#' @importFrom jsonlite read_json
get_fars_summary <- function(start_year = 2014,
                             end_year = 2015,
                             state = 1) {
  validate_year(
    start_year = start_year,
    end_year = end_year
  )

  state_fips <- state_to_fips(state) |>
    as.integer()

  query <- make_query("/analytics/GetInjurySeverityCounts?fromCaseYear={start_year}&toCaseYear={end_year}&state={state_fips}")

  jsonlite::read_json(query, simplifyVector = TRUE)$Results[[1]]
}

#' @rdname get_fars
#' @export
#' @importFrom jsonlite read_json
#' @importFrom readr read_csv
get_fars_year <- function(year,
                          data = "ACCIDENT",
                          format = "json",
                          download = FALSE) {
  year <- match.arg(as.character(year), c(2010:2017))
  data <- match.arg(data, c("ACCIDENT", "CEVENT", "DAMAGE", "DISTRACT", "DRIMPAIR", "FACTOR", "MANEUVER", "NMCRASH", "NMIMPAIR", "NMPRIOR", "PARKWORK", "PBTYPE", "PERSON", "SAFETYEQ", "VEHICLE", "VEVENT VINDECODE", "VINDERIVED", "VIOLATION", "VISION", "VSOE"))
  format <- match.arg(format, c("csv", "json"))

  query <- make_query("/FARSData/GetFARSData?dataset={stringr::str_to_sentence(data)}&caseYear={year}", format = format)

  if (format == "json") {
    fars <- jsonlite::read_json(query, simplifyVector = TRUE)$Results[[1]]
  } else if (format == "csv") {
    fars <- readr::read_csv(query)
  }

  if (download) {
    download.file(fars, destfile = paste0(year, "_", data, ".", format))
  } else {
    fars
  }
}

#' @rdname get_fars
#' @export
#' @importFrom jsonlite read_json
get_fars_crash_details <- function(year = 2015,
                                   state = 1,
                                   case) {
  year <- match.arg(as.character(year), c(2010:2019))

  states_fips <- state_to_fips(state) |>
    as.integer()

  query <- make_query("/crashes/GetCaseDetails?stateCase={case}&caseYear={year}&state={state_fips}")

  jsonlite::read_json(query, simplifyVector = TRUE)$Results[[1]]
}
