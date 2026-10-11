test_that("format_crashes() reorders and adds date columns", {
  x <- data.frame(
    EXTRA = "a",
    MINUTE = "5",
    HOUR = "14",
    DAY = "3",
    MONTH = "7",
    YEAR = "2022",
    FATALS = "2",
    ST_CASE = "500001",
    STATE = "50"
  )

  out <- format_crashes(x, labels = FALSE)

  expect_identical(
    names(out)[1:4],
    c("STATE", "ST_CASE", "date", "time")
  )
  expect_identical(names(out)[[ncol(out)]], "EXTRA")
  expect_identical(out$FATALS, 2L)
  expect_identical(out$date, as.Date("2022-07-03"))
  expect_identical(out$time, "14:05")
  expect_identical(
    out$datetime,
    as.POSIXct("2022-07-03 14:05", tz = "UTC")
  )
})

test_that("format_crashes() returns data without FARS variables unchanged", {
  x <- data.frame(a = 1, b = "x")
  expect_identical(format_crashes(x), x)
})

test_that("format_crashes() adds variable labels", {
  x <- data.frame(
    ST_CASE = "500001",
    YEAR = "2022",
    MONTH = "7",
    DAY = "3",
    HOUR = "14",
    MINUTE = "5",
    FATALS = "2",
    EXTRA = "a"
  )

  out <- format_crashes(x)

  expect_identical(attr(out$ST_CASE, "label"), "Consecutive Number")
  expect_identical(attr(out$FATALS, "label"), "Fatalities")
  expect_identical(attr(out$date, "label"), "Crash date")
  expect_null(attr(out$EXTRA, "label"))

  out <- format_crashes(x, labels = FALSE)
  expect_null(attr(out$FATALS, "label"))
})
