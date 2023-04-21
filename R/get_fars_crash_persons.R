#' Get Crashes By Occupant
#'
#' This function returns a list of fatal crashes by occupant that have occurred
#' throughout United States. This function is not currently working.
#'
#' @rdname get_fars_crash_persons
#' @inheritParams get_fars
#' @param year numeric vector. Year or range with start and end year. 2010 to
#'   2021 supported.
#' @param state Required. State name, abbreviation, or FIPS number.
#' @param age numeric
#' @param sex Options "m", "f", "male", "female", "unknown", "not reported."
#' @param seat Seat position
#' @param injury Options "unknown", "not reported", "died prior", "injured",
#'   "fatal", "suspected serious", "suspected minor", "possible", "no apparent"
#' @param occupants Include vehicle occupants in query; defaults to `TRUE`
#' @param nonoccupants Include non-occupants in query; defaults to `TRUE`
#' @export
#' @importFrom glue glue
get_fars_crash_persons <- function(year = NULL,
                                   start_year,
                                   end_year = NULL,
                                   state,
                                   age = NULL,
                                   sex = NULL,
                                   seat,
                                   injury,
                                   occupants = TRUE,
                                   nonoccupants = TRUE) {
  year <- validate_year(year, start_year = start_year, end_year = end_year)

  if (is.character(seat)) {
    front <- grepl("front", seat)
    second <- grepl("second", seat)
    third <- grepl("third", seat)
    fourth <- grepl("fourth", seat)

    left <- grepl("left", seat)
    middle <- grepl("middle", seat)
    right <- grepl("right", seat)
    other <- grepl("other", seat)
  }

  injury <- switch(tolower(injury),
    "unknown" = 9,
    "not reported" = 9,
    "died prior" = 6,
    "injured" = 5,
    "fatal" = 4,
    "suspected serious" = 3,
    "suspected minor" = 2,
    "possible" = 1,
    "no apparent" = 0
  )

  sex <- switch(tolower(sex),
    "m" = 1,
    "male" = 1,
    "f" = 2,
    "female" = 2,
    "not reported" = 8,
    "unknown" = 9
  )

  stopifnot(
    is.numeric(age),
    is.numeric(sex),
    is.numeric(seat),
    is.numeric(injury)
  )

  read_crashapi(
    data = "crashes",
    type = "GetCrashesByPerson",
    age = as.integer(age),
    sex = sex,
    seatPos = as.integer(seat),
    injurySeverity = as.integer(injury),
    fromCaseYear = min(year),
    toCaseYear = max(year),
    state = lookup_fips(state),
    includeOccupants = tolower(occupants),
    includeNonOccupants = tolower(nonoccupants),
    format = "json"
  )
}
