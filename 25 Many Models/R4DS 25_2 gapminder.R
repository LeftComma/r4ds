library(modelr)
library(tidyverse)
library(gapminder)

# We're going to use 3 techniques
# 1. Using many simple models to understand complex data
# 2. Using list-columns to store arbitrary data structures in a df. E.g. letting you have a column containing linear models
# 3. Using the broom package to turn models into tidy data

# We're going to look at life-expectancy data from gapminder
gapminder
# Specifically, we'll ask "How does life expectancy change over time for each country?"

# We can plot this
gapminder %>% 
  ggplot(aes(year, lifeExp, group = country)) +
  geom_line(alpha = 1/3)
# Overall it looks like it's been improving, but there's a lot there so it's hard to see what's going on

# We could fit a linear model to take explain that steady upward trend
# This is what it would look like for a single country
nz <- filter(gapminder, country == "New Zealand")
nz %>% 
  ggplot(aes(year, lifeExp)) + 
  geom_line() + 
  ggtitle("Full data = ")

nz_mod <- lm(lifeExp ~ year, data = nz)
nz %>% 
  add_predictions(nz_mod) %>%
  ggplot(aes(year, pred)) + 
  geom_line() + 
  ggtitle("Linear trend + ")

nz %>% 
  add_residuals(nz_mod) %>% 
  ggplot(aes(year, resid)) + 
  geom_hline(yintercept = 0, colour = "white", size = 3) + 
  geom_line() + 
  ggtitle("Remaining pattern")

# To do it for all countries, we can make a function and apply it with the purrr map function
# But we want to interate over each country, which is a set of rows
# For this we use a nested data frame
by_country <- gapminder %>% 
  group_by(country, continent) %>% 
  nest()

by_country
# This means each row contains a tibble

# Here we can look at the first country, Afghanistan
by_country$data[[1]]

# In a nested df each row is a group, rather than being an observation

# Now we can create a model-fitting function and fit it to each country
country_model <- function(df) {
  lm(lifeExp ~ year, data = df)
}

models <- map(by_country$data, country_model)
# Instead of having some massive object with all the models, we can add each model as a column in our df
by_country <- by_country %>% 
  mutate(model = map(data, country_model))
by_country
# This is neater because it keeps everything together for you

# To add residuals, we need to call the function for each model
by_country <- by_country %>% 
  mutate(
    resids = map2(data, model, add_residuals)
  )
by_country

# A nested df is tricky to plot, so we can just unnest it
resids <- unnest(by_country, resids)
resids
# Now each regular column is repeated once for each row of the nested tibble

# Now we can plot the residuals
resids %>% 
  ggplot(aes(year, resid)) +
  geom_line(aes(group = country), alpha = 1 / 3) + 
  geom_smooth(se = FALSE)

# And maybe facet by continent
resids %>% 
  ggplot(aes(year, resid, group = country)) +
  geom_line(alpha = 1 / 3) + 
  facet_wrap(~continent)
# This shows that there are some minor patterns we might be missing
# And that we're missing something major in Africa


# Model quality -----------------------------------------------------------

# We could look at measures of model quality rather than residuals
# This uses broom to turn models into tidy data
#broom::glance() extracts some model quality metrics
broom::glance(nz_mod)

# We can create a df with a row for each country with mutate and unnest
glance <- by_country %>% 
  mutate(glance = map(model, broom::glance)) %>% 
  unnest(glance)

glance %>% 
  arrange(r.squared)
# The worst models all appear to be in Africa

# We can visualise this using points as well
glance %>% 
  ggplot(aes(continent, r.squared)) + 
  geom_jitter(width = 0.5)
# There are actually two distinctive groups in Africa with worse models, which is interesting

# We can pull just the bad fits out to look at them
bad_fit <- filter(glance, r.squared < 0.25)

gapminder %>% 
  semi_join(bad_fit, by = "country") %>% 
  ggplot(aes(year, lifeExp, colour = country)) +
  geom_line()
# We see two main effects here: the tragedies of the HIV/AIDS epidemic and the Rwandan genocide.


#### Questions ####
# 1. A linear trend seems to be slightly too simple for the overall trend. Can you do better with 
# a quadratic polynomial? How can you interpret the coefficients of the quadratic? 
# (Hint you might want to transform year so that it has mean zero.)
# poly() creates a polynomial of a variable
lifeExp ~ poly(year, 2)

# Create a function as before
country_model2 <- function(df) {
  lm(lifeExp ~ poly(year - median(year), 2), data = df)
}

by_country2 <- gapminder %>%
  group_by(country, continent) %>%
  nest()

by_country2 <- by_country2 %>%
  mutate(model = map(data, country_model2))

by_country2 <- by_country2 %>%
  mutate(
    resids = map2(data, model, add_residuals)
  )

# I want to see the two options side-by-side
# I could do this with gridExtra::grid.arrange()
p1 <- resids %>% 
  ggplot(aes(year, resid)) +
  geom_line(aes(group = country), alpha = 1 / 3) + 
  geom_smooth(se = FALSE)
p2 <- unnest(by_country2, resids) %>%
  ggplot(aes(year, resid)) +
  geom_line(aes(group = country), alpha = 1 / 3) +
  geom_smooth(se = FALSE)

gridExtra::grid.arrange(p1, p2, ncol = 2)
# We can see that while the quadratic model still wobbles, it fits a lot better
# This method is useful for combining completely seperate graphs
# We can use facet_wrap instead, but I cba

# Lets look at the other graph
p3 <- glance %>% 
  ggplot(aes(continent, r.squared)) + 
  geom_jitter(width = 0.5)
  
p4 <- by_country2 %>%
  mutate(glance = map(model, broom::glance)) %>%
  unnest(glance) %>%
  ggplot(aes(continent, r.squared)) +
  geom_jitter(width = 0.5)

gridExtra::grid.arrange(p3, p4, ncol = 2)
# We can see again that the quadractic formula has a much better fit

# The one stand-out country with a much worse fit than expected is Rwanda
by_country2 %>% 
  mutate(glance = map(model, broom::glance)) %>%
  unnest(glance) %>%
  filter(r.squared < 0.25)


# 2. Explore other methods for visualizing the distribution of R2 per continent. 
# You might want to try the ggbeeswarm package, which provides similar methods for 
# avoiding overlaps as jitter, but uses deterministic methods.
library("ggbeeswarm")
by_country %>%
  mutate(glance = map(model, broom::glance)) %>%
  unnest(glance, .drop = TRUE) %>%
  ggplot(aes(continent, r.squared)) +
  geom_beeswarm()


# 3. To create the last plot (showing the data for the countries with the worst model fits), 
# we needed two steps: we created a data frame with one row per country and then semi-joined 
# it to the original dataset. It's possible to avoid this join if we use unnest() instead of 
# unnest(.drop = TRUE). How?
gapminder %>%
  group_by(country, continent) %>%
  nest() %>%
  mutate(model = map(data, ~lm(lifeExp ~ year, .))) %>%
  mutate(glance = map(model, broom::glance)) %>%
  unnest(glance) %>%
  unnest(data) %>%
  filter(r.squared < 0.25) %>%
  ggplot(aes(year, lifeExp)) +
  geom_line(aes(color = country))
