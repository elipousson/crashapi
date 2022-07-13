<!-- NEWS.md is maintained by https://cynkra.github.io/fledge, do not edit -->

# crashapi 0.1.1

- refactor: update 2019 -> 2020 max year
- feat: add geometry and state parameter support to get_fars_year
- refactor: set default crs to NULL and switch to use df_to_sf from sfext
- refactor: replace usethis and progress w/ cli in Imports
- test: update tests with corrected error messages
- docs: minor updates to get_fars documentation
- fix: correct onLoad handling of fars_vars_labels data
- style: run styler
- docs: finish update to pkgdown site
- docs: add date added/updated to data documentation
- feat: update crash_data_index with recent additions (e.g. Wyoming)
- docs: update pkgdown site
- fix: correct issue w/ analytics API template
- refactor: reorganize fars_vars
- test: restore tests for "summary count" data
-refactor: switch to use httr2 package + read_crashapi for data access (except for zip)
- test: add tests and set up code coverage tests
- feat: Add get_fars_crash_persons function
- docs: update pkgdown site
- fix: Fix issue w/ inaccurate derived time column by updating `format_crashes()` to correctly pad and combine hour/minute columns
- refactor: Rename `tidy_crashes()` to `format_crashes()`
- docs: Update pkgdown site (again)
- feat: Add progress_bar parameter to `get_fars_cases()`
- docs: Update pkgdown site (again)
- docs: Update README and pkgdown site
- feat: rename `get_fars_crash_details` to `get_fars_cases`
- refactor: remove automatic API parameter message
- feat: Add details parameter to `get_fars_crashes()` to supported appending detailed case information
- feat: Add `tidy_crashes()` utility function to clean/reorder column names and append date/time columns
- fix: remove broken case number check from  `get_fars_cases()`
- refactor: rename "case" parameter to "cases" for `get_fars()` and `get_fars_cases()`
- refactor: update `validate_year()` helper function/defaults to better handle start_year and end_year
- feat: Add `fars_vars_labels` with names and labels derived from current analytical manual


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
