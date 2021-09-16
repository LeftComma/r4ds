library(tidyverse)

# separate() turns one column into multiple columns
# In table3, the case and population data is saved in one column as the rate
# separate() splits a column like this based on a separator character
table3 %>%
  separate(rate, into = c("cases", "population"))
# By default it separates wherever it sees a non-alphanumeric character
# You can specify the separator with the sep argument (which is a regular expression)

# By default it also leaves the new columns as the same type of data as the old column
# You can try and convert the data type with convert = TRUE
table3 %>% 
  separate(rate, into = c("cases", "population"), convert = TRUE)

# You can also give sep an integer or vector of integers,
# whose position it will sperate on
table3 %>%
  separate(year, into = c("century", "year"), sep = 2)


# Unite
# unite() does the opposite of separate(), it brings together two columns into one
table5 %>%
  unite(new, century, year)
# By default it adds an underscore between them

# To remove the underscore we have to specify the sperator
table5 %>%
  unite(new, century, year, sep = "")


#### Questions ####
# 1. what do the extra and fill arguments do in separate()?
# extra determines what to do if there are too many pieces. By default it will show a warning and drop the extra
#   pieces. It can also drop them silently or merge them so the extra values aren't seperated
tibble(x = c("a,b,c", "d,e,f,g", "h,i,j")) %>% 
  separate(x, c("one", "two", "three"), extra = "merge")

# fill controls what happens if there are too few pieces. By default it will throw a warning and fill from the right,
#   meaning the NA missing value will be on the right
#   but it can also fill from right with no warning, or fill from the left
tibble(x = c("a,b,c", "d,e", "f,g,i")) %>% 
  separate(x, c("one", "two", "three"), fill = "left")

# 2. Both unite() and separate() have a remove argument. What does it do? Why would you set it to FALSE?
# remove removes the input columns from the final tibble, keeping only the result
# You'd set it to FALSE if you wanted to keep both the original and the new columns
table5 %>%
  unite(new, century, year, sep = "", rem)

# 3.Compare and contrast separate() and extract(). Why are there three variations of separation 
#   (by position, by separator, and with groups), but only one unite?
# extract() seperates by using regular expressions to find the groups, which makes it more flexible
extract()
# For example, seperate wouldn't be able to handle this
tibble(x = c("X1", "X20", "AA11", "AA2")) %>%
  extract(x, c("variable", "id"), regex = "([A-Z]+)([0-9]+)") # One group is a length of letters, the other is a length of numbers

# There are three seperators because there are multiple ways to chop up something into groups
# There's only one unite because the groups are specified by giving the columns
