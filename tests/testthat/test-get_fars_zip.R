test_that("get_fars_zip() supports the default year", {
  path <- withr::local_tempdir()
  destfile <- local_fars_zip(path)

  expect_identical(
    get_fars_zip(read = FALSE, path = path),
    file.path(path, "FARS2022NationalCSV.zip")
  )
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
