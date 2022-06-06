test_that("fars_vars works", {
  # Works with numeric years
  expect_true("data.frame" %in% class(fars_vars(year = 2010, var = "make")))
  # Works with character years
  expect_true("data.frame" %in% class(fars_vars(year = "2010")))
  # Does not work with years outside of API range
  expect_error(fars_vars(year = 2001), "Check on 'year' failed")
  # Does not work if var = model and make is not provided
  # expect_error(fars_vars(year = 2010, var = "model"), "Error in open.connection")
  # Works if var is model and a make ID number is provided
  expect_true("data.frame" %in% class(fars_vars(year = 2010, var = "model", make = 54)))
  # Works if var is bodytype and a make and model ID number are both provided
  expect_true("data.frame" %in% class(fars_vars(year = 2010, var = "bodytype", make = 54, model = 37)))
})
