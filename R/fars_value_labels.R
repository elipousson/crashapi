#' Get value labels for FARS and CRSS variables
#'
#' `fars_value_labels()` returns the value labels (the decoded value for each
#' code) for variables in the FARS or CRSS data files by year. The value labels
#' are built from the SAS format programs and data files that NHTSA publishes
#' with the zipped SAS data for each year (see `data-raw/fars_value_labels.R`).
#'
#' Value labels change over time, so the same code can have a different label
#' in different years. For example, the `INJ_SEV` code 3 is labelled
#' "Incapacitating" in early FARS data and "Suspected Serious Injury (A)" in
#' recent years.
#'
#' The CrashAPI and FARS zipped CSV files from 2015 onwards include `…NAME`
#' columns with decoded values. Use [decode_fars()] to add these columns to
#' older FARS data or CRSS data.
#'
#' Labels from the SAS formats can differ slightly in wording from the `…NAME`
#' columns in the CSV files (e.g. "Curve - Right" instead of "Curve Right"
#' for `VALIGN`). A few variables use SAS formats that NHTSA doesn't publish
#' (e.g. a state variable in some 2006-2015 tables) and are not included.
#' Value labels for the FARS vPIC variables (e.g. `VPICMAKE` and `VPICMODEL`,
#' used from 2020 onwards) are not included since FARS data already includes
#' `…NAME` columns for these variables; they are included for CRSS data.
#'
#' @param year One or more years. If `NULL` (default), returns value labels for
#'   all years.
#' @param table One or more FARS or CRSS data table names (e.g. "accident",
#'   "person", or "vehicle"). Not case sensitive. If `NULL` (default), returns
#'   value labels for all tables.
#' @param variable One or more variable names (e.g. "INJ_SEV"). Not case
#'   sensitive. If `NULL` (default), returns value labels for all variables.
#' @param source Data source: "FARS" (default) or "CRSS".
#' @returns A data frame with columns `source`, `year`, `table`, `variable`,
#'   `format` (the SAS format name, without the year), `code` (as written in the SAS format, e.g.
#'   "01"), `code_min` and `code_max` (numeric codes or ranges), and `value`
#'   (the label).
#' @examples
#' # Injury severity labels for the person table in 1985 and 2024
#' fars_value_labels(
#'   year = c(1985, 2024),
#'   table = "person",
#'   variable = "INJ_SEV"
#' )
#' @export
fars_value_labels <- function(
  year = NULL,
  table = NULL,
  variable = NULL,
  source = c("FARS", "CRSS")
) {
  source <- match.arg(source)
  vars <- read_value_label_file("fars_variables.parquet")
  vars <- vars[vars[["source"]] == source & !is.na(vars[["format"]]), ]

  if (!is.null(year)) {
    vars <- vars[vars[["year"]] %in% as.integer(year), ]
  }

  if (!is.null(table)) {
    vars <- vars[vars[["table"]] %in% tolower(table), ]
  }

  if (!is.null(variable)) {
    vars <- vars[toupper(vars[["variable"]]) %in% toupper(variable), ]
  }

  # Value labels are stored once for consecutive years with the same labels
  formats <- read_value_label_file("fars_formats.parquet")
  formats <- formats[
    formats[["source"]] == source &
      formats[["format"]] %in% unique(vars[["format"]]) &
      formats[["last_year"]] >= min(vars[["year"]], Inf) &
      formats[["first_year"]] <= max(vars[["year"]], -Inf),
  ]

  value_labels <- merge(
    vars,
    formats,
    by = c("source", "format"),
    sort = FALSE
  )

  value_labels <- value_labels[
    value_labels[["year"]] >= value_labels[["first_year"]] &
      value_labels[["year"]] <= value_labels[["last_year"]],
  ]

  value_labels <- value_labels[
    order(
      value_labels[["year"]],
      value_labels[["table"]],
      value_labels[["variable"]],
      value_labels[["code_min"]]
    ),
    c(
      "source",
      "year",
      "table",
      "variable",
      "format",
      "code",
      "code_min",
      "code_max",
      "value"
    )
  ]

  rownames(value_labels) <- NULL
  value_labels
}

