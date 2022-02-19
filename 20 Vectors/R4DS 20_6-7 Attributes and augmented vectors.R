library(tidyverse)

# Attributes are additional metadata about a vector
x <- 1:10
attr(x, "greeting") # Check a single attribute

attr(x, "greeting") <- "Hi!"
attr(x, "farewell") <- "Bye!"
attributes(x) # Check them all

# There are three important attributes:
#   Names are used to name the elements of a vector.
#   Dimensions (dims, for short) make a vector behave like a matrix or array.
#   Class is used to implement the S3 object oriented system.

# Classes afect how generic functions work
# Here's a typical generic function
as.Date
# UseMethod means it's generic, and calls a method based on the class given
methods("as.Date")
# So, if x is a character, it will call as.Date.character()

# getS3method() shows you specific implementation of a method
getS3method("as.Date", "default")
getS3method("as.Date", "numeric")

# print() is the most important S3 generic, [, [[, and $ are also important ones


# Augmented vectors -------------------------------------------------------

# Augmented vectors have additional attributes, so they behave differently
# We deal with 4 in this book: Factors, Dates, Date-times, and Tibbles

# Factors represent categorical data with a fixed set of possible values
# They have a levels attribute and are built on integers
x <- factor(c("ab", "cd", "ab"), levels = c("ab", "cd", "ef"))
typeof(x)
attributes(x)

# Dates are numeric vectors that show the number of daues since 1 Jan 1970
x <- as.Date("1971-01-01")
unclass(x)
typeof(x)
attributes(x)

# Date-times are numeric vectors with class POSIXct, they represent the number of seconds
# since Jan 1 1970. (POSIXct: Portable Operating System Interface, calendar time)
x <- lubridate::ymd_hm("1970-01-01 01:00")
unclass(x)
typeof(x)
attributes(x)

# tzone is an optional attribute, it controls how time is printed.
attr(x, "tzone") <- "US/Pacific"
x
attr(x, "tzone") <- "US/Eastern"
x

# POSIXlt is another type of date-time
y <- as.POSIXlt(x)
typeof(y)
attributes(y)
# These are sometimes found in base R, because they're useful for extracting components
# lubridate provides tools for that though, so you should always convert POSIXlt datetimes

# Tibbles are augmented lists: they have class "tbl_df" + "tbl" + "data.frame", 
#   and names (column) and row.names attributes
tb <- tibble::tibble(x = 1:5, y = 5:1)
typeof(tb)
attributes(tb)
# Tibbles are special because all vectors have to be the same length

# Traditional data.frames have a similar structure
df <- data.frame(x = 1:5, y = 5:1)
typeof(df)
attributes(df)
# Class is the main difference, with tibbles inheriting the regular data frame behaviours


#### Questions ####
# 1. What does hms::hms(3600) return? How does it print? 
#   What primitive type is the augmented vector built on top of? What attributes does it use?
x <- hms::hms(3600)
print(x) # It prints looking like an hour, with 0s and :s and everything
typeof(x) # It's built on top of the double type
attributes(x) # It has a units attibute, and a class of hms and difftime

# 2. Try and make a tibble that has columns with different lengths. What happens?
t <- tibble::tibble(x = 1:5, y = 5:2)
# You get an error, telling you which columns aren't the right length
# The exception is when you use a scalar, if so it recycles
t <- tibble::tibble(x = 1:5, y = 5)
t

# 3. Based on the definition above, is it ok to have a list as a column of a tibble?
# Yes seemingly, as long as the list is the same length as the other columns
t <- tibble::tibble(x = 1:2, y = list(c(1:2), c(1)))
t
                    