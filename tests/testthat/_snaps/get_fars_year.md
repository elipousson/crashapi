# get_fars_year() returns data if geometry can't be added

    Code
      out <- get_fars_year(year = 2022, state = "VT", type = "person", format = "csv",
        geometry = TRUE)
    Condition
      Warning:
      Coordinate columns LONGITUD and LATITUDE can't be found in data of the type "PERSON".
      i Use `type = "accident"` with `geometry = TRUE` to return an sf object.

