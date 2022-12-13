library(tidyverse)
library(modelr)
options(na.action = na.warn)

library(nycflights13)
library(lubridate)
library(broom)

# We're going to try and work out what affects the number of flights on a particular day
daily <- flights %>% 
  mutate(date = make_date(year, month, day)) %>% 
  group_by(date) %>% 
  summarise(n = n())
daily

ggplot(daily, aes(date, n)) + 
  geom_line()


# Days of the week --------------------------------------------------------
daily <- daily %>%
  mutate(wday = wday(date, label = TRUE))

ggplot(daily, aes(wday, n)) +
  geom_boxplot()
# People don't tend to travel as much on the weekends, particularly on Saturday.
# This is apparently because most travel is for business. While people might be expected
# to fly on Sunday for Monday morning. Saturday flights are unpopular

# We can use a model to account for this trend
mod <- lm(n ~ wday, data = daily)

# Here we can see that the model fits closely with the data
grid <- daily %>%
  data_grid(wday) %>%
  add_predictions(mod, "n")

ggplot(daily, aes(wday, n)) +
  geom_boxplot() +
  geom_point(data = grid, colour = "red", size = 4)

# And now we can plot the residuals
# These show how much the data deviates from what we'd expect based on days of the week
daily <- daily %>% 
  add_residuals(mod)
daily %>% 
  ggplot(aes(date, resid)) + 
  geom_ref_line(h = 0) + 
  geom_line()
# There are still some important things our model isn't capturing

# One thing is the model starts to get worse around June
# Plotting days of the week makes this more clear
ggplot(daily, aes(date, resid, colour = wday)) + 
  geom_ref_line(h = 0) + 
  geom_line()
# Our model underestimates the amount of Saturday travel in the summer and overestimates the amount in the autumn

# A second is that there are certain days with far fewer flights than expected
daily %>% 
  filter(resid < -100)
# Many of these match US national holidays

# Thirdly, there seems to be a slower trend over the course of the year
daily %>% 
  ggplot(aes(date, resid)) + 
  geom_ref_line(h = 0) + 
  geom_line(colour = "grey50") + 
  geom_smooth(se = FALSE, span = 0.20)
# With fewer flights in Jan, Feb and Dec, and more in Jun-Aug
# This is likely due to holiday travel


# Seasonal Saturday -------------------------------------------------------
# Lets figure out why we failed to predict Sat year round
# Going back to the raw numbers again
daily %>% 
  filter(wday == "Sat") %>% 
  ggplot(aes(date, n)) + 
  geom_point() + 
  geom_line() +
  scale_x_date(NULL, date_breaks = "1 month", date_labels = "%b")
# This is likely due to summer holidays for the summer months
# According to some Americans, they're less likely to plan holidays for the autumn
# because of Thanksgiving and Christmas coming up
# You also have Easter and Spring Break in the spring

# Lets create a term that captures the three school terms, to slightly adjust for seasonal differences
# (but not for holidays directly)
term <- function(date) {
  cut(date, 
      breaks = ymd(20130101, 20130605, 20130825, 20140101),
      labels = c("spring", "summer", "fall") 
  )
}

daily <- daily %>% 
  mutate(term = term(date)) 

daily %>% 
  filter(wday == "Sat") %>% 
  ggplot(aes(date, n, colour = term)) +
  geom_point(alpha = 1/3) + 
  geom_line() +
  scale_x_date(NULL, date_breaks = "1 month", date_labels = "%b")
# The breaks can really help to show how the terms are different from one another

# Terms don't just affect Saturdays
daily %>% 
  ggplot(aes(wday, n, colour = term)) +
  geom_boxplot()
# There seems significant termly differences for each day of the week

# So lets fit term as a new factor in our model
mod1 <- lm(n ~ wday, data = daily)
mod2 <- lm(n ~ wday * term, data = daily)

# And we can compare how effective each model is
daily %>% 
  gather_residuals(without_term = mod1, with_term = mod2) %>% 
  ggplot(aes(date, resid, colour = model)) +
  geom_line(alpha = 0.75)
# With terms is better, but there's still a lot it doesn't capture

# We can see this clearly by overlaying the predictions on the raw data
grid <- daily %>% 
  data_grid(wday, term) %>% 
  add_predictions(mod2, "n")

ggplot(daily, aes(wday, n)) +
  geom_boxplot() + 
  geom_point(data = grid, colour = "red") + 
  facet_wrap(~ term)
# The issue is that we're measuring mean effect, and that's heavily skewed by some large outliers

