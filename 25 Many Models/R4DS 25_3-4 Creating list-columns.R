library(modelr)
library(tidyverse)
library(gapminder)

# A df is a names list of equal length vectors
# A list is a vector
# So naturally you could use a list as a column of a data-frame
# However base R doesn't make that easy, and data.frame treats a list as a list of columns
data.frame(x = list(1:3, 3:5))

# You can force it not to using I(), but this looks weird when printing
data.frame(
  x = I(list(1:3, 3:5)), 
  y = c("1, 2", "3, 4, 5")
)

# tibble() solves this by being lazy (not altering inputs), and printing more clearly
tibble(
  x = list(1:3, 3:5), 
  y = c("1, 2", "3, 4, 5")
)
# Though this actually SHOWS you less than the data.frame printing does

# tribble() automatically works out you need a list
tribble(
  ~x, ~y,
  1:3, "1, 2",
  3:5, "3, 4, 5"
)

# List-columns function well as an intermediate data structure, almost like a placeholder
# Most R functions work with dfs or atomic vectors, which makes list-columns hard to work with
# But they keep related items together very neatly

# There are generally 3 parts to a list-column pipeline
# 1. You create the list-column using one of nest(), summarise() + list(), or mutate() + a map function
# 2. You create other intermediate list-columns by transforming existing list columns with map(), map2() or pmap(). 
# For example, in the case study above, we created a list-column of models by transforming a 
# list-column of data frames.
# 3. You simplify the list-column back down to a data frame or atomic vector


# Creating column-lists ---------------------------------------------------

# There are three typical ways to make a list-column
# 1. Use tidyr::nest() to convert a grouped df into a nested df with a list-column of dfs
# 2. With mutate() and vectorised functions that return a list
# 3. With summarise() and summary functions that return multiple results
# Or you could create them from a named list, using tibble::enframe()

# You should make sure your list-columns are homogenous, which should come automatically when using purrr

















