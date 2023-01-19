library(tidyverse)

# This chapter is about transforming your graphs from being rough and ready to
# looking nice anc conveying your information well

# labs() adds labels
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = class)) +
  geom_smooth(se = FALSE) +
  labs(title = "Fuel efficiency generally decreases with engine size")

# Use titles that summarise the main finding, rather than just describe the plot

# Subtitles and captions can also be useful
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = class)) +
  geom_smooth(se = FALSE) +
  labs(
    title = "Fuel efficiency generally decreases with engine size",
    subtitle = "Two seaters (sports cars) are an exception because of their light weight",
    caption = "Data from fueleconomy.gov"
  )

# labs() canalso replace axis and legend titles
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(colour = class)) +
  geom_smooth(se = FALSE) +
  labs(
    x = "Engine displacement (L)",
    y = "Highway fuel economy (mpg)",
    colour = "Car type"
  )

# It's even possible to use equations instead of strings
df <- tibble(
  x = runif(10),
  y = runif(10)
)
ggplot(df, aes(x, y)) +
  geom_point() +
  labs(
    x = quote(sum(x[i] ^ 2, i == 1, n)),
    y = quote(alpha + beta + frac(delta, theta))
  )

#### Questions ####
# 1. Create one plot on the fuel economy data with customised title, subtitle, 
# caption, x, y, and colour labels.
labels = c("2 Seater", "Compact", "Mid-size", "Minivan", "Pickup Truck", "Sub-compact", "SUV")
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = class)) +
  geom_smooth(se = FALSE) +
  labs(
    title = "Fuel efficiency generally decreases with engine size",
    subtitle = "Two seaters (sports cars) are an exception because of their light weight",
    caption = "Data from fueleconomy.gov",
    x = "Engine displacement (L)",
    y = "Highway fuel economy (mpg)",
    colour = "Car type"
  ) +
  scale_colour_discrete(labels = labels)

# Or...
ggplot(
  data = mpg,
  mapping = aes(x = fct_reorder(class, hwy), y = hwy)
) +
  geom_boxplot() +
  coord_flip() +
  labs(
    title = "Compact Cars have > 10 Hwy MPG than Pickup Trucks",
    subtitle = "Comparing the median highway mpg in each class",
    caption = "Data from fueleconomy.gov",
    x = "Car Class",
    y = "Highway Miles per Gallon"
  )


# 2. The geom_smooth() is somewhat misleading because the hwy for large engines is skewed upwards 
# due to the inclusion of lightweight sports cars with big engines. Use your modelling tools to 
# fit and display a better model.

# You could plot this all as one group
labels = c("2 Seater", "Compact", "Mid-size", "Minivan", "Pickup Truck", "Sub-compact", "SUV")
ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    title = "Fuel efficiency generally decreases with engine size",
    caption = "Data from fueleconomy.gov",
    x = "Engine Displacement (L)",
    y = "Highway Fuel Economy (mpg)",
  ) +
  scale_colour_discrete(labels = labels)

# Or plot a different line for each class of car
ggplot(mpg, aes(displ, hwy, colour = class)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    title = "Fuel Efficiency Mostly Varies by Car Class",
    subtitle = "Subcompact caries fuel efficiency varies by engine size",
    caption = "Data from fueleconomy.gov",
    y = "Highway Miles per Gallon",
    x = "Engine Displacement"
  )
# This shows that subcompact cars have the strongest correlation between efficiency and engine

# Or you can run a regression of fuel efficiency on car class. And then plot the residuals against
# engine displacement. This effectively looks at the relationship after accounting for car class
mod <- lm(hwy ~ class, data = mpg)
mpg %>%
  add_residuals(mod) %>%
  ggplot(aes(x = displ, y = resid)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    title = "Engine size has little effect on fuel efficiency",
    subtitle = "After accounting for car class",
    caption = "Data from fueleconomy.gov",
    y = "Highway MPG Relative to Class Average",
    x = "Engine Displacement"
  )
# And it shows that there's a much weaker relationship after class is accounted for


# 3. Take an exploratory graphic that you've created in the last month, 
# and add informative titles to make it easier for others to understand.

# Tbh... I don't have one
