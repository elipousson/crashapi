
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
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
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
#> ■■■                                8% | ETA:  1m
#> ■■■■■■                            18% | ETA:  1m
#> ■■■■■■■■                          22% | ETA:  1m
#> ■■■■■■■■■                         28% | ETA: 47s
#> ■■■■■■■■■■                        30% | ETA: 45s
#> ■■■■■■■■■■■                       35% | ETA: 42s
#> ■■■■■■■■■■■■■                     40% | ETA: 39s
#> ■■■■■■■■■■■■■■■                   45% | ETA: 35s
#> ■■■■■■■■■■■■■■■■                  50% | ETA: 32s
#> ■■■■■■■■■■■■■■■■■                 55% | ETA: 29s
#> ■■■■■■■■■■■■■■■■■■■               60% | ETA: 25s
#> ■■■■■■■■■■■■■■■■■■■■■             65% | ETA: 22s
#> ■■■■■■■■■■■■■■■■■■■■■■            70% | ETA: 19s
#> ■■■■■■■■■■■■■■■■■■■■■■■           75% | ETA: 16s
#> ■■■■■■■■■■■■■■■■■■■■■■■■■         80% | ETA: 13s
#> ■■■■■■■■■■■■■■■■■■■■■■■■■■        82% | ETA: 11s
#> ■■■■■■■■■■■■■■■■■■■■■■■■■■■       88% | ETA:  8s
#> ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■     92% | ETA:  5s
#> ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■    98% | ETA:  2s

