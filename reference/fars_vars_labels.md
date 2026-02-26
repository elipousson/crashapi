# FARS variable names and labels

A table of FARS table variable names extracted from the Fatality
Analysis Reporting System (FARS) Analytical User's Manual, 1975-2019,
documentation of the SAS format data files.

## Usage

``` r
fars_vars_labels
```

## Format

A data frame with 498 rows and 14 variables:

- `name`:

  character Variable name

- `label`:

  character Variable label

- `order`:

  double Sort order

- `data_file`:

  character SAS data file name

- `data_file_id`:

  double SAS data file ID

- `file_id`:

  character File ID

- `key`:

  logical Indicator for key variables

- `location`:

  double Location in SAS data file

- `mmuc_equivalent`:

  logical Equivalent term in MMUC (placeholder)

- `discontinued`:

  logical Indicator for discontinued variables

- `api_only`:

  logical Indicator for variables only used by API

- `api`:

  character Name(s) of corresponding CrashAPI service

- `name_var`:

  logical Indicator for "NAME" variable returned by API

- `nm`:

  Short version of the variable name

- `api_list_col`:

  logical Indicator for list columns returned by API

## Details

Added: January 31 2022 Updated: March 27 2022
