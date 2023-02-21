fars_terms <- readr::read_csv("inst/extdata/fars_terms.csv")

usethis::use_data(fars_terms, overwrite = TRUE)

fars_vars_labels <-
  googlesheets4::read_sheet(
    "https://docs.google.com/spreadsheets/d/1aqRsXKtumgt5umiVsDTC0ETQiNVFZdWaal9ttQZmSNw/edit?usp=sharing"
  )

fars_vars_labels <-
  fars_vars_labels |>
  dplyr::mutate(
    nm = janitor::make_clean_names(name),
    .after = dplyr::all_of("name")
  )

usethis::use_data(fars_vars_labels, overwrite = TRUE)