# Show 10 fatal crashes at random
dplyr::slice_sample(crashes_detailed, n = 10)
#>    case_year totalvehicles state statename st_case       date  time
#> 1       2019             2    24  Maryland  240265 2019-08-27 07:08
#> 2       2019             2    24  Maryland  240149 2019-06-02 13:07
#> 3       2019             1    24  Maryland  240236 2019-07-30 17:54
#> 4       2019             1    24  Maryland  240048 2019-02-20 18:25
#> 5       2019             1    24  Maryland  240319 2019-09-20 21:02
#> 6       2019             1    24  Maryland  240242 2019-06-29 23:14
#> 7       2019             1    24  Maryland  240366 2019-11-04 15:58
#> 8       2019             1    24  Maryland  240373 2019-11-10 18:10
#> 9       2019             2    24  Maryland  240429 2019-12-11 15:16
#> 10      2019             3    24  Maryland  240069 2019-03-15 01:26
#>               datetime peds pernotmvit ve_total ve_forms pvh_invl
#> 1  2019-08-27 07:08:00    0          0        2        2        0
#> 2  2019-06-02 13:07:00    0          0        2        2        0
#> 3  2019-07-30 17:54:00    0          0        1        1        0
#> 4  2019-02-20 18:25:00    1          1        1        1        0
#> 5  2019-09-20 21:02:00    0          0        1        1        0
#> 6  2019-06-29 23:14:00    1          1        1        1        0
#> 7  2019-11-04 15:58:00    0          0        1        1        0
#> 8  2019-11-10 18:10:00    1          1        1        1        0
#> 9  2019-12-11 15:16:00    0          0        2        2        0
#> 10 2019-03-15 01:26:00    0          0        3        3        0
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      n_persons
#> 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         NULL
#> 2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         NULL
#> 3                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         NULL
#> 4             26, 26 Years, 97, Not a Motor Vehicle Occupant, 9, Not Reported, 0, 0.000 % BAC, 2, Test Given, 1, Blood, NA, NA, NA, 3, ANNE ARUNDEL (3), 2019, 20, 20, 20, 18, 18:00-18:59, 43, 43, 2, February, 1843, 1843, 2019, 2019, 7, Died at Scene, 9, Reported as Unknown, NA, NA, NA, NA, NA, NA, 9, Reported as Unknown, NA, NA, NA, NA, NA, NA, 8, Not Reported, 2, Test Given, 8, Not Applicable, 0, Ejection Path Not Applicable, NA, NA, 0, Not Extricated or Not Applicable, NA, NA, 5, Major Collector, 8, Pedestrian, 8, Not a Motor Vehicle Occupant, 96, Not a Motor Vehicle Occupant, 7, Non-Hispanic, 0, Not Transported, 18, 6:00pm-6:59pm, NA, NA, NA, NA, NA, NA, 4, Fatal Injury (K), 0, 0, 18, 18, 11, Not at Intersection - On Roadway, Not in Marked Crosswalk, NA, NA, NA, NA, 0, The First Harmful Event was Not a Collision with a Motor Vehicle in Transport, 25, 25, NA, NA, 2, February, NA, NA, 1, 5, Pedestrian, 0, None, 0, None, 0, None, NA, NA, NA, 8, Not a Motor Vehicle Occupant, 96, Not a Motor Vehicle Occupant, NA, NA, NA, NA, 2, Urban, NA, 0, No, 0, Not a Motor Vehicle Occupant, 1, Male, NA, NA, 24, Maryland, 1, NA, 240048, NA, NA, 0, 1, NA, NA, NA, NA, NA, NA, 0, No
#> 5                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         NULL
#> 6         32, 32 Years, 97, Not a Motor Vehicle Occupant, 9, Not Reported, 0, 0.000 % BAC, 2, Test Given, 1, Blood, NA, NA, NA, 3, ANNE ARUNDEL (3), 2019, 29, 29, 29, 23, 23:00-23:59, 32, 32, 6, June, 2332, 2332, 2019, 2019, 7, Died at Scene, 8, Not Reported, NA, NA, NA, NA, NA, NA, 0, No (drugs not involved), NA, NA, NA, NA, NA, NA, 1, Evidential Test (Blood, Urine), 2, Test Given, 8, Not Applicable, 0, Ejection Path Not Applicable, NA, NA, 0, Not Extricated or Not Applicable, NA, NA, 1, Interstate, 8, Pedestrian, 8, Not a Motor Vehicle Occupant, 96, Not a Motor Vehicle Occupant, 7, Non-Hispanic, 0, Not Transported, 23, 11:00pm-11:59pm, NA, NA, NA, NA, NA, NA, 4, Fatal Injury (K), 0, 0, 18, 18, 11, Not at Intersection - On Roadway, Not in Marked Crosswalk, NA, NA, NA, NA, 0, The First Harmful Event was Not a Collision with a Motor Vehicle in Transport, 14, 14, NA, NA, 6, June, NA, NA, 1, 5, Pedestrian, 0, None, 0, None, 0, None, NA, NA, NA, 8, Not a Motor Vehicle Occupant, 96, Not a Motor Vehicle Occupant, NA, NA, NA, NA, 2, Urban, NA, 0, No, 0, Not a Motor Vehicle Occupant, 1, Male, NA, NA, 24, Maryland, 1, NA, 240242, NA, NA, 0, 1, NA, NA, NA, NA, NA, NA, 0, No
#> 7                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         NULL
#> 8  50, 50 Years, 97, Not a Motor Vehicle Occupant, 9, Not Reported, 130, 0.130 % BAC, 2, Test Given, 1, Blood, NA, NA, NA, 3, ANNE ARUNDEL (3), 2019, 10, 10, 10, 18, 18:00-18:59, 25, 25, 11, November, 1825, 1825, 2019, 2019, 7, Died at Scene, 1, Yes (Alcohol Involved), NA, NA, NA, NA, NA, NA, 8, Not Reported, NA, NA, NA, NA, NA, NA, 8, Not Reported, 2, Test Given, 8, Not Applicable, 0, Ejection Path Not Applicable, NA, NA, 0, Not Extricated or Not Applicable, NA, NA, 3, Principal Arterial - Other, 8, Pedestrian, 8, Not a Motor Vehicle Occupant, 96, Not a Motor Vehicle Occupant, 7, Non-Hispanic, 0, Not Transported, 18, 6:00pm-6:59pm, NA, NA, NA, NA, NA, NA, 4, Fatal Injury (K), 0, 0, 15, 15, 11, Not at Intersection - On Roadway, Not in Marked Crosswalk, NA, NA, NA, NA, 0, The First Harmful Event was Not a Collision with a Motor Vehicle in Transport, 10, 10, NA, NA, 11, November, NA, NA, 1, 5, Pedestrian, 0, None, 0, None, 0, None, NA, NA, NA, 8, Not a Motor Vehicle Occupant, 96, Not a Motor Vehicle Occupant, NA, NA, NA, NA, 2, Urban, NA, 0, No, 0, Not a Motor Vehicle Occupant, 1, Male, NA, NA, 24, Maryland, 1, NA, 240373, NA, NA, 0, 1, NA, NA, NA, NA, NA, NA, 0, No
#> 9                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         NULL
#> 10                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        NULL
#>    persons permvit county       countyname city       cityname month month_name
#> 1        2       2      3 ANNE ARUNDEL (3)    0 NOT APPLICABLE     8     August
#> 2        3       3      3 ANNE ARUNDEL (3)    0 NOT APPLICABLE     6       June
#> 3        1       1      3 ANNE ARUNDEL (3)    0 NOT APPLICABLE     7       July
#> 4        2       2      3 ANNE ARUNDEL (3)    0 NOT APPLICABLE     2   February
#> 5        4       4      3 ANNE ARUNDEL (3)    0 NOT APPLICABLE     9  September
#> 6        1       1      3 ANNE ARUNDEL (3)    0 NOT APPLICABLE     6       June
#> 7        1       1      3 ANNE ARUNDEL (3)    0 NOT APPLICABLE    11   November
#> 8        1       1      3 ANNE ARUNDEL (3)    0 NOT APPLICABLE    11   November
#> 9        2       2      3 ANNE ARUNDEL (3)    0 NOT APPLICABLE    12   December
#> 10       6       6      3 ANNE ARUNDEL (3)    0 NOT APPLICABLE     3      March
#>    day day_week day_weekname year hour        hourname minute minutename
#> 1   27        3      Tuesday 2019    7   7:00am-7:59am      8          8
#> 2    2        1       Sunday 2019   13   1:00pm-1:59pm      7          7
#> 3   30        3      Tuesday 2019   17   5:00pm-5:59pm     54         54
#> 4   20        4    Wednesday 2019   18   6:00pm-6:59pm     25         25
#> 5   20        6       Friday 2019   21   9:00pm-9:59pm      2          2
#> 6   29        7     Saturday 2019   23 11:00pm-11:59pm     14         14
#> 7    4        2       Monday 2019   15   3:00pm-3:59pm     58         58
#> 8   10        1       Sunday 2019   18   6:00pm-6:59pm     10         10
#> 9   11        4    Wednesday 2019   15   3:00pm-3:59pm     16         16
#> 10  15        6       Friday 2019    1   1:00am-1:59am     26         26
#>        tway_id tway_id2 route     routename rur_urb rur_urbname func_sys
#> 1      CR-5461     <NA>     4   County Road       2       Urban        4
#> 2        SR-10     <NA>     3 State Highway       2       Urban        2
#> 3        CR-10     <NA>     4   County Road       2       Urban        5
#> 4      CR-2633     <NA>     4   County Road       2       Urban        5
#> 5      CR-3549     <NA>     4   County Road       2       Urban        5
#> 6       I-895B     <NA>     1    Interstate       2       Urban        1
#> 7  SR-176 RAMP     <NA>     3 State Highway       2       Urban        4
#> 8         SR-2     <NA>     3 State Highway       2       Urban        3
#> 9       SR-176   CR-597     3 State Highway       2       Urban        4
#> 10       I-195     <NA>     1    Interstate       2       Urban        1
#>                                           func_sysname rd_owner
#> 1                                       Minor Arterial        2
#> 2  Principal Arterial - Other Freeways and Expressways        1
#> 3                                      Major Collector        2
#> 4                                      Major Collector        2
#> 5                                      Major Collector        2
#> 6                                           Interstate        1
#> 7                                       Minor Arterial        1
#> 8                           Principal Arterial - Other        1
#> 9                                       Minor Arterial        1
#> 10                                          Interstate        1
#>             rd_ownername nhs                        nhsname sp_jur
#> 1  County Highway Agency   0 This section IS NOT on the NHS      0
#> 2   State Highway Agency   0 This section IS NOT on the NHS      0
#> 3  County Highway Agency   0 This section IS NOT on the NHS      0
#> 4  County Highway Agency   0 This section IS NOT on the NHS      0
#> 5  County Highway Agency   0 This section IS NOT on the NHS      0
#> 6   State Highway Agency   1     This section IS ON the NHS      0
#> 7   State Highway Agency   0 This section IS NOT on the NHS      0
#> 8   State Highway Agency   0 This section IS NOT on the NHS      0
#> 9   State Highway Agency   0 This section IS NOT on the NHS      0
#> 10  State Highway Agency   1     This section IS ON the NHS      0
#>                 sp_jurname milept mileptname    latitude latitudename
#> 1  No Special Jurisdiction     20         20 39.09671667  39.09671667
#> 2  No Special Jurisdiction     50         50 39.17210278  39.17210278
#> 3  No Special Jurisdiction      3          3 39.19875000  39.19875000
#> 4  No Special Jurisdiction     12         12 39.02736667  39.02736667
#> 5  No Special Jurisdiction     73         73 38.81967778  38.81967778
#> 6  No Special Jurisdiction      0       None 39.22533056  39.22533056
#> 7  No Special Jurisdiction    147        147 39.16499167  39.16499167
#> 8  No Special Jurisdiction    275        275 39.05690556  39.05690556
#> 9  No Special Jurisdiction     35         35 39.16266389  39.16266389
#> 10 No Special Jurisdiction     26         26 39.21617222  39.21617222
#>         longitud  longitudname harm_ev                harm_evname man_coll
#> 1  -76.624222220 -76.624222220      12 Motor Vehicle In-Transport        6
#> 2  -76.608405560 -76.608405560      12 Motor Vehicle In-Transport        6
#> 3  -76.672713890 -76.672713890      42       Tree (Standing Only)        0
#> 4  -76.708527780 -76.708527780       8                 Pedestrian        0
#> 5  -76.690894440 -76.690894440      42       Tree (Standing Only)        0
#> 6  -76.624466670 -76.624466670       8                 Pedestrian        0
#> 7  -76.642452780 -76.642452780      42       Tree (Standing Only)        0
#> 8  -76.527052780 -76.527052780       8                 Pedestrian        0
#> 9  -76.668719440 -76.668719440      12 Motor Vehicle In-Transport        2
#> 10 -76.698411110 -76.698411110      12 Motor Vehicle In-Transport        2
#>                                                                     man_collname
#> 1                                                                          Angle
#> 2                                                                          Angle
#> 3  The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 4  The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 5  The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 6  The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 7  The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 8  The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 9                                                                 Front-to-Front
#> 10                                                                Front-to-Front
#>    reljct1 reljct1name reljct2                reljct2name typ_int
#> 1        0          No       8    Driveway Access Related       1
#> 2        0          No       1               Non-Junction       1
#> 3        0          No       1               Non-Junction       1
#> 4        0          No       1               Non-Junction       1
#> 5        0          No       1               Non-Junction       1
#> 6        0          No       1               Non-Junction       1
#> 7        0          No       5 Entrance/Exit Ramp Related       1
#> 8        0          No       1               Non-Junction       1
#> 9        0          No       2               Intersection       3
#> 10       0          No       1               Non-Junction       1
#>            typ_intname rel_road rel_roadname wrk_zone wrk_zonename lgt_cond
#> 1  Not an Intersection        1   On Roadway        0         None        1
#> 2  Not an Intersection        1   On Roadway        0         None        1
#> 3  Not an Intersection        4  On Roadside        0         None        1
#> 4  Not an Intersection        1   On Roadway        0         None        2
#> 5  Not an Intersection        4  On Roadside        0         None        3
#> 6  Not an Intersection        1   On Roadway        0         None        2
#> 7  Not an Intersection        4  On Roadside        0         None        1
#> 8  Not an Intersection        1   On Roadway        0         None        2
#> 9       T-Intersection        1   On Roadway        0         None        1
#> 10 Not an Intersection        1   On Roadway        0         None        2
#>          lgt_condname weather  weathername weather1 weather1name weather2
#> 1            Daylight      10       Cloudy       10       Cloudy        0
#> 2            Daylight       1        Clear        1        Clear        0
#> 3            Daylight       1        Clear        1        Clear        0
#> 4  Dark - Not Lighted       4         Snow        4         Snow        0
#> 5      Dark - Lighted       1        Clear        1        Clear        0
#> 6  Dark - Not Lighted       2         Rain        2         Rain        0
#> 7            Daylight       1        Clear        1        Clear        0
#> 8  Dark - Not Lighted       1        Clear        1        Clear        0
#> 9            Daylight       1        Clear        1        Clear        0
#> 10 Dark - Not Lighted      98 Not Reported       98 Not Reported        0
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
#> 6  Unknown EMS Scene Arrival Hour      98                Unknown if Arrived
#> 7  Unknown EMS Scene Arrival Hour      99 Unknown EMS Scene Arrival Minutes
#> 8  Unknown EMS Scene Arrival Hour      99 Unknown EMS Scene Arrival Minutes
#> 9  Unknown EMS Scene Arrival Hour      99 Unknown EMS Scene Arrival Minutes
#> 10 Unknown EMS Scene Arrival Hour      99 Unknown EMS Scene Arrival Minutes
#>    hosp_hr                      hosp_hrname hosp_mn
#> 1       88 Not Applicable (Not Transported)      88
#> 2       99                          Unknown      99
#> 3       99                          Unknown      99
#> 4       88 Not Applicable (Not Transported)      88
#> 5       99                          Unknown      99
#> 6       88 Not Applicable (Not Transported)      88
#> 7       88 Not Applicable (Not Transported)      88
#> 8       88 Not Applicable (Not Transported)      88
#> 9       99                          Unknown      99
#> 10      99                          Unknown      99
#>                          hosp_mnname cf1 cf1name cf2 cf2name cf3 cf3name fatals
#> 1   Not Applicable (Not Transported)   0    None   0    None   0    None      1
#> 2  Unknown EMS Hospital Arrival Time   0    None   0    None   0    None      1
#> 3  Unknown EMS Hospital Arrival Time   0    None   0    None   0    None      1
#> 4   Not Applicable (Not Transported)   0    None   0    None   0    None      1
#> 5  Unknown EMS Hospital Arrival Time   0    None   0    None   0    None      1
#> 6   Not Applicable (Not Transported)   0    None   0    None   0    None      1
#> 7   Not Applicable (Not Transported)   0    None   0    None   0    None      1
#> 8   Not Applicable (Not Transported)   0    None   0    None   0    None      1
#> 9  Unknown EMS Hospital Arrival Time   0    None   0    None   0    None      1
#> 10 Unknown EMS Hospital Arrival Time   0    None   0    None   0    None      1
#>    drunk_dr road_fnc road_fncname
#> 1         0       NA           NA
#> 2         0       NA           NA
#> 3         0       NA           NA
#> 4         0       NA           NA
#> 5         0       NA           NA
#> 6         0       NA           NA
#> 7         0       NA           NA
#> 8         0       NA           NA
#> 9         0       NA           NA
#> 10        1       NA           NA
#>                                                                                                                                                                                                                                                                                                            nm_crashes
#> 1                                                                                                                                                                                                                                                                                                                NULL
#> 2                                                                                                                                                                                                                                                                                                                NULL
#> 3                                                                                                                                                                                                                                                                                                                NULL
#> 4                                          2019, 2019, 4, 9, In Roadway Improperly (Standing, Lying, Working, Playing, etc.), Wrong-Way Riding or Walking, 4, 9, In Roadway Improperly (Standing, Lying, Working, Playing, etc.), Wrong-Way Riding or Walking, 1, 1, 24, 24, Maryland, Maryland, 240048, 240048, 0, 0
#> 5                                                                                                                                                                                                                                                                                                                NULL
#> 6  2019, 2019, 4, 19, In Roadway Improperly (Standing, Lying, Working, Playing, etc.), Not Visible (Dark clothing, No Lighting, etc.), 4, 19, In Roadway Improperly (Standing, Lying, Working, Playing, etc.), Not Visible (Dark clothing, No Lighting, etc.), 1, 1, 24, 24, Maryland, Maryland, 240242, 240242, 0, 0
#> 7                                                                                                                                                                                                                                                                                                                NULL
#> 8                                                                                                                                                                                                                2019, 2, Failure to Yield Right-Of-Way, 2, Failure to Yield Right-Of-Way, 1, 24, Maryland, 240373, 0
#> 9                                                                                                                                                                                                                                                                                                                NULL
#> 10                                                                                                                                                                                                                                                                                                               NULL
#>                                                               nm_impairs
#> 1                                                                   NULL
#> 2                                                                   NULL
#> 3                                                                   NULL
#> 4  2019, 99, Reported as Unknown if Impaired, 1, 24, Maryland, 240048, 0
#> 5                                                                   NULL
#> 6                     2019, 98, Not Reported, 1, 24, Maryland, 240242, 0
#> 7                                                                   NULL
#> 8                     2019, 98, Not Reported, 1, 24, Maryland, 240373, 0
#> 9                                                                   NULL
#> 10                                                                  NULL
#>                                                                                                              nm_priors
#> 1                                                                                                                 NULL
#> 2                                                                                                                 NULL
#> 3                                                                                                                 NULL
#> 4     2019, 5, Movement Along Roadway with Traffic (In or Adjacent to Travel Lane), NA, NA, 1, 24, Maryland, 240048, 0
#> 5                                                                                                                 NULL
#> 6  2019, 6, Movement Along Roadway Against Traffic (In or Adjacent to Travel Lane), NA, NA, 1, 24, Maryland, 240242, 0
#> 7                                                                                                                 NULL
#> 8                                                        2019, 3, Crossing Roadway, NA, NA, 1, 24, Maryland, 240373, 0
#> 9                                                                                                                 NULL
#> 10                                                                                                                NULL
#>                                 safety_e_qs park_works
#> 1                                      NULL       NULL
#> 2                                      NULL       NULL
#> 3                                      NULL       NULL
#> 4  2019, NA, NA, 1, 24, Maryland, 240048, 0       NULL
#> 5                                      NULL       NULL
#> 6  2019, NA, NA, 1, 24, Maryland, 240242, 0       NULL
#> 7                                      NULL       NULL
#> 8  2019, NA, NA, 1, 24, Maryland, 240373, 0       NULL
#> 9                                      NULL       NULL
#> 10                                     NULL       NULL
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     pb_types
#> 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       NULL
#> 2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       NULL
#> 3                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       NULL
#> 4  0, 0, 0, Not a Cyclist, Not a Cyclist, Not a Cyclist, 0, 0, 0, Not a Cyclist, Not a Cyclist, Not a Cyclist, 7, 7, 7, Not a Cyclist, Not a Cyclist, Not a Cyclist, 7, 7, 7, Not a Cyclist, Not a Cyclist, Not a Cyclist, 7, 7, 7, Not a Cyclist, Not a Cyclist, Not a Cyclist, 2019, 2019, 2019, 8, 8, 8, Not Applicable, Not Applicable, Not Applicable, 8, 8, 8, Not Applicable, Not Applicable, Not Applicable, 26, 26, 26, 26 Years, 26 Years, 26 Years, 0, 0, 0, None Noted, None Noted, None Noted, 5, 5, 5, Pedestrian, Pedestrian, Pedestrian, 1, 1, 1, Male, Male, Male, 0, 0, 0, None Noted, None Noted, None Noted, 0, 0, 0, None Noted, None Noted, None Noted, 400, 400, 400, Walking/Running Along Roadway, Walking/Running Along Roadway, Walking/Running Along Roadway, 410, 410, 410, Walking/Running Along Roadway With Traffic - From Behind, Walking/Running Along Roadway With Traffic - From Behind, Walking/Running Along Roadway With Traffic - From Behind, 8, 8, 8, Not Applicable, Not Applicable, Not Applicable, 8, 8, 8, Not Applicable, Not Applicable, Not Applicable, 3, 3, 3, Not At Intersection, Not At Intersection, Not At Intersection, 3, 3, 3, Travel Lane, Travel Lane, Travel Lane, 8, 8, 8, Not Applicable, Not Applicable, Not Applicable, 1, 1, 2, 24, 24, 24, Maryland, Maryland, Maryland, 240048, 240048, 240048, 0, 1, 1
#> 5                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       NULL
#> 6                                                                                                                                                                                                                                                                                                                                                                                                                                                       0, 0, Not a Cyclist, Not a Cyclist, 0, 0, Not a Cyclist, Not a Cyclist, 7, 7, Not a Cyclist, Not a Cyclist, 7, 7, Not a Cyclist, Not a Cyclist, 7, 7, Not a Cyclist, Not a Cyclist, 2019, 2019, 8, 8, Not Applicable, Not Applicable, 8, 8, Not Applicable, Not Applicable, 32, 32, 32 Years, 32 Years, 0, 0, None Noted, None Noted, 5, 5, Pedestrian, Pedestrian, 1, 1, Male, Male, 0, 0, None Noted, None Noted, 0, 0, None Noted, None Noted, 400, 400, Walking/Running Along Roadway, Walking/Running Along Roadway, 440, 440, Walking/Running Along Roadway Against Traffic - From Front, Walking/Running Along Roadway Against Traffic - From Front, 8, 8, Not Applicable, Not Applicable, 8, 8, Not Applicable, Not Applicable, 3, 3, Not At Intersection, Not At Intersection, 3, 3, Travel Lane, Travel Lane, 8, 8, Not Applicable, Not Applicable, 1, 1, 24, 24, Maryland, Maryland, 240242, 240242, 0, 1
#> 7                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       NULL
#> 8                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     0, 0, Not a Cyclist, Not a Cyclist, 0, 0, Not a Cyclist, Not a Cyclist, 7, 7, Not a Cyclist, Not a Cyclist, 7, 7, Not a Cyclist, Not a Cyclist, 7, 7, Not a Cyclist, Not a Cyclist, 2019, 2019, 8, 8, Not Applicable, Not Applicable, 8, 8, Not Applicable, Not Applicable, 50, 50, 50 Years, 50 Years, 0, 0, None Noted, None Noted, 5, 5, Pedestrian, Pedestrian, 1, 1, Male, Male, 0, 0, None Noted, None Noted, 0, 0, None Noted, None Noted, 750, 750, Crossing Roadway - Vehicle Not Turning, Crossing Roadway - Vehicle Not Turning, 760, 760, Pedestrian Failed to Yield, Pedestrian Failed to Yield, 8, 8, Not Applicable, Not Applicable, 8, 8, Not Applicable, Not Applicable, 3, 3, Not At Intersection, Not At Intersection, 3, 3, Travel Lane, Travel Lane, 8, 8, Not Applicable, Not Applicable, 1, 1, 24, 24, Maryland, Maryland, 240373, 240373, 0, 1
#> 9                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       NULL
#> 10                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      NULL
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
