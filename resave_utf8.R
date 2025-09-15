# Resave all Rmd files in UTF-8 encoding
library(readr)

# Function to resave file in UTF-8
resave_utf8 <- function(file_path) {
  tryCatch({
    # Read the file with auto-detection of encoding
    content <- readLines(file_path, warn = FALSE)
    
    # Write back with UTF-8 encoding
    writeLines(content, file_path, useBytes = FALSE)
    
    cat("Resaved in UTF-8:", file_path, "\n")
  }, error = function(e) {
    cat("Error resaving", file_path, ":", e$message, "\n")
  })
}

# Get all Rmd files
rmd_files <- list.files(pattern = "\\.Rmd$", full.names = TRUE)

cat("Found", length(rmd_files), "Rmd files to resave\n")

# Resave each file
for (file in rmd_files) {
  resave_utf8(file)
}

cat("UTF-8 resave complete.\n")
