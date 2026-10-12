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

  out <- format_crashes(x, var_labels = "none")

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

test_that("label_fars_vars() prefers labels for the matching data file", {
  x <- data.frame(CDL_STAT = 1)

  expect_identical(
    attr(label_fars_vars(x)$CDL_STAT, "label"),
    "Commercial Motor Vehicle License Status"
  )
  expect_identical(
    attr(label_fars_vars(x, data_file = "PARKWORK")$CDL_STAT, "label"),
    "Commercial Motor Vehicle License Status (discontinued)"
  )
})

test_that("label_fars_vars() prefers labels for current variables", {
  x <- data.frame(HIT_RUN = 1)

  expect_identical(attr(label_fars_vars(x)$HIT_RUN, "label"), "Hit and Run")
  expect_identical(
    attr(label_fars_vars(x, data_file = "ACCIDENT")$HIT_RUN, "label"),
    "Hit and Run (discontinued)"
  )
})

test_that("label_fars_vars() matches names case-insensitively as a fallback", {
  out <- label_fars_vars(data.frame(CASEYEAR = 2022, Vehicles = 1))

  expect_identical(attr(out$CASEYEAR, "label"), "Case Year")
  # Vehicles has its own label so it is not matched to VEHICLES
  # ("Vehicles in Transport (discontinued)")
  expect_identical(attr(out$Vehicles, "label"), "Vehicles")
})

test_that("label_fars_vars() labels NAME columns from the coded variable", {
  out <- label_fars_vars(
    data.frame(BODY_TYP = 1, BODY_TYPNAME = "a", STATENAME = "b", ABCNAME = "c")
  )

  expect_identical(attr(out$BODY_TYPNAME, "label"), "Body Type (name)")
  expect_identical(attr(out$STATENAME, "label"), "State Name")
  expect_null(attr(out$ABCNAME, "label"))
})

test_that("label_fars_vars() labels nested list columns", {
  vehicle <- data.frame(BODY_TYP = 1)
  vehicle$Persons <- list(data.frame(AGE = 30))
  x <- data.frame(ST_CASE = 1)
  x$Vehicles <- list(vehicle)

  out <- label_fars_vars(x)
  out_vehicle <- out$Vehicles[[1]]

  expect_identical(attr(out_vehicle$BODY_TYP, "label"), "Body Type")
  expect_identical(attr(out_vehicle$Persons[[1]]$AGE, "label"), "Age")
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

  out <- format_crashes(x, var_labels = "none")
  expect_null(attr(out$FATALS, "label"))
})

test_that("read_crashapi() builds URLs with the current CrashAPI path", {
  expect_identical(
    read_crashapi(
      data = "analytics",
      type = "GetInjurySeverityCounts",
      fromCaseYear = 2014,
      toCaseYear = 2015,
      state = 1,
      results = FALSE
    ),
    "https://crashviewer.nhtsa.dot.gov/crashviewer/CrashAPI/analytics/GetInjurySeverityCounts?fromCaseYear=2014&toCaseYear=2015&state=1&format=json"
  )
})

test_that("read_crashapi() returns NULL for responses without results", {
  httr2::local_mocked_responses(function(req) {
    httr2::response_json(
      body = list(
        Count = 0,
        Message = "Object reference not set to an instance of an object.",
        Results = list(),
        SearchCriteria = ""
      )
    )
  })

  expect_snapshot(
    out <- read_crashapi(
      data = "definitions",
      type = "GetVariables",
      dataYear = 2020
    )
  )
  expect_null(out)
})

test_that("label_fars_vars() labels CrashAPI-only columns", {
  x <- data.frame(STATEINITIAL = "MD", NCSAMAKE = 12, TrackWidthIN = 60)
  x$VinDeriveds <- list(data.frame(SAEAutomationLevel_from = 0))

  out <- label_fars_vars(x, data_file = "VEHICLE")
  expect_identical(attr(out$STATEINITIAL, "label"), "State Abbreviation")
  expect_identical(attr(out$NCSAMAKE, "label"), "NCSA Make")
  expect_identical(attr(out$TrackWidthIN, "label"), "Track Width (Inches)")
  expect_identical(
    attr(out$VinDeriveds[[1]]$SAEAutomationLevel_from, "label"),
    "SAE Automation Level (From)"
  )
})

test_that("label_fars_vars() uses the SAS violatn table for VIOLATION data", {
  out <- label_fars_vars(
    data.frame(CASEYEAR = 2024, VIOLATION = 1),
    data_file = "VIOLATION"
  )
  expect_identical(attr(out$VIOLATION, "label"), "Citations Issued")
})
