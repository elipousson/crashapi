#' Get Fatality Analysis Reporting System (FARS) data tables
#'
#' `get_fars()` returns a FARS data table (e.g. accident, person, or vehicle)
#' for one or more states, an optional county, and one or more years, using
#' the CrashAPI or the zipped data files from the NHTSA downloads site:
#'
#' - With `source = "auto"` (default), data for a state from 2010 onwards
#' comes from the CrashAPI with [get_fars_year()]. National data (`state =
#' NULL`), data for Puerto Rico (`state = "PR"`), and data before 2010 comes
#' from zipped data files with [get_fars_zip()], which are converted to parquet
#' files and cached so later calls do not download the data again.
#' - Data from zipped files is filtered to the requested states and, if
#' needed, a `CASEYEAR` column is added so the data matches the CrashAPI.
#' - If `county` is provided, tables with a `COUNTY` column (accident and
#' person) are filtered by county and other tables are filtered to crashes in
#' the county from the accident table (matching `ST_CASE` and `CASEYEAR`).
#'
#' Use [get_fars_crashes()], [get_fars_cases()], [get_fars_crash_list()], or
#' [get_fars_summary()] to access other CrashAPI endpoints.
#'
#' @param state One or more state names, abbreviations, or FIPS numbers. If
#'   `NULL` (default), returns national data. Use "PR" for Puerto Rico.
#' @param year One or more years from 1975 to 2024 (or from 2010 for the
#'   CrashAPI). The minimum and maximum values are used as the start and end
#'   year, with a message if `year` has gaps. Defaults to
#'   `getOption("crashapi.year", 2024)`.
#' @param type Name of the FARS data table, e.g. "accident" (default),
#'   "person", or "vehicle". Lowercase or uppercase values are permitted. The
#'   available tables vary by year and source; see [get_fars_year()] for tables
#'   available from the CrashAPI.
#' @param county County name or FIPS number. Requires a single `state`.
#' @param source Source for the data: "auto" (default), "api" for the CrashAPI,
#'   or "zip" for zipped data files.
#' @param ... Additional parameters passed to [get_fars_zip()] when data comes
#'   from zipped data files, e.g. `path`, `overwrite`, or `keep_files`.
#' @param geometry If `TRUE`, return an sf object. Only supported for tables
#'   with `LATITUDE` and `LONGITUD` columns (e.g. accident).
#' @param crs Coordinate reference system to use if `geometry` is `TRUE`.
#' @param decode How to decode coded values using [decode_fars()]: "names"
#'   (default) adds `…NAME` columns with decoded values where they are missing
#'   (data from the CrashAPI and FARS zipped CSV files from 2015 onwards already
#'   include them), "replace" replaces codes with factors of decoded values,
#'   "labelled" adds value labels with [haven::labelled()], and "none" doesn't
#'   decode values. See [decode_fars()] for details.
#' @inheritParams format_crashes
#' @returns A data frame, or an sf object if `geometry = TRUE`. If tables for
#'   multiple years from zipped data files can't be combined, a list of data
#'   frames named by year.
#' @examples
#' # Person table for Maryland from the CrashAPI
#' head(get_fars(state = "MD", year = 2022, type = "person"), 5)
#'
#' # Accident table for Baltimore City
#' get_fars(state = "MD", county = "Baltimore city", year = 2022)
#'
#' \donttest{
#' # National accident table from the zipped data files
#' get_fars(year = 2024)
#' }
#' @export
get_fars <- function(
  state = NULL,
  year = getOption("crashapi.year", 2024),
  type = "accident",
  county = NULL,
  source = c("auto", "api", "zip"),
  ...,
  geometry = FALSE,
  crs = NULL,
  decode = c("names", "replace", "labelled", "none"),
  var_labels = c("attribute", "none")
) {
  source <- match.arg(source)
  decode <- rlang::arg_match(decode)
  year <- year_span(validate_year(year, year_range = c(1975, 2024)))
  years <- seq(year[[1]], year[[2]])

  if (!rlang::is_string(type)) {
    cli_abort("{.arg type} must be a single table name.")
  }

  type <- tolower(type)

  if (!is.null(county) && length(state) != 1) {
    cli_abort("{.arg county} requires a single {.arg state}.")
  }

  # Check the county before getting any data
  if (!is.null(county)) {
    lookup_fips(state, county)
  }

  is_pr <- !is.null(state) && all(lookup_fips(state, several.ok = TRUE) == 72)

  if (source == "auto") {
    source <- "api"

    if (is.null(state) || is_pr || year[[1]] < 2010) {
      source <- "zip"
    }
  }

  if (source == "api") {
    if (is.null(state) || is_pr || year[[1]] < 2010) {
      cli_abort(
        c(
          "{.code source = \"api\"} requires a {.arg state} (other than
          Puerto Rico) and years from 2010 onwards.",
          "i" = "Use {.code source = \"zip\"} for national data, Puerto Rico,
          or years before 2010."
        )
      )
    }

    if (...length() > 0) {
      cli::cli_warn(
        "Additional parameters in {.arg ...} are ignored when
        {.code source = \"api\"}."
      )
    }

    fars_data <- get_fars_api_table(state, year, type)
  } else {
    fars_data <- get_fars_zip_table(state, years, type, is_pr = is_pr, ...)
  }

  if (!is.null(county)) {
    fars_data <- filter_fars_county(
      fars_data,
      state = state,
      county = county,
      year = year,
      source = source,
      ...
    )
  }

  if (is.data.frame(fars_data)) {
    return(finish_fars_table(
      fars_data,
      type,
      geometry,
      crs,
      var_labels,
      decode
    ))
  }

  lapply(fars_data, finish_fars_table, type, geometry, crs, var_labels, decode)
}

