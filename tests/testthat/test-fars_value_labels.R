test_that("fars_value_labels() returns labels that vary by year", {
  inj_sev <- fars_value_labels(
    year = c(1985, 2024),
    table = "person",
    variable = "INJ_SEV"
  )

  expect_named(
    inj_sev,
    c(
      "source",
      "year",
      "table",
      "variable",
      "format",
      "code",
      "code_min",
      "code_max",
      "value"
    )
  )
  expect_setequal(inj_sev$year, c(1985L, 2024L))
  expect_identical(
    inj_sev$value[inj_sev$year == 1985 & inj_sev$code_min == 3],
    "Incapacitating"
  )
  expect_identical(
    inj_sev$value[inj_sev$year == 2024 & inj_sev$code_min == 3],
    "Suspected Serious Injury (A)"
  )
})

test_that("fars_value_labels() covers FARS and CRSS years", {
  expect_setequal(unique(fars_value_labels(table = "accident")$year), 1975:2024)
  expect_setequal(
    unique(fars_value_labels(table = "accident", source = "CRSS")$year),
    2016:2024
  )
})

test_that("decode_fars() adds decoded columns by year", {
  person <- data.frame(
    CASEYEAR = c(1985, 2024),
    INJ_SEV = c(3, 3),
    SEX = c(1, 2)
  )

  out <- decode_fars(person, table = "person")
  expect_named(out, c("CASEYEAR", "INJ_SEV", "INJ_SEVNAME", "SEX", "SEXNAME"))
  expect_identical(
    out$INJ_SEVNAME,
    c("Incapacitating", "Suspected Serious Injury (A)")
  )
  expect_identical(out$SEXNAME, c("Male", "Female"))
})

test_that("decode_fars() keeps existing decoded columns", {
  person <- data.frame(CASEYEAR = 2024, INJ_SEV = 4, INJ_SEVNAME = "Fatal")

  expect_identical(decode_fars(person, table = "person"), person)
  expect_identical(
    decode_fars(person, table = "person", overwrite = TRUE)$INJ_SEVNAME,
    "Fatal Injury (K)"
  )
})

test_that("decode_fars() uses year if provided", {
  person <- data.frame(INJ_SEV = 3)

  expect_identical(
    decode_fars(person, table = "person", year = 1985)$INJ_SEVNAME,
    "Incapacitating"
  )
  expect_snapshot(decode_fars(person, table = "person"), error = TRUE)
})

test_that("get_fars() decodes data from zipped data files", {
  path <- withr::local_tempdir()
  local_mocked_bindings(
    get_fars_zip = function(year, ...) {
      file <- file.path(path, "person.parquet")
      nanoparquet::write_parquet(
        data.frame(STATE = 24, ST_CASE = 240001, INJ_SEV = 4),
        file
      )
      c(person = file)
    }
  )

  out <- get_fars("MD", year = 1985, type = "person", labels = FALSE)
  expect_identical(out$INJ_SEVNAME, "Fatal Injury")

  out <- get_fars(
    "MD",
    year = 1985,
    type = "person",
    decode = FALSE,
    labels = FALSE
  )
  expect_named(out, c("STATE", "ST_CASE", "INJ_SEV", "CASEYEAR"))
})
