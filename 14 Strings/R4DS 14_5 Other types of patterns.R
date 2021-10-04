library(tidyverse)

# When you use a pattern that's a string, it's automattcally wrapped in a call to regex()
str_view(fruit, "nana")
# Is short for:
str_view(fruit, regex("nana"))

# This means you can use other aspects of regex to control details
# ignore_case = TRUE ignores the case of the text
bananas <- c("banana", "Banana", "BANANA")
str_view(bananas, "banana")
str_view(bananas, regex("banana", ignore_case = TRUE))

# multiline = TRUE means ^ and $ match the start and end of each line rather than of the whole string
x <- "Line 1\nLine 2\nLine 3"
str_extract_all(x, "^Line")[[1]]
str_extract_all(x, regex("^Line", multiline = TRUE))[[1]]

# comments = TRUE lets you use comments to make complex regex's more readable
#   spaces and everything after # are ignored. To include a space you need to escape it
phone <- regex("
  \\(?     # optional opening parens
  (\\d{3}) # area code
  [) -]?   # optional closing parens, space, or dash
  (\\d{3}) # another three numbers
  [ -]?    # optional space or dash
  (\\d{3}) # three more numbers
  ", comments = TRUE)

str_match("514-791-8141", phone)

# dotall = TRUE lets . match everything, including \n

# There are also alternatives to regex()
# fixed() matches specified sequences of bytes. It works at a very low level, ignoring
#   all special regex language.
#   This means it can be much faster
# A quick benchmark here shows that it's 3x faster
microbenchmark::microbenchmark(
  fixed = str_detect(sentences, fixed("the")),
  regex = str_detect(sentences, "the"),
  times = 20
)

# However because it works on bytes, it can be tricky with non-english data
#   because things that look the same can be represented differently
a1 <- "\u00e1"
a2 <- "a\u0301"
c(a1, a2)
a1 == a2

# coll() solves that problem, by matching based on standard collation rules
# It takes a locale argument for which set of rules it should follow
# This bit doesn't actually work for me I'm not sure why
i <- c("I", "I", "i", "i")

str_subset(i, coll("i", ignore_case = TRUE))
str_subset(i, coll("i", ignore_case = TRUE, locale = "tr"))
# However, coll() is relatively slow

# boundary() can also be used with other functions besides str_split()
x <- "This is a sentence."
str_view_all(x, boundary("word"))
str_extract_all(x, boundary("word"))


#### Questions ####
# 1. How would you find all strings containing \ with regex() vs. with fixed()?
# With regex() you would need four backslashes, with fixed() you'd only need two
str_subset(c("a\\b", "ab"), "\\\\")
str_subset(c("a\\b", "ab"), fixed("\\"))

# 2. What are the five most common words in sentences?
# unlist() was the part of this I didn't get, I could do the rest though
tibble(word = unlist(str_extract_all(sentences, boundary("word")))) %>%
  mutate(word = str_to_lower(word)) %>%
  count(word, sort = TRUE) %>%
  head(5)
