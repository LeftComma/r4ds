library(broom)

# broom has 3 functions for turning models into tidy dfs

# broom::glance(model) returns a row for each model. Each column gives a model summary,
# which is either a measure of quality, complexity, or both

# broom::tidy(model) returns a row for each coefficient in the model. Each column
# gives information about the estimate or its variability

# broom::augment(model, data) returns a row for each row in data, adding extra values 
# like residuals, and influence statistics
