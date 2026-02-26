# Read data from the CrashAPI using a url template

An updated utility function using the httr2 package to read data from
the CrashAPI using the API URL templates listed on the NHSTA website:
<https://crashviewer.nhtsa.dot.gov/crashviewer/CrashAPI>

## Usage

``` r
read_crashapi(
  url = "https://crashviewer.nhtsa.dot.gov/crashviewer/CrashAPI",
  data = "crashes",
  type = NULL,
  format = "json",
  results = TRUE,
  ...,
  cookie_file = "crashapi.cookies",
  call = caller_env()
)
```

## Arguments

- url:

  Base url for CrashAPI.

- data:

  Data (crashes, analytics, or fars), Default: 'crashes'

- type:

  Type of API to use, Default: `NULL`

- format:

  Format to return, Default: 'json'

- results:

  If `FALSE`, return formatted url, Default: `TRUE`

- ...:

  Additional parameters used in template (varies by type).

- call:

  The execution environment of a currently running function, e.g.
  `caller_env()`. The function will be mentioned in error messages as
  the source of the error. See the `call` argument of
  [`abort()`](https://rlang.r-lib.org/reference/abort.html) for more
  information.

## Value

Data frame with requested data or a formatted url (if `results = FALSE`)
