library(tidyverse)
library(modelr)

# Patterns point to systematic relationships between variables
# When you see a pattern, you could ask yourself:
#   Could this pattern be due to coincidence (i.e. random chance)?
#   How can you describe the relationship implied by the pattern?
#   How strong is the relationship implied by the pattern?
#   What other variables might affect the relationship?
#   Does the relationship change if you look at individual subgroups of the data?
  
# A scatterplot of the eruption length vs time between eruptions of old faithful shows that longer waits
#   are associated with longer eruptions. But it also shows two clusters
ggplot(data = faithful) + 
  geom_point(mapping = aes(x = eruptions, y = waiting))

# Models let us extract patterns from the data
# For example, it's hard to understand the relationship between cut and price, because cut and carat, 
#   and carat and price are tightly related
# But we could use a model to remove the effects of carat on the relationship between price and cut
# This model predicts price from carat
mod <- lm(log(price) ~ log(carat), data = diamonds)

# Then calculates the residuals
diamonds2 <- diamonds %>% 
  add_residuals(mod) %>% 
  mutate(resid = exp(resid))

# Plotting the residuals shows that as cut improves, price goes up, now carat has been taken care of
ggplot(data = diamonds2) + 
  geom_boxplot(mapping = aes(x = cut, y = resid))


# So far with ggplot2, we've been writing out the arguments explicily
ggplot(data = faithful, mapping = aes(x = eruptions)) + 
  geom_freqpoly(binwidth = 0.25)

# However, the inital arguments should be well known, and don't need to be written explicitly
# This means you can write the code more consicely, and see the differences between functions
ggplot(faithful, aes(eruptions)) + 
  geom_freqpoly(binwidth = 0.25)


