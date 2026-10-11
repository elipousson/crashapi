# Get Fatality Analysis Reporting System (FARS) data with the FARS API

This function provides a convenient interface for accessing FARS data or
data summaries using a range of criteria. The `api` parameter allows you
to call one of the following functions to access DOT NHTSA’s Crash API:

- `get_fars_crash_list` returns a list of fatal crashes that have
  occurred in multiple states in one or more years.

- `get_fars_crash_details` returns a details of a fatal crash that has
  occurred in a state for a single year.

- `get_fars_crashes` a list of fatal crashes by location that have
  occurred throughout U.S.

- `get_fars_summary` provides a count of injury severity that have
  occurred throughout U.S. including count of fatalities and crashes.

- `get_fars_year` provides one of 20 FARS data tables for a single year.
  Supports downloading to a CSV or JSON file.

Both `get_fars_crash_list` and `get_fars_crashes` limit the returned
data to 5000 records so consider limiting the range of years requested
if data exceeds that threshold.

This package also enables access to the FARS data available through the
NHTSA data downloads server in a zip format. Set `api` to "zip" or use
the `get_fars_zip` function to download this data.

## Usage

``` r
get_fars(
  state,
  year = getOption("crashapi.year", 2024),
  county = NULL,
  api = c("crashes", "cases", "state list", "summary count", "year dataset", "zip"),
  type = NULL,
  details = FALSE,
  geometry = FALSE,
  crs = NULL,
  cases = NULL,
  vehicles = NULL,
  format = "json",
  pr = FALSE,
  path = NULL,
  download = FALSE,
  labels = TRUE
)

get_fars_crashes(
  state,
  county,
  year = getOption("crashapi.year", 2024),
  details = FALSE,
  geometry = FALSE,
  crs = NULL,
  labels = TRUE
)

get_fars_cases(
  state,
  cases,
  year = getOption("crashapi.year", 2024),
  details = FALSE,
  geometry = FALSE,
  crs = NULL,
  labels = TRUE
)

get_fars_crash_list(
  state,
  year = getOption("crashapi.year", 2024),
  vehicles = c(1, 50),
  labels = TRUE
)

get_fars_summary(state, year = getOption("crashapi.year", 2024), labels = TRUE)

get_fars_year(
  state,
  year = getOption("crashapi.year", 2024),
  type = "accident",
  format = "json",
  path = NULL,
  geometry = FALSE,
  crs = NULL,
  download = FALSE,
  labels = TRUE,
  call = caller_env()
)
```

## Arguments

- state:

  Required. State name, abbreviation, or FIPS number.
  `get_fars_crash_list` supports multiple states.

- year:

  numeric vector. One or more years. For `get_fars_crashes`,
  `get_fars_crash_list`, `get_fars_summary`, and `get_fars_year` (and
  the corresponding `api` values), the minimum and maximum values are
  used as the start and end year, so `year = 2015:2020` and
  `year = c(2015, 2020)` both request data from 2015 through 2020 (with
  a message if `year` has gaps). For `get_fars_cases`, `year` must be a
  single year or one year for each case in `cases`. For `get_fars_zip`,
  each year is downloaded separately. Most `api` options support the
  years from 2010 through 2024 and "zip" supports 1975 to 2024. Defaults
  to `getOption("crashapi.year", 2024)` so the default year can be set
  for all functions with `options(crashapi.year = 2022)`.

- county:

  County name or FIPS number. Required for `get_fars_crashes`.

- api:

  character. API function to use. Supported values include "crashes",
  "cases", "state list", "summary count", "year dataset", and "zip". If
  `api` is not provided, it is "cases" if `cases` is provided, "state
  list" if `vehicles` is provided, "year dataset" if `type` is provided,
  "zip" if `pr` is `TRUE`, and "crashes" otherwise.

- type:

  Name of the dataset or data file to download when using the "year
  dataset" api or `get_fars_year`. Supported values include "ACCIDENT",
  "CEVENT", "DAMAGE", "DISTRACT", "DRIMPAIR", "DRUGS", "FACTOR",
  "MANEUVER", "NMCRASH", "NMIMPAIR", "NMPRIOR", "PARKWORK", "PBTYPE",
  "PERSON", "SAFETYEQ", "VEHICLE", "VEVENT", "VINDECODE", "VINDERIVED",
  "VIOLATION", "VISION", and "VSOE". "TRAILERVINDERIVED" is supported
  for 2016 onwards, "NMDISTRACT" and "RACE" for 2019 onwards, and
  "CRASHRF", "DRIVERRF", "PERSONRF", "PVEHICLESF", "VEHICLESF", and
  "WEATHER" for 2020 onwards. Lowercase or mixed case values are
  permitted.

