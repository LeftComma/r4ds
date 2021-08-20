library(tidyverse)

# read_csv() reads CSV files, read_delim() is the general form for any seperated file
# read_fwf() reads fixed width files. There are specific variations if you want to specify by width or position
#   a common variation where columns are seperated by a space is read by read_table()

# These all have similar syntax, here we'll focus on read_csv()
# The first argument is the path to the file, for example:
heights <- read_csv("data/heights.csv")
# It then gives you the names and types of each column

# You can also create inline csv files, useful for experimenting
# It automatically uses the first line as column names
read_csv("a,b,c
1,2,3
4,5,6")

# The skip argument lets you skip inital, metadata, columns
read_csv("The first line of metadata
  The second line of metadata
  x,y,z
  1,2,3", skip = 2)

# The comment argument skips all lines that start with a particular thing
read_csv("# A comment I want to skip
  x,y,z
  1,2,3", comment = "#")

# If there are no columns, read_csv() will generate them
read_csv("1,2,3\n4,5,6", col_names = FALSE)

# Or you can give it column names
read_csv("1,2,3\n4,5,6", col_names = c("x", "y", "z"))

# NA files might be represented in a different way in the file, and these can be converted
read_csv("a,b,c\n1,2,.", na = ".")


#### Questions ####
# 1. What function would you use to read a file where fields were separated with "|"?
# Include delim = "|"
read_delim()

# 2. Apart from file, skip, and comment, what other arguments do read_csv() and read_tsv() have in common?
# All of them
intersect(names(formals(read_csv)), names(formals(read_tsv)))
identical(names(formals(read_csv)), names(formals(read_tsv)))

# 3. What are the most important arguments to read_fwf()?
# col_positions which tells the function where data columns begin and end

# 4. CSV files sometimes contain commas, these have to be surrounded by a quoting character
#   The default quote character for read_csv() is ", how would you change it?
read_csv("x,y\n1,'a,b'", quote = "'")

# 5. Identify what is wrong with each of the following inline CSV files
read_csv("a,b\n1,2,3\n4,5,6") # Mismatching number of columns in each row
read_csv("a,b,c\n1,2\n1,2,3,4") # Same thing as above
read_csv("a,b\n\"1") # There's no contents added to the tibble
read_csv("a,b\n1,2\na,b") # NA shouldn't follow a slash
read_csv("a;b\n1;3") # The seperator is a semicolon

