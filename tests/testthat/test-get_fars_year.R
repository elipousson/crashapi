test_that("get_fars_year works", {
  expect_s3_class(get_fars_year(year = c(2019, 2020), state = "VT"), "data.frame")
  expect_error(get_fars_year(year = c(2019, 2020), state = "VT", type = "XYZ"), "'arg' should be one of")
  expect_error(get_fars_year(year = c(2017, 2018), state = "VT", type = "NMDISTRACT"), "'arg' should be one of")
  expect_s3_class(get_fars_year(year = 2019, state = "VT", type = "NMDISTRACT"), "data.frame")
  expect_warning(get_fars_year(year = 2019, state = "VT", type = "NMDISTRACT", geometry = TRUE), "Coordinate columns LONGITUD and LATITUDE can't be found")
  expect_s3_class(get_fars_year(year = 2019, state = "VT", type = "accident", geometry = TRUE), "sf")
})
