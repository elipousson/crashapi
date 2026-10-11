# crashapi (development version)

- crashapi now requires R 4.1.0 or later, matching its dependencies and its use of the native pipe.
- Fix package to use the current CrashAPI base URL and browser headers (broken since January 2025).
- Breaking change: required arguments now come before `year` in `get_fars()` (`state`), `get_fars_crashes()` (`state`, `county`), `get_fars_cases()` (`state`, `cases`), `get_fars_crash_list()`, `get_fars_summary()`, `get_fars_year()`, `get_fars_crash_vehicles()` (`state`, `make`, `model`, `model_year`, `body_type`), and `get_fars_crash_persons()` (`state`, `age`, `sex`, `seat`, `injury`). Calls that pass `year` by position need to name it.
- `get_fars_crash_persons()` now works. `age`, `sex`, `seat`, and `injury` are all required since the CrashAPI returns an error unless all four are provided (contrary to NHTSA's documentation), and names (e.g. `sex = "female"`, `seat = "front left"`, `injury = "fatal"`) are converted to codes. The `occupants` and `nonoccupants` arguments are removed since the seat position determines whether occupants or non-occupants are returned.
- `get_fars_crash_vehicles()` now requires `make`, `model`, `model_year`, and `body_type` since the CrashAPI returns an error unless all four are provided, and accepts names or numeric IDs for `make`, `model`, and `body_type` (previously only character IDs worked).
- Data from 2024 (released in April 2026) is now supported and the default `year` for all functions is `getOption("crashapi.year", 2024)`. Use `options(crashapi.year = 2022)` to set a different default year for the session.
- Breaking change: the `start_year` and `end_year` arguments are removed. Functions for API endpoints that take a range of years (`get_fars_crashes()`, `get_fars_crash_list()`, `get_fars_summary()`, `get_fars_year()`, `get_fars_crash_vehicles()`, and `get_fars_crash_persons()`) now use the minimum and maximum of `year` as the start and end year, with a message if `year` has gaps.
- `fars_vars()` supports multiple years and returns a `year` column.
- `get_fars()` now uses `api` when it is provided instead of inferring the api from other arguments (e.g. `type`).
- `get_fars_cases(details = "events")` and `get_fars_cases(details = "vehicles")` now return details for all cases instead of only the first case, and `get_fars_cases()` errors clearly if no case details are found.
- `get_fars_zip()` and `get_crss_zip()` now error before downloading if `read = TRUE` and `format = "sas"`.
- `read_crashapi()` no longer errors for responses without results and returns `NULL` with the CrashAPI message.
- `get_fars_cases()` supports one year for each case number, and `get_fars_crashes(details = TRUE)` now works for multiple years by using the case year for each crash.
- `get_fars_zip()` and `get_crss_zip()` now read CSV files from the folder inside newer zip files, which previously caused `read = TRUE` to fail for most recent years.
- `get_fars_zip(pr = TRUE)` now uses the correct file name for Puerto Rico data and errors for years without Puerto Rico data (1975-1977 and 1979). `get_fars_zip(year = 1996, aux = TRUE)` now handles the misspelled file name on the NHTSA site.
- `get_fars_zip()` and `get_crss_zip()` support multiple years and return a list (or vector of file paths) named by year.
- `format_crashes()`, `get_crss_zip()`, `get_fars()`, `get_fars_cases()`, `get_fars_crash_list()`, `get_fars_crash_persons()`, `get_fars_crash_vehicles()`, `get_fars_crashes()`, `get_fars_summary()`, `get_fars_year()`, and `get_fars_zip()` gain a `labels` argument. When `TRUE` (the default), each column with a matching variable in `fars_vars_labels` gets a `"label"` attribute, which is shown by `View()` and used by packages such as gt and gtsummary. Where a variable appears in more than one FARS data file, the label for the table being read is used.
- Variable labels now prefer labels for current variables over discontinued ones, match names case-insensitively when there is no exact match (e.g. `CASEYEAR`), label `…NAME` columns from their coded variable (e.g. `BODY_TYPNAME` from `BODY_TYP`), and label nested data frames in list columns returned by `get_fars_cases()`.
- `format_crashes()` now reorders columns, converts coordinate and count columns, and appends `date`, `time`, and `datetime` columns as documented. Previously, a faulty check skipped this step, so `get_fars_crashes()`, `get_fars_crash_list()`, and `get_fars_summary()` returned unformatted data. Column names are kept as returned by the API, and columns not found in `fars_vars_labels` are kept at the end.
- `get_fars()` now works with `api = "zip"` when `format` is left at its default ("json" is treated as "csv").
- `get_fars_year()` now supports the "RACE" (2019 onwards) and "TRAILERVINDERIVED" (2016 onwards) tables.
- `get_fars_year()` now sends the same browser headers as other API requests when reading CSV data or downloading a file (`download = TRUE`), and returns the downloaded file path invisibly.
- `get_fars_year()` returns the data with a warning when `geometry = TRUE` and the table has no coordinate columns, instead of downloading a file.

# crashapi 0.1.2

- Update year range to cover 2022 data.

# crashapi 0.1.1.9

- Update year range to cover 2021 data.
- Add `get_crss_zip()` function

# crashapi 0.1.1

CrashAPI now has data from 2010 to 2020. `get_fars_year()` is also updated to support multiple years and to include a state parameter which makes it much easier to use.

- refactor: update 2019 -> 2020 max year
- feat: add geometry and state parameter support to `get_fars_year()`
- refactor: set default crs to NULL and switch to use `sfext::df_to_sf`
- refactor: switch to use `httr2` package + `read_crashapi()` for data access (except for zip)
- test: add tests and set up code coverage tests

# crashapi 0.1.0.12

- feat: Add `get_fars_crash_persons()` function
- refactor: Rename `tidy_crashes()` to `format_crashes()`
- feat: rename `get_fars_crash_details()` to `get_fars_cases()`
- feat: Add details parameter to `get_fars_crashes()` to supported appending detailed case information
- feat: Add `fars_vars_labels` with names and labels derived from current analytical manual

# crashapi 0.1.0.11

- feat: add `get_fars()` function that uses an api parameter to call different APIs
- feat: import helper functions from {tigris} package to improve renamed `lookup_fips()` function
- feat: Add `get_fars_crash_vehicles` to support downloading crash data by vehicle make, model, and/or body type
- fix: `get_fars_year` was not using the correct query URL if download = TRUE
- refactor: relocate helper functions to utils.R
- refactor: rename `make_query()` helper function to `read_api()`
- refactor: update `validate_year()` helper function to work with {checkmate} package
- refactor: update default values for year, start_year, end_year and other parameters
- docs: Update README and pkgdown site

# crashapi 0.1.0.10

- feat: `get_fars_zip` added to provide alternate (non-API) method for downloading zipped CSV or SAS data files
- fix: `get_fars_crash_details` updated to return data frame w/o list columns
- feat: `get_fars_crash_details` updated to optionally return vehicle or crash events data frames

# crashapi 0.1.0.9

- docs: Revise README and update pkgdown site
- fix: Add missing imports to `DESCRIPTION`
- fix: Update `county_to_fips()` to support partial county names, e.g. "Adams" instead of "Adams County" and avoiding matching multiple counties (closes [#1](https://github.com/elipousson/crashapi/issues/1))
- feat: Update `get_fars_crash_details()` to return sf objects using geometry parameter
- refactor: Set up API calls w/ unexported utility function (`make_query`)

# crashapi 0.1.0

* Added functions for accessing FARS APIs including Get Crash List Information,  Get Crash Details, Get Crashes By Location, Get Summary Counts, and Get FARS Data By Year (documented in `get_fars()`)
* Added functions for accessing FARS APIs including Get Variables and Get Variable Attributes (documented in `get_fars_vars()`)
* Added `fars_terms` data with terms and definitions from National Highway Traffic Safety Administration (NHTSA) website
* Added a `NEWS.md` file to track changes to the package.
* Set up a pkgdown website
