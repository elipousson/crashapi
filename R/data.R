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
