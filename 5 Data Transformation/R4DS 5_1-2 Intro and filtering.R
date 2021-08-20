library(nycflights13)
library(tidyverse)

# Were going to be working with the flights data
flights
View(flights)
# There are several types of variable within this df
# int: integers
# dbl: double, real numbers (floats)
# chr: charactor vector, strings
# dttm: date-times
# lgl: logical, boolean
# fctr: factor, a categorical variable with fixed possible values
# date: dates

# There are six key functions in dplyr
# filter() picks observations by their values
# arrange() reorders rows
# select() lets you pick variables by name
# mutate() creates new variables with functions of existing ones
# summarise() collapses variables down to a summary
# group_by() alters how the other functions work on the dataset

# They all work similarly:
# First argument is a data frame
# The next argument describes what to do, using the variable names without quotes
# The result is a new data frame


# Lets start with filter()
# dplyr never modifies the input, so to get the df out, you have to save it to a new variable
# If not, it will just get printed
jan1 <- filter(flights, month == 1, day == 1)

# When using logical operators, the computer sometimes calcualtes an approximation
sqrt(2) ^ 2 == 2
near(sqrt(2) ^ 2,  2) # near() can be used instead

# filtering uses logical operates like ==, >, >= and !=
# They can be combined with boolean operators
# & means and, | means or, ! is not, xor means everything in one of the groups but exclude things in both

# This gives us the flights in November and December
filter(flights, month == 11 | month == 12)
# Another way of writing it is using x %in% y notation
filter(flights, month %in% c(11, 12))

# Often boolean operators can be simplified
# These two get the same result, but the second is simpler
filter(flights, !(arr_delay > 120 | dep_delay > 120))
filter(flights, arr_delay <= 120, dep_delay <= 120)
# When filter expressions get to complex, consider doing them step-by-step with new variables

# Missing values are represented by NA
# You can check if a value is missing using is.na()
x = NA
is.na(x)

# filter() automatically excludes NA or FALSE values
df <- tibble(x = c(1, NA, 3))
filter(df, x > 1)
# You can ask for them explicitly
filter(df, is.na(x) | x > 1)


#### Questions ####
# 1. Find all flights that had...
# a) arrival delay of 2 or more hours
filter(flights, arr_delay >= 120)
# b) flew to Houston
filter(flights, dest == "HOU" | dest == "IAH")
# c) were operated by United, American, or Delta
filter(flights, carrier %in% c("UA", "DL", "AA"))
# d) departed in summer
filter(flights, month %in% 7:9)
# e) left on time but arrived over two hours late
filter(flights, dep_delay <= 0 & arr_delay >= 120)
# f) were delayed by at least an hour, but made 30 minutes back
filter(flights, dep_delay >= 60 & arr_delay < dep_delay - 30)
# g) departed between midnight and 6am (inclusive)
# midnight is represented by 2400
summary(flights$dep_time)
filter(flights, dep_time <= 600 | dep_time == 2400)

# 2. between() essentially means within a range, it's the same as doing x:y
?between

# 3. There are 8,225 flights with no dept time, these are likely cancelled flights
filter(flights, is.na(dep_time))

# 4. NA usually makes any operation including it missing
# Unless, that operation can account for NA
NA ^ 0 # Anything to the power of 0 is one
NA | TRUE # Anything or true would be true
NA * 0 # Should work but doesn't, because 0 * infinity (Inf) are undefined (NaNs)
