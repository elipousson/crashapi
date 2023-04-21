test_that("get_fars_zip works", {
  expect_true(
    file.exists(
      get_fars_zip(
        year = 1978,
        read = FALSE,
        path = tempdir(),
        overwrite = TRUE
      )
    )
  )
  data <-
    suppressWarnings(
      get_fars_zip(
        year = 1978,
        read = TRUE,
        path = tempdir(),
        overwrite = TRUE
      )
    )
  expect_type(
    data,
    "list"
  )
  expect_identical(
    names(data),
    c("accident", "person", "vehicle")
  )
})
