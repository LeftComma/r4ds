library(tidyverse)

df <- tibble(
  a = rnorm(10),
  b = rnorm(10),
  c = rnorm(10),
  d = rnorm(10)
)

# purrr has a family of functions for looping over a vector,
# split by the type of output they produce
# They all take a vector, apply a function to each piece, and return,
# a vector with the same length and same names

# map() makes a list
# map_lgl() makes a logical vector
# map_int() makes an integer vector
# map_dble() makes a double vector
# map_chr() makes a character vector


map_dbl(df, mean)

df %>% map_dbl(median)

# purrr functions are built in C and pretty fast
# the .f argument can be a formular, a character vector, or an integer vector
# ... can be used to pass additional arguments


# Shortcuts ---------------------------------------------------------------
# Say you want to fit a linear model to each part of cars
models <- mtcars %>% 
  split(.$cyl) %>% 
  map(function(df) lm(mpg ~ wt, data = df))

# You can do it in a much shorter, one-sided formula
models <- mtcars %>% 
  split(.$cyl) %>% 
  map(~lm(mpg ~ wt, data = .))
# . refers to the current list item, like i in a loop

# With a lot of models you might want to extract a named component
models %>% 
  map(summary) %>% 
  map_dbl(~.$r.squared)
# This can be done even faster by using a string
models %>% 
  map(summary) %>% 
  map_dbl("r.squared")

# You can also use an integer to select elements by their position
x <- list(list(1, 2, 3), list(4, 5, 6), list(7, 8, 9))
x %>% map_dbl(2)


# Base R ------------------------------------------------------------------
# lappy() in base R is essentially the same as map(),
# but it doesn't work as well with the rest of purrr


#### Questions ####
# 1. Write code that uses a map function to:
# a) Compute the mean of every column in mtcars
mtcars %>% map_dbl(mean)

# b) Determine the type of each column in nycflights13::flights
nycflights13::flights %>% map_chr(typeof)

# c) Compute the number of unique values in each column of iris
iris %>% map_dbl(length(unique))
# The above doesn't work because I haven't given unique any arguments I think
# This is the correct way to write it:
map_int(iris, function(x) length(unique(x)))
# Or to use a one-sided formula
map_int(iris, ~length(unique(.x)))

# Or you can use the function n_distinct()
map_int(iris, n_distinct)

# d) Generate 10 random normals from distributions with means of -10, 0, 10, and 100
# This means 10 normal distributions, which means you'd get a list back
map(c(-10, 0, 10, 100), ~rnorm(n = 10, mean = .))

# 2. How can you create a single vector that for each column in a data frame,
# indicates whether or not it's a factor?
map_lgl(diamonds, is.factor)

# 3. What happens when you use the map functions on vectors that aren't lists? 
# What does map(1:5, runif) do? Why?
map(1:5, runif)
# map works with any vector, but always outputs as a list
# It's the equivalent of running this:
list(
  runif(1),
  runif(2),
  runif(3),
  runif(4),
  runif(5)
)
# So for the 5th item it's calling a runif which draws 5 samples

# 4. What does map(-2:2, rnorm, n = 5) do? Why? 
# What does map_dbl(-2:2, rnorm, n = 5) do? Why?
map(-2:2, rnorm, n = 5)
# I think that it gives 5 items taken from a normal distribution with means of
# -2, -1, 0, 1, and 2
map_dbl(-2:2, rnorm, n = 5)
# For me, this just broke
# This is because it needs to return a numeric vector of length 1.

# 5. Rewrite map(x, function(df) lm(mpg ~ wt, data = df)) to eliminate the anonymous function.
x <- split(mtcars, mtcars$cyl)
map(x, function(df) lm(mpg ~ wt, data = df))

# Rewritten:
map(x, ~lm(mpg ~ wt, data = .))