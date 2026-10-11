# decode_fars() uses year if provided

    Code
      decode_fars(person, table = "person")
    Condition
      Error in `decode_fars()`:
      ! `year` must be provided if `x` doesn't have a CASEYEAR, CaseYear, or YEAR column.

# decode_fars() replaces codes with factors for categorical variables

    Code
      out <- decode_fars(person, table = "person", decode = "replace")
    Message
      i "AGE" wasn't replaced since it is a measure or has values without value labels.

# decode_fars() adds value labels with haven::labelled()

    Code
      out <- decode_fars(multi_year, table = "person", decode = "labelled")
    Condition
      Warning:
      Value labels for "INJ_SEV" differ between 1985 and 2022.
      i Using value labels from 2022.

# var_labels must be a valid value

    Code
      format_crashes(data.frame(ST_CASE = 1), var_labels = "yes")
    Condition
      Error in `format_crashes()`:
      ! `var_labels` must be one of "attribute" or "none", not "yes".

