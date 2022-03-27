#' @title NHSTA Terms and Defintions
#' @description FARS-related terms defined by the National Highway Traffic
#'   Safety Administration based on ANSI D16.1-1996: Manual on Classification of
#'   Motor Vehicle Traffic Accidents.
#' @format A data frame with 66 rows and 2 variables:
#' \describe{
#'   \item{\code{term}}{character Term}
#'   \item{\code{definition}}{character Term definition}
#' }
#' @source \href{https://www-fars.nhtsa.dot.gov/Help/Terms.aspx}{NHTSA FARS Terms}
"fars_terms"


#' @title FARS variable names and labels
#' @description A table of FARS table variable names extracted from the Fatality
#'   Analysis Reporting System (FARS) Analytical User's Manual, 1975-2019,
#'   documentation of the SAS format data files.
#' @format A data frame with 498 rows and 14 variables:
#' \describe{
#'   \item{\code{data_file}}{character SAS data file name}
#'   \item{\code{data_file_id}}{double SAS data file ID}
#'   \item{\code{file_id}}{character File ID}
#'   \item{\code{label}}{character Variable label}
#'   \item{\code{name}}{character Variable name}
#'   \item{\code{location}}{double Location in SAS data file}
#'   \item{\code{order}}{double Sort order}
#'   \item{\code{mmuc_equivalent}}{logical Equivalent term in MMUC (placeholder)}
#'   \item{\code{discontinued}}{logical Indicator for discontinued variables}
#'   \item{\code{key}}{logical Indicator for key variables}
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
