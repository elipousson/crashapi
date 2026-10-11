fars_parquet_path <- function(
  path,
  year,
  scope = "National",
  table = "accident"
) {
  folder <- paste0("FARS", year, scope, "CSV")
  rlang::set_names(
    file.path(path, "FARS", year, folder, paste0(table, ".parquet")),
    table
  )
}

test_that("get_fars_zip() uses the crashapi.year option for the default year", {
  skip_if_not_installed("readr")
  path <- withr::local_tempdir()
  local_fars_zip(path, year = 2024)
  local_fars_zip(path, year = 2022)

  expect_identical(
    get_fars_zip(read = FALSE, path = path),
    fars_parquet_path(path, 2024)
  )

  withr::local_options(crashapi.year = 2022)
  expect_identical(
    get_fars_zip(read = FALSE, path = path),
    fars_parquet_path(path, 2022)
  )
})

test_that("get_fars_zip() caches parquet files and removes zip files", {
  skip_if_not_installed("readr")
  path <- withr::local_tempdir()
  zipfile <- local_fars_zip(path, year = 2024)

  first <- get_fars_zip(year = 2024, path = path)
  expect_identical(list.files(dirname(zipfile)), "accident.parquet")

  # Later calls read the cached parquet files without downloading
  local_mocked_bindings(
    download.file = function(...) stop("download.file() should not be called")
  )
  expect_identical(get_fars_zip(year = 2024, path = path), first)
})

test_that("get_fars_zip() keeps or replaces downloaded files", {
  skip_if_not_installed("readr")
  path <- withr::local_tempdir()
  fixture <- make_fars_zip(file.path(withr::local_tempdir(), "fixture.zip"))
  downloads <- 0
  local_mocked_bindings(
    download.file = function(url, destfile, ...) {
      downloads <<- downloads + 1
      file.copy(fixture, destfile)
    }
  )

  get_fars_zip(year = 2024, path = path, read = FALSE, keep_files = TRUE)
  cache <- file.path(path, "FARS", "2024", "FARS2024NationalCSV")
  expect_identical(
    sort(list.files(cache)),
    c("FARS2024NationalCSV", "FARS2024NationalCSV.zip", "accident.parquet")
  )

  get_fars_zip(year = 2024, path = path, read = FALSE, overwrite = TRUE)
  expect_identical(downloads, 2)
  expect_identical(list.files(cache), "accident.parquet")
})

test_that("get_fars_zip() returns results for multiple years named by year", {
  skip_if_not_installed("readr")
  path <- withr::local_tempdir()
  local_fars_zip(path, year = 2023)
  local_fars_zip(path, year = 2024)

  paths <- get_fars_zip(year = 2023:2024, read = FALSE, path = path)
  expect_identical(
    paths,
    list(
      "2023" = fars_parquet_path(path, 2023),
      "2024" = fars_parquet_path(path, 2024)
    )
  )

  data <- get_fars_zip(year = 2023:2024, path = path)
  expect_named(data, c("2023", "2024"))
  expect_named(data[["2024"]], "accident")
})

test_that("get_fars_zip() builds URLs for Puerto Rico and 1996 auxiliary data", {
  skip_if_not_installed("readr")
  fixture <- make_fars_zip(file.path(withr::local_tempdir(), "fixture.zip"))
  urls <- NULL
  local_mocked_bindings(
    download.file = function(url, destfile, ...) {
      urls <<- c(urls, url)
      file.copy(fixture, destfile)
    }
  )
  path <- withr::local_tempdir()

  get_fars_zip(year = 2022, pr = TRUE, read = FALSE, path = path)
  aux <- get_fars_zip(year = 1996, aux = TRUE, read = FALSE, path = path)

  expect_identical(
    urls,
    c(
      "https://static.nhtsa.gov/nhtsa/downloads/FARS/2022/Puerto%20Rico/FARS2022PuertoRicoCSV.zip",
      "https://static.nhtsa.gov/nhtsa/downloads/FARS/1996/National/FARS1996NationalAuxiliaryCVS.zip"
    )
  )
  expect_identical(
    aux,
    fars_parquet_path(path, 1996, scope = "NationalAuxiliary")
  )
})

test_that("get_fars_zip() downloads SAS files without converting them", {
  local_mocked_bindings(
    download.file = function(url, destfile, ...) file.create(destfile)
  )
  path <- withr::local_tempdir()

  expect_identical(
    get_fars_zip(year = 2024, format = "sas", read = FALSE, path = path),
    file.path(
      path,
      "FARS",
      "2024",
      "FARS2024NationalSAS",
      "FARS2024NationalSAS.zip"
    )
  )
})

test_that("get_fars_zip() errors for years without Puerto Rico data", {
  expect_snapshot(get_fars_zip(year = 1979, pr = TRUE), error = TRUE)
})

test_that("get_fars_zip() reads CSV files in a folder within the zip file", {
  skip_if_not_installed("readr")
  path <- withr::local_tempdir()
  local_fars_zip(path, year = 2022, scope = "PuertoRico", nested = TRUE)

  data <- get_fars_zip(year = 2022, pr = TRUE, path = path)
  expect_named(data, "accident")
  expect_s3_class(data$accident, "data.frame")
})

test_that("get_fars_zip() errors before downloading SAS files to read", {
  local_mocked_bindings(
    download.file = function(...) stop("download.file() should not be called")
  )

  expect_snapshot(
    get_fars_zip(year = 2024, format = "sas", read = TRUE),
    error = TRUE
  )
})

test_that("get_fars_zip() adds variable labels", {
  skip_if_not_installed("readr")
  path <- withr::local_tempdir()
  local_fars_zip(path)

  data <- get_fars_zip(path = path)
  expect_identical(attr(data$accident$LATITUDE, "label"), "Latitude")

  data <- get_fars_zip(path = path, labels = FALSE, overwrite = FALSE)
  expect_null(attr(data$accident$LATITUDE, "label"))
})

test_that("get_fars_zip works", {
  skip_if_not_installed("readr")
  path <- withr::local_tempdir()

  paths <- get_fars_zip(year = 1978, read = FALSE, path = path)
  expect_named(paths, c("accident", "person", "vehicle"))
  expect_identical(unname(file.exists(paths)), c(TRUE, TRUE, TRUE))

  data <- get_fars_zip(year = 1978, path = path)
  expect_type(data, "list")
  expect_named(data, c("accident", "person", "vehicle"))
})

test_that("fix_latin1() converts text that isn't valid UTF-8 from Latin-1", {
  x <- c("Caf\xe9", "Plain", NA)
  expect_identical(fix_latin1(x), c("Café", "Plain", NA))
  expect_identical(fix_latin1(1:2), 1:2)
})
