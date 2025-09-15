# Instructions

In lines 12-60 of README.md are a checklist of .Rmd files in the main directory.
Files that have boxes checked have compiled properly. Files without checks have not yet compiled properly.

Please iteratively compile the gitbook using `book_dev.R` until all .Rmd files compile properly and all boxes are checked. 

When compiling, comment out all but the one Rmd file of interest in the _bookdown.yml file, to ensure quick compile time and avoid confounding problems from other files.

# Example

Round 1: comment out all files except 01_workshop.Rmd. Run `source("book_dev.R")`. If it compiles properly, check the box. If not, leave a question mark and move on.

Round 2: comment out all files except 02_workshop.Rmd. Run `source("book_dev.R")`. If it compiles properly, check the box. If not, leave a question mark and move on. Add a bullet point to this file describing the issue.

Etc.

# Most likely problems

The most common problems you encounter will be:

1. Tries to install python erroneously. Needs to use reticulate instead. Use 01_workshop_python.Rmd as an example.

2. Graphics API mismatch. Use png instead of svg. Avoid ragg.

3. Sometimes I write ```something``` instead of `something` in the text.

# Advice

Avoid erroneously fixing other issues. Just stick to the main ones. This gitbook used to compile okay in RStudio until I switched to cursor, so it's probably just these 3 issues throughout the book.

# Remaining Issues

- Insert here
