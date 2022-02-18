library(tidyverse)

# There are a few important things you might want to know how to do to a vector:
#   How to convert from one type to another, and when that happens automatically.
#   How to tell if an object is a specific type of vector.
#   What happens when you work with vectors of different lengths.
#   How to name the elements of a vector.
#   How to pull out elements of interest.


# Coercion ----------------------------------------------------------------

# There are two ways to convert/coerce a vector from one type to another

# Explicit conversion involves using as.logical(), as.integer(), as.double(), or as.character()
# This is rare, and you should check that something wasn't wrong earlier in the code if
# you have to use them

# Implicit coercion happens when you use a vector in a context which requires a certain type
# For example, when TRUE is converted to 1 and FALSE to 0
x <- sample(20, 100, replace = TRUE)
y <- x > 10
sum(y)  # how many are greater than 10?
mean(y) # what proportion are greater than 10?

# It also means that when you have a vector with multiple types, the more complex type wins
typeof(c(1.5, "a"))


# Testing the type --------------------------------------------------------

# typeof() gives one option
# Or you can use a function which returns a TRUE or FALSE
# The R base functions like is.integer() often return suprising results
# is_* functions from purrr are better:
#   is_logical()
#   is_integer()
#   is_double()
#   is_numeric()
#   is_character()
#   is_atomic()
#   is_list()
#   is_vector()


# Scalars and recycling ---------------------------------------------------

# R also implicitly coerces the length of vectors when using multiple vectors together
# The shorter vector is recycled (repeated) to the same length as the longer one

# This is most useful when dealing with scalars, which R treats as vectors of length 1
sample(10) + 100

# This is silent unless the shorter vector can't multiply to the same length as the longer one
1:10 + 1:2
1:10 + 1:3

# Because it can sometimes conceal problems, tidyverse functions throw errors if you try and
#   recycle anything that isn't a scalar
tibble(x = 1:4, y = 1:2)
# rep() solves this issue
tibble(x = 1:4, y = rep(1:2, 2))


# Naming ------------------------------------------------------------------

# You can name vectors during creation
c(x = 1, y = 2, z = 4)

# Or after the fact
set_names(1:3, c("a", "b", "c"))


# Subsetting --------------------------------------------------------------

# filter() lets us subset tibbles, [] lets us subset vectors

# There are four types of things you can subset a vector with:
# 1. Another vector of all integers
# Using positive integers keeps the elements in those positions
x <- c("one", "two", "three", "four", "five")
x[c(3, 2, 5)]

# You can repeat positions
x[c(1, 1, 5, 5, 5, 2)]

# Negative values drop the elements at those positions
x[c(-1, -3, -5)]
# You can't mix positive and negative values

# 2. With a logical vector that keeps all values that are TRUE
x <- c(10, 3, NA, 5, 8, 1, NA)

# All non-missing values of x
x[!is.na(x)]

# All even (or missing!) values of x
x[x %% 2 == 0]

# 3. With a character vector (if it's got names)
x <- c(abc = 1, def = 2, xyz = 5)
x[c("xyz", "def")]

# 4. Nothing, using x[], which returns the whole vector
# This is useful for matricies
# x[1, ] returns the first row and all the columns
# x[ , -1] selects all rows and all columns but the first

# [[ is a variation of [ for extracting single elements


#### Questions ####
# 1. What does mean(is.na(x)) tell you about a vector x? What about sum(!is.finite(x))?
# mean(is.na(x)) tells you what percentage of a list are NAs
x <- c(1, NA, 2, NA)
mean(is.na(x))

# sum(!is.finite(x)) tells you how many non-finite values you've got
x <- c(2, 4, 6, Inf, Inf, NA)
sum(!is.finite(x))

# 2. Carefully read the documentation of is.vector(). What does it actually test for? 
#   Why does is.atomic() not agree with the definition of atomic vectors above?
# is.vector() only checks something doesn't have attributes besides names
# This means lists can also be a vector
is.vector(list(a = 1, b = 2))

# is.atomic() checks whether it's one of the atomic types
is.atomic(1:10)
# This even includes things with extra attributes
x <- 1:10
attr(x, "something") <- TRUE
is.atomic(x)

# 3. Compare and contrast setNames() with purrr::set_names().
setNames()
set_names()
# The purrr function is stricter and has more features
# These include augmenting existing names, removing names etc
# It can work in the same way as setNames()
set_names(1:4, c("a", "b", "c", "d"))

# Or the names can be unspecified arguments
set_names(1:4, "a", "b", "c", "d")

# Or it can name an object with itself if no name argument is given
set_names(c("a", "b", "c", "d"))

# It also lets you use a function or formula to change the names
set_names(c(a = 1, b = 2, c = 3), toupper)
set_names(c(a = 1, b = 2, c = 3), ~toupper(.))

# It also checks that the length of names is the same as the vector
set_names(1:4, c("a", "b"))
# setNames() just sets missing names to NA

# 4. Create functions that take a vector as input and returns:
x <- c("one", "two", "three", "four", "five")

#   The last value. Should you use [ or [[?
last <- function(x) {
  x[[length(x)]]
}
last(x)

#   The elements at even numbered positions.
even_positions <- function(x) {
  integer_equivalent <- c(1:length(x))
  even_is_true <- integer_equivalent %% 2 == 0
  x[even_is_true]
}
even_positions(x)
                                        
#   Every element except the last value.
all_but_last <- function(x) {
len <- length(x)
minus_len <- 0 - len
x[minus_len]
}
all_but_last(x)
                                        
#   Only even numbers (and no missing values).
x <- c(1:10, NA)

evens_only <- function(x) {
  no_na <- na.omit(x)
  is_even <- no_na %% 2 == 0
  x[is_even]
}
evens_only(x)

# 5. Why is x[-which(x > 0)] not the same as x[x <= 0]?
# They differ in how they return non-numeric values
x <- c(-1:1, Inf, -Inf, NaN, NA)
x[-which(x > 0)]
x[x <= 0]

# 6. What happens when you subset with a positive integer that's bigger than the 
#   length of the vector? What happens when you subset with a name that doesn't exist?
x <- c(1:10)
x[[11]]
# It gives you an error and tells you the subscript is out of bounds

x <- c(abc = 1, def = 2, xyz = 5)
x["abe"]
# Gives you an NA
