# Download CRSS data files as zipped CSV or SAS files

This function is similar to
[`get_fars_zip()`](https://elipousson.github.io/crashapi/reference/get_fars_zip.md)
to download files directly from NHTSA FTP site. If read is `TRUE`, the
function reads a list containing data frames for each table available in
the selected year. If geometry is `TRUE`, the accident table is
converted to an sf object.

## Usage

``` r
get_crss_zip(
  year = getOption("crashapi.year", 2024),
  format = "csv",
  path = NULL,
  aux = FALSE,
  read = TRUE,
  geometry = FALSE,
  overwrite = FALSE,
  labels = TRUE
)
```

## Arguments

- year:

  One or more years of data from 2016 to 2024. Each year is downloaded
  separately and, if `read = TRUE`, returned as a list named by year.
  Defaults to `getOption("crashapi.year", 2024)`.

- format:

  Format of zipped data tables ('csv' or 'sas'). Default: 'csv'. unzip
  and geo options are only supported if format is "csv".

- path:

  Path to download zip file. Set to
  [`getwd()`](https://rdrr.io/r/base/getwd.html) if `NULL` (default).

- aux:

  If `TRUE`, download auxiliary CRSS datasets .

- read:

  If `TRUE`, unzip the downloaded file and read CSV files into a list of
  tables with each list item corresponding to one CSV file.

- geometry:

  If `TRUE`, convert the accident table to a sf object.

- overwrite:

  If `FALSE`, abort if file exists at the provided path. If `TRUE`,
  overwrite file.

- labels:

  If `TRUE` (default), add a `"label"` attribute to each column with a
  matching variable in
  [fars_vars_labels](https://elipousson.github.io/crashapi/reference/fars_vars_labels.md).
  Labels are taken from the FARS Analytical User's Manual so variables
  only used in CRSS are not labelled.

## Value

Downloads zip file with CSV or SAS tables and returns the zip file path
invisibly if `read = FALSE`, or a list of data frames with one item for
each table (with the accident table converted to an sf object if
`geometry = TRUE`). If more than one year is provided, returns a named
vector of file paths or a list of lists named by year.
