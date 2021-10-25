#' @title Get variables and variable attributes for the Fatality Analysis
#'   Reporting System (FARS) API
#' @description By default, this function returns the returns the list of
#'   variables for the data year specified. If `vars` is "make", "model", or
#'   "bodytype", the function returns #'   list of variable attributes for the
#'   specified variable name or attributes for make model and body type
#'   specified in the FARS dataset.
#' @param year Case year. Year must be between 2010 and 2019.
#' @param var Default NULL. Supported values are "make", "model", and
#'   "bodytype". Using the var parameter returns variable attributes for the
#'   specified variable name or attributes for make model and body type
#'   specified in the dataset.
#' @param make Integer. Make ID number. Required to return variables for "model"
#'   and "bodytype". Get a list of make ID numbers using the "make" var for the
#'   selected year, e.g. `fars_vars(year = 2010, var = "make")`.
#' @param model Integer. Model ID number. Required to return variables for
#'   "bodytype". Get a list of model ID numbers using the "model" var for the
#'   selected year with a valid make ID number, e.g. `fars_vars(year = 2010, var
#'   = "model", make = 37)`
#' @rdname fars_vars
#' @export
#' @importFrom glue glue
#' @importFrom jsonlite read_json
fars_vars <- function(year, var = NULL, make = NULL, model = NULL) {
  if ((year >= 2020 | year <= 2009) & !is.null(year)) {
    stop("The year must be between 2010 and 2019.")
  }

  query <- "https://crashviewer.nhtsa.dot.gov/CrashAPI"

  if (!is.null(var)) {
    var <- match.arg(var, c("make", "model", "bodytype"))
    if (var == "make") {
      query <- glue::glue("{query}/definitions/GetVariableAttributes?variable={var}&caseYear={year}&format=json")
    } else if (var == "model") {
      query <- glue::glue("{query}/definitions/GetVariableAttributesForModel?variable={var}&caseYear={year}&make={make}&format=json")
    } else if (var == "bodytype") {
      query <- glue::glue("{query}/definitions/GetVariableAttributesForbodyType?variable={var}&make={make}&model={model}&format=json")
    }
  } else {
    query <- glue::glue("{query}/definitions/GetVariables?dataYear={year}&format=json")
  }

  jsonlite::read_json(query, simplifyVector = TRUE)$Results[[1]]
}

