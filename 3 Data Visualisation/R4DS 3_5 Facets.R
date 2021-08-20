library("tidyverse")

# Instead of using aesthetics to add information, data can be split into subplots, called facets

# facet_wrap() facets a plot by a single variable
# The ~ indicates the formula that you're splitting the data by, formula here just means R data structure
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) + 
  facet_wrap(~ class, nrow = 2) # Only facet_wrap() with a discreet variable

# facet_grip() lets you facet based on two variables
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) + 
  facet_grid(drv ~ cyl) # Here the formula shows what you'll split in the: x axis ~ y axis

# Adding a full stop instead of a variable means nothing will be faceted in that axis
# This ends up doing the same thing as facet wrap really
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) + 
  facet_grid(. ~ cyl)


#### Questions ####
# 1. Faceting a continous variable creates a facet for each one, making way too many
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) + 
  facet_wrap(~ cty)

# 2. The empty plots in facet_grid(drv ~ cyl) are when there are no cars with those two characteristics
# They're also the places in this plot with no dots
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = drv, y = cyl))

# 3. These plots each make half of the facet_grid(drv ~ cyl) plot, the full stops stop faceting in that dimension
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_grid(drv ~ .)

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_grid(. ~ cyl)

# 4. Faceting allows data to be seperated, which makes it looking at each component seperately easier, but
# makes it harder to compare them compared to using colours say. With a large dataset (or more categories)
# it would get better to facet, as a single plot could get too crowded

# 5. nrow and ncol sets the number of rows and columns
# facet_grid() doesn't have these because the rows/columns are dictated by the variables
?facet_wrap()

# 6. In facet_wrap(), you want to put the variable with more levels in the columns because a horizontal
# layout will give these ones more space


