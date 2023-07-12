# sheet()
#
# The `sheet()` function converts a Google Sheets spreadsheet share link into a download link.
# By default, it generates a csv for the first sheet, but by adding the sheet's specific gid,
# you can extract just one specific sheet if need be.
# 
# Example structure of a Google Sheets download link
# https://docs.google.com/spreadsheets/d/KEY/export?format=csv&id=KEY&gid=SHEET_ID

sheet = function(sharelink = NULL, key = NULL, format = "csv", gid = NULL, base = "https://docs.google.com/spreadsheets/d"){
  # Let's write a quick function for getting Google Sheets download links.
  
  require(dplyr)
  require(stringr)
  
  # If they supply a sharelink...
  if(!is.null(sharelink)){
    # If they supply a sharelink (even if they give a key), use the sharelinke

    # Extract the base, which is everything before the 'd'
    base = sharelink %>%
      str_extract(".*[/]d[/]")
    
    # Extract the key, which is everything after the 'd', but before the next backslash
    key = sharelink %>% 
      # by removing the base
      str_remove(base) %>%
      # and everything after the next backlash
      str_remove("[/].*")

  }
  
  # assuming you were able to obtain a base and key, 
  # either directly or from the sharelink,
  # make the download link.
  if(!is.null(key) & !is.null(base)){
    
    # Make a URL downloader
    paste(
      base,  # base URL for Google Sheets
      key, "/", # add the specific spreadsheet ID
      "export?format=", format, # add the format
      if(!is.null(gid)){
        # If there's a specific sheet, add its ID here
        paste("&", "gid=", gid, sep = "")}, # add the sheet ID
      sep = "") %>%
      return()
    
  }else{
    print("Must supply either a sharelink or a key.")
    stop()
  }
}