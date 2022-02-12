
# The arguments to a function are typically either the data to compute or the details of how to compute
# E.g. in t.test(), the data are x and y, and the details are alternative, mu, paired, 
#   var.equal and conf.level. In log() the data is x and the mean is the base of the logarithm

# Data arguments should come first and details arguments should usually have defaults
# Compute confidence interval around mean using normal approximation
mean_ci <- function(x, conf = 0.95) {
  se <- sd(x) / sqrt(length(x))
  alpha <- 1 - conf
  mean(x) + se * qnorm(c(alpha / 2, 1 - alpha / 2))
}

x <- runif(100)
mean_ci(x)
mean_ci(x, conf = 0.99)

# The default should usually be the most common or safest option

# These are some common, sort, names for arguments
# x, y, and z: vectors
# w: vector of weights
# df: data frame
# i, j: numeric indices (usually rows and columns)
# n: length, or number of rows
# p: number of columns
# You can also match R functions, like using na.rm for removing missing values


# Checking values ---------------------------------------------------------
# Sometimes you might not remember how old functions work, and you might make a mistake
# For example, this calculates a weighted mean
wt_mean <- function(x, w) {
  sum(x * w) / sum(w)
}

# If you give it vectors of different lengths, you don't get an error because
#   R recycles vectors
wt_mean(1:6, 1:3)

# To prevent things you don't want happening, you can make them throw an error
wt_mean <- function(x, w) {
  if (length(x) != length(w)) {
    stop("`x` and `w` must be the same length", call. = FALSE)
  }
  sum(w * x) / sum(w)
}

# However there is a trade-off between robustness and effort
# Adding na.rm checks adds a lot of work for little gain
wt_mean <- function(x, w, na.rm = FALSE) {
  if (!is.logical(na.rm)) {
    stop("`na.rm` must be logical")
  }
  if (length(na.rm) != 1) {
    stop("`na.rm` must be length 1")
  }
  if (length(x) != length(w)) {
    stop("`x` and `w` must be the same length", call. = FALSE)
  }
  
  if (na.rm) {
    miss <- is.na(x) | is.na(w)
    x <- x[!miss]
    w <- w[!miss]
  }
  sum(w * x) / sum(w)
}

# stopifnot() is a useful compromise
wt_mean <- function(x, w, na.rm = FALSE) {
  stopifnot(is.logical(na.rm), length(na.rm) == 1)
  stopifnot(length(x) == length(w))
  
  if (na.rm) {
    miss <- is.na(x) | is.na(w)
    x <- x[!miss]
    w <- w[!miss]
  }
  sum(w * x) / sum(w)
}

wt_mean(1:6, 6:1, na.rm = "foo")


# Dot-dot-dot -------------------------------------------------------------
# Some functions take an arbitrary number of inputs
# These use the argument ... 
# This is very useful when you want to pass arguments on to another function
commas <- function(...) stringr::str_c(..., collapse = ", ")
commas(letters[1:10])

rule <- function(..., pad = "-") {
  title <- paste0(...)
  width <- getOption("width") - nchar(title) - 5
  cat(title, " ", stringr::str_dup(pad, width), "\n", sep = "")
}
rule("Important output")

# However, misspelled arguments don't raise an error
x <- c(1, 2)
sum(x, na.mr = TRUE)

# Use list(...) to capture the values of the ...


# Lazy evaluation ---------------------------------------------------------
# Arguments in R aren't computed until they're needed
# If they're never called, they're never used


#### Questions ####
# 1. What does commas(letters, collapse = "-") do? Why?
# It breaks. Not sure why
commas(letters[1:10], collapse = "-")

# It's because collapse is passed to str_C(), which already has collapse defined
# It would be as if you did this: str_c(letters, collapse = "-", collapse = ", ")

# 2. It'd be nice if you could supply multiple characters to the pad argument, 
#   e.g. rule("Title", pad = "-+"). Why doesn't this currently work? How could you fix it?
# It doesn't work because the function would work out with width incorrectly
#   You could use str_trunc() to make the string shorter and str_length to work
# out how long the pad is
rule <- function(..., pad = "-") {
  title <- paste0(...)
  width <- getOption("width") - nchar(title) - 5
  padding <- str_dup(
    pad,
    ceiling(width / str_length(title))
  ) %>%
    str_trunc(width)
  cat(title, " ", padding, "\n", sep = "")
}

# 3. What does the trim argument to mean() do? When might you use it?
# It's the fraction of observations to take from each end. 
#   You might use it if you have outliers

# 4. The default value for the method argument to cor() is 
#   c("pearson", "kendall", "spearman"). What does that mean? What value is used by default?
# They're different types of correlation, the method can take any one of them
# Pearson is default
