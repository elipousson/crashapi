## code to prepare `DATASET` dataset goes here
fars_terms <-
 readr::read_csv("inst/extdata/fars_terms.csv")

usethis::use_data(fars_terms, overwrite = TRUE)

fars_vars_labels <-
  googlesheets4::read_sheet("https://docs.google.com/spreadsheets/d/1aqRsXKtumgt5umiVsDTC0ETQiNVFZdWaal9ttQZmSNw/edit?usp=sharing")

usethis::use_data(fars_vars_labels, overwrite = TRUE)
