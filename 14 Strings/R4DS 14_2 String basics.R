library(tidyverse)

# Use a backslash to include any characters that would mess up the string
x <- c("\"", "\\")
x

# writeLines() lets you see the actual presentation of the string
writeLines(x)

# You can see all the special characters by looking at the help like this
?'"'

# Strings like these are ways of writing non-english characters which would work on any platform
x <- "\u00b5"
x

# Base R has a lot of string functions, but we'll just use stringr to be consistent
# str_length() tells you the length of a string
str_length(c("a", "R for data science", NA))
# Just typing str_ lets you see all the stringr functions

# str_c() combines strings
str_c("x", "y", "z")

# You can control how they're combined with the sep argument
str_c("x", "y", sep = ", ")

# Like usual, NA values are contaigous (Combining them with things creates more NAs)
x <- c("abc", NA)
str_c("|-", x, "-|")

# str_replace_na() lets you treat them as strings
str_c("|-", str_replace_na(x), "-|")

# The function is vectorised, and recycles shorter vectors to match the longest
str_c("prefix-", c("a", "b", "c"), "-suffix")

# Objects of length 0 are silently dropped
# This can be combined with an if statement
name <- "Hadley"
time_of_day <- "morning"
birthday <- FALSE

str_c(
  "Good ", time_of_day, " ", name,
  if (birthday) " and HAPPY BIRTHDAY",
  "."
)

# The collapse argument turns a vector of strings into a single string
str_c(c("x", "y", "z"), collapse = ", ")


# str_sub() extracts part of a string based on (inclusive) positions
# REMEMBER R INDEXING STARTS AT 1
x <- c("Apple", "Banana", "Pear")
str_sub(x, 1, 3)

# If the string is too short it'll return as much as possible
str_sub("a", 1, 5)

# str_sub() can also be used to modify strings
str_sub(x, 1, 1) <- str_to_lower(str_sub(x, 1, 1))
x


# Locales determine what language's rules the code should follow
# They are specified as ISO 639 language codes, with 2-3 letter abbreviations
# For example, Turkish has two i's, with different categorisation rules
str_to_upper(c("i", "i"))

str_to_upper(c("i", "i"), locale = "tr") # This still didn't work for some reason

# Other operations like sorting are affected by locale
# By default, the OS's locale is used
x <- c("apple", "eggplant", "banana")

str_sort(x, locale = "en") # English
str_sort(x, locale = "haw") # Hawaiian


#### Questions ####
# 1. In code that doesn't use stringr, you'll often see paste() and paste0(). 
#   What's the difference between the two functions? What stringr function are they equivalent to? 
#   How do the functions differ in their handling of NA?
# paste() seperates strings by spaces by default
# paste0() seperates strings by nothing by default
paste("bob", "cat")
paste0("bob", "cat")

# the paste functions convert NA to a string "NA" and then treat it as such
paste("foo", NA)

# 2. In your own words, describe the difference between the sep and collapse arguments to str_c().
# seperate governs what happens when between different arguments
# collapse governs what happens within a single argument given to str_c()
str_c()

# 3. Use str_length() and str_sub() to extract the middle character from a string. 
#   What will you do if the string has an even number of characters?
# If the string is even it just rounds up
x <- "string"
len <- str_length(x) %/% 2
str_sub(x, len, len)

# 4. What does str_wrap() do? When might you want to use it?
# It governs how many characters should go on a line, how big indents should be etc
# It'd be useful if you're printing large paragraphs

# 5. What does str_trim() do? What's the opposite of str_trim()?
# It removes whitespace from the start and end of a string
# The opposite is str_pad()

# Write a function that turns (e.g.) a vector c("a", "b", "c") into the string a, b, and c. 
#   Think carefully about what it should do if given a vector of length 0, 1, or 2.
# Not a very flexible solution
x <- c("a", "b", "c")

# The idea would be to work backwards
x <- str_c(x, collapse = ", ")
str_sub(x, -2) <- str_c(" and ", str_sub(x, -1))

# His method is much more robust
# It's a function that takes the string and deliminator as arguments
str_commasep <- function(x, delim = ",") {
  n <- length(x)
  
  # If the string is empty, return nothing
  if (n == 0) {
    ""
  }
  
  # If it's only got one thing, return that back
  if (n == 1) {
    x
  }
  
  # If there are two things, just add the and, without a comma
  if (n == 2) {
    str_c(x[[1]], "and", x[[2]], sep = " ")
  }
  
  else {
    # If it's more than that, add commas after all but the last element
    not_last <- str_c(x[seq_len(n - 1)], delim)
    # Add and before the last element
    last <- str_c("and", x[[n]], sep = " ")
    # And then combine the two pieces with spaces
    str_c(c(not_last, last), collapse = " ")
  }
}

str_commasep(c("a", "b", "c", "d"))

