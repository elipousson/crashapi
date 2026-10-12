# Add decoded value columns to FARS or CRSS data

`decode_fars()` adds a column with decoded values (e.g. `INJ_SEVNAME`
for `INJ_SEV`) after each coded variable in a FARS or CRSS data table,
using the value labels from
[`fars_value_labels()`](https://elipousson.github.io/crashapi/reference/fars_value_labels.md)
for the year of each row. Variables that already have a decoded column
(like the `…NAME` columns in data from the CrashAPI or FARS zipped CSV
files from 2015 onwards) are not changed unless `overwrite = TRUE`.

## Usage

``` r
decode_fars(
  x,
  table,
  year = NULL,
  decode = c("names", "replace", "labelled"),
  source = c("FARS", "CRSS"),
  suffix = "NAME",
  overwrite = FALSE
)
```

## Arguments

- x:

  A data frame with a FARS or CRSS data table, e.g. from
  [`get_fars()`](https://elipousson.github.io/crashapi/reference/get_fars.md),
  [`get_fars_zip()`](https://elipousson.github.io/crashapi/reference/get_fars_zip.md),
  or
  [`get_crss_zip()`](https://elipousson.github.io/crashapi/reference/get_crss_zip.md).

- table:

  Name of the FARS or CRSS data table (e.g. "accident", "person", or
  "vehicle").

- year:

  Year of the data. If `NULL` (default), uses the `CASEYEAR`,
  `CaseYear`, or `YEAR` column of `x`. Can be a single year or one year
  for each row of `x`.

- decode:

  How to decode values:

  - "names" (default) adds a column with decoded values after each coded
    variable (e.g. `INJ_SEVNAME` for `INJ_SEV`), matching the `…NAME`
    columns in data from the CrashAPI and FARS zipped CSV files from
    2015 onwards.

  - "replace" replaces the codes with a factor of decoded values (with
    levels in code order) and removes any existing `…NAME` column.
    Variables with values that don't have value labels (e.g. `AGE`,
    where only special codes like "Not Reported" have labels) are not
    replaced.

  - "labelled" keeps the codes and adds value labels with
    [`haven::labelled()`](https://haven.tidyverse.org/reference/labelled.html).
    A labelled vector has a single set of value labels so the value
    labels from the latest year in the data are used (with a warning if
    the value labels differ between years). Requires the haven package.

- source:

  Data source: "FARS" (default) or "CRSS".

- suffix:

  Suffix for the names of the decoded columns if `decode = "names"`.
  Default: "NAME".

- overwrite:

  If `TRUE` and `decode = "names"`, replace existing decoded columns.
  Default: `FALSE`.

## Value

`x` with additional columns of decoded values (`decode = "names"`),
factors of decoded values (`decode = "replace"`), or labelled vectors
(`decode = "labelled"`).

## Details

[`get_fars()`](https://elipousson.github.io/crashapi/reference/get_fars.md)
uses `decode_fars()` to add decoded columns to data from zipped FARS
data files before 2015.

## Examples

``` r
person <- data.frame(CASEYEAR = c(1985, 2024), INJ_SEV = c(3, 3))
decode_fars(person, table = "person")
#>   CASEYEAR INJ_SEV                  INJ_SEVNAME
#> 1     1985       3               Incapacitating
#> 2     2024       3 Suspected Serious Injury (A)

decode_fars(person, table = "person", decode = "replace")
#>   CASEYEAR                      INJ_SEV
#> 1     1985               Incapacitating
#> 2     2024 Suspected Serious Injury (A)
```
