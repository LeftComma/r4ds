library(tidyverse)
library(microbenchmark)

df <- tibble(
  a = rnorm(10),
  b = rnorm(10),
  c = rnorm(10),
  d = rnorm(10)
)

# To compute the median of each column:
median(df$a)
median(df$b)
median(df$c)
median(df$d)
# However this is very repetitive

# We could do it in a for loop instead
output <- vector("double", ncol(df))  # 1. output
for (i in seq_along(df)) {            # 2. sequence
  output[[i]] <- median(df[[i]])      # 3. body
}
output

# 1. The output is a vector. You should make sure it has enough space beforehand,
# otherwise the loop will be very slow
# 2. The sequence determins what to loop over. seq_along() does a similar thing to,
# 1:length(l), but it handles vectors of length 0 properly
# 3. The body is the code that actually does the work


#### Questions ####
# 1. Write for loops to:
#   Compute the mean of every column in mtcars
output <- vector("double", ncol(mtcars))
for (i in seq_along(mtcars)) {
  output[[i]] <- mean(df[[i]])
}
output

#   Determine the type of each column in nycflights13::flights
flights <- nycflights13::flights

output <- vector("list", ncol(flights))
names(output) <- names(flights)
for (i in names(flights)) {
  output[[i]] <- class(flights[[i]])
}
output

#   Compute the number of unique values in each column of iris.
iris

iris_uniq <- vector("double", ncol(iris))
names(iris_uniq) <- names(iris)
for (i in names(iris)) {
  iris_uniq[[i]] <- length(unique(iris[[i]])) # could also use n_distinct
}
iris_uniq

#   Generate 10 random normals from distributions with means of -10, 0, 10 and 100
means <- c(-10, 0, 10, 100)
for (i in seq_along(means)) {
  print(rnorm(10, i))
}

# 2. Eliminate the for loop in each of the following examples by taking advantage 
#   of an existing function that works with vectors
out <- ""
for (x in letters) {
  out <- stringr::str_c(out, x)
}
out

# Answer:
stringr::str_c(letters, collapse = "")

x <- sample(100)
sd <- 0
for (i in seq_along(x)) {
  sd <- sd + (x[i] - mean(x)) ^ 2
}
sd <- sqrt(sd / (length(x) - 1))
sd

# Answer:
sd(x)

x <- runif(100)
out <- vector("numeric", length(x))
out[1] <- x[1]
for (i in 2:length(x)) {
  out[i] <- out[i - 1] + x[i]
}
x
out

# Answer:
cumsum(x)
all.equal(cumsum(x), out) # This shows the two are the same


# 3. Combine function writing and for loops
#   Write a for loop that prints() the lyrics to the children's song "Alice the camel"
humps <- c("five", "four", "three", "two", "one", "no")
for (i in humps) {
  cat(str_c("Alice the camel has ", rep(i, 3), " humps.",
            collapse = "\n"
  ), "\n")
  if (i == "no") {
    cat("Now Alice is a horse.\n")
  } else {
    cat("So go, Alice, go.\n")
  }
  cat("\n")
}

#   Convert the nursery rhyme "ten in the bed" to a function. 
#   Generalize it to any number of people in any sleeping structure.
# Set the number of people
number <- 4

# Set the sleeping structure
structure <- "car"

numbers <- as.character(number:1)

for (i in numbers) {
  cat(str_c("There were ", i, " in the ", structure, "\n"))
  cat("and the little one said\n")
  if (i == "1") {
    cat("I'm lonely...")
  } else {
    cat("Roll over, roll over\n")
    cat("So they all rolled over and one fell out.\n")
  }
  cat("\n")
}

#   Convert the song "99 bottles of beer on the wall" to a function. 
#   Generalize to any number of any vessel containing any liquid on surface.
bottles <- function(n) {
  if (n > 1) {
    str_c(n, " ", container, "s")
  } else if (n == 1) {
    str_c("1 ", container)
  } else {
    str_c("no more ", container, "s")
  }
}

beer_bottles <- function(total_bottles) {
  # print each lyric
  for (current_bottles in seq(total_bottles, 0)) {
    # first line
    cat(str_to_sentence(str_c(bottles(current_bottles), " of ", substance, " on the wall, ", 
                              bottles(current_bottles), " of ", substance, ".\n")))   
    # second line
    if (current_bottles > 0) {
      cat(str_c(
        "Take one down and pass it around, ", bottles(current_bottles - 1),
        " of ", substance, " on the wall.\n"
      ))          
    } else {
      cat(str_c("Go to the store and buy some more, ", bottles(total_bottles),
                " of ", substance, " on the wall.\n"))                }
    cat("\n")
  }
}

substance <- "mud"
container <- "pie"

beer_bottles(3)

# 4. It's common to see for loops that don't preallocate the output and instead 
#   increase the length of a vector at each step. How does this affect performance?
add_to_vector <- function(n) {
  output <- vector("integer", 0)
  for (i in seq_len(n)) {
    output <- c(output, i)
  }
  output
}

add_to_vector_2 <- function(n) {
  output <- vector("integer", n)
  for (i in seq_len(n)) {
    output[[i]] <- i
  }
  output
}

timings <- microbenchmark(add_to_vector(10000), add_to_vector_2(10000), times = 10)
timings
# Here, appending takes about 325 times longer