library(tidyverse)

# Here we'll learn the stringr functions that help you actually work with regex and matches

#### Detect Matches ####
# str_detect() detects matches
x <- c("apple", "banana", "pear")
str_detect(x, "e")

# It can be useful to just use str_detect and logical operators instead of more complext regexs
no_vowels_1 <- !str_detect(words, "[aeiou]")
no_vowels_2 <- str_detect(words, "^[^aeiou]+$")
identical(no_vowels_1, no_vowels_2)

# To extract the words that match your string, you can use logical subsetting
words[str_detect(words, "x$")]
# Or the subset function
str_subset(words, "x$")

# Whent the strings are part of a df though, you'll want to use a filter
df <- tibble(
  word = words, 
  i = seq_along(word) # just creates a sequence of numbers
)

df %>% 
  filter(str_detect(word, "x$"))

# str_count() tells you how many matches there are in a string
x <- c("apple", "banana", "pear")
str_count(x, "a")

# On average, how many vowels per word?
mean(str_count(words, "[aeiou]"))

# You can often use str_count() with mutate
df %>% 
  mutate(
    vowels = str_count(word, "[aeiou]"),
    consonants = str_count(word, "[^aeiou]")
  )

# Regular expressions never overlap, they're always distinct
str_view_all("abababa", "aba")
# Lots of stringr functions come in pairs. One for a single match, and a corresponding _all version


#### Questions ####
# 1. For each of the following challenges, try solving it by using both a single 
#   regular expression, and a combination of multiple str_detect() calls.
# Find all words that start or end with x
x <- str_detect(words, "^x|x$")
y <- str_detect(words, "^x") | str_detect(words, "x$")
identical(x, y)

# Find all words that start with a vowel and end with a consonant
x <- str_detect(words, "^[aeiou].*[^aeiou]$")
y <- str_detect(words, "^[aeiou]") & str_detect(words, "[^aeiou]$")
identical(x, y)

# Are there any words that contain at least one of each different vowel?
# Doing this as a regex is very complicated (this is their working)
pattern <-
  cross(rerun(5, c("a", "e", "i", "o", "u")),
        .filter = function(...) {
          x <- as.character(unlist(list(...)))
          length(x) != length(unique(x))
        }
  ) %>%
  map_chr(~str_c(unlist(.x), collapse = ".*")) %>%
  str_c(collapse = "|")

# It's much more readable to just do it as a group of detects
sum(str_detect(words, "[a]") & str_detect(words, "[e]") & 
      str_detect(words, "[i]") & str_detect(words, "[o]") & str_detect(words, "[u]"))

# 2. What word has the highest number of vowels? 
#  What word has the highest proportion of vowels? (Hint: what is the denominator?)
# There are 8 words with 5 vowels each
# "a" has the highest proportion of vowels, after that it's "area" and "idea"
df %>%
  mutate(
    vowels = str_count(word, "[aeiou]"),
    consonants = str_count(word, "[^aeiou]"),
    total = vowels + consonants,
    prop = vowels / total
  ) %>%
  arrange(desc(prop))

# For count of vowels there's a much simpler way:
vowels <- str_count(words, "[aeiou]")
words[which(vowels == max(vowels))]


#### Extract Matches ####
# To do extraction we're going to use the Harvard sentences set
head(sentences)

# Lets find all the sentences that contain a colour
colours <- c("red", "orange", "yellow", "green", "blue", "purple")
colour_match <- str_c(colours, collapse = "|")

# Select only the sentences with a colour
has_colour <- str_subset(sentences, colour_match)
# Then extract the colour to see what it is
matches <- str_extract(has_colour, colour_match)
head(matches)

# str_extract() only lets you see the first match
more <- sentences[str_count(sentences, colour_match) > 1]
str_view_all(more, colour_match)

# You have to add the _all to make it see more than the first
str_extract(more, colour_match)
str_extract_all(more, colour_match)

# simplify turns the result of the _all from a set of lists to a matrix
str_extract_all(more, colour_match, simplify = TRUE)

# Short matches are expanded to the same length as the longest
x <- c("a", "a b", "a b c")
str_extract_all(x, "[a-z]", simplify = TRUE)


#### Questions ####
# 1. In the previous example, you might have noticed that the regular expression 
#   matched "flickered", which is not a colour. Modify the regex to fix the problem.
# Adding a word break fixes that problem
colours <- c("\\bred", "orange", "yellow", "green", "blue", "purple")
colour_match <- str_c(colours, collapse = "|")
more <- sentences[str_count(sentences, colour_match) > 1]
str_view_all(more, colour_match)

# 2. From the Harvard sentences data, extract:
# The first word from each sentence
str_extract(sentences, "[A-Za-z][A-Za-z']*") %>% head()

# All words ending in "ing"
pattern <- "\\b[A-Za-z]+ing\\b"
sentences_with_ing <- str_detect(sentences, pattern)
unique(unlist(str_extract_all(sentences[sentences_with_ing], pattern))) %>%
  head()

# All plurals
unique(unlist(str_extract_all(sentences, "\\b[A-Za-z]{3,}s\\b"))) %>%
  head()