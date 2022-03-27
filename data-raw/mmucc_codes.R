
library(dplyr)
library(purrr)
library(stringr)
library(xml2)
library(rvest)

mmucc_url <-
  "https://release.niem.gov/niem/codes/mmucc/4.1/mmucc.xsd"

x <- read_html(mmucc_url)
# xml_structure(x)

simpletypes <-
  x |>
  xml_find_all(xpath = "//simpletype")

simpletypes_df <-
  tibble(
    "name" = simpletypes |>
      xml_attr("name") |>
      as_tibble(),
    "type" = "simpletype",
    "documentation" = simpletypes |>
      xml_find_all("annotation//documentation") |>
      xml_text()
  )

# simpletypes
get_restriction <-
  function(x) {
    select <-
      simpletypes |>
      xml_find_all("restriction") |>
      xml_child(x)

    text <- select |>
      xml_text()

    parent <- select |>
      xml_parent() |>
      xml_parent()

    name <- parent |>
      xml_attr("name")

    definition <- parent |>
      xml_child() |>
      xml_text()

    tibble(
      "id" = x,
      "name" = name,
      "definition" = definition,
      "restriction" = text
    )

  }

restrictions <-
  map_dfr(
    c(1:700),
    ~ get_restriction(.x)
  )

restrictions |>
  mutate(
    type = "simple",
    code = snakecase::to_title_case(str_remove(name, "SimpleType$"))
  ) |>
  select(
    code,
    name,
    type,
    definition,
    restriction_id = id,
    restriction
  ) |>
  write_csv("mmucc_codes.csv")

mmucc_codes <-
  readr::read_csv("inst/extdata/mmucc_codes.csv")

usethis::use_data(mmucc_codes, overwrite = TRUE)
