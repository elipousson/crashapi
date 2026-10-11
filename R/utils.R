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
#' <https://crashviewer.nhtsa.dot.gov/crashviewer/CrashAPI>
#'
#' @param url Base url for CrashAPI.
#' @param data Data (crashes, analytics, or fars), Default: 'crashes'
#' @param type Type of API to use, Default: `NULL`
#' @param format Format to return, Default: 'json'
#' @param results If `FALSE`, return formatted url, Default: `TRUE`
#' @param ... Additional parameters used in template (varies by type).
#' @param cookie_file File name passed to [tempfile()] for the temporary cookie
#'   file used to preserve cookies between requests.
#' @inheritParams rlang::args_error_context
#' @return Data frame with requested data or a formatted url (if `results = FALSE`)
#' @export
#' @importFrom httr2 req_template request req_perform resp_body_json
read_crashapi <- function(
  url = "https://crashviewer.nhtsa.dot.gov/crashviewer/CrashAPI",
  data = "crashes",
  type = NULL,
  format = "json",
  results = TRUE,
  ...,
  cookie_file = "crashapi.cookies",
  call = caller_env()
) {
  template <-
    switch(
      type,
      "GetCaseList" = "GET /{data}/{type}?states={states}&fromYear={fromYear}&toYear={toYear}&minNumOfVehicles={minNumOfVehicles}&maxNumOfVehicles={maxNumOfVehicles}&format={format}",
      "GetCaseDetails" = "GET /{data}/{type}?stateCase={stateCase}&caseYear={caseYear}&state={state}&format={format}",
      "GetCrashesByVehicle" = "GET /{data}/{type}?make={make}&model={model}&modelyear={modelyear}&bodyType={bodyType}&fromCaseYear={fromCaseYear}&toCaseYear={toCaseYear}&state={state}&format={format}",
      "GetCrashesByPerson" = "GET /{data}/{type}?age={age}&sex={sex}&seatPos={seatPos}&injurySeverity={injurySeverity}&fromCaseYear={fromCaseYear}&toCaseYear={toCaseYear}&state={state}&format={format}",
      "GetCrashesByLocation" = "GET /{data}/{type}?fromCaseYear={fromCaseYear}&toCaseYear={toCaseYear}&state={state}&county={county}&format={format}",
      "GetInjurySeverityCounts" = "GET /{data}/{type}?fromCaseYear={fromCaseYear}&toCaseYear={toCaseYear}&state={state}&format={format}",
      "GetVariables" = "GET /{data}/{type}?dataYear={dataYear}&format={format}",
      "GetVariableAttributes" = "GET /{data}/{type}?variable={variable}&caseYear={caseYear}&format={format}",
      "GetVariableAttributesForModel" = "GET /{data}/{type}?variable={variable}&caseYear={caseYear}&make={make}&format={format}",
      "GetVariableAttributesForbodyType" = "GET /{data}/{type}?variable={variable}&make={make}&model={model}&format={format}",
      # "GetFARSData" = "GET /{data}/{type}?dataset={dataset}&caseYear={caseYear}&format={format}"
      "GetFARSData" = "GET /{data}/{type}?dataset={dataset}&FromYear={FromYear}&ToYear={ToYear}&State={State}&format={format}"
    )

  req <- httr2::request(url) |>
    req_crashapi_headers(cookie_file)

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

  # FIXME: Implement a way of dealing with alternate formats
  data <- httr2::resp_body_json(
    httr2::req_perform(request, error_call = call),
    check_type = FALSE,
    simplifyVector = TRUE
  )

  results <- data[["Results"]]

  if (isTRUE(data[["Count"]] == 0) || length(results) == 0) {
    cli::cli_bullets(
      c(
        "!" = data[["Message"]] %||% "No results returned by the CrashAPI.",
        "*" = "Adjust search criteria and try again: {data[['SearchCriteria']]}"
      )
    )
  }

  # The CrashAPI returns an empty list of results for some errors
  if (length(results) == 0) {
    return(NULL)
  }

  results[[1]]
}

