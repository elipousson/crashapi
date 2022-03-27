crash_data_index <-
  readr::read_csv("inst/extdata/crash_data_index.csv")

usethis::use_data(crash_data_index, overwrite = TRUE)
