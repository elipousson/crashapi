# Changelog

## crashapi (development version)

- New
  [`fars_value_labels()`](https://elipousson.github.io/crashapi/reference/fars_value_labels.md)
  returns value labels (the decoded value for each code) for FARS
  (1975-2024) and CRSS (2016-2024) variables by year, built from the SAS
  format files NHTSA publishes with each year of data. New
  [`decode_fars()`](https://elipousson.github.io/crashapi/reference/decode_fars.md)
  uses these labels to decode FARS or CRSS data with `decode = "names"`
  (add `…NAME` columns), `decode = "replace"` (replace codes with
  factors of decoded values for categorical variables), or
  `decode = "labelled"` (add value labels with
  [`haven::labelled()`](https://haven.tidyverse.org/reference/labelled.html)).
  [`get_fars()`](https://elipousson.github.io/crashapi/reference/get_fars.md)
  gains the same `decode` argument (with an additional `"none"` option)
  and adds `…NAME` columns by default where they are missing (FARS data
  before 2015) ([\#4](https://github.com/elipousson/crashapi/issues/4)).
- New
  [`fars_variables()`](https://elipousson.github.io/crashapi/reference/fars_variables.md)
  returns year-specific variable labels for FARS and CRSS variables from
  the SAS data files NHTSA publishes with each year of data. Variable
  labels from these files are now used (before `fars_vars_labels`) when
  the table and year are known, which labels variables added in recent
  years, discontinued variables, and CRSS-only variables
  (e.g. `WEIGHT`).
- `fars_vars_labels` adds title case labels for columns only returned by
  the CrashAPI (e.g. nested list columns from
  [`get_fars_cases()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md),
  `STATEINITIAL`, and vPIC variables in the VINDERIVED table), so every
  column returned by the CrashAPI now has a variable label. Variable
  labels from the SAS data files are used for variables that were only
  added in later years.
- [`get_fars_zip()`](https://elipousson.github.io/crashapi/reference/get_fars_zip.md)
  and
  [`get_crss_zip()`](https://elipousson.github.io/crashapi/reference/get_crss_zip.md)
  now retry failed downloads, give a clearer error when a file isn’t
  available, and no longer leave a partially downloaded zip file in the
  cache if a download fails.
- Breaking change:
  [`get_fars()`](https://elipousson.github.io/crashapi/reference/get_fars.md)
  is redesigned to return a FARS data table (e.g. accident, person, or
  vehicle) for one or more states, an optional county, and one or more
  years, similar to `stats19::get_stats19()`. Data for a state from 2010
  onwards comes from the CrashAPI and national data, Puerto Rico, or
  data before 2010 comes from zipped data files (set `source` to
  choose). Tables are filtered by county directly or by matching crashes
  in the county from the accident table. The `api`, `cases`, `vehicles`,
  `details`, `format`, `pr`, `path`, and `download` arguments are
  removed; use
  [`get_fars_crashes()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md),
  [`get_fars_cases()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md),
  [`get_fars_crash_list()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md),
  [`get_fars_summary()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md),
  or
  [`get_fars_year()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md)
  for other CrashAPI endpoints.
- Breaking change:
  [`get_fars_zip()`](https://elipousson.github.io/crashapi/reference/get_fars_zip.md)
  and
  [`get_crss_zip()`](https://elipousson.github.io/crashapi/reference/get_crss_zip.md)
  now convert zipped CSV files to parquet files cached in the user cache
  directory (or `getOption("crashapi.cache_dir")`) and remove the zip
  and CSV files unless `keep_files = TRUE`. Later calls read the cached
  files without downloading the data again unless `overwrite = TRUE`.
  With `read = FALSE`, they return the parquet file paths named by table
  (or a list named by year for multiple years). crashapi now imports
  nanoparquet.
- crashapi now requires R 4.1.0 or later, matching its dependencies and
  its use of the native pipe.
- Fix package to use the current CrashAPI base URL and browser headers
  (broken since January 2025).
- Breaking change: required arguments now come before `year` in
  [`get_fars_crashes()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md)
  (`state`, `county`),
  [`get_fars_cases()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md)
  (`state`, `cases`),
  [`get_fars_crash_list()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md),
  [`get_fars_summary()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md),
  [`get_fars_year()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md),
  [`get_fars_crash_vehicles()`](https://elipousson.github.io/crashapi/reference/get_fars_crash_vehicles.md)
  (`state`, `make`, `model`, `model_year`, `body_type`), and
  [`get_fars_crash_persons()`](https://elipousson.github.io/crashapi/reference/get_fars_crash_persons.md)
  (`state`, `age`, `sex`, `seat`, `injury`). Calls that pass `year` by
  position need to name it.
- [`get_fars_crash_persons()`](https://elipousson.github.io/crashapi/reference/get_fars_crash_persons.md)
  now works. `age`, `sex`, `seat`, and `injury` are all required since
  the CrashAPI returns an error unless all four are provided (contrary
  to NHTSA’s documentation), and names (e.g. `sex = "female"`,
  `seat = "front left"`, `injury = "fatal"`) are converted to codes. The
  `occupants` and `nonoccupants` arguments are removed since the seat
  position determines whether occupants or non-occupants are returned.
- [`get_fars_crash_vehicles()`](https://elipousson.github.io/crashapi/reference/get_fars_crash_vehicles.md)
  now requires `make`, `model`, `model_year`, and `body_type` since the
  CrashAPI returns an error unless all four are provided, and accepts
  names or numeric IDs for `make`, `model`, and `body_type` (previously
  only character IDs worked).
- Data from 2024 (released in April 2026) is now supported and the
  default `year` for all functions is
  `getOption("crashapi.year", 2024)`. Use
  `options(crashapi.year = 2022)` to set a different default year for
  the session.
- Breaking change: the `start_year` and `end_year` arguments are
  removed. Functions for API endpoints that take a range of years
  ([`get_fars_crashes()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md),
  [`get_fars_crash_list()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md),
  [`get_fars_summary()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md),
  [`get_fars_year()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md),
  [`get_fars_crash_vehicles()`](https://elipousson.github.io/crashapi/reference/get_fars_crash_vehicles.md),
  and
  [`get_fars_crash_persons()`](https://elipousson.github.io/crashapi/reference/get_fars_crash_persons.md))
  now use the minimum and maximum of `year` as the start and end year,
  with a message if `year` has gaps.
- [`fars_vars()`](https://elipousson.github.io/crashapi/reference/fars_vars.md)
  supports multiple years and returns a `year` column.
- [`get_fars_crashes()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md)
  errors with a clear message if `county` is missing.
- [`get_fars()`](https://elipousson.github.io/crashapi/reference/get_fars.md)
  and
  [`get_fars_crashes()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md)
  now error if `county` can’t be matched to a county in `state` (e.g. an
  ambiguous name like “Baltimore” or an invalid FIPS code) instead of
  filtering by the state FIPS code and returning no rows.
- Matching state and county names now returns FIPS codes for valid
  values when some values are invalid and drops county names that match
  more than one county (e.g. “Baltimore”) with a warning asking for a
  more specific name.
- `get_fars_cases(details = "events")` and
  `get_fars_cases(details = "vehicles")` now return details for all
  cases instead of only the first case, and
  [`get_fars_cases()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md)
  errors clearly if no case details are found.
- [`get_fars_zip()`](https://elipousson.github.io/crashapi/reference/get_fars_zip.md)
  and
  [`get_crss_zip()`](https://elipousson.github.io/crashapi/reference/get_crss_zip.md)
  now error before downloading if `read = TRUE` and `format = "sas"`.
- [`read_crashapi()`](https://elipousson.github.io/crashapi/reference/read_crashapi.md)
  no longer errors for responses without results and returns `NULL` with
  the CrashAPI message.
- [`get_fars_cases()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md)
  supports one year for each case number, and
  `get_fars_crashes(details = TRUE)` now works for multiple years by
  using the case year for each crash.
- [`get_fars_zip()`](https://elipousson.github.io/crashapi/reference/get_fars_zip.md)
  and
  [`get_crss_zip()`](https://elipousson.github.io/crashapi/reference/get_crss_zip.md)
  now read CSV files from the folder inside newer zip files, which
  previously caused `read = TRUE` to fail for most recent years.
- `get_crss_zip(year = 2019, aux = TRUE)` now handles the misspelled
  file name on the NHTSA site, and
  [`get_crss_zip()`](https://elipousson.github.io/crashapi/reference/get_crss_zip.md)
  is documented with a description of CRSS and a link to the official
  CRSS page.
- [`get_fars_zip()`](https://elipousson.github.io/crashapi/reference/get_fars_zip.md)
  and
  [`get_crss_zip()`](https://elipousson.github.io/crashapi/reference/get_crss_zip.md)
  warn if `geometry = TRUE` and the accident table has no coordinate
  columns (e.g. CRSS data or older FARS data) instead of silently
  returning a data frame.
- `get_fars_zip(pr = TRUE)` now uses the correct file name for Puerto
  Rico data and errors for years without Puerto Rico data (1975-1977 and
  1979). `get_fars_zip(year = 1996, aux = TRUE)` now handles the
  misspelled file name on the NHTSA site.
- [`get_fars_zip()`](https://elipousson.github.io/crashapi/reference/get_fars_zip.md)
  and
  [`get_crss_zip()`](https://elipousson.github.io/crashapi/reference/get_crss_zip.md)
  support multiple years and return a list named by year.
- [`format_crashes()`](https://elipousson.github.io/crashapi/reference/format_crashes.md),
  [`get_crss_zip()`](https://elipousson.github.io/crashapi/reference/get_crss_zip.md),
  [`get_fars()`](https://elipousson.github.io/crashapi/reference/get_fars.md),
  [`get_fars_cases()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md),
  [`get_fars_crash_list()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md),
  [`get_fars_crash_persons()`](https://elipousson.github.io/crashapi/reference/get_fars_crash_persons.md),
  [`get_fars_crash_vehicles()`](https://elipousson.github.io/crashapi/reference/get_fars_crash_vehicles.md),
  [`get_fars_crashes()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md),
  [`get_fars_summary()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md),
  [`get_fars_year()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md),
  and
  [`get_fars_zip()`](https://elipousson.github.io/crashapi/reference/get_fars_zip.md)
  gain a `var_labels` argument. When `"attribute"` (the default), each
  column with a matching variable in `fars_vars_labels` gets a `"label"`
  attribute (use `"none"` to skip variable labels), which is shown by
  [`View()`](https://rdrr.io/r/utils/View.html) and used by packages
  such as gt and gtsummary. Where a variable appears in more than one
  FARS data file, the label for the table being read is used.
- Variable labels now prefer labels for current variables over
  discontinued ones, match names case-insensitively when there is no
  exact match (e.g. `CASEYEAR`), label `…NAME` columns from their coded
  variable (e.g. `BODY_TYPNAME` from `BODY_TYP`), and label nested data
  frames in list columns returned by
  [`get_fars_cases()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md).
- [`format_crashes()`](https://elipousson.github.io/crashapi/reference/format_crashes.md)
  now reorders columns, converts coordinate and count columns, and
  appends `date`, `time`, and `datetime` columns as documented.
  Previously, a faulty check skipped this step, so
  [`get_fars_crashes()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md),
  [`get_fars_crash_list()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md),
  and
  [`get_fars_summary()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md)
  returned unformatted data. Column names are kept as returned by the
  API, and columns not found in `fars_vars_labels` are kept at the end.
- [`get_fars_year()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md)
  now supports the “RACE” (2019 onwards) and “TRAILERVINDERIVED” (2016
  onwards) tables.
- [`get_fars_year()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md)
  now sends the same browser headers as other API requests when reading
  CSV data or downloading a file (`download = TRUE`), and returns the
  downloaded file path invisibly.
- [`get_fars_year()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md)
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
[`get_fars_year()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md)
is also updated to support multiple years and to include a state
parameter which makes it much easier to use.

- refactor: update 2019 -\> 2020 max year
- feat: add geometry and state parameter support to
  [`get_fars_year()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md)
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
  [`get_fars_crash_details()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md)
  to
  [`get_fars_cases()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md)
- feat: Add details parameter to
  [`get_fars_crashes()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md)
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
  [`get_fars_crash_details()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md)
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
