# Get Crashes By Vehicle

This function returns a list of fatal crashes involving a specific
vehicle make, model, model year, and body type using the CrashAPI
GetCrashesByVehicle endpoint. The make, model, and body type can be
names or ID numbers matching the options returned by
[`fars_vars()`](https://elipousson.github.io/crashapi/reference/fars_vars.md).
Names are converted to ID numbers for use in the API query.

## Usage

``` r
get_fars_crash_vehicles(
  state,
  make,
  model,
  model_year,
  body_type,
  year = getOption("crashapi.year", 2024),
  var_labels = c("attribute", "none")
)
```

## Arguments

- state:

  Required. State name, abbreviation, or FIPS number.

- make:

  Required. Make name or ID, e.g. "Ford" or 12. Valid options are
  returned by `fars_vars(var = "make")` for the earliest year in `year`.

- model:

  Required. Model name or ID. Valid options are returned by
  `fars_vars(var = "model", make = make)`.

- model_year:

  Required. Vehicle model year.

- body_type:

  Required. Body type name or ID. Valid options are returned by
  `fars_vars(var = "bodytype", make = make, model = model)`.

- year:

  numeric vector. One or more years from 2010 to 2024. The minimum and
  maximum values are used as the start and end year. Defaults to
  `getOption("crashapi.year", 2024)`.

- var_labels:

  How to add variable labels from
  [fars_vars_labels](https://elipousson.github.io/crashapi/reference/fars_vars_labels.md):
  "attribute" (default) adds a `"label"` attribute to each column, which
  is shown by [`View()`](https://rdrr.io/r/utils/View.html) in RStudio
  and Positron and used by packages such as gt and gtsummary, and "none"
  doesn't add variable labels.

## API behavior

NHTSA's documentation says this endpoint accepts "one or more" vehicle
details for make, model, model year, and body type. However, testing in
October 2026 found that the API does not behave this way: the API
returns an error (HTTP 404) unless all four are provided and an error
message if any are blank. For this reason, `make`, `model`,
`model_year`, and `body_type` are all required.

To find crashes using other vehicle criteria, download the vehicle table
with
[`get_fars_year()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md)
using `type = "vehicle"` and filter the data.

## Examples

``` r
get_fars_crash_vehicles(
  state = "CA",
  make = "Ford",
  model = 37,
  model_year = 2012,
  body_type = 4,
  year = 2022
)
#>   BODY_TYP          BODY_TYPNAME CaseYear DAY HARM_EV
#> 1        4 4-door sedan, hardtop     2022   2      42
#> 2        4 4-door sedan, hardtop     2022   1      12
#>                  HARM_EVNAME HIT_RUN HIT_RUNNAME HOUR      HOURNAME J_KNIFE
#> 1       Tree (Standing Only)       0          No   18 6:00pm-6:59pm       0
#> 2 Motor Vehicle In-Transport       0          No    2 2:00am-2:59am       0
#>                  J_KNIFENAME MAKE MAK_MOD MAK_MODNAME MAN_COLL
#> 1 Not an Articulated Vehicle   12   12037  Ford Focus        0
#> 2 Not an Articulated Vehicle   12   12037  Ford Focus        1
#>                                                                    MAN_COLLNAME
#> 1 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 2                                                                 Front-to-Rear
#>   MCARR_I1   MCARR_I1NAME  MCARR_I2   MCARR_I2NAME    MCARR_ID   MCARR_IDNAME
#> 1       NA Not Applicable 000000000 Not Applicable 00000000000 Not Applicable
#> 2       NA Not Applicable 000000000 Not Applicable 00000000000 Not Applicable
#>   MINUTE MINUTENAME MODEL MOD_YEAR MOD_YEARNAME MONTH MONTHNAME NUMOCCS
#> 1     10         10    37     2012         2012     6      June       1
#> 2     24         24    37     2012         2012     1   January       1
#>   NUMOCCSNAME OWNER                                    OWNERNAME REG_STAT
#> 1          01     1 Driver (in this crash) was  Registered Owner        6
#> 2          01     1 Driver (in this crash) was  Registered Owner        6
#>   REG_STATNAME STATE  STATENAME ST_CASE TOW_VEH TOW_VEHNAME UNITTYPE
#> 1   California     6 California   60520       0 No Trailers        1
#> 2   California     6 California   60029       0 No Trailers        1
#>                                                    UNITTYPENAME VEH_NO VE_FORMS
#> 1 Motor Vehicle In-Transport (Inside or Outside the Trafficway)      1        1
#> 2 Motor Vehicle In-Transport (Inside or Outside the Trafficway)      2        2
#>            VIN VINNAME
#> 1 1FAHP3H27CL2      NA
#> 2 1FAHP3H29CL1      NA
```
