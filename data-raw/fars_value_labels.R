# Build variable and value labels for FARS and CRSS from NHTSA SAS files
#
# NHTSA's zipped SAS files for each year include a SAS PROC FORMAT program
# (e.g. Format24.sas) with the value labels for each format and SAS data files
# (.sas7bdat) that record the variable label and format for each column. This
# script downloads the zipped SAS files with get_fars_zip() and get_crss_zip(),
# parses the format programs, reads the variable labels and formats with
# haven::read_sas(), and writes two parquet files to inst/extdata:
#
# - fars_formats.parquet: source, format, code, code_min, code_max, value,
#   first_year, last_year
# - fars_variables.parquet: source, year, table, variable, label, format
#
# Most format names include the data year (e.g. STATE24F in 2024) so the year
# is removed from format names (e.g. STATEF) and identical values are combined
# into a single row with the first and last year of consecutive years. Format
# names with other years (e.g. FMKMD87F in 1991) are not changed.
#
# fars_value_labels() joins the two files and fars_variables() returns the
# variable labels. This script requires the haven, nanoparquet, and cli
# packages. The zipped SAS files (about 1.6 GB) are cached in data-raw/sas
# (ignored by git) so the script can be run again without downloading them.

devtools::load_all()
library(cli)

# Parse SAS PROC FORMAT VALUE statements into a data frame with the format
# name, code (as written, e.g. "1", "1-5", or "OTHER"), and value label
parse_sas_formats <- function(path) {
  txt <- readLines(path, warn = FALSE, encoding = "latin1")
  txt <- iconv(txt, from = "latin1", to = "UTF-8", sub = "")
  txt <- gsub("\r", "", txt, fixed = TRUE)
  # Drop SAS comment statements (lines starting with "*") since they can
  # contain unbalanced quotes
  txt <- txt[!grepl("^\\s*\\*", txt)]
  txt <- paste(txt, collapse = "\n")

  # Replace quoted strings with placeholder tokens so semicolons, equal signs,
  # and comment markers inside labels are ignored
  quoted <- "'(?:[^']|'')*'|\"(?:[^\"]|\"\")*\""
  strings <- regmatches(txt, gregexpr(quoted, txt, perl = TRUE))[[1]]
  pieces <- regmatches(
    txt,
    gregexpr(quoted, txt, perl = TRUE),
    invert = TRUE
  )[[1]]
  tokens <- sprintf("\u0001%d\u0002", seq_along(strings))
  txt <- paste0(pieces, c(tokens, ""), collapse = "")
  txt <- gsub("/\\*.*?\\*/", " ", txt, perl = TRUE)

  unquote <- function(x) {
    q <- substr(x, 1, 1)
    x <- substr(x, 2, nchar(x) - 1)
    gsub(paste0(q, q), q, x, fixed = TRUE)
  }

  restore <- function(x) {
    ids <- regmatches(
      x,
      gregexpr("(?<=\u0001)[0-9]+(?=\u0002)", x, perl = TRUE)
    )[[1]]

    for (i in as.integer(ids)) {
      x <- sub(
        sprintf("\u0001%d\u0002", i),
        unquote(strings[[i]]),
        x,
        fixed = TRUE
      )
    }

    x
  }

  statements <- trimws(strsplit(txt, ";", fixed = TRUE)[[1]])
  statements <- grep("^VALUE\\s", statements, ignore.case = TRUE, value = TRUE)

  rows <- lapply(statements, function(statement) {
    m <- regmatches(
      statement,
      regexec(
        "^VALUE\\s+(\\$?[A-Za-z_][A-Za-z0-9_]*)\\s*(\\([^)]*\\))?(.*)$",
        statement,
        ignore.case = TRUE
      )
    )[[1]]

    if (length(m) == 0) {
      return(NULL)
    }

    body <- m[[4]]
    entries <- regmatches(
      body,
      gregexpr("([^=\u0002]+?)\\s*=\\s*\u0001[0-9]+\u0002", body, perl = TRUE)
    )[[1]]

    if (length(entries) == 0) {
      return(NULL)
    }

    codes <- sub("\\s*=\\s*\u0001[0-9]+\u0002$", "", entries, perl = TRUE)
    labels <- regmatches(entries, regexpr("\u0001[0-9]+\u0002", entries))

    data.frame(
      format = toupper(m[[2]]),
      code = trimws(vapply(codes, restore, character(1), USE.NAMES = FALSE)),
      value = trimws(vapply(labels, restore, character(1), USE.NAMES = FALSE))
    )
  })

  do.call(rbind, rows)
}

