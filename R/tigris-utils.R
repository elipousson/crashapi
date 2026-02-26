# Import unexported functions from tigris to support lookup_fips utility function
# https://github.com/walkerke/tigris/blob/acbd0cf29f86aa90ab1ee339905f3fd6f26c1ed6/R/utils.R

# These functions use a compatable MIT license and have been cited as consistent
# with the guidelines here: https://r-pkgs.org/license.html#how-to-include
# via: http://www.epa.gov/envirofw/html/codes/state.html
#
# this somewhat duplicates "state_codes" but it's primarily intended
# to validate_state. A TODO might be to refactor the code to eliminate this
# but put "state_codes" to all lowercase for utility functions and then
# use string transformations when presenting messages to the user

fips_state_table <- structure(
  list(
    abb = c(
      "ak",
      "al",
      "ar",
      "as",
      "az",
      "ca",
      "co",
      "ct",
      "dc",
      "de",
      "fl",
      "ga",
      "gu",
      "hi",
      "ia",
      "id",
      "il",
      "in",
      "ks",
      "ky",
      "la",
      "ma",
      "md",
      "me",
      "mi",
      "mn",
      "mo",
      "ms",
      "mt",
      "nc",
      "nd",
      "ne",
      "nh",
      "nj",
      "nm",
      "nv",
      "ny",
      "oh",
      "ok",
      "or",
      "pa",
      "pr",
      "ri",
      "sc",
      "sd",
      "tn",
      "tx",
      "ut",
      "va",
      "vi",
      "vt",
      "wa",
      "wi",
      "wv",
      "wy",
      "mp"
    ),
    fips = c(
      "02",
      "01",
      "05",
      "60",
      "04",
      "06",
      "08",
      "09",
      "11",
      "10",
      "12",
      "13",
      "66",
      "15",
      "19",
      "16",
      "17",
      "18",
      "20",
      "21",
      "22",
      "25",
      "24",
      "23",
      "26",
      "27",
      "29",
      "28",
      "30",
      "37",
      "38",
      "31",
      "33",
      "34",
      "35",
      "32",
      "36",
      "39",
      "40",
      "41",
      "42",
      "72",
      "44",
      "45",
      "46",
      "47",
      "48",
      "49",
      "51",
      "78",
      "50",
      "53",
      "55",
      "54",
      "56",
      "69"
    ),
    name = c(
      "alaska",
      "alabama",
      "arkansas",
      "american samoa",
      "arizona",
      "california",
      "colorado",
      "connecticut",
      "district of columbia",
      "delaware",
      "florida",
      "georgia",
      "guam",
      "hawaii",
      "iowa",
      "idaho",
      "illinois",
      "indiana",
      "kansas",
      "kentucky",
      "louisiana",
      "massachusetts",
      "maryland",
      "maine",
      "michigan",
      "minnesota",
      "missouri",
      "mississippi",
      "montana",
      "north carolina",
      "north dakota",
      "nebraska",
      "new hampshire",
      "new jersey",
      "new mexico",
      "nevada",
      "new york",
      "ohio",
      "oklahoma",
      "oregon",
      "pennsylvania",
      "puerto rico",
      "rhode island",
      "south carolina",
      "south dakota",
      "tennessee",
      "texas",
      "utah",
      "virginia",
      "virgin islands",
      "vermont",
      "washington",
      "wisconsin",
      "west virginia",
      "wyoming",
      "northern mariana islands"
    )
  ),
  .Names = c("abb", "fips", "name"),
  row.names = c(NA, -56L),
  class = "data.frame"
)

