library(tidyverse)

# R is a functional language, meaning you can wrap loops into a function
# and call the function instead of a loop
df <- tibble(
  a = rnorm(10),
  b = rnorm(10),
  c = rnorm(10),
  d = rnorm(10)
)

# Say you want the mean of each column, a for loop would do it
output <- vector("double", length(df))
for (i in seq_along(df)) {
  output[[i]] <- mean(df[[i]])
}
output

# Say you want to do that repeatedly, so you put it into a function
col_mean <- function(df) {
  output <- vector("double", length(df))
  for (i in seq_along(df)) {
    output[i] <- mean(df[[i]])
  }
  output
}

# If you want to do median too, you can make a function for that
col_median <- function(df) {
  output <- vector("double", length(df))
  for (i in seq_along(df)) {
    output[i] <- median(df[[i]])
  }
  output
}
# But now you've copy-pasted code!
# Most of the code is the same, with the mean/median difference

# You could create a generic function with an argument for the type of operation
col_summary <- function(df, fun) {
  out <- vector("double", length(df))
  for (i in seq_along(df)) {
    out[i] <- fun(df[[i]])
  }
  out
}

col_summary(df, mean)
col_summary(df, median)

# Being able to pass functions to other functions is part of what makes R functional
# It also enables a few purrr functions that replace the need for loops
# Base R also has the apply functions (apply(), tapply(), lapply()) that act similarly

# purrr tries to break down list manipulation issues into independent pieces


#### Questions ####
# 1. Read the documentation for apply(). In the 2d case, what two for loops does it generalise?
# It replaces looping over rows and looping over columns


# 2. Adapt col_summary() so that it only applies to numeric columns You might want to start, 
#   with an is_numeric() function that returns a logical vector that has a TRUE corresponding,
#   to each numeric column.
col_summary2 <- function(df, fun) {
  # create an empty vector which will store whether each
  # column is numeric
  numeric_cols <- vector("logical", length(df))
  # test whether each column is numeric
  for (i in seq_along(df)) {
    numeric_cols[[i]] <- is.numeric(df[[i]])
  }
  # find the indexes of the numeric columns
  idxs <- which(numeric_cols)
  # find the number of numeric columns
  n <- sum(numeric_cols)
  # create a vector to hold the results
  out <- vector("double", n)
  # apply the function only to numeric vectors
  for (i in seq_along(idxs)) {
    out[[i]] <- fun(df[[idxs[[i]]]])
  }
  # name the vector
  names(out) <- names(df)[idxs]
  out
}





