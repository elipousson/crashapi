# Get value labels for FARS and CRSS variables

`fars_value_labels()` returns the value labels (the decoded value for
each code) for variables in the FARS or CRSS data files by year. The
value labels are built from the SAS format programs and data files that
NHTSA publishes with the zipped SAS data for each year (see
`data-raw/fars_value_labels.R`).

## Usage

``` r
fars_value_labels(
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

A data frame with columns `source`, `year`, `table`, `variable`,
`format` (the SAS format name, without the year), `code` (as written in
the SAS format, e.g. "01"), `code_min` and `code_max` (numeric codes or
ranges), and `value` (the label).

## Details

Value labels change over time, so the same code can have a different
label in different years. For example, the `INJ_SEV` code 3 is labelled
"Incapacitating" in early FARS data and "Suspected Serious Injury (A)"
in recent years.

The CrashAPI and FARS zipped CSV files from 2015 onwards include `…NAME`
columns with decoded values. Use
[`decode_fars()`](https://elipousson.github.io/crashapi/reference/decode_fars.md)
to add these columns to older FARS data or CRSS data.

Labels from the SAS formats can differ slightly in wording from the
`…NAME` columns in the CSV files (e.g. "Curve - Right" instead of "Curve
Right" for `VALIGN`). A few variables use SAS formats that NHTSA doesn't
publish (e.g. a state variable in some 2006-2015 tables) and are not
included. Value labels for the FARS vPIC variables (e.g. `VPICMAKE` and
`VPICMODEL`, used from 2020 onwards) are not included since FARS data
already includes `…NAME` columns for these variables; they are included
for CRSS data.

## Examples

``` r
# Injury severity labels for the person table in 1985 and 2024
fars_value_labels(
  year = c(1985, 2024),
  table = "person",
  variable = "INJ_SEV"
)
#>    source year  table variable  format code code_min code_max
#> 1    FARS 1985 person  INJ_SEV FINJURY    0        0        0
#> 2    FARS 1985 person  INJ_SEV FINJURY    1        1        1
#> 3    FARS 1985 person  INJ_SEV FINJURY    2        2        2
#> 4    FARS 1985 person  INJ_SEV FINJURY    3        3        3
#> 5    FARS 1985 person  INJ_SEV FINJURY    4        4        4
#> 6    FARS 1985 person  INJ_SEV FINJURY    5        5        5
#> 7    FARS 1985 person  INJ_SEV FINJURY    6        6        6
#> 8    FARS 1985 person  INJ_SEV FINJURY    7        7        7
#> 9    FARS 1985 person  INJ_SEV FINJURY    9        9        9
#> 10   FARS 2024 person  INJ_SEV  INJURF   00        0        0
#> 11   FARS 2024 person  INJ_SEV  INJURF   01        1        1
#> 12   FARS 2024 person  INJ_SEV  INJURF   02        2        2
#> 13   FARS 2024 person  INJ_SEV  INJURF   03        3        3
#> 14   FARS 2024 person  INJ_SEV  INJURF   04        4        4
#> 15   FARS 2024 person  INJ_SEV  INJURF   05        5        5
#> 16   FARS 2024 person  INJ_SEV  INJURF   06        6        6
#> 17   FARS 2024 person  INJ_SEV  INJURF   09        9        9
#>                           value
#> 1                            No
#> 2                      Possible
#> 3                Non Incapacity
#> 4                Incapacitating
#> 5                  Fatal Injury
#> 6                  Inj, Sev Unk
#> 7        Died Prior to Accident
#> 8        Died Prior to Accident
#> 9                       Unknown
#> 10       No Apparent Injury (O)
#> 11          Possible Injury (C)
#> 12   Suspected Minor Injury (B)
#> 13 Suspected Serious Injury (A)
#> 14             Fatal Injury (K)
#> 15    Injured, Severity Unknown
#> 16         Died Prior to Crash*
#> 17         Unknown/Not Reported
```
