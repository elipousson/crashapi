# Download FARS data files as zipped CSV or SAS files

This function provides an alternative to
[`get_fars_year()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md)
that downloads files directly from the NHTSA downloads site. If `read`
is `TRUE`, the function returns a list containing data frames for each
table available in the selected year. If `geometry` is `TRUE`, the
accident table is converted to an sf object.

## Usage

``` r
get_fars_zip(
  year = getOption("crashapi.year", 2024),
  format = "csv",
  path = NULL,
  pr = FALSE,
  aux = FALSE,
  read = TRUE,
  geometry = FALSE,
  overwrite = FALSE,
  keep_files = FALSE,
  var_labels = c("attribute", "none")
)
```

## Arguments

- year:

  One or more years of data from 1975 to 2024. Each year is downloaded
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

- pr:

  If `TRUE`, download FARS data for Puerto Rico. Puerto Rico data is
  available for 1978 and from 1980 onwards. Default: `FALSE`

- aux:

  If `TRUE` and year is 1982 or later, download auxiliary FARS datasets
  that "contain data derived from the regular FARS/GES variables using
  NCSA analytical data classifications." In 2010, the NHTSA explained:
  "These classifications are widely used in NCSA publications and
  research. Many definitions such as "speeding-related" or "distracted
  driving" comprise a combination of variables whose names or attributes
  have changed over time. The derived variables in the auxiliary files
  incorporate these nuances, thus simplifying the use of standard
  classifications in any traffic safety research." Learn more from the
  FARS and GES Auxiliary Datasets Q & A:
  <https://crashstats.nhtsa.dot.gov/Api/Public/ViewPublication/811364>

- read:

  If `TRUE` (default), read the cached parquet files into a list of
  tables with each list item corresponding to one data file.

- geometry:

  If `TRUE`, convert the accident table to a sf object.

- overwrite:

  If `TRUE`, download the data and replace any cached files. Default:
  `FALSE`

- keep_files:

  If `TRUE`, keep the downloaded zip file and the extracted CSV files in
  the cache folder. Default: `FALSE`

- var_labels:

  How to add variable labels from
  [fars_vars_labels](https://elipousson.github.io/crashapi/reference/fars_vars_labels.md):
  "attribute" (default) adds a `"label"` attribute to each column, which
  is shown by [`View()`](https://rdrr.io/r/utils/View.html) in RStudio
  and Positron and used by packages such as gt and gtsummary, and "none"
  doesn't add variable labels.

## Value

If `read = TRUE`, a list of data frames with one item for each table
(with the accident table converted to an sf object if
`geometry = TRUE`). If `read = FALSE`, the cached parquet file paths
named by table (or the zip file path if `format = "sas"`) invisibly. If
more than one year is provided, returns a list named by year.

## Details

Zipped CSV files are converted to parquet files and cached in a folder
named after the zip file within `path` (by default, the user cache
directory from
[`tools::R_user_dir()`](https://rdrr.io/r/tools/userdir.html)), and the
zip and CSV files are removed unless `keep_files = TRUE`. Later calls
read the cached parquet files without downloading the data again unless
`overwrite = TRUE`.
