
# This is some code without a function
df <- tibble::tibble(
  a = rnorm(10),
  b = rnorm(10),
  c = rnorm(10),
  d = rnorm(10)
)

# It involves repetition, which can lead to mistakes
# And make things harder to read
df$a <- (df$a - min(df$a, na.rm = TRUE)) / 
  (max(df$a, na.rm = TRUE) - min(df$a, na.rm = TRUE))
df$b <- (df$b - min(df$b, na.rm = TRUE)) / 
  (max(df$b, na.rm = TRUE) - min(df$a, na.rm = TRUE))
df$c <- (df$c - min(df$c, na.rm = TRUE)) / 
  (max(df$c, na.rm = TRUE) - min(df$c, na.rm = TRUE))
df$d <- (df$d - min(df$d, na.rm = TRUE)) / 
  (max(df$d, na.rm = TRUE) - min(df$d, na.rm = TRUE))

# Lets re-write it as a function
# We need to first work out the number of inputs. Here it's 1
(df$a - min(df$a, na.rm = TRUE)) /
  (max(df$a, na.rm = TRUE) - min(df$a, na.rm = TRUE))

# You can then rewrite it using generic names
x <- df$a
(x - min(x, na.rm = TRUE)) / (max(x, na.rm = TRUE) - min(x, na.rm = TRUE))

# In this code we use the range multiple times, so it makes sense to do that first
rng <- range(x, na.rm = TRUE)
(x- rng[1]) / (rng[2] - rng[1])
# Pulling the steps apart makes it easier to see what the code is doing

# Now we can put it into a function
rescale01 <- function(x) {
  rng <- range(x, na.rm = TRUE)
  (x- rng[1]) / (rng[2] - rng[1])
}

# We can then test it
rescale01(c(0, 5, 10))
rescale01(c(1, 2, 3, NA, 5))
rescale01(c(-10, 0, 10))

# A function needs a name, an input, and a body of code
# It's generally easier to start with working code and then put it into a function

# This is our original code after we made the function
df$a <- rescale01(df$a)
df$b <- rescale01(df$b)
df$c <- rescale01(df$c)
df$d <- rescale01(df$d)

# Another advantage is we only need to change one thing if we want to
# Say if some of our variables include infinite units
x <- c(1:10, Inf)
rescale01(x)

# All we have to do is change the function
rescale01 <- function(x) {
  rng <- range(x, na.rm = TRUE, finite = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}
rescale01(x)


#### Questions ####
# 1. Why is TRUE not a parameter to rescale01()? 
#   What would happen if x contained a single missing value, and na.rm was FALSE?
# TRUE isn't a parameter because it's within the range function
# If na.rm = FALSE, then all the values would be NA if there's a single NA going in
rescale01 <- function(x) {
  rng <- range(x, na.rm = FALSE)
  (x- rng[1]) / (rng[2] - rng[1])
}
rescale01(c(1, 2, 3, NA, 5))

# 2. In the second variant of rescale01(), infinite values are left unchanged. 
#   Rewrite rescale01() so that -Inf is mapped to 0, and Inf is mapped to 1.
# Not sure, I tried using if statements but that didn't work
rescale01 <- function(x) {
  rng <- range(x, na.rm = TRUE, finite = TRUE)
  y <- (x - rng[1]) / (rng[2] - rng[1])
  y[y == -Inf] <- 0 # Select the variables of interest and then change them
  y[y == Inf] <- 1
}
rescale01(c(1:10, Inf))

# 3. Practice turning the following code snippets into functions. 
#   Think about what each function does. What would you call it? 
#   How many arguments does it need? Can you rewrite it to be more expressive or less duplicative?
mean(is.na(x))

# 1 argument, quite simple I think, works out the percentage of an input is NA values
how_many_na <- function(x) {
  mean(is.na(x))
}
# Test it with a vector with three things, one of which is NA
how_many_na(c(1:2, NA))


x / sum(x, na.rm = TRUE)

# Works out what percent of the total each number is
percent_of_total <- function(x) {
  x / sum(x, na.rm = TRUE)
}

# 1 + 2 is 3, so 1 is 0.33 of that and 2 is 0.67 of that. NA doesn't change anything
percent_of_total(c(1:2, NA))


sd(x, na.rm = TRUE) / mean(x, na.rm = TRUE)

# Divides the sd by the mean
sd_divide_by_mean <- function(x) {
  y <- na.omit(x) # We can remove the na values first (this is drop_na() in tidyr)
  sd(y) / mean(y)
}

sd_divide_by_mean(c(1:5))

# 4. Write your own functions to compute the variance and skewness of a numeric vector. 
x <- c(1:10)
var(x) # This is the variance using another function

# This calculates the variance
1/(length(x) - 1) * sum((x - mean(x, na.rm = TRUE))^2)

# This is now kinda following from them because I looked at theirs to see if I could use mean()
#   and got kinda confused
variance <- function(x, na.rm = TRUE) {
  n <- length(x) # save length to a variable
  m <- mean(x) # save mean to a variable
  sq_err <- (x - m)^2 # work out the square error (the right half of the above equation)
  sum(sq_err) / (n - 1) # put it all together and rearrange, dividing the right half by the left
}

variance(x)
variance(1:12)
var(1:12)
variance(1:6, NA)


# Do the same for skew:
x <- c(1, 2, 5, 100)

# This code works out skew correctly
1 / (length(x) -2) * sum((x - mean(x))^3) / (variance(x)^(3/2))

# This is the function
skew <- function(x, na.rm = TRUE) {
  n <- length(x)
  m <- mean(x)
  cube_err <- (x - m)^3
  v <- var(x)
  sum(cube_err) / (n - 2) / v ^ (3 / 2)
}

# It works!
skew(c(1, 2, 5, 100))
# It doesn't handle NAs, but neither does their example one

# 5. Write both_na(), a function that takes two vectors of the same length 
#   and returns the number of positions that have an NA in both vectors.
x <- c(1, 2, NA, 4, NA, 6, NA)
y <- c(1, 2, NA, NA, 5, 6, NA)

both_na <- function(x, y) {
  z <- is.na(x) & is.na(y)
  sum(z)
}

both_na(c(NA, 2, 3), c(NA, NA, 3))
both_na(x, y)

# 6. What do the following functions do? Why are they useful even though they are so short?
is_directory <- function(x) file.info(x)$isdir # Tells you if something is a directory
is_readable <- function(x) file.access(x, 4) == 0 # Tells you if something is readable
# Presumably useful because you can put a lot of files through them, and their names are much clearer

# 7. Read "Little Bunny Foo Foo", extend the original pipes example and use functions to reduce duplication
# https://en.wikipedia.org/wiki/Little_Bunny_Foo_Foo
threat <- function(chances) {
  give_chances(
    from = Good_Fairy,
    to = foo_foo,
    number = chances,
    condition = "Don't behave",
    consequence = turn_into_goon
  )
}

lyric <- function() {
  foo_foo %>%
    hop(through = forest) %>%
    scoop(up = field_mouse) %>%
    bop(on = head)
  
  down_came(Good_Fairy)
  said(
    Good_Fairy,
    c(
      "Little bunny Foo Foo",
      "I don't want to see you",
      "Scooping up the field mice",
      "And bopping them on the head."
    )
  )
}

lyric()
threat(3)
lyric()
threat(2)
lyric()
threat(1)
lyric()
turn_into_goon(Good_Fairy, foo_foo)
