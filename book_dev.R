# book_dev.R
# Timothy Fraser, Fall 2022
# Optimized version for faster rendering

# This script contains vital functions for rendering this bookdown into a book!

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
        cat("🎲 Disabling cache for random chunk:", options$label, "\n")
      }
      options
    }
  )
}

# Login to Github with Personal Access Token (PAT)
library(credentials)
#set_github_pat(force_new = TRUE)

# your working directory MUST be the one containing the file 'index.Rmd'
cat("📁 Working directory:", getwd(), "\n")

# Check if we're in the right directory
if (!file.exists("index.Rmd") || !file.exists("_bookdown.yml")) {
  stop("❌ Please run this script from the bookdown project root directory")
}

# Clean up any existing _main.rds file that might be locked
if (file.exists("_main.rds")) {
  cat("🧹 Cleaning up _main.rds...\n")
  try(unlink("_main.rds", force = TRUE), silent = TRUE)
}

# Set up hybrid caching
setup_hybrid_caching()

# Start timing
start_time <- Sys.time()
cat("🚀 Starting bookdown render...\n")

# Render the book with optimizations
tryCatch({
  bookdown::render_book(
    input = "index.Rmd", 
    new_session = TRUE, 
    output_format = "bookdown::gitbook",
    clean = FALSE  # Don't clean intermediate files for faster subsequent renders
  )
  
  end_time <- Sys.time()
  render_time <- end_time - start_time
  
  cat("✅ Render completed successfully!\n")
  cat("⏱️  Total render time:", round(render_time, 2), "seconds\n")
  cat("📁 Output directory: docs/\n")
  
  # Open the book in browser
  book_url <- file.path(getwd(), "docs", "index.html")
  if (file.exists(book_url)) {
    cat("📖 Opening book at:", book_url, "\n")
    browseURL(book_url)
  }
  
}, error = function(e) {
  cat("❌ Render failed with error:\n")
  cat(as.character(e), "\n")
  stop("Render failed")
})

# Optional: commit and push (uncomment if desired)
# gert::git_add(files = dir(all.files = TRUE, recursive = TRUE))
# gert::git_commit_all(message = "Update site")
# gert::git_push() # Push to Github!

# Clear environment
rm(list = ls())
