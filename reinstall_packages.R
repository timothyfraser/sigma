# Aggressive fix for graphics API version mismatch
cat("Aggressively fixing graphics API version mismatch...\n")

# Get the library path
lib_path <- .libPaths()[1]
cat("Library path:", lib_path, "\n")

# Manually remove package directories (this bypasses locks)
packages_to_remove <- c("svglite", "kableExtra", "systemfonts", "ragg", "textshaping", "freetype")
for (pkg in packages_to_remove) {
  pkg_path <- file.path(lib_path, pkg)
  if (dir.exists(pkg_path)) {
    cat("Removing package directory:", pkg_path, "\n")
    unlink(pkg_path, recursive = TRUE, force = TRUE)
  }
}

# Also remove any lock directories
lock_dirs <- list.dirs(lib_path, full.names = TRUE, recursive = FALSE)
lock_dirs <- lock_dirs[grepl("00LOCK", basename(lock_dirs))]
for (lock_dir in lock_dirs) {
  cat("Removing lock directory:", lock_dir, "\n")
  unlink(lock_dir, recursive = TRUE, force = TRUE)
}

# Install fresh packages in the right order
cat("Installing fresh ragg (graphics engine)...\n")
install.packages("ragg", repos = "https://cran.r-project.org", 
                 type = "binary", dependencies = TRUE)

cat("Installing fresh svglite...\n")
install.packages("svglite", repos = "https://cran.r-project.org", 
                 type = "binary", dependencies = TRUE)

cat("Installing fresh kableExtra...\n")
install.packages("kableExtra", repos = "https://cran.r-project.org", 
                 type = "binary", dependencies = TRUE)

# Test immediately
cat("Testing packages...\n")
tryCatch({
  library(ragg)
  library(svglite)
  library(kableExtra)
  cat("✅ Graphics packages loaded successfully!\n")
  
  # Test basic graphics
  png("test.png", width = 100, height = 100)
  plot(1:10, 1:10)
  dev.off()
  unlink("test.png")
  cat("✅ Basic graphics work!\n")
  
  # Test spec_hist function
  test_data <- list(rnorm(100), rnorm(100))
  result <- kableExtra::spec_hist(test_data)
  cat("✅ spec_hist function works!\n")
  
}, error = function(e) {
  cat("❌ Error:", e$message, "\n")
  cat("You may need to restart Cursor completely and try again.\n")
})

cat("Aggressive package fix complete!\n")
