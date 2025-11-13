# Appendix: `ggplot` tips



## Getting Started {.unnumbered}

`ggplot2` and the Grammar of Graphics behind it is an incredible resource for data visualization.

Looking for extra information on making the perfect visualization? Consider these helpful resources, and see below for extra Learning Checks!

### Resources

- [RGraphGallery](https://r-graph-gallery.com/): hundreds of example charts in `R`.
- [ggplot2 Documentation](https://ggplot2.tidyverse.org/): online guide describing `ggplot` functions.
- [ggplot2 Cheat Sheets](https://github.com/rstudio/cheatsheets/blob/main/data-visualization.pdf): helpful cheat sheets of `ggplot` functions.

### Our Packages

Be sure to load these packages before proceeding!


``` r
library(dplyr) # for data wrangling
library(ggplot2) # for data visualization
```

### Our Data

These exercises use the `diamonds` dataset from the `ggplot2` package.


``` r
# Import the diamonds dataset from the ggplot2 package!
diamonds = ggplot2::diamonds
# Let's glimpse it!
diamonds %>% glimpse()
```

```
## Rows: 53,940
## Columns: 10
## $ carat   <dbl> 0.23, 0.21, 0.23, 0.29, 0.31, 0.24, 0.24, 0.26, 0.22, 0.23, 0.…
## $ cut     <ord> Ideal, Premium, Good, Premium, Good, Very Good, Very Good, Ver…
## $ color   <ord> E, E, E, I, J, J, I, H, E, H, J, J, F, J, E, E, I, J, J, J, I,…
## $ clarity <ord> SI2, SI1, VS1, VS2, SI2, VVS2, VVS1, SI1, VS2, VS1, SI1, VS1, …
## $ depth   <dbl> 61.5, 59.8, 56.9, 62.4, 63.3, 62.8, 62.3, 61.9, 65.1, 59.4, 64…
## $ table   <dbl> 55, 61, 65, 58, 58, 57, 57, 55, 61, 61, 55, 56, 61, 54, 62, 58…
## $ price   <int> 326, 326, 327, 334, 335, 336, 336, 337, 337, 338, 339, 340, 34…
## $ x       <dbl> 3.95, 3.89, 4.05, 4.20, 4.34, 3.94, 3.95, 4.07, 3.87, 4.00, 4.…
## $ y       <dbl> 3.98, 3.84, 4.07, 4.23, 4.35, 3.96, 3.98, 4.11, 3.78, 4.05, 4.…
## $ z       <dbl> 2.43, 2.31, 2.31, 2.63, 2.75, 2.48, 2.47, 2.53, 2.49, 2.39, 2.…
```
<br>
<br>

---

## Flipping Axes

### Learning Check 1 {.unnumbered .LC}

**Question**

Sometimes, the names of categories won't fit well. We can try the following. Compare these two plots. What did we do?


``` r
library(ggplot2)
diamonds = ggplot2::diamonds
# Plot 1
gg1 = gg1 = ggplot(data = diamonds, mapping = aes(x = cut, y = price, 
                                      group = cut, fill = cut)) +
  geom_boxplot()
# Plot2
ggplot(data = diamonds, mapping = aes(x = cut, y = price, 
                                      group = cut, fill = cut)) +
  geom_boxplot() + 
  coord_flip()
```


<details><summary>**[View Answer!]**</summary>

We used `coord_flip()` to **flip** the coordinates of the `x` and `y` axis, which gives our `cut` labels more room!

</details>


<br>
<br>
<br>

---

## Legend Positioning

### Learning Check 8 {.unnumbered .LC}

**Question**

Sometimes, the legend doesn't fit well. We can try this:

What happens when you change `legend.position` from `"right"` to `"bottom"` to `"left"` to `"top"`?


``` r
library(ggplot2)
diamonds = ggplot2::diamonds
ggplot(data = diamonds, mapping = aes(x = cut, y = price,
  group = cut, fill = cut)) +
  geom_boxplot() + coord_flip() +
  theme(legend.position = "bottom")
ggplot(data = diamonds, mapping = aes(x = cut, y = price,
  group = cut, fill = cut)) +
  geom_boxplot() + coord_flip() +
  theme(legend.position = "right")
ggplot(data = diamonds, mapping = aes(x = cut, y = price, 
  group = cut, fill = cut)) +
  geom_boxplot() + coord_flip() +
  theme(legend.position = "left")
ggplot(data = diamonds, mapping = aes(x = cut, y = price, 
  group = cut, fill = cut)) +
  geom_boxplot() + coord_flip() +
  theme(legend.position = "top")
```


<details><summary>**[View Answer!]**</summary>

These four values for `legend.position` will relocate the `fill` legend (and any other legends) to be at the top, bottom, left, or right of the visual!

</details>

---


## Breaking Up a Visual

Finally, we might want to break up our visual into multiple parts. We can use `facet_wrap` to do this, but how exactly does it work? Try the learning check below.

---

### Learning Check 10 {.unnumbered .LC}

**Question**

What changed in the code below, and what did it result in?


``` r
library(ggplot2)
diamonds = ggplot2::diamonds
ggplot(data = diamonds, mapping = aes(x = price, fill = cut)) +
  geom_histogram(color = "white") + 
  facet_wrap(~cut) + # must be categorical variable
  labs(x = "Price (USD)",
       y = "Frequency of Price (Count)",
       title = "US Diamond Sales")
```

<details><summary>**[View Answer!]**</summary>

This visual split up our histograms into separate panels (making it much more readable), and easier to compare distributions. We write `facet_wrap(~` before the variable name (eg. `cut`) to specify that we want to split up the data by the values of `cut`. This sorts our rows of data into 5 different piles (since there are 5 different categories in `cut`) and makes a panel out of each.

</details>

---


