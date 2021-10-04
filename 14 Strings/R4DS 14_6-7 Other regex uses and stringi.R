library(tidyverse)
library(stringi)

# There are two base R functions which can utilise regex
# apropos() searches all objects available from the global environment
#   This can help with finding a function if you can't quite remember the name
apropos("replace")

# dir() lists all the files in a directory that match a pattern
head(dir(pattern = "\\.Rmd$"))
# globs can also be converted to regex using glob2rx()


# Stringi is the underlying package stringr is built on
#   Stringr has the most popular functions while stringi has everything you should
#   ever need (250 functions vs 49). So stringi might have a function if stringr doesn't
# The main difference is the prefix changes from str_ to stri_


#### Questions ####
# 1. Find the stringi functions that:
# Count the number of words
stri_count_words()

# Find duplicate strings
stri_duplicated()

# Generate random text
stri_rand_strings(4, 5) # Generates n random strings of m length
stri_rand_shuffle("The brown fox jumped over the lazy cow.") # Randomly shuffles characters
stri_rand_lipsum(1) # Generates x paragraphs of lorem ipsum text

# 2. How do you control the language that stri_sort() uses for sorting?
# It uses the locale argument, with the languages presented in lowercase, underscore, uppercase format
?stri_sort()

