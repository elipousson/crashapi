test_that("fars_vars works", {
  with_mock_api({
    expect_GET(
      fars_vars(year = 2010, var = "make")
    )
  })

  skip_if_offline()
  # Works with numeric years
  expect_s3_class(fars_vars(year = 2010, var = "make"), "data.frame")
  # Works with character years
  expect_s3_class(fars_vars(year = "2010"), "data.frame")
  # Does not work with years outside of API range
  expect_error(fars_vars(year = 2001), "must be greater than or equal to")
  # Does not work if var = model and make is not provided
  # expect_error(fars_vars(year = 2010, var = "model"), "Error in open.connection")
  # Works if var is model and a make ID number is provided
  expect_s3_class(
    fars_vars(year = 2010, var = "model", make = 54),
    "data.frame"
  )
  # Works if var is bodytype and a make and model ID number are both provided
  expect_s3_class(
    fars_vars(year = 2010, var = "bodytype", make = 54, model = 37),
    "data.frame"
  )
})