#' Get a FARS data table for one or more states from the CrashAPI
#'
#' The CrashAPI returns all values as character strings so columns are
#' converted to numeric or logical values where possible to match the data
#' from zipped data files.
#' @noRd
get_fars_api_table <- function(state, year, type) {
  fars_df <- list_rbind(
    map(
      lookup_fips(state, several.ok = TRUE),
      function(state_fips) {
        get_fars_year(
          state = state_fips,
          year = year,
          type = type,
          var_labels = "none"
        )
      }
    )
  )

  if (is.null(fars_df)) {
    return(fars_df)
  }

  fars_df[] <- lapply(fars_df, utils::type.convert, as.is = TRUE)
  fars_df
}

#' Get a FARS data table from cached parquet files for zipped data files
#' @noRd
get_fars_zip_table <- function(
  state,
  years,
  type,
  is_pr = FALSE,
  ...,
  call = caller_env()
) {
  state_fips <- NULL

  if (!is.null(state) && !is_pr) {
    state_fips <- lookup_fips(state, several.ok = TRUE)
  }

  tables <- lapply(years, function(year) {
    parquet_files <- get_fars_zip(year = year, pr = is_pr, read = FALSE, ...)

    if (!rlang::has_name(parquet_files, type)) {
      cli_abort(
        c(
          "The {.val {type}} table is not available for {year}.",
          "i" = "Available tables: {.val {names(parquet_files)}}"
        ),
        call = call
      )
    }

    fars_df <- nanoparquet::read_parquet(parquet_files[[type]])

    if (!is.null(state_fips)) {
      fars_df <- fars_df[fars_df[["STATE"]] %in% state_fips, ]
    }

    # Add a case year column to match tables from the CrashAPI
    if (is.null(fars_year_col(fars_df))) {
      fars_df[["CASEYEAR"]] <- year
    }

    fars_df
  })

  if (length(tables) == 1) {
    return(tables[[1]])
  }

  tryCatch(
    list_rbind(tables),
    error = function(cnd) {
      cli::cli_warn(
        c(
          "The {.val {type}} tables for {years} can't be combined.",
          "i" = "Returning a list of tables named by year."
        ),
        parent = cnd,
        call = call
      )

      rlang::set_names(tables, years)
    }
  )
}

#' Get the case year column name for a FARS data table
#' @noRd
fars_year_col <- function(x) {
  year_col <- intersect(c("CASEYEAR", "CaseYear"), names(x))

  if (length(year_col) == 0) {
    return(NULL)
  }

  year_col[[1]]
}

