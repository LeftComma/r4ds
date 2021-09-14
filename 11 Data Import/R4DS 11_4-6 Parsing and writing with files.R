library(tidyverse)
library(feather)

# readr tries to guess the data type of each column by checking the first 1000 items against a set of rules
#   logical: contains only "F", "T", "FALSE", or "TRUE"
#   integer: contains only numeric characters (and -)
#   double: contains only valid doubles (including numbers like 4.5e-5)
#   number: contains valid doubles with the grouping mark inside
#   time: matches the default time_format
#   date: matches the default date_format
#   date-time: any ISO8601 date

guess_parser("2010-10-01")
guess_parser("15:01")
guess_parser(c("1", "5", "9"))
str(parse_guess("2010-10-10"))

# However this can cause a problem with larger files, when either:
#   The first thousand rows are a special case. For example a column of doubles that only contains integers in the first 1000
#   The first thousand rows are missing values

# This file illustrates these problems
challenge <- read_csv(readr_example("challenge.csv")) # The output isn't the same as in the book
# I think readr has been improved since, because there are no problems
problems(challenge)
# And the tail looks the same as his does after he fixed it
tail(challenge)

# If needed, you can specify the column when you parse a file
# Every parse3_xyz() function has a corresponding col_xyz() function
# He recommends always supplying column types
challenge <- read_csv(
  readr_example("challenge.csv"), 
  col_types = cols(
    x = col_double(),
    y = col_date()
  )
)

# You can also read all the columns in as characters, and work from there
challenge2 <- read_csv(readr_example("challenge.csv"), 
                       col_types = cols(.default = col_character())
)
# You can then use type_convert() to change them into the type you want

# If you're having major problems, you can read the file into a character vector with each line as a row,
#   done with read_lines() or the whole thing into a character vector of length 1 with read_file(),
#   and then use string parsing


# readr comes with write_csv() and write_tsv() to write out files
# They both encode strings in UTF-8 and save dates and date-times in ISO8601 format

# To export a csv for Excel use write_excel_csv(), which tells Excel it's using UFT-8

# To write, add the df being written and the path
write_csv(challenge, "challenge.csv")
# Type information is lost when writing to a csv

# To save results in a way that maintains column types there are two options
# Use R's custom binary format, called RDS
write_rds(challenge, "challenge.rds")
read_rds("challenge.rds")

# Or use the feather package's binary format, which is faster and can be used by other programming languages
write_feather(challenge, "challenge.feather")
read_feather("challenge.feather")


# There are other tidyverse packages besides readr for other types of data
# For rectangular data:
#   haven reads SPSS, Stata, and SAS files
#   readxl reads excel files (both .xls and .xlsx)
#   DBI, along with a database specific backend (e.g. RMySQL, RSQLite, RPostgreSQL etc) for SQL queries

# For anything else try the R data import/export manual and the rio package



