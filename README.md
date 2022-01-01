
<!-- README.md is generated from README.Rmd. Please edit that file -->

# crashapi

<!-- badges: start -->
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
-   [x] Get Summary Counts
-   [x] Get Variables and Get Variable Attributes
-   [x] Get FARS Data By Year

Most of these APIs support XML, JSV, CSV, and JSON output formats. This
package only uses JSON with the exception of get\_fars\_year (which
supports downloading CSV files).

Currently unsupported APIs include:

-   [ ] Get Crashes By Vehicle
-   [ ] Get Crashes By Occupant

Pull requests are welcome if you are interested in adding support for
these APIs to the package. For reference, this package also includes a
list of terms and NHTSA technical definitions in `fars_terms`.

The FARS API currently only provides access to data from 2010 to 2019.
Earlier data along with data from the the [General Estimates
System](https://www.nhtsa.gov/national-automotive-sampling-system-nass/nass-general-estimates-system)
(GES) / [Crash Report Sampling
System](https://www.nhtsa.gov/crash-data-systems/crash-report-sampling-system-crss)
(CRSS) is available through the [Fatality and Injury Reporting System
Tool](https://cdan.dot.gov/query) (FIRST).

The [NHTSA website](https://www-fars.nhtsa.dot.gov/Help/helplinks.aspx)
also provides additional information on the release data and version
status for the FARS Dataset:

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

``` r
# Get fatal crashes in NY from 2019 with 5 to 10 vehicles
get_fars_crash_list(
  start_year = 2019,
  end_year = 2019,
  state = "NY",
  vehicles = c(5,10)
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

``` r
# Get fatal crashes for Baltimore County, MD from 2017 to 2018
get_fars_crashes(
  start_year = 2017,
  end_year = 2018,
  state = "MD",
  county = "Baltimore County") |>
  # Show 10 fatal crashes at random
  dplyr::slice_sample(n = 10)
#>    CITY       CITYNAME COUNTY    COUNTYNAME CaseYear FATALS    LATITUDE
#> 1     0 NOT APPLICABLE      5 BALTIMORE (5)     2017      1 39.39542500
#> 2     0 NOT APPLICABLE      5 BALTIMORE (5)     2018      1 39.30686389
#> 3     0 NOT APPLICABLE      5 BALTIMORE (5)     2018      1 39.32589722
#> 4     0 NOT APPLICABLE      5 BALTIMORE (5)     2017      1 39.27750278
#> 5     0 NOT APPLICABLE      5 BALTIMORE (5)     2018      2 39.23797778
#> 6     0 NOT APPLICABLE      5 BALTIMORE (5)     2018      1 39.40715278
#> 7     0 NOT APPLICABLE      5 BALTIMORE (5)     2017      1 39.32919167
#> 8     0 NOT APPLICABLE      5 BALTIMORE (5)     2017      1 39.32236667
#> 9     0 NOT APPLICABLE      5 BALTIMORE (5)     2017      1 39.39217222
#> 10    0 NOT APPLICABLE      5 BALTIMORE (5)     2018      1 39.59704722
#>         LONGITUD STATE STATENAME ST_CASE TOTALVEHICLES   TWAY_ID TWAY_ID2
#> 1  -76.407447220    24  Maryland  240077             1     US-40         
#> 2  -76.741608330    24  Maryland  240007             1 I-70 RAMP         
#> 3  -76.497469440    24  Maryland  240206             2     US-40  CR-4447
#> 4  -76.488580560    24  Maryland  240043             1   CR-5500         
#> 5  -76.706641670    24  Maryland  240301             2      I-95         
#> 6  -76.631930560    24  Maryland  240495             2    SR-139         
#> 7  -76.466880560    24  Maryland  240079             1   CR-4552         
#> 8  -76.750622220    24  Maryland  240166             1   CR-2356         
#> 9  -76.763561110    24  Maryland  240201             2     I-795         
#> 10 -76.664830560    24  Maryland  240222             1      I-83         
#>    VE_FORMS
#> 1         1
#> 2         1
#> 3         2
#> 4         1
#> 5         2
#> 6         2
#> 7         1
#> 8         1
#> 9         1
#> 10        1
```

``` r
# Get crashes for Baltimore County, MD from 2014
crashes <-
  get_fars_crashes(
    start_year = 2014,
    end_year = 2014,
    state = "MD",
    county = "Baltimore County",
    geometry = TRUE
  )

# Map crashes
ggplot() +
  geom_sf(
    data = tigris::county_subdivisions(state = "MD", county = "Baltimore County"),
    fill = NA, color = "black"
  ) +
  geom_sf(
    data = crashes,
    aes(color = TOTALVEHICLES)
  ) +
  theme_void()
#> Downloading: 14 kB     Downloading: 14 kB     Downloading: 23 kB     Downloading: 23 kB     Downloading: 23 kB     Downloading: 23 kB     Downloading: 25 kB     Downloading: 25 kB     Downloading: 37 kB     Downloading: 37 kB     Downloading: 40 kB     Downloading: 40 kB     Downloading: 52 kB     Downloading: 52 kB     Downloading: 58 kB     Downloading: 58 kB     Downloading: 63 kB     Downloading: 63 kB     Downloading: 69 kB     Downloading: 69 kB     Downloading: 75 kB     Downloading: 75 kB     Downloading: 80 kB     Downloading: 80 kB     Downloading: 88 kB     Downloading: 88 kB     Downloading: 88 kB     Downloading: 88 kB     Downloading: 99 kB     Downloading: 99 kB     Downloading: 120 kB     Downloading: 120 kB     Downloading: 120 kB     Downloading: 120 kB     Downloading: 130 kB     Downloading: 130 kB     Downloading: 130 kB     Downloading: 130 kB     Downloading: 140 kB     Downloading: 140 kB     Downloading: 150 kB     Downloading: 150 kB     Downloading: 170 kB     Downloading: 170 kB     Downloading: 200 kB     Downloading: 200 kB     Downloading: 200 kB     Downloading: 200 kB     Downloading: 230 kB     Downloading: 230 kB     Downloading: 280 kB     Downloading: 280 kB     Downloading: 300 kB     Downloading: 300 kB     Downloading: 320 kB     Downloading: 320 kB     Downloading: 330 kB     Downloading: 330 kB     Downloading: 350 kB     Downloading: 350 kB     Downloading: 370 kB     Downloading: 370 kB     Downloading: 370 kB     Downloading: 370 kB     Downloading: 400 kB     Downloading: 400 kB     Downloading: 430 kB     Downloading: 430 kB     Downloading: 450 kB     Downloading: 450 kB     Downloading: 490 kB     Downloading: 490 kB     Downloading: 560 kB     Downloading: 560 kB     Downloading: 560 kB     Downloading: 560 kB     Downloading: 610 kB     Downloading: 610 kB     Downloading: 630 kB     Downloading: 630 kB     Downloading: 630 kB     Downloading: 630 kB     Downloading: 650 kB     Downloading: 650 kB     Downloading: 690 kB     Downloading: 690 kB     Downloading: 740 kB     Downloading: 740 kB     Downloading: 750 kB     Downloading: 750 kB     Downloading: 800 kB     Downloading: 800 kB     Downloading: 820 kB     Downloading: 820 kB     Downloading: 880 kB     Downloading: 880 kB     Downloading: 920 kB     Downloading: 920 kB     Downloading: 930 kB     Downloading: 930 kB     Downloading: 970 kB     Downloading: 970 kB     Downloading: 1 MB     Downloading: 1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.1 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.2 MB     Downloading: 1.3 MB     Downloading: 1.3 MB     Downloading: 1.3 MB     Downloading: 1.3 MB     Downloading: 1.3 MB     Downloading: 1.3 MB     Downloading: 1.4 MB     Downloading: 1.4 MB     Downloading: 1.4 MB     Downloading: 1.4 MB     Downloading: 1.4 MB     Downloading: 1.4 MB     Downloading: 1.4 MB     Downloading: 1.4 MB     Downloading: 1.4 MB     Downloading: 1.4 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.5 MB     Downloading: 1.6 MB     Downloading: 1.6 MB     Downloading: 1.6 MB     Downloading: 1.6 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.7 MB     Downloading: 1.8 MB     Downloading: 1.8 MB     Downloading: 1.8 MB     Downloading: 1.8 MB     Downloading: 1.8 MB     Downloading: 1.8 MB     Downloading: 1.8 MB     Downloading: 1.8 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 1.9 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.1 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.2 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.3 MB     Downloading: 2.4 MB     Downloading: 2.4 MB     Downloading: 2.5 MB     Downloading: 2.5 MB     Downloading: 2.5 MB     Downloading: 2.5 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.6 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.7 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.8 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 2.9 MB     Downloading: 3 MB     Downloading: 3 MB     Downloading: 3 MB     Downloading: 3 MB     Downloading: 3 MB     Downloading: 3 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB     Downloading: 3.1 MB
```

<img src="man/figures/README-map_fars_crashes-1.png" width="100%" />

``` r
# Get summary crash count and fatal crash count data for Maryland from 2010 to 2019
get_fars_summary(
  start_year = 2010,
  end_year = 2019,
  state = "MD"
)
#>    CaseYear CrashCounts TotalFatalCounts
#> 1      2010         463              496
#> 2      2011         455              485
#> 3      2012         462              511
#> 4      2013         431              465
#> 5      2014         416              442
#> 6      2015         479              520
#> 7      2016         484              522
#> 8      2017         518              558
#> 9      2018         485              512
#> 10     2019         484              521
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
