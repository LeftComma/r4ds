library("tidyverse")

# diamonds is another dataset in ggplot2

# This shows cut on the x-axis and count on the y-axis
# Count is a variable that geom_bar() has calculated
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut))

# Some graphs plot raw values, like scatterplots, others calculate new values
# Bar charts and histograms bin your data and then plot bin counts, the amount of data in each bin
# Smoothers fit a model to the data and then plot its predictions
# Boxplots calculate a summary of the distribution and display that

# A stat (short for statistical transformation) is the algorithm used to calculate new values
# for a graph

# You can see the stat that a geom uses by looking at its documentation
?geom_bar()

# Default geoms and stats can be plotted interchangably
# geom_bar() is the default geom for stat_count() and vice versa
ggplot(data = diamonds) + 
  stat_count(mapping = aes(x = cut))

# Usually you don't have to touch the stat, but there are three reasons to use stats explicitly
# 1. To override the default stat
# Here where the freq is already in the data, so you just want the height to be the raw y values
demo <- tribble(
  ~cut,         ~freq,
  "Fair",       1610,
  "Good",       4906,
  "Very Good",  12082,
  "Premium",    13791,
  "Ideal",      21551
)

ggplot(data = demo) +
  geom_bar(mapping = aes(x = cut, y = freq), stat = "identity")

# 2. You might want to override how the transformed variable is presented
# Here we're showing the counts as proportions, rather than raw counts
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, y = stat(prop), group = 1))

# 3. You might want to draw attention to the statistical transformation
# This shows attention to the range involved
ggplot(data = diamonds) + 
  stat_summary(
    mapping = aes(x = cut, y = depth),
    fun.min = min,
    fun.max = max,
    fun = median
  )


#### Questions ####
# 1. The default geom for stat_summary() is pointrange()
?stat_summary()
# Recreating the above plot the other way round. This was my (failed) attempt:
ggplot(data = diamonds)+
  geom_pointrange(
    mapping = aes(x = cut, y = median(depth), ymin = min(depth), ymax = max(depth)))
# This is his attempt:
ggplot(data = diamonds)+
  geom_pointrange(
    mapping = aes(x = cut, y = depth), # For mapping, don't need anything funny
    stat = 'summary', # Change the stat to the one we want
    fun.min = min, # Now set components of stats_identity like we did originally
    fun.max = max,
    fun = median
  )


# 2. geom_col() plots the raw data - uses stats_identity() - by default. It expects the height
# of the bars to be in the y axis
?geom_bar

# 3. Pairs of geoms and stats which are usually used together tend to have the same name
# Aside from that, most geoms use identity as their default stat, meaning the raw y values


# 4. stat_smooth() computes a model and plots a prediction from that
# It calculates the predicted value, the upper and lower CI levels and the SE
# It's governed by the method, formula (for custom methods) and a couple of other parameters
?stat_smooth

# 5. Without group = 1, the bars are all full height
# The issue is that the proportions are calculated within-groups, so each proportion is 100% of it's group
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, y = after_stat(prop)))
# For this one, you just need to add the group = 1 (idk why exactly)
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, y = after_stat(prop), group = 1))

ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = color, y = after_stat(prop)))
# For this one, the bars need to be normalised (no idea what the ..count.. does exactly)
# Presumably takes a count, but why the full stops?
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = color, y = ..count.. / sum(..count..)))
