## code to prepare `DATASET` dataset goes here

fars_terms <-
  readr::read_csv("inst/extdata/fars_terms.csv")

usethis::use_data(fars_terms, overwrite = TRUE)
