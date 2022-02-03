# Utility functions

# Build query URL and download data from API
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

# Validate start and end year
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

# Convert data frame to sf object
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


# Validate state and county name/abbreviation and convert to FIPS number
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

#' @importFrom dplyr filter
reorder_fars_vars <- function(x) {
  # Reorder columns to match analytical manual order
  x_vars <- dplyr::filter(fars_vars_labels, name %in% names(x))
  x[,match(x_vars$name, colnames(x))]
}

#' Format crash data
#'
#' Reorder columns to match the order documented in Fatality Analysis Reporting
#' System (FARS) Analytical User's Manual, 1975-2019 and append derived columns
#' for date, time, and datetime.
#'
#' @importFrom janitor clean_names
#' @importFrom dplyr mutate
#' @importFrom stringr str_pad
#' @importFrom lubridate ymd_hm ymd
#' @export
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
