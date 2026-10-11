# Get Crashes By Occupant

This function returns a list of people involved in fatal crashes that
match a specific age, sex, seat position, and injury severity using the
CrashAPI GetCrashesByPerson endpoint. The returned data has one row for
each person.

## Usage

``` r
get_fars_crash_persons(
  state,
  age,
  sex,
  seat,
  injury,
  year = getOption("crashapi.year", 2024),
  labels = TRUE
)
```

## Arguments

- state:

  Required. State name, abbreviation, or FIPS number.

- age:

  Required. Age in years.

- sex:

  Required. Code or name for the person's sex: 1 ("Male"), 2 ("Female"),
  8 ("Not Reported"), or 9 ("Reported as Unknown"). "m", "f", and
  "unknown" are also accepted.

- seat:

  Required. Code or name for the person's seat position, e.g. 11 or
  "Front Seat, Left Side" ("front left" is also accepted). Use 0 or "Not
  a Motor Vehicle Occupant" for non-occupants. See the FARS Analytical
  User's Manual for all seat position codes.

- injury:

  Required. Code or name for the person's injury severity: 0 ("No
  Apparent Injury (O)"), 1 ("Possible Injury (C)"), 2 ("Suspected Minor
  Injury (B)"), 3 ("Suspected Serious Injury (A)"), 4 ("Fatal Injury
  (K)"), 5 ("Injured, Severity Unknown"), 6 ("Died Prior to Crash"), or
  9 ("Unknown/Not Reported"). Short names (e.g. "fatal") and KABCO
  letters (e.g. "K") are also accepted.

- year:

  numeric vector. One or more years from 2010 to 2024. The minimum and
  maximum values are used as the start and end year. Defaults to
  `getOption("crashapi.year", 2024)`.