# We can fix this by using a robust model that isn't as affected by outliers
mod3 <- MASS::rlm(n ~ wday * term, data = daily)

daily %>% 
  add_residuals(mod3, "resid") %>% 
  ggplot(aes(date, resid)) +
  geom_hline(yintercept = 0, size = 2, colour = "white") +
  geom_line()

daily %>% 
  gather_residuals(without_term = mod1, with_term = mod2, robust = mod3) %>% 
  ggplot(aes(date, resid, colour = model)) +
  geom_line(alpha = 0.75) +
  ylim(-75, 75)
# This has less day-to-day fluctuation, making the long-term trend easier to see

# Computed variables ------------------------------------------------------
# If you're experimenting with a lot of visualisations and models, you can bundle the variable
# Creation into a function so it's the same every time
compute_vars <- function(data) {
  data %>% 
    mutate(
      term = term(date), 
      wday = wday(date, label = TRUE)
    )
}

# Or put it directly into the model formula
wday2 <- function(x) wday(x, label = TRUE)
mod3 <- lm(n ~ wday2(date) * term(date), data = daily)
# I don't fully understand the point of this if I'm being entirely honest

# Another approach --------------------------------------------------------
# Before we used domain knowledge about schools to improve our model
# We could also fit a more flexible, non-linear model to the data
# Here we use a natural spline to fit a smooth curve over the year
library(splines)
mod <- MASS::rlm(n ~ wday * ns(date, 5), data = daily)

daily %>% 
  data_grid(wday, date = seq_range(date, n = 13)) %>% 
  add_predictions(mod) %>% 
  ggplot(aes(date, pred, colour = wday)) + 
  geom_line() +
  geom_point()
# This shows a varying pattern for Saturday. This is good because it's also what we found with the other technique


#### Questions ####
# 1. Use your Google sleuthing skills to brainstorm why there were fewer than expected flights on Jan 20, May 26, and Sep 1. 
# (Hint: they all have the same explanation.) How would these days generalise to another year?
# They're all Sundays and the day before a national holiday in the USA
# Jan 20th is the day before MLK Jr Day
# May 26th is the day before Memorial Day
# September 1st is the day before Labor Day
# On other years there would be a dip on a Sunday at roughly the same time, but not exactly

# 2. What do the three days with high positive residuals represent? How would these days generalise to another year?
daily %>% 
  slice_max(n = 3, resid)
# Nov 30th and Dec 1st are the weekend after Thanksgiving, so you'd have people travelling back from seeing their families
# Dec 28th is between Christmas and New Years Eve, so might have people travelling to different events, or to spend time
# with different groups. It's also a Saturday, so may be particularly high because Saturdays are usually low
# They will all likely change to a degree year by year, to be on weekends in roughly the same spot

# 3. Create a new variable that splits the wday variable into terms, but only for Saturdays,
# i.e. it should have Thurs, Fri, but Sat-summer, Sat-spring, Sat-fall. How does this model compare with the 
# model with every combination of wday and term?
# One way to do that is using case_when()
daily <- daily %>%
  mutate(
    wday2 =
      case_when(
        wday == "Sat" & term == "summer" ~ "Sat-summer",
        wday == "Sat" & term == "fall" ~ "Sat-fall",
        wday == "Sat" & term == "spring" ~ "Sat-spring",
        TRUE ~ as.character(wday)
      )
  )

# Then fit a new model and plot the new and old
mod3 <- lm(n ~ wday2, data = daily)

daily %>%
  gather_residuals(sat_term = mod3, all_interact = mod2) %>%
  ggplot(aes(date, resid, colour = model)) +
  geom_line(alpha = 0.75)

# It might be easier to see the differences by plotting the differences directly
# spread_residuals() adds residuals as seperate columns
daily %>%
  spread_residuals(sat_term = mod3, all_interact = mod2) %>%
  mutate(resid_diff = sat_term - all_interact) %>%
  ggplot(aes(date, resid_diff)) +
  geom_line(alpha = 0.75)
# The model with terms × Saturday has higher residuals in the fall and lower residuals in the spring 
# than the model with all interactions.

glance(mod3) %>% select(r.squared, sigma, AIC, df)
glance(mod2) %>% select(r.squared, sigma, AIC, df)
# mod3 has a lower R-squared, meaning it explains less of the variance
# It also has a higher AIC, implying a greater amount of error


