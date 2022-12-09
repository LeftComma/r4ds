library(tidyverse)
library(modelr)
options(na.action = na.warn)

# Lower quality diamonds as measured by cut, colour and clarity are more expensive
ggplot(diamonds, aes(cut, price)) + geom_boxplot()
ggplot(diamonds, aes(color, price)) + geom_boxplot() # J is the worst colour
ggplot(diamonds, aes(clarity, price)) + geom_boxplot() # I1 is the worst clarity

# This is because of the overwhelming impact carat (weight) has on price
# And low-quality diamonds tend to be larger
ggplot(diamonds, aes(carat, price)) + 
  geom_hex(bins = 50)

# To make this easier to work with we're going to:
# 1. Exclude diamonds larger than 2.5 carats (0.3% of the data)
# 2. Log-transform carat and price variables
diamonds2 <- diamonds %>% 
  filter(carat <= 2.5) %>% 
  mutate(lprice = log2(price), lcarat = log2(carat))

# This makes it easier to see the relationship
ggplot(diamonds2, aes(lcarat, lprice)) + 
  geom_hex(bins = 50)

# Now we can fit a linear model
mod_diamond <- lm(lprice ~ lcarat, data = diamonds2)

# And we can add the line to the original data
grid <- diamonds2 %>% 
  data_grid(carat = seq_range(carat, 20)) %>% 
  mutate(lcarat = log2(carat)) %>% # This is here so predictions can be related to a variable in the data
  add_predictions(mod_diamond, "lprice") %>% 
  mutate(price = 2 ^ lprice)

ggplot(diamonds2, aes(carat, price)) +
  geom_hex(bins = 50) +
  geom_line(data = grid, colour = "red", size = 1)

# You can also view it on the transformed linear data
grid2 <- diamonds2 %>% 
  data_grid(carat = seq_range(carat, 20)) %>% 
  mutate(lcarat = log2(carat)) %>% # This is here so predictions can be related to a variable in the data (I think)
  add_predictions(mod_diamond, "lprice")

ggplot(diamonds2, aes(lcarat, lprice)) +
  geom_hex(bins = 50) +
  geom_line(data = grid, colour = "red", size = 1)

cor.test(diamonds2$lcarat, diamonds2$lprice, alternative = "two.sided", method = "pearson")
# And we can determine that the correlation between price and carat is 0.97, p < .001

summary(mod_diamond)
# This sumamry shows that carat describes 93.34% of the variance in price

# We're going to take a few breaks to do the tests to make sure we can actually do a linear regression
# Is the relationship linear?
ggplot(diamonds2, aes(lcarat, lprice)) + 
  geom_hex(bins = 50)
# Yes, roughly

# Is the DV normally distributed
ggplot(diamonds2, aes(lprice)) + 
  geom_histogram(bins = 30)
# It's actually looking like it's got a bimodal distribution.
# This is interesting, but would exclude our ability to do a linear regression

# The Q-Q plot shows that we've met the assumption of homoscedasticity
par(mfrow=c(2,2))
plot(mod_diamond)
par(mfrow=c(1,1))

# The residuals confirm that we've removed the linear pattern
diamonds2 <- diamonds2 %>% 
  add_residuals(mod_diamond, "lresid")

ggplot(diamonds2, aes(lcarat, lresid)) + 
  geom_hex(bins = 50)

# When we look at our original plots, but with the residuals, we can see that price improves as quality does
ggplot(diamonds2, aes(cut, lresid)) + geom_boxplot()
ggplot(diamonds2, aes(color, lresid)) + geom_boxplot()
ggplot(diamonds2, aes(clarity, lresid)) + geom_boxplot()
# Here, a residual of -1 means lprice was 1 unit lower than expected based on its weight
# Transforming that back using 2^(-1) gives 1/2 showing points with a residual of -1 are half their expected price
# Those with residuals of 1 are double their expected price
# And this is due to the quality factors we've mentioned


# A more complicated model -------------------------------------------------
# We could include the other variables as predictors in the model
mod_diamond2 <- lm(lprice ~ lcarat + color + cut + clarity, data = diamonds2)

# All predictors are independent at the moment, so we can plot them seperately
grid <- diamonds2 %>% 
  data_grid(cut, .model = mod_diamond2) %>% 
  add_predictions(mod_diamond2)
grid

ggplot(grid, aes(cut, pred)) + 
  geom_point()

# We can plot the residuals as before
diamonds2 <- diamonds2 %>% 
  add_residuals(mod_diamond2, "lresid2")

ggplot(diamonds2, aes(lcarat, lresid2)) + 
  geom_hex(bins = 50)
# This shows some pretty far outliers. A score of 2 in the residuals means its 4x higher than we'd expect

# We can look at these outliers specifically
diamonds2 %>% 
  filter(abs(lresid2) > 1) %>% 
  add_predictions(mod_diamond2) %>% 
  mutate(pred = round(2 ^ pred)) %>% 
  select(price, pred, carat:table, x:z) %>% 
  arrange(price)
# There isn't any obvious relationship. This may be an issue with the model or the data


####  Questions ####
# 1. In the plot of lcarat vs. lprice, there are some bright vertical strips. What do they represent?
ggplot(diamonds2, aes(lcarat, lprice)) + 
  geom_hex(bins = 50)
# I think they're because there are more diamonds at round carat numbers

# 2. If log(price) = a_0 + a_1 * log(carat), what does that say about the relationship between price and carat?
# That its non-linear

# 3. Extract the diamonds that have very high and very low residuals. 
# Is there anything unusual about these diamonds? Are they particularly bad or good, 
# or do you think these are pricing errors?
# This is what we did at the end before the questions, there didn't look like there was anything wrong
# There aren't really residuals with very low distributions

# 4. Does the final model, mod_diamonds2, do a good job of predicting diamond prices? 
# Would you trust it to tell you how much to spend if you were buying a diamond?
ggplot(diamonds2, aes(lcarat, lresid2)) +
  geom_hex(bins = 50)
# There are outliers, but most of the residuals are between -0.5 and 0.5

lresid2_summary <- summarise(diamonds2,
                             rmse = sqrt(mean(lresid2^2)),
                             mae = mean(abs(lresid2)),
                             p025 = quantile(lresid2, 0.025),
                             p975 = quantile(lresid2, 0.975)
)
lresid2_summary
# The root mean squared error is 0.19, meaning the average error is around -14%.
# The mean absolute error is 0.15 which is -11%
# 95% of the residuals are between -0.37 and 0.38, which is 23-31 in real units

summary(mod_diamond2)
# Without doing any of the safety checks, the R-squared shows that the model explains >0.98% of the variance in price

# This feels pretty good, especially if you start out knowing nothing about pricing diamonds