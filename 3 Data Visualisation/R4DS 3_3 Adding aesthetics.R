library("tidyverse")

# Information can be added as aesthetics
# Here we're changing the colour based on the class of the car 
# You can change lots of things, like shape or size
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, color = class))

# It's generally bad to map a continuous aesthetic to a discreet variable
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, size = class))

# You put aesthetics inside of the aes() function if you want it to change in some way
# This shows that x and y are also seen as aesthetics, being added to the geom_point layer
# Once you add an aesthetic, ggplot sorts out the legend and scale and things (though I think you can set these manually)

# You can also set aesthetics manually
# This is done outside the aes() function
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy), color = "blue")

# This loop shows you all the possible shapes
# 1-14 are outlines, they take no fill and the default colour is black
# 15-20 are solid, they also take no fill and the default colour is black
# 21-24 are filled shapes, they take a fill and colour, both defaulting to black
for (i in 1:24){
  print(ggplot(data = mpg)+
      geom_point(mapping = aes(x = displ, y = hwy), shape = i, color = "black", fill = "red"))
  Sys.sleep(1) # This waits for a second to make the graphs viewable
}


#### Questions ####
# 1. The reason this code doesn't have any blue dots is that the color is inside the aes() function
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, color = "blue"))

# 2. mpg has 6 categorical variables and 5 continous variables
# under head(), <chr> means categorical, <int> and <dbl> are continous
# The type of variable dictates what operations can be performed on it
?mpg
head(mpg)
# glimpse() is another way of viewing a section of a data set
glimpse(mpg)

# 3. Continous data mapped to an aesthetic creates a smooth gradient. They can't be mapped to shape
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, size = cty))

# 4. Mapping the same variable to two aesthetics does work, but can look weird
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, color = class, shape = class))

# 5. The stroke aesthetic changes the width of the border when you have a shape with one variable dictating the
# outer colour and another variable dictating the inner colour
?geom_point
# An example from the documentation can be seen here
ggplot(mtcars, aes(wt, mpg)) +
  geom_point(shape = 21, colour = "black", fill = "white", size = 5, stroke = 5)
# Plotted in the way we've been doing, that code would look like this:
ggplot(data = mtcars) +
  geom_point(mapping = aes(x = wt, y = mpg), shape = 21, colour = "black", fill = "white", size = 5, stroke = 5)


# 6. Mapping a conditional to a variable splits it into True or False for that condition
ggplot(data = mpg)+
  geom_point(mapping = aes(x = cty, y = hwy, colour = displ > 5))
