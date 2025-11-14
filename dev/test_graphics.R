
# Test graphics packages
cat("Testing graphics packages...
")
tryCatch({
  library(svglite)
  library(kableExtra)
  cat("✅ Graphics packages loaded successfully!
")
  
  # Test spec_hist function
  test_data <- list(rnorm(100), rnorm(100))
  result <- kableExtra::spec_hist(test_data)
  cat("✅ spec_hist function works!
")
  
}, error = function(e) {
  cat("❌ Error:", e$message, "
")
})

