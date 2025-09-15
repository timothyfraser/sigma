# cleanup_bookdown.R
# Manual cleanup script for bookdown file lock issues on Windows

cat("Cleaning up bookdown temporary files...\n")

# List of files/directories to clean
cleanup_files <- c(
  "_main.rds",
  "_bookdown_files", 
  "docs",
  ".Rhistory",
  ".RData"
)

# Clean up each file/directory
for (file in cleanup_files) {
  if (file.exists(file)) {
    cat("Removing:", file, "\n")
    try(unlink(file, recursive = TRUE, force = TRUE), silent = TRUE)
  } else {
    cat("Not found:", file, "\n")
  }
}

# Give Windows time to process
Sys.sleep(1)

# Verify cleanup
cat("\nVerification:\n")
for (file in cleanup_files) {
  if (file.exists(file)) {
    cat("WARNING: Still exists:", file, "\n")
  } else {
    cat("Cleaned:", file, "\n")
  }
}

cat("\nCleanup complete! You can now run source('book_dev.R') again.\n")