#' Filter a FARS data table (or list of tables) by county
#'
#' Tables without a COUNTY column are filtered to crashes in the county from
#' the accident table, matching on ST_CASE and the case year.
#' @noRd
filter_fars_county <- function(
  fars_data,
  state,
  county,
  year,
  source,
  ...,
  call = caller_env()
) {
  county_fips <- lookup_fips(state, county, call = call)

  if (!is.data.frame(fars_data)) {
    return(
      lapply(
        fars_data,
        filter_fars_county,
        state = state,
        county = county,
        year = year,
        source = source,
        ...
      )
    )
  }

  if (rlang::has_name(fars_data, "COUNTY")) {
    return(fars_data[fars_data[["COUNTY"]] %in% county_fips, ])
  }

  accident <- get_fars(
    state = state,
    year = year,
    type = "accident",
    county = county,
    source = source,
    ...,
    var_labels = "none"
  )

  if (!is.data.frame(accident)) {
    accident <- list_rbind(unname(accident))
  }

  case_key <- function(x) {
    paste(x[["ST_CASE"]], x[[fars_year_col(x)]])
  }

  fars_data[case_key(fars_data) %in% case_key(accident), ]
}

#' Add geometry and labels to a FARS data table
#' @noRd
finish_fars_table <- function(
  fars_df,
  type,
  geometry,
  crs,
  var_labels,
  decode = "none"
) {
  # Data has a case year column (added to data from zipped data files by
  # get_fars_zip_table()) so the value labels for each year can be used
  if (decode != "none" && !is.null(fars_year_col(fars_df))) {
    fars_df <- decode_fars(
      fars_df,
      table = type,
      decode = decode,
      source = "FARS"
    )
  }

  if (geometry) {
    coords <- c("LONGITUD", "LATITUDE")

    if (all(coords %in% names(fars_df))) {
      fars_df <- df_to_sf(fars_df, crs = crs)
    } else {
      cli::cli_warn(
        c(
          "Coordinate columns {coords} can't be found in the
          {.val {type}} table.",
          "i" = "Use {.code type = \"accident\"} with {.code geometry = TRUE}
          to return an sf object."
        )
      )
    }
  }

  if (!use_var_labels(var_labels)) {
    return(fars_df)
  }

  label_fars_vars(fars_df, data_file = toupper(type))
}

