local_mocked_vehicle_options <- function(env = parent.frame()) {
  query <- new.env()
  local_mocked_bindings(
    fars_vars = function(year, var, make = NULL, model = NULL) {
      switch(
        var,
        "make" = data.frame(ID = c(12, 20), TEXT = c("Ford", "Chevrolet")),
        "model" = data.frame(ID = c(37, 481), MODELNAME = c("Focus", "Fusion")),
        "bodytype" = data.frame(
          BODY_ID = c(4, 34),
          BODY_DEF = c("Sedan", "SUV")
        )
      )
    },
    read_crashapi = function(...) {
      args <- list(...)
      for (nm in names(args)) {
        assign(nm, args[[nm]], envir = query)
      }
      data.frame(ST_CASE = 1)
    },
    .env = env
  )
  query
}

test_that("get_fars_crash_vehicles() converts names to IDs", {
  query <- local_mocked_vehicle_options()

  get_fars_crash_vehicles(
    state = "CA",
    make = "ford",
    model = "Focus",
    model_year = 2012,
    body_type = 4,
    year = 2022
  )

  expect_identical(
    mget(c("make", "model", "modelyear", "bodyType"), envir = query),
    list(make = "12", model = "37", modelyear = 2012L, bodyType = "4")
  )
})

test_that("get_fars_crash_vehicles() errors for missing or invalid values", {
  local_mocked_vehicle_options()

  expect_snapshot(
    get_fars_crash_vehicles(state = "CA", make = 12, model = 37, body_type = 4),
    error = TRUE
  )
  expect_snapshot(
    get_fars_crash_vehicles(
      state = "CA",
      make = "Tesla",
      model = 37,
      model_year = 2012,
      body_type = 4
    ),
    error = TRUE
  )
})

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
