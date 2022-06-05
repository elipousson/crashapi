#' NHSTA Terms and Definitions
#'
#' FARS-related terms defined by the National Highway Traffic
#'   Safety Administration based on ANSI D16.1-1996: Manual on Classification of
#'   Motor Vehicle Traffic Accidents.
#'
#' `r pkg_data_date("fars_terms", "added")`
#' `r pkg_data_date("fars_terms", "updated")`
#'
#' @format A data frame with 66 rows and 2 variables:
#' \describe{
#'   \item{\code{term}}{character Term}
#'   \item{\code{definition}}{character Term definition}
#' }
#' @source \href{https://www-fars.nhtsa.dot.gov/Help/Terms.aspx}{NHTSA FARS Terms}
"fars_terms"


#' FARS variable names and labels
#'
#' A table of FARS table variable names extracted from the Fatality
#'   Analysis Reporting System (FARS) Analytical User's Manual, 1975-2019,
#'   documentation of the SAS format data files.
#'
#' `r pkg_data_date("fars_vars_labels", "added")`
#' `r pkg_data_date("fars_vars_labels", "updated")`
#'
#' @format A data frame with 498 rows and 14 variables:
#' \describe{
#'   \item{\code{name}}{character Variable name}
#'   \item{\code{label}}{character Variable label}
#'   \item{\code{order}}{double Sort order}
#'   \item{\code{data_file}}{character SAS data file name}
#'   \item{\code{data_file_id}}{double SAS data file ID}
#'   \item{\code{file_id}}{character File ID}
#'   \item{\code{key}}{logical Indicator for key variables}
#'   \item{\code{location}}{double Location in SAS data file}
#'   \item{\code{mmuc_equivalent}}{logical Equivalent term in MMUC (placeholder)}
#'   \item{\code{discontinued}}{logical Indicator for discontinued variables}
#'   \item{\code{api_only}}{logical Indicator for variables only used by API}
#'   \item{\code{api}}{character Name(s) of corresponding CrashAPI service}
#'   \item{\code{name_var}}{logical Indicator for "NAME" variable returned by API}
#'   \item{\code{api_list_col}}{logical Indicator for list columns returned by API}
#' }
"fars_vars_labels"


#' @title Model Minimum Uniform Crash Criteria (MMUCC) codes (simple)
#'
#' @description
#'
#' A collection of the 73 unique codes identified as simple codes:
#' <https://release.niem.gov/niem/codes/mmucc/4.1/mmucc.xsd>
#'
#' See the MMUCC Guideline Fifth Edition (2017) for more information:
#' <https://crashstats.nhtsa.dot.gov/Api/Public/Publication/812433>
#'
#' About MMUC from NHTSA: <https://www.nhtsa.gov/mmucc-1>
#'
#' To encourage greater uniformity, the National Highway Traffic Safety
#' Administration (NHTSA) and the Governors Highway Safety Association (GHSA)
#' cooperatively developed a voluntary data collection guideline in 1998. The
#' MMUCC guideline identifies a minimum set of motor vehicle crash data elements
#' and their attributes that States should consider collecting and including in
#' their State crash data system.
#'
#' The MMUCC 5th Edition is the result of an 18-month collaboration between
#' NHTSA, the Federal Highway Administration (FHWA), the Federal Motor Carrier
#' Safety Administration (FMCSA), the National Transportation Safety Board
#' (NTSB), the GHSA, and subject matter experts from State DOTs, local law
#' enforcement, emergency medical services, safety organizations, industry
#' partners, and academia. The traffic records community and general public also
#' contributed through external forums (Federal Register) and at the 2016
#' Traffic Records Forum.
#'
#' - `r pkg_data_date("mmucc_codes", "added")`
#' - `r pkg_data_date("mmucc_codes", "updated")`
#'
#' @format A data frame with 700 rows and 6 variables:
#' \describe{
#'   \item{\code{code}}{Attribute code}
#'   \item{\code{name}}{Attribute code name}
#'   \item{\code{type}}{Attribute code type}
#'   \item{\code{definition}}{Code definition}
#'   \item{\code{restriction_id}}{Restriction id number}
#'   \item{\code{restriction}}{Restriction value}
#' }
"mmucc_codes"


#' U.S. vehicular crash data index (city, county, regional, and state)
#'
#' This index  include identified data from cities, counties, or regional
#' entities in 43 of 50 U.S. states. Statewide data sources are included from 33
#' states. In 4 states (NE, OH, ME, and CT), the only identified statewide data
#' sources allow limited access through a web-based public query form. In 1
#' state (MN), data only available through restricted access mapping/query tool.
#' Not all statewide data sources include all crashes (some include only
#' cyclist/pedestrian crashes or fatal crashes) and the structure and format of
#' the crash data provided varies considerably.
#'
#' This index was compiled by Eli Pousson between October 2021 and February
#' 2022 with additional contributions from Mae Hanzlik.
#'
#' `r pkg_data_date("crash_data_index", "added")`
#' `r pkg_data_date("crash_data_index", "updated")`
#'
#' Corrections, updates, or additional sources should be added to this public
#' Google Sheet:
#' <https://docs.google.com/spreadsheets/d/1rmn6GbHNkfWLLDEEmA87iuy2yHdh7hBybCTZiQJEY0k/edit?usp=sharing>
#'
#' @format A data frame with 75 rows and 22 variables:
#' \describe{
#'   \item{\code{name}}{Name of data set from provider.}
#'   \item{\code{level}}{Geographic scope/level (e.g. city, county, region, state, national)}
#'   \item{\code{city}}{City name}
#'   \item{\code{county}}{County name}
#'   \item{\code{region}}{logical COLUMN_DESCRIPTION}
#'   \item{\code{state_name}}{U.S. state name}
#'   \item{\code{state_abb}}{U.S. state abbreviation}
#'   \item{\code{info_url}}{Informational URL (e.g. informational page about file download options)}
#'   \item{\code{data_url}}{Data URL (e.g. direct link to ArcGIS FeatureServer layer)}
#'   \item{\code{format}}{Data format (e.g. Socrata, CKAN, ArcGIS MapServer, etc.)}
#'   \item{\code{statewide_yn}}{Yes for data with statewide geographic scope; NA for data from city, county, or regional level providers}
#'   \item{\code{batch_download_yn}}{Yes for data where batch download is possible}
#'   \item{\code{start_year}}{Earliest year for crashes in dataset}
#'   \item{\code{end_year}}{Latest year for crashes in dataset}
#'   \item{\code{publisher}}{Agency/organization responsible for publishing the data online}
#'   \item{\code{description}}{Description of the dataset from provider}
#'   \item{\code{bike_ped_only}}{Yes for data that only includes bike/ped involved crashes (common for Vision Zero programs)}
#'   \item{\code{rolling_window}}{Description of rolling time window if data is only available within a rolling window}
#'   \item{\code{fatal_severe_only}}{Yes for data that only includes fatal/severe crashes (common for Vision Zero programs)}
#'   \item{\code{date_note}}{Note on the dates for the crash data}
#'   \item{\code{updates}}{Information on update schedule if available}
#'   \item{\code{note}}{General notes}
#' }
"crash_data_index"
