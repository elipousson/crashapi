# Get Crashes By Vehicle

This function returns a list of fatal crashes by vehicle type that have
occurred throughout United States. The make, model, and body type must
match the options returned by `fars_vars`. This function accepts named
options that are converted to ID numbers for use in the API query.

## Usage

``` r
get_fars_crash_vehicles(
  state,
  year = getOption("crashapi.year", 2024),
  make = NULL,
  model = NULL,
  model_year = 2010,
  body_type = NULL,
  labels = TRUE
)
```

## Arguments

- state:

  Required. State name, abbreviation, or FIPS number.

- year:

  numeric vector. One or more years from 2010 to 2024. The minimum and
  maximum values are used as the start and end year. Defaults to
  `getOption("crashapi.year", 2024)`.

- make:

  Make name or ID, Required. The earliest year in `year` is used to
  return a list of support make options. Default: `NULL`

- model:

  Model name or ID, Optional. Default: `NULL`

- model_year:

  Model year, Optional. Default: `NULL`

- body_type:

  Body type, Optional. `model` must be provided to use body_type
  parameter. Default: `NULL`

- labels:

  If `TRUE` (default), add a `"label"` attribute to each column with a
  variable label from
  [fars_vars_labels](https://elipousson.github.io/crashapi/reference/fars_vars_labels.md).
  Labels are shown by [`View()`](https://rdrr.io/r/utils/View.html) in
  RStudio and Positron and used by packages such as gt and gtsummary.
