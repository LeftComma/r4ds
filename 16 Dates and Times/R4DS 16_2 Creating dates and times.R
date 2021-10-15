library(tidyverse)
library(lubridate)
library(nycflights13)

# There are three types of date/time data:
# date - presented in tibbles as <date>
# time within a day - presented as <time> by tibbles
# a date-time is both - presented by tibbles as <dttm> and elsewhere in R as POSIXct

# R doesn't have a native class for storing times, when dealing with times use the hms pacakage

# You should always use the simplest data type you can

# To get the current date or date-time:
today()
now()

# You can create date/times from strings, components or existing date/time objects
# From strings:
# lubridate contains parsers which work out the format of a date/time once you give it the order
#   To use them you just arrange y, m and d
ymd("2017-01-31")
mdy("January 31st, 2017")
dmy("31-Jan-2017")
ymd(20170131) # They also take unquoted numbers

# You can add time by adding an underscore and including h, m and s
ymd_hms("2017-01-31 20:11:59")
mdy_hm("01/31/2017 08:01")

# You can also specify the timezone directly
ymd(20170131, tz = "UTC")


# From components:
# The flights data has all the date-time components as seperate variables
flights %>% 
  select(year, month, day, hour, minute)

# Here you'd use make_date() or make_datetime()
flights %>% 
  select(year, month, day, hour, minute) %>% 
  mutate(departure = make_datetime(year, month, day, hour, minute))

# Lets do this for all the time columns
#   Because time is represented in a strange format, we have to do some maths on it
# Lets do that in a function
make_datetime_100 <- function(year, month, day, time) {
  make_datetime(year, month, day, time %/% 100, time %% 100)
}

# Run the function on our time variables, and save what we'll be using later to a df
flights_dt <- flights %>% 
  filter(!is.na(dep_time), !is.na(arr_time)) %>% 
  mutate(
    dep_time = make_datetime_100(year, month, day, dep_time),
    arr_time = make_datetime_100(year, month, day, arr_time),
    sched_dep_time = make_datetime_100(year, month, day, sched_dep_time),
    sched_arr_time = make_datetime_100(year, month, day, sched_arr_time)
  ) %>% 
  select(origin, dest, ends_with("delay"), ends_with("time"))

flights_dt

# Now you can visualise how departure times are distributed across the year
flights_dt %>% 
  ggplot(aes(dep_time)) + 
  geom_freqpoly(binwidth = 86400) # 86400 seconds = 1 day

# Or within a day
flights_dt %>% 
  filter(dep_time < ymd(20130102)) %>% # Select a particular date
  ggplot(aes(dep_time)) + 
  geom_freqpoly(binwidth = 600) # 600 s = 10 minutes
# With date-times, 1 means 1 second. For dates, 1 means 1 day


# From other types
# as_datetime() and as_date() let you switch between a date-time and a date
as_datetime(today())
as_date(now())

# Sometimes you'll get date/times as offset since the "Unix Epoch", 01/01/1970
# If the offset is in seconds, use as_datetime()
as_datetime(60 * 60 * 10)
# If it's in days, use as_Date()
as_date(365 * 10 + 2)


#### Questions ####
# 1. What happens if you parse a string that contains invalid dates?
# It parses everything it can, invalid things become NA, and it throws a warning
# It does the same if the date is in the wrong format
ymd(c("2010-10-10", "bananas", "10-10-2010"))

# 2. What does the tzone argument to today() do? Why is it important?
# It tells you what timezone you want the time in
# It the default is the OS's timezone
today()

# 3. Use the appropriate lubridate function to parse each of the following dates
d1 <- "January 1, 2010"
d2 <- "2015-Mar-07"
d3 <- "06-Jun-2017"
d4 <- c("August 19 (2015)", "July 1 (2015)")
d5 <- "12/30/14" # Dec 30, 2014

mdy(d1)
ymd(d2)
dmy(d3)
mdy(d4)
mdy(d5)
