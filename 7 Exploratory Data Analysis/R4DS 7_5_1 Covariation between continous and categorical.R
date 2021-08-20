library(tidyverse)
library(ggstance)
library(lvplot)
library(ggbeeswarm)

# Covariation can be between a categorical and continous variable
# The default geom_freqpoly() doesn't show this well because hight is determined by count,
# which can make the shape hard to see
ggplot(data = diamonds, mapping = aes(x = price)) + 
  geom_freqpoly(mapping = aes(colour = cut), binwidth = 500)

# Displaying density instead of count means the area under each graph is 1, making comparisons easier
ggplot(data = diamonds, mapping = aes(x = price, y = ..density..)) + 
  geom_freqpoly(mapping = aes(colour = cut), binwidth = 500)
# It seems like the lowest quality of cut has the highest average price

# Boxplots are another way to view continous x categorical covariance
ggplot(data = diamonds, mapping = aes(x = cut, y = price)) +
  geom_boxplot()

# Many categorical plots don't have a specific order
ggplot(data = mpg, mapping = aes(x = class, y = hwy)) +
  geom_boxplot()

# You can order them by using reorder()
ggplot(data = mpg) +
  geom_boxplot(mapping = aes(x = reorder(class, hwy, FUN = median), y = hwy)) +
  coord_flip() # Flipping by 90 degrees can help if the names are long


#### Questions ####
# 1. Improve the visualisation of the departure times of cancelled vs. non-cancelled flights
# Recreate out cancellation df from before
cancellations <- nycflights13::flights %>% 
  mutate(
    cancelled = is.na(dep_time),
    sched_hour = sched_dep_time %/% 100, # Extracting hours and minutes from the time
    sched_min = sched_dep_time %% 100,
    sched_dep_time = sched_hour + sched_min / 60 # Then combining them and converting into hours
  )

# Plot it using desnsity, which shows that cancelled flights are more likely to happen in the afternoon
ggplot(data = cancellations, mapping = aes(x = sched_dep_time, y = ..density..)) +
  geom_freqpoly(mapping = aes(colour = cancelled), binwidth = 1/2)

# This is a worse way to display it than above but I feel gets the same idea across
ggplot(data = cancellations, mapping = aes(x = cancelled, y = sched_dep_time)) +
  geom_boxplot()

# 2. What variable in the diamonds dataset is most important for predicting the price of a diamond? 
# How is that variable correlated with cut? 
# Why does the combination of those two relationships lead to lower quality diamonds being more expensive?
# I'm predicting size determines price, and low cuts tend to be bigger and so more expensive
# Color and clarity are both categorical
# E is the cheapest colour, and J is the most expensive
ggplot(data = diamonds) +
  geom_boxplot(mapping = aes(x = reorder(color, price, FUN = median), y = price))
# IF is the cheapest clarity and SI2 is the most expensive
ggplot(data = diamonds) +
  geom_boxplot(mapping = aes(x = reorder(clarity, price, FUN = median), y = price))

# Compare the quality to the top and bottom colours
# 81% of Ideal (best cut) diamonds have the worst colour E, compared to the best colour J
# This compares to only 65% of Fair (worst cut) diamonds being E
# So, high cut diamonds may be cheaper because they're cheaper colours
diamonds %>%
  filter(color == "E" | color == "J") %>%
  filter(cut == "Fair" | cut == "Ideal") %>% 
  select(color, cut) %>%
  group_by(cut) %>%
  count(color) %>%
  mutate(percent = n / sum(n))

# Do the same thing to see if clarity is associated with cut
# 68% of Ideal diamonds have the highest clarity compared to the lowest clarity
# Compared to 98% of Fair diamonds having the highest clarity
# Clarity might also be driving this difference
diamonds %>%
  filter(clarity == "IF" | clarity == "SI2") %>%
  filter(cut == "Fair" | cut == "Ideal") %>% 
  select(clarity, cut) %>%
  group_by(cut) %>%
  count(clarity) %>%
  mutate(percent = n / sum(n))
# These are very quick and dirty methods, they don't account for all the middle values
# They also don't show direction, but they give a quick idea and I'm kinda proud of thinking them up

# 3. Install ggstance and create a horizontal boxplot. How does this compare to using coord_flip()?
# Plot with ggstance. You put whatever's on the x axis first
ggplot(mpg, aes(hwy, class, fill = factor(cyl))) +
  geom_boxploth()
# Same plot with ggplot. The order within each class is also reversed
ggplot(mpg, aes(class, hwy, fill = factor(cyl))) +
  geom_boxplot() +
  coord_flip()

# 4. Try using geom_lv() to display the distribution of price vs cut. What do you learn? How do you interpret the plots?
# They look like hot garbage honestly, like violin plots but worse
# They're useful for larger datasets because:
#   larger datasets can give precise estimates of quantiles beyond the quartiles
#   in expectation, larger datasets should have more outliers (in absolute numbers)
ggplot(data = diamonds, mapping = aes(x = cut, y = price)) +
  geom_lv()

# 5. Compare geom_violin(), a faceted geom_histogram(), and a coloured geom_freqpoly()
# Is best for looking at and comparing the actual shape of the distribution
ggplot(data = diamonds, mapping = aes(x = cut, y = price)) +
  geom_violin()
# Seperates them out clearly
ggplot(data = diamonds, mapping = aes(x = price)) +
  geom_histogram(binwidth = 100) +
  facet_wrap(~ cut)
  #facet_wrap(~cut, ncol = 1, scales = "free_y") # Another option for this one
# Better for comparing the count of each at any one price point
ggplot(data = diamonds, mapping = aes(x = price)) +
  geom_freqpoly(mapping = aes(color = cut))

# 6. The ggbeeswarm package provides a number of methods similar to geom_jitter(). 
# List them and briefly describe what each one does.
# geom_quasirandom() generates random points based on the distribution, like a jitter and violin plot combined
# There are several different methods for how exactly points should be generated
ggplot(data = mpg) +
  geom_quasirandom(mapping = aes(
    x = reorder(class, hwy, FUN = median),
    y = hwy
  ))

# geom_beeswarm() offsets the points within a package so they don't overlap
ggplot(data = mpg) +
  geom_beeswarm(mapping = aes(
    x = reorder(class, hwy, FUN = median),
    y = hwy
  ))
