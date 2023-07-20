# Set options
knitr::opts_chunk$set(echo = TRUE, message = FALSE, warning = FALSE, cache = TRUE)
options(knitr.graphics.auto_pdf = TRUE)
# Load packages
library(tidyverse)
library(bookdown)
library(htmltools)

# Clear environment
rm(list = ls())

# Load all functions in the f directory
funs = dir("f", full.names = TRUE)
funs %>% purrr::map(~source(.))

# Update any static data for us.
update(images = TRUE)
i = images() # Load images metadata list
