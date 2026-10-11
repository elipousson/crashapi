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

