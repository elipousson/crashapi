# get_fars_zip() errors for years without Puerto Rico data

    Code
      get_fars_zip(year = 1979, pr = TRUE)
    Condition
      Error in `get_fars_zip()`:
      ! Puerto Rico data is not available for 1979.
      i Puerto Rico data is available for 1978 and from 1980 onwards.

# get_fars_zip() errors before downloading SAS files to read

    Code
      get_fars_zip(year = 2024, format = "sas", read = TRUE)
    Condition
      Error in `get_fars_zip()`:
      ! `read = TRUE` is only supported when `format = "csv"`.
      i Set `read = FALSE` to download SAS files without reading them.

