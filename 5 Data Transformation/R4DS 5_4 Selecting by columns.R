library(nycflights13)
library(tidyverse)

# select() lets us narrow down a df
# To save changes you need to assign them to a variable, otherwise it just prints them

# These both only show these three variables
select(flights, year, month, day)
select(flights, year:day)

# We can also choose to select everything but those columns
select(flights, -(year:day))

# There are a lot of helper functions that go with select()
# starts_with("abc"): matches names that begin with "abc"
# ends_with("xyz"): matches names that end with "xyz"
# contains("ijk"): matches names that contain "ijk"
# matches("(.)\\1"): selects variables that match a regular expression. 
# ^^^ That one matches any variables that contain repeated characters
# num_range("x", 1:3): matches x1, x2 and x3

# select() can rename variables but drops any variable not mentioned
# rename() renames while keeping other columns
rename(flights, tail_num = tailnum) # Place the new variable on the left

# select() can also be used to rearrange the columns in a df
select(flights, time_hour, everything()) # Here it's used w/ everything() to move the date-time to the start


#### Questions ####
# 1. Ways you can select a group of variables within a df
# Specify column names, without or with quotes
# Specify the column numbers (bad because they might get shifted around
# Use any_of() or all_of()
# starts_with() dep or time
# matches() a regular expression "^(dep|arr)_(time|delay)$"

# 2. If you put a variable twice it only counts the first time
select(flights, year, day, year)

# 3. any_of() selects variables that are in a vector (in this case, vars)
vars <- c("year", "month", "day", "dep_delay", "arr_delay")
select(flights, any_of(vars))

# 4. By default it ignores case, add "ignore.case = FALSE" to change that
select(flights, contains("TIME"))
