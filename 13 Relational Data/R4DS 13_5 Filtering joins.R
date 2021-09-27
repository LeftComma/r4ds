library(tidyverse)
library(nycflights13)
library(fueleconomy)

# Filtering joins affect the observations rather than the joins
# semi_join(x, y) keeps all observations in x that have a match in y
# anti_join(x, y) drops all observations in x that have a match in y

# Semi-joins can help you match filtered tables back up to their originals
# For example if you've found the most popular destinations
top_dest <- flights %>%
  count(dest, sort = TRUE) %>%
  head(10)
top_dest

# Then to find the flights to fly to each dest, you could make the filter yourself
flights %>% 
  filter(dest %in% top_dest$dest)
# But that doesn't extend well to multiple variables

# semi_join() solves that problem for you
flights %>%
  semi_join(top_dest)

# Anti-joins are the opposite, and can be useful for finding mismatches between tables
# Say you want to find how many flights there are without a matching plane
flights %>%
  anti_join(planes, by = "tailnum") %>%
  count(tailnum, sort = TRUE)


#### Questions ####
# 1. What does it mean for a flight to have a missing tailnum? 
#   What do the tail numbers that don't have a matching record in planes have in common?
# Flights with a missing tailnum also have miss arr_time, meaning they were cancelled
flights %>%
  filter(is.na(tailnum), !is.na(arr_time)) %>%
  nrow()

# For tailnums that don't have matches in planes, about 90% are MQ or AA flights
flights %>%
  anti_join(planes, by = "tailnum") %>%
  count(carrier, sort = TRUE) %>%
  mutate(p = n / sum(n))
# These two companies report fleet numbers not tail numbers

# However, some tailnums from these carriers do match the planes dataset, which he can't explain
flights %>%
  distinct(carrier, tailnum) %>%
  left_join(planes, by = "tailnum") %>%
  group_by(carrier) %>%
  summarise(total_planes = n(),
            not_in_planes = sum(is.na(model))) %>%
  mutate(missing_pct = not_in_planes / total_planes) %>%
  arrange(desc(missing_pct))

# 2. Filter flights to only show flights with planes that have flown at least 100 flights.
popular_planes <- flights %>%
  count(tailnum, sort = TRUE) %>%
  na.exclude() %>%
  filter(n >= 100)

flights %>%
  semi_join(popular_planes, by = "tailnum")

# 3. Combine fueleconomy::vehicles and fueleconomy::common 
#   to find only the records for the most common models.
vehicles %>%
  semi_join(common)

# 4. Find the 48 hours (over the course of the whole year) that have the worst delays. 
#   Cross-reference it with the weather data. Can you see any patterns?
# The issue I have is grouping by 48 hour periods, I can't figure out how to do that
# Okay so he defines a lot of things
# 1 - We'll use departure delays
# 2 - "Worst" refers to average delay per flights for flights scheduled to leave in that hour
# 3 - We'll look for 48 not-necessarily contiguous hours. That fixes my problem
# First, get the 48 hours with the worst delays
worst_hours <- flights %>%
  mutate(hour = sched_dep_time %/% 100) %>%
  group_by(origin, year, month, day, hour) %>%
  summarise(dep_delay = mean(dep_delay, na.rm = TRUE)) %>%
  ungroup() %>%
  arrange(desc(dep_delay)) %>%
  slice(1:48)

# Then join it to weather
weather_most_delayed <- semi_join(weather, worst_hours, 
                                  by = c("origin", "year",
                                         "month", "day", "hour"))

# Then we can view it, and tbh the weather isn't that bad
select(weather_most_delayed, temp, wind_speed, precip) %>%
  print(n = 48)
ggplot(weather_most_delayed, aes(x = precip, y = wind_speed, color = temp)) +
  geom_point()

# 5. What does anti_join(flights, airports, by = c("dest" = "faa")) tell you?
anti_join(flights, airports, by = c("dest" = "faa"))
# All the destinations that aren't found in the airports table
# These are three Puerto Rican airports and one in the US Virgin Islands
# That's because of different definitions of what counts as "domestic"

# What does anti_join(airports, flights, by = c("faa" = "dest")) tell you?
anti_join(airports, flights, by = c("faa" = "dest"))
# All the airports with no flights from New York arriving at them

# 6. You might expect that there's an implicit relationship between plane and airline, 
#   because each plane is flown by a single airline. Confirm or reject this hypothesis 
#   using the tools you've learned above.
# I couldn't do this, this is his working
# Find distinct airline-plane combos
planes_carriers <- flights %>%
  filter(!is.na(tailnum)) %>%
  distinct(tailnum, carrier)

# Planes flying for multiple carriers will have their tailnum appear multiple times in this data
planes_carriers %>%
  count(tailnum) %>%
  filter(n > 1) %>%
  nrow()
# There are 17 of them

# Join them to the airlines data to get their info
carrier_transfer_tbl <- planes_carriers %>%
  # keep only planes which have flown for more than one airline
  group_by(tailnum) %>%
  filter(n() > 1) %>%
  # join with airlines to get airline names
  left_join(airlines, by = "carrier") %>%
  arrange(tailnum, carrier)

carrier_transfer_tbl