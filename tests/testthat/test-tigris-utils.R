test_that("validate_state and validate_county works", {
  expect_type(validate_state("MD", .msg = FALSE), "character")
  expect_type(validate_county("MD", "Garrett", .msg = FALSE), "character")
  expect_warning(
    validate_county("DC", "Garrett", .msg = FALSE),
    "'Garrett' is not a valid name for counties in District of Columbia"
  )
})
