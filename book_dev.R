# book_dev.R
# Timothy Fraser, Fall 2022

# This script contains vital functions for rendering this bookdown into a book!

# Load packages.
library(bookdown)
library(tidyverse)
library(usethis)
library(credentials)
library(gert)


# Login to Github with Personal Access Token (PAT)
library(credentials)
#set_github_pat(force_new = TRUE)


# your working directory MUST be the one containing the file 'index.Rmd'
getwd()

# Delete any existing copy of the book
unlink("_main.Rmd")
unlink("_book", recursive = TRUE)
unlink("docs", recursive = TRUE)
# Render the book!
#bookdown::render_book(input = "index.Rmd", new_session = TRUE, output_format = "bookdown::gitbook")
#browseURL("docs/introduction.html")

#serve_book(dir = ".", output_dir = "docs", preview = FALSE, in_session = FALSE)

bookdown::render_book(input = "index.Rmd", new_session = TRUE, output_format = "bookdown::gitbook")
# Assuming we're happy, commit it!
gert::git_add(files = dir(all.files = TRUE, recursive = TRUE))
gert::git_commit_all(message = "...")
gert::git_push() # Push to Github!

# Clear environment
rm(list = ls())
