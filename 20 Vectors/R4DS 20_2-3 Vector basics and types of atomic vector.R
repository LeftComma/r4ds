library(tidyverse)

# Vectors are either atomic (one type) or lists (any type of data)
# Atomic vectors can be logical, integer, double, character, complex and raw
# NULL is used to represent a lack of a vector (it's usually treated as a vector of length 0)

# Each vector has two key properties: type and length
typeof(letters)
typeof(1:10)

x <- list("a", "b", 1:10)
length(x)

# They can also have additional metadata called attributes
# These make augmented vectors, of which there are three main types:
#   Factors are built on top of integer vectors
#   Dates and date-times are built on top of numeric vectors
#   Data frames and tibbles are built on top of lists

# The four main atomic types for data analysis are logical, integer, double and character


# Logical ---------------------------------------------------------

# The simplest form of vector, taking only TRUE, FALSE, and NA
1:10 %% 3 == 0
c(TRUE, TRUE, FALSE, NA)


# Numeric -----------------------------------------------------------------

# This includes both integer and doubles. Doubles are the default in R
# To make an integer, add L after the number
typeof(1)
typeof(1L)

# Doubles are floating point numbers that can't always be precisely represented
#   with a fixed amount of memory. So all doubles should be treated as approximations
x <- sqrt(2) ^ 2
x
x - 2
# When comparing doubles, it's better to use dplyr::near() because of this

# Integers have the special value: NA.
# Doubles have four: NA, NaN, Inf, and -Inf
# Don't use == to check for these
# It's better to use is.finite(), is.infinite(), is.na(), and is.nan()


# Character ---------------------------------------------------------------

# The most complex type, as each element is a string
# R uses a global string pool, so each unique string is only stored once
# When that string is used more, it's just as a pointer to the original string
# This reduces the memory needed to store duplicates
x <- "This is a reasonably long string."
pryr::object_size(x)

y <- rep(x, 1000)
pryr::object_size(y)
# y doesn't take up 1000x the memory that x does


# Missing values ----------------------------------------------------------

# Each type has its own NA
NA            # logical
NA_integer_   # integer
NA_real_      # double
NA_character_ # character

# You generally don't need to know this because NA is converted using implicit coercion
# Some functions are strict about inputs though, so it's worth knowing


#### Questions ####
# 1. Describe the difference between is.finite(x) and !is.infinite(x).
# !is.infinite(x) would be true if x was NA or NaN, because these aren't infinite
# is.finite(x) wouldn't include either of those, because they're not finite either

# 2. Read the source code for dplyr::near() (Hint: to see the source code, drop the ()). 
#   How does it work?
near
# There's a tolerance, which equals the value below
.Machine$double.eps
# This is the smallest positive floating point number that the machine can store
# The function checks whether the difference between the two inputs is smaller than
#   the square root of this

# 3. A logical vector can take 3 possible values. How many possible values can an 
#  integer vector take? How many possible values can a double take? Use google to do some research.
# It's constrained by the memory of the machine
# R uses 32-bit representation, with one value set aside for NA
# The range of integer values is +- 2^31 - 1
#   It's not 2^32 because 1 bit is used to represent the sign, and one for NA
.Machine$integer.max

# Trying to go bigger with integers gives you an NA
.Machine$integer.max + 1L
# However you can store it exactly as a numeric vector
as.numeric(.Machine$integer.max) + 1
# (This uses about double the amount of memory)

# Doubles use 64-bit representation, but has to store NA, Inf, -Inf, and NaN
# They end up with +-2 * 10^308
.Machine$double.xmax

# 4. Brainstorm at least four functions that allow you to convert a double to an integer. 
#   How do they differ? Be precise.
# You could round down, taking the floor() of a number
# Round up, taking the ceiling()
# Round towards zero, used by trunc() and as.integer()
# Round away from zero
# Round to the nearest integer, with various rules for handling ties:
#   Round down, towards -Inf
#   Round up, towards Inf
#   Round towards zero
#   Round away from zero
#   Round towards the even integer, round() uses this
#   Round towards the odd integer

# R and most programming languages use the IEEE standard to round to even because
#   it averages to 0, unlike rounding up which would create a positive bias


# 5. What functions from the readr package allow you to turn a string into logical, 
#   integer, and double vector?
readr::parse_logical()
parse_integer()
# parse_integer() throws an error if there are any non-numeric characters like £ or ,
parse_number() # This is a lot more forgiving with what it parses
parse_integer(c("1000", "$1,000", "10.00"))
parse_number(c("1.0", "3.5", "$1,000.00", "NA", "ABCD12234.90", "1234ABC", "A123B", "A1B2C"))

parse_double()
