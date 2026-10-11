local_mocked_person_request <- function(env = parent.frame()) {
  query <- new.env()
  local_mocked_bindings(
    read_crashapi = function(...) {
      args <- list(...)
      for (nm in names(args)) {
        assign(nm, args[[nm]], envir = query)
      }
      data.frame(AGE = args$age)
    },
    .env = env
  )
  query
}

test_that("get_fars_crash_persons() converts names to codes", {
  query <- local_mocked_person_request()

  out <- get_fars_crash_persons(
    state = "MD",
    age = 30,
    sex = "female",
    seat = "front left",
    injury = "fatal",
    year = 2022
  )

  expect_identical(
    mget(c("age", "sex", "seatPos", "injurySeverity"), envir = query),
    list(age = 30L, sex = 2, seatPos = 11, injurySeverity = 4)
  )
  expect_identical(attr(out$AGE, "label"), "Age")
})

test_that("get_fars_crash_persons() accepts codes, attribute names, and aliases", {
  query <- local_mocked_person_request()

  get_fars_crash_persons(
    state = "MD",
    age = "45",
    sex = 1,
    seat = "Not a Motor Vehicle Occupant",
    injury = "K",
    year = 2022
  )

  expect_identical(
    mget(c("age", "sex", "seatPos", "injurySeverity"), envir = query),
    list(age = 45L, sex = 1L, seatPos = 0, injurySeverity = 4)
  )
})

test_that("get_fars_crash_persons() errors for missing or invalid values", {
  local_mocked_person_request()

  expect_snapshot(
    get_fars_crash_persons(state = "MD", age = 30, sex = "f", seat = 11),
    error = TRUE
  )
  expect_snapshot(
    get_fars_crash_persons(
      state = "MD",
      age = 30,
      sex = "other",
      seat = 11,
      injury = 4
    ),
    error = TRUE
  )
  expect_snapshot(
    get_fars_crash_persons(
      state = "MD",
      age = c(30, 31),
      sex = "f",
      seat = 11,
      injury = 4
    ),
    error = TRUE
  )
})
