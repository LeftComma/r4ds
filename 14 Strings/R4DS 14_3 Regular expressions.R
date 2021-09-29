library(tidyverse)


# Regular Expressions involve matching patterns to strings
# The simplest match exact strings
x <- c("apple", "banana", "pear")
str_view(x, "an")

# A full stop matches any character that isn't a new line
str_view(x, ".a.")

# To match a full stop, you use an escape character, the backslash
#   However, we use strings to represent regex's, and backslash is an escape character in strings
#   That means you need two backslashes to represent one in a regular expression
# This looks for a full stop explicitly
str_view(c("abc", "a.c", "bef"), "a\\.c")

# To find a backslash, you need to include four in your regular expression
x <- "a\\b"
str_view(x, "\\\\")

#### Questions ####
# 1. Explain why each of these strings don't match a \: "\", "\\", "\\\"
# "\" escapes the next character in the R string
# "\\" means a backslash makes it to the regex, and so escapes the next character there
# "\\\" The first two backslashes will resolve to a literal backslash in the regular expression, 
#   the third will escape the next character. So in the regular expression, 
#   this will escape some escaped character. (Not sure what "escape some escaped character" means)

# 2. How would you match the sequence "'\
x <- "\"'\\"
writeLines(x)

str_view(x, "\"'\\\\")

# 3. What patterns will the regular expression \..\..\.. match? How would you represent it as a string?
# It would match something in the form .a.B.C


#### Anchors ####
# Regular expressions match any point of a string. But you can anchor them to the start or end
# ^ matches the start of the string
# $ matches the end of the string
x <- c("apple", "banana", "pear")
str_view(x, "^a")
str_view(x, "a$")

# This means you can force a regex to match only whole strings
x <- c("apple pie", "apple", "apple cake")
str_view(x, "apple") # Matches all instances
str_view(x, "^apple$") # Only matches the whole string

# \b matches the boundary between words

#### Questions ####
# 1. How would you match the literal string "$^$"?
x <- "$^$"
str_view(x, "\\$\\^\\$")

# 2. Given the corpus of common words in stringr::words, 
#   create regular expressions that find all words that
# Start with "y"
str_view(words, "^y", match = TRUE)

# End with "x"
str_view(words, "x$", match = TRUE)

# Are exactly three letters long
str_view(words, "^...$", match = TRUE)

# Have seven letters or more
str_view(words, ".......", match = TRUE)


#### Character classes and alternatives ####
# There are other useful tools that match more than one character
# \d matches any digit
# \s matches any whitespace
# [abc] matches a, b, or c
# [^abc] matches anything except a, b, or c
# Importantly, when creating something like \d, you'll need to write it as \\d

# You can also create a character class as an alternative to doing backslashes
# Look for a literal character that normally has special meaning in a regex
str_view(c("abc", "a.c", "a*c", "a c"), "a[.]c")
# This works for most regex metacharacters

# Alternation can be used to pick between alternative patterns using |
str_view(c("grey", "gray"), "gr(e|a)y")

#### Questions ####
# 1. Create regular expressions to find all words that:
# Start with a vowel
str_view(words, "^[aeiou]", match = TRUE)

# Only contain consonants
str_view(words, "^[^aeiou]*$", match = TRUE)

# Ends with "ed" but not "eed"
str_view(words, "[^e]ed$", match = TRUE)

# Ending with "ing" or "ise"
str_view(words, "(ing|ise)$", match = TRUE)

# 2. Empirically verify the rule "i before e except after c"
str_view(words, "[^c]ei", match = TRUE) # NOT TRUE!

# 3. Is "q" always followed by a "u"
str_view(words, "q[^u]", match = TRUE) # YES!
# Not in the English language though, e.g. burqa, cinq, qwerty

# 4. Write a regular expression that matches a word if it's 
#   probably written in British English, not American English.
str_view(words, "ou|ise$|ae|oe|yse$", match = TRUE)

# 5. Create a regular expression that will match telephone numbers 
#   as commonly written in your country.
str_view(x, "[+]44")


#### Repetition ####
# Here we can control how many times a pattern matches
# ? = 0 or 1
# + = 1 or more
# * = 0 or more

x <- "1888 is the longest year in Roman numerals: MDCCCLXXXVIII"
str_view(x, "CC?")
str_view(x, "CC+")
str_view(x, 'C[LX]+')

# By default these only apply to the thing directly before them
# So colou?r matches US or British spellings
# This means most uses will need brackets

# You can also specify number of repetitions exactly
# {n} = exactly n
# {n,} = n or more
# {,m} = at most m
# {n,m} = between n and m

str_view(x, "C{2}")
str_view(x, "C{2,}")
str_view(x, "C{2,3}")

# These matches are by default greedy, they'll match the longest string possible
# You can make them lazy by putting a ? after them
str_view(x, 'C{2,3}?')
str_view(x, 'C[LX]+?')


#### Questions ####
# 1. Describe the equivalents of ?, +, * in {m,n} form
# ? = {0,1}
# + = {1,}
# * = {0,}

# 2. Describe in words what these regular expressions match
# ^.*$ matches any string
#   "\\{.+\\}" matches a curly open bracket, one or more letters, then a curley close bracket
# \d{4}-\d{2}-\d{2} # matches 4 digits, followed by a dash, followed by 2 digits, then dash, then two more digits
# "\\\\{4}" # matches 4 backslashes

# 3.Create regular expressions to find all words that:
# Start with three consonants.
str_view(words, "^[^aeiou]{3}", match = TRUE)

# Have three or more vowels in a row
str_view(words, "[aeiou]{3,}", match = TRUE)

# Have two or more vowel-consonant pairs in a row.
str_view(words, "(([^aeiou][aeiou]){2,})|(([aeiou][^aeiou]){2,})", match = TRUE)


#### Grouping and backreferences ####
# Parenthases create a "captured group" which stores the part of the string that matches
#   that bit of the regex. These are numbered and can be referred to.
#   Referring to a group matches that expression again
# For example, this matches repeated pairs of letters in fruits
str_view(fruit, "(..)\\1", match = TRUE)


#### Questions ####
# 1. Describe, in words, what these expressions will match
# (.)\1\1 matches the same letter three times in a row
# "(.)(.)\\2\\1" matches a mirrored pair of letters, like "caac"
# (..)\1 matches a repeated pair of letters
# "(.).\\1.\\1" matches a string of letters in the form axaya where x and y are anything
# "(.)(.)(.).*\\3\\2\\1" matches a word with three mirrored letters around any number of letters inside

# 2. Construct regular expressions to match words that
# Start and end with the same character.
str_view(words, "^(.).*\\1$", match = TRUE)

# Contain a repeated pair of letters (e.g. "church" contains "ch" repeated twice.)
str_view(words, "(..).*\\1", match = TRUE)

# Contain one letter repeated in at least three places (e.g. "eleven" contains three "e"s.)
str_view(words, "(.).*\\1.*\\1", match = TRUE)

