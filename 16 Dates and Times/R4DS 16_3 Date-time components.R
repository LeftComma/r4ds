library(tidyverse)
library(lubridate)
library(nycflights13)

# This is the code from earlier to make the df we'll be using
make_datetime_100 <- function(year, month, day, time) {
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

# You can get the components using year(), month(), mday() (day of month),
#   yday() (day of the year), wday() (day of the week), hour(), minute(), and second()
datetime <- ymd_hms("2016-07-08 12:34:56")

year(datetime)
month(datetime)
mday(datetime)
yday(datetime)
wday(datetime)

# For month() or wday() you can turn the label and abbreviation on or off
month(datetime, label = TRUE)
wday(datetime, label = TRUE, abbr = FALSE)

# With this we can see which days of the week are most popular
flights_dt %>% 
  mutate(wday = wday(dep_time, label = TRUE)) %>% 
  ggplot(aes(x = wday)) +
  geom_bar()

# If you look at mean dep delay by minute in the hour, it looks like flights leaving
#   at 20-30min and 50-60min have much lower delays
flights_dt %>%
  mutate(minute = minute(dep_time)) %>%
  group_by(minute) %>%
  summarise(
    ave_delay = mean(dep_delay, na.rm = TRUE),
    n = n()) %>%
  ggplot(aes(minute, ave_delay)) +
  geom_line()

# This patten doesn't hold true for scheduled departure time
sched_dep <- flights_dt %>%
  mutate(minute = minute(sched_dep_time)) %>%
  group_by(minute) %>%
  summarise(
    ave_delay = mean(dep_delay, na.rm = TRUE),
    n = n())

ggplot(sched_dep, aes(minute, ave_delay)) +
  geom_line()

# This is because people have a bias towards recording leavings at "round" times
ggplot(sched_dep, aes(minute, n)) +
  geom_line()

# You can round the components to a nearby unit of time
#   This is done with fllor_date(), round_date(), and ceiling_date()
flights_dt %>% 
  count(week = floor_date(dep_time, "week")) %>% 
  ggplot(aes(week, n)) +
  geom_line()

# You can also manually change the componenets of a datetime
(datetime <- ymd_hms("2016-07-08 12:34:56"))

year(datetime) <- 2020
datetime
month(datetime) <- 01
datetime
hour(datetime) <- hour(datetime) + 1
datetime

# You can also modify multiple components with update()
update(datetime, year = 2020, month = 2, mday = 2, hour = 2)

# Values that're too big will roll over
ymd("2015-02-01") %>% 
  update(mday = 30)

ymd("2015-02-01") %>% 
  update(hour = 400)

# An example of this would be setting all the days to the same value so we can
#   see the distribution over the day for the whole year
flights_dt %>%
  mutate(dep_hour = update(dep_time, yday = 1)) %>%
  ggplot(aes(dep_hour)) +
  geom_freqpoly(binwidth = 300)


#### Questions ####
# 1. How does the distribution of flight times within a day change over the course of the year?
# Lets plot the same thing as above but with the months in different colours
flights_dt %>%
  filter(!is.na(dep_time)) %>%
  mutate(dep_hour = update(dep_time, yday = 1)) %>%
  mutate(month = factor(month(dep_time))) %>%
  ggplot(aes(dep_hour, color = month)) +
  geom_freqpoly(binwidth = 60 * 60)

# Feb has fewer flights because it has fewer days, so we need to normalise our data
flights_dt %>%
  filter(!is.na(dep_time)) %>%
  mutate(dep_hour = update(dep_time, yday = 1)) %>%
  mutate(month = factor(month(dep_time))) %>%
  ggplot(aes(dep_hour, color = month)) +
  geom_freqpoly(aes(y = ..density..), binwidth = 60 * 60)
# Doesn't look like there's much variation

# 2. Compare dep_time, sched_dep_time and dep_delay. Are they consistent? Explain your findings
# If they're consistent, dep_time = sched_dep_time + dep_delay
flights_dt %>%
  mutate(dep_time_ = sched_dep_time + dep_delay * 60) %>%
  filter(dep_time_ != dep_time) %>%
  select(dep_time_, dep_time, sched_dep_time, dep_delay)
# That isn't what we find, these are from cases where the delay has crossed over into a new day
# Our function for creating datetimes didn't account for this

# 3. Compare air_time with the duration between the departure and arrival. Explain your findings.
# They're often quite different, but I'm not sure why, it happens in both directions
flights_dt %>%
  mutate(
    flight_duration = as.numeric(arr_time - dep_time),
    air_time_mins = air_time,
    diff = flight_duration - air_time_mins
  ) %>%
  select(origin, dest, flight_duration, air_time_mins, diff)

# 4. How does the average delay time change over the course of a day? 
#   Should you use dep_time or sched_dep_time? Why?
# sched_dep_time is better because it's more useful for someone booking a flight
#   also, dep_time will be later on average as flights are pushed back
flights_dt %>%
  mutate(sched_dep_hour = hour(sched_dep_time)) %>%
  group_by(sched_dep_hour) %>%
  summarise(dep_delay = mean(dep_delay)) %>%
  ggplot(aes(y = dep_delay, x = sched_dep_hour)) +
  geom_point() +
  geom_smooth()

# 5. On what day of the week should you leave if you want to minimize the chance of a delay?
# Saturday has both the lowest dep delays and arr delays
flights_dt %>%
  mutate(dow = wday(sched_dep_time)) %>%
  group_by(dow) %>%
  summarise(
    dep_delay = mean(dep_delay),
    arr_delay = mean(arr_delay, na.rm = TRUE)
  ) %>%
  print(n = Inf)

flights_dt %>%
  mutate(wday = wday(dep_time, label = TRUE)) %>% 
  group_by(wday) %>% 
  summarize(ave_dep_delay = mean(dep_delay, na.rm = TRUE)) %>% 
  ggplot(aes(x = wday, y = ave_dep_delay)) + 
  geom_bar(stat = "identity")

flights_dt %>% 
  mutate(wday = wday(dep_time, label = TRUE)) %>% 
  group_by(wday) %>% 
  summarize(ave_arr_delay = mean(arr_delay, na.rm = TRUE)) %>% 
  ggplot(aes(x = wday, y = ave_arr_delay)) + 
  geom_bar(stat = "identity")

# 6. What makes the distribution of diamonds$carat and flights$sched_dep_time similar?
ggplot(diamonds, aes(x = carat)) +
  geom_density()

# Both have abnormally high values at nice, round human-friendly values
# For carats this is 0, 1/3, 1/2, and 2/3
ggplot(diamonds, aes(x = carat %% 1 * 100)) +
  geom_histogram(binwidth = 1)

# For dep times, it's 00 and 30 minutes, and then minutes ending in 0 or 5
ggplot(flights_dt, aes(x = minute(sched_dep_time))) +
  geom_histogram(binwidth = 1)

# 7. Confirm my hypothesis that the early departures of flights in minutes 20-30 and 50-60 
#   are caused by scheduled flights that leave early. 
#   Hint: create a binary variable that tells you whether or not a flight was delayed.
# The lowest proportion of flights leave early around 00 and 30
# (they interpreted it as the opposite but I'm pretty sure I'm right)
flights_dt %>% 
  mutate(minute = minute(dep_time),
         # Create a value called early which is 1 if it's early and 0 otherwise
         early = dep_delay < 0) %>% 
  # Then group by minute
  group_by(minute) %>% 
  summarise(
    # Calculate the proportion of flights that leave early
    early = mean(early, na.rm = TRUE),
    n = n()) %>% 
  # Plot the lot
  ggplot(aes(minute, early)) +
  geom_line()

