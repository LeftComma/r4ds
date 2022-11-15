library(tidyverse)
library(modelr)
options(na.action = na.warn)

# Models provide summaries of data sets. In this book we'll split data into patterns and residuals
# This chapter will use only simulated data, to get a sense of how models themselves work

# There are two parts to a model:
# Define the family, that express a precise but generic pattern. Such as a straight line: y = mx + c
# Generate the fitted model, by selecting the parameters that best fit your data, e.g. y = 2x + 3

# Having a fitted model just means it's the one from that family that most closely links to your data,
# not that it's the best model, or 'true'

# "All models are wrong, but some are useful" - George Box

# sim1 is included in modelr
ggplot(sim1, aes(x, y)) +
  geom_point()
# This looks like a pretty linear relationship

# Lets generate a few straight lines and overlay them
# models contains 250 pairs of parameters
models <- tibble(
  a1 = runif(250, -20, 40),
  a2 = runif(250, -5, 5)
)

ggplot(sim1, aes(x, y)) + 
  geom_abline(aes(intercept = a1, slope = a2), data = models, alpha = 1/4) +
  geom_point() 
# So, a lot of them are terrible...

# We need to find the line that minimizes the distance between the line and the points
# To find this, we turn the model into a function, that takes two parameters and the x position of each point as inputs
# This spits out a y position based on the model parameters
model1 <- function(a, data) {
  a[1] + data$x * a[2]
}
# We can give it the parameters c = 7 and m = 1.5
model1(c(7, 1.5), sim1)

# Now we need to calculate the overall distance these points are from the real points
# We're going to use the root-mean-squared deviation
measure_distance <- function(mod, data) {
  diff <- data$y - model1(mod, data)
  sqrt(mean(diff ^ 2))
}
measure_distance(c(7, 1.5), sim1)

# We can use purrr to compute this distance for all the models we tried above
# We need to make this little helper function because our distance function expects the parameters
# to come in a vector of 2, rather than as seperate inputs
sim1_dist <- function(a1, a2) {
  measure_distance(c(a1, a2), sim1)
}

models <- models %>% 
  mutate(dist = purrr::map2_dbl(a1, a2, sim1_dist))
models

# Lets overlay the best 10, with their distance being shown by their colour
ggplot(sim1, aes(x, y)) + 
  geom_point(size = 2, colour = "grey30") + 
  geom_abline(
    aes(intercept = a1, slope = a2, colour = -dist), 
    data = filter(models, rank(dist) <= 10)
  )

# We can also think of the models as observations and show a scatter plot in parameter space
ggplot(models, aes(a1, a2)) +
  geom_point(data = filter(models, rank(dist) <= 10), size = 4, colour = "red") +
  geom_point(aes(colour = -dist))
# This can't directly compare to the data, but the distance can be seen in the colour
# The best 10 are highlighted in red

# But that was done with 250 random lines. We can be more systematic about it.
# Here we create a df from all combinations of 2 variables
# We chose only the space that above looked like it contained the best models
grid <- expand.grid(
  a1 = seq(-5, 20, length = 25),
  a2 = seq(1, 3, length = 25)
) %>% 
  mutate(dist = purrr::map2_dbl(a1, a2, sim1_dist))

# And we can do the same as we did before
grid %>% 
  ggplot(aes(a1, a2)) +
  geom_point(data = filter(grid, rank(dist) <= 10), size = 4, colour = "red") +
  geom_point(aes(colour = -dist)) 

# And the new best 10 look a lot better on the data
ggplot(sim1, aes(x, y)) + 
  geom_point(size = 2, colour = "grey30") + 
  geom_abline(
    aes(intercept = a1, slope = a2, colour = -dist), 
    data = filter(grid, rank(dist) <= 10)
  )

# You could just repeat this more and more precisely until you get the best fit
# But the Newton-Raphson search is a minimization technique that does it for you
# In R, it's done using optim(), which will work for any family of models
best <- optim(c(0, 0), measure_distance, data = sim1)
best$par

ggplot(sim1, aes(x, y)) + 
  geom_point(size = 2, colour = "grey30") + 
  geom_abline(intercept = best$par[1], slope = best$par[2])

# For linear models, you can use lm(), that are more mathematically precise, and faster
sim1_mod <- lm(y ~ x, data = sim1)
coef(sim1_mod)


#### Questions ####
# 1. One downside of the linear model is that it is sensitive to unusual values because the distance incorporates 
#   a squared term. Fit a linear model to the simulated data below, and visualise the results. Rerun a few times 
#   to generate different simulated datasets. What do you notice about the model?
sim1a <- tibble(
  x = rep(1:10, each = 3),
  y = x * 1.5 + 6 + rt(length(x), df = 2)
)

sim1a_mod <- lm(y ~ x, data = sim1a)

ggplot(sim1a, aes(x, y)) + 
  geom_point(size = 2, colour = "grey30") + 
  geom_abline(intercept = sim1a_mod$coefficients[1], slope = sim1a_mod$coefficients[2])
# Outliers can have an outsized effect on both the slope and intercept of the line

# 2. One way to make linear models more robust is to use a different distance measure. 
#   For example, instead of root-mean-squared distance, you could use mean-absolute distance.
#   Use optim() to fit this model to the simulated data above and compare it to the linear model
measure_distance <- function(mod, data) {
  diff <- data$y - model1(mod, data)
  mean(abs(diff))
}

best <- optim(c(0, 0), measure_distance, data = sim1a)

ggplot(sim1a, aes(x, y)) + 
  geom_point(size = 2, colour = "grey30") + 
  geom_abline(intercept = sim1a_mod$coefficients[1], slope = sim1a_mod$coefficients[2], colour = "red") +
  geom_abline(intercept = best$par[1], slope = best$par[2], colour = "blue")
# The second method is less influenced by outliers
# The solutions workbook suggests using rlm() and lqs() in the MASS package to fit robust linear models over using optim()

# 3. One challenge with performing numerical optimisation is that it's only guaranteed to find one local optimum. 
#   What's the problem with optimising a three parameter model like this?
model1 <- function(a, data) {
  a[1] + data$x * a[2] + a[3]
}
# The issue is that a[1] and a[3] can combine in an infinite number of ways to form a constant
# so depending on where your starting point is you'll get different parameters

