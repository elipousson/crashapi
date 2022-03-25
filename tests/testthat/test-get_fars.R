test_that("Test lookup_fips outputs", {
  expect_identical(lookup_fips(state = "MD"), 24L)
  expect_identical(lookup_fips(state = "MD", county = "Baltimore city"), 510L)
  expect_type(lookup_fips(state = "MD", county = "Baltimore city", list = TRUE), "list")
  expect_type(lookup_fips(state = "MD", int = FALSE), "character")
  expect_warning(lookup_fips(state = "XX"), "not a valid FIPS code or state name/abbreviation")
})


test_that("get_fars", {
  #   expect_error(get_fars(year = 2000), "Check on year is not TRUE")
  #  expect_error(get_fars(year = 2019, state = "XX", county = "Garrett County"), "A valid county name or FIPS is required")
  # expect_error(get_fars(year = 2019, state = "MD", api = "crashes"), "valid county name or FIPS")
  expect_type(get_fars(year = 2019, state = "MD", county = "Garrett County"), "list")
  expect_type(get_fars(year = 2019, state = "MD", county = "Garrett County", details = TRUE), "list")
  # expect_type(get_fars(year = 2019, state = "MD", api = "summary count"), "list")
  expect_type(get_fars(year = 2019, state = "MD", api = "state list", vehicles = 1), "list")
})


test_that("get_fars", {
  expect_error(get_fars(year = 2000), "Check on year is not TRUE")
  expect_error(get_fars(year = 2019, state = "MD", api = "crashes"), "A valid county name or FIPS is required")
  expect_type(get_fars(year = 2019, state = "MD", county = "Garrett County"), "list")
  expect_type(get_fars(year = 2019, state = "MD", county = "Garrett County", details = TRUE), "list")
  #  expect_type(get_fars(year = 2019, state = "MD", api = "summary count"), "list")
  expect_type(get_fars(year = 2019, state = "MD", api = "state list", vehicles = 1), "list")
  expect_type(get_fars(year = 2019, state = "MD", api = "state list", vehicles = 1), "list")
})


test_that("get_fars", {
  expect_error(get_fars(year = 2000), "Check on year is not TRUE")
  expect_error(get_fars(year = 2019, state = "MD", api = "crashes"), "A valid county name or FIPS is required")
  expect_type(get_fars(year = 2019, state = "MD", county = "Garrett County"), "list")
  expect_type(get_fars(year = 2019, state = "MD", county = "Garrett County", details = TRUE), "list")
  #  expect_type(get_fars(year = 2019, state = "MD", api = "summary count"), "list")
  expect_type(get_fars(year = 2019, state = "MD", api = "state list", vehicles = 1), "list")
  expect_type(get_fars(year = 2019, state = "MD", api = "state list", vehicles = 1), "list")
})


test_that("get_cases", {
  # Works with character and numeric inputs
  expect_s3_class(get_fars_cases(year = 2019, state = "MD", cases = "240063"), "data.frame")
  expect_s3_class(get_fars_cases(year = 2019, state = "MD", cases = 240063), "data.frame")
  expect_error(get_fars_cases(year = 2019, state = "MD", cases = "0"), "subscript out of bounds")

})
