
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
technical definitions in `fars_terms`.

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
#> 1     0 NOT APPLICABLE      5 BALTIMORE (5)     2017      1 39.37209167
#> 2     0 NOT APPLICABLE      5 BALTIMORE (5)     2018      1 39.53543333
#> 3     0 NOT APPLICABLE      5 BALTIMORE (5)     2017      1 39.38739722
#> 4     0 NOT APPLICABLE      5 BALTIMORE (5)     2018      1 39.34260278
#> 5     0 NOT APPLICABLE      5 BALTIMORE (5)     2018      1 39.24831944
#> 6     0 NOT APPLICABLE      5 BALTIMORE (5)     2017      2 39.42957778
#> 7     0 NOT APPLICABLE      5 BALTIMORE (5)     2018      1 39.24068611
#> 8     0 NOT APPLICABLE      5 BALTIMORE (5)     2017      1 39.32246111
#> 9     0 NOT APPLICABLE      5 BALTIMORE (5)     2018      2 39.68845556
#> 10    0 NOT APPLICABLE      5 BALTIMORE (5)     2017      1 39.66936944
#>         LONGITUD STATE STATENAME ST_CASE TOTALVEHICLES TWAY_ID TWAY_ID2
#> 1  -76.720697220    24  Maryland  240462             1  SR-140         
#> 2  -76.728091670    24  Maryland  240142             2   SR-25   SR-128
#> 3  -76.623925000    24  Maryland  240380             1  SR-139         
#> 4  -76.479944440    24  Maryland  240320             2    SR-7         
#> 5  -76.677350000    24  Maryland  240131             4   I-695         
#> 6  -76.386275000    24  Maryland  240224             2    I-95         
#> 7  -76.680222220    24  Maryland  240460             2  US-1AL  CR-3178
#> 8  -76.504061110    24  Maryland  240298            11   US-40         
#> 9  -76.644813890    24  Maryland  240354             4    I-83         
#> 10 -76.802547220    24  Maryland  240483             2   CR-14    CR-15
#>    VE_FORMS
#> 1         1
#> 2         2
#> 3         1
#> 4         1
#> 5         4
#> 6         1
#> 7         2
#> 8         1
#> 9         4
#> 10        2
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
#>   |                                                                              |                                                                      |   0%  |                                                                              |                                                                      |   1%  |                                                                              |=                                                                     |   1%  |                                                                              |=                                                                     |   2%  |                                                                              |==                                                                    |   2%  |                                                                              |==                                                                    |   3%  |                                                                              |==                                                                    |   4%  |                                                                              |===                                                                   |   4%  |                                                                              |===                                                                   |   5%  |                                                                              |====                                                                  |   5%  |                                                                              |====                                                                  |   6%  |                                                                              |=====                                                                 |   7%  |                                                                              |=====                                                                 |   8%  |                                                                              |======                                                                |   8%  |                                                                              |======                                                                |   9%  |                                                                              |=======                                                               |  10%  |                                                                              |========                                                              |  11%  |                                                                              |========                                                              |  12%  |                                                                              |=========                                                             |  13%  |                                                                              |=========                                                             |  14%  |                                                                              |==========                                                            |  15%  |                                                                              |============                                                          |  17%  |                                                                              |================                                                      |  23%  |                                                                              |=================                                                     |  24%  |                                                                              |===================                                                   |  27%  |                                                                              |====================                                                  |  28%  |                                                                              |=====================                                                 |  30%  |                                                                              |======================                                                |  31%  |                                                                              |=======================                                               |  33%  |                                                                              |========================                                              |  34%  |                                                                              |=========================                                             |  36%  |                                                                              |==========================                                            |  37%  |                                                                              |===========================                                           |  38%  |                                                                              |==============================                                        |  43%  |                                                                              |===============================                                       |  44%  |                                                                              |=================================                                     |  47%  |                                                                              |==================================                                    |  48%  |                                                                              |===================================                                   |  50%  |                                                                              |====================================                                  |  51%  |                                                                              |======================================                                |  54%  |                                                                              |=======================================                               |  56%  |                                                                              |========================================                              |  57%  |                                                                              |========================================                              |  58%  |                                                                              |============================================                          |  62%  |                                                                              |============================================                          |  63%  |                                                                              |=============================================                         |  64%  |                                                                              |===============================================                       |  68%  |                                                                              |=================================================                     |  69%  |                                                                              |=================================================                     |  71%  |                                                                              |==================================================                    |  72%  |                                                                              |===================================================                   |  73%  |                                                                              |====================================================                  |  74%  |                                                                              |======================================================                |  78%  |                                                                              |========================================================              |  80%  |                                                                              |==========================================================            |  83%  |                                                                              |===========================================================           |  85%  |                                                                              |============================================================          |  85%  |                                                                              |============================================================          |  86%  |                                                                              |=============================================================         |  87%  |                                                                              |==============================================================        |  89%  |                                                                              |===============================================================       |  90%  |                                                                              |================================================================      |  91%  |                                                                              |=================================================================     |  92%  |                                                                              |=================================================================     |  93%  |                                                                              |==================================================================    |  95%  |                                                                              |===================================================================   |  95%  |                                                                              |====================================================================  |  97%  |                                                                              |===================================================================== |  98%  |                                                                              |======================================================================| 100%
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
