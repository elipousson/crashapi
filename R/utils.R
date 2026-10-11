.onLoad <- function(libname, pkgname) {
  utils::data(
    "fars_vars_labels",
    package = pkgname,
    envir = parent.env(environment())
  )
}

utils::globalVariables(c(
  "CITY",
  "CITYNAME",
  "COUNTY",
  "COUNTYNAME",
  "FATALS",
  "LATITUDE",
  "LONGITUD",
  "STATENAME",
  "TWAY_ID",
  "TWAY_ID2",
  "VE_FORMS",
  "abb",
  "get_area_crashes",
  "name",
  "state_abb",
  "statewide_yn",
  "time",
  "year"
))

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
#' @inheritParams rlang::args_error_context
#' @return Data frame with requested data or a formatted url (if `results = FALSE`)
#' @export
#' @importFrom httr2 req_template request req_perform resp_body_json
read_crashapi <- function(
  url = "https://crashviewer.nhtsa.dot.gov",
  data = "crashes",
  type = NULL,
  format = "json",
  results = TRUE,
  ...,
  call = caller_env()
) {
  template <-
    switch(
      type,
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
      # "GetFARSData" = "GET /CrashAPI/{data}/{type}?dataset={dataset}&caseYear={caseYear}&format={format}"
      "GetFARSData" = "GET /CrashAPI/{data}/{type}?dataset={dataset}&FromYear={FromYear}&ToYear={ToYear}&State={State}&format={format}"
    )

  req <-
    httr2::req_user_agent(
      httr2::request(url),
      "crashapi https://elipousson.github.io/crashapi/"
    )

  request <-
    httr2::req_template(
      req = req,
      template = template,
      data = data,
      type = type,
      format = format,
      ...
    )

  if (!results) {
    return(request[["url"]])
  }

  request <- httr2::req_timeout(
    req = request,
    seconds = 180
  )

  request <- httr2::req_options(
    .req = request,
    http_version = 1.1
  )

  # FIXME: Implement a way of dealing with alternate formats
  data <- httr2::resp_body_json(
    httr2::req_perform(request, error_call = call),
    check_type = FALSE,
    simplifyVector = TRUE
  )

  if (data[["Count"]] == 0) {
    cli::cli_bullets(
      c(
        "!" = data[["Message"]],
        "*" = "Adjust search criteria and try again: {data[['SearchCriteria']]}"
      )
    )
  }

  data[["Results"]][[1]]
}

#' Validate start and end year
#' @noRd
validate_year <- function(
  year,
  year_range = c(2010, 2022),
  start_year = NULL,
  end_year = NULL,
  call = caller_env()
) {
  if (is.null(year)) {
    if (is.null(start_year) && is.null(end_year)) {
      cli_abort(
        "A {.arg year}, {.arg start_year}, or
        {.arg end_year} must be provided to download FARS data.",
        call = call
      )
    }

    year <- c(start_year, end_year)
  }

  year <- as.integer(year)

  if (any(is.na(year))) {
    cli_abort(
      "{.arg year} must be an integer or coercible to an integer.",
      call = call
    )
  }

  if (!all(year >= min(year_range))) {
    cli_abort(
      "{.arg year} must be greater than or equal to {.val {min(year_range)}}.",
      call = call
    )
  }

  if (!all(year <= max(year_range))) {
    cli_abort(
      "{.arg year} must be less than or equal to {.val {max(year_range)}}.",
      call = call
    )
  }

  year
}

#' Convert data frame to sf object
#'
#' @noRd
#' @importFrom dplyr mutate across all_of
#' @importFrom rlang check_installed %||%
df_to_sf <- function(
  x,
  coords = c("LONGITUD", "LATITUDE"),
  crs = 4326,
  na.fail = FALSE,
  remove = FALSE
) {
  crs <- crs %||% 4326

  if (!all(coords %in% names(x))) {
    # FIXME: Consider adding a warning if coords not found
    return(x)
  }

  x <-
    dplyr::mutate(
      x,
      dplyr::across(
        dplyr::all_of(coords),
        ~ as.numeric(.x)
      )
    )

  rlang::check_installed("sf")

  sf::st_transform(
    sf::st_as_sf(
      x,
      coords = coords,
      agr = "constant",
      crs = 4326,
      na.fail = na.fail,
      remove = remove
    ),
    crs
  )
}


#' Validate state and county name/abbreviation and convert to FIPS number
#' @noRd
lookup_fips <- function(
  state,
  county = NULL,
  several.ok = FALSE,
  list = FALSE,
  int = TRUE
) {
  if (!several.ok) {
    state_fips <- suppressMessages(validate_state(state))
    county_fips <- suppressMessages(validate_county(state, county))
  } else {
    state_fips <- suppressMessages(vapply(
      state,
      validate_state,
      USE.NAMES = FALSE,
      FUN.VALUE = "1"
    ))

    county_fips <- NULL

    if (!is.null(county)) {
      county_fips <- suppressMessages(mapply(
        validate_county,
        state_fips,
        county,
        USE.NAMES = FALSE
      ))
    }
  }

  if (int) {
    state_fips <- as.integer(state_fips)

    if (!is.null(county_fips)) {
      county_fips <- as.integer(county_fips)
    }
  }

  if (list) {
    return(
      list(
        "state" = state_fips,
        "county" = county_fips
      )
    )
  }

  if (!is.null(county_fips)) {
    return(county_fips)
  }

  state_fips
}

