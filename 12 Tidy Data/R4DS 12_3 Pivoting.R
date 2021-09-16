library(tidyverse)

# There are two common reasons data isn't tidy:
#   1. One variable is spread across multiple columns
#   2. One observation is spread across multiple rows

# Longer
# Sometimes a dataset will have columns whose names are values of a variable, not a variable themselves
# An example of this is table4a, where 1999 and 2000 are values, and each row has two observations
table4a
# To solve this you need to pivot the data into the correct form
# To do this you need:
#   The set of columns whose names are values, not variables (here it's 1999 and 2000)
#   The name of the variable to move those columns to (here it's "year")
#   The name of the variable to move the values of those columns to (here it's "cases")

# pivot_longer() performs this operation
table4a %>%
  pivot_longer(c(`1999`, `2000`), names_to = "year", values_to = "cases")
# The existing columns are written in dplyr::select() notation, without inverted commas
# The year and cases variables don't exist in the df yet, so require inverted commas

# We can do the same to table4b
table4b %>%
  pivot_longer(c(`1999`, `2000`), names_to = "year", values_to = "population")

# We can also combine them together into a single tibble
tidy4a <- table4a %>% 
  pivot_longer(c(`1999`, `2000`), names_to = "year", values_to = "cases")

tidy4b <- table4b %>% 
  pivot_longer(c(`1999`, `2000`), names_to = "year", values_to = "population")

left_join(tidy4a, tidy4b) # We learn more about left_join() later


# Wider
# Wider is the opposite of longer, an observation is spread across multiple rows
# table2 has data presented in this way
table2
# To rearrange this data we need:
#   The column to take variable names from (here it's "type")
#   The column to take values from (here it's "count")

# Then we use pivot_wider()
table2 %>%
  pivot_wider(names_from = type, values_from = count)

# pivot_longer() makes tables narrower and longer, pivot_wider() makes them shorter and wider


#### Questions ####
# 1. Why aren't pivot_longer() and pivot_wider() perfectly symmetrical? Look at this example:
stocks <- tibble(
  year   = c(2015, 2015, 2016, 2016),
  half  = c(   1,    2,     1,    2),
  return = c(1.88, 0.59, 0.92, 0.17)
)
stocks

stocks %>% 
  pivot_wider(names_from = year, values_from = return) %>% 
  pivot_longer(`2015`:`2016`, names_to = "year", values_to = "return")
# pivot_longer loses information about data type
# Because it takes column names, it presumes these are character types, which is a safe bet but sometimes wrong

# The names_ptypes lets you specify the type of data each created column will be
# It can't convert the year to a double though
stocks %>%
  pivot_wider(names_from = year, values_from = return)%>%
  pivot_longer(`2015`:`2016`, names_to = "year", values_to = "return",
               names_ptype = list(year = double()))

# For that you need to use the names_transform argument
stocks %>%
  pivot_wider(names_from = year, values_from = return)%>%
  pivot_longer(`2015`:`2016`, names_to = "year", values_to = "return",
               names_transform = list(year = as.numeric))

# 2. Why does this code fail?
# 1999 and 2000 weren't surrounded by ticks, which means they aren't recognised as column names
# This is because they're non-syntactic names
# Putting them in inverted commas also works
table4a %>% 
  pivot_longer(c(1999, 2000), names_to = "year", values_to = "cases")

# 3. What would happen if you widen this table? Why? How could you add a new column to uniquely identify each value?
people <- tribble(
  ~name,             ~key,  ~values,
  #-----------------|--------|------
  "Phillip Woods",   "age",       45,
  "Phillip Woods",   "height",   186,
  "Phillip Woods",   "age",       50,
  "Jessica Cordero", "age",       37,
  "Jessica Cordero", "height",   156
)

people %>%
  pivot_wider(names_from = key, values_from = values)
# The table can't be widened because there are multiple ages for one person, so it doesn't know which to use

# We could keep the duplicate by adding a row with a count for each combo of name and key
people2 <- people %>%
  group_by(name, key) %>%
  mutate(obs = row_number())
# This gives each row a unique signfier
people2

# So it can be widened
pivot_wider(people2, names_from="key", values_from = "values")

# Or you can drop duplicate rows
people %>%
  distinct(name, key, .keep_all = TRUE) %>%
  pivot_wider(names_from = "key", values_from = "values")

# 4. Tidy the tibble below. What must you do? What are the variables?
# Gender is a variable, pregnant feels like another, count would be the third
preg <- tribble(
  ~pregnant, ~male, ~female,
  "yes",     NA,    10,
  "no",      20,    12
)

# I've made it longer, it still doesn't look fully correct but I can't tell what else I'd do
# The thing to do was to drop the NA value for the male and pregnant combination
# This turns it from explicitly missing (shown with an NA) to implicitly missing (just not there)
preg_tidy <- preg %>%
  pivot_longer(c(male, female), names_to = "sex", values_to = "count", values_drop_na = TRUE)

# Another further thing would be to convert binary variables into logical data types
preg_tidy2 <- preg_tidy %>%
  mutate(female = sex == "female",
         pregnant = pregnant == "yes"
  ) %>%
  select(female, pregnant, count)

preg_tidy2
# Having female as the sex column name makes the data self-describing
# If you had it as "sex" then you'd need to look it up to figure out what "TRUE" means

# Converting to logical makes it cleaner to do stuff to the tibble
# For example selecting the non-pregnant females
filter(preg_tidy, sex == "female", pregnant == "no")
filter(preg_tidy2, female, !pregnant) # This is a lot more consice (though maybe harder to read)
