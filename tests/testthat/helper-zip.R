# Create a minimal FARS-style zip file in `path` so zip functions can be
# tested without downloading data
local_fars_zip <- function(path, filename = "FARS2022NationalCSV.zip") {
  testthat::skip_if(Sys.which("zip") == "", "zip utility not available")
  src <- withr::local_tempdir()
  utils::write.csv(
    data.frame(ST_CASE = 1, LATITUDE = 39.3, LONGITUD = -76.6),
    file.path(src, "ACCIDENT.CSV"),
    row.names = FALSE
  )
  withr::with_dir(
    src,
    utils::zip(file.path(path, filename), "ACCIDENT.CSV", flags = "-q")
  )
  file.path(path, filename)
}
