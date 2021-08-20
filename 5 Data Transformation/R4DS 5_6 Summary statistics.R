library(nycflights13)
library(tidyverse)

# summarise() summarises our data
summarise(flights, delay = mean(dep_delay, na.rm = TRUE))

# It only really works when combined with group_by()
by_day <- group_by(flights, year, month, day)
summarise(by_day, delay = mean(dep_delay, na.rm = TRUE))

# Piping is a way to rewrite code without creating variables at every stage
# It uses the symbol %>%, which can be read as 'then'
# So, if you want to look at the relationship between delay and distance to an airport, you could do this:
by_dest <- group_by(flights, dest) # First, group flights by destination
delay <- summarise(by_dest,
                   count = n(), 
                   dist = mean(distance, na.rm = TRUE),
                   delay = mean(arr_delay, na.rm = TRUE) # Then add a count, and mean dist and delay
)

delay <- filter(delay, count > 20, dest != "HNL") # Then filter the data to remove noise and an outlier

# A cleaner way of writing that same thing is using pipes
delays <- flights %>% # First we give the ending and starting data frames
  group_by(dest) %>% # Then we go stage by stage on what we need to do
  summarise(
    count = n(),
    dist = mean(distance, na.rm = TRUE),
    delay = mean(arr_delay, na.rm = TRUE)
  ) %>% 
  filter(count > 20, dest != "HNL")

# na.rm() removes NA values, which would otherwise ruin our summary statistics
# We could also remove all NA values, which here mean cancelled flights, before we summarise
not_cancelled <- flights %>% 
  filter(!is.na(dep_delay), !is.na(arr_delay))

not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(mean = mean(dep_delay))

# When aggregating, it's always good to include a count
# Here we're looking at delays grouped by type of plane, aka the tailnum
# We'll also include a count
delays <- not_cancelled %>%
  group_by(tailnum) %>%
  summarise(
    delay = mean(arr_delay),
    n = n()
  )

# Plotting the delays makes it look like there are some planes with an ave delay of 300 minutes (5 hours)
ggplot(data = delays, mapping = aes(x = delay)) +
  geom_freqpoly(binwidth = 10)

# However, look at number of flights vs ave delay, it shows there's massive variation when there's only
# a few flights, which is what you'd expect from random variation
ggplot(data = delays, mapping = aes(x = n, y = delay)) +
         geom_point(alpha = 1/10)

# So it's probably good to filter out the points with low numbers of observations
# Now you can see there's much less variation
delays %>%
  filter(n > 25) %>%
  ggplot(mapping = aes(x = n, y = delay)) +
  geom_point(alpha = 1/10)
# Ctrl + Alt + P resends the last block, so you can modify n and then run the block again easily
# Not sure why I'd use that, but I guess it's useful to know

# The way variation decreases as you get more data points can also be seen if you plot the batting average
# (hits / attempts) against the number of times the player bats (attempts)
# This uses the Lahman baseball dataset
# Convert to a tibble so it prints nicely
batting <- as_tibble(Lahman::Batting)

# Then group and summarise
batters <- batting %>%
  group_by(playerID) %>%
  summarise(
    ba = sum(H, na.rm = TRUE) / sum(AB, na.rm = TRUE),
    ab = sum(AB, na.rm = TRUE)
  )

# Then plot performance against amount of time batting
# You can see variation decreases as time batting increases
# Very high or very low performances tend to be through chance
batters %>% 
  filter(ab > 100) %>% 
  ggplot(mapping = aes(x = ab, y = ba)) +
  geom_point() + 
  geom_smooth(se = FALSE)

# This also explains why ranking wouldn't work for this dataset
# All of the highest people had a very low number of total hits, they were just lucky
batters %>% 
  arrange(desc(ba))


# Useful summary functions:
# Measures of location, like mean() or median()
# These can be combined with logical subsetting, here we're getting the average positive delay
not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(
    avg_delay1 = mean(arr_delay),
    avg_delay2 = mean(arr_delay[arr_delay > 0]) # the average positive delay
  )

# Measures of spread, sd(), IQR() or mad() - median absolute deviation
# Why is distance to some destinations more variable than to others?
not_cancelled %>% 
  group_by(dest) %>% 
  summarise(distance_sd = sd(distance)) %>% 
  arrange(desc(distance_sd))

# Measures of rank: min(x), max(x) quantile(x, 0.25)
# When do the first and last flights leave each day?
not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(
    first = min(dep_time),
    last = max(dep_time)
  )

# Measures of position: first(x), last(x), nth(x, 2)
# We can also use this to find the first and last departures each day
not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(
    first_dep = first(dep_time), 
    last_dep = last(dep_time)
  )

# Measures of count: n(), sum(!is.na(x)) which counts the number of non-missing values, and
# n_distinct(x), which counts the number of unique values
# Which destinations have the most carriers?
not_cancelled %>% 
  group_by(dest) %>% 
  summarise(carriers = n_distinct(carrier)) %>% 
  arrange(desc(carriers))

# Counts actually has its own dplyr variable
not_cancelled %>% 
  count(dest)

# You can also provide a weight, here we count (sum) the total number of miles a plane flew
not_cancelled %>%
  count(tailnum, wt = distance)

# Measures of count and proportions of logical values: sum(x > 10) or mean(y == 0)
# TRUE is 1 and FALSE is 0, sum gives the number of TRUEs in x and mean gives the proportion
# How many flights left before 5am? (these usually indicate delayed
# flights from the previous day)
not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(n_early = sum(dep_time < 500))

