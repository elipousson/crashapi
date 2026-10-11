test_that("Test lookup_fips outputs", {
  expect_identical(lookup_fips(state = "MD"), 24L)
  expect_identical(lookup_fips(state = "MD", county = "Baltimore city"), 510L)
  expect_type(
    lookup_fips(state = "MD", county = "Baltimore city", list = TRUE),
    "list"
  )
  expect_type(
    lookup_fips(state = "MD", int = FALSE),
    "character"
  )
  expect_identical(lookup_fips(c("MD", "VT"), several.ok = TRUE), c(24L, 50L))
  expect_snapshot(out <- lookup_fips(state = "XX"))
  expect_identical(out, integer(0))
})

test_that("validate_state and validate_county works", {
  expect_type(validate_state("MD", .msg = FALSE), "character")
  expect_type(validate_county("MD", "Garrett", .msg = FALSE), "character")
  expect_identical(validate_county("MD", 5, .msg = FALSE), "005")
  expect_identical(validate_county("CA", "Los Angeles", .msg = FALSE), "037")
  expect_snapshot(out <- validate_county("DC", "Garrett", .msg = FALSE))
  expect_null(out)
  expect_snapshot(out <- validate_county("MD", "Baltimore", .msg = FALSE))
  expect_identical(out, "005")
})

test_that("validate_state() returns FIPS codes for valid values", {
  expect_identical(validate_state(6, .msg = FALSE), "06")
  expect_identical(validate_state("Puerto Rico", .msg = FALSE), "72")
  expect_snapshot(
    out <- validate_state(c("MD", "XX"), multiple = TRUE, .msg = FALSE)
  )
  expect_identical(out, "24")
  expect_snapshot(validate_state(c("MD", "VT"), .msg = FALSE), error = TRUE)
})
