library(nycflights13)
library(tidyverse)

# mutate() always adds variables at the end, so we're gonna work with a smaller dataset
flights_sml <- select(flights, 
                      year:day, 
                      ends_with("delay"), 
                      distance, 
                      air_time
)

# mutate() requires the df, and what the new columns will be
mutate(flights_sml,
       gain = dep_delay - arr_delay,
       hours = air_time / 60,
       gain_per_hour = gain / hours # You can refer to columns you've just made
)

# transmute() only keeps the new variables
transmute(flights,
          gain = dep_delay - arr_delay,
          hours = air_time / 60,
          gain_per_hour = gain / hours
)

# There are lots of functions that work with mutate()
# They are all vectorised, they do the same thing to each
# value in a vector, and so output a vector of the same length
# as the one they were given

# Arithmetic operators: +, -, *, /, ^

# Modular arithmetic: %/% integer division, %% remainder
# Lets you break up integers
transmute(flights,
          dep_time,
          hour = dep_time %/% 100,
          minute = dep_time %% 100
)

# Logs: log(), log2(), log10()

# Offsets: lead() and lag() let you offset a vector forwards or backwards

# Cumulative aggregates: cumsum(), cummean() etc. Rolling aggregates can be found in the RcppRoll package

# Logical comparisons: <. >, != etc

# Ranking: e.g. min_rank() gives the smallest values the samllest rank
# there are also a lot of other ranking functions
# We'll create a tibble
rankme <- tibble(x = c(10, 5, 1, 5, 5))

# Add a few types of rank so we can compare them
rankme <- mutate(rankme,
                 x_row_number = row_number(x),
                 x_min_rank = min_rank(x),
                 x_dense_rank = dense_rank(x),
                 x_desc_min_rank = min_rank(desc(x)),
                 x_percent_rank = percent_rank(x),
                 x_cume_dist = cume_dist(x)
)

arrange(rankme, x)


#### Questions ####
View(flights)
# 1. Convert dep_time to minutes since midnight
# The %% 1440 converts midnight to 0 while leaving everything else the same
# This would be a good place for a function to reduce retyping
flights_times <- mutate(flights,
                        dep_time_mins = (dep_time %/% 100 * 60 + dep_time %% 100) %% 1440,
                        sched_dep_time_mins = (sched_dep_time %/% 100 * 60 +
                                               sched_dep_time %% 100) %% 1440
)

# Then we show the important factors
select(
  flights_times, dep_time, dep_time_mins, sched_dep_time,
  sched_dep_time_mins
)

# 2. These should be the same
# Here we've converted time into minute form like above
flights_airtime <- mutate(flights,
                          dep_time = (dep_time %/% 100 * 60 + dep_time %% 100) %% 1440,
                          arr_time = (arr_time %/% 100 * 60 + arr_time %% 100) %% 1440,
                          air_time_diff = air_time - arr_time + dep_time
)

# This checks the number of rows for which the two variables are different, it should be none, but it's a lot
nrow(filter(flights_airtime, air_time_diff != 0))
# This might be because flights go past midnight or cross time zones

# If that's the case, a histogram would show spikes at 60 minute increments, as the hours change
ggplot(flights_airtime, aes(x = air_time_diff)) +
  geom_histogram(binwidth = 1)
# That explains part of the issue, but there's still a lot of error that's unaccounted for
# Looking at the documentation we can see that the air_time doesn't include taxiing, which is why the
# variables differ

# 3. The departure time should be equal to the scheduled time plus the delay 
# First convert to minutes, as always, and make our new variable
flights_deptime <- mutate(flights,
         dep_time_min = (dep_time %/% 100 * 60 + dep_time %% 100) %% 1440,
         sched_dep_time_min = (sched_dep_time %/% 100 * 60 + sched_dep_time %% 100) %% 1440,
         dep_delay_diff = dep_delay - dep_time_min + sched_dep_time_min
)

# However, there are a lot of rows where it isn't equal
nrow(filter(flights_deptime, dep_delay_diff != 0))
# Time zones can't be at play, but delays crossing midnight might be responsible

# We can plot the data to see if that's true
# This graph shows that all delays that aren't zero are exactly 1440 (24 hours)
# And, the scheduled depart time is later in the day, so it's not a midnight problem
# The issue is a quirk of how the data was stored
ggplot(filter(flights_deptime, dep_delay_diff > 0),
       aes(y = sched_dep_time_min, x = dep_delay_diff)
) +
  geom_point()

# 4. Finds the most delayed flight
# Add a variable that ranks flights by delay, here we'll use min_rank()
flights_delayed <- mutate(flights, dep_delay_min_rank = min_rank(desc(dep_delay)))

# Filter to select only the variables with a rank of 10 or less
flights_delayed <- filter(flights_delayed, !(dep_delay_min_rank > 10))

# Arrange the df by rank
flights_delayed <- arrange(flights_delayed, dep_delay_min_rank)

# Print a few of the columns
print(select(flights_delayed, month, day, carrier, flight, dep_delay, 
             dep_delay_min_rank),
      n = Inf)

# You could also do it with arrange() and slice()
flights_delayed2 <- arrange(flights, desc(dep_delay))
flights_delayed2 <- slice(flights_delayed2, 1:10)
select(flights_delayed2,  month, day, carrier, flight, dep_delay)

# Or with top_n()
flights_delayed3 <- top_n(flights, 10, dep_delay)
flights_delayed3 <- arrange(flights_delayed3, desc(dep_delay))
select(flights_delayed3, month, day, carrier, flight, dep_delay)
# Those two methods will only ever select 10 items, so aren't good if you have ties

# 5. The shorter vector loops (is recycled) to make sure they're the same length
# It also throws up a warning because this happening is usually a mistake
1:3 + 1:10

# 6. R provides the primary Trig functions: sin(), cos(), tan(). These are done in radians
# It's often easier to talk about radians as multiples of pi, so there are sinpi(), cospi() and tanpi()
# It also provides arc functions acos(), asin(), and atan()
# Finally it has atan2(), returning the angle between the x axis and a vector
?sin # This gives you the info on all the trig functions
