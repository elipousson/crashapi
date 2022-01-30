# Utility functions

# Build query URL and download data from API
#' @importFrom glue glue
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
#' @importFrom checkmate expect_integerish
validate_year <- function(year, year_range = c(2010, 2019)) {
  suppressMessages(
    checkmate::expect_integerish(year, lower = min(year_range), upper = max(year_range))
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
