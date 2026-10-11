# Get Crashes By Occupant

This function returns a list of fatal crashes by occupant that have
occurred throughout United States. This function is not currently
working.

## Usage

``` r
get_fars_crash_persons(
  state,
  seat,
  injury,
  year = getOption("crashapi.year", 2024),
  age = NULL,
  sex = NULL,
  occupants = TRUE,
  nonoccupants = TRUE,
  labels = TRUE
)
```

## Arguments

- state:

  Required. State name, abbreviation, or FIPS number.

- seat:

  Seat position

- injury:

  Options "unknown", "not reported", "died prior", "injured", "fatal",
  "suspected serious", "suspected minor", "possible", "no apparent"

- year:

  numeric vector. One or more years from 2010 to 2024. The minimum and
  maximum values are used as the start and end year. Defaults to
  `getOption("crashapi.year", 2024)`.

- age:

  numeric

- sex:

  Options "m", "f", "male", "female", "unknown", "not reported."

- occupants:

  Include vehicle occupants in query; defaults to `TRUE`

- nonoccupants:

  Include non-occupants in query; defaults to `TRUE`

- labels:

  If `TRUE` (default), add a `"label"` attribute to each column with a
  variable label from
  [fars_vars_labels](https://elipousson.github.io/crashapi/reference/fars_vars_labels.md).
  Labels are shown by [`View()`](https://rdrr.io/r/utils/View.html) in
  RStudio and Positron and used by packages such as gt and gtsummary.
