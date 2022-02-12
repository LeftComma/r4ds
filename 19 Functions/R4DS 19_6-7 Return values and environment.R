
# Two important thoughts when returning a value
# Does returning early make your function easier to read?
# Can you make the function pipeable?

# What is returned is usually the last statment it evaluates
# You can return early, this should generally be done when there's a simpler solution
# This might be because the inputs are empty:
complicated_function <- function(x, y, z) {
  if (length(x) == 0 || length(y) == 0) {
    return(0)
  }
  
  # Complicated code here
}

# If the simple solution comes last, it might be more readable if you rearrange the function


# For piping, there are two types of pipable functions. Transformations and side-effects
# In transformations, the input object is modified and returned
# In side-effects, some action happens to the object, like drawning a graph.
#   These functions should return the first argument invisibly, so it can be piped
show_missings <- function(df) {
  n <- sum(is.na(df))
  cat("Missing values: ", n, "\n", sep = "")
  
  invisible(df)
}
# The invisible() means the df input doesn't get printed
show_missings(mtcars)

# But it's still there
x <- show_missings(mtcars) 
class(x)
dim(x)

# And it can be piped
mtcars %>% 
  show_missings() %>% 
  mutate(mpg = ifelse(mpg < 20, NA, mpg)) %>% 
  show_missings()


# Environment -------------------------------------------------------------
# This isn't that impactful early on, but important to know
f <- function(x) {
  x + y
} 
# This would throw an error in another language because y isn't defined in the function

# R uses lexical scoping to find a value in the environment if it isn't defined
# So that function is valid
y <- 100
f(10)

# You should avoid creating functions that do this deliberately
# But it means R is ver consistent and unrestrained
# That even means you can change things like the meaning of +
`+` <- function(x, y) {
  if (runif(1) < 0.1) {
    sum(x, y)
  } else {
    sum(x, y) * 1.1
  }
}

table(replicate(1000, 1 + 2))

rm(`+`)









