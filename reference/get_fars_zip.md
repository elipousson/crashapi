# Download FARS data files as zipped CSV or SAS files

This function provides an alternative to
[`get_fars_year()`](https://elipousson.github.io/crashapi/reference/get_fars.md)
that downloads files directly from NHTSA FTP site. If read is `TRUE`,
the function reads a list containing data frames for each table
available in the selected year. If geometry is `TRUE`, the accident
table is converted to an sf object.

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
  labels = TRUE
)
```

## Arguments

- year:

  One or more years of data from 1975 to 2024. Each year is downloaded
  separately and, if `read = TRUE`, returned as a list named by year.
  Defaults to `getOption("crashapi.year", 2024)`.

- format:

  Format of zipped data tables ('csv' or 'sas'). Default: 'csv'. unzip
  and geo options are only supported if format is "csv".

- path:

  Path to download zip file. Set to
  [`getwd()`](https://rdrr.io/r/base/getwd.html) if `NULL` (default).

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

  If `TRUE`, unzip the downloaded file and read CSV files into a list of
  tables with each list item corresponding to one CSV file.

- geometry:

  If `TRUE`, convert the accident table to a sf object.

- overwrite:

  If `FALSE`, abort if file exists at the provided path. If `TRUE`,
  overwrite file.

- labels:

  If `TRUE` (default), add a `"label"` attribute to each column with a
  variable label from
  [fars_vars_labels](https://elipousson.github.io/crashapi/reference/fars_vars_labels.md).
  Labels are shown by [`View()`](https://rdrr.io/r/utils/View.html) in
  RStudio and Positron and used by packages such as gt and gtsummary.

## Value

Downloads zip file with CSV or SAS tables and returns the zip file path
invisibly if `read = FALSE`, or a list of data frames with one item for
each table (with the accident table converted to an sf object if
`geometry = TRUE`). If more than one year is provided, returns a named
vector of file paths or a list of lists named by year.
