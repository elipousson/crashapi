test_that("get_fars_summary() uses the minimum and maximum year", {
  local_mocked_bindings(
    read_crashapi = function(...) {
      args <- list(...)
      data.frame(FromYear = args$fromCaseYear, ToYear = args$toCaseYear)
    }
  )

  expect_no_message(out <- get_fars_summary(state = "MD", year = 2015:2020))
  expect_identical(c(out$FromYear, out$ToYear), c(2015L, 2020L))

  expect_snapshot(out <- get_fars_summary(state = "MD", year = c(2020, 2015)))
  expect_identical(c(out$FromYear, out$ToYear), c(2015L, 2020L))
})

test_that("get_fars_cases() uses one year for each case", {
  case_years <- NULL
  local_mocked_bindings(
    read_crashapi = function(...) {
      args <- list(...)
      case_years <<- c(case_years, args$caseYear)
      list(CrashResultSet = data.frame(ST_CASE = args$stateCase))
    }
  )

  get_fars_cases(state = "MD", cases = c(1, 2), year = c(2020, 2021))
  expect_identical(case_years, c(2020L, 2021L))

  case_years <- NULL
  get_fars_cases(state = "MD", cases = c(1, 2), year = 2022)
  expect_identical(case_years, c(2022L, 2022L))

  expect_snapshot(
    get_fars_cases(state = "MD", cases = c(1, 2), year = 2020:2022),
    error = TRUE
  )
})

test_that("get_fars_cases() adds variable labels", {
  local_mocked_bindings(
    read_crashapi = function(...) {
      crash_df <- data.frame(ST_CASE = 500001, LATITUDE = "44.5")
      crash_df$CEvents <- list(data.frame(AOI1 = 12))
      list(CrashResultSet = crash_df)
    }
  )

  out <- get_fars_cases(year = 2022, state = "VT", cases = 500001)
  expect_identical(attr(out$LATITUDE, "label"), "Latitude")
  expect_named(out, c("ST_CASE", "LATITUDE"))

  events <- get_fars_cases(
    year = 2022,
    state = "VT",
    cases = 500001,
    details = "events"
  )
  expect_identical(attr(events$AOI1, "label"), "Area of Impact (This Vehicle)")

  out <- get_fars_cases(
    year = 2022,
    state = "VT",
    cases = 500001,
    var_labels = "none"
  )
  expect_null(attr(out$LATITUDE, "label"))
})

test_that("CrashAPI endpoint functions work", {
  with_mock_api({
    expect_GET(
      get_fars_crashes(year = 2019, state = "MD", county = "Garrett County")
    )
    expect_GET(get_fars_cases(year = 2019, state = "MD", cases = 240063))
    expect_GET(get_fars_year(year = 2019, state = "MD", type = "ACCIDENT"))
  })

  expect_s3_class(
    get_fars_crash_list(year = 2019, state = "MD", vehicles = 5),
    "data.frame"
  )
  expect_s3_class(
    get_fars_crashes(year = 2019, state = "MD", county = "Garrett County"),
    "data.frame"
  )
  expect_s3_class(
    get_fars_crashes(
      year = 2019,
      state = "MD",
      county = "Garrett County",
      details = TRUE
    ),
    "data.frame"
  )
  expect_s3_class(
    get_fars_cases(year = 2019, state = "MD", cases = 240063),
    "data.frame"
  )
  expect_s3_class(
    get_fars_year(year = 2019, state = "MD", type = "ACCIDENT"),
    "data.frame"
  )
  expect_s3_class(get_fars_summary(year = 2019, state = "MD"), "data.frame")
})

test_that("get_fars warns and errors", {
  expect_warning(
    get_fars_crashes(year = 2022, state = "RI", county = "Bristol County"),
    "No records found with the provided parameters."
  )
  expect_message(
    get_fars_crashes(
      year = c(2010, 2020),
      state = "California",
      county = "Los Angeles"
    ),
    "Additional records may be available for this query."
  )
  expect_error(
    get_fars_summary(year = 2000, state = "MD"),
    "must be greater than or equal to"
  )
  expect_error(
    get_fars_crashes(year = 2019, state = "MD"),
    "must be a valid county name or FIPS code"
  )
})

test_that("get_cases works", {
  # Works with character and numeric inputs
  expect_s3_class(
    get_fars_cases(year = 2019, state = "MD", cases = "240063"),
    "data.frame"
  )
  expect_s3_class(
    get_fars_cases(year = 2019, state = "MD", cases = 240063),
    "data.frame"
  )
  expect_s3_class(
    get_fars_cases(
      year = 2019,
      state = "MD",
      cases = 240063,
      details = "events"
    ),
    "data.frame"
  )
  expect_s3_class(
    get_fars_cases(
      year = 2019,
      state = "MD",
      cases = 240063,
      details = "vehicles"
    ),
    "data.frame"
  )

  skip_if_not_installed("sf")
  expect_s3_class(
    get_fars_cases(
      year = 2019,
      state = "MD",
      cases = "240063",
      geometry = TRUE
    ),
    "sf"
  )
})

test_that("get_cases errors", {
  expect_error(
    get_fars_cases(year = 2019, state = "MD", cases = "0"),
    "No case details found"
  )
  expect_error(get_fars_cases(year = 2019, state = "MD"))
})

test_that("get_cases works", {
  # Works with character and numeric inputs
  expect_s3_class(
    get_fars_cases(year = 2019, state = "MD", cases = "240063"),
    "data.frame"
  )
  expect_s3_class(
    get_fars_cases(year = 2019, state = "MD", cases = 240063),
    "data.frame"
  )
  expect_s3_class(
    get_fars_cases(
      year = 2019,
      state = "MD",
      cases = 240063,
      details = "events"
    ),
    "data.frame"
  )
  expect_s3_class(
    get_fars_cases(
      year = 2019,
      state = "MD",
      cases = 240063,
      details = "vehicles"
    ),
    "data.frame"
  )

  skip_if_not_installed("sf")
  expect_s3_class(
    get_fars_crashes(
      year = 2022,
      state = "MD",
      county = "Garrett",
      geometry = TRUE
    ),
    "sf"
  )
})

