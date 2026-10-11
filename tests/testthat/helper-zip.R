# Create a minimal FARS-style zip file in `path` so zip functions can be
# tested without downloading data. If `nested = TRUE`, the CSV file is placed
# in a folder within the zip file like the files for more recent years.
local_fars_zip <- function(
  path,
  year = 2024,
  scope = "National",
  nested = FALSE
) {
  filename <- paste0("FARS", year, scope, "CSV.zip")
  testthat::skip_if(Sys.which("zip") == "", "zip utility not available")
  src <- withr::local_tempdir()
  csv <- "ACCIDENT.CSV"

  if (nested) {
    csv <- file.path(sub("[.]zip$", "", filename), "accident.csv")
    dir.create(file.path(src, dirname(csv)))
  }

  utils::write.csv(
    data.frame(ST_CASE = 1, LATITUDE = 39.3, LONGITUD = -76.6),
    file.path(src, csv),
    row.names = FALSE
  )
  withr::with_dir(
    src,
    utils::zip(file.path(path, filename), csv, flags = "-q")
  )
  file.path(path, filename)
}