#' Get variable labels for FARS and CRSS variables
#'
#' `fars_variables()` returns the variables in each FARS or CRSS data table by
#' year with the variable label and SAS format name from the SAS data files
#' that NHTSA publishes with the zipped SAS data for each year (see
#' `data-raw/fars_value_labels.R`). Variable labels can change over time and
#' include variables that are not in [fars_vars_labels] (e.g. variables added
#' in recent years or only used in CRSS).
#'
#' @inheritParams fars_value_labels
#' @returns A data frame with columns `source`, `year`, `table`, `variable`,
#'   `label` (the variable label), and `format` (the SAS format name without
#'   the year, or `NA` for variables without value labels).
#' @examples
#' fars_variables(year = 2024, table = "person", variable = c("AGE", "INJ_SEV"))
#' @export
fars_variables <- function(
  year = NULL,
  table = NULL,
  variable = NULL,
  source = c("FARS", "CRSS")
) {
  source <- match.arg(source)
  vars <- read_value_label_file("fars_variables.parquet")
  vars <- vars[vars[["source"]] == source, ]

  if (!is.null(year)) {
    vars <- vars[vars[["year"]] %in% as.integer(year), ]
  }

  if (!is.null(table)) {
    vars <- vars[vars[["table"]] %in% tolower(table), ]
  }

  if (!is.null(variable)) {
    vars <- vars[toupper(vars[["variable"]]) %in% toupper(variable), ]
  }

  vars <- vars[order(vars[["year"]], vars[["table"]]), ]
  rownames(vars) <- NULL
  as.data.frame(vars)
}

