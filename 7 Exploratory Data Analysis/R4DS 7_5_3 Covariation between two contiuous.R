library(tidyverse)
library(hexbin)

# Scatterplots are an easy way to map two continous variables
ggplot(data = diamonds) +
  geom_point(mapping = aes(x = carat, y = price))
 
# To prevent transparency we can lower opacity
ggplot(data = diamonds) + 
  geom_point(mapping = aes(x = carat, y = price), alpha = 1 / 100)

# We can also bin variables int groups, in the same way that's done with histograms
# Just looking at a subset of the data
smaller <- diamonds %>% 
  filter(carat < 3)
# This creates rectangular bins
ggplot(data = smaller) +
  geom_bin2d(mapping = aes(x = carat, y = price))

# And this creates hexagonal bins. For me this creates weird white lines I can't get rid of
ggplot(data = smaller) +
  geom_hex(mapping = aes(x = carat, y = price))

# Or we can bin something so it acts like a categorical variable
# We can do this by dividing the x axis into bins of a set width
ggplot(data = smaller, mapping = aes(x = carat, y = price)) + 
  geom_boxplot(mapping = aes(group = cut_width(carat, 0.1)))
# Adding varwidth = TRUE lets the boxes reflect the number of points in them, but it looks kinda bad here

# Or we can cut our data into bins with the same amount of points in them
ggplot(data = smaller, mapping = aes(x = carat, y = price)) + 
  geom_boxplot(mapping = aes(group = cut_number(carat, 20)))


#### Questions ####
# 1. Try using a frequency polygon instead of boxplots, what do you need to think about?
# Too small of a bin means too many lines
# It also just doesn't really work with carat on the x axis
ggplot(data = smaller, mapping = aes(x = price)) + 
  geom_freqpoly(mapping = aes(color = cut_width(carat, 1, boundary = 0))) + # Boundary ensures the first bin starts at 0
  labs(x = "Price", y = "Count", color = "Carat")

ggplot(data = smaller, mapping = aes(x = price)) + 
  geom_freqpoly(mapping = aes(color = cut_number(carat, 5))) +
  labs(x = "Price", y = "Count", color = "Carat")

# 2. Visualise the distribution of carat, partitioned by price.
# Not really sure what it wants me to achieve here, but I'm going to use violins
ggplot(data = smaller, mapping = aes(x = cut_width(price, 5000), y = carat)) + 
  geom_violin() +
  coord_flip() +
  xlab("Price")

# I feel violins show the actual distribution better than boxplots, but they need bigger bins to do that
ggplot(diamonds, aes(x = cut_width(price, 2000, boundary = 0), y = carat)) +
  geom_boxplot(varwidth = TRUE) +
  coord_flip() +
  xlab("Price")

# 3. How does the price distribution of very large diamonds compare to small diamonds? 
#   Is it as you expect, or does it surprise you?
# It's pretty much what I expect
# I can't figure out how to get rid of the x = 0 values
diamonds %>%
  #filter(x > 3 & x < 10) %>% # This doesn't work but I don't know why
  ggplot(data = diamonds, mapping = aes(x = x, y = price)) + 
  geom_boxplot(mapping = aes(group = cut_width(x, 1))) +
  coord_cartesian(xlim = c(3, 10)) # This kinda does but leaves some space on the left

# 4. Combine two of the techniques you've learned to visualise the combined distribution of cut, carat, and price.
# Cut is categorical, the other two are continous
# Out of his ones, I think the coloured boxplots look best
# Either have carat on the x axis and divide by cut
ggplot(diamonds, aes(x = cut_number(carat, 5), y = price, colour = cut)) +
  geom_boxplot()

# Or have cut on the x axis and divide by colour
ggplot(diamonds, aes(colour = cut_number(carat, 5), y = price, x = cut)) +
  geom_boxplot()

# 5. Two dimensional plots reveal outliers that are not visible in one dimensional plots. 
#   For example, some points in the plot below have an unusual combination of x and y values, 
#   which makes the points outliers even though their x and y values appear normal when examined separately.
#   Why is a scatterplot a better display than a binned plot for this case?
# Bins are way too big, and try to group the data, which means individual points can't be seen
ggplot(data = diamonds, mapping = aes(x = x, y = y)) +
  #geom_point() +
  geom_bin2d() +
  coord_cartesian(xlim = c(4, 11), ylim = c(4, 11))



