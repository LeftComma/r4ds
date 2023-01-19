library(tidyverse)

# There are 3 ways to control plot limits
# 1. Adjusting what data are plotted
# 2. Setting the limits in each scale
# 3. Setting xlim and ylim in coord_cartesian()

# To zoom in on a portion of the plot, coord_cartesian() is probably best
ggplot(mpg, mapping = aes(displ, hwy)) +
  geom_point(aes(color = class)) +
  geom_smooth() +
  coord_cartesian(xlim = c(5, 7), ylim = c(10, 30))

# The above plot looks a lot nicer than the below one

mpg %>%
  filter(displ >= 5, displ <= 7, hwy >= 10, hwy <= 30) %>%
  ggplot(aes(displ, hwy)) +
  geom_point(aes(color = class)) +
  geom_smooth()

# Reducing the limits is basically subsetting a scale
# Expanding the limits can be more helpful, say so they match across two plots
# For example, it's hard to compare the car classes when they're plotted normally
suv <- mpg %>% filter(class == "suv")
compact <- mpg %>% filter(class == "compact")

ggplot(suv, aes(displ, hwy, colour = drv)) +
  geom_point()
ggplot(compact, aes(displ, hwy, colour = drv)) +
  geom_point()
# Because they use different scales

# So you can force them to share the same scale
x_scale <- scale_x_continuous(limits = range(mpg$displ))
y_scale <- scale_y_continuous(limits = range(mpg$hwy))
col_scale <- scale_colour_discrete(limits = unique(mpg$drv))

ggplot(suv, aes(displ, hwy, colour = drv)) +
  geom_point() +
  x_scale +
  y_scale +
  col_scale

ggplot(compact, aes(displ, hwy, colour = drv)) +
  geom_point() +
  x_scale +
  y_scale +
  col_scale


# Themes ------------------------------------------------------------------

# Themes let you customise the non-data parts of your plot
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = class)) +
  geom_smooth(se = FALSE) +
  theme_bw()

# ggplot has 8 default themes. Add-ons like ggthemes have a lot more


# Saving plots ------------------------------------------------------------

# The two ways to save plots are ggsave() and knitr.
# ggsave() saves the most recent plot to disk
ggplot(mpg, aes(displ, hwy)) + geom_point()

ggsave("my-plot.pdf")
# If you don't set dimensions, they'll be chosen based on your plotting device at this moment


# Figure sizing can be tricky in Markdown
# There are five main options that control figure sizing: fig.width, fig.height, fig.asp, out.width and out.height
# There are two sizes, the size of the figure made by R and the size at which it's put into the output document
# And there are multiple ways of setting size (though you only pick two)

# He only ever uses 3 options:
# 1. I find it most aesthetically pleasing for plots to have a consistent width. To enforce this, 
# I set fig.width = 6 (6") and fig.asp = 0.618 (the golden ratio) in the defaults. Then in individual chunks, 
# I only adjust fig.asp

# 2. I control the output size with out.width and set it to a percentage of the line width. 
# I default to out.width = "70%" and fig.align = "center". That give plots room to breathe, 
# without taking up too much space.

# 3. To put multiple plots in a single row I set the out.width to 50% for two plots, 33% for 3 plots, 
# or 25% to 4 plots, and set fig.align = "default". Depending on what I'm trying to illustrate 
# (e.g. show data or show plot variations), I'll also tweak fig.width, as discussed below.


# If you have to squint to read the text, you need to tweak fig.width
# If fig.width is larger than the size the figure is rendered in the final doc, the text will be too small; 
# if fig.width is smaller, the text will be too big

# If you want to make sure the font size is consistent across all your figures, whenever you set out.width, 
# you'll also need to adjust fig.width to maintain the same ratio with your default out.width.
# For example, if your default fig.width is 6 and out.width is 0.7, when you set out.width = "50%" you'll 
# need to set fig.width to 4.3 (6 * 0.5 / 0.7).


# When you show text and code and figures together, setting fig.show = "hold" means plots are shown after the code
# fig.cap adds a caption to the figure
# When making a PDF, setting dev = "png" can reduce your file sizes


# A good option for learning more is the ggplot2 book: ggplot2: Elegant graphics for data analysis
# Source code is at https://github.com/hadley/ggplot2-book
# Another option is the ggplot extensions gallery https://exts.ggplot2.tidyverse.org/gallery/