#' Add decoded value columns to FARS or CRSS data
#'
#' `decode_fars()` adds a column with decoded values (e.g. `INJ_SEVNAME` for
#' `INJ_SEV`) after each coded variable in a FARS or CRSS data table, using the
#' value labels from [fars_value_labels()] for the year of each row. Variables
#' that already have a decoded column (like the `…NAME` columns in data from
#' the CrashAPI or FARS zipped CSV files from 2015 onwards) are not changed
#' unless `overwrite = TRUE`.
#'
#' [get_fars()] uses `decode_fars()` to add decoded columns to data from zipped
#' FARS data files before 2015.
#'
#' @param x A data frame with a FARS or CRSS data table, e.g. from
#'   [get_fars()], [get_fars_zip()], or [get_crss_zip()].
#' @param table Name of the FARS or CRSS data table (e.g. "accident", "person",
#'   or "vehicle").
#' @param year Year of the data. If `NULL` (default), uses the `CASEYEAR`,
#'   `CaseYear`, or `YEAR` column of `x`. Can be a single year or one year for
#'   each row of `x`.
#' @param decode How to decode values:
#'   - "names" (default) adds a column with decoded values after each coded
#'   variable (e.g. `INJ_SEVNAME` for `INJ_SEV`), matching the `…NAME` columns
#'   in data from the CrashAPI and FARS zipped CSV files from 2015 onwards.
#'   - "replace" replaces the codes with a factor of decoded values (with levels
#'   in code order) and removes any existing `…NAME` column. Variables with
#'   values that don't have value labels (e.g. `AGE`, where only special codes
#'   like "Not Reported" have labels) are not replaced.
#'   - "labelled" keeps the codes and adds value labels with
#'   [haven::labelled()]. A labelled vector has a single set of value labels so
#'   the value labels from the latest year in the data are used (with a warning
#'   if the value labels differ between years). Requires the haven package.
#' @param suffix Suffix for the names of the decoded columns if `decode =
#'   "names"`. Default: "NAME".
#' @param overwrite If `TRUE` and `decode = "names"`, replace existing decoded
#'   columns. Default: `FALSE`.
#' @inheritParams fars_value_labels
#' @returns `x` with additional columns of decoded values (`decode =
#'   "names"`), factors of decoded values (`decode = "replace"`), or labelled
#'   vectors (`decode = "labelled"`).
#' @examples
#' person <- data.frame(CASEYEAR = c(1985, 2024), INJ_SEV = c(3, 3))
#' decode_fars(person, table = "person")
#'
#' decode_fars(person, table = "person", decode = "replace")
#' @export
decode_fars <- function(
  x,
  table,
  year = NULL,
  decode = c("names", "replace", "labelled"),
  source = c("FARS", "CRSS"),
  suffix = "NAME",
  overwrite = FALSE
) {
  decode <- rlang::arg_match(decode)
  source <- match.arg(source)

  if (decode == "labelled") {
    rlang::check_installed("haven", reason = "to use `decode = \"labelled\"`.")
  }

  if (is.null(year)) {
    year_col <- c(fars_year_col(x), intersect("YEAR", names(x)))[1]

    if (is.na(year_col)) {
      cli_abort(
        "{.arg year} must be provided if {.arg x} doesn't have a
        {.field CASEYEAR}, {.field CaseYear}, or {.field YEAR} column."
      )
    }

    year <- x[[year_col]]
  }

  year <- as.integer(year)

  if (!(length(year) %in% c(1, nrow(x)))) {
    cli_abort(
      "{.arg year} must be a single year or one year for each row of {.arg x}."
    )
  }

  year <- rep_len(year, nrow(x))
  value_labels <- fars_value_labels(
    year = unique(year),
    table = table,
    source = source
  )

  # Match variable names case-insensitively since the case of some variable
  # names varies between years and file formats (e.g. vPICMAKE and VPICMAKE)
  variables <- names(x)[
    toupper(names(x)) %in% toupper(value_labels[["variable"]])
  ]

  not_replaced <- character(0)
  labels_differ <- character(0)

  for (variable in variables) {
    variable_labels <- value_labels[
      toupper(value_labels[["variable"]]) == toupper(variable),
    ]
    name_col <- paste0(variable, suffix)

    if (decode == "names") {
      if (rlang::has_name(x, name_col) && !isTRUE(overwrite)) {
        next
      }

      x[[name_col]] <- decode_values(x[[variable]], year, variable_labels)
      x <- dplyr::relocate(
        x,
        dplyr::all_of(name_col),
        .after = dplyr::all_of(variable)
      )
    }

    if (decode == "replace") {
      decoded <- decode_values(x[[variable]], year, variable_labels)

      # Only replace values for categorical variables where every value can be
      # decoded (e.g. not AGE where labels are like "30 Years" or only special
      # codes like "Not Reported" have labels)
      if (
        is_measure_labels(variable_labels) ||
          any(is.na(decoded) & !is.na(x[[variable]]))
      ) {
        not_replaced <- c(not_replaced, variable)
        next
      }

      x[[variable]] <- factor(decoded, levels = label_levels(variable_labels))
      x[[name_col]] <- NULL
    }

    if (decode == "labelled") {
      # Only label special codes without numbers (e.g. "Not Reported") for
      # measures like AGE
      if (is_measure_labels(variable_labels)) {
        variable_labels <- variable_labels[
          !grepl("[0-9]", variable_labels[["value"]]),
        ]
      }

      labelled <- labelled_values(x[[variable]], variable_labels)

      if (is.null(labelled)) {
        next
      }

      if (isTRUE(attr(labelled, "labels_differ"))) {
        labels_differ <- c(labels_differ, variable)
        attr(labelled, "labels_differ") <- NULL
      }

      x[[variable]] <- labelled
    }
  }

  if (length(not_replaced) > 0) {
    cli::cli_inform(
      c(
        "i" = "{.val {not_replaced}} {?wasn't/weren't} replaced since
        {?it is a measure or has/they are measures or have} values without
        value labels."
      )
    )
  }

  if (length(labels_differ) > 0) {
    cli::cli_warn(
      c(
        "Value labels for {.val {labels_differ}} differ between
        {min(year)} and {max(year)}.",
        "i" = "Using value labels from {max(year)}."
      )
    )
  }

  x
}

#' Is the first number in a value label equal to its code (e.g. "30 Years" for
#' 30 or "001 MPH" for 1)?
#' @noRd
is_code_label <- function(code, value) {
  first_number <- suppressWarnings(
    as.numeric(regmatches(value, regexpr("[0-9]+([.][0-9]+)?", value)))
  )
  matched <- rep(FALSE, length(value))
  has_number <- grepl("[0-9]", value)
  matched[has_number] <- !is.na(code[has_number]) &
    first_number == code[has_number]
  matched
}

