# book_dev.R
# Timothy Fraser, Fall 2022
# Optimized version for faster rendering

# This script contains vital functions for rendering this bookdown into a book!

# Set to TRUE to clean intermediate files
is_clean = FALSE

if(is_clean) { unlink("docs", recursive = TRUE) }

# Set locale to handle multibyte characters properly
Sys.setlocale("LC_ALL", "en_US.UTF-8")

# Load packages.
library(bookdown)
library(tidyverse)
library(usethis)
library(credentials)
library(gert)

# Tell R where to find Pandoc
Sys.setenv(RSTUDIO_PANDOC = "C:/Users/tmf77/AppData/Local/Pandoc")

# Set optimized chunk options for faster rendering
knitr::opts_chunk$set(
  cache = TRUE,   # Enable caching for faster subsequent renders
  cache.lazy = FALSE,  # Load cache eagerly for better performance
  message = FALSE,
  warning = FALSE,
  echo = TRUE,
  eval = TRUE,
  fig.width = 8,
  fig.height = 6,
  dpi = 96  # Lower DPI for faster rendering
)

# Global reticulate configuration for Python integration
library(reticulate)

# Use your specific Python installation
python_path <- "C:/Python312/python.exe"
if (file.exists(python_path)) {
  use_python(python_path, required = FALSE)
  cat("Using Python at:", python_path, "\n")
} else {
  # Fallback to system Python
  system_python <- Sys.which("python")
  if (system_python != "") {
    use_python(system_python, required = FALSE)
    cat("Using system Python at:", system_python, "\n")
  } else {
    cat("Warning: No Python installation found\n")
  }
}

# Disable automatic environment creation and downloads
Sys.unsetenv("RETICULATE_PYTHON_ENV")
Sys.unsetenv("RETICULATE_PYTHON") 
Sys.unsetenv("RETICULATE_AUTOCONFIGURE")
Sys.unsetenv("RETICULATE_PYTHON_FALLBACK")

# Set the Python path explicitly
Sys.setenv(RETICULATE_PYTHON = python_path)

# Prevent reticulate from downloading Python
options(reticulate.conda_binary = NULL)

# Set global random seed for reproducible results
set.seed(123)  # Use a consistent seed across all chapters

# Function to detect and handle random chunks
setup_hybrid_caching <- function() {
  # Default: cache everything
  knitr::opts_chunk$set(cache = TRUE)
  
  # For chunks with random functions, disable caching
  # This will be applied when knitr processes each chunk
  knitr::opts_hooks$set(
    cache = function(options) {
      # Check if chunk contains random functions
      if (any(grepl("rnorm|runif|rbinom|rexp|rpois|sample\\(|set\\.seed", 
                   options$code, ignore.case = TRUE))) {
        options$cache <- FALSE
        cat("Disabling cache for random chunk:", options$label, "\n")
      }
      options
    }
  )
}

# Login to Github with Personal Access Token (PAT)
library(credentials)
#set_github_pat(force_new = TRUE)

# your working directory MUST be the one containing the file 'index.Rmd'
cat("Working directory:", getwd(), "\n")

# Check if we're in the right directory
if (!file.exists("index.Rmd") || !file.exists("_bookdown.yml")) {
  stop("Please run this script from the bookdown project root directory")
}

# Clean up any existing _main.rds file that might be locked (Windows issue)
if (file.exists("_main.rds")) {
  cat("Cleaning up _main.rds...\n")
  try(unlink("_main.rds", force = TRUE), silent = TRUE)
  # Additional cleanup for Windows
  Sys.sleep(0.5)  # Give Windows time to release the file
  if (file.exists("_main.rds")) {
    cat("Warning: _main.rds still exists, attempting force removal...\n")
    try(file.remove("_main.rds"), silent = TRUE)
  }
}

# Also clean up any other potential lock files
lock_files <- c("_main.rds", "_bookdown_files", "docs")
for (file in lock_files) {
  if (file.exists(file)) {
    cat("Cleaning up", file, "...\n")
    try(unlink(file, recursive = TRUE, force = TRUE), silent = TRUE)
  }
}

# Set up hybrid caching
setup_hybrid_caching()

# Start timing
start_time <- Sys.time()
cat("Starting bookdown render...\n")

# Render the book with optimizations
tryCatch({
  bookdown::render_book(
    input = "index.Rmd", 
    new_session = TRUE, 
    output_format = "bookdown::gitbook",
    encoding = "UTF-8",
    clean = is_clean 
    # Don't clean intermediate files for faster subsequent renders
  )
  
  end_time <- Sys.time()
  render_time <- end_time - start_time
  
  cat("Render completed successfully!\n")
  cat("Total render time:", round(render_time, 2), "seconds\n")
  cat("Output directory: docs/\n")
  
  # Open the book in browser
  book_url <- file.path(getwd(), "docs", "index.html")
  if (file.exists(book_url)) {
    cat("Opening book at:", book_url, "\n")
    browseURL(book_url)
  }
  
}, error = function(e) {
  cat("Render failed with error:\n")
  cat(as.character(e), "\n")
  
  # Additional cleanup on error
  cat("Performing cleanup after error...\n")
  try(unlink("_main.rds", force = TRUE), silent = TRUE)
  try(unlink("_bookdown_files", recursive = TRUE, force = TRUE), silent = TRUE)
  
  # Check if it's a _main.rds specific error
  if (grepl("_main.rds", as.character(e))) {
    cat("\n*** _main.rds FILE LOCK ERROR DETECTED ***\n")
    cat("This is a common Windows issue. Try:\n")
    cat("1. Close any R/RStudio sessions\n")
    cat("2. Wait a few seconds\n")
    cat("3. Run source('book_dev.R') again\n")
    cat("4. If it persists, restart your computer\n\n")
  }
  
  stop("Render failed")
})

# Optional: commit and push (uncomment if desired)
# gert::git_add(files = dir(all.files = TRUE, recursive = TRUE))
# gert::git_commit_all(message = "Update site")
# gert::git_push() # Push to Github!

# Clear environment
rm(list = ls())
