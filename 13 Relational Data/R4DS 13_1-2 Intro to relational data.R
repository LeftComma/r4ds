library(tidyverse)
library(nycflights13)

# Data is often given in multiple tables, which need to be joined together
# There are three families of terms for when working with pairs of tables:
#   Mutating joins, adding new variables to one df from matching observations in another
#   Filtering joins, filtering observations from a df based on whether or not they match observations in the other
#   Set operations, which treat observations as set elements

# Relational data is often found in a relational database management system (RDBMS), such as all modern databases

# nycflights13 has four tibbles that are related to the main flights table
# airlines lets you look up a carrier's full name
airlines

# airports gives information about each airport
airports

# planes gives info about each plane
planes

# weather gives the weather at each NYC airport for each hour
weather

# flights is connected to...
#   planes via the variable tailnum
#   airlines through the carrier vairable
#   airports via origin and dest
#   weather via origin and the year, month, day and hour variables


#### Questions ####
# 1. Imagine you wanted to draw (approximately) the route each plane flies from its origin to its destination. 
#   What variables would you need? What tables would you need to combine?
# You'd need the airports and flights data, and a map
# flights would have origin and dest for each flight. airports has longitude and latitude of each airport
# This might be done like so:
flights_latlon <- flights %>%
  inner_join(select(airports, origin = faa, origin_lat = lat, origin_lon = lon),
             by = "origin"
  ) %>%
  inner_join(select(airports, dest = faa, dest_lat = lat, dest_lon = lon),
             by = "dest"
  )

# Then you can plot this data on a map
flights_latlon %>%
  slice(1:100) %>%
  ggplot(aes(
    x = origin_lon, xend = dest_lon,
    y = origin_lat, yend = dest_lat
  )) +
  borders("state") +
  geom_segment(arrow = arrow(length = unit(0.1, "cm"))) +
  coord_quickmap() +
  labs(y = "Latitude", x = "Longitude")

# 2. I forgot to draw the relationship between weather and airports.
#   What is the relationship and how should it appear in the diagram?
# weather connects to airports through the origin variable

# 3. weather only contains information for the origin (NYC) airports.
#   If it contained weather records for all airports in the USA, what additional relation would it define with flights?
# It would also be related through the dest variable

# 4. We know that some days of the year are "special", and fewer people than usual fly on them. 
#   How might you represent that data as a data frame? What would be the primary keys of that table? 
#   How would it connect to the existing tables?
# You'd have a key for the name of the holiday, and then a key for the year, month and day
# It would connect to flights and weather via year, month and day