#' Are value labels for a measure (e.g. AGE or MOD_YEAR) where most labels
#' include their code?
#' @noRd
is_measure_labels <- function(value_labels) {
  codes <- value_labels[!is.na(value_labels[["code_min"]]), ]
  nrow(codes) > 0 &&
    mean(is_code_label(codes[["code_min"]], codes[["value"]])) > 0.5
}

#' Get factor levels from value labels in code order
#' @noRd
label_levels <- function(value_labels) {
  value_labels <- value_labels[
    order(value_labels[["code_min"]], -value_labels[["year"]]),
  ]
  unique(value_labels[["value"]])
}

#' Create a haven_labelled vector using value labels from the latest year
#'
#' Ranges can't be used as labelled values so only single codes are used.
#' Returns NULL if no codes can be used as labels for x.
#' @noRd
labelled_values <- function(x, value_labels) {
  is_numeric <- is.numeric(x)
  single <- value_labels[
    is.na(value_labels[["code_min"]]) |
      value_labels[["code_min"]] == value_labels[["code_max"]],
  ]

  if (is_numeric) {
    single <- single[!is.na(single[["code_min"]]), ]
  }

  if (nrow(single) == 0) {
    return(NULL)
  }

  # Check if any code has a different label in another year
  codes <- if (is_numeric) single[["code_min"]] else single[["code"]]
  labels_differ <- any(tapply(single[["value"]], codes, function(v) {
    length(unique(v)) > 1
  }))

  latest <- single[single[["year"]] == max(single[["year"]]), ]
  latest_codes <- if (is_numeric) latest[["code_min"]] else latest[["code"]]
  latest <- latest[!duplicated(latest_codes), ]
  latest_codes <- latest_codes[!duplicated(latest_codes)]

  labels <- tryCatch(
    vctrs::vec_cast(latest_codes, x[0]),
    error = function(e) NULL
  )

  if (is.null(labels)) {
    return(NULL)
  }

  labelled <- haven::labelled(
    vctrs::vec_data(x),
    labels = rlang::set_names(labels, latest[["value"]]),
    label = attr(x, "label", exact = TRUE)
  )

  attr(labelled, "labels_differ") <- labels_differ
  labelled
}

#' Match values to value labels by year using numeric codes, ranges, or
#' character codes
#' @noRd
decode_values <- function(values, year, value_labels) {
  decoded <- rep(NA_character_, length(values))
  values <- fix_latin1(values)
  values_num <- suppressWarnings(as.numeric(values))

  # Numeric codes
  exact <- value_labels[
    !is.na(value_labels[["code_min"]]) &
      value_labels[["code_min"]] == value_labels[["code_max"]],
  ]
  i <- match(
    paste(year, values_num),
    paste(exact[["year"]], exact[["code_min"]])
  )
  decoded[!is.na(i)] <- exact[["value"]][i[!is.na(i)]]

  # Numeric ranges
  ranges <- value_labels[
    !is.na(value_labels[["code_min"]]) &
      value_labels[["code_min"]] != value_labels[["code_max"]],
  ]

  for (r in seq_len(nrow(ranges))) {
    in_range <- is.na(decoded) &
      year == ranges[["year"]][[r]] &
      !is.na(values_num) &
      values_num >= ranges[["code_min"]][[r]] &
      values_num <= ranges[["code_max"]][[r]]
    decoded[in_range] <- ranges[["value"]][[r]]
  }

  # Character codes
  character_codes <- value_labels[is.na(value_labels[["code_min"]]), ]
  i <- match(
    paste(year, values),
    paste(character_codes[["year"]], character_codes[["code"]])
  )
  decoded[is.na(decoded) & !is.na(i)] <- character_codes[["value"]][
    i[is.na(decoded) & !is.na(i)]
  ]

  decoded
}

#' Read a value label parquet file from inst/extdata (cached for the session)
#' @noRd
read_value_label_file <- function(file) {
  if (is.null(crashapi_env[[file]])) {
    crashapi_env[[file]] <- nanoparquet::read_parquet(
      system.file("extdata", file, package = "crashapi", mustWork = TRUE)
    )
  }

  crashapi_env[[file]]
}

crashapi_env <- new.env(parent = emptyenv())
