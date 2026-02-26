# Get Fatality Analysis Reporting System (FARS) data with the FARS API

This function provides a convenient interface for accessing FARS data or
data summaries using a range of criteria. The `api` parameter allows you
to call one of the following functions to access DOT NHTSA’s Crash API:

- `get_fars_crash_list` returns a list of fatal crashes that have
  occurred in multiple states in one or more years.

- `get_fars_crash_details` returns a details of a fatal crash that has
  occurred in a state for a single year.

- `get_fars_crashes` a list of fatal crashes by location that have
  occurred throughout U.S.

- `get_fars_summary` provides a count of injury severity that have
  occurred throughout U.S. including count of fatalities and crashes.

- `get_fars_year` provides one of 20 FARS data tables for a single year.
  Supports downloading to a CSV or JSON file.

Both `get_fars_crash_list` and `get_fars_crashes` limit the returned
data to 5000 records so consider limiting the range of years requested
if data exceeds that threshold.

This package also enables access to the FARS data available through the
NHTSA data downloads server in a zip format. Set `api` to "zip" or use
the `get_fars_zip` function to download this data.

## Usage

``` r
get_fars(
  year = 2024,
  state,
  county = NULL,
  api = c("crashes", "cases", "state list", "summary count", "year dataset", "zip"),
  type = NULL,
  details = FALSE,
  geometry = FALSE,
  crs = NULL,
  cases = NULL,
  vehicles = NULL,
  format = "json",
  pr = FALSE,
  path = NULL,
  download = FALSE
)

get_fars_crashes(
  year = 2024,
  start_year,
  end_year = NULL,
  state,
  county,
  details = FALSE,
  geometry = FALSE,
  crs = NULL
)

get_fars_cases(
  year = 2024,
  state,
  cases,
  details = FALSE,
  geometry = FALSE,
  crs = NULL
)

get_fars_crash_list(
  year = 2024,
  start_year = NULL,
  end_year = NULL,
  state,
  vehicles = c(1, 50)
)

get_fars_summary(year = 2024, start_year, end_year = NULL, state)

get_fars_year(
  year = 2024,
  type = "accident",
  state,
  format = "json",
  path = NULL,
  geometry = FALSE,
  crs = NULL,
  download = FALSE,
  call = caller_env()
)
```

## Arguments

- year:

  numeric vector. Year or range with start and end year. If `api` is
  "details", "year dataset", or "zip" (or using the
  `get_fars_crash_details`, `get_fars_year`, or `get_fars_zip`
  functions), a single year is required. All other `api` options support
  a range with the minimum value is used as a start year and the maximum
  value used as a end year. Most `api` options support the years from
  2010 through the most recent year of release. "year dataset" only
  supports 2010 to 2017 and "zip" supports 1975 to 2023. `start_year`
  and `end_year` are ignored if `year` is not `NULL`.

- state:

  Required. State name, abbreviation, or FIPS number.
  `get_fars_crash_list` supports multiple states.

- county:

  County name or FIPS number. Required for `get_fars_crashes`.

- api:

  character. API function to use. Supported values include "crashes",
  "cases", "state list", "summary count", "year dataset", and "zip".
  Default: "crashes".

- type:

  Name of the dataset or data file to download when using the "year
  dataset" api or `get_fars_year`. Supported values include "ACCIDENT",
  "CEVENT", "DAMAGE", "DISTRACT", "DRIMPAIR", "FACTOR", "MANEUVER",
  "NMCRASH", "NMIMPAIR", "NMPRIOR", "PARKWORK", "PBTYPE", "PERSON",
  "SAFETYEQ", "VEHICLE", "VEVENT VINDECODE", "VINDERIVED", "VIOLATION",
  "VISION", and "VSOE". Lowercase or mixed case values are permitted.

- details:

  Type of detailed crash data to return (either "events" or "vehicles").
  If `TRUE` for `get_fars` or `get_fars_crashes`, detailed case data
  (excluding event and vehicle data) is attached to the returned crash
  data. If `NULL` for `get_fars_cases`, events and vehicle data are
  excluded from the returned case data. returned by `get_fars_cases`.
  Optional for `get_fars_crash_details`. Default: `NULL` for
  `get_fars_cases`; `FALSE` for `get_fars` and `get_fars_crashes`.

- geometry:

  If `TRUE`, return sf object. Optional for `get_fars_crashes`.

- crs:

  Coordinate reference system to return for `get_fars_crashes` if
  `geometry` is `TRUE`.

- cases:

  One or more FARS case numbers. Required if `api` is "cases" or using
  `get_fars_cases`. Multiple case numbers can be provided.

- vehicles:

  numeric vector with the minimum and maximum number of vehicles, e.g.
  c(1, 2) for minimum of 1 vehicle and maximum of 2. Required for
  `get_fars_crash_list`.

- format:

  Default "json". "csv" is supported when using the "year dataset" api.
  "sas" is supporting for the "zip" api.

- pr:

  logical. If `TRUE`, download zip file with FARS data for Puerto Rico.
  No Puerto Rico data available for years 1975-1977. Default: `FALSE`
  for `get_fars_zip` only.

- path:

  File path used if download is `TRUE`.

- download:

  logical. If `TRUE` and the `api` is "year dataset" or "zip", download
  the data to a file. Default `FALSE`.

- start_year:

  Start year for crash reports.

- end_year:

  End year for crash reports.

## Examples

``` r
head(get_fars_crashes(state = "MD", county = "Baltimore city"), 5)
#> ! No data found
#> • Adjust search criteria and try again: FromYear: 2024 | ToYear: 2024 | State:
#>   24 | County: 510
#> Warning: No records found with the provided parameters.
#> NULL

get_fars_cases(state = "MD", cases = "240274")
#> ! Object reference not set to an instance of an object.
#> • Adjust search criteria and try again: StateCase: 240274 And CaseYear: 2024
#>   And State: 24
#> Error in data[["Results"]][[1]]: subscript out of bounds

get_fars_crash_list(state = "MD", vehicles = 5)
#> ! No data found
#> • Adjust search criteria and try again: State(s): 24 | FromYear: 2024 | ToYear:
#>   2024 | MinNumOfVehicles: 5 | MaxNumOfVehicles: 5
#> NULL

get_fars_summary(state = "MD")
#> ! No data found
#> • Adjust search criteria and try again: FromYear: 2024 | ToYear: 2024 | State:
#>   24
#> Error in UseMethod("mutate"): no applicable method for 'mutate' applied to an object of class "list"

head(get_fars_year(state = "MD", type = "PERSON"), 5)
#> list()
```
