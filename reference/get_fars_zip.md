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
  year = 2023,
  format = "csv",
  path = NULL,
  pr = FALSE,
  aux = FALSE,
  read = TRUE,
  geometry = FALSE,
  overwrite = FALSE
)
```

## Arguments

- year:

  Year of data from 1975 to 2024, Default: 2024

- format:

  Format of zipped data tables ('csv' or 'sas'). Default: 'csv'. unzip
  and geo options are only supported if format is "csv".

- path:

  Path to download zip file. Set to
  [`getwd()`](https://rdrr.io/r/base/getwd.html) if `NULL` (default).

- pr:

  If `TRUE`, download FARS data for Puerto Rico. No Puerto Rico data
  available for years 1975-1977. Default: `FALSE`

- aux:

  If `TRUE` and year is after 1982, download auxiliary FARS datasets
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

## Value

Downloads zip file with CSV or SAS tables and returns the zip file path
invisibly or returns a list of data frames (if geometry is `FALSE`), or
returns a list of data frames with the accident table converted to a sf
object.
