fars_terms <- readr::read_csv("inst/extdata/fars_terms.csv")

usethis::use_data(fars_terms, overwrite = TRUE)

# Variable labels were originally compiled in a Google Sheet:
# https://docs.google.com/spreadsheets/d/1aqRsXKtumgt5umiVsDTC0ETQiNVFZdWaal9ttQZmSNw/edit?usp=sharing
# Edit data-raw/fars_vars_labels.csv instead. Column definitions are in
# data-raw/fars_vars_labels_definitions.csv.
fars_vars_labels <-
  readr::read_csv(
    "data-raw/fars_vars_labels.csv",
    col_types = readr::cols(
      name = readr::col_character(),
      label = readr::col_character(),
      order = readr::col_double(),
      data_file = readr::col_character(),
      data_file_id = readr::col_double(),
      file_id = readr::col_character(),
      key = readr::col_logical(),
      location = readr::col_double(),
      mmuc_equivalent = readr::col_logical(),
      discontinued = readr::col_logical(),
      api_only = readr::col_logical(),
      api = readr::col_character(),
      name_var = readr::col_logical(),
      api_list_col = readr::col_logical()
    )
  )

fars_vars_labels <-
  fars_vars_labels |>
  dplyr::mutate(
    nm = janitor::make_clean_names(name),
    .after = dplyr::all_of("name")
  )

usethis::use_data(fars_vars_labels, overwrite = TRUE)