test_that("get_fars_cases() combines details for all cases", {
  local_mocked_bindings(
    read_crashapi = function(...) {
      args <- list(...)
      crash_df <- data.frame(ST_CASE = args$stateCase)
      crash_df$CEvents <- list(
        data.frame(ST_CASE = args$stateCase, EVENTNUM = 1:2)
      )
      list(CrashResultSet = crash_df)
    }
  )

  events <- get_fars_cases(
    state = "MD",
    cases = c(1, 2),
    year = 2020,
    details = "events",
    var_labels = "none"
  )
  expect_identical(events$ST_CASE, c(1, 1, 2, 2))
})

test_that("get_fars_cases() errors if no case details are found", {
  local_mocked_bindings(read_crashapi = function(...) NULL)

  expect_snapshot(
    get_fars_cases(state = "MD", cases = 1, year = 2020),
    error = TRUE
  )
})

local_mocked_fars_zip <- function(tables, env = parent.frame()) {
  path <- withr::local_tempdir(.local_envir = env)
  local_mocked_bindings(
    get_fars_zip = function(year, ...) {
      year_tables <- tables[[as.character(year)]]
      files <- file.path(
        path,
        paste0(year, "_", names(year_tables), ".parquet")
      )
      for (i in seq_along(files)) {
        nanoparquet::write_parquet(year_tables[[i]], files[[i]])
      }
      rlang::set_names(files, names(year_tables))
    },
    .env = env
  )
}

test_that("get_fars() uses the CrashAPI or zipped data files", {
  sources <- NULL
  local_mocked_bindings(
    get_fars_api_table = function(...) {
      sources <<- c(sources, "api")
      data.frame(ST_CASE = 1)
    },
    get_fars_zip_table = function(state, years, type, is_pr = FALSE, ...) {
      sources <<- c(sources, if (is_pr) "zip (PR)" else "zip")
      data.frame(ST_CASE = 1)
    }
  )

  get_fars("MD", year = 2022)
  get_fars(year = 2022)
  get_fars("MD", year = 2005)
  get_fars("PR", year = 2022)
  get_fars("MD", year = 2022, source = "zip")

  expect_identical(sources, c("api", "zip", "zip", "zip (PR)", "zip"))
  expect_snapshot(get_fars("MD", year = 2005, source = "api"), error = TRUE)
})

test_that("get_fars() filters zipped data by state and adds a case year", {
  local_mocked_fars_zip(list(
    "2021" = list(accident = data.frame(STATE = c(24, 50), ST_CASE = 1:2)),
    "2022" = list(accident = data.frame(STATE = c(24, 50), ST_CASE = 3:4))
  ))

  out <- get_fars("VT", year = 2021:2022, source = "zip", var_labels = "none")
  expect_identical(out$ST_CASE, c(2L, 4L))
  expect_identical(out$CASEYEAR, c(2021L, 2022L))

  expect_snapshot(
    get_fars("VT", year = 2021, type = "race", source = "zip"),
    error = TRUE
  )
})

test_that("get_fars() returns a list if tables can't be combined", {
  local_mocked_fars_zip(list(
    "2021" = list(accident = data.frame(STATE = 24, ST_CASE = 1)),
    "2022" = list(accident = data.frame(STATE = 24, ST_CASE = "a"))
  ))

  expect_snapshot(
    out <- get_fars("MD", year = 2021:2022, source = "zip", var_labels = "none")
  )
  expect_named(out, c("2021", "2022"))
})

test_that("get_fars() filters by county using the accident table", {
  local_mocked_fars_zip(list(
    "2022" = list(
      accident = data.frame(STATE = 24, ST_CASE = 1:3, COUNTY = c(510, 5, 510)),
      vehicle = data.frame(
        STATE = 24,
        ST_CASE = c(1, 1, 2, 3),
        VEH_NO = c(1, 2, 1, 1)
      )
    )
  ))

  accident <- get_fars(
    "MD",
    year = 2022,
    county = "Baltimore city",
    source = "zip",
    var_labels = "none"
  )
  expect_identical(accident$ST_CASE, c(1L, 3L))

  vehicle <- get_fars(
    "MD",
    year = 2022,
    type = "vehicle",
    county = "Baltimore city",
    source = "zip",
    var_labels = "none"
  )
  expect_identical(vehicle$ST_CASE, c(1, 1, 3))

  expect_snapshot(
    get_fars(c("MD", "VT"), year = 2022, county = "Baltimore city"),
    error = TRUE
  )
})

test_that("get_fars() converts CrashAPI values to match zipped data", {
  local_mocked_bindings(
    get_fars_year = function(...) {
      data.frame(ST_CASE = "240001", LATITUDE = "39.3", STATENAME = "Maryland")
    }
  )

  out <- get_fars("MD", year = 2022, var_labels = "none")
  expect_identical(out$ST_CASE, 240001L)
  expect_identical(out$LATITUDE, 39.3)
  expect_identical(out$STATENAME, "Maryland")
})

test_that("get_fars() errors for a county that can't be matched", {
  local_mocked_bindings(
    get_fars_api_table = function(...) stop("data should not be requested"),
    get_fars_zip_table = function(...) stop("data should not be requested")
  )

  expect_snapshot(
    get_fars("MD", year = 2022, county = "Baltimore"),
    error = TRUE
  )
})
