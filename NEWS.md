<!-- NEWS.md is maintained by https://cynkra.github.io/fledge, do not edit -->

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
