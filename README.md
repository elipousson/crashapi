
<!-- README.md is generated from README.Rmd. Please edit that file -->

# crashapi

<!-- badges: start -->
<!-- badges: end -->

The goal of crashapi is to provides functions for downloading data from
the National Highway Traffic Safety Administration (NHTSA) [Fatality
Analysis Reporting System (FARS)
API](https://crashviewer.nhtsa.dot.gov/CrashAPI/). The NHTSA website
explains the purpose of the API:

> The NHTSA Crash data Application Programming Interface (API) provides
> various ways to get crash data collected by DOT NHTSA’s Fatality
> Analysis Reporting System (FARS) program. The APIs are primarily
> targeted for developers, programmers or researchers interested in
> obtaining Crash statistics on Fatal Motor Vehicle Crashes. The API
> supports multiple data output formats, namely, XML, CSV/XLSX, JSV and
> JSON. FARS data starting from 2010 onwards is made available through
> this website. There are different APIs provided to make it easier to
> query specific data.

Currently three of the 3 of the 9 query APIs are supported by this
package.

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
# Get crashes in NY from 2019 with 5 to 10 vehicles
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
# Get crashes for Baltimore County, MD from 2014 to 2015
get_fars_crashes(
  start_year = 2014,
  end_year = 2015,
  state = "MD",
  county = "Baltimore County") |>
  # Show 10 fatal crashes at random
  dplyr::slice_sample(n = 10)
#>    CITY       CITYNAME COUNTY    COUNTYNAME CaseYear FATALS    LATITUDE
#> 1     0 NOT APPLICABLE      5 BALTIMORE (5)     2014      1 39.45480833
#> 2     0 NOT APPLICABLE      5 BALTIMORE (5)     2014      1 39.34865278
#> 3     0 NOT APPLICABLE      5 BALTIMORE (5)     2015      1 39.37956667
#> 4     0 NOT APPLICABLE      5 BALTIMORE (5)     2015      1 39.32650000
#> 5   543          ESSEX      5 BALTIMORE (5)     2014      1 39.30697500
#> 6     0 NOT APPLICABLE      5 BALTIMORE (5)     2015      2 39.29557500
#> 7     0 NOT APPLICABLE      5 BALTIMORE (5)     2014      1 39.45822500
#> 8     0 NOT APPLICABLE      5 BALTIMORE (5)     2015      1 39.29632222
#> 9     0 NOT APPLICABLE      5 BALTIMORE (5)     2015      1 39.33761667
#> 10    0 NOT APPLICABLE      5 BALTIMORE (5)     2015      1 39.47094167
#>         LONGITUD STATE STATENAME ST_CASE TOTALVEHICLES TWAY_ID TWAY_ID2
#> 1  -76.415350000    24  Maryland  240373             3    US-1         
#> 2  -76.497319440    24  Maryland  240122             2    I-95         
#> 3  -76.777680560    24  Maryland  240254             3 CR-2200  CR-2202
#> 4  -76.423050000    24  Maryland  240101             1  SR-587         
#> 5  -76.443363890    24  Maryland  240200             1 CR-4967  CR-4849
#> 6  -76.524544440    24  Maryland  240244             2  SR-151  CR-5148
#> 7  -76.633777780    24  Maryland  240297             2   SR-45         
#> 8  -76.734202780    24  Maryland  240437             1 CR-2511         
#> 9  -76.744733330    24  Maryland  240018             1   I-695         
#> 10 -76.660891670    24  Maryland  240224             1    I-83         
#>    VE_FORMS
#> 1         3
#> 2         2
#> 3         3
#> 4         1
#> 5         1
#> 6         2
#> 7         2
#> 8         1
#> 9         1
#> 10        1
```

``` r
# Get crashes for Baltimore County, MD from 2014 to 2015
# Set geometry to TRUE to return an sf object
crashes <-
  get_fars_crashes(
    start_year = 2014,
    end_year = 2015,
    state = "MD",
    county = "Baltimore County",
    geometry = TRUE
  )

# Map crashes
ggplot() +
  geom_sf(data = dplyr::filter(mapbaltimore::baltimore_msa_counties, namelsad == "Baltimore County"), fill = NA, color = "black") +
  geom_sf(data = crashes, aes(color = TOTALVEHICLES)) +
  theme_void()
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
