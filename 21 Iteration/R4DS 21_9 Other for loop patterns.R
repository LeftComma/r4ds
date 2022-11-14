library(tidyverse)

# There are a few other rarer functions, this is just so I know they exist
# Many work with predicate functions, which return either TRUE or FALSE

# keep() and discard() keeps elements that are TRUE and FALSE respectively
iris %>% 
  keep(is.factor) %>% 
  str()

iris %>% 
  discard(is.factor) %>% 
  str()

# some() and every() determine if the predicate is true for any or all elements
x <- list(1:5, letters, list(10))

x %>% 
  some(is_character)

x %>%
  every(is.character)

# detect() returns the first element where the predicate is true
x <- sample(10)
x
x %>%
  detect(~ . > 5)
# detect_index() returns its position
x %>%
  detect_index(~ . > 5)

# head_while() and tail_while() take elements from the start or end of
# a vector while the predicate is true
x %>% 
  head_while(~ . > 5)
x %>% 
  tail_while(~ . > 5)
# These don't work for me for some reason


# Reduce and accumulate let you reduce a list by repeatedly joining different
# elements together
# reduce() lets you repeatedly reduce a pair into a single item
# It takes a binary function (one with two inputs) and repeatedly applies it to a list until there's
# only one item left
# For example combining the elements of 3 dfs into 1
dfs <- list(
  age = tibble(name = "John", age = 30),
  sex = tibble(name = c("John", "Mary"), sex = c("M", "F")),
  trt = tibble(name = "Mary", treatment = "A")
)

dfs %>% reduce(full_join)

# Or you want to find the intersection of a list of vectors
vs <- list(
  c(1, 3, 5, 6, 10),
  c(1, 2, 3, 7, 8, 10),
  c(1, 2, 3, 4, 8, 9, 10)
)

vs %>% reduce(intersect)

# accumulate() does the same but keeps the interim results
# This could be used to calculate a cumulative sum
x <- sample(10)
x
x %>% accumulate(`+`)


#### Questions ####
# 1. Implement your own version of every() using a for loop. Compare it with purrr::every(). 
#   What does purrr's version do that your version doesn't?
x <- list(1:5, letters, list(10))
y <- length(x)-1
check <- 1
for (i in 1:y) {
  a <- x[i]
  b <- x[i+1]
  if (typeof(a) != typeof(b)){
    print("FALSE")
  }
}
# The above doesn't work. I also realise I was just trying to do types, rather than letting the loop accept
# a generic function to apply to each item
# The solution is below:
# Use ... to pass arguments to the function
every2 <- function(.x, .p, ...) { # .x refers to the list. .p refers to the function
  for (i in .x) {
    if (!.p(i, ...)) { # check each item of x against the function p
      # If any is FALSE we know not all of then were TRUE
      return(FALSE)
    }
  }
  # if nothing was FALSE, then it is TRUE
  TRUE
}

# Below gives the list [1,2,3] as x and a function that checks whether each item is greater than 1
every2(1:3, function(x) {
  x > 1
})
# purrr apparently lets you do fancy things with the predicate function and the input list

# 2. Create an enhanced col_summary() that applies a summary function to every numeric column in a data frame
# This is straight from the solutions:
# I will use map to apply the function to all the columns, and keep to only select numeric columns.
col_sum2 <- function(df, f, ...) {
  map(keep(df, is.numeric), f, ...)
}

col_sum2(iris, mean)

# 3. A possible base R equivalent of col_summary() is:
col_sum3 <- function(df, f) {
  is_num <- sapply(df, is.numeric)
  df_num <- df[, is_num]
  
  sapply(df_num, f)
}
# But it has a number of bugs as illustrated with the following inputs:
df <- tibble(
  x = 1:3, 
  y = 3:1,
  z = c("a", "b", "c")
)
col_sum3(df, mean)
col_sum3(df[1:2], mean)
col_sum3(df[1], mean)
col_sum3(df[0], mean)

# The sapply() function does not guarantee the type of vector it returns, 
# and will returns different types of vectors depending on its inputs. If no columns are selected, 
# instead of returning an empty numeric vector, it returns an empty list. 
# This causes an error since we can't use a list with [
sapply(df[0], is.numeric)
sapply(df[1], is.numeric)
sapply(df[1:2], is.numeric)
# I got different results from the exercise solution, funnily enough.
# Apparently you should avoid programming with sapply()