# Called to check to see if "state" is a FIPS code, full name or abbreviation.
#
# returns `NULL` if input is `NULL`
# returns valid state FIPS code if input is even pseud-valid (i.e. single digit
# but w/in range)
# returns `NULL` if input is not a valid FIPS code
#' @noRd
#' @importFrom stringr str_trim
validate_state <- function(state, .msg = interactive()) {
  if (is.null(state)) {
    return(NULL)
  }

  state <- tolower(stringr::str_trim(state)) # forgive white space

  if (grepl("^[[:digit:]]+$", state)) {
    # we prbly have FIPS

    state <- sprintf("%02d", as.numeric(state)) # forgive 1-digit FIPS codes

    if (state %in% fips_state_table$fips) {
      return(state)
    } else {
      # perhaps they passed in a county FIPS by accident so forgive that, too,
      # but warn the caller
      state_sub <- substr(state, 1, 2)
      if (state_sub %in% fips_state_table$fips) {
        message(
          sprintf(
            "Using first two digits of %s - '%s' (%s) - for FIPS code.",
            state,
            state_sub,
            fips_state_table[fips_state_table$fips == state_sub, "name"]
          ),
          call. = FALSE
        )
        return(state_sub)
      } else {
        cli::cli_warn(
          "{.arg state} ({.val state}) is not a valid FIPS code or
        state name/abbreviation."
        )
        return(invisible(NULL))
      }
    }
  } else if (grepl("^[[:alpha:]]+", state)) {
    # we might have state abbrev or name

    if (nchar(state) == 2 & state %in% fips_state_table$abb) {
      # yay, an abbrev!

      if (.msg) {
        message(sprintf(
          "Using FIPS code '%s' for state '%s'",
          fips_state_table[fips_state_table$abb == state, "fips"],
          toupper(state)
        ))
      }
      return(fips_state_table[fips_state_table$abb == state, "fips"])
    } else if (nchar(state) > 2 & state %in% fips_state_table$name) {
      # yay, a name!

      if (.msg) {
        message(sprintf(
          "Using FIPS code '%s' for state '%s'",
          fips_state_table[fips_state_table$name == state, "fips"],
          simpleCapSO(state)
        ))
      }
      return(fips_state_table[fips_state_table$name == state, "fips"])
    } else {
      cli::cli_warn(
        "{.arg state} ({.val state}) is not a valid FIPS code or
        state name/abbreviation."
      )
      return(NULL)
    }
  } else {
    cli::cli_warn(
      "{.arg state} ({.val state}) is not a valid FIPS code or
        state name/abbreviation."
    )
    return(NULL)
  }
}

# Some work on a validate_county function
#
#
validate_county <- function(state, county, .msg = interactive()) {
  if (is.null(state)) {
    return(NULL)
  }

  if (is.null(county)) {
    return(NULL)
  }

  # Get the state of the county
  state <- validate_state(state, .msg = .msg)

  # Get a df for the requested state to work with
  county_table <- fips_codes[fips_codes$state_code == state, ]
  if (grepl("^[[:digit:]]+$", county)) {
    # if probably a FIPS code

    # in case they passed in 1 or 2 digit county codes
    county <- sprintf("%03d", as.numeric(county))

    if (county %in% county_table$county_code) {
      return(county)
    } else {
      warning(
        sprintf(
          "'%s' is not a valid FIPS code for counties in %s",
          county,
          county_table$state_name[1]
        ),
        call. = FALSE
      )
      return(NULL)
    }
  } else if ((grepl("^[[:alpha:]]+", county))) {
    # should be a county name

    county_index <- grepl(
      sprintf("^%s", county),
      county_table$county,
      ignore.case = TRUE
    )

    matching_counties <- county_table$county[county_index] # Get the counties that match

    if (length(matching_counties) == 0) {
      warning(
        sprintf(
          "'%s' is not a valid name for counties in %s",
          county,
          county_table$state_name[1]
        ),
        call. = FALSE
      )
      return(NULL)
    } else if (length(matching_counties) == 1) {
      if (.msg) {
        message(sprintf(
          "Using FIPS code '%s' for '%s'",
          county_table[county_table$county == matching_counties, "county_code"],
          matching_counties
        ))
      }

      return(
        county_table[county_table$county == matching_counties, "county_code"]
      )
    } else if (length(matching_counties) > 1) {
      ctys <- format_vec(matching_counties)

      warning(
        paste0(
          "Your county string matches ",
          ctys,
          " Please refine your selection."
        ),
        call. = FALSE
      )
      return(NULL)
    }
  }
}


# Quick function to return formatted string for county codes

format_vec <- function(vec) {
  out <- paste0(vec, ", ")

  l <- length(out)

  out[l - 1] <- paste0(out[l - 1], "and ")

  out[l] <- gsub(", ", ".", out[l])

  return(paste0(out, collapse = ""))
}

# Function from SO to do proper capitalization

simpleCapSO <- function(x) {
  s <- strsplit(x, " ")[[1]]
  paste(toupper(substring(s, 1, 1)), substring(s, 2), sep = "", collapse = " ")
}
