# Get Crashes By Occupant

This function returns a list of fatal crashes by occupant that have
occurred throughout United States. This function is not currently
working.

## Usage

``` r
get_fars_crash_persons(
  year = NULL,
  start_year,
  end_year = NULL,
  state,
  age = NULL,
  sex = NULL,
  seat,
  injury,
  occupants = TRUE,
  nonoccupants = TRUE
)
```

## Arguments

- year:

  numeric vector. Year or range with start and end year. 2010 to 2022
  supported.

- start_year:

  Start year for crash reports.

- end_year:

  End year for crash reports.

- state:

  Required. State name, abbreviation, or FIPS number.

- age:

  numeric

- sex:

  Options "m", "f", "male", "female", "unknown", "not reported."

- seat:

  Seat position

- injury:

  Options "unknown", "not reported", "died prior", "injured", "fatal",
  "suspected serious", "suspected minor", "possible", "no apparent"

- occupants:

  Include vehicle occupants in query; defaults to `TRUE`

- nonoccupants:

  Include non-occupants in query; defaults to `TRUE`
