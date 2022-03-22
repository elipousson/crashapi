
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
-   [x] Get Summary Counts (not currently working)
-   [x] Get Variables and Get Variable Attributes
-   [x] Get FARS Data By Year
-   [x] Get Crashes By Occupant (partial support)

Most of these APIs support XML, JSV, CSV, and JSON output formats. This
package only uses JSON with the exception of get\_fars\_year (which
supports downloading CSV files).

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
#> ℹ Downloading case data for MD crashes.

# Show 10 fatal crashes at random
dplyr::slice_sample(crashes_detailed, n = 10)
#>    case_year totalvehicles state statename st_case       date  time
#> 1       2019             2    24  Maryland  240162 2019-06-07 14:36
#> 2       2019             2    24  Maryland  240294 2019-09-14 15:46
#> 3       2019             1    24  Maryland  240119 2019-05-05 11:39
#> 4       2019             2    24  Maryland  240190 2019-06-30 18:20
#> 5       2019             1    24  Maryland  240236 2019-07-30 17:54
#> 6       2019             2    24  Maryland  240169 2019-06-14 22:30
#> 7       2019             2    24  Maryland  240265 2019-08-27 07:08
#> 8       2019             1    24  Maryland  240096 2019-04-16 20:06
#> 9       2019             2    24  Maryland  240389 2019-09-27 20:31
#> 10      2019             1    24  Maryland  240048 2019-02-20 18:25
#>               datetime peds pernotmvit ve_total ve_forms pvh_invl
#> 1  2019-06-07 14:36:00    0          0        2        2        0
#> 2  2019-09-14 15:46:00    0          2        2        1        1
#> 3  2019-05-05 11:39:00    1          1        1        1        0
#> 4  2019-06-30 18:20:00    1          1        2        1        1
#> 5  2019-07-30 17:54:00    0          0        1        1        0
#> 6  2019-06-14 22:30:00    0          0        2        2        0
#> 7  2019-08-27 07:08:00    0          0        2        2        0
#> 8  2019-04-16 20:06:00    1          1        1        1        0
#> 9  2019-09-27 20:31:00    0          0        2        2        0
#> 10 2019-02-20 18:25:00    1          1        1        1        0
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       n_persons
#> 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          NULL
#> 2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          NULL
#> 3                             55, 55 Years, 97, Not a Motor Vehicle Occupant, 9, Not Reported, 130, 0.130 % BAC, 2, Test Given, 1, Blood, NA, NA, NA, 3, ANNE ARUNDEL (3), 2019, 5, 5, 5, 13, 13:00-13:59, 39, 39, 5, May, 1339, 1339, 2019, 2019, 0, Not Applicable, 9, Reported as Unknown, NA, NA, NA, NA, NA, NA, 9, Reported as Unknown, NA, NA, NA, NA, NA, NA, 8, Not Reported, 2, Test Given, 8, Not Applicable, 0, Ejection Path Not Applicable, NA, NA, 0, Not Extricated or Not Applicable, NA, NA, 3, Principal Arterial - Other, 9, Pedalcyclist, 8, Not a Motor Vehicle Occupant, 96, Not a Motor Vehicle Occupant, 7, Non-Hispanic, 5, EMS Ground, 11, 11:00am-11:59am, NA, NA, NA, NA, NA, NA, 4, Fatal Injury (K), 2, 2, 0, 0, 3, At Intersection - Not In Crosswalk, NA, NA, NA, NA, 0, The First Harmful Event was Not a Collision with a Motor Vehicle in Transport, 39, 39, NA, NA, 5, May, NA, 1, 6, Bicyclist, 0, None, 0, None, 0, None, NA, NA, NA, 8, Not a Motor Vehicle Occupant, 96, Not a Motor Vehicle Occupant, NA, NA, NA, NA, 2, Urban, NA, 0, No, 0, Not a Motor Vehicle Occupant, 1, Male, NA, NA, 24, Maryland, 1, NA, 240119, NA, NA, 0, 1, NA, NA, NA, NA, NA, NA, 0, No
#> 4                           41, 41 Years, 97, Not a Motor Vehicle Occupant, 9, Not Reported, 20, 0.020 % BAC, 2, Test Given, 1, Blood, NA, NA, NA, 3, ANNE ARUNDEL (3), 2019, 30, 30, 30, 18, 18:00-18:59, 33, 33, 6, June, 1833, 1833, 2019, 2019, 7, Died at Scene, 0, No (Alcohol Not Involved), NA, NA, NA, NA, NA, NA, 0, No (drugs not involved), NA, NA, NA, NA, NA, NA, 8, Not Reported, 2, Test Given, 8, Not Applicable, 0, Ejection Path Not Applicable, NA, NA, 0, Not Extricated or Not Applicable, NA, NA, 3, Principal Arterial - Other, 8, Pedestrian, 8, Not a Motor Vehicle Occupant, 96, Not a Motor Vehicle Occupant, 7, Non-Hispanic, 0, Not Transported, 18, 6:00pm-6:59pm, NA, NA, NA, NA, NA, NA, 4, Fatal Injury (K), 0, 0, 13, 13, 20, Shoulder/Roadside, NA, NA, NA, NA, 0, The First Harmful Event was Not a Collision with a Motor Vehicle in Transport, 20, 20, NA, NA, 6, June, NA, 1, 5, Pedestrian, 0, None, 0, None, 0, None, NA, NA, NA, 8, Not a Motor Vehicle Occupant, 96, Not a Motor Vehicle Occupant, NA, NA, NA, NA, 2, Urban, NA, 0, No, 0, Not a Motor Vehicle Occupant, 1, Male, NA, NA, 24, Maryland, 1, NA, 240190, NA, NA, 0, 1, NA, NA, NA, NA, NA, NA, 1, Yes
#> 5                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          NULL
#> 6                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          NULL
#> 7                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          NULL
#> 8                                         12, 12 Years, 97, Not a Motor Vehicle Occupant, 9, Not Reported, 0, 0.000 % BAC, 2, Test Given, 1, Blood, NA, NA, NA, 3, ANNE ARUNDEL (3), 2019, 16, 17, 17, 8, 8:00-8:59, 15, 15, 4, April, 815, 815, 2019, 2019, 0, Not Applicable, 0, No (Alcohol Not Involved), NA, NA, NA, NA, NA, NA, 0, No (drugs not involved), NA, NA, NA, NA, NA, NA, 8, Not Reported, 2, Test Given, 8, Not Applicable, 0, Ejection Path Not Applicable, NA, NA, 0, Not Extricated or Not Applicable, NA, NA, 7, Local, 8, Pedestrian, 8, Not a Motor Vehicle Occupant, 96, Not a Motor Vehicle Occupant, 7, Non-Hispanic, 5, EMS Ground, 20, 8:00pm-8:59pm, NA, NA, NA, NA, NA, NA, 4, Fatal Injury (K), 12, 12, 9, 9, 3, At Intersection - Not In Crosswalk, NA, NA, NA, NA, 0, The First Harmful Event was Not a Collision with a Motor Vehicle in Transport, 6, 6, NA, NA, 4, April, NA, 1, 5, Pedestrian, 0, None, 0, None, 0, None, NA, NA, NA, 8, Not a Motor Vehicle Occupant, 96, Not a Motor Vehicle Occupant, NA, NA, NA, NA, 2, Urban, NA, 0, No, 0, Not a Motor Vehicle Occupant, 2, Female, NA, NA, 24, Maryland, 1, NA, 240096, NA, NA, 0, 1, NA, NA, NA, NA, NA, NA, 0, No
#> 9                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          NULL
#> 10 26, 26 Years, 97, Not a Motor Vehicle Occupant, 9, Not Reported, 0, 0.000 % BAC, 2, Test Given, 1, Blood, NA, NA, NA, 3, ANNE ARUNDEL (3), 2019, 20, 20, 20, 18, 18:00-18:59, 43, 43, 2, February, 1843, 1843, 2019, 2019, 7, Died at Scene, 9, Reported as Unknown, NA, NA, NA, NA, NA, NA, 9, Reported as Unknown, NA, NA, NA, NA, NA, NA, 8, Not Reported, 2, Test Given, 8, Not Applicable, 0, Ejection Path Not Applicable, NA, NA, 0, Not Extricated or Not Applicable, NA, NA, 5, Major Collector, 8, Pedestrian, 8, Not a Motor Vehicle Occupant, 96, Not a Motor Vehicle Occupant, 7, Non-Hispanic, 0, Not Transported, 18, 6:00pm-6:59pm, NA, NA, NA, NA, NA, NA, 4, Fatal Injury (K), 0, 0, 18, 18, 11, Not at Intersection - On Roadway, Not in Marked Crosswalk, NA, NA, NA, NA, 0, The First Harmful Event was Not a Collision with a Motor Vehicle in Transport, 25, 25, NA, NA, 2, February, NA, 1, 5, Pedestrian, 0, None, 0, None, 0, None, NA, NA, NA, 8, Not a Motor Vehicle Occupant, 96, Not a Motor Vehicle Occupant, NA, NA, NA, NA, 2, Urban, NA, 0, No, 0, Not a Motor Vehicle Occupant, 1, Male, NA, NA, 24, Maryland, 1, NA, 240048, NA, NA, 0, 1, NA, NA, NA, NA, NA, NA, 0, No
#>    persons permvit county       countyname city       cityname month month_name
#> 1        2       2      3 ANNE ARUNDEL (3)    0 NOT APPLICABLE     6       June
#> 2        3       1      3 ANNE ARUNDEL (3)    0 NOT APPLICABLE     9  September
#> 3        1       1      3 ANNE ARUNDEL (3)    0 NOT APPLICABLE     5        May
#> 4        1       1      3 ANNE ARUNDEL (3)    0 NOT APPLICABLE     6       June
#> 5        1       1      3 ANNE ARUNDEL (3)    0 NOT APPLICABLE     7       July
#> 6        3       3      3 ANNE ARUNDEL (3)    0 NOT APPLICABLE     6       June
#> 7        2       2      3 ANNE ARUNDEL (3)    0 NOT APPLICABLE     8     August
#> 8        1       1      3 ANNE ARUNDEL (3)    0 NOT APPLICABLE     4      April
#> 9        3       3      3 ANNE ARUNDEL (3) 1415         SEVERN     9  September
#> 10       2       2      3 ANNE ARUNDEL (3)    0 NOT APPLICABLE     2   February
#>    day day_week day_weekname year hour        hourname minute minutename
#> 1    7        6       Friday 2019   14   2:00pm-2:59pm     36         36
#> 2   14        7     Saturday 2019   15   3:00pm-3:59pm     46         46
#> 3    5        1       Sunday 2019   11 11:00am-11:59am     39         39
#> 4   30        1       Sunday 2019   18   6:00pm-6:59pm     20         20
#> 5   30        3      Tuesday 2019   17   5:00pm-5:59pm     54         54
#> 6   14        6       Friday 2019   22 10:00pm-10:59pm     30         30
#> 7   27        3      Tuesday 2019    7   7:00am-7:59am      8          8
#> 8   16        3      Tuesday 2019   20   8:00pm-8:59pm      6          6
#> 9   27        6       Friday 2019   20   8:00pm-8:59pm     31         31
#> 10  20        4    Wednesday 2019   18   6:00pm-6:59pm     25         25
#>                tway_id     tway_id2 route     routename rur_urb rur_urbname
#> 1              CR-1178         <NA>     4   County Road       2       Urban
#> 2               SR-295         <NA>     3 State Highway       2       Urban
#> 3                 SR-2       OP-226     3 State Highway       2       Urban
#> 4               SR-295         <NA>     3 State Highway       2       Urban
#> 5                CR-10         <NA>     4   County Road       2       Urban
#> 6               SR-295         <NA>     3 State Highway       2       Urban
#> 7              CR-5461         <NA>     4   County Road       2       Urban
#> 8               CR-938 GLENEAGLE DR     4   County Road       2       Urban
#> 9  SR-175 ANNAPOLIS RD      CR-5454     3 State Highway       2       Urban
#> 10             CR-2633         <NA>     4   County Road       2       Urban
#>    func_sys               func_sysname rd_owner          rd_ownername nhs
#> 1         5            Major Collector        2 County Highway Agency   0
#> 2         4             Minor Arterial        1  State Highway Agency   0
#> 3         3 Principal Arterial - Other        1  State Highway Agency   0
#> 4         3 Principal Arterial - Other        1  State Highway Agency   0
#> 5         5            Major Collector        2 County Highway Agency   0
#> 6         7                      Local        1  State Highway Agency   0
#> 7         4             Minor Arterial        2 County Highway Agency   0
#> 8         7                      Local        2 County Highway Agency   0
#> 9         4             Minor Arterial        1  State Highway Agency   0
#> 10        5            Major Collector        2 County Highway Agency   0
#>                           nhsname sp_jur              sp_jurname milept
#> 1  This section IS NOT on the NHS      0 No Special Jurisdiction     20
#> 2  This section IS NOT on the NHS      0 No Special Jurisdiction    119
#> 3  This section IS NOT on the NHS      0 No Special Jurisdiction    343
#> 4  This section IS NOT on the NHS      0 No Special Jurisdiction     90
#> 5  This section IS NOT on the NHS      0 No Special Jurisdiction      3
#> 6  This section IS NOT on the NHS      0 No Special Jurisdiction      9
#> 7  This section IS NOT on the NHS      0 No Special Jurisdiction     20
#> 8  This section IS NOT on the NHS      0 No Special Jurisdiction      7
#> 9  This section IS NOT on the NHS      0 No Special Jurisdiction     47
#> 10 This section IS NOT on the NHS      0 No Special Jurisdiction     12
#>    mileptname    latitude latitudename      longitud longitudname harm_ev
#> 1          20 39.08629167  39.08629167 -76.659530560 -76.65953056       1
#> 2         119 39.20472500    39.204725 -76.690747220 -76.69074722      14
#> 3         343 39.13838333  39.13838333 -76.600591670 -76.60059167       9
#> 4          90 39.17808889  39.17808889 -76.723630560 -76.72363056       8
#> 5           3 39.19875000     39.19875 -76.672713890 -76.67271389      42
#> 6           9 39.17067778  39.17067778 -76.730925000   -76.730925      12
#> 7          20 39.09671667  39.09671667 -76.624222220 -76.62422222      12
#> 8           7 39.14598889  39.14598889 -76.741250000    -76.74125       8
#> 9          47 39.09596667  39.09596667 -76.720419440 -76.72041944      12
#> 10         12 39.02736667  39.02736667 -76.708527780 -76.70852778       8
#>                   harm_evname man_coll
#> 1           Rollover/Overturn        0
#> 2        Parked Motor Vehicle        0
#> 3                Pedalcyclist        0
#> 4                  Pedestrian        0
#> 5        Tree (Standing Only)        0
#> 6  Motor Vehicle In-Transport        6
#> 7  Motor Vehicle In-Transport        6
#> 8                  Pedestrian        0
#> 9  Motor Vehicle In-Transport        6
#> 10                 Pedestrian        0
#>                                                                     man_collname
#> 1  The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 2  The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 3  The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 4  The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 5  The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 6                                                                          Angle
#> 7                                                                          Angle
#> 8  The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 9                                                                          Angle
#> 10 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#>    reljct1 reljct1name reljct2                            reljct2name typ_int
#> 1        0          No       1                           Non-Junction       1
#> 2        1         Yes      19 Other location within Interchange Area       1
#> 3        0          No       2                           Intersection       2
#> 4        0          No       1                           Non-Junction       1
#> 5        0          No       1                           Non-Junction       1
#> 6        0          No       5             Entrance/Exit Ramp Related       1
#> 7        0          No       8                Driveway Access Related       1
#> 8        0          No       3                   Intersection-Related       2
#> 9        0          No       2                           Intersection       3
#> 10       0          No       1                           Non-Junction       1
#>              typ_intname rel_road rel_roadname wrk_zone wrk_zonename lgt_cond
#> 1    Not an Intersection        1   On Roadway        0         None        1
#> 2    Not an Intersection        8         Gore        0         None        1
#> 3  Four-Way Intersection        1   On Roadway        0         None        1
#> 4    Not an Intersection        2  On Shoulder        0         None        1
#> 5    Not an Intersection        4  On Roadside        0         None        1
#> 6    Not an Intersection        1   On Roadway        0         None        3
#> 7    Not an Intersection        1   On Roadway        0         None        1
#> 8  Four-Way Intersection        1   On Roadway        0         None        5
#> 9         T-Intersection        1   On Roadway        0         None        3
#> 10   Not an Intersection        1   On Roadway        0         None        2
#>          lgt_condname weather weathername weather1 weather1name weather2
#> 1            Daylight       1       Clear        1        Clear        0
#> 2            Daylight      10      Cloudy       10       Cloudy        0
#> 3            Daylight       2        Rain        2         Rain        0
#> 4            Daylight       1       Clear        1        Clear        0
#> 5            Daylight       1       Clear        1        Clear        0
#> 6      Dark - Lighted       1       Clear        1        Clear        0
#> 7            Daylight      10      Cloudy       10       Cloudy        0
#> 8                Dusk       1       Clear        1        Clear        0
#> 9      Dark - Lighted       1       Clear        1        Clear        0
#> 10 Dark - Not Lighted       4        Snow        4         Snow        0
#>                            weather2name sch_bus sch_busname rail       railname
#> 1  No Additional Atmospheric Conditions       0          No    0 Not Applicable
#> 2  No Additional Atmospheric Conditions       0          No    0 Not Applicable
#> 3  No Additional Atmospheric Conditions       0          No    0 Not Applicable
#> 4  No Additional Atmospheric Conditions       0          No    0 Not Applicable
#> 5  No Additional Atmospheric Conditions       0          No    0 Not Applicable
#> 6  No Additional Atmospheric Conditions       0          No    0 Not Applicable
#> 7  No Additional Atmospheric Conditions       0          No    0 Not Applicable
#> 8  No Additional Atmospheric Conditions       0          No    0 Not Applicable
#> 9  No Additional Atmospheric Conditions       0          No    0 Not Applicable
#> 10 No Additional Atmospheric Conditions       0          No    0 Not Applicable
#>    not_hour not_hourname not_min not_minname arr_hour
#> 1        99      Unknown      99     Unknown       99
#> 2        99      Unknown      99     Unknown       99
#> 3        99      Unknown      99     Unknown       99
#> 4        99      Unknown      99     Unknown       99
#> 5        99      Unknown      99     Unknown       99
#> 6        99      Unknown      99     Unknown       99
#> 7        99      Unknown      99     Unknown       99
#> 8        99      Unknown      99     Unknown       99
#> 9        99      Unknown      99     Unknown       99
#> 10       99      Unknown      99     Unknown       99
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
#> 1       88 Not Applicable (Not Transported)      88
#> 2       99                          Unknown      99
#> 3       99                          Unknown      99
#> 4       99                          Unknown      99
#> 5       99                          Unknown      99
#> 6       88 Not Applicable (Not Transported)      88
#> 7       88 Not Applicable (Not Transported)      88
#> 8       99                          Unknown      99
#> 9       88 Not Applicable (Not Transported)      88
#> 10      88 Not Applicable (Not Transported)      88
#>                          hosp_mnname cf1
#> 1   Not Applicable (Not Transported)   0
#> 2  Unknown EMS Hospital Arrival Time   0
#> 3  Unknown EMS Hospital Arrival Time   0
#> 4  Unknown EMS Hospital Arrival Time  14
#> 5  Unknown EMS Hospital Arrival Time   0
#> 6   Not Applicable (Not Transported)   0
#> 7   Not Applicable (Not Transported)   0
#> 8  Unknown EMS Hospital Arrival Time   0
#> 9   Not Applicable (Not Transported)   0
#> 10  Not Applicable (Not Transported)   0
#>                                                                                                                     cf1name
#> 1                                                                                                                      None
#> 2                                                                                                                      None
#> 3                                                                                                                      None
#> 4  Motor Vehicle struck by falling cargo,or something that came loose from or something that was set in motion by a vehicle
#> 5                                                                                                                      None
#> 6                                                                                                                      None
#> 7                                                                                                                      None
#> 8                                                                                                                      None
#> 9                                                                                                                      None
#> 10                                                                                                                     None
#>    cf2 cf2name cf3 cf3name fatals drunk_dr road_fnc road_fncname
#> 1    0    None   0    None      1        0       NA           NA
#> 2    0    None   0    None      1        1       NA           NA
#> 3    0    None   0    None      1        0       NA           NA
#> 4    0    None   0    None      1        0       NA           NA
#> 5    0    None   0    None      1        0       NA           NA
#> 6    0    None   0    None      2        0       NA           NA
#> 7    0    None   0    None      1        0       NA           NA
#> 8    0    None   0    None      1        0       NA           NA
#> 9    0    None   0    None      1        1       NA           NA
#> 10   0    None   0    None      1        0       NA           NA
#>                                                                                                                                                                                nm_crashes
#> 1                                                                                                                                                                                    NULL
#> 2                                                                                                                                                                                    NULL
#> 3              2019, 2019, 2, 3, Failure to Yield Right-Of-Way, Failure to Obey Traffic Signs, Signals or Officer, NA, NA, NA, NA, 1, 1, 24, 24, Maryland, Maryland, 240119, 240119, 0, 0
#> 4                                                                                                                                 2019, 0, None Noted, NA, NA, 1, 24, Maryland, 240190, 0
#> 5                                                                                                                                                                                    NULL
#> 6                                                                                                                                                                                    NULL
#> 7                                                                                                                                                                                    NULL
#> 8                                                                                                   2019, 11, Dash - Run, No Visual Obstruction Noted, NA, NA, 1, 24, Maryland, 240096, 0
#> 9                                                                                                                                                                                    NULL
#> 10 2019, 2019, 4, 9, In Roadway Improperly (Standing, Lying, Working, Playing, etc.), Wrong-Way Riding or Walking, NA, NA, NA, NA, 1, 1, 24, 24, Maryland, Maryland, 240048, 240048, 0, 0
#>                                                               nm_impairs
#> 1                                                                   NULL
#> 2                                                                   NULL
#> 3  2019, 99, Reported as Unknown if Impaired, 1, 24, Maryland, 240119, 0
#> 4            2019, 0, None/Apparently Normal, 1, 24, Maryland, 240190, 0
#> 5                                                                   NULL
#> 6                                                                   NULL
#> 7                                                                   NULL
#> 8            2019, 0, None/Apparently Normal, 1, 24, Maryland, 240096, 0
#> 9                                                                   NULL
#> 10 2019, 99, Reported as Unknown if Impaired, 1, 24, Maryland, 240048, 0
#>                                                                                                            nm_priors
#> 1                                                                                                               NULL
#> 2                                                                                                               NULL
#> 3                                                      2019, 3, Crossing Roadway, NA, NA, 1, 24, Maryland, 240119, 0
#> 4  2019, 12, Disabled Vehicle Related (Working on, Pushing, Leaving/Approaching), NA, NA, 1, 24, Maryland, 240190, 0
#> 5                                                                                                               NULL
#> 6                                                                                                               NULL
#> 7                                                                                                               NULL
#> 8                                                      2019, 3, Crossing Roadway, NA, NA, 1, 24, Maryland, 240096, 0
#> 9                                                                                                               NULL
#> 10  2019, 5, Movement Along Roadway with Traffic (In or Adjacent to Travel Lane), NA, NA, 1, 24, Maryland, 240048, 0
#>                                 safety_e_qs
#> 1                                      NULL
#> 2                                      NULL
#> 3  2019, NA, NA, 1, 24, Maryland, 240119, 0
#> 4  2019, NA, NA, 1, 24, Maryland, 240190, 0
#> 5                                      NULL
#> 6                                      NULL
#> 7                                      NULL
#> 8  2019, NA, NA, 1, 24, Maryland, 240096, 0
#> 9                                      NULL
#> 10 2019, NA, NA, 1, 24, Maryland, 240048, 0
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    park_works
#> 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        NULL
#> 2                        2019, 4, 4-door sedan, hardtop, 0, Not a Bus, 0, Not Applicable (N/A), 14, 1, 0, Not Applicable, 0, No or Not Reported, 0, Not Applicable, NA, NA, NA, NA, 14, Parked Motor Vehicle, 0, Not Applicable, 0, Not Applicable, 0, Not Applicable, 1, No, 0, Not Applicable, 0, No, 15, 3:00pm-3:59pm, NA, NA, 6, 6 Clock Point, NA, NA, 41, Mazda, NA, Mazda Mazda3, 0, The First Harmful Event was Not a Collision with a Motor Vehicle in Transport, 0, Not Applicable, 0, Not Applicable, 0, Not Applicable, 46, 46, 51, NA, 2018, 2018, 9, September, 12, Motor Vehicle In-Transport, 2, 2, 6, Driverless/Motor Vehicle Parked/Stopped Off Roadway, 34, New Jersey, 0, No Special Use, 2, Towed Due to Disabling Damage, 0, No Trailing Units, NA, NA, NA, No Trailing Units, NA, NA, NA, No Trailing Units, NA, NA, NA, No Trailing Units, 2, Motor Vehicle Not In-Transport Within the Trafficway, 0, No Underride or Override Noted, 0, None, 0, None, 6, Disabling Damage, 1, 3MZBN1V34JM2, 3MZBN1V34JM2, 3, J, M, 2, M, Z, B, N, 1, V, 3, 4, NA, NA, NA, NA, NA, NA, 0, Not Applicable, 24, Maryland, 240294, 2
#> 3                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        NULL
#> 4  2019, 51, Cross Country/Intercity Bus, 5, Charter/Tour, 22, Bus, 30, 0, 0, Not Applicable, 0, No or Not Reported, 3, 26,001 lbs. or more, NA, NA, NA, NA, 8, Pedestrian, 0, Not Applicable, 0, Not Applicable, 0, Not Applicable, 1, No, 0, Not Applicable, 0, No, 18, 6:00pm-6:59pm, NA, NA, 8, 8 Clock Point, NA, NA, 98, Other Make, NA, Other Make Van Hool, 0, The First Harmful Event was Not a Collision with a Motor Vehicle in Transport, 57, US DOT, 1759030, 1759030, 571759030, 571759030, 20, 20, 908, NA, 2012, 2012, 6, June, 12, Motor Vehicle In-Transport, 0, None, 6, Driverless/Motor Vehicle Parked/Stopped Off Roadway, 17, Illinois, 3, Vehicle Used as Other Bus, 5, Not Towed, 0, No Trailing Units, NA, NA, NA, No Trailing Units, NA, NA, NA, No Trailing Units, NA, NA, NA, No Trailing Units, 2, Motor Vehicle Not In-Transport Within the Trafficway, 0, No Underride or Override Noted, 0, None, 0, None, 2, Minor Damage, 1, YE2DG13B5C20, YE2DG13B5C20, Y, C, 2, 0, E, 2, D, G, 1, 3, B, 5, NA, NA, NA, NA, NA, NA, 21, Bus (seats for more than 15 occupants, including driver), 24, Maryland, 240190, 2
#> 5                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        NULL
#> 6                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        NULL
#> 7                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        NULL
#> 8                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        NULL
#> 9                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        NULL
#> 10                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       NULL
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     pb_types
#> 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       NULL
#> 2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       NULL
#> 3                                                                                                                                                                                                                                                                                                                                                                                                 158, 158, Bicyclist Failed to Yield - Signalized Intersection, Bicyclist Failed to Yield - Signalized Intersection, 153, 153, Bicyclist Ride Out - Signalized Intersection, Bicyclist Ride Out - Signalized Intersection, 2, 2, Facing Traffic, Facing Traffic, 1, 1, At Intersection, At Intersection, 1, 1, Travel Lane, Travel Lane, 2019, 2019, 7, 7, Not a Pedestrian, Not a Pedestrian, 7, 7, Not a Pedestrian, Not a Pedestrian, 55, 55, 55 Years, 55 Years, 0, 0, None Noted, None Noted, 6, 6, Bicyclist, Bicyclist, 1, 1, Male, Male, 0, 0, None Noted, None Noted, 0, 0, None Noted, None Noted, 0, 0, Not a Pedestrian, Not a Pedestrian, 0, 0, Not a Pedestrian, Not a Pedestrian, 7, 7, Not a Pedestrian, Not a Pedestrian, 7, 7, Not a Pedestrian, Not a Pedestrian, 7, 7, Not a Pedestrian, Not a Pedestrian, 77, 77, Not a Pedestrian, Not a Pedestrian, 7, 7, Not a Pedestrian, Not a Pedestrian, 1, 1, 24, 24, Maryland, Maryland, 240119, 240119, 0, 1
#> 4                                                                                                                                                                                                                                                                                                                                                                                                                                                               0, 0, Not a Cyclist, Not a Cyclist, 0, 0, Not a Cyclist, Not a Cyclist, 7, 7, Not a Cyclist, Not a Cyclist, 7, 7, Not a Cyclist, Not a Cyclist, 7, 7, Not a Cyclist, Not a Cyclist, 2019, 2019, 8, 8, Not Applicable, Not Applicable, 8, 8, Not Applicable, Not Applicable, 41, 41, 41 Years, 41 Years, 0, 0, None Noted, None Noted, 5, 5, Pedestrian, Pedestrian, 1, 1, Male, Male, 0, 0, None Noted, None Noted, 0, 0, None Noted, None Noted, 100, 100, Unusual Circumstances, Unusual Circumstances, 150, 150, Motor Vehicle Loss of Control, Motor Vehicle Loss of Control, 8, 8, Not Applicable, Not Applicable, 8, 8, Not Applicable, Not Applicable, 3, 3, Not At Intersection, Not At Intersection, 4, 4, Paved Shoulder / Bicycle Lane / Parking Lane, Paved Shoulder / Bicycle Lane / Parking Lane, 8, 8, Not Applicable, Not Applicable, 1, 1, 24, 24, Maryland, Maryland, 240190, 240190, 0, 1
#> 5                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       NULL
#> 6                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       NULL
#> 7                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       NULL
#> 8                                                                                                                                                                                                                                                                                                                                     0, 0, Not a Cyclist, Not a Cyclist, 0, 0, Not a Cyclist, Not a Cyclist, 7, 7, Not a Cyclist, Not a Cyclist, 7, 7, Not a Cyclist, Not a Cyclist, 7, 7, Not a Cyclist, Not a Cyclist, 2019, 2019, 4, 4, Westbound, Westbound, 3, 3, Straight through, Straight through, 12, 12, 12 Years, 12 Years, 0, 0, None Noted, None Noted, 5, 5, Pedestrian, Pedestrian, 2, 2, Female, Female, 0, 0, None Noted, None Noted, 0, 0, None Noted, None Noted, 740, 740, Dash / Dart-Out, Dash / Dart-Out, 741, 741, Dash, Dash, 3, 3, Southbound, Southbound, 2, 2, Farside, Farside, 1, 1, At Intersection, At Intersection, 1, 1, Intersection Area, Intersection Area, 4b, 4b, Motorist traveling straight through - Crash Occurred on Far Side of Intersection / Pedestrian outside crosswalk area, traveled from motorist`s right, Motorist traveling straight through - Crash Occurred on Far Side of Intersection / Pedestrian outside crosswalk area, traveled from motorist`s right, 1, 1, 24, 24, Maryland, Maryland, 240096, 240096, 0, 1
#> 9                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       NULL
#> 10 0, 0, 0, Not a Cyclist, Not a Cyclist, Not a Cyclist, 0, 0, 0, Not a Cyclist, Not a Cyclist, Not a Cyclist, 7, 7, 7, Not a Cyclist, Not a Cyclist, Not a Cyclist, 7, 7, 7, Not a Cyclist, Not a Cyclist, Not a Cyclist, 7, 7, 7, Not a Cyclist, Not a Cyclist, Not a Cyclist, 2019, 2019, 2019, 8, 8, 8, Not Applicable, Not Applicable, Not Applicable, 8, 8, 8, Not Applicable, Not Applicable, Not Applicable, 26, 26, 26, 26 Years, 26 Years, 26 Years, 0, 0, 0, None Noted, None Noted, None Noted, 5, 5, 5, Pedestrian, Pedestrian, Pedestrian, 1, 1, 1, Male, Male, Male, 0, 0, 0, None Noted, None Noted, None Noted, 0, 0, 0, None Noted, None Noted, None Noted, 400, 400, 400, Walking/Running Along Roadway, Walking/Running Along Roadway, Walking/Running Along Roadway, 410, 410, 410, Walking/Running Along Roadway With Traffic - From Behind, Walking/Running Along Roadway With Traffic - From Behind, Walking/Running Along Roadway With Traffic - From Behind, 8, 8, 8, Not Applicable, Not Applicable, Not Applicable, 8, 8, 8, Not Applicable, Not Applicable, Not Applicable, 3, 3, 3, Not At Intersection, Not At Intersection, Not At Intersection, 3, 3, 3, Travel Lane, Travel Lane, Travel Lane, 8, 8, 8, Not Applicable, Not Applicable, Not Applicable, 1, 1, 2, 24, 24, 24, Maryland, Maryland, Maryland, 240048, 240048, 240048, 0, 1, 1
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
