
<!-- README.md is generated from README.Rmd. Please edit that file -->

# crashapi

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/crashapi)](https://CRAN.R-project.org/package=crashapi)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![License:
MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Codecov test
coverage](https://codecov.io/gh/elipousson/crashapi/branch/main/graph/badge.svg)](https://app.codecov.io/gh/elipousson/crashapi?branch=main)
<!-- badges: end -->

The goal of the crashapi R package is to provide functions for
downloading data from the National Highway Traffic Safety Administration
(NHTSA) [Fatality Analysis Reporting System (FARS)
API](https://crashviewer.nhtsa.dot.gov/CrashAPI/).

What is FARS? NHTSA explains: “The Fatality Analysis Reporting System
(FARS) contains data on all vehicle crashes in the United States that
occur on a public roadway and involve a fatality.”

Supported APIs for this package include:

-   [x] Get Crash List Information
-   [x] Get Crash Details
-   [x] Get Crashes By Location
-   [x] Get Crashes By Vehicle
-   [x] Get Summary Counts
-   [x] Get Variables and Get Variable Attributes
-   [x] Get FARS Data By Year
-   [x] Get Crashes By Occupant (partial support)

Most of these APIs support XML, JSV, CSV, and JSON output formats. This
package only uses JSON with the exception of get_fars_year (which
supports downloading CSV files).

For reference, this package also includes a list of terms and NHTSA
technical definitions in `fars_terms` and a list of variable labels in
`fars_vars_labels`.

The FARS API currently provides access to data from 2010 to 2020. The
`get_fars_zip` function can be used to access FARS data files from 1975
to 2020 that that are available for download on through [the NHTSA File
Downloads
site](https://www.nhtsa.gov/file-downloads?p=nhtsa/downloads/FARS/) as
zipped CSV or SAS files (not available through the NHTSA FARS API). This
site also provides extensive technical documentation on coding and use
of the FARS data files.

Earlier data along with data from the the [General Estimates
System](https://www.nhtsa.gov/national-automotive-sampling-system-nass/nass-general-estimates-system)
(GES) / [Crash Report Sampling
System](https://www.nhtsa.gov/crash-data-systems/crash-report-sampling-system-crss)
(CRSS) is also available through the [Fatality and Injury Reporting
System Tool](https://cdan.dot.gov/query) (FIRST).

The [NHTSA website](https://www-fars.nhtsa.dot.gov/Help/helplinks.aspx)
also provides additional information on the release data and version
status for the FARS data files:

| Data Year | File Version | Release Date      |
|-----------|--------------|-------------------|
| 2010      | Final        | December 11, 2012 |
| 2011      | Final        | November 13, 2013 |
| 2012      | Final        | December 12, 2013 |
| 2013      | Final        | December 14, 2014 |
| 2014      | Final        | December 18, 2015 |
| 2015      | Final        | December 16, 2016 |
| 2016      | Final        | December 14, 2017 |
| 2017      | Final        | December 18, 2018 |
| 2018      | Final        | June 24, 2021     |
| 2019      | Final        | March 2, 2022     |
| 2020      | Annual       | March 2, 2022     |

## Installation

You can install the development version of crashapi using the pak
package:

``` r
pak::pkg_install("elipousson/crashapi")
```

## Examples

``` r
library(crashapi)
library(ggplot2)
```

Most features for the package can be accessed using the `get_fars()`
function that selects the appropriate API-specific function based on the
provided parameters. You can also set the API to use with the `api`
parameter or use an API-specific function (e.g. `get_fars_summary()`).

For example, you can use the `get_fars()` access state-level summary
data on crash and fatality counts.

``` r
# Get summary crash count and fatality count data for Maryland from 2010 to 2019
md_summary <-
  get_fars(
    year = c(2010, 2020),
    state = "MD",
    api = "summary count"
  )

ggplot(md_summary, aes(x = CaseYear, y = TotalFatalCounts)) +
  geom_point(color = "red") +
  geom_line(color = "red", group = 1) +
  theme_minimal()
```

<img src="man/figures/README-get_fars_summary-1.png" width="100%" />

You can download crash data and set geometry to TRUE optionally convert
the data frame into an `sf` object for mapping.

``` r
crashes_sf <-
  get_fars(
  year = c(2018, 2020),
  state = "MD",
  county = "Baltimore city",
  geometry = TRUE
)

# Map crashes
ggplot() +
  geom_sf(
    data = mapbaltimore::baltimore_city,
    fill = NA, color = "black"
  ) +
  geom_sf(
    data = crashes_sf,
    aes(color = totalvehicles),
    alpha = 0.75
  ) +
  theme_void()
```

<img src="man/figures/README-map_fars_crashes-1.png" width="100%" />

You can list crashes and filter by the number of vehicles involved.

``` r
# Get fatal crashes in New York state from 2019 with 5 to 10 vehicles
get_fars(
  year = 2019,
  state = "NY",
  vehicles = c(5, 10)
)
#>      CountyName                  CrashDate Fatals Peds Persons St_Case State
#> 1     BRONX (5) /Date(1549865820000-0500)/      2    1       7  360042    36
#> 2     ERIE (29) /Date(1551915000000-0500)/      1    0       4  360159    36
#> 3   QUEENS (81) /Date(1561656240000-0400)/      1    0       6  360319    36
#> 4     BRONX (5) /Date(1561866000000-0400)/      1    0      11  360339    36
#> 5    KINGS (47) /Date(1564564080000-0400)/      1    0       5  360440    36
#> 6 SUFFOLK (103) /Date(1563792360000-0400)/      1    0       2  360551    36
#> 7   ORANGE (71) /Date(1558274040000-0400)/      1    0       1  360277    36
#>   StateName TotalVehicles
#> 1  New York             5
#> 2  New York             5
#> 3  New York             5
#> 4  New York             5
#> 5  New York             5
#> 6  New York             6
#> 7  New York             6
```

If you call `get_fars()` or `get_fars_crashes()` with details set to
TRUE, additional information from `get_fars_cases()` (including the
crash date and time) is appended to the crash data frame.

``` r
# Get fatal crashes for Anne Arundel County, MD for 2019 and append details
crashes_detailed <-
  get_fars(
  year = 2019,
  state = "MD",
  county = "Anne Arundel County",
  details = TRUE
)
#> ■■■                                5% | ETA:  1m
#> ■■■■■                             15% | ETA:  1m
#> ■■■■■■■                           20% | ETA:  1m
#> ■■■■■■■■■                         25% | ETA: 47s
#> ■■■■■■■■■■                        30% | ETA: 44s
#> ■■■■■■■■■■■                       35% | ETA: 41s
#> ■■■■■■■■■■■■■                     40% | ETA: 39s
#> ■■■■■■■■■■■■■■                    42% | ETA: 37s
#> ■■■■■■■■■■■■■■■                   48% | ETA: 34s
#> ■■■■■■■■■■■■■■■■■                 52% | ETA: 31s
#> ■■■■■■■■■■■■■■■■■■                57% | ETA: 27s
#> ■■■■■■■■■■■■■■■■■■■■              62% | ETA: 24s
#> ■■■■■■■■■■■■■■■■■■■■■             65% | ETA: 23s
#> ■■■■■■■■■■■■■■■■■■■■■■            70% | ETA: 19s
#> ■■■■■■■■■■■■■■■■■■■■■■■           75% | ETA: 16s
#> ■■■■■■■■■■■■■■■■■■■■■■■■■         80% | ETA: 13s
#> ■■■■■■■■■■■■■■■■■■■■■■■■■■■       85% | ETA: 10s
#> ■■■■■■■■■■■■■■■■■■■■■■■■■■■■      90% | ETA:  6s
#> ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■     92% | ETA:  5s
#> ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■    98% | ETA:  2s

# Show 10 fatal crashes at random
dplyr::slice_sample(crashes_detailed, n = 10)
#>    case_year totalvehicles state statename st_case       date  time
#> 1       2019             3    24  Maryland  240291 2019-09-12 08:00
#> 2       2019             2    24  Maryland  240389 2019-09-27 20:31
#> 3       2019             2    24  Maryland  240162 2019-06-07 14:36
#> 4       2019             1    24  Maryland  240302 2019-09-21 17:11
#> 5       2019             2    24  Maryland  240333 2019-08-26 11:57
#> 6       2019             1    24  Maryland  240119 2019-05-05 11:39
#> 7       2019             1    24  Maryland  240236 2019-07-30 17:54
#> 8       2019             2    24  Maryland  240429 2019-12-11 15:16
#> 9       2019             1    24  Maryland  240463 2019-01-05 23:42
#> 10      2019             2    24  Maryland  240116 2019-04-22 08:00
#>               datetime peds pernotmvit ve_total ve_forms pvh_invl
#> 1  2019-09-12 08:00:00    0          0        3        3        0
#> 2  2019-09-27 20:31:00    0          0        2        2        0
#> 3  2019-06-07 14:36:00    0          0        2        2        0
#> 4  2019-09-21 17:11:00    1          1        1        1        0
#> 5  2019-08-26 11:57:00    0          0        2        2        0
#> 6  2019-05-05 11:39:00    1          1        1        1        0
#> 7  2019-07-30 17:54:00    0          0        1        1        0
#> 8  2019-12-11 15:16:00    0          0        2        2        0
#> 9  2019-01-05 23:42:00    0          0        1        1        0
#> 10 2019-04-22 08:00:00    0          0        2        2        0
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 n_persons
#> 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    NULL
#> 2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    NULL
#> 3                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    NULL
#> 4  47, 47 Years, 97, Not a Motor Vehicle Occupant, 9, Not Reported, 200, 0.200 % BAC, 2, Test Given, 1, Blood, NA, NA, NA, 3, ANNE ARUNDEL (3), 2019, 21, 21, 21, 17, 17:00-17:59, 45, 45, 9, September, 1745, 1745, 2019, 2019, 0, Not Applicable, 9, Reported as Unknown, NA, NA, NA, NA, NA, NA, 9, Reported as Unknown, NA, NA, NA, NA, NA, NA, 8, Not Reported, 2, Test Given, 8, Not Applicable, 0, Ejection Path Not Applicable, NA, NA, 0, Not Extricated or Not Applicable, NA, NA, 3, Principal Arterial - Other, 8, Pedestrian, 8, Not a Motor Vehicle Occupant, 96, Not a Motor Vehicle Occupant, 7, Non-Hispanic, 5, EMS Ground, 17, 5:00pm-5:59pm, NA, NA, NA, NA, NA, NA, 4, Fatal Injury (K), 0, 0, 34, 34, 1, At Intersection - In Marked Crosswalk, NA, NA, NA, NA, 0, The First Harmful Event was Not a Collision with a Motor Vehicle in Transport, 11, 11, NA, NA, 9, September, NA, NA, 1, 5, Pedestrian, 0, None, 0, None, 0, None, NA, NA, NA, 8, Not a Motor Vehicle Occupant, 96, Not a Motor Vehicle Occupant, NA, NA, NA, NA, 2, Urban, NA, 0, No, 0, Not a Motor Vehicle Occupant, 1, Male, NA, NA, 24, Maryland, 1, NA, 240302, NA, NA, 0, 1, NA, NA, NA, NA, NA, NA, 0, No
#> 5                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    NULL
#> 6                   55, 55 Years, 97, Not a Motor Vehicle Occupant, 9, Not Reported, 130, 0.130 % BAC, 2, Test Given, 1, Blood, NA, NA, NA, 3, ANNE ARUNDEL (3), 2019, 5, 5, 5, 13, 13:00-13:59, 39, 39, 5, May, 1339, 1339, 2019, 2019, 0, Not Applicable, 9, Reported as Unknown, NA, NA, NA, NA, NA, NA, 9, Reported as Unknown, NA, NA, NA, NA, NA, NA, 8, Not Reported, 2, Test Given, 8, Not Applicable, 0, Ejection Path Not Applicable, NA, NA, 0, Not Extricated or Not Applicable, NA, NA, 3, Principal Arterial - Other, 9, Pedalcyclist, 8, Not a Motor Vehicle Occupant, 96, Not a Motor Vehicle Occupant, 7, Non-Hispanic, 5, EMS Ground, 11, 11:00am-11:59am, NA, NA, NA, NA, NA, NA, 4, Fatal Injury (K), 2, 2, 0, 0, 3, At Intersection - Not In Crosswalk, NA, NA, NA, NA, 0, The First Harmful Event was Not a Collision with a Motor Vehicle in Transport, 39, 39, NA, NA, 5, May, NA, NA, 1, 6, Bicyclist, 0, None, 0, None, 0, None, NA, NA, NA, 8, Not a Motor Vehicle Occupant, 96, Not a Motor Vehicle Occupant, NA, NA, NA, NA, 2, Urban, NA, 0, No, 0, Not a Motor Vehicle Occupant, 1, Male, NA, NA, 24, Maryland, 1, NA, 240119, NA, NA, 0, 1, NA, NA, NA, NA, NA, NA, 0, No
#> 7                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    NULL
#> 8                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    NULL
#> 9                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    NULL
#> 10                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   NULL
#>    persons permvit county       countyname city       cityname month month_name
#> 1        3       3      3 ANNE ARUNDEL (3)    0 NOT APPLICABLE     9  September
#> 2        3       3      3 ANNE ARUNDEL (3) 1415         SEVERN     9  September
#> 3        2       2      3 ANNE ARUNDEL (3)    0 NOT APPLICABLE     6       June
#> 4        1       1      3 ANNE ARUNDEL (3)    0 NOT APPLICABLE     9  September
#> 5        2       2      3 ANNE ARUNDEL (3)    0 NOT APPLICABLE     8     August
#> 6        1       1      3 ANNE ARUNDEL (3)    0 NOT APPLICABLE     5        May
#> 7        1       1      3 ANNE ARUNDEL (3)    0 NOT APPLICABLE     7       July
#> 8        2       2      3 ANNE ARUNDEL (3)    0 NOT APPLICABLE    12   December
#> 9        1       1      3 ANNE ARUNDEL (3)    0 NOT APPLICABLE     1    January
#> 10       2       2      3 ANNE ARUNDEL (3)    0 NOT APPLICABLE     4      April
#>    day day_week day_weekname year hour        hourname minute minutename
#> 1   12        5     Thursday 2019    8   8:00am-8:59am      0          0
#> 2   27        6       Friday 2019   20   8:00pm-8:59pm     31         31
#> 3    7        6       Friday 2019   14   2:00pm-2:59pm     36         36
#> 4   21        7     Saturday 2019   17   5:00pm-5:59pm     11         11
#> 5   26        2       Monday 2019   11 11:00am-11:59am     57         57
#> 6    5        1       Sunday 2019   11 11:00am-11:59am     39         39
#> 7   30        3      Tuesday 2019   17   5:00pm-5:59pm     54         54
#> 8   11        4    Wednesday 2019   15   3:00pm-3:59pm     16         16
#> 9    5        7     Saturday 2019   23 11:00pm-11:59pm     42         42
#> 10  22        2       Monday 2019    8   8:00am-8:59am      0          0
#>                tway_id             tway_id2 route     routename rur_urb
#> 1              CR-5461                 <NA>     4   County Road       2
#> 2  SR-175 ANNAPOLIS RD              CR-5454     3 State Highway       2
#> 3              CR-1178                 <NA>     4   County Road       2
#> 4       SR-3 CRAIN HWY CR-3828 CRAINMONT DR     3 State Highway       2
#> 5               SR-710              CR-3700     3 State Highway       2
#> 6                 SR-2               OP-226     3 State Highway       2
#> 7                CR-10                 <NA>     4   County Road       2
#> 8               SR-176               CR-597     3 State Highway       2
#> 9               SR-295                 <NA>     3 State Highway       2
#> 10              SR-450                 <NA>     3 State Highway       2
#>    rur_urbname func_sys               func_sysname rd_owner
#> 1        Urban        4             Minor Arterial        2
#> 2        Urban        4             Minor Arterial        1
#> 3        Urban        5            Major Collector        2
#> 4        Urban        3 Principal Arterial - Other        1
#> 5        Urban        4             Minor Arterial        1
#> 6        Urban        3 Principal Arterial - Other        1
#> 7        Urban        5            Major Collector        2
#> 8        Urban        4             Minor Arterial        1
#> 9        Urban        3 Principal Arterial - Other        1
#> 10       Urban        3 Principal Arterial - Other        1
#>             rd_ownername nhs                        nhsname sp_jur
#> 1  County Highway Agency   0 This section IS NOT on the NHS      0
#> 2   State Highway Agency   0 This section IS NOT on the NHS      0
#> 3  County Highway Agency   0 This section IS NOT on the NHS      0
#> 4   State Highway Agency   0 This section IS NOT on the NHS      0
#> 5   State Highway Agency   0 This section IS NOT on the NHS      0
#> 6   State Highway Agency   0 This section IS NOT on the NHS      0
#> 7  County Highway Agency   0 This section IS NOT on the NHS      0
#> 8   State Highway Agency   0 This section IS NOT on the NHS      0
#> 9   State Highway Agency   1     This section IS ON the NHS      1
#> 10  State Highway Agency   0 This section IS NOT on the NHS      0
#>                 sp_jurname milept mileptname    latitude latitudename
#> 1  No Special Jurisdiction      4          4 39.07551111  39.07551111
#> 2  No Special Jurisdiction     47         47 39.09596667  39.09596667
#> 3  No Special Jurisdiction     20         20 39.08629167  39.08629167
#> 4  No Special Jurisdiction     10         10 39.13292222  39.13292222
#> 5  No Special Jurisdiction      9          9 39.19551111  39.19551111
#> 6  No Special Jurisdiction    343        343 39.13838333  39.13838333
#> 7  No Special Jurisdiction      3          3 39.19875000  39.19875000
#> 8  No Special Jurisdiction     35         35 39.16266389  39.16266389
#> 9    National Park Service      0       None 39.11144722  39.11144722
#> 10 No Special Jurisdiction    102        102 38.98215833  38.98215833
#>         longitud  longitudname harm_ev                harm_evname man_coll
#> 1  -76.629047220 -76.629047220      12 Motor Vehicle In-Transport        7
#> 2  -76.720419440 -76.720419440      12 Motor Vehicle In-Transport        6
#> 3  -76.659530560 -76.659530560       1          Rollover/Overturn        0
#> 4  -76.636916670 -76.636916670       8                 Pedestrian        0
#> 5  -76.597869440 -76.597869440      12 Motor Vehicle In-Transport        2
#> 6  -76.600591670 -76.600591670       9               Pedalcyclist        0
#> 7  -76.672713890 -76.672713890      42       Tree (Standing Only)        0
#> 8  -76.668719440 -76.668719440      12 Motor Vehicle In-Transport        2
#> 9  -76.781183330 -76.781183330      42       Tree (Standing Only)        0
#> 10 -76.531572220 -76.531572220      12 Motor Vehicle In-Transport        6
#>                                                                     man_collname
#> 1                                                     Sideswipe - Same Direction
#> 2                                                                          Angle
#> 3  The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 4  The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 5                                                                 Front-to-Front
#> 6  The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 7  The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 8                                                                 Front-to-Front
#> 9  The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 10                                                                         Angle
#>    reljct1 reljct1name reljct2                reljct2name typ_int
#> 1        0          No       1               Non-Junction       1
#> 2        0          No       2               Intersection       3
#> 3        0          No       1               Non-Junction       1
#> 4        0          No       3       Intersection-Related       2
#> 5        0          No       2               Intersection       2
#> 6        0          No       2               Intersection       2
#> 7        0          No       1               Non-Junction       1
#> 8        0          No       2               Intersection       3
#> 9        0          No       5 Entrance/Exit Ramp Related       1
#> 10       0          No       8    Driveway Access Related       1
#>              typ_intname rel_road rel_roadname wrk_zone wrk_zonename lgt_cond
#> 1    Not an Intersection        1   On Roadway        0         None        1
#> 2         T-Intersection        1   On Roadway        0         None        3
#> 3    Not an Intersection        1   On Roadway        0         None        1
#> 4  Four-Way Intersection        1   On Roadway        0         None        1
#> 5  Four-Way Intersection        1   On Roadway        0         None        1
#> 6  Four-Way Intersection        1   On Roadway        0         None        1
#> 7    Not an Intersection        4  On Roadside        0         None        1
#> 8         T-Intersection        1   On Roadway        0         None        1
#> 9    Not an Intersection        3    On Median        0         None        3
#> 10   Not an Intersection        1   On Roadway        0         None        1
#>      lgt_condname weather weathername weather1 weather1name weather2
#> 1        Daylight       1       Clear        1        Clear        0
#> 2  Dark - Lighted       1       Clear        1        Clear        0
#> 3        Daylight       1       Clear        1        Clear        0
#> 4        Daylight       1       Clear        1        Clear        0
#> 5        Daylight       1       Clear        1        Clear        0
#> 6        Daylight       2        Rain        2         Rain        0
#> 7        Daylight       1       Clear        1        Clear        0
#> 8        Daylight       1       Clear        1        Clear        0
#> 9  Dark - Lighted       1       Clear        1        Clear        0
#> 10       Daylight      10      Cloudy       10       Cloudy        0
#>                            weather2name sch_bus sch_busname    rail
#> 1  No Additional Atmospheric Conditions       0          No 0000000
#> 2  No Additional Atmospheric Conditions       0          No 0000000
#> 3  No Additional Atmospheric Conditions       0          No 0000000
#> 4  No Additional Atmospheric Conditions       0          No 0000000
#> 5  No Additional Atmospheric Conditions       0          No 0000000
#> 6  No Additional Atmospheric Conditions       0          No 0000000
#> 7  No Additional Atmospheric Conditions       0          No 0000000
#> 8  No Additional Atmospheric Conditions       0          No 0000000
#> 9  No Additional Atmospheric Conditions       0          No 0000000
#> 10 No Additional Atmospheric Conditions       0          No 0000000
#>          railname not_hour not_hourname not_min not_minname arr_hour
#> 1  Not Applicable       99      Unknown      99     Unknown       99
#> 2  Not Applicable       99      Unknown      99     Unknown       99
#> 3  Not Applicable       99      Unknown      99     Unknown       99
#> 4  Not Applicable       99      Unknown      99     Unknown       99
#> 5  Not Applicable       99      Unknown      99     Unknown       99
#> 6  Not Applicable       99      Unknown      99     Unknown       99
#> 7  Not Applicable       99      Unknown      99     Unknown       99
#> 8  Not Applicable       99      Unknown      99     Unknown       99
#> 9  Not Applicable       99      Unknown      99     Unknown       99
#> 10 Not Applicable       99      Unknown      99     Unknown       99
#>                      arr_hourname arr_min                       arr_minname
#> 1  Unknown EMS Scene Arrival Hour      99 Unknown EMS Scene Arrival Minutes
#> 2  Unknown EMS Scene Arrival Hour      99 Unknown EMS Scene Arrival Minutes
#> 3  Unknown EMS Scene Arrival Hour      99 Unknown EMS Scene Arrival Minutes
#> 4  Unknown EMS Scene Arrival Hour      99 Unknown EMS Scene Arrival Minutes
#> 5  Unknown EMS Scene Arrival Hour      99 Unknown EMS Scene Arrival Minutes
#> 6  Unknown EMS Scene Arrival Hour      99 Unknown EMS Scene Arrival Minutes
#> 7  Unknown EMS Scene Arrival Hour      99 Unknown EMS Scene Arrival Minutes
#> 8  Unknown EMS Scene Arrival Hour      99 Unknown EMS Scene Arrival Minutes
#> 9  Unknown EMS Scene Arrival Hour      99 Unknown EMS Scene Arrival Minutes
#> 10 Unknown EMS Scene Arrival Hour      99 Unknown EMS Scene Arrival Minutes
#>    hosp_hr                      hosp_hrname hosp_mn
#> 1       99                          Unknown      99
#> 2       88 Not Applicable (Not Transported)      88
#> 3       88 Not Applicable (Not Transported)      88
#> 4       99                          Unknown      99
#> 5       99                          Unknown      99
#> 6       99                          Unknown      99
#> 7       99                          Unknown      99
#> 8       99                          Unknown      99
#> 9       88 Not Applicable (Not Transported)      88
#> 10      99                          Unknown      99
#>                          hosp_mnname cf1 cf1name cf2 cf2name cf3 cf3name fatals
#> 1  Unknown EMS Hospital Arrival Time   0    None   0    None   0    None      1
#> 2   Not Applicable (Not Transported)   0    None   0    None   0    None      1
#> 3   Not Applicable (Not Transported)   0    None   0    None   0    None      1
#> 4  Unknown EMS Hospital Arrival Time   0    None   0    None   0    None      1
#> 5  Unknown EMS Hospital Arrival Time   0    None   0    None   0    None      1
#> 6  Unknown EMS Hospital Arrival Time   0    None   0    None   0    None      1
#> 7  Unknown EMS Hospital Arrival Time   0    None   0    None   0    None      1
#> 8  Unknown EMS Hospital Arrival Time   0    None   0    None   0    None      1
#> 9   Not Applicable (Not Transported)   0    None   0    None   0    None      1
#> 10 Unknown EMS Hospital Arrival Time   0    None   0    None   0    None      1
#>    drunk_dr road_fnc road_fncname
#> 1         0       NA           NA
#> 2         1       NA           NA
#> 3         0       NA           NA
#> 4         0       NA           NA
#> 5         0       NA           NA
#> 6         0       NA           NA
#> 7         0       NA           NA
#> 8         0       NA           NA
#> 9         1       NA           NA
#> 10        0       NA           NA
#>                                                                                                                                                                                                                                            nm_crashes
#> 1                                                                                                                                                                                                                                                NULL
#> 2                                                                                                                                                                                                                                                NULL
#> 3                                                                                                                                                                                                                                                NULL
#> 4  2019, 2019, 2, 3, Failure to Yield Right-Of-Way, Failure to Obey Traffic Signs, Signals or Officer, 2, 3, Failure to Yield Right-Of-Way, Failure to Obey Traffic Signs, Signals or Officer, 1, 1, 24, 24, Maryland, Maryland, 240302, 240302, 0, 0
#> 5                                                                                                                                                                                                                                                NULL
#> 6  2019, 2019, 2, 3, Failure to Yield Right-Of-Way, Failure to Obey Traffic Signs, Signals or Officer, 2, 3, Failure to Yield Right-Of-Way, Failure to Obey Traffic Signs, Signals or Officer, 1, 1, 24, 24, Maryland, Maryland, 240119, 240119, 0, 0
#> 7                                                                                                                                                                                                                                                NULL
#> 8                                                                                                                                                                                                                                                NULL
#> 9                                                                                                                                                                                                                                                NULL
#> 10                                                                                                                                                                                                                                               NULL
#>                                                               nm_impairs
#> 1                                                                   NULL
#> 2                                                                   NULL
#> 3                                                                   NULL
#> 4  2019, 99, Reported as Unknown if Impaired, 1, 24, Maryland, 240302, 0
#> 5                                                                   NULL
#> 6  2019, 99, Reported as Unknown if Impaired, 1, 24, Maryland, 240119, 0
#> 7                                                                   NULL
#> 8                                                                   NULL
#> 9                                                                   NULL
#> 10                                                                  NULL
#>                                                        nm_priors
#> 1                                                           NULL
#> 2                                                           NULL
#> 3                                                           NULL
#> 4  2019, 3, Crossing Roadway, NA, NA, 1, 24, Maryland, 240302, 0
#> 5                                                           NULL
#> 6  2019, 3, Crossing Roadway, NA, NA, 1, 24, Maryland, 240119, 0
#> 7                                                           NULL
#> 8                                                           NULL
#> 9                                                           NULL
#> 10                                                          NULL
#>                                 safety_e_qs park_works
#> 1                                      NULL       NULL
#> 2                                      NULL       NULL
#> 3                                      NULL       NULL
#> 4  2019, NA, NA, 1, 24, Maryland, 240302, 0       NULL
#> 5                                      NULL       NULL
#> 6  2019, NA, NA, 1, 24, Maryland, 240119, 0       NULL
#> 7                                      NULL       NULL
#> 8                                      NULL       NULL
#> 9                                      NULL       NULL
#> 10                                     NULL       NULL
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            pb_types
#> 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              NULL
#> 2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              NULL
#> 3                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              NULL
#> 4  0, 0, Not a Cyclist, Not a Cyclist, 0, 0, Not a Cyclist, Not a Cyclist, 7, 7, Not a Cyclist, Not a Cyclist, 7, 7, Not a Cyclist, Not a Cyclist, 7, 7, Not a Cyclist, Not a Cyclist, 2019, 2019, 1, 1, Northbound, Northbound, 3, 3, Straight through, Straight through, 47, 47, 47 Years, 47 Years, 1, 1, Yes, Yes, 5, 5, Pedestrian, Pedestrian, 1, 1, Male, Male, 1, 1, Yes, Yes, 0, 0, None Noted, None Noted, 750, 750, Crossing Roadway - Vehicle Not Turning, Crossing Roadway - Vehicle Not Turning, 760, 760, Pedestrian Failed to Yield, Pedestrian Failed to Yield, 2, 2, Eastbound, Eastbound, 1, 1, Nearside, Nearside, 1, 1, At Intersection, At Intersection, 2, 2, Crosswalk Area, Crosswalk Area, 1a, 1a, Motorist traveling straight through - Crash Occurred on Near (Approach) Side of Intersection / Pedestrian within crosswalk area, traveled from motorist`s left, Motorist traveling straight through - Crash Occurred on Near (Approach) Side of Intersection / Pedestrian within crosswalk area, traveled from motorist`s left, 1, 1, 24, 24, Maryland, Maryland, 240302, 240302, 0, 1
#> 5                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              NULL
#> 6                                                                                                                                        158, 158, Bicyclist Failed to Yield - Signalized Intersection, Bicyclist Failed to Yield - Signalized Intersection, 153, 153, Bicyclist Ride Out - Signalized Intersection, Bicyclist Ride Out - Signalized Intersection, 2, 2, Facing Traffic, Facing Traffic, 1, 1, At Intersection, At Intersection, 1, 1, Travel Lane, Travel Lane, 2019, 2019, 7, 7, Not a Pedestrian, Not a Pedestrian, 7, 7, Not a Pedestrian, Not a Pedestrian, 55, 55, 55 Years, 55 Years, 0, 0, None Noted, None Noted, 6, 6, Bicyclist, Bicyclist, 1, 1, Male, Male, 0, 0, None Noted, None Noted, 0, 0, None Noted, None Noted, 0, 0, Not a Pedestrian, Not a Pedestrian, 0, 0, Not a Pedestrian, Not a Pedestrian, 7, 7, Not a Pedestrian, Not a Pedestrian, 7, 7, Not a Pedestrian, Not a Pedestrian, 7, 7, Not a Pedestrian, Not a Pedestrian, 77, 77, Not a Pedestrian, Not a Pedestrian, 7, 7, Not a Pedestrian, Not a Pedestrian, 1, 1, 24, 24, Maryland, Maryland, 240119, 240119, 0, 1
#> 7                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              NULL
#> 8                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              NULL
#> 9                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              NULL
#> 10                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             NULL
```

## Related packages and projects

-   [stats19](https://github.com/ropensci/stats19) “provides functions
    for downloading and formatting road crash data” from “the UK’s
    official road traffic casualty database, STATS19.”
-   [njtr1](https://github.com/gavinrozzi/njtr1): “An R interface to New
    Jersey traffic crash data reported on form NJTR-1.”
-   [nzcrash](https://github.com/nacnudus/nzcrash): “An R package to
    distribute New Zealand crash data in a convenient form.”
-   [GraphHopper Open Traffic
    Collection](https://github.com/graphhopper/open-traffic-collection):
    “Collections of URLs pointing to traffic information portals which
    contain open data or at least data which is free to use.”
-   [Open Crash Data
    Index](https://docs.google.com/spreadsheets/d/1rmn6GbHNkfWLLDEEmA87iuy2yHdh7hBybCTZiQJEY0k/edit?usp=sharing):
    A Google Sheet listing a range of city, county, regional and state
    sources for crash data including non-injury crashes as well as the
    fatal crashes available through the FARS API. Contributions for
    crash data from other U.S. cities and states are welcome.
