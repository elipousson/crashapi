
pkg_data <-
  utils::data(package = "crashapi", envir = .GlobalEnv)$results[, "Item"]

names(pkg_data) <-
  c("U.S. vehicular crash data index",
    "NHSTA Terms and Definitions",
    "FARS variable names and labels",
    "Model Minimum Uniform Crash Criteria (MMUCC) codes (simple)")

pkg_data_index <-
  tibble::enframe(
  pkg_data,
  value = "data"
)

pkg_data_index <-
  dplyr::bind_cols(
    pkg_data_index,
    "date_updated" = c("2022-06-05", "2021-10-25", "2022-03-27", "2022-03-26"),
    "date_added" = c( "2022-03-27", "2021-10-25", "2022-01-31", "2022-03-26")
  )

usethis::use_data(pkg_data_index, internal = TRUE, overwrite = TRUE)

crash_data_index <-
  googlesheets4::read_sheet("https://docs.google.com/spreadsheets/d/1rmn6GbHNkfWLLDEEmA87iuy2yHdh7hBybCTZiQJEY0k/edit#gid=0")

usethis::use_data(crash_data_index, overwrite = TRUE)

