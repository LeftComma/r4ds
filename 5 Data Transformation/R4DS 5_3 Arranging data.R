library(nycflights13)
library(tidyverse)

# arrange() changes the order of rows
# It takes a df and column names or some other expression to sort by
arrange(flights, year, month, day) # Arranges by year, then month, then day

# desc() makes it sort in descending order
arrange(flights, desc(dep_delay))

# Missing values are always sorted at the end
df <- tibble(x = c(5, 2, NA))
arrange(df, x)
arrange(df, desc(x))


#### Questions ####
# 1. Sort so NA values are at the top
arrange(flights, desc(is.na(dep_time)), dep_time)

# 2. Sort flights to find the most delayed flights
arrange(flights, desc(dep_delay)) # 21 hours 41 minutes late!!

# 3. Find the fastest (highest speed) flights
glimpse(flights) # Find the variables we want in the df
arrange(flights, desc(distance / air_time))

# 4. Find the farthest and shortest flights
# By distance, shortest is 80miles from EWR to PHL. Longest is 4983 from JFK to HNL
glimpse(arrange(flights, desc(distance)))
