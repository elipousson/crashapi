# Get variables and variable attributes for the Fatality Analysis Reporting System (FARS) API

By default, this function returns the returns the list of variables for
the data year specified. If `vars` is "make", "model", or "bodytype",
the function returns \#' list of variable attributes for the specified
variable name or attributes for make model and body type specified in
the FARS dataset.

## Usage

``` r
fars_vars(year, var = NULL, make = NULL, model = NULL)
```

## Arguments

- year:

  Case year. Year must be between 2010 and 2019.

- var:

  Default NULL. Supported values are "make", "model", and "bodytype".
  Using the var parameter returns variable attributes for the specified
  variable name or attributes for make model and body type specified in
  the dataset.

- make:

  Integer. Make ID number. Required to return variables for "model" and
  "bodytype". Get a list of make ID numbers using the "make" var for the
  selected year, e.g. `fars_vars(year = 2010, var = "make")`.

- model:

  Integer. Model ID number. Required to return variables for "bodytype".
  Get a list of model ID numbers using the "model" var for the selected
  year with a valid make ID number, e.g.
  `fars_vars(year = 2010, var = "model", make = 37)`

## Examples

``` r
head(fars_vars(year = 2022, var = "make"), 5)
#>   FROM_YEAR ID            TEXT TO_YEAR
#> 1      1994 54           Acura      NA
#> 2      1994 31      Alfa Romeo      NA
#> 3      1994  3      AM General      NA
#> 4      2010  1 American Motors      NA
#> 5      1994 32            Audi      NA

head(fars_vars(year = 2022, var = "model", make = 12), 5)
#>    ID
#> 1 441
#> 2  36
#> 3 401
#> 4 421
#> 5 981
#>                                                                                                                   MODELNAME
#> 1                                                                                                                  Aerostar
#> 2                                                                                                                    Aspire
#> 3 Bronco (thru 1977)/Bronco II/Explorer/Explorer Sport (Explorer for 1990-2018 only.  For model years 2019 on, see 12-425.)
#> 4                                                                                                 Bronco-fullsize (1978-on)
#> 5                                                                                    Bus**: Conventional (Engine out front)
#>   Make
#> 1   NA
#> 2   NA
#> 3   NA
#> 4   NA
#> 5   NA

fars_vars(year = 2022, var = "bodytype", make = 12, model = 37)
#>                                        BODY_DEF BODY_ID FROM_YEAR MAKE_DEF
#> 1                    2-door sedan,hardtop,coupe       2      1994     Ford
#> 2                       3-door/2-door hatchback       3      1994     Ford
#> 3                         4-door sedan, hardtop       4      1994     Ford
#> 4                       5-door/4-door hatchback       5      1994     Ford
#> 5 Station Wagon (excluding van and truck based)       6      1994     Ford
#> 6        Sedan/Hardtop, number of doors unknown       8      2017     Ford
#> 7              Other or Unknown automobile type       9      1994     Ford
#> 8                                  Not Reported      98      1994     Ford
#>   MAKE_ID MODEL_DEF MODEL_ID TO_YEAR
#> 1      12     Focus       37    <NA>
#> 2      12     Focus       37    <NA>
#> 3      12     Focus       37    <NA>
#> 4      12     Focus       37    <NA>
#> 5      12     Focus       37    <NA>
#> 6      12     Focus       37    <NA>
#> 7      12     Focus       37    <NA>
#> 8      12     Focus       37    2010
```
