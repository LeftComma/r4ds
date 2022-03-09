
# R Markdown gives a way to present your code, results and commentary
# They can communicate conclusions, enable collaberation and replication, and record your thoughts
# You generally can't find help through ?, but there are usefull cheatsheets that I've downloaded

# A markdown file is a .Rmd file with: a YAMAL header, surrounded by --- s
# It has chunks of R code surrounded by ```
# And it has text with formatting like _italics_, **bold** or # heading

# Opening an .Rmd file in RStudio it opens a little notebook where you can run each code
# section by pressing the play button or Ctrl + Shift + Enter

# To produce the complete report you can click "Knit" or press Ctrl + Shift + K
# Or by using the render function
rmarkdown::render("1-example.Rmd")

# What happens behind the scenes when you knit the document is R sends it to knitr, 
# which executes the chunks and creates a document with the code and its output. 
# This is then passed to pandoc, which creates the final file


#### Questions ####
# 1. Create a new notebook using File > New File > R Notebook. Read the instructions. 
#   Practice running the chunks. Verify that you can modify the code, re-run it, and see modified output.
# Done!!

# 2. Create a new R Markdown document with File > New File > R Markdown. Knit it by clicking 
#   the appropriate button. Knit it by using the appropriate keyboard short cut. Verify 
#   that you can modify the input and see the output update.
# Done !!

# 3. Compare and contrast the R notebook and R markdown files you created above. How are the 
#   outputs similar? How are they different? How are the inputs similar? How are they different? 
#   What happens if you copy the YAML header from one to the other?

# R Notebook shows the output of code chunks in the editor while suppressing the console
# R Markdown files show it in the editor and console
# This doesn't always seem to be true though, can't figure out exactly why

# Notebook files also always output to html
# The html is also a .nb.html file, which enables the original Rmd file to be
# recovered from the output. You can't recover a Markdown file from the output beyond what's right there

# Copying the YAML from one to the other changes the type, it's just based on
# The output being html_document or html_notebook


# 4. Create one new R Markdown document for each of the three built-in formats: HTML, PDF and Word. 
#   Knit each of the three documents. How does the output differ? How does the input differ?

# Output just differs in what file type it goes to really

