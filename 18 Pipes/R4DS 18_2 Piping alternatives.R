library(magrittr)


# To understand pipes, we're going to look at different ways to do the same thing
# Using the little bunny poem:
"Little bunny Foo Foo
Went hopping through the forest
Scooping up the field mice
And bopping them on the head"

# The actions are hop, scoop and bop

# We could retell the story in 4 ways..
# 1. Save each intermediate step as a new object.
# 2. Overwrite the original object many times.
# 3. Compose functions.
# 4. Use the pipe.

# Each has advantages and disadvantages
# These aren't real functions, just metaphors
foo_foo <- little_bunny() 


# Intermediate steps
# The simplest option is to save each step
foo_foo_1 <- hop(foo_foo, through = forest)
foo_foo_2 <- scoop(foo_foo_1, up = field_mice)
foo_foo_3 <- bop(foo_foo_2, on = head)

# This forces you to name each one, which makes it cluttered and easy to make mistakes

# However, it doesn't take up more space
diamonds <- ggplot2::diamonds
diamonds2 <- diamonds %>% 
  dplyr::mutate(price_per_carat = price / carat)

pryr::object_size(diamonds) # 3.46 MB
pryr::object_size(diamonds2) # 3.89 MB
pryr::object_size(diamonds, diamonds2) # 3.89 MB
# R only copies things to the new variable if they're modified


# Overwrite the original
foo_foo <- hop(foo_foo, through = forest)
foo_foo <- scoop(foo_foo, up = field_mice)
foo_foo <- bop(foo_foo, on = head)

# The perk is less mistakes from typing
# The issue is debugging is a pain and it's hard to tell what changed each line


# Function composition
# You could just string the functions together
bop(
  scoop(
    hop(foo_foo, through = forest),
    up = field_mice
  ), 
  on = head
)

# However this involves reading from inside out, right to left, which is harder


# Using the pipe
foo_foo %>%
  hop(through = forest) %>%
  scoop(up = field_mice) %>%
  bop(on = head)

# This is a pretty readable way once you know what the %>% means

# Behind the scenes, magrittr does something like this
my_pipe <- function(.) {
  . <- hop(., through = forest)
  . <- scoop(., up = field_mice)
  bop(., on = head)
}
my_pipe(foo_foo)

# So, pipe doesn't work for two types of functions
# 1. Functions that use the current environment
# assign() creates a new variable in the current environment
assign("x", 10)
x

# The pipe creates a temporary environment so doesn't give you what you want
"x" %>% assign(100)
x

# To use it, you'd have to be specific about the environment you're using
env <- environment()
"x" %>% assign(100, envir = env)
x

# 2. Functions that use lazy evaluation. R only computes arguments as the function uses them
# The pipe does things one at a time, which doesn't always work
# tryCatch() helps you capture and handle errors
tryCatch(stop("!"), error = function(e) "An error")

stop("!") %>% 
  tryCatch(error = function(e) "An error")

# Functions like try(), suppressMessages(), and suppressWarnings() in base R can't be used because of this
