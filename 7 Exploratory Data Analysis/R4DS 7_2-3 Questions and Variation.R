library(tidyverse)

# Exploratory Data Analysis (EDA) is fundamentally a creative process, without a clear set of steps
# It's about figuring out what your data can tell you, generating questions, testing them and repeating

# Two types of questions are often useful in EDA:
#   What type of variation occurs within my variables
#   What type of covariation occurs between my variables

# Terms:
# A Variable - a quantity, quality, or property that you can measure
# A Value - the state of the variable when you measure it, the value of a variable may change from measurement to measurement
# An Observation - A set of measurements made under similar conditions, (you usually make all of the 
#   measurements in an observation at the same time and on the same object). An observation will contain several 
#   values, each associated with a different variable. Sometimes referred to here as a data point
# Tabular Data - a set of values, each associated with a variable and an observation. 
#   Tabular data is tidy if each value is placed in its own "cell", each variable in its own column, 
#   and each observation in its own row.

# How you visualise distributions of the data depend on it's form
# Categorical data can only take a small set of values, and can often be visualised in a bar chart
ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut))
# Bar height is how many observations occured within the x value

# These can be computed with count()
diamonds %>%
  count(cut)

# Distribution of continuous variables can be done using histograms
ggplot(data = diamonds) +
  geom_histogram(mapping = aes(x = carat), binwidth = 0.5)

# This can be computed with count() and cut_width()
diamonds %>%
  count(cut_width(carat, 0.5))

# Binwidth can be adjusted to reveal different things about the data
# Zooming in on a subset of the data
smaller <- diamonds %>%
  filter(carat < 3)

# Using a smaller binwidth makes it look considerably different
ggplot(data = smaller, mapping = aes(x = carat)) +
  geom_histogram(binwidth = 0.1)

# Overlaying histograms on the same plot is messy
# geom_freqpoly() does the same thing but with lines, which are much easier to read when overlaid
ggplot(data = smaller, mapping = aes(x = carat, colour = cut)) +
  geom_freqpoly(binwidth = 0.1)


# Once you've visualised, there are follow-up questions you can ask
# These should be based on curiosity and skepticism
# Look for anything unexpected:
#   Which values are most common? Why?
#   Which values are rare? Why? Does this match your expectations?
#   Are there any unusual patterns? What might explain them?

# For example this histogram suggests several questions:
#   Why are more diamonds at whole carats and common fractions?
#   Why are there more diamonds to the right of each peak than the left?
ggplot(data = smaller, mapping = aes(x = carat)) +
  geom_histogram(binwidth = 0.01) +
  scale_x_continuous(breaks = seq(0, 3, by = 0.2))
# Clusters in your data suggest subgroups exist:
#   How are observations within clusters similar to each other and disimilar to other clusters?
#   How can you explain or describe the clusters?
#   Might the appearence of clusters be misleading


# Outliers are important because they're often entry errors or interesting new findings
# They can often be hard to see in a histogram
# Here, the only evidence of them is a strangly wide x axis
ggplot(diamonds) + 
  geom_histogram(mapping = aes(x = y), binwidth = 0.5)

# The outlier bins are too short for us to see them
# We can zoom in with coord_cartesian()
# coord_cartesian() adjusts axes limits without dropping data, xlim() and ylim() cause data outside the limits to be dropped
ggplot(diamonds) + 
  geom_histogram(mapping = aes(x = y), binwidth = 0.5) +
  coord_cartesian(ylim = c(0, 50))
# We can see three unusal values

# Lets extract them
unusual <- diamonds %>%
  filter(y < 3 | y > 20) %>%
  select(price, x:z) %>%
  arrange(y)
unusual
# y is a mm measurement of dimension, so we know the 0 values must be errors
# Relatively cheap diamons of 32 and 59 mm long also sound pretty implausible!


#### Questions ####
# 1. Explore the distribution of the x, y and z variables. How might you describe them as length, width and depth
# He does a lot of looking at outliers, which I'm not going to add
# Lets plot them all on the same graph using different colours
# We can see that x and y are essentially identical, whereas x is a lot lower
# Presuming cut diamonds are round, this implies that x and y are length and width, and z is depth
ggplot(data = smaller) +
  geom_freqpoly(mapping = aes(x = x), binwidth = 0.1, color = "red") +
  geom_freqpoly(mapping = aes(x = y), binwidth = 0.1, color = "blue") +
  geom_freqpoly(mapping = aes(x = z), binwidth = 0.1, color = "green") +
  coord_cartesian(xlim = c(0, 10))

# Okay, this isn't strictly to the question, but I wanted to know how to add a legend
# This is important because I originally thought green was x instead of z!
# One way is through scale_color_identity(), and that's what we'll do
ggplot(data = smaller) +
  geom_freqpoly(mapping = aes(x = x, color = "red"), binwidth = 0.1) + # Move the colours inside aes
  geom_freqpoly(mapping = aes(x = y, color = "blue"), binwidth = 0.1) +
  geom_freqpoly(mapping = aes(x = z, color = "green"), binwidth = 0.1) +
  coord_cartesian(xlim = c(0, 10)) +
  scale_color_identity(name = "Dimension", # We name our legend
                       breaks = c("red", "blue", "green"), # We identify the different colours
                       labels = c("x", "y", "z"), # We label them, so they don't just say "red" etc
                       guide = "legend") # Tell it to produce this as a legend

# 2. Explore the distribution of price. Do you discover anything unusual or surprising?
# Again, he goes into more depth than I do
# Most are low in cost and this tails off as prices rise
# At smaller binwidths you can see no diamonds with prices around $1,500
ggplot(data = smaller, mapping = aes(x = price)) +
  geom_histogram(binwidth = 10) +
  coord_cartesian(xlim = c(1000, 2000)) + # Zooming in to investigate further
  scale_x_continuous(breaks = seq(1000, 2000, by = 50)) + # Create finer ticks to identify the gap
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) # Rotate the ticks to make reading easier

# Based on the histogram we'll take a closer look at the data
odd_price <- diamonds %>%
  filter(price > 1450 & price < 1550) %>% # Lets pick a rough range based on what we can see
  arrange(price)
View(odd_price) # This shows no diamonds priced between 1454 and 1546, which is a very odd gap

# 3. How many diamonds are 0.99 carat? How many are 1 carat? What do you think is the cause of the difference?
# There are 1558 1 carat diamonds compared to 23 0.99 carat diamonds
diamonds %>%
  filter(carat == 0.99 | carat == 1) %>%
  count(carat)

# Looking at a slightly wider range, we can see that count decreases as carat approaches 1, and then jumps afterwards
diamonds %>%
  filter(carat >= 0.9, carat <= 1.1) %>%
  count(carat) %>%
  print(n = Inf)

# 4. Compare and contrast coord_cartesian() vs xlim() or ylim() when zooming in on a histogram.
# coord_cartesian() zooms in after the geom is calcualted and drawn
# xlim() and ylim() zoom in beforehand, and so influence the calculation of the stats
ggplot(data = smaller, mapping = aes(x = price)) +
  geom_histogram(binwidth = 10) +
  xlim(1000, 2000)
  #coord_cartesian(xlim = c(1000, 2000))
