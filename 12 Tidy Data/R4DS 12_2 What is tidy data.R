library(tidyverse)

# Tidy data is a form of organisation which works well with the tidyverse package
# It can take some upfront work but makes things a lot easier in the long run

# There are three rules that make a dataset tidy:
#   1. Each variables must have its own column
#   2. Each observation must have its own row
#   3. Each value must have its own cell

# These can be done by:
#   1. Put each dataset in a tibble
#   2. Put each variable in a column

# These are four ways to represent the same data
# Only table1 is tidy
table1
table2
table3
table4a
table4b

# There are two main advantages to tidy data:
#   1. It's good to store data in a consistent way, this makes analysis and use of tools easier
#   2. Variables as columns allows R's vectorised nature to shine

# The tidyverse packages are designed to work with tidy data, for example with table1 it's easy to:
# Compute rate per 10,000
table1 %>%
  mutate(rate = cases / population * 10000)

# Compute cases per year
table1 %>%
  count(year, wt = cases)

# Visualise change over time
ggplot(table1, aes(year, cases)) +
  geom_line(aes(group = country), colour = "grey50") +
  geom_point(aes(colour = country))


#### Questions ####
# 1. Describe how variables and observations are organised in each sample table
# table2 has two rows for each observation, split into a row for cases and a row for population
# there's a sinlge count variable and a type variable to tell you whether the count is for cases or population
table2
# table3 has 1 row per observation. It has no counts but a single variable for rate
table3
# table 4a contains cases, with a row per country and the count for each year as a variable
# table4b does the same thing but for population
table4a
table4b

# 2. Compute rate for table 2, 3, 4a, 4b. To do this:
#   Extract number of TB cases per year
#   Extract the matching population per country per year
#   Divide cases by population and multiply by 10000
#   Store in an appropraite place
#   Which is easiest to work with? Which is hardest? Why?
# For 2, first seperate the cases and pop into two tables
t2_cases <- filter(table2, type == "cases") %>%
  rename(cases = count) %>%
  arrange(country, year)
t2_population <- filter(table2, type == "population") %>%
  rename(population = count) %>%
  arrange(country, year)

# Then put them together and calculate the rate
t2_rates <- tibble(
  year = t2_cases$year,
  country = t2_cases$country,
  cases = t2_cases$cases,
  population = t2_population$population
) %>%
  mutate(rate = cases / population * 10000) %>%
  select(country, year, rate)

# Then put it back into the original data frame
# Create the two columns we want in this new dataframe
t2_rates <- t2_rates %>%
  mutate(type = "rate") %>%
  rename(count = rate)

# Add them back together
# For me this shows everything as scientific notation which is quite annoying
bind_rows(table2, t2_rates) %>%
  arrange(country, year, type, count)

# For table 3 the rate is already displayed, but as a string

# For 4, create a new table with the rate
table4c <- tibble(
  country = table4a$country,
  `1999` = table4a[["1999"]] / table4b[["1999"]] * 10000,
  `2000` = table4a[["2000"]] / table4b[["2000"]] * 10000
  )

table4c

# 3. Recreate the plot showing cases over time with table2. What must you do first?
# You have to filter the data to remove the population
table2 %>%
  filter(type == "cases") %>%
  ggplot(aes(year, count)) +
  geom_line(aes(group = country), colour = "grey50") +
  geom_point(aes(colour = country)) +
  scale_x_continuous(breaks = unique(table2$year)) +
  ylab("cases")




