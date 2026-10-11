# Download CRSS data files as zipped CSV or SAS files

The [Crash Report Sampling System
(CRSS)](https://www.nhtsa.gov/crash-data-systems/crash-report-sampling-system)
is a national sample of police-reported motor vehicle crashes of all
severities, from minor property damage to fatal crashes, and replaced
the General Estimates System (GES) in 2016. This function is similar to
[`get_fars_zip()`](https://elipousson.github.io/crashapi/reference/get_fars_zip.md)
to download CRSS files directly from the NHTSA downloads site. If `read`
is `TRUE`, the function returns a list containing data frames for each
table available in the selected year.

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
  keep_files = FALSE,
  labels = TRUE
)
```

## Arguments

- year:

  One or more years of data from 2016 to 2024. Each year is downloaded
  separately and, if `read = TRUE`, returned as a list named by year.
  Defaults to `getOption("crashapi.year", 2024)`.

- format:

  Format of zipped data tables ('csv' or 'sas'). Default: 'csv'.
  `read = TRUE` and `geometry = TRUE` are only supported if format is
  "csv".

- path:

  Directory for downloaded and cached files. If `NULL` (default), uses
  `getOption("crashapi.cache_dir")` or the user cache directory from
  `tools::R_user_dir("crashapi", "cache")`.

- aux:

  If `TRUE`, download auxiliary CRSS datasets.

- read:

  If `TRUE` (default), read the cached parquet files into a list of
  tables with each list item corresponding to one data file.

- geometry:

  Not supported for CRSS data, which does not include coordinates. If
  `TRUE`, a warning is shown and the accident table is returned as a
  data frame.

- overwrite:

  If `TRUE`, download the data and replace any cached files. Default:
  `FALSE`

- keep_files:

  If `TRUE`, keep the downloaded zip file and the extracted CSV files in
  the cache folder. Default: `FALSE`

- labels:

  If `TRUE` (default), add a `"label"` attribute to each column with a
  matching variable in
  [fars_vars_labels](https://elipousson.github.io/crashapi/reference/fars_vars_labels.md).
  Labels are taken from the FARS Analytical User's Manual so variables
  only used in CRSS are not labelled.

## Value

If `read = TRUE`, a list of data frames with one item for each table
(with the accident table converted to an sf object if
`geometry = TRUE`). If `read = FALSE`, the cached parquet file paths
named by table (or the zip file path if `format = "sas"`) invisibly. If
more than one year is provided, returns a list named by year.

## Details

CRSS is a sample, so national estimates should use the sampling weight
(`WEIGHT`) and survey design variables (e.g. `PSU_VAR` and `PSUSTRAT`)
as described in the CRSS Analytical User's Manual. CRSS data does not
include crash locations beyond broad geographic categories (e.g.
`REGION` and `URBANICITY`).

Zipped CSV files are converted to parquet files and cached in a folder
named after the zip file within `path` (by default, the user cache
directory from
[`tools::R_user_dir()`](https://rdrr.io/r/tools/userdir.html)), and the
zip and CSV files are removed unless `keep_files = TRUE`. Later calls
read the cached parquet files without downloading the data again unless
`overwrite = TRUE`.
