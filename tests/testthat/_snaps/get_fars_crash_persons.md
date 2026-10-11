# get_fars_crash_persons() errors for missing or invalid values

    Code
      get_fars_crash_persons(state = "MD", age = 30, sex = "f", seat = 11)
    Condition
      Error in `get_fars_crash_persons()`:
      ! `injury` is absent but must be supplied.

---

    Code
      get_fars_crash_persons(state = "MD", age = 30, sex = "other", seat = 11,
        injury = 4)
    Condition
      Error in `get_fars_crash_persons()`:
      ! `sex` must be a numeric code or one of "Male", "Female", "Not Reported", and "Reported as Unknown".
      x "other" is not a valid value.

---

    Code
      get_fars_crash_persons(state = "MD", age = c(30, 31), sex = "f", seat = 11,
      injury = 4)
    Condition
      Error in `get_fars_crash_persons()`:
      ! `age` must be a single number.

