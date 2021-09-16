library(tidyverse)

# Missing values can be explicit - represented by NA, or implicit - not shown in the data
# In this dataset the fourth quarter of 2015 is explicitly missing
#   and the first quarter of 2016 is implicitly missing
stocks <- tibble(
  year   = c(2015, 2015, 2015, 2015, 2016, 2016, 2016),
  qtr    = c(   1,    2,    3,    4,    2,    3,    4),
  return = c(1.88, 0.59, 0.35,   NA, 0.92, 0.17, 2.66)
)

# Presenting data in a particular way can make implicit missing values explicit
stocks %>%
  pivot_wider(names_from = year, values_from = return)

# You can also drop NA values if they're not relevant to how you want to display your data
stocks %>% 
  pivot_wider(names_from = year, values_from = return) %>% 
  pivot_longer(
    cols = c(`2015`, `2016`), 
    names_to = "year", 
    values_to = "return", 
    values_drop_na = TRUE
  )

# complete() also makes implicit missing values explicit
# It takes a set of columns and finds all unique combinations of them, if they're not present it adds them with an NA
stocks %>%
  complete(year, qtr)

# drop_na() does the opposite, dropping rows with NA values
stocks %>%
  drop_na()

# Sometimes missing values imply that the previous value should be carried forward
treatment <- tribble(
  ~ person,           ~ treatment, ~response,
  "Derrick Whitmore", 1,           7,
  NA,                 2,           10,
  NA,                 3,           9,
  "Katherine Burke",  1,           4
)

# fill() lets you replcae a missing value with the most recent non-missing value (last observation)
treatment %>%
  fill(person)


#### Questions ####
# 1. Compare and contrast the fill arguments to pivot_wider() and complete()
# values_fill takes a single value that should be inserted if implicit missing data is found
#   can also be a list that gives a different value for each column
#   doesn't affect already explicitly missing data
stocks %>%
  pivot_wider(names_from = year, values_from = return, values_fill = 0)

# fill here can only accept a list, you have to give it a column and the value to fill that column's missing values with
#   this replaces both explicit and implicit values
stocks %>%
  complete(year, qtr, fill = list(return = 0))

# 2. What does the direction argument to fill() do?
# It tells the function which way to fill missing values
# The default is down, so it looks above for the latest observation
treatment %>%
  fill(person, .direction = "up")
