test_that("validate_state and validate_county works", {
  expect_true("character" %in% class(validate_state("MD", .msg = FALSE)))
  expect_true("character" %in% class(validate_county("MD", "Garrett", .msg = FALSE)))
  expect_warning(validate_county("DC", "Garrett", .msg = FALSE), "'Garrett' is not a valid name for counties in District of Columbia")
})
