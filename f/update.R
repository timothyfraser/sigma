# update.R
#
# This book contains many images, tables, etc!
# We need an efficient way to store 
# the chunks, names, captions, attributions, and licenses for all of this content.
# This update.R script loads in a `function` that you can use to update some or all of this content when needed.
#
# author: Timothy Fraser, Fall 2022


update = function(images = FALSE){
  # I wrote a function called sheets() saved in my folder "f/"; converts share links to download links
  # Load in sheets() function
  source("f/sheet.R")
  
  
  # Use spreadsheet share link to download file
  "https://docs.google.com/spreadsheets/d/1IzR1mD_4ksAEvlTsFEMA4OlxoD2r8mZixd4b4ZOAXCg/edit?usp=sharing" %>%
    sheet() %>%
    download.file(destfile = "images/images.csv")
  
  # We can now source this script from the book whenever we need it, preferrably at the beginning!
}


