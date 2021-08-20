library(tidyverse)

# There are two options for what to do with unusual values
# You could drop the entire row with stange values
diamonds2 <- diamonds %>% 
  filter(between(y, 3, 20))
# The issue with this is it can remove other, valid measurements,
# and if your data is low quality, you can end up removing a lot of it once you've fixed every variable

# The alternative is to replace the unusual values with missing data, using mutate() and ifelse()
# ifelse() has three arguments, the first is a logic argument, to select the data
# The second tells you what should be put there when the test is true
# The third tells you what to put there when the test is false
diamonds2 <- diamonds %>%
  mutate(y = ifelse(y < 3 | y > 20, NA, y))

# ggplot will let you know if you're doing something with missing values by showing a warning
ggplot(data = diamonds2, mapping = aes(x = x, y = y)) + 
  geom_point() # Add na.rm = TRUE to supress the warning

# Sometimes having missing values is important, like in the flights data, where it indicates a cancelled flight
# You could make that into a new variable showing whether the flight was cancelled
nycflights13::flights %>% 
  mutate(
    cancelled = is.na(dep_time),
    sched_hour = sched_dep_time %/% 100, # Extracting hours and minutes from the time
    sched_min = sched_dep_time %% 100,
    sched_dep_time = sched_hour + sched_min / 60 # Then combining them and converting into hours
  ) %>% 
  ggplot(mapping = aes(sched_dep_time)) +
  geom_freqpoly(mapping = aes(colour = cancelled), binwidth = 1/4)
# This plot isn't great because the non-cancelled flights crowd out the cancelled ones


#### Questions ####
# 1. What happens to missing values in a histogram? What happens to missing values in a bar chart? 
# Why is there a difference?
# They both seem to remove rows containing missing values. I can't see a difference
ggplot(data = diamonds2, mapping = aes(x = y)) +
  geom_histogram(binwidth = 1)
  #geom_bar()

# The difference is, for categorical data, NA values can be treated as another category, and so be included
diamonds %>%
  mutate(cut = if_else(runif(n()) < 0.1, NA_character_, as.character(cut))) %>%
  ggplot() +
  geom_bar(mapping = aes(x = cut))


# 2. What does na.rm = TRUE do in mean() and sum()
# Removes NA values to stop the outcome being NA

