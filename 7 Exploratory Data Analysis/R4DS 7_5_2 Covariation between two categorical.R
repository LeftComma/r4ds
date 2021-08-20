library(tidyverse)
library(nycflights13)

# Comparing two categorical variables involves counting each combination
# You can do this with geom_count()
ggplot(data = diamonds) +
  geom_count(mapping = aes(x = cut, y = color))

# Or count with dplyr
diamonds %>%
  count(color, cut) %>%
  # And then plot a heatmap
  ggplot(mapping = aes(x = color, y = cut)) +
    geom_tile(mapping = aes(fill = n))

#### Questions ####
# 1. How could you rescale the count dataset above to more clearly show the distribution of cut within colour, or colour within cut?
# Shows the distribution of colours within each cut
diamonds %>%
  count(color, cut) %>%
  group_by(cut) %>% # Group by the variable x
  mutate(prop = n / sum(n)) %>% # Work out the percentage of variable y in each grouping of x
  ggplot(mapping = aes(x = color, y = cut)) + # Plot it
  geom_tile(mapping = aes(fill = prop))

# Shows the distribution of cuts within each colour
diamonds %>%
  count(color, cut) %>%
  group_by(color) %>%
  mutate(prop = n / sum(n)) %>%
  ggplot(mapping = aes(x = color, y = cut)) +
  geom_tile(mapping = aes(fill = prop))

# 2. Use geom_tile() together with dplyr to explore how average flight delays vary by destination and month of year. 
#   What makes the plot difficult to read? How could you improve it?
# The y axis labels are a mess, the only solution I can think of is to make the graph much bigger
# Also, you can't really tell tile is which dest, interactivity would help with that
# Also it doesn't really reveal a huge amount in terms of patters, ordering might be able to help with that
flights %>%
  group_by(dest, month) %>%
  summarise(delay = mean(arr_delay, na.rm = TRUE)) %>%
  ggplot(mapping = aes(x = factor(month), y = dest)) + # factor(month) tells it that month is categorical
  geom_tile(mapping = aes(fill = delay)) +
  labs(x = "Month", y = "Destination", fill = "Departure Delay")

# He sorts destinations and removes missing values:
flights %>%
  group_by(month, dest) %>%                                 # This gives us (month, dest) pairs
  summarise(dep_delay = mean(dep_delay, na.rm = TRUE)) %>%
  group_by(dest) %>%                                        # group all (month, dest) pairs by dest ..
  filter(n() == 12) %>%                                     # and only select those that have one entry per month 
  ungroup() %>%
  mutate(dest = reorder(dest, dep_delay)) %>%               # Reorders dest by dep_delay
  ggplot(aes(x = factor(month), y = dest, fill = dep_delay)) +
  geom_tile() +
  labs(x = "Month", y = "Destination", fill = "Departure Delay")

# 3. Why is it better to use x = color, y = cut rather than x = cut and y = color in the graph above?
# There are more levels to color, so it's better suited for the y axis
ggplot(data = diamonds) +
  geom_count(mapping = aes(x = cut, y = color))
