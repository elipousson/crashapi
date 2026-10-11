# crashapi: CrashAPI

Get Fatality Analysis Reporting System (FARS) data with the FARS API
from the U.S. National Highway Traffic Safety Administration (NHTSA).

## Package options

- `crashapi.year`: Default year used by
  [`get_fars()`](https://elipousson.github.io/crashapi/reference/get_fars.md),
  [`get_fars_zip()`](https://elipousson.github.io/crashapi/reference/get_fars_zip.md),
  [`get_crss_zip()`](https://elipousson.github.io/crashapi/reference/get_crss_zip.md),
  [`fars_vars()`](https://elipousson.github.io/crashapi/reference/fars_vars.md),
  and related functions. Defaults to 2024, the most recent year of FARS
  data supported by the package. Set with
  `options(crashapi.year = 2022)`.

## See also

Useful links:

- <https://github.com/elipousson/crashapi>

- <https://elipousson.github.io/crashapi/>

- Report bugs at <https://github.com/elipousson/crashapi/issues>

## Author

**Maintainer**: Eli Pousson <eli.pousson@gmail.com>
([ORCID](https://orcid.org/0000-0001-8280-1706))

Authors:

- Eli Pousson <eli.pousson@gmail.com>
  ([ORCID](https://orcid.org/0000-0001-8280-1706))

Other contributors:

- Kyle Walker <kyle@walker-data.com> (Author of tigris helper functions
  bundled with crashapi (see tigris-utils.R).) \[copyright holder\]
