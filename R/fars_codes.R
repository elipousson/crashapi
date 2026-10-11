# Attribute codes and names for person variables used by the CrashAPI
# GetCrashesByPerson endpoint. Names match the SEXNAME, INJ_SEVNAME, and
# SEAT_POSNAME values returned by the CrashAPI for 2022 and 2024 data. INJ_SEV 6
# (Died Prior to Crash) is from the FARS Analytical User's Manual.
fars_person_codes <- list(
  sex = c(
    "Male" = 1,
    "Female" = 2,
    "Not Reported" = 8,
    "Reported as Unknown" = 9
  ),
  injury = c(
    "No Apparent Injury (O)" = 0,
    "Possible Injury (C)" = 1,
    "Suspected Minor Injury (B)" = 2,
    "Suspected Serious Injury (A)" = 3,
    "Fatal Injury (K)" = 4,
    "Injured, Severity Unknown" = 5,
    "Died Prior to Crash" = 6,
    "Unknown/Not Reported" = 9
  ),
  seat = c(
    "Not a Motor Vehicle Occupant" = 0,
    "Front Seat, Left Side" = 11,
    "Front Seat, Middle" = 12,
    "Front Seat, Right Side" = 13,
    "Front Seat, Other" = 18,
    "Front Seat, Unknown" = 19,
    "Second Seat, Left Side" = 21,
    "Second Seat, Middle" = 22,
    "Second Seat, Right Side" = 23,
    "Second Seat, Other" = 28,
    "Second Seat, Unknown" = 29,
    "Third Seat, Left Side" = 31,
    "Third Seat, Middle" = 32,
    "Third Seat, Right Side" = 33,
    "Third Seat, Other" = 38,
    "Third Seat, Unknown" = 39,
    "Sleeper Section of Cab (Truck)" = 50,
    "Other Passenger in enclosed passenger or cargo area" = 51,
    "Other Passenger in unenclosed passenger or cargo area" = 52,
    "Other Passenger in passenger or cargo area, unknown whether or not enclosed" = 53,
    "Trailing Unit" = 54,
    "Riding on Exterior of Vehicle" = 55,
    "Appended to a Motor Vehicle for Motion" = 56,
    "Not Reported" = 98,
    "Reported as Unknown" = 99
  )
)

# Short names accepted in addition to the attribute names
fars_person_aliases <- list(
  sex = c("m" = 1, "f" = 2, "unknown" = 9),
  injury = c(
    "o" = 0,
    "no apparent" = 0,
    "c" = 1,
    "possible" = 1,
    "b" = 2,
    "suspected minor" = 2,
    "a" = 3,
    "suspected serious" = 3,
    "k" = 4,
    "fatal" = 4,
    "injured" = 5,
    "died prior" = 6,
    "unknown" = 9,
    "not reported" = 9
  ),
  seat = c("non-occupant" = 0, "unknown" = 99)
)

# Normalize attribute names for matching, e.g. "Front Seat, Left Side" becomes
# "front left" and "Fatal Injury (K)" becomes "fatal injury k"
normalize_code_name <- function(x) {
  x <- tolower(x)
  x <- gsub("[^a-z0-9 -]", " ", x)
  x <- gsub("\\b(seat|side)\\b", " ", x)
  trimws(gsub(" +", " ", x))
}

#' Convert a person attribute name or code to a single numeric code
#' @noRd
fars_person_code <- function(
  x,
  type = c("sex", "injury", "seat"),
  arg = rlang::caller_arg(x),
  call = caller_env()
) {
  type <- match.arg(type)

  if (length(x) != 1 || is.na(x)) {
    cli_abort("{.arg {arg}} must be a single value.", call = call)
  }

  code <- suppressWarnings(as.integer(x))

  if (!is.na(code)) {
    return(code)
  }

  codes <- fars_person_codes[[type]]
  lookup <- c(
    rlang::set_names(codes, normalize_code_name(names(codes))),
    fars_person_aliases[[type]]
  )

  code <- lookup[normalize_code_name(x)]

  if (is.na(code)) {
    cli_abort(
      c(
        "{.arg {arg}} must be a numeric code or one of {.val {names(codes)}}.",
        "x" = "{.val {x}} is not a valid value."
      ),
      call = call
    )
  }

  unname(code)
}

#' Convert a vehicle attribute name or ID to an ID using fars_vars() options
#' @noRd
match_fars_option <- function(
  x,
  options,
  id_col,
  name_col,
  arg = rlang::caller_arg(x),
  call = caller_env()
) {
  if (length(x) != 1 || is.na(x)) {
    cli_abort("{.arg {arg}} must be a single value.", call = call)
  }

  ids <- as.character(options[[id_col]])

  if (as.character(x) %in% ids) {
    return(as.character(x))
  }

  i <- match(tolower(x), tolower(options[[name_col]]))

  if (is.na(i)) {
    cli_abort(
      c(
        "{.arg {arg}} must be a valid name or ID.",
        "x" = "{.val {x}} can't be found.",
        "i" = "Use {.fn fars_vars} to list valid options."
      ),
      call = call
    )
  }

  ids[[i]]
}
