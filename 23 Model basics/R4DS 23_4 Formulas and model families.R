library(tidyverse)
library(modelr)

df <- tribble(
  ~y, ~x1, ~x2,
  4, 2, 5,
  5, 1, 6
)

# R uses formulas that are converted into equations
# y ~ x converts to y = a_1 + x * a_2 also known as y = mx + c
# model_matrix() lets you visualise this equation. Each column is associated with one coefficient
model_matrix(df, y ~ x1)
# R adds an intercept by having a column full of 1s. If you don't want this you have to drop it
model_matrix(df, y ~ x1 - 1)
# Adding more variables makes the matrix larger
model_matrix(df, y ~ x1 + x2)

# This formula notation is called "Wilkinson-Rogers notation"


# Categorical variables ---------------------------------------------------
# This is more complicated when working with a categorical variable because you can't multiply by a category
# But it converts it so 'sex' becomes 'sexmale' where 1 means yes and 0 means no
df <- tribble(
  ~ sex, ~ response,
  "male", 1,
  "female", 2,
  "other", 1
)
model_matrix(df, response ~ sex)
# It doesn't create a sexfemale column because this creates a column that is perfectly based on another column
# This means there's an infinite combination of models that would be equally fitted to the data
#   Interestingly, it can only do this in a binary 0/1 fashion
# If you have more than one option it will create multiple columns

# This is sim2 from modelr
ggplot(sim2) + 
  geom_point(aes(x, y))

# Lets fit a linear model
mod2 <- lm(y ~ x, data = sim2)

# And create predictions
grid <- sim2 %>% 
  data_grid(x) %>% 
  add_predictions(mod2)
grid
# What this does is create a mean for each category, because that minimised RMS distance

ggplot(sim2, aes(x)) + 
  geom_point(aes(y = y)) +
  geom_point(data = grid, aes(y = pred), colour = "red", size = 4)

# You can't make predictions about levels you didn't observe
# This can easily be done accidentally, so it's good to know what the error looks like
tibble(x = "e") %>% 
  add_predictions(mod2)


# Categorical x continuous interactions -----------------------------------
# Sim3 has this case
ggplot(sim3, aes(x1, y)) + 
  geom_point(aes(colour = x2))

# There are two possible models that can fit this
# + means each effect is independent of the others
mod1 <- lm(y ~ x1 + x2, data = sim3)
# * means they're dependent. And the main effects and interactions are included into the model
mod2 <- lm(y ~ x1 * x2, data = sim3)

# We have 2 predictors, and so need to give data_grid() both variables
# This lets it generate all unique combinations of x1 and x2
#   We can use gather_predictions() to add multiple models simultaneously
grid <- sim3 %>% 
  data_grid(x1, x2) %>% 
  gather_predictions(mod1, mod2)
grid

# We can use faceting to view both the models together
ggplot(sim3, aes(x1, y, colour = x2)) + 
  geom_point() + 
  geom_line(data = grid, aes(y = pred)) + 
  facet_wrap(~ model)
# The model that uses + has the same slope for each line, but difference intercepts
# The model with * has different slope and intercept for each line

# To determine which is better we can look at the residuals for each category and model
sim3 <- sim3 %>% 
  gather_residuals(mod1, mod2)

ggplot(sim3, aes(x1, resid, colour = x2)) + 
  geom_point() + 
  facet_grid(model ~ x2)
# mod1 is clearly missing some of the pattern in b, and to a lesser degree in c and d
# mod2 has residuals which look a lot more random
# These can be mathematical comparisons but we don't need to do it


# Continuous x continuous interaction -------------------------------------
# Lets do the same thing with two continuous variables
mod1 <- lm(y ~ x1 + x2, data = sim4)
mod2 <- lm(y ~ x1 * x2, data = sim4)

grid <- sim4 %>% 
  data_grid(
    x1 = seq_range(x1, 5), 
    x2 = seq_range(x2, 5) 
  ) %>% 
  gather_predictions(mod1, mod2)
grid

# seq_range() creates a regular sequence between the min and max number, rather than every combo
# This can apparently be a useful technique, presumably when you have a lot more values
# For seq_range():
# pretty = TRUE generates numbers that look good to the human eye
seq_range(c(0.0123, 0.923423), n = 5)
seq_range(c(0.0123, 0.923423), n = 5, pretty = TRUE)

