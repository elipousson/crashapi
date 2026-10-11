# get_crss_zip() warns that geometry is not supported

    Code
      data <- get_crss_zip(year = 2024, path = path, geometry = TRUE)
    Condition
      Warning in `get_crss_zip()`:
      CRSS data for 2024 doesn't include coordinate columns so `geometry = TRUE` is ignored.

# get_crss_zip() errors for invalid years and reading SAS files

    Code
      get_crss_zip(year = 2015)
    Condition
      Error in `get_crss_zip()`:
      ! `year` must be greater than or equal to 2016.

---

    Code
      get_crss_zip(year = 2024, format = "sas", read = TRUE)
    Condition
      Error in `get_crss_zip()`:
      ! `read = TRUE` is only supported when `format = "csv"`.
      i Set `read = FALSE` to download SAS files without reading them.

