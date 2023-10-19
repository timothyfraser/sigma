# Skill: Functions in `R` {.unnumbered}



We've learned how to use built-in `R` functions like `dnorm()` and `pnorm()` to analyze distributions, but sometimes it's going to be more helpful to be able to (A) do the math by hand or (B) code your function to do it. So, let's learn how in the world you do that!

<br>
<br>

## Getting Started {-}

### Packages {-}

We'll be using the `tidyverse` package, a super-package that auto-loads `dplyr`, `ggplot2`, and other common functions.


```r
library(tidyverse)
```

<br>

## Coding your own function! {-}

`Functions` are machines that do a specific **calculation** using an **input** to produce a specific **output**.


```{=html}
<div class="DiagrammeR html-widget html-fill-item-overflow-hidden html-fill-item" id="htmlwidget-1868d097390373c70450" style="width:100%;height:144px;"></div>
<script type="application/json" data-for="htmlwidget-1868d097390373c70450">{"x":{"diagram":"graph LR\n subgraph before\n i[input data <i>x<\/i>]\n end\n subgraph function\n c[calculation]\n end\n subgraph after\n o[output data <i>y<\/i>]\n end\n i --> c\n c --> o"},"evals":[],"jsHooks":[]}</script>
```

Below, we'll write an example function, called `add(a, b)`. 

- This function takes two `numeric` values, `a` and `b`, as `inputs`, and adds them together. 

- Using `function()`, we'll tell `R` that our function contains two inputs, `a` and `b`. 

- Then, using `{ ... }`, we'll put the action we want `R` to do in there. 

- The function can involve multiple operations inside it. But at the end, you need to print *one* final output, or put `return()` around your output.


```r
# Make function
add <- function(a, b){
  # Compute and directly output
  a + b 
}
add(1, 2)
```

```
## [1] 3
```


```r
# This also works
add <- function(a, b){
  # Assign output to a temporary object
  output <- a + b
  # Return the temporary object 'output'
  return(output)
}
# 
add(1, 2)
```

```
## [1] 3
```

<br>
<br>

## Functions with Default Inputs {-}

- You can also assign default `input` values to your `function`. Below, we write that by default, `b = 2`. If we supply a different `b`, the default will get overwritten, but otherwise, we won't need to supply `b`.


```r
add = function(a, b = 2){
  a + b
}
```

Let's try it!


```r
# See? I only need to write 'a' now 
add(1)
```

```
## [1] 3
```

```r
# But if I write 'b' too....
add(1, 2)
```

```
## [1] 3
```

```r
# And if I change 'b'...
add(1, 3)
```

```
## [1] 4
```

```r
# It will adjust accordingly
```


```r
# clear data
remove(add)
```

Great! Let's go make some functions!


