#' @rdname get_fars_crash_vehicles
#' @title Get Crashes By Vehicle
#' @description This function returns a list of fatal crashes involving a
#'   specific vehicle make, model, model year, and body type using the CrashAPI
#'   GetCrashesByVehicle endpoint. The make, model, and body type can be names
#'   or ID numbers matching the options returned by [fars_vars()]. Names are
#'   converted to ID numbers for use in the API query.
#'
#' # API behavior
#'
#' NHTSA's documentation says this endpoint accepts "one or more" vehicle
#' details for make, model, model year, and body type. However, testing in
#' October 2026 found that the API does not behave this way: the API returns an
#' error (HTTP 404) unless all four are provided and an error message if any
#' are blank. For this reason, `make`, `model`, `model_year`, and `body_type`
#' are all required.
#'
#' To find crashes using other vehicle criteria, download the vehicle table
#' with [get_fars_year()] using `type = "vehicle"` and filter the data.
#'
#' @inheritParams get_fars
#' @param year numeric vector. One or more years from 2010 to 2024. The minimum
#'   and maximum values are used as the start and end year. Defaults to
#'   `getOption("crashapi.year", 2024)`.
#' @param state Required. State name, abbreviation, or FIPS number.
#' @param make Required. Make name or ID, e.g. "Ford" or 12. Valid options are
#'   returned by `fars_vars(var = "make")` for the earliest year in `year`.
#' @param model Required. Model name or ID. Valid options are returned by
#'   `fars_vars(var = "model", make = make)`.
#' @param model_year Required. Vehicle model year.
#' @param body_type Required. Body type name or ID. Valid options are returned
#'   by `fars_vars(var = "bodytype", make = make, model = model)`.
#' @examples
#' get_fars_crash_vehicles(
#'   state = "CA",
#'   make = "Ford",
#'   model = 37,
#'   model_year = 2012,
#'   body_type = 4,
#'   year = 2022
#' )
#' @export
get_fars_crash_vehicles <- function(
  state,
  make,
  model,
  model_year,
  body_type,
  year = getOption("crashapi.year", 2024),
  var_labels = c("attribute", "none")
) {
  rlang::check_required(make)
  rlang::check_required(model)
  rlang::check_required(model_year)
  rlang::check_required(body_type)

  year <- year_span(validate_year(year))
  state_fips <- lookup_fips(state)

  model_year_code <- suppressWarnings(as.integer(model_year))

  if (length(model_year) != 1 || is.na(model_year_code)) {
    cli_abort("{.arg model_year} must be a single year.")
  }

  make <- match_fars_option(
    make,
    fars_vars(year = year[[1]], var = "make"),
    id_col = "ID",
    name_col = "TEXT"
  )

  model <- match_fars_option(
    model,
    fars_vars(year = year[[1]], var = "model", make = make),
    id_col = "ID",
    name_col = "MODELNAME"
  )

  body_type <- match_fars_option(
    body_type,
    fars_vars(var = "bodytype", make = make, model = model),
    id_col = "BODY_ID",
    name_col = "BODY_DEF"
  )

  crash_df <- read_crashapi(
    data = "crashes",
    type = "GetCrashesByVehicle",
    make = make,
    model = model,
    modelyear = model_year_code,
    bodyType = body_type,
    fromCaseYear = year[[1]],
    toCaseYear = year[[2]],
    state = state_fips,
    format = "json"
  )

  if (!use_var_labels(var_labels) || rlang::is_empty(crash_df)) {
    return(crash_df)
  }

  label_fars_vars(crash_df)
}
