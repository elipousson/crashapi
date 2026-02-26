# Format crash data

Reorder columns to match the order documented in Fatality Analysis
Reporting System (FARS) Analytical User's Manual, 1975-2019 and append
derived columns for date, time, and datetime.

## Usage

``` r
format_crashes(x, details = TRUE)
```

## Arguments

- x:

  Data frame with crash data.

- details:

  If `TRUE`, append date, time, datetime columns to formatted crash
  data; defaults to TRUE
