# get_fars_crash_vehicles() errors for missing or invalid values

    Code
      get_fars_crash_vehicles(state = "CA", make = 12, model = 37, body_type = 4)
    Condition
      Error in `get_fars_crash_vehicles()`:
      ! `model_year` is absent but must be supplied.

---

    Code
      get_fars_crash_vehicles(state = "CA", make = "Tesla", model = 37, model_year = 2012,
        body_type = 4)
    Condition
      Error in `get_fars_crash_vehicles()`:
      ! `make` must be a valid name or ID.
      x "Tesla" can't be found.
      i Use `fars_vars()` to list valid options.

