# get_fars_summary() uses the minimum and maximum year

    Code
      out <- get_fars_summary(state = "MD", year = c(2020, 2015))
    Message
      i Requesting data for all years from 2015 to 2020, including 2016, 2017, 2018, and 2019 not in `year`.

# get_fars_cases() uses one year for each case

    Code
      get_fars_cases(state = "MD", cases = c(1, 2), year = 2020:2022)
    Condition
      Error in `get_fars_cases()`:
      ! `year` must be a single year or one year for each case in `cases`, not 3 years for 2 cases.

# get_fars_cases() errors if no case details are found

    Code
      get_fars_cases(state = "MD", cases = 1, year = 2020)
    Condition
      Error in `get_fars_cases()`:
      ! No case details found for `cases` 1.

# get_fars() uses the CrashAPI or zipped data files

    Code
      get_fars("MD", year = 2005, source = "api")
    Condition
      Error in `get_fars()`:
      ! `source = "api"` requires a `state` (other than Puerto Rico) and years from 2010 onwards.
      i Use `source = "zip"` for national data, Puerto Rico, or years before 2010.

# get_fars() filters zipped data by state and adds a case year

    Code
      get_fars("VT", year = 2021, type = "race", source = "zip")
    Condition
      Error in `get_fars()`:
      ! The "race" table is not available for 2021.
      i Available tables: "accident"

# get_fars() returns a list if tables can't be combined

    Code
      out <- get_fars("MD", year = 2021:2022, source = "zip", labels = FALSE)
    Condition
      Warning in `get_fars()`:
      The "accident" tables for 2021 and 2022 can't be combined.
      i Returning a list of tables named by year.
      Caused by error in `list_rbind()`:
      ! Can't combine `..1$ST_CASE` <double> and `..2$ST_CASE` <character>.

# get_fars() filters by county using the accident table

    Code
      get_fars(c("MD", "VT"), year = 2022, county = "Baltimore city")
    Condition
      Error in `get_fars()`:
      ! `county` requires a single `state`.

