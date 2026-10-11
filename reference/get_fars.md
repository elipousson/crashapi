# Get Fatality Analysis Reporting System (FARS) data tables

`get_fars()` returns a FARS data table (e.g. accident, person, or
vehicle) for one or more states, an optional county, and one or more
years, using the CrashAPI or the zipped data files from the NHTSA
downloads site:

## Usage

``` r
get_fars(
  state = NULL,
  year = getOption("crashapi.year", 2024),
  type = "accident",
  county = NULL,
  source = c("auto", "api", "zip"),
  ...,
  geometry = FALSE,
  crs = NULL,
  labels = TRUE
)
```

## Arguments

- state:

  One or more state names, abbreviations, or FIPS numbers. If `NULL`
  (default), returns national data. Use "PR" for Puerto Rico.

- year:

  One or more years from 1975 to 2024 (or from 2010 for the CrashAPI).
  The minimum and maximum values are used as the start and end year,
  with a message if `year` has gaps. Defaults to
  `getOption("crashapi.year", 2024)`.

- type:

  Name of the FARS data table, e.g. "accident" (default), "person", or
  "vehicle". Lowercase or uppercase values are permitted. The available
  tables vary by year and source; see
  [`get_fars_year()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md)
  for tables available from the CrashAPI.

- county:

  County name or FIPS number. Requires a single `state`.

- source:

  Source for the data: "auto" (default), "api" for the CrashAPI, or
  "zip" for zipped data files.

- ...:

  Additional parameters passed to
  [`get_fars_zip()`](https://elipousson.github.io/crashapi/reference/get_fars_zip.md)
  when data comes from zipped data files, e.g. `path`, `overwrite`, or
  `keep_files`.

- geometry:

  If `TRUE`, return an sf object. Only supported for tables with
  `LATITUDE` and `LONGITUD` columns (e.g. accident).

- crs:

  Coordinate reference system to use if `geometry` is `TRUE`.

- labels:

  If `TRUE` (default), add a `"label"` attribute to each column with a
  variable label from
  [fars_vars_labels](https://elipousson.github.io/crashapi/reference/fars_vars_labels.md).
  Labels are shown by [`View()`](https://rdrr.io/r/utils/View.html) in
  RStudio and Positron and used by packages such as gt and gtsummary.

## Value

A data frame, or an sf object if `geometry = TRUE`. If tables for
multiple years from zipped data files can't be combined, a list of data
frames named by year.

## Details

- With `source = "auto"` (default), data for a state from 2010 onwards
  comes from the CrashAPI with
  [`get_fars_year()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md).
  National data (`state = NULL`), data for Puerto Rico (`state = "PR"`),
  and data before 2010 comes from zipped data files with
  [`get_fars_zip()`](https://elipousson.github.io/crashapi/reference/get_fars_zip.md),
  which are converted to parquet files and cached so later calls do not
  download the data again.

- Data from zipped files is filtered to the requested states and, if
  needed, a `CASEYEAR` column is added so the data matches the CrashAPI.

- If `county` is provided, tables with a `COUNTY` column (accident and
  person) are filtered by county and other tables are filtered to
  crashes in the county from the accident table (matching `ST_CASE` and
  `CASEYEAR`).

Use
[`get_fars_crashes()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md),
[`get_fars_cases()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md),
[`get_fars_crash_list()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md),
or
[`get_fars_summary()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md)
to access other CrashAPI endpoints.

## Examples

``` r
# Person table for Maryland from the CrashAPI
head(get_fars(state = "MD", year = 2022, type = "person"), 5)
#>   AGE  AGENAME AIR_BAG           AIR_BAGNAME ALC_DET ALC_DETNAME ALC_RES
#> 1  93 93 Years      20          Not Deployed      NA          NA       0
#> 2  29 29 Years       1       Deployed- Front      NA          NA     996
#> 3  33 33 Years       8 Deployed- Combination      NA          NA     996
#> 4  13 13 Years       8 Deployed- Combination      NA          NA       0
#> 5  32 32 Years       8 Deployed- Combination      NA          NA     996
#>      ALC_RESNAME ALC_STATUS ALC_STATUSNAME ATST_TYP    ATST_TYPNAME BODY_TYP
#> 1    0.000 % BAC          2     Test Given        1           Blood        4
#> 2 Test Not Given          0 Test Not Given        0  Test Not Given       14
#> 3 Test Not Given          0 Test Not Given        0  Test Not Given        4
#> 4    0.000 % BAC          2     Test Given        8 Other Test Type        4
#> 5 Test Not Given          0 Test Not Given        0  Test Not Given        4
#>                                                         BODY_TYPNAME CASEYEAR
#> 1                                              4-door sedan, hardtop     2022
#> 2 Compact Utility (Utility Vehicle Categories "Small" and "Midsize")     2022
#> 3                                              4-door sedan, hardtop     2022
#> 4                                              4-door sedan, hardtop     2022
#> 5                                              4-door sedan, hardtop     2022
#>   CERT_NO COUNTY      COUNTYNAME DAY DAYNAME DEATH_DA
#> 1      NA     43 WASHINGTON (43)   1       1        1
#> 2      NA     43 WASHINGTON (43)   1       1       88
#> 3      NA      5   BALTIMORE (5)   1       1       88
#> 4      NA      5   BALTIMORE (5)   1       1        1
#> 5      NA      5   BALTIMORE (5)   1       1       88
#>                 DEATH_DANAME DEATH_HR               DEATH_HRNAME DEATH_MN
#> 1                          1       11                11:00-11:59        5
#> 2 Not Applicable (Non-Fatal)       88 Not Applicable (Non-fatal)       88
#> 3 Not Applicable (Non-Fatal)       88 Not Applicable (Non-fatal)       88
#> 4                          1       22                22:00-22:59       16
#> 5 Not Applicable (Non-Fatal)       88 Not Applicable (Non-fatal)       88
#>                 DEATH_MNNAME DEATH_MO               DEATH_MONAME DEATH_TM
#> 1                          5        1                    January     1105
#> 2 Not Applicable (Non-fatal)       88 Not Applicable (Non-Fatal)     8888
#> 3 Not Applicable (Non-fatal)       88 Not Applicable (Non-Fatal)     8888
#> 4                         16        1                    January     2216
#> 5 Not Applicable (Non-fatal)       88 Not Applicable (Non-Fatal)     8888
#>                 DEATH_TMNAME DEATH_YR               DEATH_YRNAME DEVMOTOR
#> 1                       1105     2022                       2022       NA
#> 2 Not Applicable (Non-fatal)     8888 Not Applicable (Non-fatal)       NA
#> 3 Not Applicable (Non-fatal)     8888 Not Applicable (Non-fatal)       NA
#> 4                       2216     2022                       2022       NA
#> 5 Not Applicable (Non-fatal)     8888 Not Applicable (Non-fatal)       NA
#>   DEVMOTORNAME DEVTYPE DEVTYPENAME DOA        DOANAME DRINKING
#> 1         <NA>      NA        <NA>   0 Not Applicable        8
#> 2         <NA>      NA        <NA>   0 Not Applicable        0
#> 3         <NA>      NA        <NA>   0 Not Applicable        0
#> 4         <NA>      NA        <NA>   0 Not Applicable        8
#> 5         <NA>      NA        <NA>   0 Not Applicable        8
#>                DRINKINGNAME DRUGRES1 DRUGRES1NAME DRUGRES2 DRUGRES2NAME
#> 1              Not Reported       NA           NA       NA           NA
#> 2 No (Alcohol Not Involved)       NA           NA       NA           NA
#> 3 No (Alcohol Not Involved)       NA           NA       NA           NA
#> 4              Not Reported       NA           NA       NA           NA
#> 5              Not Reported       NA           NA       NA           NA
#>   DRUGRES3 DRUGRES3NAME DRUGS               DRUGSNAME DRUGTST1 DRUGTST1NAME
#> 1       NA           NA     8            Not Reported       NA           NA
#> 2       NA           NA     0 No (drugs not involved)       NA           NA
#> 3       NA           NA     0 No (drugs not involved)       NA           NA
#> 4       NA           NA     8            Not Reported       NA           NA
#> 5       NA           NA     8            Not Reported       NA           NA
#>   DRUGTST2 DRUGTST2NAME DRUGTST3 DRUGTST3NAME DRUG_DET DRUG_DETNAME DSTATUS
#> 1       NA           NA       NA           NA       NA           NA       2
#> 2       NA           NA       NA           NA       NA           NA       0
#> 3       NA           NA       NA           NA       NA           NA       0
#> 4       NA           NA       NA           NA       NA           NA       2
#> 5       NA           NA       NA           NA       NA           NA       0
#>      DSTATUSNAME EJECTION    EJECTIONNAME EJ_PATH                  EJ_PATHNAME
#> 1     Test Given        1 Totally Ejected       9        Ejection Path Unknown
#> 2 Test Not Given        0     Not Ejected       0 Ejection Path Not Applicable
#> 3 Test Not Given        0     Not Ejected       0 Ejection Path Not Applicable
#> 4     Test Given        0     Not Ejected       0 Ejection Path Not Applicable
#> 5 Test Not Given        0     Not Ejected       0 Ejection Path Not Applicable
#>   EMER_USE   EMER_USENAME EXTRICAT                     EXTRICATNAME FIRE_EXP
#> 1        0 Not Applicable        0 Not Extricated or Not Applicable        0
#> 2        0 Not Applicable        0 Not Extricated or Not Applicable        0
#> 3        0 Not Applicable        0 Not Extricated or Not Applicable        0
#> 4        0 Not Applicable        0 Not Extricated or Not Applicable        0
#> 5        0 Not Applicable        0 Not Extricated or Not Applicable        0
#>         FIRE_EXPNAME FUNC_SYS               FUNC_SYSNAME GVWR_FROM
#> 1 No or Not Reported        3 Principal Arterial - Other        11
#> 2 No or Not Reported        3 Principal Arterial - Other        11
#> 3 No or Not Reported        1                 Interstate        11
#> 4 No or Not Reported        1                 Interstate        11
#> 5 No or Not Reported        1                 Interstate        11
#>                                    GVWR_FROMNAME GVWR_TO
#> 1 Class 1: 6,000 lbs. or less (2,722 kg or less)      11
#> 2 Class 1: 6,000 lbs. or less (2,722 kg or less)      11
#> 3 Class 1: 6,000 lbs. or less (2,722 kg or less)      11
#> 4 Class 1: 6,000 lbs. or less (2,722 kg or less)      11
#> 5 Class 1: 6,000 lbs. or less (2,722 kg or less)      11
#>                                      GVWR_TONAME HARM_EV
#> 1 Class 1: 6,000 lbs. or less (2,722 kg or less)      12
#> 2 Class 1: 6,000 lbs. or less (2,722 kg or less)      12
#> 3 Class 1: 6,000 lbs. or less (2,722 kg or less)      25
#> 4 Class 1: 6,000 lbs. or less (2,722 kg or less)      25
#> 5 Class 1: 6,000 lbs. or less (2,722 kg or less)      25
#>                  HARM_EVNAME HELM_MIS             HELM_MISNAME HELM_USE
#> 1 Motor Vehicle In-Transport        7 None Used/Not Applicable       20
#> 2 Motor Vehicle In-Transport        7 None Used/Not Applicable       20
#> 3   Concrete Traffic Barrier        7 None Used/Not Applicable       20
#> 4   Concrete Traffic Barrier        7 None Used/Not Applicable       20
#> 5   Concrete Traffic Barrier        7 None Used/Not Applicable       20
#>     HELM_USENAME HISPANIC                    HISPANICNAME HOSPITAL
#> 1 Not Applicable        7                    Non-Hispanic        0
#> 2 Not Applicable        0 Not A Fatality (not Applicable)        5
#> 3 Not Applicable        0 Not A Fatality (not Applicable)        0
#> 4 Not Applicable        7                    Non-Hispanic        5
#> 5 Not Applicable        0 Not A Fatality (not Applicable)        0
#>                    HOSPITALNAME HOUR      HOURNAME ICFINALBODY ICFINALBODYNAME
#> 1 Not Transported for Treatment    9 9:00am-9:59am           0  Not Applicable
#> 2                    EMS Ground    9 9:00am-9:59am           0  Not Applicable
#> 3 Not Transported for Treatment   21 9:00pm-9:59pm           0  Not Applicable
#> 4                    EMS Ground   21 9:00pm-9:59pm           0  Not Applicable
#> 5 Not Transported for Treatment   21 9:00pm-9:59pm           0  Not Applicable
#>   IMPACT1    IMPACT1NAME IMPACT2 IMPACT2NAME INJ_SEV                INJ_SEVNAME
#> 1      12 12 Clock Point      NA          NA       4           Fatal Injury (K)
#> 2      12 12 Clock Point      NA          NA       2 Suspected Minor Injury (B)
#> 3      12 12 Clock Point      NA          NA       1        Possible Injury (C)
#> 4      12 12 Clock Point      NA          NA       4           Fatal Injury (K)
#> 5      12 12 Clock Point      NA          NA       1        Possible Injury (C)
#>   LAG_HRS LAG_HRSNAME LAG_MINS LAG_MINSNAME LOCATION
#> 1       1           1       17           17        0
#> 2     999     Unknown       99      Unknown        0
#> 3     999     Unknown       99      Unknown        0
#> 4       1           1       10           10        0
#> 5     999     Unknown       99      Unknown        0
#>                  LOCATIONNAME MAKE      MAKENAME MAK_MOD
#> 1 Occupant of a Motor Vehicle   42 Mercedes-Benz   42031
#> 2 Occupant of a Motor Vehicle   35 Nissan/Datsun   35401
#> 3 Occupant of a Motor Vehicle   55       Hyundai   55035
#> 4 Occupant of a Motor Vehicle   55       Hyundai   55035
#> 5 Occupant of a Motor Vehicle   55       Hyundai   55035
#>                                               MAK_MODNAME MAN_COLL
#> 1 Mercedes-Benz 200/220/230/240/ 250/260/280/300/ 320/420        2
#> 2                                Nissan/Datsun Pathfinder        2
#> 3                                         Hyundai Elantra        0
#> 4                                         Hyundai Elantra        0
#> 5                                         Hyundai Elantra        0
#>                                                                    MAN_COLLNAME
#> 1                                                                Front-to-Front
#> 2                                                                Front-to-Front
#> 3 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 4 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 5 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#>   MINUTE MINUTENAME MOD_YEAR MOD_YEARNAME MONTH MONTHNAME N_MOT_NO PER_NO
#> 1     48         48     1988         1988     1   January       NA      1
#> 2     48         48     2002         2002     1   January       NA      1
#> 3      6          6     2021         2021     1   January       NA      1
#> 4      6          6     2021         2021     1   January       NA      2
#> 5      6          6     2021         2021     1   January       NA      3
#>   PER_TYP                               PER_TYPNAME P_SF1 P_SF1NAME P_SF2
#> 1       1    Driver of a Motor Vehicle In-Transport    NA        NA    NA
#> 2       1    Driver of a Motor Vehicle In-Transport    NA        NA    NA
#> 3       1    Driver of a Motor Vehicle In-Transport    NA        NA    NA
#> 4       2 Passenger of a Motor Vehicle In-Transport    NA        NA    NA
#> 5       2 Passenger of a Motor Vehicle In-Transport    NA        NA    NA
#>   P_SF2NAME P_SF3 P_SF3NAME RACE RACENAME REST_MIS             REST_MISNAME
#> 1        NA    NA        NA   NA       NA        7 None Used/Not Applicable
#> 2        NA    NA        NA   NA       NA        0  No Indication of Misuse
#> 3        NA    NA        NA   NA       NA        0  No Indication of Misuse
#> 4        NA    NA        NA   NA       NA        0  No Indication of Misuse
#> 5        NA    NA        NA   NA       NA        0  No Indication of Misuse
#>   REST_USE               REST_USENAME ROAD_FNC ROAD_FNCNAME ROLLOVER
#> 1       20   None Used/Not Applicable       NA           NA        0
#> 2        3 Shoulder and Lap Belt Used       NA           NA        0
#> 3        3 Shoulder and Lap Belt Used       NA           NA        0
#> 4        3 Shoulder and Lap Belt Used       NA           NA        0
#> 5        3 Shoulder and Lap Belt Used       NA           NA        0
#>   ROLLOVERNAME RUR_URB RUR_URBNAME SCH_BUS SCH_BUSNAME SEAT_POS
#> 1  No Rollover       2       Urban       0          No       11
#> 2  No Rollover       2       Urban       0          No       11
#> 3  No Rollover       2       Urban       0          No       11
#> 4  No Rollover       2       Urban       0          No       23
#> 5  No Rollover       2       Urban       0          No       13
#>              SEAT_POSNAME SEX SEXNAME SPEC_USE         SPEC_USENAME STATE
#> 1   Front Seat, Left Side   1    Male        0 No Special Use Noted    24
#> 2   Front Seat, Left Side   1    Male        0 No Special Use Noted    24
#> 3   Front Seat, Left Side   1    Male        0 No Special Use Noted    24
#> 4 Second Seat, Right Side   1    Male        0 No Special Use Noted    24
#> 5  Front Seat, Right Side   2  Female        0 No Special Use Noted    24
#>   STATENAME STR_VEH                 STR_VEHNAME ST_CASE TOW_VEH TOW_VEHNAME
#> 1  Maryland       0 Occupant of a Motor Vehicle  240001       0 No Trailers
#> 2  Maryland       0 Occupant of a Motor Vehicle  240001       0 No Trailers
#> 3  Maryland       0 Occupant of a Motor Vehicle  240002       0 No Trailers
#> 4  Maryland       0 Occupant of a Motor Vehicle  240002       0 No Trailers
#> 5  Maryland       0 Occupant of a Motor Vehicle  240002       0 No Trailers
#>   VEH_NO VE_FORMS VPICBODYCLASS
#> 1      1        2            13
#> 2      2        2             7
#> 3      1        2            13
#> 4      1        2            13
#> 5      1        2            13
#>                                         VPICBODYCLASSNAME VPICMAKE
#> 1                                            Sedan/Saloon      449
#> 2 Sport Utility Vehicle (SUV)/Multi-Purpose Vehicle (MPV)      478
#> 3                                            Sedan/Saloon      498
#> 4                                            Sedan/Saloon      498
#> 5                                            Sedan/Saloon      498
#>    VPICMAKENAME VPICMODEL VPICMODELNAME WORK_INJ
#> 1 Mercedes-Benz     14014           300        0
#> 2        Nissan      1911    Pathfinder        8
#> 3       Hyundai      2735       Elantra        8
#> 4       Hyundai      2735       Elantra        0
#> 5       Hyundai      2735       Elantra        8
#>                      WORK_INJNAME
#> 1                              No
#> 2 Not Applicable (not a fatality)
#> 3 Not Applicable (not a fatality)
#> 4                              No
#> 5 Not Applicable (not a fatality)

# Accident table for Baltimore City
get_fars(state = "MD", county = "Baltimore city", year = 2022)
#>     ARR_HOUR                   ARR_HOURNAME ARR_MIN
#> 59        23                11:00pm-11:59pm      35
#> 69         6                  6:00am-6:59am      38
#> 70        99 Unknown EMS Scene Arrival Hour      99
#> 99         2                  2:00am-2:59am      20
#> 136        6                  6:00am-6:59am      25
#> 186        5                  5:00am-5:59am      57
#> 207       21                  9:00pm-9:59pm      12
#> 208       13                  1:00pm-1:59pm      23
#> 242       23                11:00pm-11:59pm      21
#> 259        2                  2:00am-2:59am      26
#> 273       18                  6:00pm-6:59pm       4
#> 298       16                  4:00pm-4:59pm      14
#> 314       23                11:00pm-11:59pm      38
#> 339        5                  5:00am-5:59am      39
#> 363       12                12:00pm-12:59pm      44
#> 382       19                  7:00pm-7:59pm       2
#> 383       12                12:00pm-12:59pm      37
#> 418       16                  4:00pm-4:59pm      51
#> 437       20                  8:00pm-8:59pm      56
#> 440        6                  6:00am-6:59am      13
#> 464        0                  0:00am-0:59am      46
#> 468       23                11:00pm-11:59pm      17
#> 475       99 Unknown EMS Scene Arrival Hour      99
#> 478       16                  4:00pm-4:59pm      22
#> 481       16                  4:00pm-4:59pm      30
#> 486        2                  2:00am-2:59am      58
#> 488        3                  3:00am-3:59am       9
#> 491       99 Unknown EMS Scene Arrival Hour      99
#> 492       19                  7:00pm-7:59pm       1
#> 493       12                12:00pm-12:59pm      51
#> 501       11                11:00am-11:59am      52
#> 502       15                  3:00pm-3:59pm       7
#> 507       22                10:00pm-10:59pm      13
#> 510       15                  3:00pm-3:59pm      14
#> 511       21                  9:00pm-9:59pm      48
#> 515        1                  1:00am-1:59am      42
#> 516       99 Unknown EMS Scene Arrival Hour      99
#> 517       99 Unknown EMS Scene Arrival Hour      99
#> 518       17                  5:00pm-5:59pm      30
#> 520       20                  8:00pm-8:59pm      16
#> 521       13                  1:00pm-1:59pm      21
#> 522        6                  6:00am-6:59am      47
#> 523       99 Unknown EMS Scene Arrival Hour      99
#> 524       99 Unknown EMS Scene Arrival Hour      99
#> 525       13                  1:00pm-1:59pm      48
#>                           ARR_MINNAME CF1 CF1NAME CF2 CF2NAME CF3 CF3NAME CITY
#> 59                                 35  NA      NA  NA      NA  NA      NA   50
#> 69                                 38  NA      NA  NA      NA  NA      NA   50
#> 70  Unknown EMS Scene Arrival Minutes  NA      NA  NA      NA  NA      NA    0
#> 99                                 20  NA      NA  NA      NA  NA      NA   50
#> 136                                25  NA      NA  NA      NA  NA      NA   50
#> 186                                57  NA      NA  NA      NA  NA      NA   50
#> 207                                12  NA      NA  NA      NA  NA      NA   50
#> 208                                23  NA      NA  NA      NA  NA      NA    0
#> 242                                21  NA      NA  NA      NA  NA      NA   50
#> 259                                26  NA      NA  NA      NA  NA      NA   50
#> 273                                 4  NA      NA  NA      NA  NA      NA   50
#> 298                                14  NA      NA  NA      NA  NA      NA   50
#> 314                                38  NA      NA  NA      NA  NA      NA   50
#> 339                                39  NA      NA  NA      NA  NA      NA   50
#> 363                                44  NA      NA  NA      NA  NA      NA    0
#> 382                                 2  NA      NA  NA      NA  NA      NA   50
#> 383                                37  NA      NA  NA      NA  NA      NA   50
#> 418                                51  NA      NA  NA      NA  NA      NA    0
#> 437                                56  NA      NA  NA      NA  NA      NA    0
#> 440                                13  NA      NA  NA      NA  NA      NA    0
#> 464                                46  NA      NA  NA      NA  NA      NA   50
#> 468                                17  NA      NA  NA      NA  NA      NA   50
#> 475 Unknown EMS Scene Arrival Minutes  NA      NA  NA      NA  NA      NA   50
#> 478                                22  NA      NA  NA      NA  NA      NA   50
#> 481                                30  NA      NA  NA      NA  NA      NA    0
#> 486                                58  NA      NA  NA      NA  NA      NA   50
#> 488                                 9  NA      NA  NA      NA  NA      NA    0
#> 491 Unknown EMS Scene Arrival Minutes  NA      NA  NA      NA  NA      NA    0
#> 492                                 1  NA      NA  NA      NA  NA      NA   50
#> 493                                51  NA      NA  NA      NA  NA      NA   50
#> 501                                52  NA      NA  NA      NA  NA      NA   50
#> 502                                 7  NA      NA  NA      NA  NA      NA   50
#> 507                                13  NA      NA  NA      NA  NA      NA   50
#> 510                                14  NA      NA  NA      NA  NA      NA   50
#> 511                                48  NA      NA  NA      NA  NA      NA   50
#> 515                                42  NA      NA  NA      NA  NA      NA    0
#> 516 Unknown EMS Scene Arrival Minutes  NA      NA  NA      NA  NA      NA    0
#> 517 Unknown EMS Scene Arrival Minutes  NA      NA  NA      NA  NA      NA   50
#> 518                                30  NA      NA  NA      NA  NA      NA   50
#> 520                                16  NA      NA  NA      NA  NA      NA   50
#> 521                                21  NA      NA  NA      NA  NA      NA   50
#> 522                                47  NA      NA  NA      NA  NA      NA   50
#> 523 Unknown EMS Scene Arrival Minutes  NA      NA  NA      NA  NA      NA   50
#> 524 Unknown EMS Scene Arrival Minutes  NA      NA  NA      NA  NA      NA   50
#> 525                                48  NA      NA  NA      NA  NA      NA   50
#>           CITYNAME COUNTY             COUNTYNAME CaseYear DAY DAYNAME DAY_WEEK
#> 59       BALTIMORE    510 BALTIMORE (CITY) (510)     2022  24      24        5
#> 69       BALTIMORE    510 BALTIMORE (CITY) (510)     2022  17      17        5
#> 70  NOT APPLICABLE    510 BALTIMORE (CITY) (510)     2022   2       2        4
#> 99       BALTIMORE    510 BALTIMORE (CITY) (510)     2022   1       1        7
#> 136      BALTIMORE    510 BALTIMORE (CITY) (510)     2022  21      21        2
#> 186      BALTIMORE    510 BALTIMORE (CITY) (510)     2022   4       4        2
#> 207      BALTIMORE    510 BALTIMORE (CITY) (510)     2022  26      26        5
#> 208 NOT APPLICABLE    510 BALTIMORE (CITY) (510)     2022  29      29        1
#> 242      BALTIMORE    510 BALTIMORE (CITY) (510)     2022  26      26        3
#> 259      BALTIMORE    510 BALTIMORE (CITY) (510)     2022  23      23        7
#> 273      BALTIMORE    510 BALTIMORE (CITY) (510)     2022  24      24        5
#> 298      BALTIMORE    510 BALTIMORE (CITY) (510)     2022  13      13        4
#> 314      BALTIMORE    510 BALTIMORE (CITY) (510)     2022  29      29        2
#> 339      BALTIMORE    510 BALTIMORE (CITY) (510)     2022  12      12        4
#> 363 NOT APPLICABLE    510 BALTIMORE (CITY) (510)     2022  21      21        3
#> 382      BALTIMORE    510 BALTIMORE (CITY) (510)     2022   5       5        1
#> 383      BALTIMORE    510 BALTIMORE (CITY) (510)     2022  28      28        3
#> 418 NOT APPLICABLE    510 BALTIMORE (CITY) (510)     2022   9       9        5
#> 437 NOT APPLICABLE    510 BALTIMORE (CITY) (510)     2022  15      15        5
#> 440 NOT APPLICABLE    510 BALTIMORE (CITY) (510)     2022  31      31        4
#> 464      BALTIMORE    510 BALTIMORE (CITY) (510)     2022  16      16        7
#> 468      BALTIMORE    510 BALTIMORE (CITY) (510)     2022  19      19        1
#> 475      BALTIMORE    510 BALTIMORE (CITY) (510)     2022  23      23        7
#> 478      BALTIMORE    510 BALTIMORE (CITY) (510)     2022   4       4        1
#> 481 NOT APPLICABLE    510 BALTIMORE (CITY) (510)     2022  10      10        7
#> 486      BALTIMORE    510 BALTIMORE (CITY) (510)     2022  26      26        5
#> 488 NOT APPLICABLE    510 BALTIMORE (CITY) (510)     2022  21      21        7
#> 491 NOT APPLICABLE    510 BALTIMORE (CITY) (510)     2022  29      29        4
#> 492      BALTIMORE    510 BALTIMORE (CITY) (510)     2022  20      20        2
#> 493      BALTIMORE    510 BALTIMORE (CITY) (510)     2022  14      14        4
#> 501      BALTIMORE    510 BALTIMORE (CITY) (510)     2022  23      23        5
#> 502      BALTIMORE    510 BALTIMORE (CITY) (510)     2022   6       6        4
#> 507      BALTIMORE    510 BALTIMORE (CITY) (510)     2022  26      26        7
#> 510      BALTIMORE    510 BALTIMORE (CITY) (510)     2022  27      27        1
#> 511      BALTIMORE    510 BALTIMORE (CITY) (510)     2022  28      28        7
#> 515 NOT APPLICABLE    510 BALTIMORE (CITY) (510)     2022   1       1        7
#> 516 NOT APPLICABLE    510 BALTIMORE (CITY) (510)     2022   3       3        7
#> 517      BALTIMORE    510 BALTIMORE (CITY) (510)     2022  19      19        2
#> 518      BALTIMORE    510 BALTIMORE (CITY) (510)     2022   2       2        4
#> 520      BALTIMORE    510 BALTIMORE (CITY) (510)     2022  30      30        5
#> 521      BALTIMORE    510 BALTIMORE (CITY) (510)     2022   6       6        1
#> 522      BALTIMORE    510 BALTIMORE (CITY) (510)     2022  27      27        5
#> 523      BALTIMORE    510 BALTIMORE (CITY) (510)     2022  22      22        6
#> 524      BALTIMORE    510 BALTIMORE (CITY) (510)     2022   8       8        7
#> 525      BALTIMORE    510 BALTIMORE (CITY) (510)     2022  19      19        7
#>     DAY_WEEKNAME DRUNK_DR FATALS FUNC_SYS
#> 59      Thursday       NA      1        1
#> 69      Thursday       NA      1        3
#> 70     Wednesday       NA      1        1
#> 99      Saturday       NA      1        1
#> 136       Monday       NA      1        1
#> 186       Monday       NA      1        4
#> 207     Thursday       NA      1        3
#> 208       Sunday       NA      1        1
#> 242      Tuesday       NA      1        4
#> 259     Saturday       NA      1        3
#> 273     Thursday       NA      1        3
#> 298    Wednesday       NA      1        3
#> 314       Monday       NA      1        1
#> 339    Wednesday       NA      1        1
#> 363      Tuesday       NA      1        4
#> 382       Sunday       NA      1        3
#> 383      Tuesday       NA      1        3
#> 418     Thursday       NA      1        5
#> 437     Thursday       NA      1        2
#> 440    Wednesday       NA      1        3
#> 464     Saturday       NA      1        1
#> 468       Sunday       NA      1        3
#> 475     Saturday       NA      1        3
#> 478       Sunday       NA      1        4
#> 481     Saturday       NA      1        4
#> 486     Thursday       NA      1        3
#> 488     Saturday       NA      1        3
#> 491    Wednesday       NA      1        3
#> 492       Monday       NA      1        5
#> 493    Wednesday       NA      1        7
#> 501     Thursday       NA      1        5
#> 502    Wednesday       NA      1        4
#> 507     Saturday       NA      1        1
#> 510       Sunday       NA      2        3
#> 511     Saturday       NA      1        4
#> 515     Saturday       NA      1        4
#> 516     Saturday       NA      1        4
#> 517       Monday       NA      1        3
#> 518    Wednesday       NA      1        4
#> 520     Thursday       NA      1        5
#> 521       Sunday       NA      1        4
#> 522     Thursday       NA      1        4
#> 523       Friday       NA      1        3
#> 524     Saturday       NA      1        3
#> 525     Saturday       NA      1        3
#>                                            FUNC_SYSNAME HARM_EV
#> 59                                           Interstate       8
#> 69                           Principal Arterial - Other       8
#> 70                                           Interstate       8
#> 99                                           Interstate       8
#> 136                                          Interstate      12
#> 186                                      Minor Arterial       8
#> 207                          Principal Arterial - Other       9
#> 208                                          Interstate      12
#> 242                                      Minor Arterial      12
#> 259                          Principal Arterial - Other      12
#> 273                          Principal Arterial - Other      14
#> 298                          Principal Arterial - Other       8
#> 314                                          Interstate       8
#> 339                                          Interstate       8
#> 363                                      Minor Arterial      12
#> 382                          Principal Arterial - Other      12
#> 383                          Principal Arterial - Other      33
#> 418                                     Major Collector       8
#> 437 Principal Arterial - Other Freeways and Expressways      12
#> 440                          Principal Arterial - Other      12
#> 464                                          Interstate       8
#> 468                          Principal Arterial - Other       8
#> 475                          Principal Arterial - Other      42
#> 478                                      Minor Arterial      33
#> 481                                      Minor Arterial      12
#> 486                          Principal Arterial - Other      30
#> 488                          Principal Arterial - Other       8
#> 491                          Principal Arterial - Other       8
#> 492                                     Major Collector       8
#> 493                                               Local      15
#> 501                                     Major Collector      33
#> 502                                      Minor Arterial      15
#> 507                                          Interstate       8
#> 510                          Principal Arterial - Other      33
#> 511                                      Minor Arterial      12
#> 515                                      Minor Arterial       8
#> 516                                      Minor Arterial       8
#> 517                          Principal Arterial - Other      14
#> 518                                      Minor Arterial      15
#> 520                                     Major Collector      12
#> 521                                      Minor Arterial       8
#> 522                                      Minor Arterial      18
#> 523                          Principal Arterial - Other      33
#> 524                          Principal Arterial - Other      12
#> 525                          Principal Arterial - Other      42
#>                             HARM_EVNAME HOSP_HR
#> 59                           Pedestrian      23
#> 69                           Pedestrian       6
#> 70                           Pedestrian      99
#> 99                           Pedestrian      88
#> 136          Motor Vehicle In-Transport      88
#> 186                          Pedestrian       6
#> 207                        Pedalcyclist      88
#> 208          Motor Vehicle In-Transport      13
#> 242          Motor Vehicle In-Transport      23
#> 259          Motor Vehicle In-Transport       2
#> 273                Parked Motor Vehicle      18
#> 298                          Pedestrian      16
#> 314                          Pedestrian      88
#> 339                          Pedestrian      88
#> 363          Motor Vehicle In-Transport      12
#> 382          Motor Vehicle In-Transport      19
#> 383                                Curb      13
#> 418                          Pedestrian      17
#> 437          Motor Vehicle In-Transport      99
#> 440          Motor Vehicle In-Transport       6
#> 464                          Pedestrian       0
#> 468                          Pedestrian      23
#> 475                Tree (Standing Only)      99
#> 478                                Curb      88
#> 481          Motor Vehicle In-Transport      16
#> 486          Utility Pole/Light Support       3
#> 488                          Pedestrian       3
#> 491                          Pedestrian      99
#> 492                          Pedestrian      19
#> 493 Non-Motorist on Personal Conveyance      13
#> 501                                Curb      99
#> 502 Non-Motorist on Personal Conveyance      15
#> 507                          Pedestrian      22
#> 510                                Curb      88
#> 511          Motor Vehicle In-Transport      22
#> 515                          Pedestrian       1
#> 516                          Pedestrian      88
#> 517                Parked Motor Vehicle      88
#> 518 Non-Motorist on Personal Conveyance      18
#> 520          Motor Vehicle In-Transport      88
#> 521                          Pedestrian      13
#> 522            Other Object (not fixed)      99
#> 523                                Curb      99
#> 524          Motor Vehicle In-Transport      99
#> 525                Tree (Standing Only)      14
#>                           HOSP_HRNAME HOSP_MN                       HOSP_MNNAME
#> 59                    11:00pm-11:59pm      48                                48
#> 69                      6:00am-6:59am      56                                56
#> 70                            Unknown      99 Unknown EMS Hospital Arrival Time
#> 99  Not Applicable (Not Transported)       88  Not Applicable (Not Transported)
#> 136 Not Applicable (Not Transported)       88  Not Applicable (Not Transported)
#> 186                     6:00am-6:59am      38                                38
#> 207 Not Applicable (Not Transported)       88  Not Applicable (Not Transported)
#> 208                     1:00pm-1:59pm      37                                37
#> 242                   11:00pm-11:59pm      39                                39
#> 259                     2:00am-2:59am      56                                56
#> 273                     6:00pm-6:59pm      20                                20
#> 298                     4:00pm-4:59pm      42                                42
#> 314 Not Applicable (Not Transported)       88  Not Applicable (Not Transported)
#> 339 Not Applicable (Not Transported)       88  Not Applicable (Not Transported)
#> 363                   12:00pm-12:59pm      54                                54
#> 382                     7:00pm-7:59pm      24                                24
#> 383                     1:00pm-1:59pm       5                                 5
#> 418                     5:00pm-5:59pm       3                                 3
#> 437                           Unknown      99 Unknown EMS Hospital Arrival Time
#> 440                     6:00am-6:59am      38                                38
#> 464                     0:00am-0:59am      59                                59
#> 468                   11:00pm-11:59pm      29                                29
#> 475                           Unknown      99 Unknown EMS Hospital Arrival Time
#> 478 Not Applicable (Not Transported)       88  Not Applicable (Not Transported)
#> 481                     4:00pm-4:59pm      53                                53
#> 486                     3:00am-3:59am      18                                18
#> 488                     3:00am-3:59am      27                                27
#> 491                           Unknown      99 Unknown EMS Hospital Arrival Time
#> 492                     7:00pm-7:59pm      14                                14
#> 493                     1:00pm-1:59pm      17                                17
#> 501                           Unknown      99 Unknown EMS Hospital Arrival Time
#> 502                     3:00pm-3:59pm      20                                20
#> 507                   10:00pm-10:59pm      23                                23
#> 510 Not Applicable (Not Transported)       88  Not Applicable (Not Transported)
#> 511                   10:00pm-10:59pm       6                                 6
#> 515                     1:00am-1:59am      55                                55
#> 516 Not Applicable (Not Transported)       88  Not Applicable (Not Transported)
#> 517 Not Applicable (Not Transported)       88  Not Applicable (Not Transported)
#> 518                     6:00pm-6:59pm       0                                 0
#> 520 Not Applicable (Not Transported)       88  Not Applicable (Not Transported)
#> 521                     1:00pm-1:59pm      35                                35
#> 522                           Unknown      99 Unknown EMS Hospital Arrival Time
#> 523                           Unknown      99 Unknown EMS Hospital Arrival Time
#> 524                           Unknown      99 Unknown EMS Hospital Arrival Time
#> 525                     2:00pm-2:59pm       2                                 2
#>     HOUR        HOURNAME LATITUDE LATITUDENAME LGT_COND       LGT_CONDNAME
#> 59    23 11:00pm-11:59pm 39.28737     39.28737        3     Dark - Lighted
#> 69     6   6:00am-6:59am 39.28748     39.28748        3     Dark - Lighted
#> 70    23 11:00pm-11:59pm 39.28099     39.28099        2 Dark - Not Lighted
#> 99     2   2:00am-2:59am 39.27736     39.27736        2 Dark - Not Lighted
#> 136    6   6:00am-6:59am 39.27402     39.27402        3     Dark - Lighted
#> 186    5   5:00am-5:59am 39.32816     39.32816        3     Dark - Lighted
#> 207   21   9:00pm-9:59pm 39.30715     39.30715        3     Dark - Lighted
#> 208   13   1:00pm-1:59pm 39.26934     39.26934        1           Daylight
#> 242   23 11:00pm-11:59pm 39.31554     39.31554        3     Dark - Lighted
#> 259    2   2:00am-2:59am 39.35251     39.35251        3     Dark - Lighted
#> 273   17   5:00pm-5:59pm 39.31114     39.31114        1           Daylight
#> 298   16   4:00pm-4:59pm 39.33275     39.33275        1           Daylight
#> 314   23 11:00pm-11:59pm 39.28726     39.28726        3     Dark - Lighted
#> 339    5   5:00am-5:59am 39.27122     39.27122        3     Dark - Lighted
#> 363   12 12:00pm-12:59pm 39.30476     39.30476        1           Daylight
#> 382   18   6:00pm-6:59pm 39.36471     39.36471        1           Daylight
#> 383   12 12:00pm-12:59pm 39.24533     39.24533        1           Daylight
#> 418   16   4:00pm-4:59pm 39.30202     39.30202        1           Daylight
#> 437   20   8:00pm-8:59pm 39.21032     39.21032        3     Dark - Lighted
#> 440    6   6:00am-6:59am 39.33377     39.33377        4               Dawn
#> 464    0   0:00am-0:59am 39.29842     39.29842        3     Dark - Lighted
#> 468   23 11:00pm-11:59pm 39.28604     39.28604        3     Dark - Lighted
#> 475   15   3:00pm-3:59pm 39.21013     39.21013        1           Daylight
#> 478   16   4:00pm-4:59pm 39.22243     39.22243        1           Daylight
#> 481   16   4:00pm-4:59pm 39.33968     39.33968        1           Daylight
#> 486    2   2:00am-2:59am 39.28459     39.28459        3     Dark - Lighted
#> 488    3   3:00am-3:59am 39.32913     39.32913        3     Dark - Lighted
#> 491   20   8:00pm-8:59pm 39.31047     39.31047        1           Daylight
#> 492   18   6:00pm-6:59pm 39.29371     39.29371        1           Daylight
#> 493   12 12:00pm-12:59pm 39.29806     39.29806        1           Daylight
#> 501   11 11:00am-11:59am 39.37131     39.37131        1           Daylight
#> 502   14   2:00pm-2:59pm 39.31321     39.31321        1           Daylight
#> 507   22 10:00pm-10:59pm 39.29071     39.29071        3     Dark - Lighted
#> 510   15   3:00pm-3:59pm 39.35951     39.35951        1           Daylight
#> 511   21   9:00pm-9:59pm 39.30478     39.30478        3     Dark - Lighted
#> 515    1   1:00am-1:59am 39.35044     39.35044        3     Dark - Lighted
#> 516   13   1:00pm-1:59pm 39.31457     39.31457        1           Daylight
#> 517   12 12:00pm-12:59pm 39.28651     39.28651        1           Daylight
#> 518   17   5:00pm-5:59pm 39.29265     39.29265        1           Daylight
#> 520   20   8:00pm-8:59pm 39.29384     39.29384        3     Dark - Lighted
#> 521   13   1:00pm-1:59pm 39.29249     39.29249        1           Daylight
#> 522    6   6:00am-6:59am 39.29005     39.29005        3     Dark - Lighted
#> 523    2   2:00am-2:59am 39.31762     39.31762        3     Dark - Lighted
#> 524   18   6:00pm-6:59pm 39.32568     39.32568        5               Dusk
#> 525   13   1:00pm-1:59pm 39.29955     39.29955        1           Daylight
#>      LONGITUD LONGITUDNAME MAN_COLL
#> 59  -76.55362    -76.55362        0
#> 69  -76.54656    -76.54656        0
#> 70  -76.62239    -76.62239        0
#> 99  -76.61972    -76.61972        0
#> 136 -76.62122    -76.62122        7
#> 186 -76.53367    -76.53367        0
#> 207 -76.67346    -76.67346        0
#> 208 -76.63510    -76.63510        1
#> 242 -76.65969    -76.65969        6
#> 259 -76.68451    -76.68451        1
#> 273 -76.61316    -76.61316        0
#> 298 -76.55931    -76.55931        0
#> 314 -76.55363    -76.55363        0
#> 339 -76.64786    -76.64786        0
#> 363 -76.58269    -76.58269        6
#> 382 -76.60719    -76.60719        6
#> 383 -76.63415    -76.63415        0
#> 418 -76.63259    -76.63259        0
#> 437 -76.53790    -76.53790        2
#> 440 -76.70320    -76.70320        6
#> 464 -76.61111    -76.61111        0
#> 468 -76.61236    -76.61236        0
#> 475 -76.58567    -76.58567        0
#> 478 -76.59536    -76.59536        0
#> 481 -76.67811    -76.67811        6
#> 486 -76.62345    -76.62345        0
#> 488 -76.56442    -76.56442        0
#> 491 -76.59985    -76.59985        0
#> 492 -76.65037    -76.65037        0
#> 493 -76.63523    -76.63523        0
#> 501 -76.57893    -76.57893        0
#> 502 -76.59634    -76.59634        0
#> 507 -76.60676    -76.60676        0
#> 510 -76.65285    -76.65285        0
#> 511 -76.58263    -76.58263        2
#> 515 -76.68084    -76.68084        0
#> 516 -76.67673    -76.67673        0
#> 517 -76.63868    -76.63868        0
#> 518 -76.67546    -76.67546        0
#> 520 -76.64723    -76.64723        6
#> 521 -76.56937    -76.56937        0
#> 522 -76.59950    -76.59950        0
#> 523 -76.57271    -76.57271        0
#> 524 -76.67649    -76.67649        6
#> 525 -76.56772    -76.56772        0
#>                                                                      MAN_COLLNAME
#> 59  The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 69  The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 70  The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 99  The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 136                                                    Sideswipe - Same Direction
#> 186 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 207 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 208                                                                 Front-to-Rear
#> 242                                                                         Angle
#> 259                                                                 Front-to-Rear
#> 273 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 298 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 314 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 339 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 363                                                                         Angle
#> 382                                                                         Angle
#> 383 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 418 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 437                                                                Front-to-Front
#> 440                                                                         Angle
#> 464 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 468 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 475 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 478 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 481                                                                         Angle
#> 486 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 488 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 491 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 492 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 493 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 501 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 502 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 507 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 510 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 511                                                                Front-to-Front
#> 515 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 516 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 517 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 518 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 520                                                                         Angle
#> 521 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 522 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 523 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 524                                                                         Angle
#> 525 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#>     MILEPT   MILEPTNAME MINUTE MINUTENAME MONTH MONTHNAME NHS
#> 59      57           57     17         17     2  February   1
#> 69      15           15     35         35     3     March   1
#> 70       0         None     46         46     2  February   1
#> 99       7            7     21         21     1   January   1
#> 136      3            3     21         21     3     March   1
#> 186      0         None     45         45     4     April   0
#> 207     14           14      5          5     5       May   1
#> 208     23           23     11         11     5       May   1
#> 242     13           13      5          5     7      July   0
#> 259     19           19     20         20     4     April   0
#> 273      0         None     55         55     3     March   1
#> 298     97           97     10         10     4     April   1
#> 314      5            5     31         31     8    August   1
#> 339     16           16     31         31    10   October   1
#> 363     18           18     36         36     6      June   0
#> 382     10           10     53         53     6      June   0
#> 383     12           12     22         22     6      June   1
#> 418      2            2     43         43     6      June   0
#> 437      9            9     46         46    12  December   1
#> 440      5            5      7          7     8    August   1
#> 464      9            9     34         34     4     April   1
#> 468      4            4     19         19     6      June   1
#> 475      0         None     40         40     7      July   1
#> 478      1            1     12         12     9 September   0
#> 481      0         None     30         30    12  December   0
#> 486      0         None     58         58     5       May   1
#> 488      0         None      2          2     5       May   1
#> 491      5            5      9          9     6      June   1
#> 492     14           14     55         55     6      June   0
#> 493  99998 Not Reported     50         50     9 September   0
#> 501     14           14     55         55     6      June   0
#> 502     14           14     52         52     7      July   0
#> 507      0         None      5          5    11  November   1
#> 510     26           26     15         15    11  November   1
#> 511      5            5     31         31     5       May   0
#> 515     49           49     35         35    10   October   0
#> 516      2            2     58         58    12  December   0
#> 517     13           13     35         35    12  December   1
#> 518      0         None     19         19    11  November   0
#> 520     12           12     11         11     6      June   0
#> 521     25           25     14         14     2  February   0
#> 522      5            5     37         37    10   October   0
#> 523     12           12      3          3     7      July   0
#> 524     20           20     30         30    10   October   1
#> 525      0         None     40         40    11  November   1
#>                            NHSNAME NOT_HOUR    NOT_HOURNAME NOT_MIN NOT_MINNAME
#> 59      This section IS ON the NHS       23 11:00pm-11:59pm      16          16
#> 69      This section IS ON the NHS        6   6:00am-6:59am      34          34
#> 70      This section IS ON the NHS       99         Unknown      99     Unknown
#> 99      This section IS ON the NHS        2   2:00am-2:59am      20          20
#> 136     This section IS ON the NHS        6   6:00am-6:59am      20          20
#> 186 This section IS NOT on the NHS        5   5:00am-5:59am      44          44
#> 207     This section IS ON the NHS       21   9:00pm-9:59pm       1           1
#> 208     This section IS ON the NHS       13   1:00pm-1:59pm       6           6
#> 242 This section IS NOT on the NHS       23 11:00pm-11:59pm       7           7
#> 259 This section IS NOT on the NHS        2   2:00am-2:59am      21          21
#> 273     This section IS ON the NHS       17   5:00pm-5:59pm      52          52
#> 298     This section IS ON the NHS       16   4:00pm-4:59pm      11          11
#> 314     This section IS ON the NHS       23 11:00pm-11:59pm      29          29
#> 339     This section IS ON the NHS        5   5:00am-5:59am      27          27
#> 363 This section IS NOT on the NHS       12 12:00pm-12:59pm      36          36
#> 382 This section IS NOT on the NHS       18   6:00pm-6:59pm      53          53
#> 383     This section IS ON the NHS       12 12:00pm-12:59pm      23          23
#> 418 This section IS NOT on the NHS       16   4:00pm-4:59pm      43          43
#> 437     This section IS ON the NHS       20   8:00pm-8:59pm      45          45
#> 440     This section IS ON the NHS        6   6:00am-6:59am       5           5
#> 464     This section IS ON the NHS        0   0:00am-0:59am      33          33
#> 468     This section IS ON the NHS       23 11:00pm-11:59pm      13          13
#> 475     This section IS ON the NHS       99         Unknown      99     Unknown
#> 478 This section IS NOT on the NHS       16   4:00pm-4:59pm      12          12
#> 481 This section IS NOT on the NHS       16   4:00pm-4:59pm      20          20
#> 486     This section IS ON the NHS        2   2:00am-2:59am      55          55
#> 488     This section IS ON the NHS        3   3:00am-3:59am       3           3
#> 491     This section IS ON the NHS       99         Unknown      99     Unknown
#> 492 This section IS NOT on the NHS       18   6:00pm-6:59pm      55          55
#> 493 This section IS NOT on the NHS       12 12:00pm-12:59pm      47          47
#> 501 This section IS NOT on the NHS       11 11:00am-11:59am      52          52
#> 502 This section IS NOT on the NHS       14   2:00pm-2:59pm      54          54
#> 507     This section IS ON the NHS       22 10:00pm-10:59pm       6           6
#> 510     This section IS ON the NHS       15   3:00pm-3:59pm       6           6
#> 511 This section IS NOT on the NHS       21   9:00pm-9:59pm      32          32
#> 515 This section IS NOT on the NHS        1   1:00am-1:59am      35          35
#> 516 This section IS NOT on the NHS       99         Unknown      99     Unknown
#> 517     This section IS ON the NHS       99         Unknown      99     Unknown
#> 518 This section IS NOT on the NHS       17   5:00pm-5:59pm      19          19
#> 520 This section IS NOT on the NHS       20   8:00pm-8:59pm      11          11
#> 521 This section IS NOT on the NHS       13   1:00pm-1:59pm      14          14
#> 522 This section IS NOT on the NHS        6   6:00am-6:59am      37          37
#> 523 This section IS NOT on the NHS       99         Unknown      99     Unknown
#> 524     This section IS ON the NHS       99         Unknown      99     Unknown
#> 525     This section IS ON the NHS       13   1:00pm-1:59pm      40          40
#>     PEDS PERMVIT PERNOTMVIT PERSONS PVH_INVL    RAIL       RAILNAME RD_OWNER
#> 59     1       1          1       1        0 0000000 Not Applicable        1
#> 69     1       1          1       1        0 0000000 Not Applicable        1
#> 70     1       2          1       2        0 0000000 Not Applicable       31
#> 99     1       9          1       9        0 0000000 Not Applicable        1
#> 136    1       2          1       2        0 0000000 Not Applicable        1
#> 186    1       1          1       1        0 0000000 Not Applicable        4
#> 207    1       2          1       2        0 0000000 Not Applicable        4
#> 208    0       2          0       2        0 0000000 Not Applicable        1
#> 242    0       2          0       2        0 0000000 Not Applicable        4
#> 259    0       2          0       2        0 0000000 Not Applicable        4
#> 273    0       1          1       2        2 0000000 Not Applicable        4
#> 298    1       1          1       1        0 0000000 Not Applicable        1
#> 314    1       1          1       1        0 0000000 Not Applicable        1
#> 339    1       2          2       3        1 0000000 Not Applicable        1
#> 363    0       2          0       2        0 0000000 Not Applicable        4
#> 382    0       3          0       3        0 0000000 Not Applicable        4
#> 383    0      11          0      11        0 0000000 Not Applicable        4
#> 418    1       3          1       3        1 0000000 Not Applicable        2
#> 437    0       3          0       3        0 0000000 Not Applicable        1
#> 440    0       2          0       2        0 0000000 Not Applicable        1
#> 464    1       2          1       2        0 0000000 Not Applicable        1
#> 468    1       1          1       1        0 0000000 Not Applicable        4
#> 475    0       1          0       1        0 0000000 Not Applicable        1
#> 478    0       1          0       1        0 0000000 Not Applicable        1
#> 481    0       3          0       3        0 0000000 Not Applicable        4
#> 486    0       2          0       2        0 0000000 Not Applicable        4
#> 488    1       1          1       1        0 0000000 Not Applicable        4
#> 491    1       1          1       1        0 0000000 Not Applicable        3
#> 492    1       2          1       2        0 0000000 Not Applicable        4
#> 493    1       1          1       1        0 0000000 Not Applicable        4
#> 501    0       2          0       2        0 0000000 Not Applicable        4
#> 502    1       1          1       1        0 0000000 Not Applicable        4
#> 507    1       1          1       1        0 0000000 Not Applicable        4
#> 510    0       2          0       2        0 0000000 Not Applicable        4
#> 511    0       2          0       2        0 0000000 Not Applicable        4
#> 515    1       1          1       1        0 0000000 Not Applicable        1
#> 516    1       1          1       1        0 0000000 Not Applicable        4
#> 517    0       1          0       1        3 0000000 Not Applicable        4
#> 518    1       1          1       1        0 0000000 Not Applicable        4
#> 520    0       6          0       6        0 0000000 Not Applicable        4
#> 521    1       7          1       7        3 0000000 Not Applicable        4
#> 522    0       2          0       2        1 0000000 Not Applicable        4
#> 523    0       1          0       1        1 0000000 Not Applicable        4
#> 524    0       9          0       9        0 0000000 Not Applicable        1
#> 525    0       2          0       2        0 0000000 Not Applicable        4
#>                         RD_OWNERNAME RELJCT1 RELJCT1NAME RELJCT2
#> 59              State Highway Agency       0          No       1
#> 69              State Highway Agency       0          No       3
#> 70                   State Toll Road       0          No       1
#> 99              State Highway Agency       0          No       1
#> 136             State Highway Agency       0          No       1
#> 186 City or Municipal Highway Agency       0          No       1
#> 207 City or Municipal Highway Agency       0          No       1
#> 208             State Highway Agency       1         Yes      20
#> 242 City or Municipal Highway Agency       0          No       2
#> 259 City or Municipal Highway Agency       0          No       2
#> 273 City or Municipal Highway Agency       0          No       1
#> 298             State Highway Agency       0          No       1
#> 314             State Highway Agency       0          No       1
#> 339             State Highway Agency       0          No       1
#> 363 City or Municipal Highway Agency       0          No       2
#> 382 City or Municipal Highway Agency       0          No       2
#> 383 City or Municipal Highway Agency       0          No       1
#> 418            County Highway Agency       0          No       1
#> 437             State Highway Agency       0          No       1
#> 440             State Highway Agency       0          No       1
#> 464             State Highway Agency       0          No       1
#> 468 City or Municipal Highway Agency       0          No       1
#> 475             State Highway Agency       0          No       1
#> 478             State Highway Agency       0          No       1
#> 481 City or Municipal Highway Agency       0          No       2
#> 486 City or Municipal Highway Agency       0          No       1
#> 488 City or Municipal Highway Agency       0          No       3
#> 491  Town or Township Highway Agency       0          No       3
#> 492 City or Municipal Highway Agency       0          No       3
#> 493 City or Municipal Highway Agency       0          No       4
#> 501 City or Municipal Highway Agency       0          No       1
#> 502 City or Municipal Highway Agency       0          No       7
#> 507 City or Municipal Highway Agency       0          No       3
#> 510 City or Municipal Highway Agency       0          No       1
#> 511 City or Municipal Highway Agency       0          No       2
#> 515             State Highway Agency       0          No       3
#> 516 City or Municipal Highway Agency       0          No       3
#> 517 City or Municipal Highway Agency       0          No       1
#> 518 City or Municipal Highway Agency       0          No       3
#> 520 City or Municipal Highway Agency       0          No       2
#> 521 City or Municipal Highway Agency       0          No       3
#> 522 City or Municipal Highway Agency       0          No       1
#> 523 City or Municipal Highway Agency       0          No       3
#> 524             State Highway Agency       0          No       2
#> 525 City or Municipal Highway Agency       0          No       1
#>              RELJCT2NAME REL_ROAD         REL_ROADNAME ROAD_FNC ROAD_FNCNAME
#> 59          Non-Junction        1           On Roadway       NA           NA
#> 69  Intersection-Related        1           On Roadway       NA           NA
#> 70          Non-Junction        1           On Roadway       NA           NA
#> 99          Non-Junction        1           On Roadway       NA           NA
#> 136         Non-Junction        1           On Roadway       NA           NA
#> 186         Non-Junction        1           On Roadway       NA           NA
#> 207         Non-Junction        1           On Roadway       NA           NA
#> 208   Entrance/Exit Ramp        1           On Roadway       NA           NA
#> 242         Intersection        1           On Roadway       NA           NA
#> 259         Intersection        1           On Roadway       NA           NA
#> 273         Non-Junction        4          On Roadside       NA           NA
#> 298         Non-Junction        1           On Roadway       NA           NA
#> 314         Non-Junction        1           On Roadway       NA           NA
#> 339         Non-Junction        2          On Shoulder       NA           NA
#> 363         Intersection        1           On Roadway       NA           NA
#> 382         Intersection        1           On Roadway       NA           NA
#> 383         Non-Junction        3            On Median       NA           NA
#> 418         Non-Junction        1           On Roadway       NA           NA
#> 437         Non-Junction        1           On Roadway       NA           NA
#> 440         Non-Junction        1           On Roadway       NA           NA
#> 464         Non-Junction        1           On Roadway       NA           NA
#> 468         Non-Junction        1           On Roadway       NA           NA
#> 475         Non-Junction        4          On Roadside       NA           NA
#> 478         Non-Junction        4          On Roadside       NA           NA
#> 481         Intersection        1           On Roadway       NA           NA
#> 486         Non-Junction        3            On Median       NA           NA
#> 488 Intersection-Related        1           On Roadway       NA           NA
#> 491 Intersection-Related        1           On Roadway       NA           NA
#> 492 Intersection-Related        1           On Roadway       NA           NA
#> 493      Driveway Access        1           On Roadway       NA           NA
#> 501         Non-Junction        4          On Roadside       NA           NA
#> 502   Crossover-Related         1           On Roadway       NA           NA
#> 507 Intersection-Related        1           On Roadway       NA           NA
#> 510         Non-Junction        3            On Median       NA           NA
#> 511         Intersection        1           On Roadway       NA           NA
#> 515 Intersection-Related        1           On Roadway       NA           NA
#> 516 Intersection-Related        4          On Roadside       NA           NA
#> 517         Non-Junction        7 In Parking Lane/Zone       NA           NA
#> 518 Intersection-Related        1           On Roadway       NA           NA
#> 520         Intersection        1           On Roadway       NA           NA
#> 521 Intersection-Related        1           On Roadway       NA           NA
#> 522         Non-Junction        5   Outside Trafficway       NA           NA
#> 523 Intersection-Related        3            On Median       NA           NA
#> 524         Intersection        1           On Roadway       NA           NA
#> 525         Non-Junction        3            On Median       NA           NA
#>     ROUTE                   ROUTENAME RUR_URB RUR_URBNAME SCH_BUS SCH_BUSNAME
#> 59      1                  Interstate       2       Urban       0          No
#> 69      3               State Highway       2       Urban       0          No
#> 70      1                  Interstate       2       Urban       0          No
#> 99      1                  Interstate       2       Urban       0          No
#> 136     1                  Interstate       2       Urban       0          No
#> 186     6 Local Street - Municipality       2       Urban       0          No
#> 207     6 Local Street - Municipality       2       Urban       0          No
#> 208     1                  Interstate       2       Urban       0          No
#> 242     6 Local Street - Municipality       2       Urban       0          No
#> 259     6 Local Street - Municipality       2       Urban       0          No
#> 273     6 Local Street - Municipality       2       Urban       0          No
#> 298     2                  US Highway       2       Urban       0          No
#> 314     1                  Interstate       2       Urban       0          No
#> 339     1                  Interstate       2       Urban       0          No
#> 363     6 Local Street - Municipality       2       Urban       0          No
#> 382     6 Local Street - Municipality       2       Urban       0          No
#> 383     6 Local Street - Municipality       2       Urban       0          No
#> 418     6 Local Street - Municipality       2       Urban       0          No
#> 437     3               State Highway       2       Urban       0          No
#> 440     3               State Highway       2       Urban       0          No
#> 464     1                  Interstate       2       Urban       0          No
#> 468     3               State Highway       2       Urban       0          No
#> 475     3               State Highway       2       Urban       0          No
#> 478     3               State Highway       2       Urban       0          No
#> 481     6 Local Street - Municipality       2       Urban       0          No
#> 486     3               State Highway       2       Urban       0          No
#> 488     2                  US Highway       2       Urban       0          No
#> 491     6 Local Street - Municipality       2       Urban       0          No
#> 492     6 Local Street - Municipality       2       Urban       0          No
#> 493     6 Local Street - Municipality       2       Urban       0          No
#> 501     6 Local Street - Municipality       2       Urban       0          No
#> 502     6 Local Street - Municipality       2       Urban       0          No
#> 507     1                  Interstate       2       Urban       0          No
#> 510     6 Local Street - Municipality       2       Urban       0          No
#> 511     6 Local Street - Municipality       2       Urban       0          No
#> 515     3               State Highway       2       Urban       0          No
#> 516     6 Local Street - Municipality       2       Urban       0          No
#> 517     6 Local Street - Municipality       2       Urban       0          No
#> 518     6 Local Street - Municipality       2       Urban       0          No
#> 520     6 Local Street - Municipality       2       Urban       0          No
#> 521     6 Local Street - Municipality       2       Urban       0          No
#> 522     6 Local Street - Municipality       2       Urban       0          No
#> 523     6 Local Street - Municipality       2       Urban       0          No
#> 524     3               State Highway       2       Urban       0          No
#> 525     6 Local Street - Municipality       2       Urban       0          No
#>     SP_JUR              SP_JURNAME STATENAME ST_CASE State
#> 59       0 No Special Jurisdiction  Maryland  240061    24
#> 69       0 No Special Jurisdiction  Maryland  240071    24
#> 70       0 No Special Jurisdiction  Maryland  240072    24
#> 99       0 No Special Jurisdiction  Maryland  240103    24
#> 136      0 No Special Jurisdiction  Maryland  240144    24
#> 186      0 No Special Jurisdiction  Maryland  240194    24
#> 207      0 No Special Jurisdiction  Maryland  240216    24
#> 208      0 No Special Jurisdiction  Maryland  240217    24
#> 242      0 No Special Jurisdiction  Maryland  240252    24
#> 259      0 No Special Jurisdiction  Maryland  240269    24
#> 273      0 No Special Jurisdiction  Maryland  240283    24
#> 298      0 No Special Jurisdiction  Maryland  240308    24
#> 314      0 No Special Jurisdiction  Maryland  240324    24
#> 339      0 No Special Jurisdiction  Maryland  240350    24
#> 363      0 No Special Jurisdiction  Maryland  240374    24
#> 382      0 No Special Jurisdiction  Maryland  240393    24
#> 383      0 No Special Jurisdiction  Maryland  240394    24
#> 418      0 No Special Jurisdiction  Maryland  240429    24
#> 437      0 No Special Jurisdiction  Maryland  240449    24
#> 440      0 No Special Jurisdiction  Maryland  240452    24
#> 464      0 No Special Jurisdiction  Maryland  240476    24
#> 468      0 No Special Jurisdiction  Maryland  240480    24
#> 475      0 No Special Jurisdiction  Maryland  240487    24
#> 478      0 No Special Jurisdiction  Maryland  240490    24
#> 481      0 No Special Jurisdiction  Maryland  240493    24
#> 486      0 No Special Jurisdiction  Maryland  240498    24
#> 488      0 No Special Jurisdiction  Maryland  240500    24
#> 491      0 No Special Jurisdiction  Maryland  240503    24
#> 492      0 No Special Jurisdiction  Maryland  240504    24
#> 493      0 No Special Jurisdiction  Maryland  240505    24
#> 501      0 No Special Jurisdiction  Maryland  240513    24
#> 502      0 No Special Jurisdiction  Maryland  240514    24
#> 507      0 No Special Jurisdiction  Maryland  240519    24
#> 510      0 No Special Jurisdiction  Maryland  240522    24
#> 511      0 No Special Jurisdiction  Maryland  240523    24
#> 515      0 No Special Jurisdiction  Maryland  240527    24
#> 516      0 No Special Jurisdiction  Maryland  240528    24
#> 517      0 No Special Jurisdiction  Maryland  240529    24
#> 518      0 No Special Jurisdiction  Maryland  240530    24
#> 520      0 No Special Jurisdiction  Maryland  240532    24
#> 521      0 No Special Jurisdiction  Maryland  240533    24
#> 522      0 No Special Jurisdiction  Maryland  240534    24
#> 523      0 No Special Jurisdiction  Maryland  240535    24
#> 524      0 No Special Jurisdiction  Maryland  240536    24
#> 525      0 No Special Jurisdiction  Maryland  240537    24
#>                       TWAY_ID        TWAY_ID2 TYP_INT           TYP_INTNAME
#> 59                      I-895                       1   Not an Intersection
#> 69         SR-150 EASTERN AVE     ANGLESEA ST       2 Four-Way Intersection
#> 70                     I-395A                       1   Not an Intersection
#> 99                      I-395                       1   Not an Intersection
#> 136                     I-395                       1   Not an Intersection
#> 186                   MU-1030                       1   Not an Intersection
#> 207                   MU-6366                       1   Not an Intersection
#> 208                 I-95 RAMP                       1   Not an Intersection
#> 242                   MU-1023    EVERGREEN ST       2 Four-Way Intersection
#> 259                   MU-1022          SR-129       2 Four-Way Intersection
#> 273                   MU-2950                       1   Not an Intersection
#> 298                      US-1                       1   Not an Intersection
#> 314                     I-895                       1   Not an Intersection
#> 339                      I-95                       1   Not an Intersection
#> 363                   MU-4021         MU-2945       2 Four-Way Intersection
#> 382                   MU-1021  CLEARSPRING RD       3        T-Intersection
#> 383                    MU-100                       1   Not an Intersection
#> 418                   MU-4200                       1   Not an Intersection
#> 437                    SR-695                       1   Not an Intersection
#> 440                     SR-26                       1   Not an Intersection
#> 464                      I-83                       1   Not an Intersection
#> 468                      SR-2                       1   Not an Intersection
#> 475                    SR-173                       1   Not an Intersection
#> 478                    SR-171                       1   Not an Intersection
#> 481                    MU-101       LEWIN AVE       3        T-Intersection
#> 486         SR-295 RUSSELL ST                       1   Not an Intersection
#> 488                      US-1     SHELDON AVE       2 Four-Way Intersection
#> 491                   MU-1359 E LAFAYETTE AVE      98          Not Reported
#> 492                   MU-6169         MU-4500       2 Four-Way Intersection
#> 493        MU-7864 LANVALE ST                       1   Not an Intersection
#> 501                   MU-2570                       1   Not an Intersection
#> 502                   MU-1445                       1   Not an Intersection
#> 507                      I-83         MU-1680       2 Four-Way Intersection
#> 510                   MU-1022                       1   Not an Intersection
#> 511                   MU-2945         MU-4021       2 Four-Way Intersection
#> 515   SR-129 PARK HEIGHTS AVE       CLOVER RD      98          Not Reported
#> 516                   MU-2125         MU-1023       4        Y-Intersection
#> 517                   MU-1395                       1   Not an Intersection
#> 518                   MU-7508         MU-7636       2 Four-Way Intersection
#> 520                   MU-6169            US-1       2 Four-Way Intersection
#> 521                   MU-1665         MU-2971       2 Four-Way Intersection
#> 522     MU-1420 S CENTRAL AVE                       1   Not an Intersection
#> 523        MU-2940 EDISON HWY       EMLEY AVE       2 Four-Way Intersection
#> 524 SR-26 LIBERTY HEIGHTS AVE    GRANTLEY AVE       4        Y-Intersection
#> 525    MU-13701 E MONUMENT ST                       1   Not an Intersection
#>     VE_FORMS VE_TOTAL WEATHER WEATHER1 WEATHER1NAME WEATHER2 WEATHER2NAME
#> 59         1        1       2       NA           NA       NA           NA
#> 69         1        1       2       NA           NA       NA           NA
#> 70         1        1       1       NA           NA       NA           NA
#> 99         4        4       5       NA           NA       NA           NA
#> 136        2        2       1       NA           NA       NA           NA
#> 186        1        1      10       NA           NA       NA           NA
#> 207        2        2      10       NA           NA       NA           NA
#> 208        2        2       1       NA           NA       NA           NA
#> 242        2        2       1       NA           NA       NA           NA
#> 259        2        2      10       NA           NA       NA           NA
#> 273        1        3      10       NA           NA       NA           NA
#> 298        1        1      10       NA           NA       NA           NA
#> 314        1        1      98       NA           NA       NA           NA
#> 339        3        4       1       NA           NA       NA           NA
#> 363        2        2       1       NA           NA       NA           NA
#> 382        2        2       1       NA           NA       NA           NA
#> 383        5        5      10       NA           NA       NA           NA
#> 418        1        2       1       NA           NA       NA           NA
#> 437        2        2       2       NA           NA       NA           NA
#> 440        2        2       1       NA           NA       NA           NA
#> 464        1        1       1       NA           NA       NA           NA
#> 468        1        1      98       NA           NA       NA           NA
#> 475        1        1       1       NA           NA       NA           NA
#> 478        1        1      10       NA           NA       NA           NA
#> 481        2        2       1       NA           NA       NA           NA
#> 486        1        1       1       NA           NA       NA           NA
#> 488        1        1       1       NA           NA       NA           NA
#> 491        1        1       1       NA           NA       NA           NA
#> 492        1        1       1       NA           NA       NA           NA
#> 493        1        1       1       NA           NA       NA           NA
#> 501        1        1      10       NA           NA       NA           NA
#> 502        1        1       1       NA           NA       NA           NA
#> 507        1        1       1       NA           NA       NA           NA
#> 510        1        1       2       NA           NA       NA           NA
#> 511        2        2       1       NA           NA       NA           NA
#> 515        1        1       2       NA           NA       NA           NA
#> 516        1        1       1       NA           NA       NA           NA
#> 517        1        4       1       NA           NA       NA           NA
#> 518        1        1       1       NA           NA       NA           NA
#> 520        2        2       1       NA           NA       NA           NA
#> 521        3        6       1       NA           NA       NA           NA
#> 522        1        2       1       NA           NA       NA           NA
#> 523        1        2      10       NA           NA       NA           NA
#> 524        4        4       1       NA           NA       NA           NA
#> 525        1        1       1       NA           NA       NA           NA
#>          WEATHERNAME WRK_ZONE            WRK_ZONENAME YEAR
#> 59              Rain        0                    None 2022
#> 69              Rain        0                    None 2022
#> 70             Clear        0                    None 2022
#> 99  Fog, Smog, Smoke        0                    None 2022
#> 136            Clear        0                    None 2022
#> 186           Cloudy        0                    None 2022
#> 207           Cloudy        0                    None 2022
#> 208            Clear        0                    None 2022
#> 242            Clear        0                    None 2022
#> 259           Cloudy        0                    None 2022
#> 273           Cloudy        0                    None 2022
#> 298           Cloudy        0                    None 2022
#> 314     Not Reported        0                    None 2022
#> 339            Clear        0                    None 2022
#> 363            Clear        0                    None 2022
#> 382            Clear        0                    None 2022
#> 383           Cloudy        0                    None 2022
#> 418            Clear        0                    None 2022
#> 437             Rain        0                    None 2022
#> 440            Clear        0                    None 2022
#> 464            Clear        0                    None 2022
#> 468     Not Reported        0                    None 2022
#> 475            Clear        0                    None 2022
#> 478           Cloudy        0                    None 2022
#> 481            Clear        0                    None 2022
#> 486            Clear        0                    None 2022
#> 488            Clear        0                    None 2022
#> 491            Clear        0                    None 2022
#> 492            Clear        0                    None 2022
#> 493            Clear        0                    None 2022
#> 501           Cloudy        0                    None 2022
#> 502            Clear        0                    None 2022
#> 507            Clear        0                    None 2022
#> 510             Rain        0                    None 2022
#> 511            Clear        0                    None 2022
#> 515             Rain        0                    None 2022
#> 516            Clear        0                    None 2022
#> 517            Clear        0                    None 2022
#> 518            Clear        0                    None 2022
#> 520            Clear        0                    None 2022
#> 521            Clear        0                    None 2022
#> 522            Clear        4 Work Zone, Type Unknown 2022
#> 523           Cloudy        0                    None 2022
#> 524            Clear        0                    None 2022
#> 525            Clear        0                    None 2022

# \donttest{
# National accident table from the zipped data files
get_fars(year = 2024)
#> Converting CSV to parquet ■■■■■■■■■■■■■■■■■■■               61% | ETA:  4s
#> Converting CSV to parquet ■■■■■■■■■■■■■■■■■■■■■■■■■■■■      91% | ETA:  1s
#> # A data frame: 36,297 × 81
#>    STATE STATENAME ST_CASE  PEDS PERNOTMVIT VE_TOTAL VE_FORMS PVH_INVL PERSONS
#>    <dbl> <chr>       <dbl> <dbl>      <dbl>    <dbl>    <dbl>    <dbl>   <dbl>
#>  1     1 Alabama     10001     0          0        1        1        0       1
#>  2     1 Alabama     10002     0          0        1        1        0       1
#>  3     1 Alabama     10003     1          1        1        1        0       2
#>  4     1 Alabama     10004     1          1        1        1        0       1
#>  5     1 Alabama     10005     1          2        3        1        2       2
#>  6     1 Alabama     10006     1          1        1        1        0       1
#>  7     1 Alabama     10007     0          0        2        2        0       2
#>  8     1 Alabama     10008     1          1        1        1        0       2
#>  9     1 Alabama     10009     0          0        2        2        0       4
#> 10     1 Alabama     10010     0          0        1        1        0       4
#> # ℹ 36,287 more rows
#> # ℹ 72 more variables: PERMVIT <dbl>, COUNTY <dbl>, COUNTYNAME <chr>,
#> #   CITY <dbl>, CITYNAME <chr>, MONTH <dbl>, MONTHNAME <chr>, DAY <dbl>,
#> #   DAYNAME <dbl>, DAY_WEEK <dbl>, DAY_WEEKNAME <chr>, YEAR <dbl>, HOUR <dbl>,
#> #   HOURNAME <chr>, MINUTE <dbl>, MINUTENAME <chr>, TWAY_ID <chr>,
#> #   TWAY_ID2 <chr>, ROUTE <dbl>, ROUTENAME <chr>, RUR_URB <dbl>,
#> #   RUR_URBNAME <chr>, FUNC_SYS <dbl>, FUNC_SYSNAME <chr>, RD_OWNER <dbl>, …
# }
```
