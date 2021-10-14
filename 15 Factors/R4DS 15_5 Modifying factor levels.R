library(tidyverse)

# You can also modify factor levels
# fct_recode() lets you change the value of each level

# These factors are pretty inconsistent
gss_cat %>% count(partyid)

# We can recode them to make them clearer
gss_cat %>%
  mutate(partyid = fct_recode(partyid,
                              "Republican, strong"    = "Strong republican",
                              "Republican, weak"      = "Not str republican",
                              "Independent, near rep" = "Ind,near rep",
                              "Independent, near dem" = "Ind,near dem",
                              "Democrat, weak"        = "Not str democrat",
                              "Democrat, strong"      = "Strong democrat"
  )) %>%
  count(partyid)

# fct_recode() leaves unmentioned levels unchanged. It also throws a warning
#   if you refer to a level that isn't there
# You can combine levels by assigning them to the same new levels
gss_cat %>%
  mutate(partyid = fct_recode(partyid,
                              "Republican, strong"    = "Strong republican",
                              "Republican, weak"      = "Not str republican",
                              "Independent, near rep" = "Ind,near rep",
                              "Independent, near dem" = "Ind,near dem",
                              "Democrat, weak"        = "Not str democrat",
                              "Democrat, strong"      = "Strong democrat",
                              "Other"                 = "No answer",
                              "Other"                 = "Don't know",
                              "Other"                 = "Other party"
  )) %>%
  count(partyid)

# For collapsing many levels, fct_collapse() takes a vector of old levels for each new one
gss_cat %>%
  mutate(partyid = fct_collapse(partyid,
                                other = c("No answer", "Don't know", "Other party"),
                                rep = c("Strong republican", "Not str republican"),
                                ind = c("Ind,near rep", "Independent", "Ind,near dem"),
                                dem = c("Not str democrat", "Strong democrat")
  )) %>%
  count(partyid)

# fct_lump() groups together all the smallest groups
gss_cat %>%
  mutate(relig = fct_lump(relig)) %>%
  count(relig)
# This has probably over-collapsed

# Manually set the number of (non-other) levels you want to keep with n
gss_cat %>%
  mutate(relig = fct_lump(relig, n = 10)) %>%
  count(relig, sort = TRUE) %>%
  print(n = Inf)


#### Questions ####
# 1. How have the proportions of people identifying as Democrat, 
#   Republican, and Independent changed over time?
# Rep has decreased slightly, and dem has increased slightly
gss_cat %>%
  mutate(partyid = fct_collapse(partyid,
                                other = c("No answer", "Don't know", "Other party"),
                                rep = c("Strong republican", "Not str republican"),
                                ind = c("Ind,near rep", "Independent", "Ind,near dem"),
                                dem = c("Not str democrat", "Strong democrat")
  )) %>%
  group_by(year) %>%
  count(partyid) %>%
  mutate(percent = n / sum(n) * 100) %>%
  ggplot(aes(x = year, y = percent, colour = fct_reorder2(partyid, year, percent))) +
  geom_line() +
  geom_point() +
  labs(colour = "Party ID")

# 2. How could you collapse rincome into a small set of categories?
gss_cat %>%
  mutate(rincome = fct_collapse(rincome,
                                "No Answer" = c("No answer", "Don't know", "Refused", "Not applicable"),
                                "Less than $5000" = c("Lt $1000", "$4000 to 4999", "$3000 to 3999", "$1000 to 2999"),
                                "$5000 - 9999" = c("$5000 to 5999", "$6000 to 6999", "$7000 to 7999", "$8000 to 9999")
  )) %>%
  count(rincome)
