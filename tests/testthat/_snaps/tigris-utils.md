# Test lookup_fips outputs

    Code
      out <- lookup_fips(state = "XX")
    Condition
      Warning in `lookup_fips()`:
      `state` contains 1 invalid FIPS code or state name/abbreviations: "XX"

# validate_state and validate_county works

    Code
      out <- validate_county("DC", "Garrett", .msg = FALSE)
    Condition
      Warning:
      `county` input can't be matched to any valid value: "Garrett"

---

    Code
      out <- validate_county("MD", "Baltimore", .msg = FALSE)
    Condition
      Warning:
      `county` input 'Baltimore' matches Baltimore County, Baltimore city. Please refine your selection.

---

    Code
      out <- validate_county("MD", 999, .msg = FALSE)
    Condition
      Warning:
      Dropping invalid `county` value: "999"

---

    Code
      out <- validate_county("XX", "Garrett", .msg = FALSE)
    Condition
      Warning:
      `state` contains 1 invalid FIPS code or state name/abbreviations: "XX"
      Warning:
      `county` can't be checked without a valid `state`.
      ! Dropping `county` value: "Garrett"

# validate_state() returns FIPS codes for valid values

    Code
      out <- validate_state(c("MD", "XX"), multiple = TRUE, .msg = FALSE)
    Condition
      Warning:
      `state` contains 1 invalid FIPS code or state name/abbreviations: "XX"

---

    Code
      validate_state(c("MD", "VT"), .msg = FALSE)
    Condition
      Error:
      ! `state` must be length 1, not length 2

---

    Code
      validate_state("XX", require_state = TRUE, .msg = FALSE)
    Condition
      Error:
      ! `state` must be a valid state name or abbreviation, not "XX".

