library(nycflights13)
library(tidyverse)

# Grouping doesn't just work with summarise(), it can also be combined with mutate() and filter()

# Reuse this smaller df from earlier
flights_sml <- flights %>%
  select(
    year:day, 
    ends_with("delay"), 
    distance, 
    air_time
  )

# Get the 10 worst flights on each day
flights_sml %>%
  group_by(year, month, day) %>%
  filter(rank(desc(arr_delay)) < 10)

# Get destinations with over 365 flights to them
popular_dests <- flights %>% 
  group_by(dest) %>% 
  filter(n() > 365)
popular_dests

vignette("window-functions")


#### Questions ####
# 1. What useful functions are affected by group?
# Aritmetric operators, modular aritmetic operators, logarithmic functions and logical comparisons are
# not affected by group
# Offset functions, rolling averages and rankings are affected by group

# 2. What plane (tailnum) has the worst on-time record?
# There are 110 flights which were always late, but those seem to have had a very low number of flights
flights %>%
  filter(!is.na(tailnum)) %>%
  mutate(on_time = !is.na(arr_time) & (arr_delay <= 0)) %>%
  group_by(tailnum) %>%
  summarise(on_time = mean(on_time), n = n()) %>%
  filter(n > 20) %>% # We can add a filter to include only planes with over 20 flights
  filter(min_rank(on_time) == 1)
# That gives us N988AT which was on time 18.9% of the time

# 20 flights is around the first quartile of the number of flights each plane takes
# Meaning just over 75% of planes had more than 20 flights
quantile(count(flights, tailnum)$n)

# 3. What time of day should you fly if you want to avoid delays as much as possible?
flights %>%
  group_by(hour) %>%
  summarise(arr_delay = mean(arr_delay, na.rm = TRUE)) %>%
  arrange(arr_delay)

# 4. For each destination, compute the total minutes of delay. 
# For each flight, compute the proportion of the total delay for its destination.
flights %>%
  filter(arr_delay > 0) %>%
  group_by(dest) %>%
  mutate(
    arr_delay_total = sum(arr_delay), # This works out the total minutes of delay for each destination
    arr_delay_prop = arr_delay / arr_delay_total # This calculates the proportion of that delay this flight caused
  ) %>%
  select(dest, month, day, dep_time, carrier, flight,
         arr_delay, arr_delay_prop, arr_delay_total) %>% # Select the variables we're intrested in
  arrange(dest, desc(arr_delay_prop)) # Arrange them by the proportion of delay they caused, largest first
  
# 5. Use lag() to explore how the delay of a flight is related to the delay of the flight before
lagged_delays <- flights %>%
  arrange(origin, month, day, dep_time) %>%
  group_by(origin) %>% # We want to group by where the planes are taking off from
  mutate(dep_delay_lag = lag(dep_delay)) %>% # This adds a variable with the delay of the flight before this one
  filter(!is.na(dep_delay), !is.na(dep_delay_lag))

# This lets us see that lag
select(lagged_delays, origin, dep_delay, dep_delay_lag)

# Now we can plot the relationship
# This shows the mean departure delay for every value of the previous flight's delay
lagged_delays %>%
  group_by(dep_delay_lag) %>% # Group flights by the delay of their previous flight
  summarise(dep_delay_mean = mean(dep_delay)) %>% # Take the mean delay for each group
  ggplot(aes(y = dep_delay_mean, x = dep_delay_lag)) + # Plot it
  geom_point() +
  scale_x_continuous(breaks = seq(0, 1500, by = 120)) + # Give the scale more ticks
  labs(y = "Departure Delay", x = "Previous Departure Delay") # Rename the labels

