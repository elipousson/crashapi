test_that("get_fars works", {
  with_mock_api({
    expect_GET(
      get_fars(year = 2019, state = "MD", county = "Garrett County")
    )
    expect_GET(
      get_fars(
        year = 2019,
        state = "MD",
        county = "Garrett County",
        cases = 240063
      )
    )
    expect_GET(
      get_fars(
        year = 2019,
        state = "MD",
        county = "Garrett County",
        type = "ACCIDENT"
      )
    )
  })

  expect_s3_class(
    get_fars(year = 2019, state = "MD", vehicles = 5),
    "data.frame"
  )
  expect_s3_class(
    get_fars(year = 2019, state = "MD", county = "Garrett County"),
    "data.frame"
  )
  expect_s3_class(
    get_fars(
      year = 2019,
      state = "MD",
      county = "Garrett County",
      details = TRUE
    ),
    "data.frame"
  )
  expect_s3_class(
    get_fars(
      year = 2019,
      state = "MD",
      county = "Garrett County",
      cases = 240063
    ),
    "data.frame"
  )
  expect_s3_class(
    get_fars(
      year = 2019,
      state = "MD",
      county = "Garrett County",
      type = "ACCIDENT"
    ),
    "data.frame"
  )
  expect_s3_class(
    get_fars(year = 2019, state = "MD", api = "summary count"),
    "data.frame"
  )
  expect_s3_class(
    get_fars(year = 2019, state = "MD", api = "state list", vehicles = 1),
    "data.frame"
  )
})

test_that("get_fars warns and errors", {
  expect_warning(
    get_fars_crashes(year = 2022, state = "RI", county = "Bristol County"),
    "No records found with the provided parameters."
  )
  expect_message(
    get_fars_crashes(
      year = c(2010, 2020),
      state = "California",
      county = "Los Angeles"
    ),
    "Additional records may be available for this query."
  )
  expect_error(get_fars(year = 2000), "must be greater than or equal to")
  expect_error(
    get_fars(year = 2019, state = "MD", api = "crashes"),
    "must be a valid county name or FIPS code"
  )
})

test_that("get_cases works", {
  # Works with character and numeric inputs
  expect_s3_class(
    get_fars_cases(year = 2019, state = "MD", cases = "240063"),
    "data.frame"
  )
  expect_s3_class(
    get_fars_cases(year = 2019, state = "MD", cases = 240063),
    "data.frame"
  )
  expect_s3_class(
    get_fars_cases(
      year = 2019,
      state = "MD",
      cases = 240063,
      details = "events"
    ),
    "data.frame"
  )
  expect_s3_class(
    get_fars_cases(
      year = 2019,
      state = "MD",
      cases = 240063,
      details = "vehicles"
    ),
    "data.frame"
  )

  skip_if_not_installed("sf")
  expect_s3_class(
    get_fars_cases(
      year = 2019,
      state = "MD",
      cases = "240063",
      geometry = TRUE
    ),
    "sf"
  )
})

test_that("get_cases errors", {
  expect_error(
    get_fars_cases(year = 2019, state = "MD", cases = "0"),
    "subscript out of bounds"
  )
  expect_error(get_fars_cases(year = 2019, state = "MD"))
})

test_that("get_cases works", {
  # Works with character and numeric inputs
  expect_s3_class(
    get_fars_cases(year = 2019, state = "MD", cases = "240063"),
    "data.frame"
  )
  expect_s3_class(
    get_fars_cases(year = 2019, state = "MD", cases = 240063),
    "data.frame"
  )
  expect_s3_class(
    get_fars_cases(
      year = 2019,
      state = "MD",
      cases = 240063,
      details = "events"
    ),
    "data.frame"
  )
  expect_s3_class(
    get_fars_cases(
      year = 2019,
      state = "MD",
      cases = 240063,
      details = "vehicles"
    ),
    "data.frame"
  )

  skip_if_not_installed("sf")
  expect_s3_class(
    get_fars_crashes(
      year = 2022,
      state = "MD",
      county = "Garrett",
      geometry = TRUE
    ),
    "sf"
  )
})
