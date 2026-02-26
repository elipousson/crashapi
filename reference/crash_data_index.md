# U.S. vehicular crash data index (city, county, regional, and state)

This index include identified data from cities, counties, or regional
entities in 43 of 50 U.S. states. Statewide data sources are included
from 33 states. In 4 states (NE, OH, ME, and CT), the only identified
statewide data sources allow limited access through a web-based public
query form. In 1 state (MN), data only available through restricted
access mapping/query tool. Not all statewide data sources include all
crashes (some include only cyclist/pedestrian crashes or fatal crashes)
and the structure and format of the crash data provided varies
considerably.

## Usage

``` r
crash_data_index
```

## Format

A data frame with 75 rows and 22 variables:

- `name`:

  Name of data set from provider.

- `level`:

  Geographic scope/level (e.g. city, county, region, state, national)

- `city`:

  City name

- `county`:

  County name

- `region`:

  logical COLUMN_DESCRIPTION

- `state_name`:

  U.S. state name

- `state_abb`:

  U.S. state abbreviation

- `info_url`:

  Informational URL (e.g. informational page about file download
  options)

- `data_url`:

  Data URL (e.g. direct link to ArcGIS FeatureServer layer)

- `format`:

  Data format (e.g. Socrata, CKAN, ArcGIS MapServer, etc.)

- `statewide_yn`:

  Yes for data with statewide geographic scope; NA for data from city,
  county, or regional level providers

- `batch_download_yn`:

  Yes for data where batch download is possible

- `start_year`:

  Earliest year for crashes in dataset

- `end_year`:

  Latest year for crashes in dataset

- `publisher`:

  Agency/organization responsible for publishing the data online

- `description`:

  Description of the dataset from provider

- `bike_ped_only`:

  Yes for data that only includes bike/ped involved crashes (common for
  Vision Zero programs)

- `rolling_window`:

  Description of rolling time window if data is only available within a
  rolling window

- `fatal_severe_only`:

  Yes for data that only includes fatal/severe crashes (common for
  Vision Zero programs)

- `date_note`:

  Note on the dates for the crash data

- `updates`:

  Information on update schedule if available

- `note`:

  General notes

## Details

This index was compiled by Eli Pousson between October 2021 and February
2022 with additional contributions from Mae Hanzlik.

Added: March 27 2022 Updated: June 05 2022

Corrections, updates, or additional sources should be added to this
public Google Sheet:
<https://docs.google.com/spreadsheets/d/1rmn6GbHNkfWLLDEEmA87iuy2yHdh7hBybCTZiQJEY0k/edit?usp=sharing>
