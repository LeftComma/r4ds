library(tidyverse)

# We'll be working with gss_cat, which is a dataset taken from the General Social Survey
#   conducted by a research org at the Uni of Chicago

gss_cat
?gss_cat # To get more information

# Seeing factors is easy when they're stored in a tibble
gss_cat %>%
  count(race)

# Or as a bar chart
ggplot(gss_cat, aes(race)) +
  geom_bar()

# You can force ggplot to show levels with no values
ggplot(gss_cat, aes(race)) +
  geom_bar() +
  scale_x_discrete(drop = FALSE)
# These levels represent valid levels that simply didn't occur
# Unfortunately dplyr doesn't have a drop function


#### Questions ####
# 1. Explore the distribution of rincome (reported income). What makes the default 
#   bar chart hard to understand? How could you improve the plot?
# It's hard to understand because all of the labels overlap
ggplot(gss_cat, aes(rincome)) +
  geom_bar() +
  coord_flip() # Flipping the coordinates makes it a lot more readable

# You can also do a bunch more things that might make it more readable
# - removing the "Not applicable" responses,
# - renaming "Lt $1000" to "Less than $1000",
# - using color to distinguish non-response categories ("Refused", "Don't know", and "No answer") 
#   from income levels ("Lt $1000", .),
# - adding meaningful y- and x-axis titles, and
# - formatting the counts axis labels to use commas.
gss_cat %>%
  filter(!rincome %in% c("Not applicable")) %>%
  mutate(rincome = fct_recode(rincome,
                              "Less than $1000" = "Lt $1000"
  )) %>%
  mutate(rincome_na = rincome %in% c("Refused", "Don't know", "No answer")) %>%
  ggplot(aes(x = rincome, fill = rincome_na)) +
  geom_bar() +
  coord_flip() +
  scale_y_continuous("Number of Respondents", labels = scales::comma) +
  scale_x_discrete("Respondent's Income") +
  scale_fill_manual(values = c("FALSE" = "black", "TRUE" = "gray")) +
  theme(legend.position = "None")

# Or you could exclude all missing responses
gss_cat %>%
  filter(!rincome %in% c("Not applicable", "Don't know", "No answer", "Refused")) %>%
  mutate(rincome = fct_recode(rincome,
                              "Less than $1000" = "Lt $1000"
  )) %>%
  ggplot(aes(x = rincome)) +
  geom_bar() +
  coord_flip() +
  scale_y_continuous("Number of Respondents", labels = scales::comma) +
  scale_x_discrete("Respondent's Income")

# 2. What's the most common relig in the survery? Most common partyid?
# Most common relig is Protestant
gss_cat %>%
  count(relig, sort = TRUE)

# Most common partyid is Independent
gss_cat %>%
  count(partyid, sort = TRUE)

# 3. Which relig does denom (denomination) apply to? 
#   How can you find out with a table? How can you find out with a visualisation?
# I bet it's Protestant
# There should be some way to count unique levels
# This is the best I've come up with
gss_cat %>%
  group_by(denom) %>%
  arrange(denom) %>%
  count(relig) %>%
  print(n = Inf)

# What they do is filter out all non-answers
levels(gss_cat$denom) # Get the levels of denom

# Then filter out all the ones which don't have a denomination
gss_cat %>%
  filter(!denom %in% c(
    "No answer", "Other", "Don't know", "Not applicable",
    "No denomination"
  )) %>%
  count(relig)

# You can also do a scatterplot with points scales by size
gss_cat %>%
  count(relig, denom) %>%
  ggplot(aes(x = relig, y = denom, size = n)) +
  geom_point() +
  theme(axis.text.x = element_text(angle = 90))
