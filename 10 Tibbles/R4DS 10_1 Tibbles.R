library(tidyverse)

# as_tibble() converts a regular data frame to a tibble
as_tibble(iris)

# You can also create tibbles directly from vectors
# It always recycles single length inputs
tibble(
  x = 1:5, 
  y = 1, 
  z = x ^ 2 + y
)

# It's technically possible to have names that aren't valid in R, these have to be surrounded by backticks
tb <- tibble(
  `:)` = "smile", 
  ` ` = "space",
  `2000` = "number"
)

# You can also create one with tribble(), which using a different formatting
# Column headings are specified with a ~ and entries are seperated by commas
tribble(
  ~x, ~y, ~z,
  #--|--|----
  "a", 2, 3.6,
  "b", 1, 8.5
)


# Two main ways tibbles and data frames differ is in printing and subsetting
# Tibbles only show a set amount of columns and rows, rather than printing the whole thing
# You can manually change the amount you print
nycflights13::flights %>% 
  print(n = 10, width = Inf)

# You can also change the default via the options
package?tibble

# The other way too look at a tibble is through View()
# You can also Ctrl + Click on a tibble to open the view of it
View(nycflights13::flights)

# Subsetting is also different between the two
df <- tibble(
  x = runif(5),
  y = rnorm(5)
)

# You can extract by name using $
df$x

# Or extract by position using [[
df[[1]]

# To combine them with pipe, you need the placeholder .
df %>% .$x
df %>% .[["x"]]

# Sometimes you need to convert a tibble back into a data frame for it to work with some functions
# Usually that's because of messiness using square brackets
class(as.data.frame(tb))


#### Questions ####
# 1. How can you tell if an object is a tibble? (Hint: try printing mtcars, which is a regular data frame)
# A data frame prints the entire thing to your screen
# You can also use class() to check the class of a function
class(mtcars)

# 2. Compare and contrast the following operations on a data.frame and equivalent tibble. 
#   What is different? Why might the default data frame behaviours cause you frustration?
df <- data.frame(abc = 1, xyz = "a")
df$x # That could be annoying if there are multiple variables with x at the start
df[, "xyz"]
df[, c("abc", "xyz")]

# 3. If you have the name of a variable stored in an object,
#   e.g. var <- "mpg", how can you extract the reference variable from a tibble?
var <- "mpg"
var <- as.tibble(var)

# 4. Practice referring to non-syntactic names in the following data frame by...
annoying <- tibble(
  `1` = 1:10,
  `2` = `1` * 2 + rnorm(length(`1`))
)
# Extracting the variable called 1
one <- select(annoying, `1`)

# Plotting a scatterplot of 1 vs 2
ggplot(annoying, aes(`1`, `2`))+
  geom_point()

# Creating a new column called 3 which is 2 divided by 1
annoying <- mutate(annoying,
                   `3` = `2` / `1`)

# Renaming the columns to one, two and three
annoying <- rename(annoying,
                   one = `1`,
                   two = `2`,
                   three = `3`)

# 5. What does tibble::enframe() do? When might you use it?
# It turns a vector into a data frame
?tibble::enframe()

# 6. What option controls how many additional column names are printed at the footer of a tibble?
# tibble.max_extra_cols controls that setting, the default is 100
package?tibble