- labels:

  If `TRUE` (default), add a `"label"` attribute to each column with a
  variable label from
  [fars_vars_labels](https://elipousson.github.io/crashapi/reference/fars_vars_labels.md).
  Labels are shown by [`View()`](https://rdrr.io/r/utils/View.html) in
  RStudio and Positron and used by packages such as gt and gtsummary.

## API behavior

NHTSA's documentation says this endpoint accepts "one or more" occupant
details for age, sex, seat position, and injury severity. However,
testing in October 2026 found that the API does not behave this way: the
API returns an error (HTTP 404) unless all four are provided, an error
message if any are blank, and only returns people who match all four
values exactly. For this reason, `age`, `sex`, `seat`, and `injury` are
all required.

The endpoint's `includeOccupants` and `includeNonOccupants` parameters
are not supported since the required seat position already determines
whether occupants or non-occupants are returned (use `seat = 0` for
people who were not motor vehicle occupants).

To find people using other criteria (e.g. a range of ages or any injury
severity), download the person table with
[`get_fars_year()`](https://elipousson.github.io/crashapi/reference/get_fars_crashes.md)
using `type = "person"` and filter the data.

## Examples

``` r
# Fatally injured 30 year old female drivers in Maryland in 2022
get_fars_crash_persons(
  state = "MD",
  age = 30,
  sex = "female",
  seat = "front left",
  injury = "fatal",
  year = 2022
)
#>   AGE  AGENAME AIR_BAG                    AIR_BAGNAME ALC_DET ALC_DETNAME
#> 1  30 30 Years      99 Reported as Deployment Unknown      NA          NA
#> 2  30 30 Years       8          Deployed- Combination      NA          NA
#>   ALC_RES                   ALC_RESNAME ALC_STATUS
#> 1     999 Reported as Unknown if Tested          9
#> 2       0                   0.000 % BAC          2
#>                  ALC_STATUSNAME ATST_TYP                  ATST_TYPNAME BODY_TYP
#> 1 Reported as Unknown if Tested       99 Reported as Unknown if Tested        4
#> 2                    Test Given        1                         Blood       14
#>                                                         BODY_TYPNAME CERT_NO
#> 1                                              4-door sedan, hardtop      NA
#> 2 Compact Utility (Utility Vehicle Categories "Small" and "Midsize")      NA
#>   COUNTY           COUNTYNAME CaseYear DAY DAYNAME DEATH_DA DEATH_DANAME
#> 1     33 PRINCE GEORGE`S (33)     2022  23      23       23           23
#> 2     43      WASHINGTON (43)     2022  18      18       18           18
#>   DEATH_HR DEATH_HRNAME DEATH_MN DEATH_MNNAME DEATH_MO DEATH_MONAME DEATH_TM
#> 1        7    7:00-7:59       23           23        1      January      723
#> 2       14  14:00-14:59        6            6        4        April     1406
#>   DEATH_TMNAME DEATH_YR DEATH_YRNAME DEVMOTOR DEVMOTORNAME DEVTYPE DEVTYPENAME
#> 1          723     2022         2022       NA           NA      NA          NA
#> 2         1406     2022         2022       NA           NA      NA          NA
#>   DOA        DOANAME DRINKING              DRINKINGNAME DRUGRES1 DRUGRES1NAME
#> 1   0 Not Applicable        8              Not Reported       NA           NA
#> 2   7  Died at Scene        0 No (Alcohol Not Involved)       NA           NA
#>   DRUGRES2 DRUGRES2NAME DRUGRES3 DRUGRES3NAME DRUGS               DRUGSNAME
#> 1       NA           NA       NA           NA     8            Not Reported
#> 2       NA           NA       NA           NA     0 No (drugs not involved)
#>   DRUGTST1 DRUGTST1NAME DRUGTST2 DRUGTST2NAME DRUGTST3 DRUGTST3NAME DRUG_DET
#> 1       NA           NA       NA           NA       NA           NA       NA
#> 2       NA           NA       NA           NA       NA           NA       NA
#>   DRUG_DETNAME DSTATUS                   DSTATUSNAME EJECTION EJECTIONNAME
#> 1           NA       9 Reported as Unknown if Tested        0  Not Ejected
#> 2           NA       2                    Test Given        0  Not Ejected
#>   EJ_PATH                  EJ_PATHNAME EMER_USE   EMER_USENAME EXTRICAT
#> 1       0 Ejection Path Not Applicable        0 Not Applicable        9
#> 2       0 Ejection Path Not Applicable        0 Not Applicable        9
#>   EXTRICATNAME FIRE_EXP       FIRE_EXPNAME FUNC_SYS               FUNC_SYSNAME
#> 1      Unknown        1                Yes        3 Principal Arterial - Other
#> 2      Unknown        0 No or Not Reported        1                 Interstate
#>   GVWR_FROM                                  GVWR_FROMNAME GVWR_TO
#> 1        11 Class 1: 6,000 lbs. or less (2,722 kg or less)      11
#> 2        11 Class 1: 6,000 lbs. or less (2,722 kg or less)      11
#>                                      GVWR_TONAME HARM_EV
#> 1 Class 1: 6,000 lbs. or less (2,722 kg or less)      59
#> 2 Class 1: 6,000 lbs. or less (2,722 kg or less)      12
#>                  HARM_EVNAME HELM_MIS             HELM_MISNAME HELM_USE
#> 1       Traffic Sign Support        7 None Used/Not Applicable       20
#> 2 Motor Vehicle In-Transport        7 None Used/Not Applicable       20
#>     HELM_USENAME HISPANIC HISPANICNAME HOSPITAL                  HOSPITALNAME
#> 1 Not Applicable        7 Non-Hispanic        8                  Not Reported
#> 2 Not Applicable        7 Non-Hispanic        0 Not Transported for Treatment
#>   HOUR      HOURNAME ICFINALBODY ICFINALBODYNAME IMPACT1    IMPACT1NAME IMPACT2
#> 1    7 7:00am-7:59am           0  Not Applicable      11 11 Clock Point      NA
#> 2   13 1:00pm-1:59pm           0  Not Applicable       6  6 Clock Point      NA
#>   IMPACT2NAME INJ_SEV      INJ_SEVNAME LAG_HRS LAG_HRSNAME LAG_MINS
#> 1          NA       4 Fatal Injury (K)       0           0       19
#> 2          NA       4 Fatal Injury (K)       0           0       17
#>   LAG_MINSNAME LOCATION                LOCATIONNAME MAKE MAKENAME MAK_MOD
#> 1           19        0 Occupant of a Motor Vehicle   12     Ford   12023
#> 2           17        0 Occupant of a Motor Vehicle   41    Mazda   41403
#>   MAK_MODNAME MAN_COLL
#> 1 Ford Fusion        0
#> 2   Mazda CX5        1
#>                                                                    MAN_COLLNAME
#> 1 The First Harmful Event was Not a Collision with a Motor Vehicle in Transport
#> 2                                                                 Front-to-Rear
#>   MINUTE MINUTENAME MOD_YEAR MOD_YEARNAME MONTH MonthName N_MOT_NO OCCDrugs
#> 1      4          4     2017         2017     1   January       NA       NA
#> 2     49         49     2020         2020     4     April       NA       NA
#>   PER_NO PER_TYP                            PER_TYPNAME P_SF1 P_SF1NAME P_SF2
#> 1      1       1 Driver of a Motor Vehicle In-Transport    NA        NA    NA
#> 2      1       1 Driver of a Motor Vehicle In-Transport    NA        NA    NA
#>   P_SF2NAME P_SF3 P_SF3NAME PersonRFs RACE RACENAME REST_MIS
#> 1        NA    NA        NA        NA   NA       NA        7
#> 2        NA    NA        NA        NA   NA       NA        0
#>               REST_MISNAME REST_USE               REST_USENAME ROAD_FNC
#> 1 None Used/Not Applicable       20   None Used/Not Applicable       NA
#> 2  No Indication of Misuse        3 Shoulder and Lap Belt Used       NA
#>   ROAD_FNCNAME ROLLOVER ROLLOVERNAME RUR_URB RUR_URBNAME Races SCH_BUS
#> 1           NA        0  No Rollover       2       Urban    NA       0
#> 2           NA        0  No Rollover       2       Urban    NA       0
#>   SCH_BUSNAME SEAT_POS          SEAT_POSNAME SEX SEXNAME SPEC_USE
#> 1          No       11 Front Seat, Left Side   2  Female        0
#> 2          No       11 Front Seat, Left Side   2  Female        0
#>           SPEC_USENAME STATE STATENAME STR_VEH                 STR_VEHNAME
#> 1 No Special Use Noted    24  Maryland       0 Occupant of a Motor Vehicle
#> 2 No Special Use Noted    24  Maryland       0 Occupant of a Motor Vehicle
#>   ST_CASE TOW_VEH TOW_VEHNAME VEH_NO VE_FORMS VPICBODYCLASS
#> 1  240026       0 No Trailers      1        1            13
#> 2  240122       0 No Trailers      3        4             7
#>                                         VPICBODYCLASSNAME VPICMAKE VPICMAKENAME
#> 1                                            Sedan/Saloon      460         Ford
#> 2 Sport Utility Vehicle (SUV)/Multi-Purpose Vehicle (MPV)      473        Mazda
#>   VPICMODEL VPICMODELNAME WORK_INJ WORK_INJNAME
#> 1      1780        Fusion        0           No
#> 2      2369          CX-5        0           No
```
