library("tidyverse")

# Bars can also be coloured
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, colour = cut))
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = cut)) # Generally, fill is more useful

# Mapping the fill to another variable creates stacked bar charts
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = clarity))

# Stacking is a form of position adjustment. There are three other types of position adjustment
# Identity places objects exactly where they would be, making them overlapping
# This makes them hard to compare unless you reduce the opacity
ggplot(data = diamonds, mapping = aes(x = cut, fill = clarity)) + 
  geom_bar(alpha = 1/5, position = "identity")
ggplot(data = diamonds, mapping = aes(x = cut, colour = clarity)) + 
  geom_bar(fill = NA, position = "identity")

# Fill position does the same thing as stacking, but makes bars the same height
# This makes it easier to compare proportions
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = clarity), position = "fill")

# Dodge places them all side by side
# This makes it easier to compare individual amounts
ggplot(data = diamonds)+
  geom_bar(mapping = aes(x = cut, fill = clarity), position = "dodge")

# Jitter is a position adjustment which is useful for scatterplots
# This makes your graph less acurate locally, so it's more informative overall
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy), position = "jitter") # geom_jitter() also does this


#### Questions ####
# 1. That graph has overplotting, adding jitter would help
ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) + 
  geom_point(position = position_jitter()) # Adding jitter like this lets you adjust it

# 2. width and height control the amount of jittering
# They can be added in position_jitter() or geom_jitter()

# 3. geom_jitter() defaults the position to jitter
# geom_count() makes points larger if there are more datapoints there

# 4. dodge2 is the default position adjustment for boxplots
# This moves the plots sideways to ensure they don't overlap
# Plotting with identity instead causes them all to overlap
ggplot(data = mpg)+
  geom_boxplot(mapping = aes(x = drv, y = cty, color = class), position = "identity")
