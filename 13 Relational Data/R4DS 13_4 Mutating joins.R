library(tidyverse)
library(nycflights13)

# A mutating join allows you to combine variables across two tables my matching
#   observations through their keys and then copying variables across

# Lets create a narrower dataset to view more easily
flights2 <- flights %>%
  select(year:day, hour, origin, dest, tailnum, carrier)

# Then we can add the carrier dataset using left_join()
flights2 %>%
  select(-origin, -dest) %>%
  left_join(airlines, by = "carrier")
# This adds another variable with name

# You could get the same result using the mutate function
# But this is a less clear and generalisable way to do it
flights2 %>%
  select(-origin, -dest) %>% 
  mutate(name = airlines$name[match(carrier, airlines$carrier)])


# Inner joins
# Lets first define two dataframes
x <- tribble(
  ~key, ~val_x,
  1, "x1",
  2, "x2",
  3, "x3"
)
y <- tribble(
  ~key, ~val_y,
  1, "y1",
  2, "y2",
  4, "y3"
)

# An inner join is the simplest join, it matches pairs of observations when they're equal
# Technically this is an inner equijoin (using the equality operator) but most joins are equijoins

# The output of this join is a df that has the key, the x values and the y values
x %>%
  inner_join(y, by = "key")
# Unmatched rows aren't included in an inner join, which means it's not very useful for analysis


# Outer joins
# There are three types of outer join:
#   A left join keeps all observations in x (this is the most commonly used join)
#   A right join keeps all observations in y
#   A full join keeps all observation in both


# Duplicate keys
# There are two possiblities when keys aren't unique
# 1. One table has duplicates. This can be useful for adding info with a one-to-many relationship
# Here, key is a primary key in y and a foreign key in x
x <- tribble(
  ~key, ~val_x,
  1, "x1",
  2, "x2",
  2, "x3",
  1, "x4"
)
y <- tribble(
  ~key, ~val_y,
  1, "y1",
  2, "y2"
)
left_join(x, y, by = "key")

# 2. Both tables have duplicate keys. This is usually an error because the keys don't
#   uniquely define an observation in either table.
#   When joining these tables you get all possible combinations (the Cartesian product)
x <- tribble(
  ~key, ~val_x,
  1, "x1",
  2, "x2",
  2, "x3",
  3, "x4"
)
y <- tribble(
  ~key, ~val_y,
  1, "y1",
  2, "y2",
  2, "y3",
  3, "y4"
)
left_join(x, y, by = "key")


# Defining the key columns
# There are three main ways to connect two tables
# The default (by = NULL) uses all variables that appear in both tables
#   This is known as the natural join
# Here it joins by year, month, day, hour and origin
flights2 %>% 
  left_join(weather)

# Or by a charactor vector (by = "x"), which only uses some of the common variables
# Here, flights and planes both use year but to mean different things, so we only want to join by tailnum
flights2 %>%
  left_join(planes, by = "tailnum")
# Both year values are included but with a suffix to show them apart

# Or by a named charactor vector (by c("a" = "b")) which matches variable a in table x
#   to variable b in table y. The variables from x will be used in the output
#   This is for when a variable is called different things in each table
# Here, we want to make a map of flights, so we need to match the lat and long to each
#   origin and destination.
# The airports df uses the ffa variable to store the airport code
# So we match origin and dest to the ffa variable
flights2 %>% 
  left_join(airports, c("dest" = "faa"))

flights2 %>% 
  left_join(airports, c("origin" = "faa"))


#### Questions ####
# 1. Compute the average delay by destination, then join on the airports data frame 
#   so you can show the spatial distribution of delays. 
#   Here's an easy way to draw a map of the United States:
# First, calculate average delays per destination airport
delays <- flights %>%
  group_by(dest) %>%
  summarise(mean_arr_delay = mean(arr_delay, na.rm = TRUE)) # I used arr_delay because we're talking about dest

# Then add it to the map code he gave us
airports %>%
  semi_join(flights, c("faa" = "dest")) %>%
  left_join(delays, c("faa" = "dest")) %>% # Use a left join to add the delay variable
  ggplot(aes(lon, lat)) +
  borders("state") +
  geom_point(aes(color = mean_arr_delay)) + # Add it as a color (size didn't really work)
  coord_quickmap()

# 2. Add the location of the origin and destination to flights
flights2 %>% 
  left_join(airports, c("dest" = "faa")) %>%
  left_join(airports, c("origin" = "faa")) %>%
  suffix = c("_origin", "_dest") %>% # Override the x and y suffixes
  select(year:lon.x, name.y:lon.y) # Don't keep the irrelevant rows

# 3. Is there a relationship between the age of a plane and its delays?
# Calculate the mean delay grouped by plane age, then plot it
flights %>%
  left_join(planes, by = "tailnum") %>%
  select(arr_delay, year.y) %>% # Only select the variables we're interested in
  group_by(year.y) %>% # Group by the year the plane was manufactured
  summarise(delay = mean(arr_delay, na.rm = TRUE)) %>%
  ggplot(aes(year.y, delay)) +
  geom_point()
# The answer is no, there doesn't seem to be a relationship between the two

# He found a very clear relationship, he used a different process but I can't
#   figure out why the results would be different from mine.
#   He found that delays increase up to 10 year-old planes and then decrease

# 4. What weather conditions make it more likely to see a delay?
# There are lots of features in weather than could make a delay more likely
# Ideal way to determine would be to run a multiple regression ***
# I'm just going to play around with it I think

# I wanted to run this as a loop but couldn't work it out
#for (x in c("temp", "visib", "pressue", "wind_speed", "wind_gust", "precip")) {
flights %>%
  left_join(weather) %>%
  select(arr_delay, temp:visib) %>%
  group_by(precip) %>%
  summarise(arr_delay = mean(arr_delay, na.rm = TRUE)) %>%
  ggplot(aes(precip, arr_delay)) +
  geom_point()
#}
  # temp might have a slight positive correlation but barely
  # Low visibility is associated with a higher arrival delay, in a hockey-stick shaped relationship
  # Low pressure is related to higher delays and massive variability
  # Higher wind spead means more delays and more variablility in delay
  # wind_gust has a slighy positive relationship with delay time
  # More precipitation means more delays and greater variability

# 5. What happened on June 13 2013? Cross reference it with the spatial pattern of delays
# There were severe thunderstorms across the southeast US
# This pattern can be seen using size and colour

# Use the same code from earlier
delays <- flights %>%
  filter(month == 6, day == 13) %>% # But filter to only include the day of interest
  group_by(dest) %>%
  summarise(mean_arr_delay = mean(arr_delay, na.rm = TRUE)) # I used arr_delay because we're talking about dest

# Then add it to the map code he gave us
airports %>%
  semi_join(flights, c("faa" = "dest")) %>%
  left_join(delays, c("faa" = "dest")) %>% # Use a left join to add the delay variable
  ggplot(aes(lon, lat)) +
  borders("state") +
  geom_point(aes(color = mean_arr_delay, size = mean_arr_delay)) + # Add it as a color (size didn't really work)
  coord_quickmap()

  