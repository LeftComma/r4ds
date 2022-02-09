# Be consistent with the naming of function

# For a related group of functions, use a common prefix rather than suffix
# This means autocomplete can show you the group of functions
# Good
input_select()
input_checkbox()
input_text()

# Not so good
select_input()
checkbox_input()
text_input()

# Avoid overwriting existing functions, especially ones in base R

# Use comments to explain the "why" of your code, not the what or how
# What and how should be intuative from reading the code itself
# Comments could point out why you chose this option, what else you tried, what doesn't work etc

# Long lines also break up code clearly:
# Load data ---------------------------------------------------------------
# Ctrl + Shift + R is a keyboard shortcut for creating these headings
# Plot data ---------------------------------------------------------------


#### Questions ####
# Read the source code for each of the following three functions, 
#   puzzle out what they do, and then brainstorm better names.
f1 <- function(string, prefix) {
  substr(string, 1, nchar(prefix)) == prefix
}
f1("string", "str")
# It checks whether the string begins with the prefix
# prefix_checker() might be a better name, or is_prefix() (or has_prefix())

f2 <- function(x) {
  if (length(x) <= 1) return(NULL)
  x[-length(x)]
}
f2(c(2, 3, 4, 3, 2))
# It cuts off the last item in a vector
# remove_last() is a better name (or drop_last())

f3 <- function(x, y) {
  rep(y, length.out = length(x))
}
f3(c(2, 2, 2, 2), c(3, 4))
# It makes the second vector the length of the first
# Repeating values if it's too short, and cutting values if it's too long
# match_length() might be a better name (or recycle() or expand())

# 2. Take a function that you've written recently and spend 5 minutes 
#   brainstorming a better name for it and its arguments.
# I'm going to use the one from the previous chapter
rescale01 <- function(x) {
  rng <- range(x, na.rm = TRUE)
  (x- rng[1]) / (rng[2] - rng[1])
}
# A better name might be normalise01() and x could be vector or something

# 3. Compare and contrast rnorm() and MASS::mvrnorm(). How could you make them more consistent?
# Could change the second one to rnorm_mv() or something like that
rnorm()
MASS:mvrnorm()
# Internally, rnorm() has n, mean and sd, while mvrnorm() has n, mu, Sigma
# These don't match with each other, mean/mu could be changed
# but the naming is internally consistent

# 4. Make a case for why norm_r(), norm_d() etc would be better than 
#   rnorm(), dnorm(). Make a case for the opposite.
# norm_r() and norm_d() groups by the distribution
# rnorm() and d_norm() groups by the action performed
# r* functions sample from distributions
# d* functions calculate probability densities or mass of a distribution



