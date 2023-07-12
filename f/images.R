# images.R
# 
# This script produces a function `images()`,
# which will read in our most recent sheet of images 
# and format them as a list, by chunk name, for easy access.
#
# (you can update the sheet with update(images = TRUE))

images = function(){
  # Read in our sheet of images
  read_csv("images/images.csv") %>%
    group_by(id) %>%
    summarize(
      # Carry forward these variables
      across(cols = c(file:license)),
      chunks = chunks %>% str_split(pattern = "[;]") %>% unlist() %>% 
        # If there are any blanks, remove them
        str_remove_all("[ ]+") %>%
        # Now, any empty strings will become NAs, and we will drop the NAs.
        na_if("") %>% .[!is.na(.)]) %>%
    # Add the 'images' folder to the start of the file link 
    mutate(file = paste("images/", file, sep = "")) %>%
    # And split into a list for easier access in the markdown document
    split(.$chunks) %>%
    return()
}
