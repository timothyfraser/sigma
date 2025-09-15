# Minimal bookdown test
library(bookdown)

# Set locale
Sys.setlocale("LC_ALL", "C")

# Set working directory
setwd("C:/Users/tmf77/OneDrive - Cornell University/Documents/rstudio/sigma")

# Try to render just the index.Rmd
tryCatch({
  bookdown::render_book(
    input = "index.Rmd", 
    new_session = TRUE, 
    output_format = "bookdown::gitbook"
  )
  cat("SUCCESS: Book rendered successfully!\n")
}, error = function(e) {
  cat("ERROR:", e$message, "\n")
})