# Expand comma-separated codes into separate rows and add numeric code_min and
# code_max columns for single values and ranges (e.g. "1-5", "LOW-0")
expand_codes <- function(formats) {
  parts <- strsplit(formats[["code"]], "\\s*,\\s*")
  formats <- formats[rep(seq_len(nrow(formats)), lengths(parts)), ]
  formats[["code"]] <- gsub("^'|'$", "", unlist(parts))

  bounds <- strsplit(formats[["code"]], "\\s*-\\s*(?=[0-9A-Za-z])", perl = TRUE)
  to_num <- function(x) {
    x <- toupper(trimws(x))
    suppressWarnings(
      ifelse(x == "LOW", -Inf, ifelse(x == "HIGH", Inf, as.numeric(x)))
    )
  }

  is_range <- lengths(bounds) == 2 & !grepl("^-", formats[["code"]])
  formats[["code_min"]] <- to_num(vapply(bounds, `[[`, character(1), 1))
  formats[["code_max"]] <- formats[["code_min"]]
  formats[["code_max"]][is_range] <- to_num(
    vapply(bounds[is_range], `[[`, character(1), 2)
  )
  formats[["code_min"]][!is_range] <- to_num(formats[["code"]][!is_range])
  formats[["code_max"]][!is_range] <- formats[["code_min"]][!is_range]
  rownames(formats) <- NULL
  formats
}

# Get the variable label and format for each column of each SAS data file
read_columns <- function(files) {
  rows <- lapply(files, function(file) {
    x <- haven::read_sas(file, n_max = 0)
    get_attr <- function(name) {
      vapply(
        x,
        function(col) attr(col, name, exact = TRUE) %||% NA_character_,
        character(1)
      )
    }

    data.frame(
      table = tolower(sub("[.]sas7bdat$", "", basename(file))),
      variable = names(x),
      label = trimws(get_attr("label")),
      format = toupper(sub("[.]$", "", get_attr("format.sas")))
    )
  })

  do.call(rbind, rows)
}

# Prefer files outside of the format-32 folder if there are any
prefer_not_32 <- function(files) {
  not_32 <- files[!grepl("format-32", files)]

  if (length(not_32) > 0) {
    return(not_32)
  }

  files
}

# Read value labels for formats from a SAS format catalog using the first
# column that uses each format
read_catalog_formats <- function(data_files, vars, formats, catalog_file) {
  vars <- vars[vars[["format"]] %in% formats, ]
  vars <- vars[!duplicated(vars[["format"]]), ]

  rows <- lapply(seq_len(nrow(vars)), function(i) {
    data_file <- data_files[
      tolower(sub("[.]sas7bdat$", "", basename(data_files))) ==
        vars[["table"]][[i]]
    ][[1]]

    x <- tryCatch(
      haven::read_sas(
        data_file,
        catalog_file = catalog_file,
        col_select = dplyr::all_of(vars[["variable"]][[i]]),
        n_max = 0
      ),
      error = function(e) NULL
    )

    labels <- attr(x[[1]], "labels")

    if (is.null(labels)) {
      return(NULL)
    }

    data.frame(
      format = vars[["format"]][[i]],
      code = as.character(unname(labels)),
      value = names(labels)
    )
  })

  do.call(rbind, rows)
}

# Download a SAS zip file and return value formats and variables
read_sas_zip <- function(source, year, sas_dir) {
  zipfile <- tryCatch(
    switch(
      source,
      FARS = get_fars_zip(year, format = "sas", read = FALSE, path = sas_dir),
      CRSS = get_crss_zip(year, format = "sas", read = FALSE, path = sas_dir)
    ),
    error = function(e) {
      cli_alert_warning("{source} {year}: {conditionMessage(e)}")
      NULL
    }
  )

  if (is.null(zipfile)) {
    return(NULL)
  }

  exdir <- tempfile("sas")
  on.exit(unlink(exdir, recursive = TRUE))
  utils::unzip(zipfile, exdir = exdir)
  files <- list.files(exdir, recursive = TRUE, full.names = TRUE)

  # Some zip files include the same format program for 32-bit and 64-bit SAS
  # (or only in the format-32 folder)
  format_files <- prefer_not_32(
    files[grepl("[.]sas$", files, ignore.case = TRUE)]
  )
  catalog_files <- prefer_not_32(
    files[grepl("[.]sas7bcat$", files, ignore.case = TRUE)]
  )
  data_files <- files[grepl("[.]sas7bdat$", files, ignore.case = TRUE)]

  if (length(format_files) == 0 || length(data_files) == 0) {
    cli_alert_warning(
      "{source} {year}: {length(format_files)} format file{?s} and
      {length(data_files)} data file{?s}"
    )
    return(NULL)
  }

  formats <- unique(do.call(rbind, lapply(format_files, parse_sas_formats)))
  vars <- read_columns(data_files)
  formatted <- vars[!is.na(vars[["format"]]), ]

  # Use the format catalog for formats that aren't in the format program
  missing_formats <- setdiff(unique(formatted[["format"]]), formats[["format"]])

  if (length(missing_formats) > 0 && length(catalog_files) > 0) {
    formats <- rbind(
      formats,
      read_catalog_formats(
        data_files,
        formatted,
        missing_formats,
        catalog_files[[1]]
      )
    )
  }

  missing_formats <- setdiff(unique(formatted[["format"]]), formats[["format"]])
  # Don't report SAS built-in formats like $20 or BEST12
  missing_formats <- missing_formats[
    !grepl("^\\$?[0-9]*$|^(BEST|DATE|TIME|COMMA|Z)[0-9]*$", missing_formats)
  ]

  # Only keep formats with value labels (dropping SAS built-in formats)
  vars[["format"]][!vars[["format"]] %in% formats[["format"]]] <- NA

  cli_alert_success(
    "{source} {year}: {nrow(vars)} variables ({sum(!is.na(vars$label))} with
    labels, {sum(!is.na(vars$format))} with formats) and
    {length(unique(formats$format))} formats in {length(data_files)} tables"
  )

  if (length(missing_formats) > 0) {
    cli_alert_info(
      "{source} {year}: formats not defined in format program:
      {.val {missing_formats}}"
    )
  }

  list(
    formats = cbind(source = source, year = year, expand_codes(formats)),
    vars = cbind(source = source, year = year, vars)
  )
}

