library(tidyverse)
library(lubridate)
library(nycflights13)


# Durations
# Subtracting dates gets a difftime object, recording a span of time
h_age <- today() - ymd(19791014)
h_age

# lubridate lets you force it to always use seconds, the duration
as.duration(h_age)

# You can convert a lot of things into durations
dseconds(15)
dminutes(10)
dhours(c(12, 24))
ddays(0:5)
dweeks(3)
dyears(1)

# You can perform operations on durations
2 * dyears(1)

dyears(1) + dweeks(12) + dhours(15)

# You can also do stuff with today's date
tomorrow <- today() + ddays(1)
last_year <- today() - dyears(1)

# Durations are the exact time in seconds
one_pm <- ymd_hms("2016-03-12 13:00:00", tz = "America/New_York")
one_pm
one_pm + ddays(1)
# The clocks changed between the two above times, which is why they seem an hour off


# Periods
# Periods are "human" time spans, which are more intuative
one_pm
one_pm + days(1)

# These have the same constructors as durations
seconds(15)
minutes(10)
hours(c(12, 24))
days(7)
weeks(3)
months(1:6)
years(1)

# And you can add and multiple them
10 * (months(6) + days(1))

# They fix some of the weirdness with durations
# For a leap year:
ymd("2016-01-01") + dyears(1)
ymd("2016-01-01") + years(1)

# For daylight savings
one_pm + ddays(1)
one_pm + days(1)

# In flights, it looks like some of our flights arrive before they depart
make_datetime_100 <- function(year, month, day, time) { # This is borrowed from 16_2
  make_datetime(year, month, day, time %/% 100, time %% 100)
}

flights_dt <- flights %>% 
  filter(!is.na(dep_time), !is.na(arr_time)) %>% 
  mutate(
    dep_time = make_datetime_100(year, month, day, dep_time),
    arr_time = make_datetime_100(year, month, day, arr_time),
    sched_dep_time = make_datetime_100(year, month, day, sched_dep_time),
    sched_arr_time = make_datetime_100(year, month, day, sched_arr_time)
  ) %>% 
  select(origin, dest, ends_with("delay"), ends_with("time"))

# These are overnight flights, we can fix the issue by adding a day to the arrival time
flights_dt %>% 
  filter(arr_time < dep_time)

flights_dt <- flights_dt %>%
  mutate(
    overnight = arr_time < dep_time,
    arr_time = arr_time + days(overnight * 1),
    sched_arr_time = sched_arr_time + days(overnight * 1)
  )

# Now none of the flights seem to arrive before they leave
flights_dt %>%
  filter(overnight, arr_time < dep_time)


# Intervals
# Intervals are durations with a starting point
# They fix the issue of years being different lengths of days
# Which gives you estimates otherwise
years(1) / days (1)

next_year <- today() + years(1)

# The %--% defines an interval
# You can then find how many durations fall into this year
(today() %--% next_year) / ddays(1)

# You can do the same with periods, but you need to use interger division
# (not sure why, both seem to work?)
(today() %--% next_year) %/% days(1)


#### Questions ####
# 1. Why is there months() but no dmonths()?
# There is now dmonths()
dmonths(1)

# 2. Explain days(overnight * 1) to someone who has just started learning R. How does it work?
# This I struggled to figure out as well
# I think it's essentially a filter. It's adding 1 day, but only to values that appear in the
#   overnight column.
# This is because overnight is a TRUE or FALSE boolean variable

# 3. Create a vector of dates giving the first day of every month in 2015. 
#   Create a vector of dates giving the first day of every month in the current year.
start_15 <- ymd(20150101)
dates_15 <- start_15 + months(0:11)
dates_15

year_current <- year(today())
start_current <- make_date(year = year_current, month = 1, day = 1)
dates_current <- start_current + months(0:11)
dates_current

# The way he does it:
# Floor date rounds down to a certain unit
floor_date(today(), unit = "year") + months(0:11)

# 4. Write a function that given your birthday (as a date), returns how old you are in years.

years_old <- function(birthday) {
  (birthday %--% today()) %/% years(1)
}

years_old(ymd(19990508))

# 5. Why can't (today() %--% (today() + years(1))) / months(1) work?
# It works but sometimes gives the wrong result, because months aren't an exact length of time
(today() %--% (today() + years(1))) / months(1)

# To find the number of months in an interval, you're meant to use %/% instead
(today() %--% (today() + years(1))) %/% months(1)

