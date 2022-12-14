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
set_github_pat(force_new = TRUE)


# Set directory to the boodata:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABIAAAASCAYAAABWzo5XAAAAWElEQVR42mNgGPTAxsZmJsVqQApgmGw1yApwKcQiT7phRBuCzzCSDSHGMKINIeDNmWQlA2IigKJwIssQkHdINgxfmBBtGDEBS3KCxBc7pMQgMYE5c/AXPwAwSX4lV3pTWwAAAABJRU5ErkJggg==k itself;
# your working directory MUST be the one containing the file 'index.Rmd'
getwd()

# Delete any existing copy of the book
unlink("_main.Rmd")
# Render the book!
bookdown::render_book(input = "index.Rmd", output_dir = "docs")


# Assuming we're happy, commit it!
git_commit_all(message = "OK!")
git_push() # Push to Github!


