library("tidyverse")

# The default coordinate system is the Cartesian system
# There are several others that can also be used
# coord_flip() switches the x and y axes, for example to make long labels legible
ggplot(data = mpg, mapping = aes(x = class, y = hwy)) + 
  geom_boxplot()

ggplot(data = mpg, mapping = aes(x = class, y = hwy)) + 
  geom_boxplot() +
  coord_flip()

# coord_quickmap() corrects the aspect ratio for maps
nz <- map_data("nz")

# Without it, the aspect ratio adjusts to the size of the window
ggplot(nz, aes(long, lat, group = group)) +
  geom_polygon(fill = "white", colour = "black")

ggplot(nz, aes(long, lat, group = group)) +
  geom_polygon(fill = "white", colour = "black") +
  coord_quickmap()

# coord_polar uses polar coordinates, which are essentially circular
# This is also a funky new way of writing ggplots
bar <- ggplot(data = diamonds) + 
  geom_bar(
    mapping = aes(x = cut, fill = cut), 
    show.legend = FALSE,
    width = 1) + 
  theme(aspect.ratio = 1) +
  labs(x = NULL, y = NULL)

bar + coord_flip()
bar + coord_polar()


# So, each ggplot has seven components/parameters
# This template can be used to make any ggplot
# data, mapping and the geom function are the only things that need to be specified for every graph
# The others generally have defaults
ggplot(data = <DATA>) + 
  <GEOM_FUNCTION>(
    mapping = aes(<MAPPINGS>),
    stat = <STAT>, 
    position = <POSITION>
  ) +
  <COORDINATE_FUNCTION> +
  <FACET_FUNCTION>
# This corresponds with how you'd build a graph step-by-step
# 1: pick a dataset
# 2: transform your data into what you want to portray, with a stat
# 3: choose a geometric form to portray the data in, and specify the aesthetics of that geom
# 4: select a coordinate system to place the geoms into
# 5: optionally, split the graph up into facets, or adjust the geom position within the graph
# 6: optionally, add aditional layers to display more information





#### Questions ####
# 1. Stacked bar chart into a pie chart. I can get it circular, but no further
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = clarity), width = 1, position = "fill")+
  coord_polar()

# 2. labs() lets you set labels, like the title, ledgend, x and y axes 
?labs

# 3. coord_map() projects the spherical earth onto a 2D surface
# This doesn't preserve straight lines and so is vert computationally expensive
# coord_quickmap is a quick and dirty approximation that does preserve straight lines
?coord_map

# 4. coord_fixed sets an aspect ratio (default 1) instead of changing it based on the window's dimensions
ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) +
  geom_point() + 
  geom_abline()
  coord_fixed()
