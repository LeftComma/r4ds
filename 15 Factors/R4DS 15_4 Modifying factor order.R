library(tidyverse)

# Here's code to visualise how much TV people of different religions watch
relig_summary <- gss_cat %>%
  group_by(relig) %>%
  summarise(
    age = mean(age, na.rm = TRUE),
    tvhours = mean(tvhours, na.rm = TRUE),
    n = n()
  )

ggplot(relig_summary, aes(tvhours, relig)) + geom_point()
# It's hard to read because the factors aren't ordered at all

# fct_reorder() reorders factors based on three arguments:
# f: the factor we want to modify
# x: the vector we want to use to reorder the factor
# fun: optional, used if there are multiple of x for each f. Defaults to median

# So, reordering the levels
ggplot(relig_summary, aes(tvhours, fct_reorder(relig, tvhours))) +
  geom_point()
# You can read the graph a lot more easily

# It's also better to reorder the factors in a mutate step than inside the aes
relig_summary %>%
  mutate(relig = fct_reorder(relig, tvhours)) %>%
  ggplot(aes(tvhours, relig)) +
  geom_point()

# What about if we looked at how age varies across income level
rincome_summary <- gss_cat %>%
  group_by(rincome) %>%
  summarise(
    age = mean(age, na.rm = TRUE),
    tvhours = mean(tvhours, na.rm = TRUE),
    n = n()
  )

ggplot(rincome_summary, aes(age, fct_reorder(rincome, age))) + geom_point()
# Here it doesn't work because rincome already has an order that makes sense

# However you could just move one factor, using fct_relevel()
ggplot(rincome_summary, aes(age, fct_relevel(rincome, "Not applicable"))) +
  geom_point()

# Reordering can also be done to make colouring of graph lines line up with the legend
by_age <- gss_cat %>%
  filter(!is.na(age)) %>%
  count(age, marital) %>%
  group_by(age) %>%
  mutate(prop = n / sum(n))

ggplot(by_age, aes(age, prop, colour = marital)) +
  geom_line(na.rm = TRUE)

ggplot(by_age, aes(age, prop, colour = fct_reorder2(marital, age, prop))) +
  geom_line() +
  labs(colour = "marital")

# You can reorder bar charts by frequency, and reverse the order like so
gss_cat %>%
  mutate(marital = marital %>% fct_infreq() %>% fct_rev()) %>%
  ggplot(aes(marital)) +
  geom_bar()


#### Questions ####
# 1. There are some suspiciously high numbers in tvhours. Is the mean a good summary?
# There are 22 people who watch 24 hours of tv a day apparently, median might be better
gss_cat %>%
  filter(tvhours == 24)

# 2. For each factor in gss_cat identify whether the order of the levels is arbitrary or principled
gss_cat
# Aribitrary: marital, race, relig, denom
# Ordered: year, age, rincome, partyid, tvhours

# 3. Why did moving "Not applicable" to the front of the levels move it to the bottom of the plot?
# Because fct_relevel() has an after argument, which governs where new levels go
# The default of this is 0, which means they go at the bottom
ggplot(rincome_summary, aes(age, fct_relevel(rincome, "Not applicable", after = 3))) +
  geom_point()
