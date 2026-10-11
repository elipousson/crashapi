# Changelog

## crashapi (development version)

- crashapi now requires R 4.1.0 or later, matching its dependencies and
  its use of the native pipe.
- Fix package to use the current CrashAPI base URL and browser headers
  (broken since January 2025).
- Breaking change: required arguments now come before `year` in
  [`get_fars()`](https://elipousson.github.io/crashapi/reference/get_fars.md)
  (`state`),
  [`get_fars_crashes()`](https://elipousson.github.io/crashapi/reference/get_fars.md)
  (`state`, `county`),
  [`get_fars_cases()`](https://elipousson.github.io/crashapi/reference/get_fars.md)
  (`state`, `cases`),
  [`get_fars_crash_list()`](https://elipousson.github.io/crashapi/reference/get_fars.md),
  [`get_fars_summary()`](https://elipousson.github.io/crashapi/reference/get_fars.md),
  [`get_fars_year()`](https://elipousson.github.io/crashapi/reference/get_fars.md),
  [`get_fars_crash_vehicles()`](https://elipousson.github.io/crashapi/reference/get_fars_crash_vehicles.md)
  (`state`), and
  [`get_fars_crash_persons()`](https://elipousson.github.io/crashapi/reference/get_fars_crash_persons.md)
  (`state`, `seat`, `injury`). Calls that pass `year` by position need
  to name it.
- Data from 2024 (released in April 2026) is now supported and the
  default `year` for all functions is
  `getOption("crashapi.year", 2024)`. Use
  `options(crashapi.year = 2022)` to set a different default year for
  the session.
- Breaking change: the `start_year` and `end_year` arguments are
  removed. Functions for API endpoints that take a range of years
  ([`get_fars_crashes()`](https://elipousson.github.io/crashapi/reference/get_fars.md),
  [`get_fars_crash_list()`](https://elipousson.github.io/crashapi/reference/get_fars.md),
  [`get_fars_summary()`](https://elipousson.github.io/crashapi/reference/get_fars.md),
  [`get_fars_year()`](https://elipousson.github.io/crashapi/reference/get_fars.md),
  [`get_fars_crash_vehicles()`](https://elipousson.github.io/crashapi/reference/get_fars_crash_vehicles.md),
  and
  [`get_fars_crash_persons()`](https://elipousson.github.io/crashapi/reference/get_fars_crash_persons.md))
  now use the minimum and maximum of `year` as the start and end year,
  with a message if `year` has gaps.
- [`fars_vars()`](https://elipousson.github.io/crashapi/reference/fars_vars.md)
  supports multiple years and returns a `year` column.
- [`get_fars_cases()`](https://elipousson.github.io/crashapi/reference/get_fars.md)
  supports one year for each case number, and
  `get_fars_crashes(details = TRUE)` now works for multiple years by
  using the case year for each crash.
- [`get_fars_zip()`](https://elipousson.github.io/crashapi/reference/get_fars_zip.md)
  and
  [`get_crss_zip()`](https://elipousson.github.io/crashapi/reference/get_crss_zip.md)
  support multiple years and return a list (or vector of file paths)
  named by year.
- [`format_crashes()`](https://elipousson.github.io/crashapi/reference/format_crashes.md),
  [`get_crss_zip()`](https://elipousson.github.io/crashapi/reference/get_crss_zip.md),
  [`get_fars()`](https://elipousson.github.io/crashapi/reference/get_fars.md),
  [`get_fars_cases()`](https://elipousson.github.io/crashapi/reference/get_fars.md),
  [`get_fars_crash_list()`](https://elipousson.github.io/crashapi/reference/get_fars.md),
  [`get_fars_crash_persons()`](https://elipousson.github.io/crashapi/reference/get_fars_crash_persons.md),
  [`get_fars_crash_vehicles()`](https://elipousson.github.io/crashapi/reference/get_fars_crash_vehicles.md),
  [`get_fars_crashes()`](https://elipousson.github.io/crashapi/reference/get_fars.md),
  [`get_fars_summary()`](https://elipousson.github.io/crashapi/reference/get_fars.md),
  [`get_fars_year()`](https://elipousson.github.io/crashapi/reference/get_fars.md),
  and
  [`get_fars_zip()`](https://elipousson.github.io/crashapi/reference/get_fars_zip.md)
  gain a `labels` argument. When `TRUE` (the default), each column with
  a matching variable in `fars_vars_labels` gets a `"label"` attribute,
  which is shown by [`View()`](https://rdrr.io/r/utils/View.html) and
  used by packages such as gt and gtsummary. Where a variable appears in
  more than one FARS data file, the label for the table being read is
  used.
- Variable labels now prefer labels for current variables over
  discontinued ones, match names case-insensitively when there is no
  exact match (e.g. `CASEYEAR`), label `…NAME` columns from their coded
  variable (e.g. `BODY_TYPNAME` from `BODY_TYP`), and label nested data
  frames in list columns returned by
  [`get_fars_cases()`](https://elipousson.github.io/crashapi/reference/get_fars.md).
- [`format_crashes()`](https://elipousson.github.io/crashapi/reference/format_crashes.md)
  now reorders columns, converts coordinate and count columns, and
  appends `date`, `time`, and `datetime` columns as documented.
  Previously, a faulty check skipped this step, so
  [`get_fars_crashes()`](https://elipousson.github.io/crashapi/reference/get_fars.md),
  [`get_fars_crash_list()`](https://elipousson.github.io/crashapi/reference/get_fars.md),
  and
  [`get_fars_summary()`](https://elipousson.github.io/crashapi/reference/get_fars.md)
  returned unformatted data. Column names are kept as returned by the
  API, and columns not found in `fars_vars_labels` are kept at the end.
- [`get_fars()`](https://elipousson.github.io/crashapi/reference/get_fars.md)
  now works with `api = "zip"` when `format` is left at its default
  (“json” is treated as “csv”).
- [`get_fars_year()`](https://elipousson.github.io/crashapi/reference/get_fars.md)
  now supports the “RACE” (2019 onwards) and “TRAILERVINDERIVED” (2016
  onwards) tables.
- [`get_fars_year()`](https://elipousson.github.io/crashapi/reference/get_fars.md)
  now sends the same browser headers as other API requests when reading
  CSV data or downloading a file (`download = TRUE`), and returns the
  downloaded file path invisibly.
- [`get_fars_year()`](https://elipousson.github.io/crashapi/reference/get_fars.md)
  returns the data with a warning when `geometry = TRUE` and the table
  has no coordinate columns, instead of downloading a file.

## crashapi 0.1.2

- Update year range to cover 2022 data.

## crashapi 0.1.1.9

- Update year range to cover 2021 data.
- Add
  [`get_crss_zip()`](https://elipousson.github.io/crashapi/reference/get_crss_zip.md)
  function

## crashapi 0.1.1

CrashAPI now has data from 2010 to 2020.
[`get_fars_year()`](https://elipousson.github.io/crashapi/reference/get_fars.md)
is also updated to support multiple years and to include a state
parameter which makes it much easier to use.

- refactor: update 2019 -\> 2020 max year
- feat: add geometry and state parameter support to
  [`get_fars_year()`](https://elipousson.github.io/crashapi/reference/get_fars.md)
- refactor: set default crs to NULL and switch to use `sfext::df_to_sf`
- refactor: switch to use `httr2` package +
  [`read_crashapi()`](https://elipousson.github.io/crashapi/reference/read_crashapi.md)
  for data access (except for zip)
- test: add tests and set up code coverage tests

## crashapi 0.1.0.12

- feat: Add
  [`get_fars_crash_persons()`](https://elipousson.github.io/crashapi/reference/get_fars_crash_persons.md)
  function
- refactor: Rename `tidy_crashes()` to
  [`format_crashes()`](https://elipousson.github.io/crashapi/reference/format_crashes.md)
- feat: rename
  [`get_fars_crash_details()`](https://elipousson.github.io/crashapi/reference/get_fars.md)
  to
  [`get_fars_cases()`](https://elipousson.github.io/crashapi/reference/get_fars.md)
- feat: Add details parameter to
  [`get_fars_crashes()`](https://elipousson.github.io/crashapi/reference/get_fars.md)
  to supported appending detailed case information
- feat: Add `fars_vars_labels` with names and labels derived from
  current analytical manual

## crashapi 0.1.0.11

- feat: add
  [`get_fars()`](https://elipousson.github.io/crashapi/reference/get_fars.md)
  function that uses an api parameter to call different APIs
- feat: import helper functions from {tigris} package to improve renamed
  `lookup_fips()` function
- feat: Add `get_fars_crash_vehicles` to support downloading crash data
  by vehicle make, model, and/or body type
- fix: `get_fars_year` was not using the correct query URL if download =
  TRUE
- refactor: relocate helper functions to utils.R
- refactor: rename `make_query()` helper function to `read_api()`
- refactor: update `validate_year()` helper function to work with
  {checkmate} package
- refactor: update default values for year, start_year, end_year and
  other parameters
- docs: Update README and pkgdown site

## crashapi 0.1.0.10

- feat: `get_fars_zip` added to provide alternate (non-API) method for
  downloading zipped CSV or SAS data files
- fix: `get_fars_crash_details` updated to return data frame w/o list
  columns
- feat: `get_fars_crash_details` updated to optionally return vehicle or
  crash events data frames

## crashapi 0.1.0.9

- docs: Revise README and update pkgdown site
- fix: Add missing imports to `DESCRIPTION`
- fix: Update `county_to_fips()` to support partial county names,
  e.g. “Adams” instead of “Adams County” and avoiding matching multiple
  counties (closes
  [\#1](https://github.com/elipousson/crashapi/issues/1))
- feat: Update
  [`get_fars_crash_details()`](https://elipousson.github.io/crashapi/reference/get_fars.md)
  to return sf objects using geometry parameter
- refactor: Set up API calls w/ unexported utility function
  (`make_query`)

## crashapi 0.1.0

- Added functions for accessing FARS APIs including Get Crash List
  Information, Get Crash Details, Get Crashes By Location, Get Summary
  Counts, and Get FARS Data By Year (documented in
  [`get_fars()`](https://elipousson.github.io/crashapi/reference/get_fars.md))
- Added functions for accessing FARS APIs including Get Variables and
  Get Variable Attributes (documented in `get_fars_vars()`)
- Added `fars_terms` data with terms and definitions from National
  Highway Traffic Safety Administration (NHTSA) website
- Added a `NEWS.md` file to track changes to the package.
- Set up a pkgdown website
