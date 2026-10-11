local_mocked_csv <- function(csv, env = parent.frame()) {
  local_mocked_bindings(
    read_crashapi = function(...) "https://example.com/GetFARSData",
    .env = env
  )
  httr2::local_mocked_responses(
    function(req) {
      httr2::response(
        status_code = 200,
        headers = list(`Content-Type` = "text/csv"),
        body = charToRaw(csv)
      )
    },
    env = env
  )
}

test_that("get_fars_year() returns data if geometry can't be added", {
  skip_if_not_installed("readr")
  local_mocked_csv("ST_CASE,AGE\n1,30\n")
  withr::local_options(readr.show_col_types = FALSE)

  expect_snapshot(
    out <- get_fars_year(
      year = 2022,
      state = "VT",
      type = "person",
      format = "csv",
      geometry = TRUE
    )
  )
  expect_s3_class(out, "data.frame")
  expect_equal(out$AGE, 30, ignore_attr = TRUE)
  expect_identical(attr(out$AGE, "label"), "Age")
})

test_that("get_fars_year() sends browser headers for csv requests", {
  skip_if_not_installed("readr")
  withr::local_options(readr.show_col_types = FALSE)
  local_mocked_bindings(
    read_crashapi = function(...) "https://example.com/GetFARSData"
  )
  user_agent <- NULL
  httr2::local_mocked_responses(function(req) {
    user_agent <<- req$headers[["User-Agent"]]
    httr2::response(status_code = 200, body = charToRaw("ST_CASE\n1\n"))
  })

  get_fars_year(year = 2022, state = "VT", format = "csv")
  expect_match(user_agent, "^Mozilla/5.0")
})

test_that("get_fars_year() downloads to a file", {
  path <- withr::local_tempdir()
  local_mocked_csv("ST_CASE,AGE\n1,30\n")

  out <- get_fars_year(
    year = 2022,
    state = "VT",
    type = "person",
    format = "csv",
    path = path,
    download = TRUE
  )
  expect_identical(out, file.path(path, "2022_2022_PERSON.csv"))
  expect_identical(readLines(out), c("ST_CASE,AGE", "1,30"))
})

test_that("get_fars_year works with csv format", {
  expect_s3_class(
    get_fars_year(year = 2022, state = "VT", format = "csv"),
    "data.frame"
  )
})

test_that("get_fars_year works", {
  expect_s3_class(
    get_fars_year(year = c(2019, 2020), state = "VT"),
    "data.frame"
  )
  expect_error(
    get_fars_year(year = c(2019, 2020), state = "VT", type = "XYZ"),
    "'arg' should be one of"
  )
  expect_error(
    get_fars_year(year = c(2017, 2018), state = "VT", type = "NMDISTRACT"),
    "'arg' should be one of"
  )
  expect_s3_class(
    get_fars_year(year = 2019, state = "VT", type = "NMDISTRACT"),
    "data.frame"
  )
  expect_warning(
    get_fars_year(
      year = 2019,
      state = "VT",
      type = "NMDISTRACT",
      geometry = TRUE
    ),
    "Coordinate columns LONGITUD and LATITUDE can't be found"
  )
  expect_s3_class(
    get_fars_year(
      year = 2019,
      state = "VT",
      type = "accident",
      geometry = TRUE
    ),
    "sf"
  )
})
