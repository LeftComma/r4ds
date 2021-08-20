library(tidyverse)
library(hms)

# Parsing involves taking a vector of strings and converting them to another variable
str(parse_logical(c("TRUE", "FALSE", "NA")))
str(parse_integer(c("1", "2", "3")))
str(parse_date(c("2010-01-01", "1979-10-14")))

# The first argument is a charactor vector
parse_integer(c("1", "231", ".", "456"), na = ".") # na tells you what strings should be treated as missing

# The parse failing gives you a warning
x <- parse_integer(c("123", "345", "abc", "123.45"))

# Multiple parsing failiures can be examined using problems(), which returns a tibble
problems(x)

# There are nine particularly important parsers:
#   parse_logical() and parse_integer() parse logicals and integers respectively
#   parse_double() is a strict number parser and parse_number() is a flexible one
#   parse_character() can help with character encoding
#   parse_factor() creates factors
#   parse_datetime(), parse_date() and parse_time() parses various date and time combinations


# Numbers can get complicated because of three reasons:
#   They're written differently round the world, sometimes a . splits the whole and fractal parts, sometimes a , does
#   They're often surrounded by context markets like £10 or 20%
#   Theyy often contain grouping characters for ledgibility, like 1,000,000

# For the decimal issue, you can specify the decimal mark. The default is a full stop
parse_double("1,23", locale = locale(decimal_mark = ","))

# parse_number() ignores other characters in a string that aren't numbers
parse_number("$100")
parse_number("20%")
parse_number("It cost $123.45")


# Strings can get complicated because they can be encoded in multiple ways
# This function shows the raw representation of a string, in this case it's being encoded in hexadecimal
# The hex is encoded into characters using ASCII
charToRaw("Hadley")

# UTF-8 is a univeral encoding standard that can encode pretty much anything. That's the default in readr()
#   However sometimes you need to deal with older systems that don't understand UFT-8
#   Your strings can end up looking like gibberish
x1 <- "El Ni\xf1o was particularly bad this year"
x2 <- "\x82\xb1\x82\xf1\x82\xc9\x82\xbf\x82\xcd"
x1
x2
# Okay, so this stuff works for me, but I'm just going to follow along anyway 

# You can parse these, by specifying the encoder
parse_character(x1, locale = locale(encoding = "Latin1"))
parse_character(x2, locale = locale(encoding = "Shift-JIS")) # To be fair this one didn't parse properly automatically

# The encoding may be in the data document, if not, you can use guess_encoding()
# It's not perfect but it works. It's better the more text there is
guess_encoding(charToRaw(x1))
guess_encoding(charToRaw(x2))


# Factors are categorical variables that have a known set of possible values
# parse_factor() gets given a vector of known levels, and then can check if there's any difference between these
#   levels and the ones in the text
fruit <- c("apple", "banana") # These are the levels we expect
parse_factor(c("apple", "banana", "bananana"), levels = fruit) # Do these levels match?
# Too many problematic entries should probably be dealt with differently, we'll learn that later


# The dates parsers deal with either a date-time, defined as the number of seconds since midnight 01/01/1970, 
#   a date, number of days since that same day, or a time, the number of seconds since midnight
# parse_datetime() gives you date-time in ISO8601 format, the international standard
#   where the components are organised from biggest to smallest
parse_datetime("2010-10-01T2010")
parse_datetime("20101010") # Omitting a time sets it to midnight

# parse_date() expects a four-digit year, the month and the day in numbers, seperated by - or /
parse_date("2010-10-01")

# parse_time() expects the hour and minutes, split by a :, seconds and am/pm are optional
# Time isn't handled well by base R, so we use the hms package
parse_time("01:10 am")
parse_time("20:10:01")

# You can also specify your own date-time format
# Year: %Y = 4 digits, %y = 2 digits
# Month: %m = 2 digits, %b = abbreviated name (Jan), %B = full name (January)
# Day: %d = 2 digits, %e = optional leading space
# Time: %H 0-23 hour, %I 0-12, %p = AM/PM, %M = minutes, %S = integer seconds, %OS = real seconds,
#   %Z = time zone, %z = offset from UTC (+0800)
# Non-digits: %. = skip a single non-digit character, %* skips any number of non-digit characters

# The best way to check the format is to create a few examples and test them
a <-  "01/02/15"
parse_date(a, "%m/%d/%y")
parse_date(a, "%d/%m/%y")
parse_date(a, "%y/%m/%d")

# If you're working with non-English month names, you change the lang argument
parse_date("1 janvier 2015", "%d %B %Y", locale = locale("fr"))
date_names_langs() # Shows all the possible languages


#### Questions ####
# 1. What are the most important arguments to locale()?
# Probable decimal mark and grouping mark
locale()

# 2. Try setting decimal_mark and grouping_mark to the same character. What happens when the defaults clash?
# Setting them to the same thing throws an error
# If you don't set one then it throws an error too
parse_double("1,000.23", locale = locale(decimal_mark = ",", grouping_mark = ","))

# 3. What do the date_format and time_format options to locale() do?
# They let you change the date and time format
# Not sure of a stiuation where they'd be useful

# 4. Create a locale object that encapsulates the format you'd typically read
l <- locale(date_format = "%d/%m/%y", time_format = "%H:%M")
parse_date("01/01/20", locale = l)

# 5. What's the difference between read_csv() and read_csv2()
# read_csv() uses commas as a seperator, read_csv2() uses semicolons

# 6. What are the most common encodings used in Europe? What are the most common encodings used in Asia?
# Seemingly, online at least, UFT-8 is the most common one

# 7. Generate the correct format string to parse each of the following dates and times:
d1 <- "January 1, 2010"
parse_date(d1, "%B%e, %Y")
d2 <- "2015-Mar-07"
parse_date(d2, "%Y-%b-%d")
d3 <- "06-Jun-2017"
parse_date(d3, "%d-%b-%Y")
d4 <- c("August 19 (2015)", "July 1 (2015)")
parse_date(d4, "%B% %e (%Y)") # This one can't do the second date
d5 <- "12/30/14" # Dec 30, 2014
parse_date(d5, "%m/%d/%y")
t1 <- "1705"
parse_time(t1, "%H%M")
t2 <- "11:15:10.12 PM"
parse_time(t2, "%I:%M:%OS %p")

