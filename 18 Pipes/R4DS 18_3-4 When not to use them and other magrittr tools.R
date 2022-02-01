library(magrittr)


# When not to use pipes:

# The pipes are too long, say >10 steps. This length makes debugging hard.
#   Create intermediary steps with meaningful names

# There are multiple inputs or outputs. The pipe is for one primary object being transformed.

# You are starting to think about a directed graph with a complex dependency structure. 
#   Pipes are fundamentally linear and expressing complex relationships with them will 
#   typically yield confusing code.


# Other magrittr tools:

# With more complex pipes, sometimes you call a function for its side effects.
#   Many functions like plot() or print() don't return anything, which would end the pipe
# "tee" pipes get around this, based around the idea of a T-shaped pipe.
#   It returns the left hand side of the pipe to the next stage
rnorm(100) %>%
  matrix(ncol = 2) %>%
  plot() %>%
  str()
# plot() doesn't return anything so str() isn't given anything

rnorm(100) %>%
  matrix(ncol = 2) %T>%
  plot() %>%
  str()
# Here the tee pipe returns the matrix() result to str() instead

# If you're working with functions that don't have a data frame based API (i.e. you pass them individual 
#   vectors, not a data frame and expressions to be evaluated in the context of that data frame),
#   you might find %$% useful. It "explodes" out the variables in a data frame so that you can refer to 
#   them explicitly. This is useful when working with many functions in base R:
mtcars %$%
  cor(disp, mpg)
# (I'm not totally sure what this means, but good to know)

# When assigning, you can use the %<>% operator
# So this...
mtcars <- mtcars %>% 
  transform(cyl = cyl * 2)
# Becomes this...
mtcars %<>% transform(cyl = cyl * 2)
# He doesn't like this because it seems less clear than explicitly doing it