#' @title Get crash data from the CrashAPI
#' @description These functions access specific endpoints of DOT NHTSA's
#'   CrashAPI:
#'
#'   - `get_fars_crashes` returns a list of fatal crashes in a county.
#'   - `get_fars_cases` returns details for one or more fatal crashes by case
#'   number.
#'   - `get_fars_crash_list` returns a list of fatal crashes that have occurred
#'   in one or more states with a range of vehicles involved.
#'   - `get_fars_summary` provides a count of crashes and fatalities by year for
#'   a state.
#'   - `get_fars_year` provides a FARS data table for a state.
#'
#'   Both `get_fars_crash_list` and `get_fars_crashes` limit the returned data
#'   to 5000 records so consider limiting the range of years requested if data
#'   exceeds that threshold.
#'
#'   Use [get_fars()] to get FARS data tables for any state, county, or year
#'   (including national data and years before 2010) from the CrashAPI or the
#'   NHTSA data downloads site.
#'
#' @param year numeric vector. One or more years. For `get_fars_crashes`,
#'   `get_fars_crash_list`, `get_fars_summary`, and `get_fars_year`, the minimum and maximum values are used as
#'   the start and end year, so `year = 2015:2020` and `year = c(2015, 2020)`
#'   both request data from 2015 through 2020 (with a message if `year` has
#'   gaps). For `get_fars_cases`, `year` must be a single year or one year for
#'   each case in `cases`. The CrashAPI supports the years from 2010 through
#'   2024. Defaults to
#'   `getOption("crashapi.year", 2024)` so the default year can be set for all
#'   functions with `options(crashapi.year = 2022)`.
#' @param state Required. State name, abbreviation, or FIPS number.
#'   `get_fars_crash_list` supports multiple states.
#' @param county  County name or FIPS number. Required for `get_fars_crashes`.
#' @param geometry If `TRUE`, return sf object. Optional for `get_fars_crashes`.
#' @param crs Coordinate reference system to return for `get_fars_crashes` if
#'   `geometry` is `TRUE`.
#' @param type Name of the FARS data table. Supported values include "ACCIDENT",
#'   "CEVENT", "DAMAGE", "DISTRACT", "DRIMPAIR", "DRUGS", "FACTOR",
#'   "MANEUVER", "NMCRASH", "NMIMPAIR", "NMPRIOR", "PARKWORK", "PBTYPE",
#'   "PERSON", "SAFETYEQ", "VEHICLE", "VEVENT", "VINDECODE", "VINDERIVED",
#'   "VIOLATION", "VISION", and "VSOE". "TRAILERVINDERIVED" is supported for
#'   2016 onwards, "NMDISTRACT" and "RACE" for 2019 onwards, and "CRASHRF",
#'   "DRIVERRF", "PERSONRF", "PVEHICLESF", "VEHICLESF", and "WEATHER" for
#'   2020 onwards for `get_fars_year`. Lowercase or mixed case values are
#'   permitted.
#' @param cases One or more FARS case numbers. Required for `get_fars_cases`.
#' @param details For `get_fars_crashes`, if `TRUE`, detailed case data
#'   (excluding event and vehicle data) is joined to the crash data. For
#'   `get_fars_cases`, if `TRUE`, event and vehicle data are included as list
#'   columns, or use "events" or "vehicles" to return the event or vehicle data
#'   for all cases. Default: `FALSE`.
#' @param vehicles numeric vector with the minimum and maximum number of
#'   vehicles, e.g. c(1, 2) for minimum of 1 vehicle and maximum of 2. Required
#'   for `get_fars_crash_list`.
#' @param format Format to request from the CrashAPI for `get_fars_year`
#'   ("json" or "csv"). Default: "json".
#' @param path Directory to save the file if `download` is `TRUE` for
#'   `get_fars_year`.
#' @param download logical. If `TRUE`, `get_fars_year` downloads the data to a
#'   file instead of returning a data frame. Default `FALSE`.
#' @inheritParams format_crashes
#' @inheritParams rlang::args_error_context
#' @rdname get_fars_crashes
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
#' @aliases get_fars_crashes
#' @export
#' @importFrom cli cli_abort
get_fars_crashes <- function(
  state,
  county,
  year = getOption("crashapi.year", 2024),
  details = FALSE,
  geometry = FALSE,
  crs = NULL,
  var_labels = c("attribute", "none")
) {
  year <- year_span(validate_year(year))

  if (missing(county) || is.null(county)) {
    cli_abort(
      "{.arg county} must be a valid county name or FIPS code."
    )
  }

  fips <- lookup_fips(state, county, list = TRUE)

  crash_df <-
    read_crashapi(
      data = "crashes",
      type = "GetCrashesByLocation",
      fromCaseYear = year[[1]],
      toCaseYear = year[[2]],
      state = fips[["state"]],
      county = fips[["county"]],
      format = "json"
    )

  if (rlang::is_empty(crash_df)) {
    cli::cli_warn(
      "No records found with the provided parameters."
    )
    return(invisible(NULL))
  }

  if (nrow(crash_df) == 5000) {
    cli_bullets(
      c(
        "!" = "Additional records may be available for this query.",
        "i" = "The API used by {.fn get_fars_crashes} limits responses
        to 5000 records or less."
      )
    )
  }

  if (isTRUE(details)) {
    # Use the case year for each crash since case numbers are only unique
    # within a year
    cases_df <-
      get_fars_cases(
        year = crash_df$CaseYear,
        state = state,
        cases = crash_df$ST_CASE,
        details = TRUE,
        geometry = FALSE,
        var_labels = "none"
      )

    cases_df <-
      subset(
        cases_df,
        select = -c(
          STATENAME,
          VE_FORMS,
          TWAY_ID,
          TWAY_ID2,
          LONGITUD,
          LATITUDE,
          FATALS,
          CITY,
          CITYNAME,
          COUNTY,
          COUNTYNAME
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

  format_crashes(crash_df, details = details, var_labels = var_labels)
}

#' @rdname get_fars_crashes
#' @aliases get_fars_cases get_fars_crash_details
#' @export
#' @importFrom cli cli_abort cli_progress_along
get_fars_cases <- function(
  state,
  cases,
  year = getOption("crashapi.year", 2024),
  details = FALSE,
  geometry = FALSE,
  crs = NULL,
  var_labels = c("attribute", "none")
) {
  if (missing(cases)) {
    cli_abort(
      "One or more valid FARS case numbers must be provided
      to download detailed crash data."
    )
  }

  year <- validate_year(year)

  if (!(length(year) %in% c(1, length(cases)))) {
    cli_abort(
      "{.arg year} must be a single year or one year for each case in
      {.arg cases}, not {length(year)} year{?s} for {length(cases)} case{?s}."
    )
  }

  year <- rep_len(year, length(cases))
  state_fips <- lookup_fips(state)

  crash_df <-
    list_rbind(
      map(
        cli::cli_progress_along(cases),
        ~ read_crashapi(
          type = "GetCaseDetails",
          stateCase = as.list(cases)[[.x]],
          caseYear = year[[.x]],
          state = state_fips,
          results = TRUE,
          format = "json"
        )[["CrashResultSet"]]
      )
    )

  if (rlang::is_empty(crash_df)) {
    cli_abort(
      "No case details found for {.arg cases} {.val {cases}}."
    )
  }

  if (is.logical(details)) {
    if (!isTRUE(details)) {
      crash_df <-
        subset(
          crash_df,
          select = !(names(crash_df) %in% c("CEvents", "Vehicles"))
        )
    }

    if (geometry) {
      crash_df <- df_to_sf(crash_df, crs = crs)
    }

    if (use_var_labels(var_labels)) {
      crash_df <- label_fars_vars(crash_df, data_file = "ACCIDENT")
    }

    return(crash_df)
  }

  stopifnot(is.character(details))

  details <- tolower(details)
  details <- match.arg(details, c("events", "vehicles"))

  details_col <- switch(details, "events" = "CEvents", "vehicles" = "Vehicles")

  # Combine the nested data frames for all cases
  details_df <- list_rbind(crash_df[[details_col]])

  if (!use_var_labels(var_labels)) {
    return(details_df)
  }

  label_fars_vars(details_df, data_file = fars_list_cols[[details_col]])
}

#' @rdname get_fars_crashes
#' @aliases get_fars_crash_list
#' @export
get_fars_crash_list <- function(
  state,
  year = getOption("crashapi.year", 2024),
  vehicles = c(1, 50),
  var_labels = c("attribute", "none")
) {
  year <- year_span(validate_year(year))

  states_fips <-
    paste0(lookup_fips(state, several.ok = TRUE), collapse = ",")

  crash_df <-
    read_crashapi(
      states = states_fips,
      type = "GetCaseList",
      fromYear = year[[1]],
      toYear = year[[2]],
      minNumOfVehicles = min(vehicles),
      maxNumOfVehicles = max(vehicles)
    )

  if (rlang::is_empty(crash_df)) {
    return(NULL)
  }

  format_crashes(crash_df, var_labels = var_labels)
}

#' @rdname get_fars_crashes
#' @aliases get_fars_summary
#' @export
get_fars_summary <- function(
  state,
  year = getOption("crashapi.year", 2024),
  var_labels = c("attribute", "none")
) {
  year <- year_span(validate_year(year))

  crash_df <-
    read_crashapi(
      data = "analytics",
      type = "GetInjurySeverityCounts",
      fromCaseYear = year[[1]],
      toCaseYear = year[[2]],
      state = lookup_fips(state)
    )

  format_crashes(crash_df, var_labels = var_labels)
}

#' @rdname get_fars_crashes
#' @export
#' @importFrom stringr str_to_sentence
#' @importFrom cli cli_warn
#' @importFrom httr2 resp_body_json req_perform request
get_fars_year <- function(
  state,
  year = getOption("crashapi.year", 2024),
  type = "accident",
  format = "json",
  path = NULL,
  geometry = FALSE,
  crs = NULL,
  download = FALSE,
  var_labels = c("attribute", "none"),
  call = caller_env()
) {
  year <- year_span(validate_year(year, call = call))
  state_fips <- lookup_fips(state)

  # This exports the FARS data by given year (2010 - 2020). In order to get the
  # FARS Data, please send in the Dataset Name, Case Year range (From Year - To
  # Year) and State code. Note: To export all state data (*), please restrict
  # the case year range to 5 years. The following are the valid dataset names:
  # ACCIDENT, CEVENT, CRASHRF (2020 Onwards), DAMAGE, DISTRACT, DRIMPAIR,
  # DRIVERRF (2020 Onwards), DRUGS, FACTOR, MANEUVER, NMCRASH, NMDISTRACT (2019
  # Onwards), NMIMPAIR, NMPRIOR, PARKWORK, PBTYPE, PERSON, PERSONRF (2020
  # Onwards), PVEHICLESF (2020 Onwards), RACE, SAFETYEQ, TRAILERVINDERIVED,
  # VEHICLE, VEHICLESF (2020 Onwards), VEVENT, VINDECODE, VINDERIVED, VIOLATION,
  # VISION, VSOE, WEATHER (2020 Onwards)

  fars_tabs <- c(
    "ACCIDENT",
    "CEVENT",
    "DAMAGE",
    "DISTRACT",
    "DRIMPAIR",
    "DRUGS",
    "FACTOR",
    "MANEUVER",
    "NMCRASH",
    "NMIMPAIR",
    "NMPRIOR",
    "PARKWORK",
    "PBTYPE",
    "PERSON",
    "SAFETYEQ",
    "VEHICLE",
    "VEVENT",
    "VINDECODE",
    "VINDERIVED",
    "VIOLATION",
    "VISION",
    "VSOE"
  )

  # Add 2016, 2019, and 2020 onwards tables to the data
  if (min(year) >= 2016) {
    fars_tabs <- c(fars_tabs, "TRAILERVINDERIVED")
  }

  if (min(year) >= 2019) {
    # Race was moved from the PERSON table to a separate RACE table in 2019
    fars_tabs <- c(fars_tabs, "NMDISTRACT", "RACE")
    if (min(year) >= 2020) {
      fars_tabs <- c(
        fars_tabs,
        "CRASHRF",
        "DRIVERRF",
        "PERSONRF",
        "PVEHICLESF",
        "VEHICLESF",
        "WEATHER"
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
      FromYear = year[[1]],
      ToYear = year[[2]],
      State = state_fips,
      format = format,
      results = FALSE
    )

  # Use the same headers as read_crashapi() for both formats since the API
  # rejects requests without browser headers
  request <- req_crashapi_headers(httr2::request(url))

  if (!download) {
    if (format == "csv") {
      rlang::check_installed("readr")
    }

    resp <- httr2::req_perform(request, error_call = call)

    crash_df <-
      switch(
        format,
        "json" = httr2::resp_body_json(
          resp,
          simplifyVector = TRUE,
          check_type = FALSE
        )[["Results"]][[1]],
        "csv" = readr::read_csv(I(httr2::resp_body_string(resp)))
      )

    coords <- c("LONGITUD", "LATITUDE")

    if (geometry && all(coords %in% names(crash_df))) {
      crash_df <- df_to_sf(x = crash_df, crs = crs)
    } else if (geometry) {
      cli::cli_warn(
        c(
          "Coordinate columns {coords} can't be found in data of
            the type {.val {type}}.",
          "i" = 'Use {.code type = "accident"} with
            {.code geometry = TRUE} to return an sf object.'
        )
      )
    }

    if (use_var_labels(var_labels)) {
      crash_df <- label_fars_vars(crash_df, data_file = type)
    }

    return(crash_df)
  }

  filename <- paste0(min(year), "_", max(year), "_", type, ".", format)

  if (!is.null(path)) {
    filename <- file.path(path, filename)
  }

  resp <- httr2::req_perform(request, error_call = call)
  writeBin(httr2::resp_body_raw(resp), filename)

  invisible(filename)
}
