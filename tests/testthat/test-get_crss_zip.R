crss_parquet_path <- function(path, year, aux = FALSE, table = "accident") {
  folder <- paste0("CRSS", year, if (aux) "Auxiliary", "CSV")
  rlang::set_names(
    file.path(path, "CRSS", year, folder, paste0(table, ".parquet")),
    table
  )
}

test_that("get_crss_zip() uses the crashapi.year option for the default year", {
  skip_if_not_installed("readr")
  path <- withr::local_tempdir()
  local_crss_zip(path, year = 2024)
  local_crss_zip(path, year = 2018)

  expect_identical(
    get_crss_zip(read = FALSE, path = path),
    crss_parquet_path(path, 2024)
  )

  withr::local_options(crashapi.year = 2018)
  expect_identical(
    get_crss_zip(read = FALSE, path = path),
    crss_parquet_path(path, 2018)
  )
})

test_that("get_crss_zip() reads cached tables", {
  skip_if_not_installed("readr")
  path <- withr::local_tempdir()
  zipfile <- local_crss_zip(path, year = 2024)

  data <- get_crss_zip(year = 2024, path = path)
  expect_named(data, "accident")
  expect_equal(data$accident$WEIGHT, 150.5, ignore_attr = TRUE)
  # CRSS-only variables are labelled from the CRSS SAS data files
  expect_identical(attr(data$accident$WEIGHT, "label"), "Case Weight")
  expect_identical(list.files(dirname(zipfile)), "accident.parquet")

  local_mocked_bindings(
    download_zip = function(...) stop("download_zip() should not be called")
  )
  expect_identical(get_crss_zip(year = 2024, path = path), data)
})

test_that("get_crss_zip() returns results for multiple years named by year", {
  skip_if_not_installed("readr")
  path <- withr::local_tempdir()
  local_crss_zip(path, year = 2023)
  local_crss_zip(path, year = 2024)

  data <- get_crss_zip(year = 2023:2024, path = path)
  expect_named(data, c("2023", "2024"))
  expect_named(data[["2023"]], "accident")
})

test_that("get_crss_zip() builds URLs including 2019 auxiliary data", {
  skip_if_not_installed("readr")
  fixture <- make_fars_zip(file.path(withr::local_tempdir(), "fixture.zip"))
  urls <- NULL
  local_mocked_bindings(
    download_zip = function(url, destfile, ...) {
      urls <<- c(urls, url)
      file.copy(fixture, destfile)
    }
  )
  path <- withr::local_tempdir()

  get_crss_zip(year = 2022, read = FALSE, path = path)
  get_crss_zip(year = 2022, aux = TRUE, read = FALSE, path = path)
  aux_2019 <- get_crss_zip(year = 2019, aux = TRUE, read = FALSE, path = path)

  expect_identical(
    urls,
    c(
      "https://static.nhtsa.gov/nhtsa/downloads/CRSS/2022/CRSS2022CSV.zip",
      "https://static.nhtsa.gov/nhtsa/downloads/CRSS/2022/CRSS2022AuxiliaryCSV.zip",
      "https://static.nhtsa.gov/nhtsa/downloads/CRSS/2019/CRSS2019AuxiliaryCVS.zip"
    )
  )
  expect_identical(aux_2019, crss_parquet_path(path, 2019, aux = TRUE))
})

test_that("get_crss_zip() warns that geometry is not supported", {
  skip_if_not_installed("readr")
  path <- withr::local_tempdir()
  local_crss_zip(path, year = 2024)

  expect_snapshot(
    data <- get_crss_zip(year = 2024, path = path, geometry = TRUE)
  )
  expect_s3_class(data$accident, "data.frame")
  expect_identical(class(data$accident), c("tbl", "data.frame"))
})

test_that("get_crss_zip() errors for invalid years and reading SAS files", {
  local_mocked_bindings(
    download_zip = function(...) stop("download_zip() should not be called")
  )

  expect_snapshot(get_crss_zip(year = 2015), error = TRUE)
  expect_snapshot(
    get_crss_zip(year = 2024, format = "sas", read = TRUE),
    error = TRUE
  )
})

test_that("get_crss_zip() downloads SAS files without converting them", {
  local_mocked_bindings(
    download_zip = function(url, destfile, ...) file.create(destfile)
  )
  path <- withr::local_tempdir()

  expect_identical(
    get_crss_zip(year = 2024, format = "sas", read = FALSE, path = path),
    file.path(path, "CRSS", "2024", "CRSS2024SAS", "CRSS2024SAS.zip")
  )
})
