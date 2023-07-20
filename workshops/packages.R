# Install main classroom use packages
install.packages(
  c("tidyverse",
    "broom",
    "gtools",
    "devtools",
    
    # Visualization packages
    "viridis",
    "ggtext",
    "shadowtext",
    "DiagrammeR",
    
    # Statistical packages
    "mtvnorm",
    "PearsonDS",
    "moments",
    "texreg",
    "mosaicCalc",
    
    # Sample data packages
    "gapminder",
    "nycflights",
    "fivethirtyeight"))

# Install extra packages for visualization and workshop development
install.packages(
  c("magick",
    "rsvg",
    "fontawesome",
    "cowplot",
    "knitr",
    "kableExtra",
    "rmdformats",
    "credentials",
    "gganimate",
    "gifski",
    "plot3D",
    "metR",
    "rsm")
)