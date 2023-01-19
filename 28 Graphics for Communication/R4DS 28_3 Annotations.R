library(tidyverse)

# It can often be useful to label individual observations or groups within the graph
# geom_text() helps with this. It's like geom_point() but with labels

# Here we pull out the best car in each class and label it
best_in_class <- mpg %>%
  group_by(class) %>%
  filter(row_number(desc(hwy)) == 1)

ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(colour = class)) +
  geom_text(aes(label = model), data = best_in_class)
# However the labels are pretty hard to read

# geom_label adds a box behind the label, and nudge moves them around slightly
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(colour = class)) +
  geom_label(aes(label = model), data = best_in_class, nudge_y = 2, alpha = 0.5)
# But there are still two labels at the top that are on top of each other

# This can be fixed with ggrepel
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(colour = class)) +
  geom_point(size = 3, shape = 1, data = best_in_class) +
  ggrepel::geom_label_repel(aes(label = model), data = best_in_class)
# It can also be useful to add something to identify which points we're refering to
# Here that's a hollow black point


# You can also replace the legend with labels on the plot itself
class_avg <- mpg %>%
  group_by(class) %>%
  summarise(
    displ = median(displ),
    hwy = median(hwy)
  )

ggplot(mpg, aes(displ, hwy, colour = class)) +
  ggrepel::geom_label_repel(aes(label = class),
                            data = class_avg,
                            size = 6,
                            label.size = 0,
                            segment.color = NA
  ) +
  geom_point() +
  theme(legend.position = "none")
# It's not great but it gets the point across


# Or sometimes you might just want one label on the plot
# You can use summarise() to put the label at the max point for x and y
label <- mpg %>%
  summarise(
    displ = max(displ),
    hwy = max(hwy),
    label = "Increasing engine size is \nrelated to decreasing fuel economy."
  )

ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  geom_text(aes(label = label), data = label, vjust = "top", hjust = "right")

# Or place it on the border itself with Inf
label <- tibble(
  displ = Inf,
  hwy = Inf,
  label = "Increasing engine size is \nrelated to decreasing fuel economy."
)

ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  geom_text(aes(label = label), data = label, vjust = "top", hjust = "right")
# We also adjust it to be in the top right hand corner
# I don't totally understand why we need the position and the adjustment, but it seems we do

# Okay so this was a complete mistake but I think it creates a really cool effect
ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  geom_text(label = "Increasing engine size is \nrelated to decreasing fuel economy.", 
            vjust = "top", hjust = "right")


# You can also use other geoms to annotate a plot
# Use geom_hline() and geom_vline() to add reference lines. I often make them thick (size = 2) 
# and white (colour = white), and draw them underneath the primary data layer. That makes them easy 
# to see, without drawing attention away from the data.

# Use geom_rect() to draw a rectangle around points of interest. 
# The boundaries of the rectangle are defined by aesthetics xmin, xmax, ymin, ymax.

# Use geom_segment() with the arrow argument to draw attention to a point with an arrow. 
# Use aesthetics x and y to define the starting location, and xend and yend to define the end location.


#### Questions ####
# 1. Use geom_text() with infinite positions to place text at the four corners of the plot.
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(colour = class)) + 
  geom_text(aes(x = Inf, y = Inf, label = "top right"), vjust = "top", hjust = "right") +
  geom_text(aes(x = -Inf, y = Inf, label = "top left"), vjust = "top", hjust = "left") +
  geom_text(aes(x = Inf, y = -Inf, label = "bottom right"), vjust = "bottom", hjust = "right") +
  geom_text(aes(x = -Inf, y = -Inf, label = "bottom left"), vjust = "bottom", hjust = "left")
# For some reason the text looks really weird when I do it like this, but I don't really care

# Or you can throw all that into one df
label <- tribble(
  ~displ, ~hwy, ~label, ~vjust, ~hjust,
  Inf, Inf, "Top right", "top", "right",
  Inf, -Inf, "Bottom right", "bottom", "right",
  -Inf, Inf, "Top left", "top", "left",
  -Inf, -Inf, "Bottom left", "bottom", "left"
)

ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  geom_text(aes(label = label, vjust = vjust, hjust = hjust), data = label)
# And the text for this works for some reason


# 2. Read the documentation for annotate(). How can you use it to add a text label to a 
# plot without having to create a tibble?
annotate()

# annotate() uses arguments instead of aesthetic mappings
ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  annotate("text",
           x = Inf, y = Inf,
           label = "Increasing engine size is \nrelated to decreasing fuel economy.", vjust = "top", hjust = "right"
  )


# 3. How do labels with geom_text() interact with faceting? How can you add a label to a single facet? 
# How can you put a different label in each facet? (Hint: think about the underlying data.)

# If you don't specify a facet, the text is drawn in all of them
label <- tibble(
  displ = Inf,
  hwy = Inf,
  label = "Increasing engine size is \nrelated to decreasing fuel economy."
)

ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  geom_text(aes(label = label),
            data = label, vjust = "top", hjust = "right",
            size = 2
  ) +
  facet_wrap(~class)

# To only do it in one, add a column to the label df with the value of the variable(s) you want to draw on
label <- tibble(
  displ = Inf,
  hwy = Inf,
  class = "2seater",
  label = "Increasing engine size is \nrelated to decreasing fuel economy."
)

ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  geom_text(aes(label = label),
            data = label, vjust = "top", hjust = "right",
            size = 2
  ) +
  facet_wrap(~class)


# 4. What arguments to geom_label() control the appearance of the background box?

# label.padding: padding around label
# label.r: amount of rounding in the corners
# label.size: size of label border


# 5. What are the four arguments to arrow()? How do they work? 
# Create a series of plots that demonstrate the most important options.

# The four arguments:
# angle : angle of arrow head
# length : length of the arrow head
# ends: ends of the line to draw arrow head
# type: "open" or "close": whether the arrow head is a closed or open triangle