# trim = 0.1 will trim 10% off the tails. This can be useful if you have long tails and want to focus on the centre
x1 <- rcauchy(100)
seq_range(x1, n = 5)
seq_range(x1, n = 5, trim = 0.10)
seq_range(x1, n = 5, trim = 0.25)

# expand = 0.1 is the opposite of trim
x2 <- c(0, 1)
seq_range(x2, n = 5)
seq_range(x2, n = 5, expand = 0.10)
seq_range(x2, n = 5, expand = 0.25)


# Lets visualise the model
# Two continuous variables creates a 3D surface of predictions
# We can visualise this with geom_tile
ggplot(grid, aes(x1, x2)) + 
  geom_tile(aes(fill = pred)) + 
  facet_wrap(~ model)

# This looks quite similar, but we're relatively bad at comparing shades like this
# This is like looking at it from the side rather than the top
ggplot(grid, aes(x1, pred, colour = x2, group = x2)) + 
  geom_line() +
  facet_wrap(~ model)
ggplot(grid, aes(x2, pred, colour = x1, group = x1)) + 
  geom_line() +
  facet_wrap(~ model)
# This clearly shows a difference between models
# Like before, the model with * has different slopes
# This kind of stuff can be quite tricky to visualise!
# Because we're doing this to explore, our models don't have to be perfect yet

# Transformations ---------------------------------------------------------
# You can transform in the model formula.
# e.g. log(y) ~ sqrt(x1) + x2 is transformed into log(y) = a_1 + a_2 * sqrt(x1) + a_3 * x2
# If you're using +, *, ^, or -, you need to wrap it in I() so R doesn't think it's defining the function
df <- tribble(
  ~y, ~x,
  1,  1,
  2,  2, 
  3,  3
)
# You can use model_matrix to compare them
model_matrix(df, y ~ x^2 + x)
model_matrix(df, y ~ I(x^2) + x)

# Transformations let you approximate non-linear functions
# Taylor's theorem says you can approximate any smooth function with an infinite sum of polynomials
# This means we can get practically smooth functions by using a lot of lines
# poly() lets us do that
model_matrix(df, y ~ poly(x, 2))
# But polynomials shoot off to positive or negative infinity outside of the data's range
# You can use the natural spline instead
model_matrix(df, y ~ splines::ns(x, 2))

# Let's see what that looks like when we try and approximate a non-linear function:
sim5 <- tibble(
  x = seq(0, 3.5 * pi, length = 50),
  y = 4 * sin(x) + rnorm(length(x))
)

ggplot(sim5, aes(x, y)) +
  geom_point()

# Lets fit 5 progressively more complex models
library(splines)
mod1 <- lm(y ~ ns(x, 1), data = sim5)
mod2 <- lm(y ~ ns(x, 2), data = sim5)
mod3 <- lm(y ~ ns(x, 3), data = sim5)
mod4 <- lm(y ~ ns(x, 4), data = sim5)
mod5 <- lm(y ~ ns(x, 5), data = sim5)

grid <- sim5 %>% 
  data_grid(x = seq_range(x, n = 50, expand = 0.1)) %>% 
  gather_predictions(mod1, mod2, mod3, mod4, mod5, .pred = "y")

ggplot(sim5, aes(x, y)) + 
  geom_point() +
  geom_line(data = grid, colour = "red") +
  facet_wrap(~ model)
# This can complement the advanced RM stuff I did on non-linear curve fitting and how to select between models
# A really clear issue is the extrapolation beyond the end of the data. Though this is a problem with any model

#### Questions ####
# 1. What happens if you repeat the analysis of sim2 using a model without an intercept. 
# What happens to the model equation? What happens to the predictions?
ggplot(sim2) + 
  geom_point(aes(x, y))

# With an intercept
mod2 <- lm(y ~ x, data = sim2)
# Without an intercept
mod2a <- lm(y ~ x - 1, data = sim2)
# Can also use + 0 instead of - 1 to remove the intercept

# The predictions are exactly the same
grid <- sim2 %>%
  data_grid(x) %>%
  spread_predictions(mod2, mod2a)
grid

# 2. Use model_matrix() to explore the equations generated for the models I fit to sim3 and sim4. 
# Why is * a good shorthand for interaction?
model_matrix(sim3, y ~ x1 + x2)
model_matrix(sim3, y ~ x1 * x2)


model_matrix(sim4, y ~ x1 + x2)
model_matrix(sim4, y ~ x1 * x2)
# * is good because it means to multiply, and an interaction is the product between the two factors

