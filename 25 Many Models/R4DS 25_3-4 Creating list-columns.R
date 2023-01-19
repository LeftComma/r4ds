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

# You should make sure your list-columns are homogeneous, which should come automatically when using purrr

# nest() creates a nested df - a df with a list-column of dfs
# You can use it on a grouped data frame, if so it leaves the groups as is
gapminder %>% 
  group_by(country, continent) %>% 
  nest()

# Or, if the df is ungrouped, you can specify which collumns you want to nest
gapminder %>% 
  nest(data = c(year:gdpPercap))


# Using it with mutate involves also using a function that takes a vector and returns a list
df <- tribble(
  ~x1,
  "a,b,c", 
  "d,e,f,g"
) 

df %>% 
  mutate(x2 = str_split(x1, ","))

# unnest() can reverse these too
df %>% 
  mutate(x2 = stringr::str_split(x1, ",")) %>% 
  unnest(x2)

# This specific pattern can be shortened with tidyr::seperate_rows()
df %>% 
  separate_rows(x1, sep = ",")

# the map() family of functions are other examples of shortening this pattern
sim <- tribble(
  ~f,      ~params,
  "runif", list(min = -1, max = 1),
  "rnorm", list(sd = 5),
  "rpois", list(lambda = 10)
)

sim %>% 
  mutate(sims = invoke_map(f, params, n = 10))


# summarise() can only work with functions that return a single value
# We can get around this by getting it to return a list
mtcars %>% 
  group_by(cyl) %>% 
  summarise(q = quantile(mpg))
# This doesn't work, because quantile returns a vector of >1 length
# (I have no idea what quantile does tbh)

# But we can get the output thrown into a list
mtcars %>% 
  group_by(cyl) %>% 
  summarise(q = list(quantile(mpg)))

# Then you can unlist it
probs <- c(0.01, 0.25, 0.5, 0.75, 0.99) # You need these for the quantile function to make sense
mtcars %>% 
  group_by(cyl) %>% 
  summarise(p = list(probs), q = list(quantile(mpg, probs))) %>% 
  unnest(c(p, q))


# Working from a named list helps you iterate over a list's elements and contents
x <- list(
  a = 1:5,
  b = 3:4, 
  c = 5:6
) 

df <- enframe(x)
df

# Now you can iterate over the names and values in parallel
df %>% 
  mutate(
    smry = map2_chr(name, value, ~ stringr::str_c(.x, ": ", .y[1]))
  )


#### Questions ####
# 1. List all the functions that you can think of that take a atomic vector and return a list.
# Many stringr functions do that
str_split(sentences[1:3], " ")
str_match_all(c("abc", "aa", "aabaa", "abbbc"), "a+")
# So does map()
map(1:3, runif)

# 2. Brainstorm useful summary functions that, like quantile(), return multiple values.
range(mtcars$mpg)
fivenum(mtcars$mpg)
boxplot.stats(mtcars$mpg)
# Other examples include any advanced stats function, like t.test() or aov()

# 3. What's missing in the following data frame? 
# How does quantile() return that missing piece? Why isn't that helpful here?
mtcars %>% 
  group_by(cyl) %>% 
  summarise(q = list(quantile(mpg))) %>% 
  unnest(q)
# It gives you the quantile that corresponds to that probability
# But we don't know what the probability is, so it's useless
# This is because quantile returns those as names of the vector, which unnest drops
quantile(mtcars$mpg)

# 4. What does this code do? Why might might it be useful?
mtcars %>% 
  group_by(cyl) %>% 
  summarise_all(list(list))
# It throws everything that isn't cyl into lists
# Presumably good so you can iterate over cyl and the lists at the same time
# Apparently dplyr::do can do a similar thing


