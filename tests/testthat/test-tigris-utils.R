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
  expect_warning(
    lookup_fips(state = "XX"),
    "not a valid FIPS code or state name/abbreviation"
  )
})

test_that("validate_state and validate_county works", {
  expect_type(validate_state("MD", .msg = FALSE), "character")
  expect_type(validate_county("MD", "Garrett", .msg = FALSE), "character")
  expect_warning(
    validate_county("DC", "Garrett", .msg = FALSE),
    "'Garrett' is not a valid name for counties in District of Columbia"
  )
})
