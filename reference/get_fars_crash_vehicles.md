# Get Crashes By Vehicle

This function returns a list of fatal crashes by vehicle type that have
occurred throughout United States. The make, model, and body type must
match the options returned by `fars_vars`. This function accepts named
options that are converted to ID numbers for use in the API query.

## Usage

``` r
get_fars_crash_vehicles(
  year = NULL,
  start_year,
  end_year = NULL,
  state,
  make = NULL,
  model = NULL,
  model_year = 2010,
  body_type = NULL
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

- make:

  Make name or ID, Required. The start_year is used to return a list of
  support make options. Default: `NULL`

- model:

  Model name or ID, Optional. Default: `NULL`

- model_year:

  Model year, Optional. Default: `NULL`

- body_type:

  Body type, Optional. `model` must be provided to use body_type
  parameter. Default: `NULL`
