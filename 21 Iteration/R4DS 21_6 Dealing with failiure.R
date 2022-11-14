library(tidyverse)

# safely() is similar to try() in base R
# It never throws an error, so lets you test out things
# It returns 2 elements:
# result is the original result, if there was an error it will be NULL
# error is an error object, if there wasn't an error it will be NULL

safe_log <- safely(log)

str(safe_log(10))
str(safe_log("a"))

# safely works with map functions
x <- list(1, 10, "a")
y <- x %>% map(safely(log))
str(y)
# You can transpose this result to get a list with the errors and a list,
# with the outputs
y <- y %>% transpose()
str(y)

# You choose how to handle the errors
# You might want to focus on the values which threw an error
is_ok <- y$error %>% map_lgl(is_null)
x[!is_ok]
# Or just extract the values which didn't
y$result[is_ok] %>% flatten_dbl()

# possibly() is like safely but it always succeeds
# We give it a value to put if there's an error
# Here we want errors to give NA
x <- list(1, 10, "a")
x %>% map_dbl(possibly(log, NA_real_))

# quietly() is similar but it also captures printed output, messages and warnings
x <- list(1, -1)
x %>% map(quietly(log)) %>% str()


# Mapping over multiple arguments -----------------------------------------

# Often you have multiple related inputs that you iterate along in parallel
# map2() and pmap() can do that
# map will let you simulate some random normals with different means
mu <- list(5, 10, -3)
mu %>% 
  map(rnorm, n = 5) %>% 
  str()

# map2 lets you iterate over another vector, such as sd
sigma <- list(1, 5, 10)
map2(mu, sigma, rnorm, n = 5) %>% str()

# Instead of map3, map4 etc there is pmap(), which takes a list of arguments
# Say you also wanted to vary the number of samples
n <- list(1, 3, 5)
args1 <- list(n, mu, sigma)
args1 %>%
  pmap(rnorm) %>% 
  str()

# You can also name the arguments to make it easier to read
args2 <- list(mean = mu, sd = sigma, n = n)
args2 %>% 
  pmap(rnorm) %>% 
  str()

# We could also store the arguments in a data frame
params <- tribble(
  ~mean, ~sd, ~n,
  5,     1,  1,
  10,     5,  3,
  -3,    10,  5
)
params %>% 
  pmap(rnorm)


# You might also want to vary the function itself, not just the args
f <- c("runif", "rnorm", "rpois")
param <- list(
  list(min = -1, max = 1), 
  list(sd = 5), 
  list(lambda = 10)
)
# invoke_map() does this
invoke_map(f, param, n = 5) %>% str()
# The first arg is a list of functions or chr vector of names
# The second is a list of lists giving the args for each function
# Any other arguments are passed to every function

# Doing this with a tribble makes things easier
sim <- tribble(
  ~f,      ~params,
  "runif", list(min = -1, max = 1),
  "rnorm", list(sd = 5),
  "rpois", list(lambda = 10)
)
sim %>% 
  mutate(sim = invoke_map(f, params, n = 10))


# Walk --------------------------------------------------------------------

# walk() is like map but if you want a function for its side effects
# This is particularly for rendering an image or saving a file
x <- list(1, "a", 3)
x %>% 
  walk(print)

# walk2() or pwalk() is usually more useful
# pwalk() could save a vector of plots to a vector of file names
plots <- mtcars %>% 
  split(.$cyl) %>% 
  map(~ggplot(., aes(mpg, wt)) + geom_point())
paths <- stringr::str_c(names(plots), ".pdf")

pwalk(list(paths, plots), ggsave, path = tempdir())
tempdir() # no clue what is up with tempdir

# All the walk functions invisibly return .x - the first argument
# This makes them useful for the middle of pipes
