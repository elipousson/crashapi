% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{fars_vars_labels}
\alias{fars_vars_labels}
\title{FARS variable names and labels}
\format{
A data frame with 498 rows and 14 variables:
\describe{
\item{\code{name}}{character Variable name}
\item{\code{label}}{character Variable label}
\item{\code{order}}{double Sort order}
\item{\code{data_file}}{character SAS data file name}
\item{\code{data_file_id}}{double SAS data file ID}
\item{\code{file_id}}{character File ID}
\item{\code{key}}{logical Indicator for key variables}
\item{\code{location}}{double Location in SAS data file}
\item{\code{mmuc_equivalent}}{logical Equivalent term in MMUC (placeholder)}
\item{\code{discontinued}}{logical Indicator for discontinued variables}
\item{\code{api_only}}{logical Indicator for variables only used by API}
\item{\code{api}}{character Name(s) of corresponding CrashAPI service}
\item{\code{name_var}}{logical Indicator for "NAME" variable returned by API}
\item{\code{nm}}{Short version of the variable name}
\item{\code{api_list_col}}{logical Indicator for list columns returned by API}
}
}
\usage{
fars_vars_labels
}
\description{
A table of FARS table variable names extracted from the Fatality
Analysis Reporting System (FARS) Analytical User's Manual, 1975-2019,
documentation of the SAS format data files.
}
\details{
Added: January 31 2022
Updated: March 27 2022
}
\keyword{datasets}
