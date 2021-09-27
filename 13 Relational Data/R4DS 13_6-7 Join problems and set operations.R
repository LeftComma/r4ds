library(tidyverse)
library(nycflights13)

# Join Problems
# Data is rarely tidy, and that can make joining difficult
# Here are some things to do to make joining go smoothly

# 1. Identify the primary key in each table. And think about what would be useful
#   For example, altitude and longitude uniquely identify airports, but they're bad identifiers

# 2. Check none of the variables in the primar key are missing,
#   that would mean you can't identify an observation

# 3. Check that the foreign keys match primary keys in another table.
#   This can be done with anti_join(). Entry errors often cause mismatch and fixing them is a lot of work
#   You'd then need to thing about using an inner or outer join, whether you want to drop frows

# You can't just check the number of rows before and after a join because there
#   might be the same number of duplicate keys in both tables


# Set Operations
# These are the last type of two-table verb
# They work with a complete row, comparing the values of every variable
# They expect x and y to have the same variabes
df1 <- tribble(
  ~x, ~y,
  1,  1,
  2,  1
)
df2 <- tribble(
  ~x, ~y,
  1,  1,
  1,  2
)

# intersect(x, y) returns only observations in both x and y
intersect(df1, df2)

# union(x, y) returns unique observations in x and y
union(df1, df2)

# setdiff(x, y) returns observations in x, but not in y
setdiff(df1, df2)
setdiff(df2, df1)
