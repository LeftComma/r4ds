library(tidyverse)

# There are four basic variations on for loops:
# 1. Modifying an existing object, instead of creating a new object.
df <- tibble(
  a = rnorm(10),
  b = rnorm(10),
  c = rnorm(10),
  d = rnorm(10)
)

rescale01 <- function(x) {
  rng <- range(x, na.rm = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}

# We could turn this into a for loop
# Ouput - same as the input
# Sequence - the list of columns, using seq_along(df)
# Body - apply rescale01()

for (i in seq_along(df)) {
  df[[i]] <- rescale01(df[[i]])
}


# 2. Looping over names or values, instead of indices.
# You can loop over numeric indicies, like we've been doing

# You can also loop over elements, like (x in xs). Hard to save the output efficiently,
#   so usually only good for plotting or other side effects

# Loop over names like for (nm in names(xs)). This gives a name which can then be,
#   used to access the associated value. Then means the outputs can have names
# But you need to name the results vector
results <- vector("list", length(x))
names(results) <- names(x)

# Iteration over indicies means you can also extract a name
for (i in seq_along(x)) {
  name <- names(x)[[i]]
  value <- x[[i]]
}


# 3. Handling outputs of unknown length.
# Growing a vector one at a time can get very slow, but sometimes you don't know how long an output will be
means <- c(0, 1, 2)

output <- double()
for (i in seq_along(means)) {
  n <- sample(100, 1)
  output <- c(output, rnorm(n, means[[i]]))
}
str(output)

# It's more efficient to save each item in a list and then combine them after
out <- vector("list", length(means))
for (i in seq_along(means)) {
  n <- sample(100, 1)
  out[[i]] <- rnorm(n, means[[i]])
}
str(out)

str(unlist(out))

# Having a variable output length can occur at other times too, and it's generally better to,
# create a more complex object and then combine them at the end


# 4. Handling sequences of unknown length.
# Just use a while loop instead
while (condition) {
  code
}


#### Questions ####
#1. Imagine you have a directory full of CSV files that you want to read in. You have their, 
#   paths in a vector, files <- dir("data/", pattern = "\\.csv$", full.names = TRUE), and now want, 
#   to read each one with read_csv(). Write the for loop that will load them into a single data frame.
files <- dir("data/", pattern = "\\.csv$", full.names = TRUE)
csvs <- vector("list", length(files))

for (i in seq_along(files)) {
  csvs[[i]] <- read_csv(files[[i]])
}
csvs <- bind_rows(csvs)

# 2. What happens if you use for (nm in names(x)) and x has no names? What if 
#   only some of the elements are named? What if the names are not unique?
# With no names, the loop doesn't run at all
x <- c(11, 12, 13)
print(names(x))

for (nm in names(x)) {
  print(nm)
  print(x[[nm]])
}

# With some names, it throws an error when it tries to access something without a name
x <- c(a = 11, 12, c = 13)
names(x)

for (nm in names(x)) {
  print(nm)
  print(x[[nm]])
}

# 3. Write a function that prints the mean of each numeric column in a data frame, 
#   along with its name. For example, show_mean(iris) would print
# This uses str_length() to grab lengths, and str_pad() to pad the strings with whitespace
show_mean <- function(df, digits = 2) {
  # Get max length of all variable names in the dataset
  maxstr <- max(str_length(names(df)))
  for (nm in names(df)) {
    if (is.numeric(df[[nm]])) {
      cat(
        str_c(str_pad(str_c(nm, ":"), maxstr + 1L, side = "right"),
              format(mean(df[[nm]]), digits = digits, nsmall = digits),
              sep = " "
        ),
        "\n"
      )
    }
  }
}

# 4. What does this code do? How does it work?
trans <- list( 
  disp = function(x) x * 0.0163871,
  am = function(x) {
    factor(x, labels = c("auto", "manual"))
  }
)
for (var in names(trans)) {
  mtcars[[var]] <- trans[[var]](mtcars[[var]])
}

# It mutates the disp and am columns
# disp is multiplied by 0.0163871
# am is replaced by a factor variable

# It loops over a named list of functions. It calls the named function in the list and the,
#   mtcars column with the same name, and replaces the value of the column
























