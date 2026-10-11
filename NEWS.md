<!-- NEWS.md is maintained by https://fledge.cynkra.com, contributors should not edit this file -->

# crashapi (development version)

- `format_crashes()` gains a `labels` argument. When `TRUE` (the default), each column with a matching variable in `fars_vars_labels` gets a `"label"` attribute, which is shown by `View()` and used by packages such as gt and gtsummary.
- `format_crashes()` now reorders columns, converts coordinate and count columns, and appends `date`, `time`, and `datetime` columns as documented. Previously, a faulty check skipped this step, so `get_fars_crashes()`, `get_fars_crash_list()`, and `get_fars_summary()` returned unformatted data. Column names are kept as returned by the API, and columns not found in `fars_vars_labels` are kept at the end.
- `get_fars()` now works with `api = "zip"` when `format` is left at its default ("json" is treated as "csv").
- `get_fars_year()` returns the data with a warning when `geometry = TRUE` and the table has no coordinate columns, instead of downloading a file.
- `get_fars_zip()` now supports 2022 data, matching its default `year`.

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
