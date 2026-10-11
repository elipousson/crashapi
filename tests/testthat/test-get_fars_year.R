test_that("get_fars_year() returns data if geometry can't be added", {
  skip_if_not_installed("readr")
  csv <- withr::local_tempfile(fileext = ".csv")
  utils::write.csv(data.frame(ST_CASE = 1, AGE = 30), csv, row.names = FALSE)
  local_mocked_bindings(read_crashapi = function(...) csv)
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
  expect_identical(out$AGE, 30)
})

test_that("get_fars_year works", {
  expect_s3_class(
    get_fars_year(year = 2022, state = "VT", format = "csv"),
    "data.frame"
  )
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
