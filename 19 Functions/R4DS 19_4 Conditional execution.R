
 # If statements look like this
if (condition) {
  # Code if true
} else if (condition2) {
  # Code if condition isn't true but condition 2 is
} else {
  # Code if both false
}

# This gives some more info
?`if`

# This is a function that tells you whether each element of a vector is named
has_name <- function(x) {
  nms <- names(x)
  if (is.null(nms)) {
    rep(FALSE, length(x))
  } else {
    !is.na(nms) & nms != ""
  }
}


# Conditions have to be TRUE or FALSE
# You can use || or && to combine multiple operators (Not | or & as these are vectorised)
# If you have a logical vector, use any() or all() to collapse it into a single value

# == is vectorised. You can check the length is 1 already, collapse with all() or any(),
#   or use identical(). This is very strict, dplyr::near() is another option

# You can also chain if statements together
# However, you shouldn't do it too many times
# If you have a long chain you can replace it with switch(), which lets you pick from a range
#   of options and do different things based on that
function(x, y, op) {
  switch(op,
    plus = x + y,
    minus = x - y,
    times = x * y,
    divide = x / y,
    stop("Unknown op!")
  )
}
# cut() is another useful function that makes continuous variables discrete

# if and function are almost always followed by curley brackets, and the contents indented
# The closing bracket should be on its own line, unless followed by else
# You can drop the curly brackets for very short, one-line if statements
y <- 10
x <- if (y < 20) "Too low" else "Too high"


#### Questions ####
# 1. What's the difference between if and ifelse()? 
#   Carefully read the help and construct three examples that illustrate the key differences.
# I'm pretty sure the key difference is that ifelse() tests each element in a vector
#   whereas if tests a single condition
if
ifelse()

# 2. Write a  greeting function that says "good morning", "good afternoon", 
#   or "good evening", depending on the time of day.
greeting <- function(time = lubridate::now()) {
  hour <- lubridate::hour(time)
  if (hour < 12) {
    "good morning"
  } else if (hour < 18) {
    "good afternoon"
  } else {
    "good evening"
  }
}

greeting()
greeting(lubridate::ymd_h("2017-01-08:05"))

# 3. mplement a fizzbuzz function. It takes a single number as input. If the number is 
#   divisible by three, it returns "fizz". If it's divisible by five it returns "buzz". 
#   If it's divisible by three and five, it returns "fizzbuzz". Otherwise, it returns the number. 
#   Make sure you first write working code before you create the function.
# I think this is how they want me to do it
fizzbuzz <- function(x) {
  if (x %% 3 == 0 && x %% 5 == 0) {
    "fizzbuzz"
  } else if (x %% 5 == 0) {
    "buzz"
  } else if (x %% 3 == 0) {
    "fizz"
  } else {
    x
  }
}

# This is the more flexible way from the Tom Scott video (I think)
# I've also adapted it to work with a vector input because why not
fizzbuzz_pro <- function(z) {
  for (x in z) {
    y <- ""
    if (x %% 3 == 0) {
      y <- paste(y,"fizz",sep="")
    }
    if (x %% 5 == 0) {
      y <- paste(y,"buzz",sep="")
    }
    if (y == "") {
      y <- x
    }
    print(y)
  }
}

fizzbuzz_pro(1:16)

# They did it a different way (mine still technically has less repetition):
fizzbuzz_vec <- function(x) {
  case_when(!(x %% 3) & !(x %% 5) ~ "fizzbuzz",
            !(x %% 3) ~ "fizz",
            !(x %% 5) ~ "buzz",
            TRUE ~ as.character(x)
  )
}
fizzbuzz_vec(c(0, 1, 2, 3, 5, 9, 10, 12, 15))

# OR:
fizzbuzz_vec2 <- function(x) {
  y <- as.character(x)
  # put the individual cases first - any elements divisible by both 3 and 5
  # will be overwritten with fizzbuzz later
  y[!(x %% 3)] <- "fizz"
  y[!(x %% 3)] <- "buzz"
  y[!(x %% 3) & !(x %% 5)] <- "fizzbuzz"
  y
}
fizzbuzz_vec2(c(0, 1, 2, 3, 5, 9, 10, 12, 15))

# 4. How could you use cut() to simplify this set of nested if-else statements?
if (temp <= 0) {
  "freezing"
} else if (temp <= 10) {
  "cold"
} else if (temp <= 20) {
  "cool"
} else if (temp <= 30) {
  "warm"
} else {
  "hot"
}

temp <- seq(-10, 50, by = 5)
cut(temp, c(-Inf, 0, 10, 20, 30, Inf),
    right = TRUE,
    labels = c("freezing", "cold", "cool", "warm", "hot")
)

# To have intervals open on the left using < :
temp <- seq(-10, 50, by = 5)
cut(temp, c(-Inf, 0, 10, 20, 30, Inf),
    right = FALSE,
    labels = c("freezing", "cold", "cool", "warm", "hot")
)
# cut() is useful because it works on vectors, whereas if only works on a single thing

# 5. What happens if you use switch() with numeric values?
# If the first argument is numeric n, it'll return the nth argument following it
switch(1, "apple", "banana", "cantaloupe")
switch(2, "apple", "banana", "cantaloupe")
# If you use a non-integer, it will truncate its value (not round!)
switch(2.8, "apple", "banana", "cantaloupe")

# 6. What does this switch() call do? What happens if x is "e"?
x <- "e"
switch(x,
       a = ,
       b = "ab",
       c = ,
       d = "cd"
)
# It returns nothing if x is "e"

# To figure out what it does we'll make it a function
switcheroo <- function(x) {
  switch(x,
         a = ,
         b = "ab",
         c = ,
         d = "cd"
  )
}
switcheroo("a")
switcheroo("b")
switcheroo("c")
switcheroo("d")
switcheroo("e")
switcheroo("f")
# switch() acts like this because when it encounters an argument with a missing value,
#   it returns the value of the next argument with a non-missing value.
#   If the object it's given doesn't match any arguments, it will either return an
#   unnamed default or NULL

# A clearer way to write the above code is:
switch(x,
       a = "ab",
       b = "ab",
       c = "cd",
       d = "cd",
       NULL # value to return if x not matched
)