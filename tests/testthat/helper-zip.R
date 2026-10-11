# Create a minimal FARS-style zip file at `zipfile` so zip functions can be
# tested without downloading data. If `nested = TRUE`, the CSV file is placed
# in a folder within the zip file like the files for more recent years.
make_fars_zip <- function(
  zipfile,
  nested = FALSE,
  data = data.frame(ST_CASE = 1, LATITUDE = 39.3, LONGITUD = -76.6)
) {
  testthat::skip_if(Sys.which("zip") == "", "zip utility not available")
  src <- withr::local_tempdir()
  csv <- "ACCIDENT.CSV"

  if (nested) {
    csv <- file.path(sub("[.]zip$", "", basename(zipfile)), "accident.csv")
    dir.create(file.path(src, dirname(csv)))
  }

  utils::write.csv(data, file.path(src, csv), row.names = FALSE)
  dir.create(dirname(zipfile), recursive = TRUE, showWarnings = FALSE)
  withr::with_dir(src, utils::zip(zipfile, csv, flags = "-q"))
  zipfile
}

# Create a zip file in the cache folder used by get_fars_zip() for `path`
local_fars_zip <- function(
  path,
  year = 2024,
  scope = "National",
  nested = FALSE
) {
  filename <- paste0("FARS", year, scope, "CSV.zip")
  make_fars_zip(
    file.path(path, "FARS", year, sub("[.]zip$", "", filename), filename),
    nested = nested
  )
}

# Create a CRSS zip file (without coordinates) in the cache folder used by
# get_crss_zip() for `path`
local_crss_zip <- function(path, year = 2024, aux = FALSE, nested = TRUE) {
  filename <- paste0("CRSS", year, if (aux) "Auxiliary", "CSV.zip")
  make_fars_zip(
    file.path(path, "CRSS", year, sub("[.]zip$", "", filename), filename),
    nested = nested,
    data = data.frame(CASENUM = 1, REGION = 3, WEIGHT = 150.5)
  )
}
