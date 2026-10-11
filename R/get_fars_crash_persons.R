#' Get Crashes By Occupant
#'
#' This function returns a list of people involved in fatal crashes that match
#' a specific age, sex, seat position, and injury severity using the CrashAPI
#' GetCrashesByPerson endpoint. The returned data has one row for each person.
#'
#' # API behavior
#'
#' NHTSA's documentation says this endpoint accepts "one or more" occupant
#' details for age, sex, seat position, and injury severity. However, testing in
#' October 2026 found that the API does not behave this way: the API returns an
#' error (HTTP 404) unless all four are provided, an error message if any are
#' blank, and only returns people who match all four values exactly. For this
#' reason, `age`, `sex`, `seat`, and `injury` are all required.
#'
#' The endpoint's `includeOccupants` and `includeNonOccupants` parameters are
#' not supported since the required seat position already determines whether
#' occupants or non-occupants are returned (use `seat = 0` for people who were
#' not motor vehicle occupants).
#'
#' To find people using other criteria (e.g. a range of ages or any injury
#' severity), download the person table with [get_fars_year()] using `type =
#' "person"` and filter the data.
#'
#' @rdname get_fars_crash_persons
#' @inheritParams get_fars
#' @param year numeric vector. One or more years from 2010 to 2024. The minimum
#'   and maximum values are used as the start and end year. Defaults to
#'   `getOption("crashapi.year", 2024)`.
#' @param state Required. State name, abbreviation, or FIPS number.
#' @param age Required. Age in years.
#' @param sex Required. Code or name for the person's sex: 1 ("Male"), 2
#'   ("Female"), 8 ("Not Reported"), or 9 ("Reported as Unknown"). "m", "f",
#'   and "unknown" are also accepted.
#' @param seat Required. Code or name for the person's seat position, e.g. 11
#'   or "Front Seat, Left Side" ("front left" is also accepted). Use 0 or "Not
#'   a Motor Vehicle Occupant" for non-occupants. See the FARS Analytical
#'   User's Manual for all seat position codes.
#' @param injury Required. Code or name for the person's injury severity: 0
#'   ("No Apparent Injury (O)"), 1 ("Possible Injury (C)"), 2 ("Suspected
#'   Minor Injury (B)"), 3 ("Suspected Serious Injury (A)"), 4 ("Fatal Injury
#'   (K)"), 5 ("Injured, Severity Unknown"), 6 ("Died Prior to Crash"), or 9
#'   ("Unknown/Not Reported"). Short names (e.g. "fatal") and KABCO letters
#'   (e.g. "K") are also accepted.
#' @examples
#' # Fatally injured 30 year old female drivers in Maryland in 2022
#' get_fars_crash_persons(
#'   state = "MD",
#'   age = 30,
#'   sex = "female",
#'   seat = "front left",
#'   injury = "fatal",
#'   year = 2022
#' )
#' @export
get_fars_crash_persons <- function(
  state,
  age,
  sex,
  seat,
  injury,
  year = getOption("crashapi.year", 2024),
  labels = TRUE
) {
  rlang::check_required(age)
  rlang::check_required(sex)
  rlang::check_required(seat)
  rlang::check_required(injury)

  year <- year_span(validate_year(year))

  age_code <- suppressWarnings(as.integer(age))

  if (length(age) != 1 || is.na(age_code)) {
    cli_abort("{.arg age} must be a single number.")
  }

  crash_df <- read_crashapi(
    data = "crashes",
    type = "GetCrashesByPerson",
    age = age_code,
    sex = fars_person_code(sex, "sex"),
    seatPos = fars_person_code(seat, "seat"),
    injurySeverity = fars_person_code(injury, "injury"),
    fromCaseYear = year[[1]],
    toCaseYear = year[[2]],
    state = lookup_fips(state),
    format = "json"
  )

  if (!isTRUE(labels) || rlang::is_empty(crash_df)) {
    return(crash_df)
  }

  label_fars_vars(crash_df, data_file = "PERSON")
}
