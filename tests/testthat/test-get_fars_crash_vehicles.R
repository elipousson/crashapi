test_that("get_fars_crash_vehicles works", {
  expect_s3_class(
    get_fars_crash_vehicles(
      year = 2019,
      state = "CA",
      make = "12",
      model = "481",
      body_type = "34",
      model_year = 2018
    ),
    "data.frame"
  )
})