#' @noRd
rename_fars_vars <- function(x, reorder = TRUE, rename = TRUE) {
  x_vars <- fars_vars_labels[fars_vars_labels[["name"]] %in% names(x), ]
  # Some variables are listed for multiple data files so keep the first
  x_vars <- x_vars[!duplicated(x_vars[["name"]]), ]

  if (nrow(x_vars) == 0) {
    return(x)
  }

  x_name <- x_vars[["name"]]

  if (isTRUE(reorder)) {
    # Reorder columns to match analytical manual order and keep any
    # unrecognized columns at the end
    x <- x[, c(x_name, setdiff(names(x), x_name)), drop = FALSE]
  }

  if (!isTRUE(rename)) {
    return(x)
  }

  dplyr::rename(x, !!!rlang::set_names(x_name, x_vars[["nm"]]))
}

#' Add variable labels from fars_vars_labels as column attributes
#' @noRd
label_fars_vars <- function(x) {
  x_vars <- fars_vars_labels[
    fars_vars_labels[["name"]] %in%
      names(x) &
      !is.na(fars_vars_labels[["label"]]),
  ]
  x_vars <- x_vars[!duplicated(x_vars[["name"]]), ]

  x_labels <- rlang::set_names(x_vars[["label"]], x_vars[["name"]])

  for (nm in names(x_labels)) {
    attr(x[[nm]], "label") <- x_labels[[nm]]
  }

  x
}

#' Format crash data
#'
#' Reorder columns to match the order documented in Fatality Analysis Reporting
#' System (FARS) Analytical User's Manual, 1975-2019, convert coordinate and
#' count columns to numeric and integer values, and append derived columns for
#' date, time, and datetime. Column names are kept as returned by the API.
#'
#' @param x Data frame with crash data.
#' @param details If `TRUE`, append date, time, datetime columns to formatted
#'   crash data; defaults to TRUE
#' @param labels If `TRUE` (default), add a `"label"` attribute to each column
#'   with a variable label from [fars_vars_labels]. Labels are shown by
#'   [View()] in RStudio and Positron and used by packages such as gt and
#'   gtsummary.
#' @export
#' @importFrom dplyr mutate
#' @importFrom rlang .data
#' @importFrom stringr str_pad
format_crashes <- function(x, details = TRUE, labels = TRUE) {
  # Reorder columns but keep the API column names
  crash_df <- rename_fars_vars(x, rename = FALSE)

  crash_df <-
    dplyr::mutate(
      crash_df,
      dplyr::across(
        dplyr::any_of(c("LATITUDE", "LONGITUD")),
        ~ as.numeric(.x)
      ),
      dplyr::across(
        dplyr::any_of(c(
          "CaseYear",
          "TOTALVEHICLES",
          "VE_FORMS",
          "FATALS",
          "PEDS",
          "PERSONS"
        )),
        ~ as.integer(.x)
      )
    )

  date_cols <- c("ST_CASE", "YEAR", "MONTH", "DAY", "HOUR", "MINUTE")

  if (isTRUE(details) && all(date_cols %in% names(crash_df))) {
    pad_hm <- function(x) {
      stringr::str_pad(x, width = 2, pad = "0")
    }

    # Append date/time columns
    crash_df <- dplyr::mutate(
      crash_df,
      date = paste(
        .data[["YEAR"]],
        .data[["MONTH"]],
        .data[["DAY"]],
        sep = "-"
      ),
      time = paste(
        pad_hm(.data[["HOUR"]]),
        pad_hm(.data[["MINUTE"]]),
        sep = ":"
      ),
      datetime = as.POSIXct(
        paste(date, time),
        format = "%Y-%m-%d %H:%M",
        tz = "UTC"
      ),
      date = as.Date(date),
      .after = "ST_CASE"
    )
  }

  if (!isTRUE(labels)) {
    return(crash_df)
  }

  label_fars_vars(crash_df)
}

#' Helper function to return date added or updated for package data for documentation
#'
#' @noRd
#' @importFrom stringr str_to_sentence
pkg_data_date <- function(
  data,
  date = "added",
  format = "%B %d %Y",
  verbose = TRUE,
  pkg = "crashapi"
) {
  data_date <-
    pkg_data_index[pkg_data_index[["data"]] == data, ][[paste0("date_", date)]]

  if (!verbose) {
    return(data_date)
  }

  data_date <-
    format(as.Date(data_date), format = format)

  glue::glue("{stringr::str_to_sentence(date)}: {data_date}")
}

# ---
# repo: r-lib/rlang
# file: standalone-purrr.R
# last-updated: 2022-06-07
# license: https://unlicense.org
# ---

#' @keywords internal
#' @importFrom rlang as_function global_env
map <- function(.x, .f, ...) {
  .f <- rlang::as_function(.f, env = rlang::global_env())
  lapply(.x, .f, ...)
}


# ---
# repo: tidyverse/purrr
# file: list-combine.R
# last-updated: 2022-11-10
# license: https://purrr.tidyverse.org/LICENSE.html
# ---

#' Combine list elements into a single data structure
#'
#' @description
#'
#' * `list_rbind()` combines elements into a data frame by row-binding them
#'   together with [vctrs::vec_rbind()].
#' @keywords internal
#' @importFrom rlang zap check_dots_empty current_env
#' @importFrom vctrs vec_rbind
list_rbind <- function(x, ..., names_to = rlang::zap(), ptype = NULL) {
  rlang::check_dots_empty(...)
  vctrs::vec_rbind(
    !!!x,
    .names_to = names_to,
    .ptype = ptype,
    .error_call = rlang::current_env()
  )
}
