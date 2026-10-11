# Format crash data

Reorder columns to match the order documented in Fatality Analysis
Reporting System (FARS) Analytical User's Manual, 1975-2019, convert
coordinate and count columns to numeric and integer values, and append
derived columns for date, time, and datetime. Column names are kept as
returned by the API.

## Usage

``` r
format_crashes(x, details = TRUE, labels = TRUE)
```

## Arguments

- x:

  Data frame with crash data.

- details:

  If `TRUE`, append date, time, datetime columns to formatted crash
  data; defaults to TRUE

- labels:

  If `TRUE` (default), add a `"label"` attribute to each column with a
  variable label from
  [fars_vars_labels](https://elipousson.github.io/crashapi/reference/fars_vars_labels.md).
  Labels are shown by [`View()`](https://rdrr.io/r/utils/View.html) in
  RStudio and Positron and used by packages such as gt and gtsummary.