req_crashapi_headers <- function(
  req,
  cookie_file = "crashapi.cookies"
) {
  # https://github.com/coatless-r-n-d/uscis-processing/blob/ec95d568a52d476bab8e9a81d1cb3f2814378d61/R/api.R#L9
  initial_headers <- c(
    "User-Agent" = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:131.0) Gecko/20100101 Firefox/131.0",
    "Accept" = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/png,image/svg+xml,*/*;q=0.8",
    "Accept-Language" = "en-US,en;q=0.5",
    "Accept-Encoding" = "gzip, deflate, br, zstd",
    "DNT" = "1",
    "Sec-GPC" = "1",
    "Connection" = "keep-alive",
    "Upgrade-Insecure-Requests" = "1",
    "Sec-Fetch-Dest" = "document",
    "Sec-Fetch-Mode" = "navigate",
    "Sec-Fetch-Site" = "none",
    "Sec-Fetch-User" = "?1",
    "Priority" = "u=0, i",
    "Pragma" = "no-cache",
    "Cache-Control" = "no-cache"
  )

  req |>
    httr2::req_user_agent("crashapi https://elipousson.github.io/crashapi/") |>
    httr2::req_headers(!!!initial_headers) |>
    httr2::req_cookie_preserve(tempfile(cookie_file))
}

#' Validate one or more years
#' @noRd
validate_year <- function(
  year,
  year_range = c(2010, 2024),
  call = caller_env()
) {
  if (is.null(year) || length(year) == 0) {
    cli_abort(
      "{.arg year} must be provided to download FARS data.",
      call = call
    )
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

#' Get the start and end year for API endpoints that take a year range
#'
#' Informs the user if `year` has gaps since the API returns all years between
#' the minimum and maximum year.
#' @noRd
year_span <- function(year) {
  span <- range(year)
  missing_year <- setdiff(seq(span[[1]], span[[2]]), year)

  if (length(missing_year) > 0) {
    cli::cli_inform(
      c(
        "i" = "Requesting data for all years from {span[[1]]} to {span[[2]]},
        including {.val {missing_year}} not in {.arg year}."
      )
    )
  }

  span
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

# Nested list columns returned by the CrashAPI GetCaseDetails endpoint and the
# corresponding FARS data file
fars_list_cols <- c(
  "CEvents" = "CEVENT",
  "Vehicles" = "VEHICLE",
  "Damages" = "DAMAGE",
  "Distractions" = "DISTRACT",
  "DrImpairs" = "DRIMPAIR",
  "DriverRFs" = "DRIVERRF",
  "Factors" = "FACTOR",
  "Maneuvers" = "MANEUVER",
  "Persons" = "PERSON",
  "OCCDrugs" = "DRUGS",
  "PersonRFs" = "PERSONRF",
  "Races" = "RACE",
  "TrailerVinDeriveds" = "TRAILERVINDERIVED",
  "VEvents" = "VEVENT",
  "VehicleSFs" = "VEHICLESF",
  "VinDecodes" = "VINDECODE",
  "VinDeriveds" = "VINDERIVED",
  "Violations" = "VIOLATN",
  "Visions" = "VISION",
  "Vsoes" = "VSOE",
  "NPersons" = "PERSON",
  "NmCrashes" = "NMCRASH",
  "NmImpairs" = "NMIMPAIR",
  "NmPriors" = "NMPRIOR",
  "SafetyEQs" = "SAFETYEQ",
  "PbTypes" = "PBTYPE"
)

#' Add variable labels from fars_vars_labels as column attributes
#'
#' Variable names are matched exactly and then, for any names not found in
#' fars_vars_labels, case-insensitively (e.g. CASEYEAR and CaseYear). When a
#' variable is listed more than once, labels for the matching data file are
#' preferred, then labels for variables that are not discontinued. Columns
#' with decoded values (e.g. BODY_TYPNAME) without their own label use the
#' label for the coded variable. Nested data frames in list columns are
#' labelled using the data file from fars_list_cols.
#' @noRd
label_fars_vars <- function(x, data_file = NULL) {
  for (nm in intersect(names(x), names(fars_list_cols))) {
    if (is.list(x[[nm]]) && !is.data.frame(x[[nm]])) {
      x[[nm]] <- lapply(x[[nm]], function(el) {
        if (!is.data.frame(el)) {
          return(el)
        }
        label_fars_vars(el, data_file = fars_list_cols[[nm]])
      })
    }
  }

  vars <- fars_vars_labels[!is.na(fars_vars_labels[["name"]]), ]

  # Prefer labels for the matching data file, then current variables
  vars <- vars[
    order(
      !(vars[["data_file"]] %in% data_file),
      vars[["discontinued"]] %in% TRUE
    ),
  ]

  exact <- vars[!duplicated(vars[["name"]]), ]
  exact_labels <- rlang::set_names(exact[["label"]], exact[["name"]])

  upper <- vars[!duplicated(toupper(vars[["name"]])), ]
  upper_labels <- rlang::set_names(upper[["label"]], toupper(upper[["name"]]))

  lookup_label <- function(name) {
    if (name %in% names(exact_labels)) {
      return(exact_labels[[name]])
    }

    upper_labels[toupper(name)][[1]]
  }

  x_labels <- vapply(
    names(x),
    function(name) {
      label <- lookup_label(name)

      if (is.na(label) && grepl("NAME$", name, ignore.case = TRUE)) {
        code_label <- lookup_label(sub("NAME$", "", name, ignore.case = TRUE))

        if (!is.na(code_label)) {
          label <- paste(code_label, "(name)")
        }
      }

      label
    },
    character(1)
  )

  for (nm in names(x_labels)[!is.na(x_labels)]) {
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
