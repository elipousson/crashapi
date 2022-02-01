
<!-- README.md is generated from README.Rmd. Please edit that file -->

# crashapi

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/crashapi)](https://CRAN.R-project.org/package=crashapi)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![License:
MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
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

Most of these APIs support XML, JSV, CSV, and JSON output formats. This
package only uses JSON with the exception of get\_fars\_year (which
supports downloading CSV files).

Currently unsupported APIs include:

-   [ ] Get Crashes By Occupant

For reference, this package also includes a list of terms and NHTSA
technical definitions in `fars_terms` and a list of variable labels in
`fars_vars_labels`.

The FARS API currently only provides access to data from 2010 to 2019.
The `get_fars_zip` function can be used to access FARS data files from
1975 to 2019 that that are available for download on through [the NHTSA
File Downloads
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
| 2019      | Annual       | June 24, 2021     |

## Installation

You can install the development version of crashapi using the remotes
package:

``` r
remotes::install_github("elipousson/crashapi")
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
    year = c(2010, 2019),
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
  year = c(2010, 2012),
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
#> 3   ORANGE (71) /Date(1558274040000-0400)/      1    0       1  360277    36
#> 4   QUEENS (81) /Date(1561656240000-0400)/      1    0       6  360319    36
#> 5     BRONX (5) /Date(1561866000000-0400)/      1    0      11  360339    36
#> 6    KINGS (47) /Date(1564564080000-0400)/      1    0       5  360440    36
#> 7 SUFFOLK (103) /Date(1563792360000-0400)/      1    0       2  360551    36
#>   StateName TotalVehicles
#> 1  New York             5
#> 2  New York             5
#> 3  New York             6
#> 4  New York             5
#> 5  New York             5
#> 6  New York             5
#> 7  New York             6
```

If you call `get_fars()` or `get_fars_crashes()` with details set to
TRUE, additional information from `get_fars_cases()` (including the
crash date and time) is appended to the crash data frame.

``` r
# Get fatal crashes for Anne Arundel County, MD for 2019 and append details
crashes_detailed <- get_fars(
  year = 2019,
  state = "MD",
  county = "Anne Arundel County",
  details = TRUE
)

# Show 10 fatal crashes at random
dplyr::slice_sample(crashes_detailed, n = 10)
#>    case_year totalvehicles state statename st_case       date  time
#> 1       2019             2    24  Maryland  240046 2019-02-16 00:02
#> 2       2019             1    24  Maryland  240319 2019-09-20 00:02
#> 3       2019             1    24  Maryland  240150 2019-05-31 00:02
#> 4       2019             2    24  Maryland  240389 2019-09-27 00:02
#> 5       2019             2    24  Maryland  240190 2019-06-30 00:02
#> 6       2019             1    24  Maryland  240048 2019-02-20 00:02
#> 7       2019             2    24  Maryland  240116 2019-04-22 00:02
#> 8       2019             2    24  Maryland  240169 2019-06-14 00:02
#> 9       2019             1    24  Maryland  240463 2019-01-05 00:02
#> 10      2019             2    24  Maryland  240294 2019-09-14 00:02
#>               datetime peds pernotmvit ve_total ve_forms pvh_invl
#> 1  2019-02-16 00:02:00    0          0        2        2        0
#> 2  2019-09-20 00:02:00    0          0        1        1        0
#> 3  2019-05-31 00:02:00    0          0        1        1        0
#> 4  2019-09-27 00:02:00    0          0        2        2        0
#> 5  2019-06-30 00:02:00    1          1        2        1        1
#> 6  2019-02-20 00:02:00    1          1        1        1        0
#> 7  2019-04-22 00:02:00    0          0        2        2        0
#> 8  2019-06-14 00:02:00    0          0        2        2        0
#> 9  2019-01-05 00:02:00    0          0        1        1        0
#> 10 2019-09-14 00:02:00    0          2        2        1        1
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               n_persons
#> 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  NULL
#> 2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  NULL
#> 3                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  NULL
#> 4                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  NULL
#> 5                           41, 41 Years, 97, Not a Motor Vehicle Occupant, 9, Not Reported, 20, 0.020 % BAC, 2, Test Given, 1, Blood, NA, NA, NA, 3, ANNE ARUNDEL (3), 2019, 30, 30, 30, 18, 18:00-18:59, 33, 33, 6, June, 1833, 2019, 2019, 7, Died at Scene, 0, No (Alcohol Not Involved), NA, NA, NA, NA, NA, NA, 0, No (drugs not involved), NA, NA, NA, NA, NA, NA, 8, Not Reported, 2, Test Given, 8, Not Applicable, 0, Ejection Path Not Applicable, NA, NA, 0, Not Extricated or Not Applicable, NA, NA, 3, Principal Arterial - Other, 8, Pedestrian, 7, Non-Hispanic, 0, Not Transported, 18, 6:00pm-6:59pm, NA, NA, 4, Fatal Injury (K), 0, 13, 20, Shoulder/Roadside, NA, NA, NA, 0, The First Harmful Event was Not a Collision with a Motor Vehicle in Transport, 20, 20, NA, NA, 6, June, 1, 5, Pedestrian, 0, None, 0, None, 0, None, NA, NA, 8, Not a Motor Vehicle Occupant, 96, Not a Motor Vehicle Occupant, NA, NA, NA, NA, 2, Urban, 0, No, 0, Not a Motor Vehicle Occupant, 1, Male, NA, NA, 24, Maryland, 1, 01, 240190, NA, NA, 0, 1, 1, Yes
#> 6  26, 26 Years, 97, Not a Motor Vehicle Occupant, 9, Not Reported, 0, 0.000 % BAC, 2, Test Given, 1, Blood, NA, NA, NA, 3, ANNE ARUNDEL (3), 2019, 20, 20, 20, 18, 18:00-18:59, 43, 43, 2, February, 1843, 2019, 2019, 7, Died at Scene, 9, Reported as Unknown, NA, NA, NA, NA, NA, NA, 9, Reported as Unknown, NA, NA, NA, NA, NA, NA, 8, Not Reported, 2, Test Given, 8, Not Applicable, 0, Ejection Path Not Applicable, NA, NA, 0, Not Extricated or Not Applicable, NA, NA, 5, Major Collector, 8, Pedestrian, 7, Non-Hispanic, 0, Not Transported, 18, 6:00pm-6:59pm, NA, NA, 4, Fatal Injury (K), 0, 18, 11, Not at Intersection - On Roadway, Not in Marked Crosswalk, NA, NA, NA, 0, The First Harmful Event was Not a Collision with a Motor Vehicle in Transport, 25, 25, NA, NA, 2, February, 1, 5, Pedestrian, 0, None, 0, None, 0, None, NA, NA, 8, Not a Motor Vehicle Occupant, 96, Not a Motor Vehicle Occupant, NA, NA, NA, NA, 2, Urban, 0, No, 0, Not a Motor Vehicle Occupant, 1, Male, NA, NA, 24, Maryland, 1, 01, 240048, NA, NA, 0, 1, 0, No
#> 7                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  NULL
#> 8                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  NULL
#> 9                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  NULL
#> 10                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 NULL
#>    persons permvit county       countyname city       cityname month month_name
#> 1        3       3      3 ANNE ARUNDEL (3)    0 NOT APPLICABLE     2   February
#> 2        4       4      3 ANNE ARUNDEL (3)    0 NOT APPLICABLE     9  September
#> 3        1       1      3 ANNE ARUNDEL (3)    0 NOT APPLICABLE     5        May
#> 4        3       3      3 ANNE ARUNDEL (3) 1415         SEVERN     9  September
#> 5        1       1      3 ANNE ARUNDEL (3)    0 NOT APPLICABLE     6       June
#> 6        2       2      3 ANNE ARUNDEL (3)    0 NOT APPLICABLE     2   February
#> 7        2       2      3 ANNE ARUNDEL (3)    0 NOT APPLICABLE     4      April
#> 8        3       3      3 ANNE ARUNDEL (3)    0 NOT APPLICABLE     6       June
#> 9        1       1      3 ANNE ARUNDEL (3)    0 NOT APPLICABLE     1    January
#> 10       3       1      3 ANNE ARUNDEL (3)    0 NOT APPLICABLE     9  September
#>    day day_week day_weekname year hour        hourname minute minutename
#> 1   16        7     Saturday 2019   11 11:00am-11:59am     43         43
#> 2   20        6       Friday 2019   21   9:00pm-9:59pm      2          2
#> 3   31        6       Friday 2019   11 11:00am-11:59am     26         26
#> 4   27        6       Friday 2019   20   8:00pm-8:59pm     31         31
#> 5   30        1       Sunday 2019   18   6:00pm-6:59pm     20         20
#> 6   20        4    Wednesday 2019   18   6:00pm-6:59pm     25         25
#> 7   22        2       Monday 2019    8   8:00am-8:59am      0          0
#> 8   14        6       Friday 2019   22 10:00pm-10:59pm     30         30
#> 9    5        7     Saturday 2019   23 11:00pm-11:59pm     42         42
#> 10  14        7     Saturday 2019   15   3:00pm-3:59pm     46         46
#>                tway_id tway_id2 route     routename rur_urb rur_urbname
#> 1               SR-100              3 State Highway       2       Urban
#> 2              CR-3549              4   County Road       2       Urban
#> 3               SR-468              3 State Highway       1       Rural
#> 4  SR-175 ANNAPOLIS RD  CR-5454     3 State Highway       2       Urban
#> 5               SR-295              3 State Highway       2       Urban
#> 6              CR-2633              4   County Road       2       Urban
#> 7               SR-450              3 State Highway       2       Urban
#> 8               SR-295              3 State Highway       2       Urban
#> 9               SR-295              3 State Highway       2       Urban
#> 10              SR-295              3 State Highway       2       Urban
#>    func_sys               func_sysname rd_owner          rd_ownername nhs
#> 1         7                      Local        1  State Highway Agency   0
#> 2         5            Major Collector        2 County Highway Agency   0
#> 3         5            Major Collector        1  State Highway Agency   0
#> 4         4             Minor Arterial        1  State Highway Agency   0
#> 5         3 Principal Arterial - Other        1  State Highway Agency   0
#> 6         5            Major Collector        2 County Highway Agency   0
#> 7         3 Principal Arterial - Other        1  State Highway Agency   0
#> 8         7                      Local        1  State Highway Agency   0
#> 9         3 Principal Arterial - Other        1  State Highway Agency   1
#> 10        4             Minor Arterial        1  State Highway Agency   0
#>                           nhsname sp_jur              sp_jurname milept
#> 1  This section IS NOT on the NHS      0 No Special Jurisdiction     70
#> 2  This section IS NOT on the NHS      0 No Special Jurisdiction     73
#> 3  This section IS NOT on the NHS      0 No Special Jurisdiction     78
#> 4  This section IS NOT on the NHS      0 No Special Jurisdiction     47
#> 5  This section IS NOT on the NHS      0 No Special Jurisdiction     90
#> 6  This section IS NOT on the NHS      0 No Special Jurisdiction     12
#> 7  This section IS NOT on the NHS      0 No Special Jurisdiction    102
#> 8  This section IS NOT on the NHS      0 No Special Jurisdiction      9
#> 9      This section IS ON the NHS      1   National Park Service      0
#> 10 This section IS NOT on the NHS      0 No Special Jurisdiction    119
#>    mileptname    latitude latitudename      longitud  longitudname harm_ev
#> 1          70 39.15160833  39.15160833 -76.637511110 -76.637511110      24
#> 2          73 38.81967778  38.81967778 -76.690894440 -76.690894440      42
#> 3          78 38.87208611  38.87208611 -76.563958330 -76.563958330      42
#> 4          47 39.09596667  39.09596667 -76.720419440 -76.720419440      12
#> 5          90 39.17808889  39.17808889 -76.723630560 -76.723630560       8
#> 6          12 39.02736667  39.02736667 -76.708527780 -76.708527780       8
#> 7         102 38.98215833  38.98215833 -76.531572220 -76.531572220      12
#> 8           9 39.17067778  39.17067778 -76.730925000 -76.730925000      12
#> 9        None 39.11144722  39.11144722 -76.781183330 -76.781183330      42
#> 10        119 39.20472500  39.20472500 -76.690747220 -76.690747220      14
#>                    harm_evname man_coll
#> 1               Guardrail Face        0
#> 2         Tree (Standing Only)        0
#> 3         Tree (Standing Only)        0
#> 4  Motor Vehicle In-Transport         6
#> 5                   Pedestrian        0
#> 6                   Pedestrian        0
#> 7  Motor Vehicle In-Transport         6
#> 8  Motor Vehicle In-Transport         6
#> 9         Tree (Standing Only)        0
#> 10       Parked Motor Vehicle         0
#>                                                                     man_collname
#> 1  The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 2  The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 3  The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 4                                                                         Angle 
#> 5  The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 6  The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 7                                                                         Angle 
#> 8                                                                         Angle 
#> 9  The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 10 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#>    reljct1 reljct1name reljct2                            reljct2name typ_int
#> 1        0          No       1                           Non-Junction       1
#> 2        0          No       1                           Non-Junction       1
#> 3        0          No       1                           Non-Junction       1
#> 4        0          No       2                           Intersection       3
#> 5        0          No       1                           Non-Junction       1
#> 6        0          No       1                           Non-Junction       1
#> 7        0          No       8                Driveway Access Related       1
#> 8        0          No       5             Entrance/Exit Ramp Related       1
#> 9        0          No       5             Entrance/Exit Ramp Related       1
#> 10       1         Yes      19 Other location within Interchange Area       1
#>            typ_intname rel_road rel_roadname wrk_zone wrk_zonename lgt_cond
#> 1  Not an Intersection        4  On Roadside        0         None        1
#> 2  Not an Intersection        4  On Roadside        0         None        3
#> 3  Not an Intersection        4  On Roadside        0         None        1
#> 4       T-Intersection        1   On Roadway        0         None        3
#> 5  Not an Intersection        2  On Shoulder        0         None        1
#> 6  Not an Intersection        1   On Roadway        0         None        2
#> 7  Not an Intersection        1   On Roadway        0         None        1
#> 8  Not an Intersection        1   On Roadway        0         None        3
#> 9  Not an Intersection        3    On Median        0         None        3
#> 10 Not an Intersection        8         Gore        0         None        1
#>          lgt_condname weather weathername weather1 weather1name weather2
#> 1            Daylight       1       Clear        1        Clear        0
#> 2      Dark - Lighted       1       Clear        1        Clear        0
#> 3            Daylight       1       Clear        1        Clear        0
#> 4      Dark - Lighted       1       Clear        1        Clear        0
#> 5            Daylight       1       Clear        1        Clear        0
#> 6  Dark - Not Lighted       4        Snow        4         Snow        0
#> 7            Daylight      10      Cloudy       10       Cloudy        0
#> 8      Dark - Lighted       1       Clear        1        Clear        0
#> 9      Dark - Lighted       1       Clear        1        Clear        0
#> 10           Daylight      10      Cloudy       10       Cloudy        0
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
#>    hosp_hr                       hosp_hrname hosp_mn
#> 1       99                           Unknown      99
#> 2       99                           Unknown      99
#> 3       88 Not Applicable (Not Transported)       88
#> 4       88 Not Applicable (Not Transported)       88
#> 5       99                           Unknown      99
#> 6       88 Not Applicable (Not Transported)       88
#> 7       99                           Unknown      99
#> 8       88 Not Applicable (Not Transported)       88
#> 9       88 Not Applicable (Not Transported)       88
#> 10      99                           Unknown      99
#>                          hosp_mnname cf1
#> 1  Unknown EMS Hospital Arrival Time   0
#> 2  Unknown EMS Hospital Arrival Time   0
#> 3   Not Applicable (Not Transported)   0
#> 4   Not Applicable (Not Transported)   0
#> 5  Unknown EMS Hospital Arrival Time  14
#> 6   Not Applicable (Not Transported)   0
#> 7  Unknown EMS Hospital Arrival Time   0
#> 8   Not Applicable (Not Transported)   0
#> 9   Not Applicable (Not Transported)   0
#> 10 Unknown EMS Hospital Arrival Time   0
#>                                                                                                                     cf1name
#> 1                                                                                                                      None
#> 2                                                                                                                      None
#> 3                                                                                                                      None
#> 4                                                                                                                      None
#> 5  Motor Vehicle struck by falling cargo,or something that came loose from or something that was set in motion by a vehicle
#> 6                                                                                                                      None
#> 7                                                                                                                      None
#> 8                                                                                                                      None
#> 9                                                                                                                      None
#> 10                                                                                                                     None
#>    cf2 cf2name cf3 cf3name fatals drunk_dr road_fnc road_fncname
#> 1    0    None   0    None      1        0       NA           NA
#> 2    0    None   0    None      1        0       NA           NA
#> 3    0    None   0    None      1        0       NA           NA
#> 4    0    None   0    None      1        1       NA           NA
#> 5    0    None   0    None      1        0       NA           NA
#> 6    0    None   0    None      1        0       NA           NA
#> 7    0    None   0    None      1        0       NA           NA
#> 8    0    None   0    None      2        0       NA           NA
#> 9    0    None   0    None      1        1       NA           NA
#> 10   0    None   0    None      1        1       NA           NA
#>                                                                                                                                                                nm_crashes
#> 1                                                                                                                                                                    NULL
#> 2                                                                                                                                                                    NULL
#> 3                                                                                                                                                                    NULL
#> 4                                                                                                                                                                    NULL
#> 5                                                                                                                         2019, 0, None Noted, 1, 24, Maryland, 240190, 0
#> 6  2019, 2019, 4, 9, In Roadway Improperly (Standing, Lying, Working, Playing, etc.), Wrong-Way Riding or Walking, 1, 1, 24, 24, Maryland, Maryland, 240048, 240048, 0, 0
#> 7                                                                                                                                                                    NULL
#> 8                                                                                                                                                                    NULL
#> 9                                                                                                                                                                    NULL
#> 10                                                                                                                                                                   NULL
#>                                                               nm_impairs
#> 1                                                                   NULL
#> 2                                                                   NULL
#> 3                                                                   NULL
#> 4                                                                   NULL
#> 5            2019, 0, None/Apparently Normal, 1, 24, Maryland, 240190, 0
#> 6  2019, 99, Reported as Unknown if Impaired, 1, 24, Maryland, 240048, 0
#> 7                                                                   NULL
#> 8                                                                   NULL
#> 9                                                                   NULL
#> 10                                                                  NULL
#>                                                                                                    nm_priors
#> 1                                                                                                       NULL
#> 2                                                                                                       NULL
#> 3                                                                                                       NULL
#> 4                                                                                                       NULL
#> 5  2019, 12, Disabled Vehicle Related (Working on, Pushing, Leaving/Approaching), 1, 24, Maryland, 240190, 0
#> 6   2019, 5, Movement Along Roadway with Traffic (In or Adjacent to Travel Lane), 1, 24, Maryland, 240048, 0
#> 7                                                                                                       NULL
#> 8                                                                                                       NULL
#> 9                                                                                                       NULL
#> 10                                                                                                      NULL
#>                                 safety_e_qs park_works
#> 1                                      NULL         NA
#> 2                                      NULL         NA
#> 3                                      NULL         NA
#> 4                                      NULL         NA
#> 5  2019, NA, NA, 1, 24, Maryland, 240190, 0         NA
#> 6  2019, NA, NA, 1, 24, Maryland, 240048, 0         NA
#> 7                                      NULL         NA
#> 8                                      NULL         NA
#> 9                                      NULL         NA
#> 10                                     NULL         NA
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     pb_types
#> 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       NULL
#> 2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       NULL
#> 3                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       NULL
#> 4                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       NULL
#> 5                                                                                                                                                                                                                                                                                                                                                                                                                                                               0, 0, Not a Cyclist, Not a Cyclist, 0, 0, Not a Cyclist, Not a Cyclist, 7, 7, Not a Cyclist, Not a Cyclist, 7, 7, Not a Cyclist, Not a Cyclist, 7, 7, Not a Cyclist, Not a Cyclist, 2019, 2019, 8, 8, Not Applicable, Not Applicable, 8, 8, Not Applicable, Not Applicable, 41, 41, 41 Years, 41 Years, 0, 0, None Noted, None Noted, 5, 5, Pedestrian, Pedestrian, 1, 1, Male, Male, 0, 0, None Noted, None Noted, 0, 0, None Noted, None Noted, 100, 100, Unusual Circumstances, Unusual Circumstances, 150, 150, Motor Vehicle Loss of Control, Motor Vehicle Loss of Control, 8, 8, Not Applicable, Not Applicable, 8, 8, Not Applicable, Not Applicable, 3, 3, Not At Intersection, Not At Intersection, 4, 4, Paved Shoulder / Bicycle Lane / Parking Lane, Paved Shoulder / Bicycle Lane / Parking Lane, 8, 8, Not Applicable, Not Applicable, 1, 1, 24, 24, Maryland, Maryland, 240190, 240190, 0, 1
#> 6  0, 0, 0, Not a Cyclist, Not a Cyclist, Not a Cyclist, 0, 0, 0, Not a Cyclist, Not a Cyclist, Not a Cyclist, 7, 7, 7, Not a Cyclist, Not a Cyclist, Not a Cyclist, 7, 7, 7, Not a Cyclist, Not a Cyclist, Not a Cyclist, 7, 7, 7, Not a Cyclist, Not a Cyclist, Not a Cyclist, 2019, 2019, 2019, 8, 8, 8, Not Applicable, Not Applicable, Not Applicable, 8, 8, 8, Not Applicable, Not Applicable, Not Applicable, 26, 26, 26, 26 Years, 26 Years, 26 Years, 0, 0, 0, None Noted, None Noted, None Noted, 5, 5, 5, Pedestrian, Pedestrian, Pedestrian, 1, 1, 1, Male, Male, Male, 0, 0, 0, None Noted, None Noted, None Noted, 0, 0, 0, None Noted, None Noted, None Noted, 400, 400, 400, Walking/Running Along Roadway, Walking/Running Along Roadway, Walking/Running Along Roadway, 410, 410, 410, Walking/Running Along Roadway With Traffic - From Behind, Walking/Running Along Roadway With Traffic - From Behind, Walking/Running Along Roadway With Traffic - From Behind, 8, 8, 8, Not Applicable, Not Applicable, Not Applicable, 8, 8, 8, Not Applicable, Not Applicable, Not Applicable, 3, 3, 3, Not At Intersection, Not At Intersection, Not At Intersection, 3, 3, 3, Travel Lane, Travel Lane, Travel Lane, 8, 8, 8, Not Applicable, Not Applicable, Not Applicable, 1, 1, 2, 24, 24, 24, Maryland, Maryland, Maryland, 240048, 240048, 240048, 0, 1, 1
#> 7                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       NULL
#> 8                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       NULL
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
    crash data from other U.S. cities adn states are welcome.
