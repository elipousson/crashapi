# Utility functions
# Validate state and convert to FIPS number
state_to_fips <- function(state) {
  if (is.integer(state)) {
    state_fips <- sprintf("%02d", state)
    state_fips <- match.arg(state_fips, tigris::fips_codes["state_code"], several.ok = TRUE)
  } else if (is.character(state)) {
    state <- match.arg(state, unique(c(tigris::fips_codes[, "state"], tigris::fips_codes[, "state_name"])), several.ok = TRUE)
    state_fips <- tigris::fips_codes[tigris::fips_codes["state_name"] == state | tigris::fips_codes["state"] == state, "state_code"] |>
      unique()
  }

  state_fips
}

# Validate county and convert to FIPS number
county_to_fips <- function(county, state) {
  state <- state_to_fips(state)

  if (is.integer(county)) {
    county_fips <- sprintf("%03d", county)
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
    stop("The start_year and stop_year must be numeric.")
  }

  if (start_year >= 2020 | start_year <= 2009) {
    stop("The start_year and end_year must both be between 2010 and 2019.")
  }

  if (end_year >= 2020 | end_year <= 2009) {
    stop("The start_year and end_year must both be between 2010 and 2019.")
  }

  if (end_year < start_year) {
    stop("The end-year must be greater than or equal to the start year.")
  }
}

# Convert data frame to sf object
data_to_sf <- function(x,
                       longitude = "LONGITUD",
                       latitude = "LATITUDE",
                       crs = 4326) {

  # Exclude rows with missing coordinates
  x <- x[!is.na(x[longitude]), ]

  # Check that lat/lon are numeric
  if (!is.numeric(x[[longitude]])) {
    x[[longitude]] <- as.double(x[[longitude]])
    x[[latitude]] <- as.double(x[[latitude]])
  }

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
#' @description Three APIs from FARS are currently supported:
#'   - `get_fars_crash_list` returns a list of fatal crashes that have occurred in
#'   multiple States in one or more years. Limit the year range as data limit
#'   has been set to 5000 records.
#'   - `get_fars_crashes` a list of fatal crashes by location that have occurred
#'   throughout U.S. Limit the year range as data limit has been set to 5000
#'   records.
#'   - `get_fars_summary` provides a count of injury severity that have occurred
#'   throughout U.S. including count of fatalities and crashes.
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
#' @rdname get_fars
#' @export
#' @md
#' @importFrom glue glue
#' @importFrom jsonlite read_json
get_fars_crashes <- function(start_year = 2014,
                        end_year = 2015,
                        state = 1,
                        county = 1,
                        geometry = FALSE,
                        crs = 4326) {

  validate_year(start_year = start_year,
                end_year = end_year)

  state_fips <- state_to_fips(state) |>
    as.integer()

  county_fips <- county_to_fips(county, state) |>
    as.integer()

  query <- "https://crashviewer.nhtsa.dot.gov/CrashAPI"
  query <- glue::glue("{query}/crashes/GetCrashesByLocation?fromCaseYear={start_year}&toCaseYear={end_year}&state={state_fips}&county={county_fips}&format=json")

  data <- jsonlite::read_json(query, simplifyVector = TRUE)$Results[[1]]

  if (geometry) {
    data |>
      data_to_sf(longitude = "LONGITUD",
                 latitude = "LATITUDE",
                 crs = crs)
  } else {
    data
  }

}

#' @rdname get_fars
#' @export
#' @importFrom glue glue
#' @importFrom jsonlite read_json
get_fars_crash_list <- function(start_year = 2014,
                           end_year = 2015,
                           state = 1,
                           vehicles = c(1, 2)) {

  validate_year(start_year = start_year,
                end_year = end_year)

  states <- state_to_fips(state) |>
    as.integer() |>
    paste0(collapse = ",")

  query <- "https://crashviewer.nhtsa.dot.gov/CrashAPI"
  query <- glue::glue("{query}/crashes/?states={states}&fromYear={start_year}&toYear={end_year}&minNumOfVehicles={vehicles[1]}&maxNumOfVehicles={vehicles[2]}&format=json")

  jsonlite::read_json(query, simplifyVector = TRUE)$Results[[1]]
}

#' @rdname get_fars
#' @export
#' @importFrom glue glue
#' @importFrom jsonlite read_json
get_fars_summary <- function(start_year = 2014,
                             end_year = 2015,
                             state = 1) {

  state_fips <- state_to_fips(state) |>
    as.integer()

  query <- "https://crashviewer.nhtsa.dot.gov/CrashAPI"
  query <- glue::glue("{query}/analytics/GetInjurySeverityCounts?fromCaseYear={start_year}&toCaseYear={end_year}&state={state_fips}&format=json")

  jsonlite::read_json(query, simplifyVector = TRUE)$Results[[1]]
}
