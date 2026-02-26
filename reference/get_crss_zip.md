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
  year = 2023,
  format = "csv",
  path = NULL,
  aux = FALSE,
  read = TRUE,
  geometry = FALSE,
  overwrite = FALSE
)
```

## Arguments

- year:

  Year of data from 2016 to 2023, Default: 2023

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

## Value

Downloads zip file with CSV or SAS tables and returns the zip file path
invisibly or returns a list of data frames (if geo is `FALSE`), or
returns a list of data frames with the accident table converted to a sf
object.
