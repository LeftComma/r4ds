#Fn + F1 on something brings up its documentation

#Installing the tidyverse package, this only needs to be done once
install.packages("tidyverse")
#Loading the tidyverse package, this needs to be done every time
library(tidyverse)

#A generic template of a ggplot2 graph looks like this
ggplot(data = <DATA>) + 
  <GEOM_FUNCTION>(mapping = aes(<MAPPINGS>))

# Head shows the start of a df
# Here I've set it to show the first 5 rows (default no of rows is 6)
# mpg is a dataset in ggplot2
head(mpg, n=5)

#This plot maps the relationship between engine size (displ) and fuel efficiency (hwy)
#The way ggplot2 works is that ggplot() creates a coordinate system
#And geoms add layers of to them
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy))


#### Questions ####
# 1. Just creating a ggplot with no data makes a blank graph
ggplot(data = mpg)

# 2. The dimensions of mpg are 234 rows and 11 columns
dim(mpg)

# 3. The drv variable describes the type of drive train, front, back or 4-wheel
?mpg

# 4. Scatterplot of hwy vs cyl
ggplot(data = mpg)+
  geom_point(mapping = aes(x = hwy, y = cyl))

# 5. A scatterplot between these two isn't useful because all the data overlaps
ggplot(data = mpg)+
  geom_point(mapping = aes(x = class, y = drv))

# Using geom_jitter instead can make overlapping data more clear
ggplot(data = mpg)+
  geom_jitter(mapping = aes(x = class, y = drv), width = 0.2, height = 0.2)