- details:

  Type of detailed crash data to return (either "events" or "vehicles").
  If `TRUE` for `get_fars` or `get_fars_crashes`, detailed case data
  (excluding event and vehicle data) is attached to the returned crash
  data. If `NULL` for `get_fars_cases`, events and vehicle data are
  excluded from the returned case data. returned by `get_fars_cases`.
  Optional for `get_fars_crash_details`. Default: `NULL` for
  `get_fars_cases`; `FALSE` for `get_fars` and `get_fars_crashes`.

- geometry:

  If `TRUE`, return sf object. Optional for `get_fars_crashes`.

- crs:

  Coordinate reference system to return for `get_fars_crashes` if
  `geometry` is `TRUE`.

- cases:

  One or more FARS case numbers. Required if `api` is "cases" or using
  `get_fars_cases`. Multiple case numbers can be provided.

- vehicles:

  numeric vector with the minimum and maximum number of vehicles, e.g.
  c(1, 2) for minimum of 1 vehicle and maximum of 2. Required for
  `get_fars_crash_list`.

- format:

  Default "json". "csv" is supported when using the "year dataset" api.
  "csv" and "sas" are supported for the "zip" api ("json" is treated as
  "csv").

- pr:

  logical. If `TRUE`, download zip file with FARS data for Puerto Rico.
  Puerto Rico data is available for 1978 and from 1980 onwards. Default:
  `FALSE` for `get_fars_zip` only.

- path:

  File path used if download is `TRUE`.

- download:

  logical. If `TRUE` and the `api` is "year dataset" or "zip", download
  the data to a file. Default `FALSE`.