# 4. Create a new wday variable that combines the day of week, term (for Saturdays), 
# and public holidays. What do the residuals of that model look like?
# Lets make something with Federal US holidays
holidays_2013 <-
  tribble(
    ~holiday, ~date,
    "New Year's Day", 20130101,
    "Martin Luther King Jr. Day", 20130121,
    "Washington's Birthday", 20130218,
    "Memorial Day", 20130527,
    "Independence Day", 20130704,
    "Labor Day", 20130902,
    "Columbus Day", 20131028,
    "Veteran's Day", 20131111,
    "Thanksgiving", 20131128,
    "Christmas", 20131225
  ) %>%
  mutate(date = lubridate::ymd(date))

# Lets also define the days before and after the holiday, because they might have abnormal travel
daily <- daily %>%
  mutate(
    wday3 =
      case_when(
        date %in% (holidays_2013$date - 1L) ~ "day before holiday",
        date %in% (holidays_2013$date + 1L) ~ "day after holiday",
        date %in% holidays_2013$date ~ "holiday",
        .$wday == "Sat" & .$term == "summer" ~ "Sat-summer",
        .$wday == "Sat" & .$term == "fall" ~ "Sat-fall",
        .$wday == "Sat" & .$term == "spring" ~ "Sat-spring",
        TRUE ~ as.character(.$wday)
      )
  )

mod4 <- lm(n ~ wday3, data = daily)

# Adding holidays seemed to make residuals a lot higher on certain days, but lower on others
# From visual inspection, I think this is a case of the days before thing causing issues
daily %>%
  gather_residuals(sat_term = mod3, holidays = mod4) %>%
  ggplot(aes(date, resid, colour = model)) +
  geom_line(alpha = 0.75)

# Comparing the residuals shows some times when the holidays residuals were far higher
daily %>%
  spread_residuals(resid_sat_terms = mod3, resid_holidays = mod4) %>%
  mutate(resid_diff = resid_holidays - resid_sat_terms) %>%
  ggplot(aes(date, resid_diff)) +
  geom_line(alpha = 0.75)


# 5. What happens if you fit a day of week effect that varies by month (i.e., n ~ wday * month)? 
# Why is this not very helpful?
daily <- mutate(daily, month = factor(lubridate::month(date)))
mod6 <- lm(n ~ wday * month, data = daily)
print(summary(mod6))
# A days x month model will have 12 * 7 = 84 parameters
# Eeach month's data is only based on a few weeks, with large standard error and little generalisability


# 6. What would you expect the model n ~ wday + ns(date, 5) to look like? 
# Knowing what you know about the data, why would you expect it to be not particularly effective?
# This model doesn't involve interaction between day of the week and long-term trends
# Which might make it rather ineffective
# Lets model both with and without interaction
mod7 <- lm(n ~ wday + ns(date, 5), data = daily)
mod8 <- lm(n ~ wday * ns(date, 5), data = daily)

daily %>%
  gather_residuals(mod7, mod8) %>%
  ggplot(aes(x = date, y = resid, color = model)) +
  geom_line(alpha = 0.75)
# Without interaction has larger residuals, and has more overestimation in the summer and underestimation in the autumn

# 7. We hypothesized that people leaving on Sundays are more likely to be business travelers who need to be somewhere on Monday. 
# Explore that hypothesis by seeing how it breaks down based on distance and time: if it's true, you'd expect to see more Sunday 
# evening flights to places that are far away.
flights %>%
  mutate(
    date = make_date(year, month, day),
    wday = wday(date, label = TRUE)
  ) %>%
  ggplot(aes(y = distance, x = wday)) +
  geom_boxplot() +
  labs(x = "Day of Week", y = "Average Distance")
# Sunday has the second-longest ave flights, after Saturday, implying the Sunday idea is true
# Sat may have long flights because it has fewer short-haul commuter flights

# It is slightly hard to see though because of the outliers
# A pointrange might work better
flights %>%
  mutate(
    date = make_date(year, month, day),
    wday = wday(date, label = TRUE)
  ) %>%
  ggplot(aes(y = distance, x = wday)) +
  stat_summary() +
  labs(x = "Day of Week", y = "Average Distance")


# 8. It's a little frustrating that Sunday and Saturday are on separate ends of the plot. 
# Write a small function to set the levels of the factor so that the week starts on Monday.
# fct_relevel() is in the factors chapter
monday_first <- function(x) {
fct_relevel(x, levels(x)[-1])
}

daily <- daily %>%
  mutate(wday = wday(date, label = TRUE))
ggplot(daily, aes(monday_first(wday), n)) +
  geom_boxplot() +
  labs(x = "Day of Week", y = "Number of flights")
