library(tidyverse)

# Factors are dealt with by the forcats package. They're CATagorical variables

# Say you have a variable containing month
x1 <- c("Dec", "Apr", "Jan", "Mar")

# A string has two issues:
# Nothing protects you from typos
x2 <- c("Dec", "Apr", "Jam", "Mar")

# And it doesn't sort in a useful way
sort(x1)

# Factors solve these problems, first you create a list of the valid levels
month_levels <- c(
  "Jan", "Feb", "Mar", "Apr", "May", "Jun", 
  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
)

# Then you can create a factor
y1 <- factor(x1, levels = month_levels)
y1
sort(y1)

# Any invalid values will be converted into NAs
y2 <- factor(x2, levels = month_levels)
y2
# Use parse_factor if you want errors to throw up warnings
y2 <- parse_factor(x2, levels = month_levels)

# If you don't give it levels, they'll be taken from the data in alphabetical order
factor(x1)

# Sometimes it's better to have the levels order match the order they appear in the data
# You can do that when creating the factors with unique()
f1 <- factor(x1, levels = unique(x1))
f1

# Or after the fact with fct_inorder()
f2 <- x1 %>% factor() %>% fct_inorder()
f2

# levels() gives you the set of valid levels directly
levels(f2)
