library(tidyverse)

# You can also improve a plot by adding scales
# Note: if you don't specify them, ggplot automatically adds scales for you

# E.g. if you put:
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(colour = class))

# ggplot adds these behind the scenes:
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(colour = class)) +
  scale_x_continuous() +
  scale_y_continuous() +
  scale_colour_discrete()
# The naming involves scale_ then the name of the aesthetic then _ then the name of the scale

# You might want to override them to change things like axes breaks
# Or to replace the scale all together!


# breaks and labels are the main arguments that affect the ticks on the axis and keys in the legend
# breaks control the position of the ticks, or value associated with the keys
# labels control the text associated with each tick/key
ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  scale_y_continuous(breaks = seq(15, 40, by = 5))

# labels can also be a character vector (same length as ticks) or can be NULL to remove them
ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  scale_x_continuous(labels = NULL) +
  scale_y_continuous(labels = NULL)

# breaks and labels can also control legends
# Axes and legends are collectively called guides. Axes are for x and y aesthetics, legends for everything else

# Another use is when you have few data points and what to specify exactly when each one occurred
presidential %>%
  mutate(id = 33 + row_number()) %>%
  ggplot(aes(start, id)) +
  geom_point() +
  geom_segment(aes(xend = end, yend = id)) +
  scale_x_date(NULL, breaks = presidential$start, date_labels = "'%y")
# Dates use a slightly different format
# date_labels takes a format specification, in the same form as parse_datetime()
# date_breaks takes a string like "2 days" or "1 month"


# You can also use them on the legends
# To control the overall legend position, you need a theme
base <- ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(colour = class))

base + theme(legend.position = "left")
base + theme(legend.position = "top")
base + theme(legend.position = "bottom")
base + theme(legend.position = "right") # the default
# legend.position = "none" also suppresses the legend

# guides() with guide_legend() or guide_colourbar() controls individual legends
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(colour = class)) +
  geom_smooth(se = FALSE) +
  theme(legend.position = "bottom") +
  guides(colour = guide_legend(nrow = 1, override.aes = list(size = 4)))
# Here we changed the number of rows and the size of the points


# Sometimes you want to fully replace a scale
# The most common ones to replace are position and colour, but the others work in the same way
ggplot(diamonds, aes(carat, price)) +
  geom_bin2d()

ggplot(diamonds, aes(log10(carat), log10(price))) +
  geom_bin2d()
# Here we log-transformed the axes to show the relationship more clearly
# However now the labels are annoying

# So we can do it with the scale instead of inside the aesthetic
ggplot(diamonds, aes(carat, price)) +
  geom_bin2d() + 
  scale_x_log10() + 
  scale_y_log10()

# Colour is a popular thing to change
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = drv))

ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = drv)) +
  scale_colour_brewer(palette = "Set1")
# This latter graph uses a colour set that is easier for people with colour blindness to distinguish

# When there aren't many colours, you can always add a shape to ensure your plot can still be read in black and white
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = drv, shape = drv)) +
  scale_colour_brewer(palette = "Set1")

# ColorBrewer scales have been specifically designed and can be found here http://colorbrewer2.org/
# They have some scales that are particularly useful if you have ordered variables, or you have a "middle" variable
# This can happen when using cut() to turn a continuous into a dichotomous variable

# If you have a set mapping in mind, you can use scale_colour_manual()
# For example making presidents red or blue
presidential %>%
  mutate(id = 33 + row_number()) %>%
  ggplot(aes(start, id, colour = party)) +
  geom_point() +
  geom_segment(aes(xend = end, yend = id)) +
  scale_colour_manual(values = c(Republican = "red", Democratic = "blue"))

# For continuous variables, scale_colour_gradient() or scale_fill_gradient() can be useful
# scale_colour_gradient2() lets you give, say, positives and negatives a different colour

# The viridis package also contains a good set of colours designed to be readable
df <- tibble(
  x = rnorm(10000),
  y = rnorm(10000)
)
ggplot(df, aes(x, y)) +
  geom_hex() +
  coord_fixed()

ggplot(df, aes(x, y)) +
  geom_hex() +
  viridis::scale_fill_viridis() +
  coord_fixed()


#### Questions ####
# 1. Why doesn't the following code override the default scale?
ggplot(df, aes(x, y)) +
  geom_hex() +
  scale_colour_gradient(low = "white", high = "red") +
  coord_fixed()
# Because colours in geom_hex() are set by the fill aesthetic not the colour aesthetic

ggplot(df, aes(x, y)) +
  geom_hex() +
  scale_fill_gradient(low = "white", high = "red") +
  coord_fixed()


# 2. What is the first argument to every scale? How does it compare to labs()?
# The first argument to every scale is the label for the scale. It is equivalent to using the labs function.
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(colour = class)) +
  geom_smooth(se = FALSE) +
  labs(
    x = "Engine displacement (L)",
    y = "Highway fuel economy (mpg)",
    colour = "Car type"
  )

# Is the same as:
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(colour = class)) +
  geom_smooth(se = FALSE) +
  scale_x_continuous("Engine displacement (L)") +
  scale_y_continuous("Highway fuel economy (mpg)") +
  scale_colour_discrete("Car type")


# 3. Change the display of the presidential terms by:
# Combining the two variants shown above.
# Improving the display of the y axis.
# Labeling each term with the name of the president.
# Adding informative plot labels.
# Placing breaks every 4 years (this is trickier than it seems!).
fouryears <- lubridate::make_date(seq(year(min(presidential$start)),
                                      year(max(presidential$end)),
                                      by = 4
                                      ), 1, 1)

presidential %>%
  mutate(
    id = 33 + row_number(),
    name_id = fct_inorder(str_c(name, " (", id, ")"))
  ) %>%
  ggplot(aes(start, name_id, colour = party)) +
  geom_point() +
  geom_segment(aes(xend = end, yend = name_id)) +
  scale_colour_manual("Party", values = c(Republican = "red", Democratic = "blue")) +
  scale_y_discrete(NULL) +
  scale_x_date(NULL,
               breaks = presidential$start, date_labels = "'%y",
               minor_breaks = fouryears
  ) +
  ggtitle("Terms of US Presdients",
          subtitle = "Roosevelth (34th) to Obama (44th)"
  ) +
  theme(
    panel.grid.minor = element_blank(),
    axis.ticks.y = element_blank()
  )


# 4. Use override.aes to make the legend on the following plot easier to see.
ggplot(diamonds, aes(carat, price)) +
  geom_point(aes(colour = cut), alpha = 1/20) + 
  guides(colour = guide_legend(override.aes = list(alpha = 1)))
