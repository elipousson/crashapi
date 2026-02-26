# Combine list elements into a single data structure

- `list_rbind()` combines elements into a data frame by row-binding them
  together with
  [`vctrs::vec_rbind()`](https://vctrs.r-lib.org/reference/vec_bind.html).

## Usage

``` r
list_rbind(x, ..., names_to = rlang::zap(), ptype = NULL)
```
