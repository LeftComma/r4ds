library(tidyverse)

# There are a few other rarer functions, this is just so I know they exist
# Many work with predicate functions, which return either TRUE or FALSE

# keep() and discard() keeps elements that are TRUE and FALSE respectively
iris %>% 
  keep(is.factor) %>% 
  str()

iris %>% 
  discard(is.factor) %>% 
  str()

# some() and every() determine if the predicate is true for any or all elements
x <- list(1:5, letters, list(10))

x %>% 
  some(is_character)

x %>%
  every(is.character)

# detect() returns the first element where the predicate is true
x <- sample(10)
x
x %>%
  detect(~ . > 5)
# detect_index() returns its position
x %>%
  detect_index(~ . > 5)

# head_while() and tail_while() take elements from the start or end of
# a vector while the predicate is true
x %>% 
  head_while(~ . > 5)
x %>% 
  tail_while(~ . > 5)
# These don't work for me for some reason


# Reduce and accumulate let you reduce a list by repeatedly joining different
# elements together
# reduce() lets you repeatedly reduce a pair into a single item.
dfs <- list(
  age = tibble(name = "John", age = 30),
  sex = tibble(name = c("John", "Mary"), sex = c("M", "F")),
  trt = tibble(name = "Mary", treatment = "A")
)

dfs %>% reduce(full_join)
