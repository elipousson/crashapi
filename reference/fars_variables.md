# Get variable labels for FARS and CRSS variables

`fars_variables()` returns the variables in each FARS or CRSS data table
by year with the variable label and SAS format name from the SAS data
files that NHTSA publishes with the zipped SAS data for each year (see
`data-raw/fars_value_labels.R`). Variable labels can change over time
and include variables that are not in
[fars_vars_labels](https://elipousson.github.io/crashapi/reference/fars_vars_labels.md)
(e.g. variables added in recent years or only used in CRSS).

## Usage

``` r
fars_variables(
  year = NULL,
  table = NULL,
  variable = NULL,
  source = c("FARS", "CRSS")
)
```

## Arguments

- year:

  One or more years. If `NULL` (default), returns value labels for all
  years.

- table:

  One or more FARS or CRSS data table names (e.g. "accident", "person",
  or "vehicle"). Not case sensitive. If `NULL` (default), returns value
  labels for all tables.

- variable:

  One or more variable names (e.g. "INJ_SEV"). Not case sensitive. If
  `NULL` (default), returns value labels for all variables.

- source:

  Data source: "FARS" (default) or "CRSS".

## Value

A data frame with columns `source`, `year`, `table`, `variable`, `label`
(the variable label), and `format` (the SAS format name without the
year, or `NA` for variables without value labels).

## Examples

``` r
fars_variables(year = 2024, table = "person", variable = c("AGE", "INJ_SEV"))
#>   source year  table variable           label format
#> 1   FARS 2024 person      AGE             Age   AGEF
#> 2   FARS 2024 person  INJ_SEV Injury Severity INJURF
```