# What proportion of flights are delayed by more than an hour?
not_cancelled %>%
  group_by(year, month, day) %>%
  summarise(n_late = mean(arr_delay > 60))

# You can also group by multiple variables, moving up one level each time
daily <- group_by(flights, year, month, day)
(per_day <- summarise(daily, flights = n())) # The first layer counts the flights per day
# The brackets around them print the whole thing
(per_month <- summarise(per_day, flights = sum(flights))) # Then combining that into months
(per_year  <- summarise(per_month, flights = sum(flights))) # Then that into years
# You can't necessarily do this with ranked stats, like the median

# ungroup() removes grouping on a df
daily %>% 
  ungroup() %>%             # no longer grouped by date
  summarise(flights = n())  # all flights


#### Questions ####
# 1. How might you assess delay? arr_delay is probably more important than dep_delay
# The issue with delays is the cost to passengers, here, variation is worse than consistency,
# Because a consistent delay can be planned for
# Percentage of times the flight is delayed by more than x
# Mean delay
# Percentage of times the flight is on time

# 2. Rewrite this code not using count
not_cancelled %>% count(dest)
# An equivallent way of writing that:
not_cancelled %>%
  group_by(dest) %>%
  summarise(n = n())
# You could also do it with tally. count() is actually just a shortcut for group_by() %>% tally()
not_cancelled %>%
  group_by(dest) %>%
  tally()
# And again
not_cancelled %>% count(tailnum, wt = distance)
# An equivalent way:
not_cancelled %>%
  group_by(tailnum) %>%
  summarise(distance = sum(distance))
# You could use tally() here too, as any arguments to tally are summed
not_cancelled %>%
  group_by(tailnum) %>%
  tally(distance)

# 3. You should probably look at dep_time for cancellations, not delay like we did
# Also it should probably be and, not or
# is.na(dep_delay) | is.na(arr_delay)
# His answer is different, but I don't understand it

# 4. Is there a pattern in the number of cancelled flights per day?
# Yes, cancellations per day go up with total number of flights per day
cancelled_per_day <- 
  flights %>%
  mutate(cancelled = (is.na(arr_delay) | is.na(dep_delay))) %>%
  group_by(year, month, day) %>%
  summarise(
    cancelled_num = sum(cancelled),
    flights_num = n(),
  )
# I can't pipe to ggplot when I'm creating a variable, which makes sense
ggplot() +
geom_point(aes(x = flights_num, y = cancelled_num))

# Is the number of cancellations per day related to the average delay on that day?
# Yes, as mean delay time goes up, the number of cancellations also goes up
# There are two outliers though, on the 8/9th feb, with high cancellations but low ave delay
cancelled_and_delays <- 
  flights %>%
  mutate(cancelled = (is.na(arr_delay) | is.na(dep_delay))) %>% # Is a flight cancelled
  group_by(year, month, day) %>%
  summarise(
    cancelled_prop = mean(cancelled), # The proportion of cancelled flights
    avg_dep_delay = mean(dep_delay, na.rm = TRUE), # Departure delay
    avg_arr_delay = mean(arr_delay, na.rm = TRUE) # Arrival delay
  ) %>%
  ungroup() # Not sure what ungroup() is actually doing here, it doesn't seem to change the graphs

# The relationship is clear for departure delay
ggplot(cancelled_and_delays) +
  geom_point(aes(x = avg_dep_delay, y = cancelled_prop))
# And arrival delay
ggplot(cancelled_and_delays) +
  geom_point(aes(x = avg_arr_delay, y = cancelled_prop))

# 5. Which carrier has the worst delays? A: Frontier Airlines
not_cancelled %>%
  group_by(carrier) %>%
  summarise(delays = mean(arr_delay)) %>%
  arrange(desc(delays))
View(airlines)
# Can you disentange bad airports vs bad carriers?
# The best way to do this is to compare each carriers delay on a particular route, to the mean of
# all the other carriers delays on that group. This shows if it's much worse or not
flights %>%
  filter(!is.na(arr_delay)) %>% # Remove cancelled/redirected flights
  # Total delay by carrier within each route
  group_by(origin, dest, carrier) %>%
  summarise(
    arr_delay = sum(arr_delay),
    flights = n()
  ) %>%
  # Total delay within each route
  group_by(origin, dest) %>%
  mutate(
    arr_delay_total = sum(arr_delay),
    flights_total = sum(flights)
  ) %>%
  # average delay of each carrier - average delay of other carriers
  ungroup() %>%
  mutate(
    # For each flight/carrier it takes the total delay minus our delay, and divide that by the
    # total flights minus our flights, to get the mean delay of the others
    arr_delay_others = (arr_delay_total - arr_delay) / (flights_total - flights),
    arr_delay_mean = arr_delay / flights,
    arr_delay_diff = arr_delay_mean - arr_delay_others
  ) %>%
  # remove NaN values (when there is only one carrier)
  filter(is.finite(arr_delay_diff)) %>%
  # average over all airports it flies to
  group_by(carrier) %>%
  summarise(arr_delay_diff = mean(arr_delay_diff)) %>%
  arrange(desc(arr_delay_diff))  
# SkyWest Airlines has more delays than other carriers for the routes it flies

# 6. The sort argument to count() shows the largest groups at the top. You might do it instead of arranging
?count
