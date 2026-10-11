test_that("get_fars_zip() uses the crashapi.year option for the default year", {
  path <- withr::local_tempdir()
  local_fars_zip(path, year = 2024)
  local_fars_zip(path, year = 2022)

  expect_identical(
    get_fars_zip(read = FALSE, path = path),
    file.path(path, "FARS2024NationalCSV.zip")
  )

  withr::local_options(crashapi.year = 2022)
  expect_identical(
    get_fars_zip(read = FALSE, path = path),
    file.path(path, "FARS2022NationalCSV.zip")
  )
})

test_that("get_fars_zip() returns results for multiple years named by year", {
  skip_if_not_installed("readr")
  path <- withr::local_tempdir()
  local_fars_zip(path, year = 2023)
  local_fars_zip(path, year = 2024)

  paths <- get_fars_zip(year = 2023:2024, read = FALSE, path = path)
  expect_named(paths, c("2023", "2024"))
  expect_identical(
    unname(paths),
    file.path(path, c("FARS2023NationalCSV.zip", "FARS2024NationalCSV.zip"))
  )

  data <- get_fars_zip(year = 2023:2024, path = path)
  expect_named(data, c("2023", "2024"))
  expect_named(data[["2024"]], "accident")
})

test_that("get_fars_zip() adds variable labels", {
  skip_if_not_installed("readr")
  path <- withr::local_tempdir()
  local_fars_zip(path)

  data <- get_fars_zip(path = path)
  expect_identical(attr(data$accident$LATITUDE, "label"), "Latitude")

  data <- get_fars_zip(path = path, labels = FALSE)
  expect_null(attr(data$accident$LATITUDE, "label"))
})

test_that("get_fars_zip works", {
  expect_true(
    file.exists(
      get_fars_zip(
        year = 1978,
        read = FALSE,
        path = tempdir(),
        overwrite = TRUE
      )
    )
  )
  data <-
    suppressWarnings(
      get_fars_zip(
        year = 1978,
        read = TRUE,
        path = tempdir(),
        overwrite = TRUE
      )
    )
  expect_type(
    data,
    "list"
  )
  expect_identical(
    names(data),
    c("accident", "person", "vehicle")
  )
})
