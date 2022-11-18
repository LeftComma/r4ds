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


## Residuals









