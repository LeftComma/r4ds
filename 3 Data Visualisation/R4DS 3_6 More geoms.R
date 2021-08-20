library("tidyverse")

# In ggplot2, geoms are the way data is displayed
# Bar charts use bar geoms, boxplots use boxplot geoms, scatterplots use point geoms

# Here is the same data presented using two different geoms
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy))

ggplot(data = mpg) + 
  geom_smooth(mapping = aes(x = displ, y = hwy))

# Every geom takes a mapping, but they don't all take the same aesthetics
# For example, geom_smooth takes a linetype aesthetic
ggplot(data = mpg) + 
  geom_smooth(mapping = aes(x = displ, y = hwy, linetype = drv))

# You can display multiple geoms by adding them as different layers to the same plot
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) +
  geom_smooth(mapping = aes(x = displ, y = hwy))

# To not have to write out the mappings twice, you can put them in the overall plot, making them global
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point() + 
  geom_smooth()

# Mappings in a particular geom are local, and override global mappings
# This means you can add different aesthetics in different layers
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point(mapping = aes(color = class)) + 
  geom_smooth()

# You could also technically add different mappings, but that often just looks rubbish
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point(mapping = aes(x = hwy, y = cty)) + 
  geom_smooth()

# Here's a better way to show different data
# By filtering one geom to only show a subset of our data
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point(mapping = aes(color = class)) + 
  geom_smooth(data = filter(mpg, class == "subcompact"), se = FALSE)


#### Questions ####
# 1. You'd use geom_line() to draw a line graph, geom_boxplot() to draw a boxplot,
# geom_histogram() to draw a histogram, geom_area() to draw an area graph

# 2. The code would show several different lines based on the colour, and the dots would be coloured,
# there would be no confidence intervals around the lines
ggplot(data = mpg, mapping = aes(x = displ, y = hwy, color = drv)) + 
  geom_point() + 
  geom_smooth(se = FALSE)

# 3. show.legend = FALSE will remove the legend from a graph

# 4. The se argument in geom_smooth() determines whether confidence intervals will be shown

# 5. These two pieces of code will show the same thing
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point() + 
  geom_smooth()

ggplot() + 
  geom_point(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_smooth(data = mpg, mapping = aes(x = displ, y = hwy))

# 6. Whoo boy, lots of coding here. I have to recreate the six graphs shown
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point(size = 4) + 
  geom_smooth(se = FALSE, size= 2)

ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point(size = 4) + 
  geom_smooth(aes(group = drv), se = FALSE, size= 2)

ggplot(data = mpg, mapping = aes(x = displ, y = hwy, color = drv)) + 
  geom_point(size = 4) + 
  geom_smooth(se = FALSE, size= 2)

ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point(aes(color = drv), size = 4) + 
  geom_smooth(se = FALSE, size= 2)

ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point(aes(color = drv), size = 4) + 
  geom_smooth(aes(linetype = drv), se = FALSE, size= 2)

ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point(aes(fill = drv), shape = 21, color = 'white',  size = 4, stroke = 2)