# 6. Look at each destination. Can you find flights that are suspiciously fast? 
# (i.e. flights that represent a potential data entry error).  
# To find unusual observations we want to standardise the scores by calculating z-scores
standardized_flights <- flights %>%
  filter(!is.na(air_time)) %>%
  group_by(dest, origin) %>% # We want to group by particular routes
  mutate(
    air_time_mean = mean(air_time), # Take the mean air time of each route
    air_time_sd = sd(air_time), # And the SD of the group's airtime
    n = n() # And the number of flights in that route
  ) %>%
  ungroup() %>% # Ungroup just because we don't need the group anymore
  mutate(air_time_standard = (air_time - air_time_mean) / (air_time_sd + 1)) # Compute a z-score for each flight
# We added 1 to the denomonator so we never divide by 0

# Plot the standardised flights
# The left tail are the flights we're interested in
ggplot(standardized_flights, aes(x = air_time_standard)) +
  geom_density()

# If we print the 10 fastest flights
standardized_flights %>%
  arrange(air_time_standard) %>%
  select(
    carrier, flight, origin, dest, month, day,
    air_time, air_time_mean, air_time_standard
  ) %>%
  head(10) %>%
  print(width = Inf)
# The fasest flight takes 65 min when it usually takes 114. 4.56 SDs above the mean
# However, we used mean and SD, which are very sensitive to outliers, which are exactly what we're looking for
# Using median and IQR will make us less sensitive to outliers

# We do the same thing as before but with the median and IQR
standardized_flights2 <- flights %>%
  filter(!is.na(air_time)) %>%
  group_by(dest, origin) %>%
  mutate(
    air_time_median = median(air_time),
    air_time_iqr = IQR(air_time),
    n = n(),
    air_time_standard = (air_time - air_time_median) / air_time_iqr)

# The characteristics of the plot are similar
ggplot(standardized_flights2, aes(x = air_time_standard)) +
  geom_density()

# Now the fastest flight is only 3.5 SD above the mean
standardized_flights2 %>%
  arrange(air_time_standard) %>%
  select(
    carrier, flight, origin, dest, month, day, air_time,
    air_time_median, air_time_standard
  ) %>%
  head(10) %>%
  print(width = Inf)
# This doesn't seem fast enough to be a data error, especially if we take into account plane speeds

# This shows the speed of our aircraft
# There are very few above 500mph, our fast one has a speed of 703, which isn't impossible
flights %>%
  mutate(mph = distance / (air_time / 60)) %>%
  ggplot(aes(x = mph)) +
  geom_histogram(binwidth = 10)

# The fast flights may have been speeding to make up time
# 5 of the top 10 were delayed at takeoff, and three of those were early at landing, so that makes sense
flights %>%
  mutate(mph = distance / (air_time / 60)) %>%
  arrange(desc(mph)) %>%
  select(
    origin, dest, mph, year, month, day, dep_time, flight, carrier,
    dep_delay, arr_delay
  )

# 7. Find all destinations that are flown by at least two carriers. 
# Use that information to rank the carriers.
# Essentially which airlines have the most destinations, only considering airports with multiple airlines
flights %>%
  # find all airports with > 1 carrier
  group_by(dest) %>%
  mutate(n_carriers = n_distinct(carrier)) %>%
  filter(n_carriers > 1) %>%
  # rank carriers by numer of destinations
  group_by(carrier) %>%
  summarize(n_dest = n_distinct(dest)) %>%
  arrange(desc(n_dest))

# EV of ExpressJet flies the most routes. Because the company operates small routes for other carriers
filter(airlines, carrier == "EV")

# 8. For each plane, count the number of flights before the first delay of greater than 1 hour
flights %>%
  # sort in increasing order
  select(tailnum, year, month,day, dep_delay) %>%
  filter(!is.na(dep_delay)) %>%
  arrange(tailnum, year, month, day) %>%
  group_by(tailnum) %>%
  # cumulative number of flights delayed over one hour
  mutate(cumulative_hr_delays = cumsum(dep_delay > 60)) %>%
  # count the number of flights == 0
  summarise(total_flights = sum(cumulative_hr_delays < 1)) %>%
  arrange(total_flights)