- labels:

  If `TRUE` (default), add a `"label"` attribute to each column with a
  variable label from
  [fars_vars_labels](https://elipousson.github.io/crashapi/reference/fars_vars_labels.md).
  Labels are shown by [`View()`](https://rdrr.io/r/utils/View.html) in
  RStudio and Positron and used by packages such as gt and gtsummary.

- call:

  The execution environment of a currently running function, e.g.
  `caller_env()`. The function will be mentioned in error messages as
  the source of the error. See the `call` argument of
  [`abort()`](https://rlang.r-lib.org/reference/abort.html) for more
  information.

## Examples

``` r

head(get_fars_crashes(state = "MD", county = "Baltimore city"), 5)
#>   CaseYear TOTALVEHICLES STATE STATENAME ST_CASE VE_FORMS COUNTY
#> 1     2024             1    24  Maryland  240017        1    510
#> 2     2024             2    24  Maryland  240061        2    510
#> 3     2024             5    24  Maryland  240076        2    510
#> 4     2024             1    24  Maryland  240154        1    510
#> 5     2024             1    24  Maryland  240177        1    510
#>               COUNTYNAME CITY  CITYNAME                TWAY_ID  TWAY_ID2
#> 1 BALTIMORE (CITY) (510)   50 BALTIMORE    MU-6448 ST GEMMA RD          
#> 2 BALTIMORE (CITY) (510)   50 BALTIMORE    MU- 101 S CATON AVE          
#> 3 BALTIMORE (CITY) (510)   50 BALTIMORE SR-140 REISTERSTOWN RD ANOKA AVE
#> 4 BALTIMORE (CITY) (510)   50 BALTIMORE              I-95 RAMP          
#> 5 BALTIMORE (CITY) (510)   50 BALTIMORE  MU-06910 E MCCOMAS ST          
#>   LATITUDE  LONGITUD FATALS
#> 1 39.29651 -76.70910      1
#> 2 39.27644 -76.67159      1
#> 3 39.32158 -76.65497      1
#> 4 39.26835 -76.63529      1
#> 5 39.26340 -76.58767      1

get_fars_cases(state = "MD", cases = "240274")
#>   ARR_HOUR                   ARR_HOURNAME ARR_MIN
#> 1       99 Unknown EMS Scene Arrival Hour      99
#>                         ARR_MINNAME CF1 CF1NAME CF2 CF2NAME CF3 CF3NAME CITY
#> 1 Unknown EMS Scene Arrival Minutes  NA      NA  NA      NA  NA      NA   50
#>    CITYNAME COUNTY             COUNTYNAME CaseYear
#> 1 BALTIMORE    510 BALTIMORE (CITY) (510)     2024
#>                                        CrashRFs DAY DAYNAME DAY_WEEK
#> 1 0, None Noted, 2024, 24, MD, Maryland, 240274  19      19        1
#>   DAY_WEEKNAME DRUNK_DR FATALS FUNC_SYS   FUNC_SYSNAME HARM_EV HARM_EVNAME
#> 1       Sunday       NA      1        4 Minor Arterial       8  Pedestrian
#>   HOSP_HR HOSP_HRNAME HOSP_MN                       HOSP_MNNAME HOUR
#> 1      99     Unknown      99 Unknown EMS Hospital Arrival Time    3
#>        HOURNAME    LATITUDE LATITUDENAME LGT_COND   LGT_CONDNAME      LONGITUD
#> 1 3:00am-3:59am 39.23503889  39.23503889        3 Dark - Lighted -76.605994440
#>   LONGITUDNAME MAN_COLL
#> 1 -76.60599444        0
#>                                                                    MAN_COLLNAME
#> 1 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#>   MILEPT MILEPTNAME MINUTE MINUTENAME MONTH MonthName NHS
#> 1     34         34     10         10     5       May   0
#>                          NHSNAME
#> 1 This Section IS NOT on the NHS
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           NMDrugs
#> 1 2024, 2024, 2024, 2024, 2024, 0.050, -99.000, -99.000, 1.500, 0.280, 0.050, Not Applicable, Not Applicable, 1.500, 0.280, 19, 9, 9, 19, 19, Unknown Confirmatory Test Method, Unknown Screening Test Method, Unknown Screening Test Method, Unknown Confirmatory Test Method, Unknown Confirmatory Test Method, 2, 3, 3, 2, 2, Actual Drug Quantity, Presumptive Positive, Presumptive Positive, Actual Drug Quantity, Actual Drug Quantity, 1059, 1123, 2175, 3022, 3033, Fentanyl, 4-anilino-N-phenethylpiperidine (4-ANPP; 4-aminophenyl-1-phenethylpiperidine; Despropionyl fentanyl), Quinine, Benzoylecgonine, Cocaine, 1, 1, 1, 1, 1, Whole Blood, Whole Blood, Whole Blood, Whole Blood, Whole Blood, 2, -9, -9, 2, 2, mg/L, Not Applicable, Not Applicable, mg/L, mg/L, 1, 1, 1, 1, 1, 24, 24, 24, 24, 24, MD, MD, MD, MD, MD, Maryland, Maryland, Maryland, Maryland, Maryland, 240274, 240274, 240274, 240274, 240274, 0, 0, 0, 0, 0
#>                                            NMPersonRF
#> 1 2024, 0, None Noted, 1, 24, MD, Maryland, 240274, 0
#>                                                                         NMRace
#> 1 2024, 0, No, 1, 1, 2, Black or African American, 24, MD, Maryland, 240274, 0
#>   NOT_HOUR NOT_HOURNAME NOT_MIN NOT_MINNAME
#> 1       99      Unknown      99     Unknown
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  NPersons
#> 1 54, 54 Years, 97, Not a Motor Vehicle Occupant, NA, NA, 0, 0.000 % BAC, 2, Test Given, 8, Other Test Type, NA, NA, NA, 510, BALTIMORE (CITY) (510), 2024, 19, 19, 19, 19, 4, 4:00-4:59, 5, 5, 5, May, 405, 405, 2024, 2024, 0, Not Applicable, 0, Not Applicable, 0, Not Applicable, 0, No (Alcohol Not Involved), NA, NA, NA, NA, NA, NA, 1, Yes (drugs involved), NA, NA, NA, NA, NA, NA, NA, NA, 2, Test Given, 8, Not Applicable, 0, Ejection Path Not Applicable, NA, NA, 0, Not Extricated or Not Applicable, NA, NA, 4, Minor Arterial, NA, NA, NA, NA, 8, Pedestrian, 8, Not a Motor Vehicle Occupant, 96, Not a Motor Vehicle Occupant, 7, Non-Hispanic, 5, EMS Ground, 3, 3:00am-3:59am, NA, NA, NA, NA, NA, NA, 4, Fatal Injury (K), 0, 0, 55, 55, 11, Not at Intersection - On Roadway, Not in Marked Crosswalk, NA, NA, NA, NA, 0, The First Harmful Event was Not a Collision with a Motor Vehicle in Transport, 10, 10, NA, NA, 5, May, NA, NA, 1, 5, Pedestrian, NA, NA, NA, NA, NA, NA, NA, NA, NA, 8, Not a Motor Vehicle Occupant, 96, Not a Motor Vehicle Occupant, NA, NA, NA, NA, 2, Urban, NA, 0, No, 0, Not a Motor Vehicle Occupant, 1, Male, NA, NA, 24, Maryland, 1, 01, 240274, NA, NA, 0, 1, NA, NA, NA, NA, NA, NA, 0, No
#>                                                                                              NmCrashes
#> 1 2024, 2, Failure to Yield Right-Of-Way, 2, Failure to Yield Right-Of-Way, 1, 24, Maryland, 240274, 0
#>                                                                   NmDistract
#> 1 2024, 0, Not Distracted, 0, Not Distracted, 1, 24, MD, Maryland, 240274, 0
#>                                                                                  NmImpairs
#> 1 2024, 9, Under the Influence of Alcohol, Drugs or Medication, 1, 24, Maryland, 240274, 0
#>                                                                     NmPriors
#> 1 2024, 3, Crossing Roadway, 3, Crossing Roadway, 1, 24, Maryland, 240274, 0
#>   PEDS PERMVIT PERNOTMVIT PERSONS PVH_INVL ParkWorks
#> 1    1       1          1       1        0        NA
#>                                                                                                                                                                                                                                                                                                                                                                                                                       PbTypes
#> 1 0, Not a Cyclist, 0, Not a Cyclist, 7, Not a Cyclist, 7, Not a Cyclist, 7, Not a Cyclist, 2024, 8, Not Applicable, 8, Not Applicable, 54, 54 Years, 0, None Noted, 5, Pedestrian, 1, Male, 1, Yes, 0, None Noted, 750, Crossing Roadway - Vehicle Not Turning, 760, Pedestrian Failed to Yield, 8, Not Applicable, 8, Not Applicable, 3, Not At Intersection, 3, Travel Lane, 8, Not Applicable, 1, 24, Maryland, 240274, 0
#>      RAIL       RAILNAME RD_OWNER                     RD_OWNERNAME RELJCT1
#> 1 0000000 Not Applicable        4 City or Municipal Highway Agency       0
#>   RELJCT1NAME RELJCT2  RELJCT2NAME REL_ROAD REL_ROADNAME ROAD_FNC ROAD_FNCNAME
#> 1          No       1 Non-Junction        1   On Roadway       NA           NA
#>   ROUTE ROUTENAME RUR_URB RUR_URBNAME SCH_BUS SCH_BUSNAME SP_JUR
#> 1     6 Municipal       2       Urban       0          No      0
#>                SP_JURNAME STATENAME ST_CASE
#> 1 No Special Jurisdiction  Maryland  240274
#>                                                                               SafetyEQs
#> 1 2024, -1, Blank, 1, No, 1, No, 1, No, 1, No, 1, No, 1, No, 1, 24, Maryland, 240274, 0
#>   State               TWAY_ID TWAY_ID2 TYP_INT         TYP_INTNAME VE_FORMS
#> 1    24 MU- 6663 WASHBURN AVE                1 Not an Intersection        1
#>   VE_TOTAL WEATHER WEATHER1 WEATHER1NAME WEATHER2 WEATHER2NAME WEATHERNAME
#> 1        1       1       NA           NA       NA           NA       Clear
#>   WRK_ZONE WRK_ZONENAME                                 Weathers YEAR
#> 1        0         None 2024, 24, MD, Maryland, 240274, 1, Clear 2024

get_fars_crash_list(state = "MD", vehicles = 5)
#>               CountyName                  CrashDate Fatals Peds Persons St_Case
#> 1        DORCHESTER (19) /Date(1715252760000-0400)/      1    0       7  240031
#> 2       ANNE ARUNDEL (3) /Date(1706941620000-0500)/      1    0       6  240040
#> 3 BALTIMORE (CITY) (510) /Date(1720028520000-0400)/      1    0       2  240076
#> 4 BALTIMORE (CITY) (510) /Date(1708518540000-0500)/      2    0       9  240253
#> 5        WASHINGTON (43) /Date(1727990160000-0400)/      1    0       5  240370
#> 6            CALVERT (9) /Date(1726585260000-0400)/      1    0       2  240375
#> 7          BALTIMORE (5) /Date(1729707300000-0400)/      2    0       6  240434
#>   State StateName TotalVehicles
#> 1    24  Maryland             5
#> 2    24  Maryland             5
#> 3    24  Maryland             5
#> 4    24  Maryland             5
#> 5    24  Maryland             5
#> 6    24  Maryland             5
#> 7    24  Maryland             5

get_fars_summary(state = "MD")
#>   CaseYear CrashCounts TotalFatalCounts
#> 1     2024         552              578

head(get_fars_year(state = "MD", type = "PERSON"), 5)
#>   AGE             AGENAME AIR_BAG                    AIR_BAGNAME ALC_DET
#> 1  36            36 Years      97   Not a Motor Vehicle Occupant      NA
#> 2  22            22 Years       1                Deployed- Front      NA
#> 3 998        Not Reported      20                   Not Deployed      NA
#> 4  50            50 Years      97   Not a Motor Vehicle Occupant      NA
#> 5 999 Reported as Unknown      99 Reported as Deployment Unknown      NA
#>   ALC_DETNAME ALC_RES    ALC_RESNAME ALC_STATUS ALC_STATUSNAME ATST_TYP
#> 1          NA     995   Not Reported          8   Not Reported       95
#> 2          NA      27    0.027 % BAC          2     Test Given        2
#> 3          NA     996 Test Not Given          0 Test Not Given        0
#> 4          NA       0    0.000 % BAC          2     Test Given        1
#> 5          NA     996 Test Not Given          0 Test Not Given        0
#>       ATST_TYPNAME BODY_TYP          BODY_TYPNAME CASEYEAR CERT_NO COUNTY
#> 1     Not Reported     <NA>                  <NA>     2024      NA     31
#> 2 Breath Test (AC)        4 4-door sedan, hardtop     2024      NA     31
#> 3   Test Not Given        4 4-door sedan, hardtop     2024      NA     31
#> 4            Blood     <NA>                  <NA>     2024      NA     33
#> 5   Test Not Given       99     Unknown body type     2024      NA     33
#>             COUNTYNAME DAY DAYNAME DEATH_DA               DEATH_DANAME DEATH_HR
#> 1      MONTGOMERY (31)   1       1        1                          1       11
#> 2      MONTGOMERY (31)   1       1       88 Not Applicable (Non-Fatal)       88
#> 3      MONTGOMERY (31)   1       1       88 Not Applicable (Non-Fatal)       88
#> 4 PRINCE GEORGE`S (33)   1       1        1                          1       21
#> 5 PRINCE GEORGE`S (33)   1       1       88 Not Applicable (Non-Fatal)       88
#>                 DEATH_HRNAME DEATH_MN               DEATH_MNNAME DEATH_MO
#> 1                11:00-11:59       17                         17        1
#> 2 Not Applicable (Non-fatal)       88 Not Applicable (Non-fatal)       88
#> 3 Not Applicable (Non-fatal)       88 Not Applicable (Non-fatal)       88
#> 4                21:00-21:59        3                          3        1
#> 5 Not Applicable (Non-fatal)       88 Not Applicable (Non-fatal)       88
#>                 DEATH_MONAME DEATH_TM               DEATH_TMNAME DEATH_YR
#> 1                    January     1117                       1117     2024
#> 2 Not Applicable (Non-Fatal)     8888 Not Applicable (Non-fatal)     8888
#> 3 Not Applicable (Non-Fatal)     8888 Not Applicable (Non-fatal)     8888
#> 4                    January     2103                       2103     2024
#> 5 Not Applicable (Non-Fatal)     8888 Not Applicable (Non-fatal)     8888
#>                 DEATH_YRNAME DEVMOTOR                DEVMOTORNAME DEVTYPE
#> 1                       2024        0              Not Applicable       0
#> 2 Not Applicable (Non-fatal)        8 Occupant of a Motor Vehicle      96
#> 3 Not Applicable (Non-fatal)        8 Occupant of a Motor Vehicle      96
#> 4                       2024        0              Not Applicable       0
#> 5 Not Applicable (Non-fatal)        8 Occupant of a Motor Vehicle      96
#>                   DEVTYPENAME DOA        DOANAME DRINKING
#> 1              Not Applicable   0 Not Applicable        0
#> 2 Occupant of a Motor Vehicle   0 Not Applicable        1
#> 3 Occupant of a Motor Vehicle   0 Not Applicable        8
#> 4              Not Applicable   7  Died at Scene        9
#> 5 Occupant of a Motor Vehicle   0 Not Applicable        9
#>                DRINKINGNAME DRUGRES1 DRUGRES1NAME DRUGRES2 DRUGRES2NAME
#> 1 No (Alcohol Not Involved)       NA           NA       NA           NA
#> 2    Yes (Alcohol Involved)       NA           NA       NA           NA
#> 3              Not Reported       NA           NA       NA           NA
#> 4       Reported as Unknown       NA           NA       NA           NA
#> 5       Reported as Unknown       NA           NA       NA           NA
#>   DRUGRES3 DRUGRES3NAME DRUGS               DRUGSNAME DRUGTST1 DRUGTST1NAME
#> 1       NA           NA     0 No (drugs not involved)       NA           NA
#> 2       NA           NA     0 No (drugs not involved)       NA           NA
#> 3       NA           NA     8            Not Reported       NA           NA
#> 4       NA           NA     9     Reported as Unknown       NA           NA
#> 5       NA           NA     9     Reported as Unknown       NA           NA
#>   DRUGTST2 DRUGTST2NAME DRUGTST3 DRUGTST3NAME DRUG_DET DRUG_DETNAME DSTATUS
#> 1       NA           NA       NA           NA       NA           NA       8
#> 2       NA           NA       NA           NA       NA           NA       0
#> 3       NA           NA       NA           NA       NA           NA       0
#> 4       NA           NA       NA           NA       NA           NA       2
#> 5       NA           NA       NA           NA       NA           NA       0
#>      DSTATUSNAME EJECTION   EJECTIONNAME EJ_PATH                  EJ_PATHNAME
#> 1   Not Reported        8 Not Applicable       0 Ejection Path Not Applicable
#> 2 Test Not Given        0    Not Ejected       0 Ejection Path Not Applicable
#> 3 Test Not Given        0    Not Ejected       0 Ejection Path Not Applicable
#> 4     Test Given        8 Not Applicable       0 Ejection Path Not Applicable
#> 5 Test Not Given        0    Not Ejected       0 Ejection Path Not Applicable
#>   EMER_USE        EMER_USENAME EXTRICAT                     EXTRICATNAME
#> 1     <NA>                <NA>        0 Not Extricated or Not Applicable
#> 2        0      Not Applicable        0 Not Extricated or Not Applicable
#> 3        0      Not Applicable        0 Not Extricated or Not Applicable
#> 4     <NA>                <NA>        0 Not Extricated or Not Applicable
#> 5        9 Reported as Unknown        0 Not Extricated or Not Applicable
#>   FIRE_EXP       FIRE_EXPNAME FUNC_SYS             FUNC_SYSNAME GVWR_FROM
#> 1     <NA>               <NA>        1               Interstate      <NA>
#> 2        0 No or Not Reported        1               Interstate        11
#> 3        0 No or Not Reported        1               Interstate        11
#> 4     <NA>               <NA>        3 Other Principal Arterial      <NA>
#> 5        0 No or Not Reported        3 Other Principal Arterial        99
#>                                    GVWR_FROMNAME GVWR_TO
#> 1                                           <NA>    <NA>
#> 2 Class 1: 6,000 lbs. or less (2,722 kg or less)      11
#> 3 Class 1: 6,000 lbs. or less (2,722 kg or less)      11
#> 4                                           <NA>    <NA>
#> 5                            Reported as Unknown      99
#>                                      GVWR_TONAME HARM_EV          HARM_EVNAME
#> 1                                           <NA>      14 Parked Motor Vehicle
#> 2 Class 1: 6,000 lbs. or less (2,722 kg or less)      14 Parked Motor Vehicle
#> 3 Class 1: 6,000 lbs. or less (2,722 kg or less)      14 Parked Motor Vehicle
#> 4                                           <NA>       8           Pedestrian
#> 5                            Reported as Unknown       8           Pedestrian
#>   HELM_MIS                 HELM_MISNAME HELM_USE                 HELM_USENAME
#> 1        8 Not a Motor Vehicle Occupant       96 Not a Motor Vehicle Occupant
#> 2        7     None Used/Not Applicable       20               Not Applicable
#> 3        7     None Used/Not Applicable       20               Not Applicable
#> 4        8 Not a Motor Vehicle Occupant       96 Not a Motor Vehicle Occupant
#> 5        7     None Used/Not Applicable       20               Not Applicable
#>   HISPANIC                    HISPANICNAME HOSPITAL
#> 1        7                    Non-Hispanic        5
#> 2        0 Not A Fatality (not Applicable)        0
#> 3        0 Not A Fatality (not Applicable)        5
#> 4        4       Central or South American        0
#> 5        0 Not A Fatality (not Applicable)        0
#>                    HOSPITALNAME HOUR      HOURNAME ICFINALBODY ICFINALBODYNAME
#> 1                    EMS Ground    4 4:00am-4:59am        <NA>            <NA>
#> 2 Not Transported for Treatment    4 4:00am-4:59am           0  Not Applicable
#> 3                    EMS Ground    4 4:00am-4:59am           0  Not Applicable
#> 4 Not Transported for Treatment   20 8:00pm-8:59pm        <NA>            <NA>
#> 5 Not Transported for Treatment   20 8:00pm-8:59pm           0  Not Applicable
#>   IMPACT1    IMPACT1NAME IMPACT2 IMPACT2NAME INJ_SEV            INJ_SEVNAME
#> 1    <NA>           <NA>      NA          NA       4       Fatal Injury (K)
#> 2      12 12 Clock Point      NA          NA       0 No Apparent Injury (O)
#> 3       6  6 Clock Point      NA          NA       1    Possible Injury (C)
#> 4    <NA>           <NA>      NA          NA       4       Fatal Injury (K)
#> 5      98   Not Reported      NA          NA       9   Unknown/Not Reported
#>   LAG_HRS LAG_HRSNAME LAG_MINS LAG_MINSNAME LOCATION
#> 1       6           6       28           28       20
#> 2     999     Unknown       99      Unknown        0
#> 3     999     Unknown       99      Unknown        0
#> 4       0           0       20           20       11
#> 5     999     Unknown       99      Unknown        0
#>                                                LOCATIONNAME MAKE      MAKENAME
#> 1                                         Shoulder/Roadside <NA>          <NA>
#> 2                               Occupant of a Motor Vehicle   35 Nissan/Datsun
#> 3                               Occupant of a Motor Vehicle    6      Chrysler
#> 4 Not at Intersection - On Roadway, Not in Marked Crosswalk <NA>          <NA>
#> 5                               Occupant of a Motor Vehicle   99  Unknown Make
#>   MAK_MOD
#> 1    <NA>
#> 2   35047
#> 3    6051
#> 4    <NA>
#> 5   99999
#>                                                                    MAK_MODNAME
#> 1                                                                         <NA>
#> 2                                                         Nissan/Datsun Altima
#> 3                                                  Chrysler 300M/300/300C/300S
#> 4                                                                         <NA>
#> 5 Unknown Make Unknown (as to automobile, motored cycle, light truck or truck)
#>   MAN_COLL
#> 1        0
#> 2        0
#> 3        0
#> 4        0
#> 5        0
#>                                                                    MAN_COLLNAME
#> 1 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 2 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 3 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 4 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 5 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#>   MINUTE MINUTENAME MOD_YEAR MOD_YEARNAME MONTH MONTHNAME N_MOT_NO PER_NO
#> 1     49         49     <NA>         <NA>     1   January       NA      1
#> 2     49         49     2014         2014     1   January       NA      1
#> 3     49         49     2016         2016     1   January       NA      1
#> 4     43         43     <NA>         <NA>     1   January       NA      1
#> 5     43         43     9999      Unknown     1   January       NA      1
#>   PER_TYP                                   PER_TYPNAME P_SF1 P_SF1NAME P_SF2
#> 1       5                                    Pedestrian    NA        NA    NA
#> 2       1        Driver of a Motor Vehicle In-Transport    NA        NA    NA
#> 3       3 Occupant of a Motor Vehicle Not In- Transport    NA        NA    NA
#> 4       5                                    Pedestrian    NA        NA    NA
#> 5       1        Driver of a Motor Vehicle In-Transport    NA        NA    NA
#>   P_SF2NAME P_SF3 P_SF3NAME RACE RACENAME REST_MIS                 REST_MISNAME
#> 1        NA    NA        NA   NA       NA        8 Not a Motor Vehicle Occupant
#> 2        NA    NA        NA   NA       NA        0      No Indication of Misuse
#> 3        NA    NA        NA   NA       NA        0      No Indication of Misuse
#> 4        NA    NA        NA   NA       NA        8 Not a Motor Vehicle Occupant
#> 5        NA    NA        NA   NA       NA        7     None Used/Not Applicable
#>   REST_USE                 REST_USENAME ROAD_FNC ROAD_FNCNAME ROLLOVER
#> 1       96 Not a Motor Vehicle Occupant       NA           NA     <NA>
#> 2        3   Shoulder and Lap Belt Used       NA           NA        0
#> 3        3   Shoulder and Lap Belt Used       NA           NA        0
#> 4       96 Not a Motor Vehicle Occupant       NA           NA     <NA>
#> 5       99          Reported as Unknown       NA           NA        0
#>   ROLLOVERNAME RUR_URB RUR_URBNAME SCH_BUS SCH_BUSNAME SEAT_POS
#> 1         <NA>       2       Urban       0          No        0
#> 2  No Rollover       2       Urban       0          No       11
#> 3  No Rollover       2       Urban       0          No       13
#> 4         <NA>       2       Urban       0          No        0
#> 5  No Rollover       2       Urban       0          No       11
#>                   SEAT_POSNAME SEX             SEXNAME SPEC_USE
#> 1 Not a Motor Vehicle Occupant   1                Male     <NA>
#> 2        Front Seat, Left Side   2              Female        0
#> 3       Front Seat, Right Side   8        Not Reported        0
#> 4 Not a Motor Vehicle Occupant   1                Male     <NA>
#> 5        Front Seat, Left Side   9 Reported as Unknown       99
#>           SPEC_USENAME STATE STATENAME STR_VEH                 STR_VEHNAME
#> 1                 <NA>    24  Maryland       1                          01
#> 2 No Special Use Noted    24  Maryland       0 Occupant of a Motor Vehicle
#> 3 No Special Use Noted    24  Maryland       0 Occupant of a Motor Vehicle
#> 4                 <NA>    24  Maryland       1                          01
#> 5  Reported as Unknown    24  Maryland       0 Occupant of a Motor Vehicle
#>   ST_CASE TOW_VEH TOW_VEHNAME VEH_NO VE_FORMS VPICBODYCLASS VPICBODYCLASSNAME
#> 1  240001    <NA>        <NA>      0        1          <NA>              <NA>
#> 2  240001       0 No Trailers      1        1            13      Sedan/Saloon
#> 3  240001       0 No Trailers      2        1            13      Sedan/Saloon
#> 4  240002    <NA>        <NA>      0        1          <NA>              <NA>
#> 5  240002       9     Unknown      1        1           999           Unknown
#>   VPICMAKE VPICMAKENAME VPICMODEL VPICMODELNAME WORK_INJ
#> 1     <NA>         <NA>      <NA>          <NA>        0
#> 2      478       Nissan      1904        Altima        8
#> 3      477     Chrysler      1878           300        8
#> 4     <NA>         <NA>      <NA>          <NA>        0
#> 5    99999      Unknown     99999       Unknown        8
#>                      WORK_INJNAME
#> 1                              No
#> 2 Not Applicable (not a fatality)
#> 3 Not Applicable (not a fatality)
#> 4                              No
#> 5 Not Applicable (not a fatality)
```
