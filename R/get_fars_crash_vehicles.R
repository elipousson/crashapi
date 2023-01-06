#' @rdname get_fars_crash_vehicles
#' @title Get Crashes By Vehicle
#' @description This function returns a list of fatal crashes by vehicle type
#'   that have occurred throughout United States. The make, model, and body type
#'   must match the options returned by `fars_vars`. This function accepts named
#'   options that are converted to ID numbers for use in the API query.
#'
#' @inheritParams get_fars
#' @param year numeric vector. Year or range with start and end year. 2010 to
#'   2020 supported.
#' @param state Required. State name, abbreviation, or FIPS number.
#' @param make Make name or ID, Required. The start_year is used to return a
#'   list of support make options. Default: `NULL`
#' @param model Model name or ID, Optional. Default: `NULL`
#' @param model_year Model year, Optional. Default: `NULL`
#' @param body_type Body type, Optional. `model` must be provided to use
#'   body_type parameter. Default: `NULL`
#' @export
#' @importFrom glue glue
get_fars_crash_vehicles <- function(year = NULL,
                                    start_year,
                                    end_year = NULL,
                                    state,
                                    make = NULL,
                                    model = NULL,
                                    model_year = 2010,
                                    body_type = NULL) {
  year <- validate_year(year, start_year = start_year, end_year = end_year)
  state_fips <- lookup_fips(state)

  make_options <- fars_vars(year = min(year), var = "make")

  if (make %in% make_options$TEXT) {
    make <- make_options[make_options$TEXT == make, ]$ID
  }

  make <- match.arg(make, make_options$ID)

  if (!is.null(model)) {
    model_options <- fars_vars(year = model_year, make = make, var = "model")

    if (model %in% model_options$MODELNAME) {
      model <-
        as.character(model_options[model_options$MODELNAME == model, ]$ID)
    }

    model <- match.arg(as.character(model), as.character(model_options$ID))

    if (!is.null(body_type)) {
      body_type_options <-
        fars_vars(
          year = model_year,
          make = make,
          model = model,
          var = "bodytype"
        )

      if (body_type %in% body_type_options$BODY_DEF) {
        body_type <-
          as.character(
            body_type_options[body_type_options$BODY_DEF == body_type, ]$BODY_ID
          )
      }

      body_type <- match.arg(body_type, body_type_options$BODY_ID)
    }
  }

  read_crashapi(
    data = "crashes",
    type = "GetCrashesByVehicle",
    make = make,
    bodyType = body_type,
    model = model,
    modelyear = model_year,
    fromCaseYear = min(year),
    toCaseYear = max(year),
    state = state_fips,
    format = "json",
    results = FALSE
  )
}