# Drop vPIC formats (e.g. VPICMODEL24F) for FARS data
drop_fars_vpic <- function(x) {
  x[!(x[["source"]] == "FARS" & grepl("^VPIC", x[["format"]])), ]
}

# Remove the two-digit data year before the final "F" in format names
normalize_format <- function(x, year) {
  year_suffix <- sprintf("%02dF", as.integer(year) %% 100L)
  has_year <- !is.na(x) &
    endsWith(x, year_suffix) &
    nchar(x) > nchar(year_suffix)
  x[has_year] <- paste0(substr(x[has_year], 1, nchar(x[has_year]) - 3), "F")
  x
}

# Combine identical value labels for consecutive years into a single row
compress_formats <- function(formats) {
  formats[["format"]] <- normalize_format(
    formats[["format"]],
    formats[["year"]]
  )
  formats <- unique(formats)
  key_cols <- c("source", "format", "code", "code_min", "code_max", "value")
  key <- do.call(paste, c(formats[key_cols], sep = "\r"))
  formats <- formats[order(key, formats[["year"]]), ]
  key <- do.call(paste, c(formats[key_cols], sep = "\r"))

  # Start a new run when the key changes or the years aren't consecutive
  new_run <- c(
    TRUE,
    key[-1] != key[-length(key)] | diff(formats[["year"]]) != 1
  )
  run <- cumsum(new_run)

  compressed <- formats[new_run, key_cols]
  compressed[["first_year"]] <- as.integer(tapply(formats[["year"]], run, min))
  compressed[["last_year"]] <- as.integer(tapply(formats[["year"]], run, max))
  compressed <- compressed[
    order(
      compressed[["source"]],
      compressed[["format"]],
      compressed[["first_year"]],
      compressed[["code_min"]]
    ),
  ]
  rownames(compressed) <- NULL
  compressed
}

sas_years <- rbind(
  data.frame(source = "FARS", year = 1975:2024),
  data.frame(source = "CRSS", year = 2016:2024)
)

# Cache the zipped SAS files so the script can be run again without
# downloading them
sas_dir <- "data-raw/sas"

results <- Map(
  read_sas_zip,
  sas_years[["source"]],
  sas_years[["year"]],
  sas_dir
)

fars_formats <- do.call(rbind, lapply(results, `[[`, "formats"))
fars_variables <- do.call(rbind, lapply(results, `[[`, "vars"))

# Drop vPIC formats for FARS since FARS data from the CrashAPI and zipped CSV
# files already includes VPICMAKENAME, VPICMODELNAME, and VPICBODYCLASSNAME
# columns (vPIC formats are only used from 2020 onwards). CRSS data doesn't
# include these columns so the vPIC formats for CRSS are kept. The variable
# labels for these columns are kept.
fars_formats <- drop_fars_vpic(fars_formats)
fars_variables[["format"]][
  fars_variables[["source"]] == "FARS" &
    grepl("^VPIC", fars_variables[["format"]])
] <- NA
rownames(fars_formats) <- NULL
rownames(fars_variables) <- NULL

fars_value_labels_full <- merge(
  fars_variables[!is.na(fars_variables[["format"]]), ],
  fars_formats,
  by = c("source", "year", "format")
)

fars_formats <- compress_formats(fars_formats)
fars_variables[["format"]] <- normalize_format(
  fars_variables[["format"]],
  fars_variables[["year"]]
)
fars_variables <- fars_variables[
  c("source", "year", "table", "variable", "label", "format")
]

# Check that the compressed formats give the same value labels for each year
fars_value_labels_check <- merge(
  fars_variables[!is.na(fars_variables[["format"]]), ],
  fars_formats,
  by = c("source", "format")
)
fars_value_labels_check <- fars_value_labels_check[
  fars_value_labels_check[["year"]] >= fars_value_labels_check[["first_year"]] &
    fars_value_labels_check[["year"]] <= fars_value_labels_check[["last_year"]],
]

label_key <- function(x) {
  sort(paste(x$source, x$year, x$table, x$variable, x$code, x$value))
}

stopifnot(identical(
  label_key(fars_value_labels_full),
  label_key(fars_value_labels_check)
))

nanoparquet::write_parquet(
  fars_formats,
  "inst/extdata/fars_formats.parquet",
  compression = "zstd"
)

nanoparquet::write_parquet(
  fars_variables,
  "inst/extdata/fars_variables.parquet",
  compression = "zstd"
)
