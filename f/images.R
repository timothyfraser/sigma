# images.R
# 
# This script produces a function `images()`,
# which will read in our most recent sheet of images 
# and format them as a list, by chunk name, for easy access.
#
# (you can update the sheet with update(images = TRUE))

images = function(){
  
  require(readr)
  require(dplyr)
  require(stringr)
  require(purrr)
  
  # Read in our sheet of images
  sheet = readr::read_csv("images/images.csv")
  
  revised = sheet %>%
    group_by(id) %>%
    summarize(
      # Carry forward these variables
      across(.cols = c(file:license), .fns = ~.x),
      chunks = chunks %>% str_split(pattern = "[;]") %>% unlist() %>% 
        # If there are any blanks, remove them
        str_remove_all("[ ]+") %>%
        # Now, any empty strings will become NAs, and we will drop the NAs.
        na_if("") %>% .[!is.na(.)]) %>%
    # Add the 'images' folder to the start of the file link 
    mutate(file = paste("images/", file, sep = "")) 
  
  output = revised %>%
    # And split into a list for easier access in the markdown document
    split(.$chunks)
  
  return(output)
}
