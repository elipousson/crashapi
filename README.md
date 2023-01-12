
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

## Installation

You can install the development version of crashapi using the pak
package:

``` r
pak::pkg_install("elipousson/crashapi")
```

## Background

### Fatality Analysis Reporting System (FARS) API support

Supported APIs for this package include:

- [x] Get Crash List Information
- [x] Get Crash Details
- [x] Get Crashes By Location
- [x] Get Crashes By Vehicle
- [x] Get Summary Counts
- [x] Get Variables and Get Variable Attributes
- [x] Get FARS Data By Year
- [x] Get Crashes By Occupant (partial support)

Most of these APIs support XML, JSV, CSV, and JSON output formats. This
package only uses JSON with the exception of `get_fars_year()` (which
supports downloading CSV files).

For reference, this package also includes a list of terms and NHTSA
technical definitions in `fars_terms` and a list of variable labels in
`fars_vars_labels`.

The FARS API currently provides access to data from 2010 to 2020. The
[NHTSA website](https://www-fars.nhtsa.dot.gov/Help/helplinks.aspx) also
provides additional information on the release data and version status
for the FARS data files available through the API:

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

### Additional data access functionality

The `get_fars_zip()` function can be used to access FARS data files from
1975 to 2020 that that are not available via the API but are available
for download on through [the NHTSA File Downloads
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

ggplot(md_summary, aes(x = case_year, y = total_fatal_counts)) +
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
    state = "NC",
    county = "Wake County",
    geometry = TRUE
  )

nc <- sf::st_read(system.file("shape/nc.shp", package = "sf"))
#> Reading layer `nc' from data source 
#>   `/Library/Frameworks/R.framework/Versions/4.2-arm64/Resources/library/sf/shape/nc.shp' 
#>   using driver `ESRI Shapefile'
#> Simple feature collection with 100 features and 14 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -84.32385 ymin: 33.88199 xmax: -75.45698 ymax: 36.58965
#> Geodetic CRS:  NAD27
wake_co <- sf::st_transform(nc[nc$NAME == "Wake", ], 4326)

# Map crashes
ggplot() +
  geom_sf(
    data = wake_co,
    fill = NA, color = "black"
  ) +
  geom_sf(
    data = sf::st_crop(crashes_sf, wake_co),
    aes(color = totalvehicles),
    alpha = 0.75
  ) +
  theme_void()
#> Warning in st_is_longlat(x): bounding box has potentially an invalid value range
#> for longlat data

#> Warning in st_is_longlat(x): bounding box has potentially an invalid value range
#> for longlat data
#> Warning: attribute variables are assumed to be spatially constant throughout all
#> geometries
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
#>     county_name                 crash_date fatals peds persons st_case state
#> 1     BRONX (5) /Date(1549865820000-0500)/      2    1       7  360042    36
#> 2     ERIE (29) /Date(1551915000000-0500)/      1    0       4  360159    36
#> 3   QUEENS (81) /Date(1561656240000-0400)/      1    0       6  360319    36
#> 4     BRONX (5) /Date(1561866000000-0400)/      1    0      11  360339    36
#> 5    KINGS (47) /Date(1564564080000-0400)/      1    0       5  360440    36
#> 6 SUFFOLK (103) /Date(1563792360000-0400)/      1    0       2  360551    36
#> 7   ORANGE (71) /Date(1558274040000-0400)/      1    0       1  360277    36
#>   state_name total_vehicles
#> 1   New York              5
#> 2   New York              5
#> 3   New York              5
#> 4   New York              5
#> 5   New York              5
#> 6   New York              6
#> 7   New York              6
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
#> ■■                                 2% | ETA:  2m
#> ■■■■■                             12% | ETA:  1m
#> ■■■■■■■                           20% | ETA: 40s
#> ■■■■■■■■■                         28% | ETA: 34s
#> ■■■■■■■■■■■                       35% | ETA: 29s
#> ■■■■■■■■■■■■■■                    42% | ETA: 25s
#> ■■■■■■■■■■■■■■■■                  50% | ETA: 22s
#> ■■■■■■■■■■■■■■■■■■■               60% | ETA: 17s
#> ■■■■■■■■■■■■■■■■■■■■■             68% | ETA: 14s
#> ■■■■■■■■■■■■■■■■■■■■■■■           75% | ETA: 10s
#> ■■■■■■■■■■■■■■■■■■■■■■■■■■■       85% | ETA:  6s
#> ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■     92% | ETA:  3s

# Show 10 fatal crashes at random
dplyr::slice_sample(crashes_detailed, n = 10)
#>    city       cityname county       countyname case_year fatals latitude
#> 1   584     FRIENDSHIP      3 ANNE ARUNDEL (3)      2019      1 38.73677
#> 2     0 NOT APPLICABLE      3 ANNE ARUNDEL (3)      2019      1 39.05691
#> 3     0 NOT APPLICABLE      3 ANNE ARUNDEL (3)      2019      1 39.08629
#> 4     0 NOT APPLICABLE      3 ANNE ARUNDEL (3)      2019      1 39.20137
#> 5     0 NOT APPLICABLE      3 ANNE ARUNDEL (3)      2019      1 39.19835
#> 6     0 NOT APPLICABLE      3 ANNE ARUNDEL (3)      2019      1 39.07551
#> 7     0 NOT APPLICABLE      3 ANNE ARUNDEL (3)      2019      1 39.21617
#> 8     0 NOT APPLICABLE      3 ANNE ARUNDEL (3)      2019      1 39.00808
#> 9     0 NOT APPLICABLE      3 ANNE ARUNDEL (3)      2019      1 39.20473
#> 10    0 NOT APPLICABLE      3 ANNE ARUNDEL (3)      2019      2 39.17068
#>     longitud state statename st_case       date  time            datetime
#> 1  -76.59366    24  Maryland  240318 2019-09-20 19:16 2019-09-20 19:16:00
#> 2  -76.52705    24  Maryland  240373 2019-11-10 18:10 2019-11-10 18:10:00
#> 3  -76.65953    24  Maryland  240162 2019-06-07 14:36 2019-06-07 14:36:00
#> 4  -76.61406    24  Maryland  240226 2019-08-04 19:57 2019-08-04 19:57:00
#> 5  -76.61325    24  Maryland  240238 2019-08-02 22:30 2019-08-02 22:30:00
#> 6  -76.62905    24  Maryland  240291 2019-09-12 08:00 2019-09-12 08:00:00
#> 7  -76.69841    24  Maryland  240069 2019-03-15 01:26 2019-03-15 01:26:00
#> 8  -76.60894    24  Maryland  240007 2019-01-09 05:38 2019-01-09 05:38:00
#> 9  -76.69075    24  Maryland  240294 2019-09-14 15:46 2019-09-14 15:46:00
#> 10 -76.73092    24  Maryland  240169 2019-06-14 22:30 2019-06-14 22:30:00
#>    totalvehicles                 tway_id               tway_id2 ve_forms
#> 1              1 SR-2 SOLOMONS ISLAND RD SR-261 W FRIENDSHIP RD        1
#> 2              1                    SR-2                   <NA>        1
#> 3              2                 CR-1178                   <NA>        2
#> 4              1                    SR-2                   <NA>        1
#> 5              1                    SR-2                   <NA>        1
#> 6              3                 CR-5461                   <NA>        3
#> 7              3                   I-195                   <NA>        3
#> 8              1                    I-97                   <NA>        1
#> 9              2                  SR-295                   <NA>        1
#> 10             2                  SR-295                   <NA>        2
#>    arr_hour                   arr_hourname arr_min
#> 1        99 Unknown EMS Scene Arrival Hour      99
#> 2        99 Unknown EMS Scene Arrival Hour      99
#> 3        99 Unknown EMS Scene Arrival Hour      99
#> 4        99 Unknown EMS Scene Arrival Hour      99
#> 5        99 Unknown EMS Scene Arrival Hour      99
#> 6        99 Unknown EMS Scene Arrival Hour      99
#> 7        99 Unknown EMS Scene Arrival Hour      99
#> 8        99 Unknown EMS Scene Arrival Hour      99
#> 9        99 Unknown EMS Scene Arrival Hour      99
#> 10       99 Unknown EMS Scene Arrival Hour      99
#>                          arr_minname cf1 cf1name cf2 cf2name cf3 cf3name
#> 1  Unknown EMS Scene Arrival Minutes   0    None   0    None   0    None
#> 2  Unknown EMS Scene Arrival Minutes   0    None   0    None   0    None
#> 3  Unknown EMS Scene Arrival Minutes   0    None   0    None   0    None
#> 4  Unknown EMS Scene Arrival Minutes   0    None   0    None   0    None
#> 5  Unknown EMS Scene Arrival Minutes   0    None   0    None   0    None
#> 6  Unknown EMS Scene Arrival Minutes   0    None   0    None   0    None
#> 7  Unknown EMS Scene Arrival Minutes   0    None   0    None   0    None
#> 8  Unknown EMS Scene Arrival Minutes   0    None   0    None   0    None
#> 9  Unknown EMS Scene Arrival Minutes   0    None   0    None   0    None
#> 10 Unknown EMS Scene Arrival Minutes   0    None   0    None   0    None
#>    crash_r_fs day day_week day_weekname drunk_dr func_sys
#> 1          NA  20        6       Friday        0        3
#> 2          NA  10        1       Sunday        0        3
#> 3          NA   7        6       Friday        0        5
#> 4          NA   4        1       Sunday        0        3
#> 5          NA   2        6       Friday        0        3
#> 6          NA  12        5     Thursday        0        4
#> 7          NA  15        6       Friday        1        1
#> 8          NA   9        4    Wednesday        0        1
#> 9          NA  14        7     Saturday        1        4
#> 10         NA  14        6       Friday        0        7
#>                  func_sysname harm_ev                harm_evname hosp_hr
#> 1  Principal Arterial - Other      33                       Curb      99
#> 2  Principal Arterial - Other       8                 Pedestrian      88
#> 3             Major Collector       1          Rollover/Overturn      88
#> 4  Principal Arterial - Other      24             Guardrail Face      88
#> 5  Principal Arterial - Other       8                 Pedestrian      88
#> 6              Minor Arterial      12 Motor Vehicle In-Transport      99
#> 7                  Interstate      12 Motor Vehicle In-Transport      99
#> 8                  Interstate       1          Rollover/Overturn      88
#> 9              Minor Arterial      14       Parked Motor Vehicle      99
#> 10                      Local      12 Motor Vehicle In-Transport      88
#>                         hosp_hrname hosp_mn                       hosp_mnname
#> 1                           Unknown      99 Unknown EMS Hospital Arrival Time
#> 2  Not Applicable (Not Transported)      88  Not Applicable (Not Transported)
#> 3  Not Applicable (Not Transported)      88  Not Applicable (Not Transported)
#> 4  Not Applicable (Not Transported)      88  Not Applicable (Not Transported)
#> 5  Not Applicable (Not Transported)      88  Not Applicable (Not Transported)
#> 6                           Unknown      99 Unknown EMS Hospital Arrival Time
#> 7                           Unknown      99 Unknown EMS Hospital Arrival Time
#> 8  Not Applicable (Not Transported)      88  Not Applicable (Not Transported)
#> 9                           Unknown      99 Unknown EMS Hospital Arrival Time
#> 10 Not Applicable (Not Transported)      88  Not Applicable (Not Transported)
#>    hour        hourname latitudename lgt_cond            lgt_condname
#> 1    19   7:00pm-7:59pm  38.73677222        3          Dark - Lighted
#> 2    18   6:00pm-6:59pm  39.05690556        2      Dark - Not Lighted
#> 3    14   2:00pm-2:59pm  39.08629167        1                Daylight
#> 4    19   7:00pm-7:59pm  39.20136667        1                Daylight
#> 5    22 10:00pm-10:59pm  39.19834722        6 Dark - Unknown Lighting
#> 6     8   8:00am-8:59am  39.07551111        1                Daylight
#> 7     1   1:00am-1:59am  39.21617222        2      Dark - Not Lighted
#> 8     5   5:00am-5:59am  39.00807778        2      Dark - Not Lighted
#> 9    15   3:00pm-3:59pm  39.20472500        1                Daylight
#> 10   22 10:00pm-10:59pm  39.17067778        3          Dark - Lighted
#>     longitudname man_coll
#> 1  -76.593663890        0
#> 2  -76.527052780        0
#> 3  -76.659530560        0
#> 4  -76.614061110        0
#> 5  -76.613247220        0
#> 6  -76.629047220        7
#> 7  -76.698411110        2
#> 8  -76.608936110        0
#> 9  -76.690747220        0
#> 10 -76.730925000        6
#>                                                                     man_collname
#> 1  The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 2  The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 3  The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 4  The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 5  The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 6                                                     Sideswipe - Same Direction
#> 7                                                                 Front-to-Front
#> 8  The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 9  The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 10                                                                         Angle
#>    milept mileptname minute minutename month month_name nhs
#> 1      12         12     16         16     9  September   1
#> 2     275        275     10         10    11   November   0
#> 3      20         20     36         36     6       June   0
#> 4     390        390     57         57     8     August   0
#> 5     388        388     30         30     8     August   0
#> 6       4          4      0          0     9  September   0
#> 7      26         26     26         26     3      March   1
#> 8      26         26     38         38     1    January   1
#> 9     119        119     46         46     9  September   0
#> 10      9          9     30         30     6       June   0
#>                           nhsname
#> 1      This section IS ON the NHS
#> 2  This section IS NOT on the NHS
#> 3  This section IS NOT on the NHS
#> 4  This section IS NOT on the NHS
#> 5  This section IS NOT on the NHS
#> 6  This section IS NOT on the NHS
#> 7      This section IS ON the NHS
#> 8      This section IS ON the NHS
#> 9  This section IS NOT on the NHS
#> 10 This section IS NOT on the NHS
#>                                                                                                                                                                                             nm_drugs
#> 1                                                                                                                                                                                               NULL
#> 2  2019, 2019, 2019, 996, 996, 996, Other Drug, Other Drug, Other Drug, 2, 2, 2, Urine, Urine, Urine, 1, 1, 1, 24, 24, 24, MD, MD, MD, Maryland, Maryland, Maryland, 240373, 240373, 240373, 0, 0, 0
#> 3                                                                                                                                                                                               NULL
#> 4                                                                                                                                                                                               NULL
#> 5                                                                                                           2019, 1, Tested, No Drugs Found/Negative, 1, Whole Blood, 1, 24, MD, Maryland, 240238, 0
#> 6                                                                                                                                                                                               NULL
#> 7                                                                                                                                                                                               NULL
#> 8                                                                                                                                                                                               NULL
#> 9                                                                                                                                                                                               NULL
#> 10                                                                                                                                                                                              NULL
#>    nm_person_rf
#> 1            NA
#> 2            NA
#> 3            NA
#> 4            NA
#> 5            NA
#> 6            NA
#> 7            NA
#> 8            NA
#> 9            NA
#> 10           NA
#>                                                                         nm_race
#> 1                                                                          NULL
#> 2                      2019, False, 1, 1, 1, White, 24, MD, Maryland, 240373, 0
#> 3                                                                          NULL
#> 4                                                                          NULL
#> 5  2019, False, 1, 1, 2, Black or African American, 24, MD, Maryland, 240238, 0
#> 6                                                                          NULL
#> 7                                                                          NULL
#> 8                                                                          NULL
#> 9                                                                          NULL
#> 10                                                                         NULL
#>    not_hour not_hourname not_min not_minname
#> 1        99      Unknown      99     Unknown
#> 2        99      Unknown      99     Unknown
#> 3        99      Unknown      99     Unknown
#> 4        99      Unknown      99     Unknown
#> 5        99      Unknown      99     Unknown
#> 6        99      Unknown      99     Unknown
#> 7        99      Unknown      99     Unknown
#> 8        99      Unknown      99     Unknown
#> 9        99      Unknown      99     Unknown
#> 10       99      Unknown      99     Unknown
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      n_persons
#> 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         NULL
#> 2  50, 50 Years, 97, Not a Motor Vehicle Occupant, 9, Not Reported, 130, 0.130 % BAC, 2, Test Given, 1, Blood, NA, NA, NA, 3, ANNE ARUNDEL (3), 2019, 10, 10, 10, 18, 18:00-18:59, 25, 25, 11, November, 1825, 1825, 2019, 2019, 7, Died at Scene, 1, Yes (Alcohol Involved), NA, NA, NA, NA, NA, NA, 8, Not Reported, NA, NA, NA, NA, NA, NA, 8, Not Reported, 2, Test Given, 8, Not Applicable, 0, Ejection Path Not Applicable, NA, NA, 0, Not Extricated or Not Applicable, NA, NA, 3, Principal Arterial - Other, 8, Pedestrian, 8, Not a Motor Vehicle Occupant, 96, Not a Motor Vehicle Occupant, 7, Non-Hispanic, 0, Not Transported, 18, 6:00pm-6:59pm, NA, NA, NA, NA, NA, NA, 4, Fatal Injury (K), 0, 0, 15, 15, 11, Not at Intersection - On Roadway, Not in Marked Crosswalk, NA, NA, NA, NA, 0, The First Harmful Event was Not a Collision with a Motor Vehicle in Transport, 10, 10, NA, NA, 11, November, NA, NA, 1, 5, Pedestrian, 0, None, 0, None, 0, None, NA, NA, NA, 8, Not a Motor Vehicle Occupant, 96, Not a Motor Vehicle Occupant, NA, NA, NA, NA, 2, Urban, NA, 0, No, 0, Not a Motor Vehicle Occupant, 1, Male, NA, NA, 24, Maryland, 1, NA, 240373, NA, NA, 0, 1, NA, NA, NA, NA, NA, NA, 0, No
#> 3                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         NULL
#> 4                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         NULL
#> 5       27, 27 Years, 97, Not a Motor Vehicle Occupant, 9, Not Reported, 0, 0.000 % BAC, 2, Test Given, 1, Blood, NA, NA, NA, 3, ANNE ARUNDEL (3), 2019, 2, 2, 2, 22, 22:00-22:59, 40, 40, 8, August, 2240, 2240, 2019, 2019, 7, Died at Scene, 9, Reported as Unknown, NA, NA, NA, NA, NA, NA, 9, Reported as Unknown, NA, NA, NA, NA, NA, NA, 8, Not Reported, 2, Test Given, 8, Not Applicable, 0, Ejection Path Not Applicable, NA, NA, 0, Not Extricated or Not Applicable, NA, NA, 3, Principal Arterial - Other, 8, Pedestrian, 8, Not a Motor Vehicle Occupant, 96, Not a Motor Vehicle Occupant, 7, Non-Hispanic, 0, Not Transported, 22, 10:00pm-10:59pm, NA, NA, NA, NA, NA, NA, 4, Fatal Injury (K), 0, 0, 10, 10, 11, Not at Intersection - On Roadway, Not in Marked Crosswalk, NA, NA, NA, NA, 0, The First Harmful Event was Not a Collision with a Motor Vehicle in Transport, 30, 30, NA, NA, 8, August, NA, NA, 1, 5, Pedestrian, 0, None, 0, None, 0, None, NA, NA, NA, 8, Not a Motor Vehicle Occupant, 96, Not a Motor Vehicle Occupant, NA, NA, NA, NA, 2, Urban, NA, 0, No, 0, Not a Motor Vehicle Occupant, 1, Male, NA, NA, 24, Maryland, 1, NA, 240238, NA, NA, 0, 1, NA, NA, NA, NA, NA, NA, 0, No
#> 6                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         NULL
#> 7                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         NULL
#> 8                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         NULL
#> 9                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         NULL
#> 10                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        NULL
#>                                                                                              nm_crashes
#> 1                                                                                                  NULL
#> 2  2019, 2, Failure to Yield Right-Of-Way, 2, Failure to Yield Right-Of-Way, 1, 24, Maryland, 240373, 0
#> 3                                                                                                  NULL
#> 4                                                                                                  NULL
#> 5  2019, 2, Failure to Yield Right-Of-Way, 2, Failure to Yield Right-Of-Way, 1, 24, Maryland, 240238, 0
#> 6                                                                                                  NULL
#> 7                                                                                                  NULL
#> 8                                                                                                  NULL
#> 9                                                                                                  NULL
#> 10                                                                                                 NULL
#>                                                                   nm_distract
#> 1                                                                        NULL
#> 2  2019, 0, Not Distracted, 0, Not Distracted, 1, 24, MD, Maryland, 240373, 0
#> 3                                                                        NULL
#> 4                                                                        NULL
#> 5    2019, 96, Not Reported, 96, Not Reported, 1, 24, MD, Maryland, 240238, 0
#> 6                                                                        NULL
#> 7                                                                        NULL
#> 8                                                                        NULL
#> 9                                                                        NULL
#> 10                                                                       NULL
#>                                                               nm_impairs
#> 1                                                                   NULL
#> 2                     2019, 98, Not Reported, 1, 24, Maryland, 240373, 0
#> 3                                                                   NULL
#> 4                                                                   NULL
#> 5  2019, 99, Reported as Unknown if Impaired, 1, 24, Maryland, 240238, 0
#> 6                                                                   NULL
#> 7                                                                   NULL
#> 8                                                                   NULL
#> 9                                                                   NULL
#> 10                                                                  NULL
#>                                                        nm_priors peds permvit
#> 1                                                           NULL    0       1
#> 2  2019, 3, Crossing Roadway, NA, NA, 1, 24, Maryland, 240373, 0    1       1
#> 3                                                           NULL    0       2
#> 4                                                           NULL    0       1
#> 5  2019, 3, Crossing Roadway, NA, NA, 1, 24, Maryland, 240238, 0    1       1
#> 6                                                           NULL    0       3
#> 7                                                           NULL    0       6
#> 8                                                           NULL    0       1
#> 9                                                           NULL    0       1
#> 10                                                          NULL    0       3
#>    pernotmvit persons pvh_invl
#> 1           0       1        0
#> 2           1       1        0
#> 3           0       2        0
#> 4           0       1        0
#> 5           1       1        0
#> 6           0       3        0
#> 7           0       6        0
#> 8           0       1        0
#> 9           2       3        1
#> 10          0       3        0
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              park_works
#> 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  NULL
#> 2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  NULL
#> 3                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  NULL
#> 4                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  NULL
#> 5                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  NULL
#> 6                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  NULL
#> 7                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  NULL
#> 8                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  NULL
#> 9  2019, 4, 4-door sedan, hardtop, 0, Not a Bus, 0, Not Applicable (N/A), 14, 1, 0, Not Applicable, 0, No or Not Reported, 0, Not Applicable, NA, NA, NA, NA, 14, Parked Motor Vehicle, 0, Not Applicable, 0, Not Applicable, 0, Not Applicable, 1, No, 0, Not Applicable, 0, No, 15, 3:00pm-3:59pm, NA, NA, 6, 6 Clock Point, NA, NA, 41, Mazda, NA, Mazda Mazda3, 0, The First Harmful Event was Not a Collision with a Motor Vehicle in Transport, 0, Not Applicable, 0, Not Applicable, 0, Not Applicable, 46, 46, 51, NA, 2018, 2018, 9, September, 12, Motor Vehicle In-Transport, 2, 2, 6, Driverless/Motor Vehicle Parked/Stopped Off Roadway, 34, New Jersey, 0, No Special Use, 2, Towed Due to Disabling Damage, 0, No Trailing Units, NA, NA, NA, No Trailing Units, NA, NA, NA, No Trailing Units, NA, NA, NA, No Trailing Units, 2, Motor Vehicle Not In-Transport Within the Trafficway, 0, No Underride or Override Noted, 0, None, 0, None, 6, Disabling Damage, 1, 3MZBN1V34JM2, 3MZBN1V34JM2, 3, J, M, 2, M, Z, B, N, 1, V, 3, 4, NA, NA, NA, NA, NA, NA, 0, Not Applicable, 24, Maryland, 240294, 2
#> 10                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 NULL
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  pb_types
#> 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    NULL
#> 2  0, 0, Not a Cyclist, Not a Cyclist, 0, 0, Not a Cyclist, Not a Cyclist, 7, 7, Not a Cyclist, Not a Cyclist, 7, 7, Not a Cyclist, Not a Cyclist, 7, 7, Not a Cyclist, Not a Cyclist, 2019, 2019, 8, 8, Not Applicable, Not Applicable, 8, 8, Not Applicable, Not Applicable, 50, 50, 50 Years, 50 Years, 0, 0, None Noted, None Noted, 5, 5, Pedestrian, Pedestrian, 1, 1, Male, Male, 0, 0, None Noted, None Noted, 0, 0, None Noted, None Noted, 750, 750, Crossing Roadway - Vehicle Not Turning, Crossing Roadway - Vehicle Not Turning, 760, 760, Pedestrian Failed to Yield, Pedestrian Failed to Yield, 8, 8, Not Applicable, Not Applicable, 8, 8, Not Applicable, Not Applicable, 3, 3, Not At Intersection, Not At Intersection, 3, 3, Travel Lane, Travel Lane, 8, 8, Not Applicable, Not Applicable, 1, 1, 24, 24, Maryland, Maryland, 240373, 240373, 0, 1
#> 3                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    NULL
#> 4                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    NULL
#> 5  0, 0, Not a Cyclist, Not a Cyclist, 0, 0, Not a Cyclist, Not a Cyclist, 7, 7, Not a Cyclist, Not a Cyclist, 7, 7, Not a Cyclist, Not a Cyclist, 7, 7, Not a Cyclist, Not a Cyclist, 2019, 2019, 8, 8, Not Applicable, Not Applicable, 8, 8, Not Applicable, Not Applicable, 27, 27, 27 Years, 27 Years, 0, 0, None Noted, None Noted, 5, 5, Pedestrian, Pedestrian, 1, 1, Male, Male, 0, 0, None Noted, None Noted, 0, 0, None Noted, None Noted, 750, 750, Crossing Roadway - Vehicle Not Turning, Crossing Roadway - Vehicle Not Turning, 760, 760, Pedestrian Failed to Yield, Pedestrian Failed to Yield, 8, 8, Not Applicable, Not Applicable, 8, 8, Not Applicable, Not Applicable, 3, 3, Not At Intersection, Not At Intersection, 3, 3, Travel Lane, Travel Lane, 8, 8, Not Applicable, Not Applicable, 1, 1, 24, 24, Maryland, Maryland, 240238, 240238, 0, 1
#> 6                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    NULL
#> 7                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    NULL
#> 8                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    NULL
#> 9                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    NULL
#> 10                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   NULL
#>       rail       railname rd_owner          rd_ownername reljct1 reljct1name
#> 1  0000000 Not Applicable        1  State Highway Agency       0          No
#> 2  0000000 Not Applicable        1  State Highway Agency       0          No
#> 3  0000000 Not Applicable        2 County Highway Agency       0          No
#> 4  0000000 Not Applicable        1  State Highway Agency       0          No
#> 5  0000000 Not Applicable        1  State Highway Agency       0          No
#> 6  0000000 Not Applicable        2 County Highway Agency       0          No
#> 7  0000000 Not Applicable        1  State Highway Agency       0          No
#> 8  0000000 Not Applicable        1  State Highway Agency       0          No
#> 9  0000000 Not Applicable        1  State Highway Agency       1         Yes
#> 10 0000000 Not Applicable        1  State Highway Agency       0          No
#>    reljct2                            reljct2name rel_road rel_roadname
#> 1        3                   Intersection-Related        4  On Roadside
#> 2        1                           Non-Junction        1   On Roadway
#> 3        1                           Non-Junction        1   On Roadway
#> 4        1                           Non-Junction        3    On Median
#> 5        1                           Non-Junction        1   On Roadway
#> 6        1                           Non-Junction        1   On Roadway
#> 7        1                           Non-Junction        1   On Roadway
#> 8        1                           Non-Junction        3    On Median
#> 9       19 Other location within Interchange Area        8         Gore
#> 10       5             Entrance/Exit Ramp Related        1   On Roadway
#>    road_fnc road_fncname route     routename rur_urb rur_urbname sch_bus
#> 1        NA           NA     3 State Highway       1       Rural       0
#> 2        NA           NA     3 State Highway       2       Urban       0
#> 3        NA           NA     4   County Road       2       Urban       0
#> 4        NA           NA     3 State Highway       2       Urban       0
#> 5        NA           NA     3 State Highway       2       Urban       0
#> 6        NA           NA     4   County Road       2       Urban       0
#> 7        NA           NA     1    Interstate       2       Urban       0
#> 8        NA           NA     1    Interstate       2       Urban       0
#> 9        NA           NA     3 State Highway       2       Urban       0
#> 10       NA           NA     3 State Highway       2       Urban       0
#>    sch_busname sp_jur              sp_jurname
#> 1           No      0 No Special Jurisdiction
#> 2           No      0 No Special Jurisdiction
#> 3           No      0 No Special Jurisdiction
#> 4           No      0 No Special Jurisdiction
#> 5           No      0 No Special Jurisdiction
#> 6           No      0 No Special Jurisdiction
#> 7           No      0 No Special Jurisdiction
#> 8           No      0 No Special Jurisdiction
#> 9           No      0 No Special Jurisdiction
#> 10          No      0 No Special Jurisdiction
#>                                 safety_e_qs state_2 typ_int         typ_intname
#> 1                                      NULL      24       6          Roundabout
#> 2  2019, NA, NA, 1, 24, Maryland, 240373, 0      24       1 Not an Intersection
#> 3                                      NULL      24       1 Not an Intersection
#> 4                                      NULL      24       1 Not an Intersection
#> 5  2019, NA, NA, 1, 24, Maryland, 240238, 0      24       1 Not an Intersection
#> 6                                      NULL      24       1 Not an Intersection
#> 7                                      NULL      24       1 Not an Intersection
#> 8                                      NULL      24       1 Not an Intersection
#> 9                                      NULL      24       1 Not an Intersection
#> 10                                     NULL      24       1 Not an Intersection
#>    ve_total weather weather1 weather1name weather2
#> 1         1       1        1        Clear        0
#> 2         1       1        1        Clear        0
#> 3         2       1        1        Clear        0
#> 4         1       1        1        Clear        0
#> 5         1      98       98 Not Reported        0
#> 6         3       1        1        Clear        0
#> 7         3      98       98 Not Reported        0
#> 8         1       1        1        Clear        0
#> 9         2      10       10       Cloudy        0
#> 10        2       1        1        Clear        0
#>                            weather2name  weathername wrk_zone wrk_zonename
#> 1  No Additional Atmospheric Conditions        Clear        0         None
#> 2  No Additional Atmospheric Conditions        Clear        0         None
#> 3  No Additional Atmospheric Conditions        Clear        0         None
#> 4  No Additional Atmospheric Conditions        Clear        0         None
#> 5  No Additional Atmospheric Conditions Not Reported        0         None
#> 6  No Additional Atmospheric Conditions        Clear        0         None
#> 7  No Additional Atmospheric Conditions Not Reported        0         None
#> 8  No Additional Atmospheric Conditions        Clear        0         None
#> 9  No Additional Atmospheric Conditions       Cloudy        0         None
#> 10 No Additional Atmospheric Conditions        Clear        0         None
#>    weathers year
#> 1        NA 2019
#> 2        NA 2019
#> 3        NA 2019
#> 4        NA 2019
#> 5        NA 2019
#> 6        NA 2019
#> 7        NA 2019
#> 8        NA 2019
#> 9        NA 2019
#> 10       NA 2019
```

## Related packages and projects

- [rfars](https://github.com/s87jackson/rfars) aims to “simplify the
  process of analyzing FARS data” by providing access to FARS downloads
  and preprocessed data back to 2015.
- [stats19](https://github.com/ropensci/stats19) “provides functions for
  downloading and formatting road crash data” from “the UK’s official
  road traffic casualty database, STATS19.”
- [njtr1](https://github.com/gavinrozzi/njtr1): “An R interface to New
  Jersey traffic crash data reported on form NJTR-1.”
- [wisdotcrashdatabase](https://github.com/jacciz/wisdotcrashdatabase):
  “A package used for internal WisDOT crash database pulls and
  analysis.”
- [nzcrash](https://github.com/nacnudus/nzcrash): “An R package to
  distribute New Zealand crash data in a convenient form.”
- [GraphHopper Open Traffic
  Collection](https://github.com/graphhopper/open-traffic-collection):
  “Collections of URLs pointing to traffic information portals which
  contain open data or at least data which is free to use.”
- [Open Crash Data
  Index](https://docs.google.com/spreadsheets/d/1rmn6GbHNkfWLLDEEmA87iuy2yHdh7hBybCTZiQJEY0k/edit?usp=sharing):
  A Google Sheet listing a range of city, county, regional and state
  sources for crash data including non-injury crashes as well as the
  fatal crashes available through the FARS API. Contributions for crash
  data from other U.S. cities and states are welcome.