# We can confirm that the variables x1:x2b is the product of x1 and x2b
x4 <- model_matrix(sim4, y ~ x1 * x2)
all(x3[["x1:x2b"]] == (x3[["x1"]] * x3[["x2b"]]))

# 3. Using the basic principles, convert the formulas in the following two models into functions. 
# (Hint: start by converting the categorical variable into 0-1 variables.)
mod1 <- lm(y ~ x1 + x2, data = sim3)
model_matrix(sim3, y ~ x1 + x2)

# A conversion function would take one argument (a df with x1 and x2 columns) and return a df
# It's like a more specific version of model_matrix()
# For sim3, x1 is an integer and x2 is a factor with 4 levels
levels(sim3$x2)

# x1 is numeric and so doesn't change
# x2 can take one of the 4 levels. a is considered the default, for the others we need to make an explicit variable
model_matrix_mod1 <- function(.data) {
  mutate(.data,
         x2b = as.numeric(x2 == "b"),
         x2c = as.numeric(x2 == "c"),
         x2d = as.numeric(x2 == "d"),
         `(Intercept)` = 1
  ) %>%
    select(`(Intercept)`, x1, x2b, x2c, x2d)
}

# Lets apply it to sim3
model_matrix_mod1(sim3)

# You could make a more generic model that doesn't hard-code specific levels
model_matrix_mod1b <- function(.data) {
  # the levels of x2
  lvls <- levels(.data$x2)
  # drop the first level
  # this assumes that there are at least two levels
  lvls <- lvls[2:length(lvls)]
  # create an indicator variable for each level of x2
  for (lvl in lvls) {
    # new column name x2 + level name
    varname <- str_c("x2", lvl)
    # add indicator variable for lvl
    .data[[varname]] <- as.numeric(.data$x2 == lvl)
  }
  # generate the list of variables to keep
  x2_variables <- str_c("x2", lvls)
  # Add an intercept
  .data[["(Intercept)"]] <- 1
  # keep x1 and x2 indicator variables
  select(.data, `(Intercept)`, x1, all_of(x2_variables))
}

model_matrix_mod1b(sim3)


# This is the second equation
mod2 <- lm(y ~ x1 * x2, data = sim3)

# As before, a simple converter function hard-codes levels of x2
model_matrix_mod2 <- function(.data) {
  mutate(.data,
         `(Intercept)` = 1,
         x2b = as.numeric(x2 == "b"),
         x2c = as.numeric(x2 == "c"),
         x2d = as.numeric(x2 == "d"),
         `x1:x2b` = x1 * x2b,
         `x1:x2c` = x1 * x2c,
         `x1:x2d` = x1 * x2d
  ) %>%
    select(`(Intercept)`, x1, x2b, x2c, x2d, `x1:x2b`, `x1:x2c`, `x1:x2d`)
}

model_matrix_mod2(sim3)

# To extend it we can build on the function used earlier
model_matrix_mod2b <- function(.data) {
  # get dataset with x1 and x2 indicator variables
  out <- model_matrix_mod1b(.data)
  # get names of the x2 indicator columns
  x2cols <- str_subset(colnames(out), "^x2")
  # create interactions between x1 and the x2 indicator columns
  for (varname in x2cols) {
    # name of the interaction variable
    newvar <- str_c("x1:", varname)
    out[[newvar]] <- out$x1 * out[[varname]]
  }
  out
}

model_matrix_mod2b(sim3)


# 4. For sim4, which of mod1 and mod2 is better? I think mod2 does a slightly better job at 
# removing patterns, but it's pretty subtle. Can you come up with a plot to support my claim?
mod1 <- lm(y ~ x1 + x2, data = sim4)
mod2 <- lm(y ~ x1 * x2, data = sim4)

# Get the residuals
sim4_mods <- gather_residuals(sim4, mod1, mod2)

# Do a frequency plot
ggplot(sim4_mods, aes(x = resid, colour = model)) +
  geom_freqpoly(binwidth = 0.5) +
  geom_rug()

# Do an absolute frequency plot
ggplot(sim4_mods, aes(x = abs(resid), colour = model)) +
  geom_freqpoly(binwidth = 0.5) +
  geom_rug()
# They're very close
# mod2 does seem like it has fewer extreme residuals (though it has the most extreme residual)

# Ploting the residuals in a scatterplot basically doesn't tell you anything
ggplot(sim4_mods, aes(x1, resid, colour = x2)) + 
  geom_point() + 
  facet_grid(model ~ x2)

