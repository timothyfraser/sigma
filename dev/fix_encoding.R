# Fix encoding issues in Rmd files
library(stringr)

# Function to clean multibyte characters
clean_multibyte <- function(file_path) {
  content <- readLines(file_path, warn = FALSE, encoding = "UTF-8")
  
  # Replace common problematic characters
  content <- str_replace_all(content, "[\u201C\u201D]", '"')  # Smart quotes
  content <- str_replace_all(content, "[\u2018\u2019]", "'")  # Smart apostrophes
  content <- str_replace_all(content, "[\u2013\u2014]", "-")  # En/em dashes
  content <- str_replace_all(content, "[\u2026]", "...")      # Ellipsis
  
  # Write back to file
  writeLines(content, file_path, useBytes = FALSE)
  cat("Cleaned:", file_path, "\n")
}

# Get all Rmd files
rmd_files <- list.files(pattern = "\\.Rmd$", full.names = TRUE)

# Clean each file
for (file in rmd_files) {
  tryCatch({
    clean_multibyte(file)
  }, error = function(e) {
    cat("Error cleaning", file, ":", e$message, "\n")
  })
}

cat("Encoding cleanup complete.\n")
