library(tidyverse)
library(modelr)

# Here we're going to look at a model by looking at its predictions

# To visualise the predictions we want to start with a grid of values that cover where our data lies
# modelr::data_grid() does this. It takes a df, and then variables that it will generate all the combinations for
grid <- sim1 %>% 
  data_grid(x) 
grid

# Then we add predictions
# modelr::add_predictions() takes a df and model, then adds the model's predictions as a new column in the df
sim1_mod <- lm(y ~ x, data = sim1)

grid <- grid %>% 
  add_predictions(sim1_mod) 
grid

# Now we plot the predictions. The benefit of doing it this way is that we can visualise any model
ggplot(sim1, aes(x)) +
  geom_point(aes(y = y)) +
  geom_line(aes(y = pred), data = grid, colour = "red", size = 1)


# Residuals
# residuals are the aspects of the data that the model hasn't captured. They're what's left over.
# It's the distance between the predicted and actual values
# Here you can add them to a df
sim1 <- sim1 %>% 
  add_residuals(sim1_mod)
sim1

# There are multiple ways to interpret them
# You could plot a freq polygon
ggplot(sim1, aes(resid)) + 
  geom_freqpoly(binwidth = 0.5)

# You often want to actually plot the residuals
ggplot(sim1, aes(x, resid)) + 
  geom_ref_line(h = 0) +
  geom_point() 
# This looks like random noise, which suggests our model has done a good job


#### Questions ####
# 1. Instead of using lm() to fit a straight line, you can use loess() to fit a smooth curve. 
# Repeat the process of model fitting, grid generation, predictions, and visualisation on sim1 using loess() 
# instead of lm(). How does the result compare to geom_smooth()?
grid <- sim1 %>% 
  data_grid(x) 

sim1_mod <- sim1_mod <- loess(y ~ x, data = sim1)

grid <- grid %>% 
  add_predictions(sim1_mod) 

ggplot(sim1, aes(x)) +
  geom_point(aes(y = y)) +
  geom_line(aes(y = pred), data = grid, colour = "red", size = 1) +
  geom_smooth(aes(y = y), colour = "blue", se = FALSE)
# It turns at each point, and basically identically matches geom_smooth

# 2. add_predictions() is paired with gather_predictions() and spread_predictions(). 
# How do these three functions differ?
add_predictions()
# add_predictions adds a single new column
# spread_predictions adds a new column for each model
# gather_predictions adds two columns, and also adds the input rows again. It also lets you add multiple
# models by adding a variable with model name

# 3. What does geom_ref_line() do? What package does it come from? 
# Why is displaying a reference line in plots showing residuals useful and important?
geom_ref_line()
# It adds a horizontal or vertical reference line, and is from the modelr package
# This can make it easier to visualise if residuals are centred around 0

# 4. Why might you want to look at a frequency polygon of absolute residuals? 
# What are the pros and cons compared to looking at the raw residuals?
# It could make it easier to see the spread, because it effectively doubles the residuals
# You lose the ability to tell whether the distribution is the same above and below 0
