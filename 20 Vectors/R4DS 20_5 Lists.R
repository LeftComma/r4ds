library(tidyverse)

# Lists can contain other lists, which means they can represent hierarchical structures
x <- list(1, 2, 3)
x

# str() is useful when using lists because it focuses on the structure
str(x)

x_named <- list(a = 1, b = 2, c = 3)
str(x_named)

# Lists can contain multiple types of data
y <- list("a", 1L, 1.5, TRUE)
str(y)

# They can also contain other lists
z <- list(list(1, 2), list(3, 4))
str(z)


# Subsetting --------------------------------------------------------------

a <- list(a = 1:3, b = "a string", c = pi, d = list(-1, -5))

# You can subset with [], which always produces a list
str(a[1:2])
str(a[4])
# This returns a new, smaller list with the same hierarchy

# [[]] extracts one element, digging one layer into the list hierarchy
str(a[[1]])
str(a[[4]])

# $ is for extracting named elements of a list
# It works the same way as [[]] but without needing quotes
a$a


#### Questions ####
# 1. Draw the following lists as nested sets:
# Not done in R

# 2. What happens if you subset a tibble as if you're subsetting a list? 
#   What are the key differences between a list and a tibble?
# You can subset tibbles in the same way you do lists
# Tibbles require all the columns to be the same length, lists can contain lists of variable length
x <- tibble(a = 1:2, b = 3:4)
x[["a"]]
x$a
