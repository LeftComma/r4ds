library(modelr)
library(tidyverse)
library(gapminder)

# You also need to be able to turn a list-vector into a regular column (atomic vector)
# or set of columns. How you do this depends on whether you want a single or multiple
# values per element

# 1. For a single value, use mutate() with map_lgl(), map_int(), map_dbl(), and map_chr() 
# to create an atomic vector

# You can always summarise a column with it's length and type
df <- tribble(
  ~x,
  letters[1:5],
  1:3,
  runif(5)
)

df %>% mutate(
  type = map_chr(x, typeof),
  length = map_int(x, length)
)
# This can be useful for filtering out bits of a list that you don't want

# map_*() shortcuts like map_chr(x, "seed") lets you extract the string stored 
# in seed for each element of x. You can use this to pull apart nested lists
df <- tribble(
  ~x,
  list(a = 1, b = 2),
  list(a = 2, c = 4)
)
df %>% mutate(
  a = map_dbl(x, "a"),
  b = map_dbl(x, "b", .null = NA_real_) # .null specifies what to do if the element is missing
)


# 2. If you want many values, use unnest() to convert back to regular columns
# unnest() repeats the new column for each element in the list-column
# Here, it repeats the first row 4 times, because the first element in y has length 4
# And then it repeats the second column twice
tibble(x = 1:2, y = list(1:4, 1)) %>% unnest(y)

# So you can't unnest two columns containing different lengths at the same time
df1 <- tribble(
  ~x, ~y,           ~z,
  1, c("a", "b"), 1:2,
  2, "c",           3
)
df1
# This works because y and z have the same number of elements in each row
df1 %>% unnest(c(y, z))

# This doesn't because y and z have different rows in each column
df2 <- tribble(
  ~x, ~y,           ~z,
  1, "a",         1:2,  
  2, c("b", "c"),   3
)
df2

df2 %>% unnest(c(y, z))
# To be completely honest I don't get why this "doesn't work"
# It looks worse true but isn't it still correct?


#### Questions ####
# 1. Why might the lengths() function be useful for creating atomic vector columns from list-columns?
# Because you can check whether all the elements in a list-column are the same length
# It does the same thing as map_int(x, length) or sapply(x, length)

# 2. List the most common types of vector found in a data frame. What makes lists different?
# Character, numeric, integer, boolean/logical, factor
# Lists are different because they're not atomic. They can contain other lists and vectors