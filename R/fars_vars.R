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
#' @aliases get_vars
#' @export
#' @importFrom jsonlite read_json
fars_vars <- function(year, var = NULL, make = NULL, model = NULL) {
  year <- validate_year(year, year_range = c(2010, 2019))
  data <- "definitions"

  if (is.null(var)) {
    return(
      read_crashapi(
        data = data,
        type = "GetVariables",
        dataYear = year
      )
    )
  }

  var <- match.arg(var, c("make", "model", "bodytype"))

  switch(var,
    "make" = read_crashapi(
      data = data,
      type = "GetVariableAttributes",
      variable = "make",
      caseYear = year
    ),
    "model" = read_crashapi(
      data = data,
      type = "GetVariableAttributesForModel",
      variable = "model",
      make = make,
      caseYear = year
    ),
    "bodytype" = read_crashapi(
      data = data,
      type = "GetVariableAttributesForbodyType",
      variable = "bodytype",
      make = make,
      model = model
    ),
  )
}
