# Skill: Failure Modes and Effects Analysis in R {.unnumbered}



This tutorial will introduce you to **Failure Modes and Effects Analysis (FMEA)** in R!

## Getting Started {-}

Please open up your project on RStudio.Cloud, for our [Github class repository](https://github.com/timothyfraser/sysen). Start a new R script (File \>\> New \>\> R Script). Save the R script as `lesson_3.R`. And let's get started!

### Load Packages  {-}


```r
# Load tidyverse, which contains dplyr and most data wrangling functions
library(tidyverse)
# Load DiagrammeR, which we'll use to make diagrams today!
library(DiagrammeR) 
```

## Example: Ben and Jerry's Ice Cream {-}

Ben and Jerry's main headquarters is in Waterbury, VT, just outside of Burlington, where it makes *a lot* of ice cream. (It's also fun to visit.) Their staff likely has to take considerable care to make sure that all that ice cream stays refrigerated! Suppose Ben and Jerry's has decided to build a new ice cream production plant in Ithaca, NY.

For the sake of Ben and Jerry's (nay, the world!) let's use Failure Modes and Effects Analysis (FMEA) to identify any hypothetical vulnerability that might occur at this new ice cream business!

<img src="https://www.benjerry.com/files/live/sites/systemsite/files/flavors/category-refresh/header_mobile_0019_our_flavors_US.jpg" style="display: block; margin: auto;" />

### Scope & Resolution {-}

As our scope, we're going to just focus on **melting**. What are all the possible ways that ice cream could melt during this process? Melting would have several negative impacts, such as getting exposed to heat, bacteria, and, worst of all, melting the ice cream! This example is primarily people-centric, because it's important to remember that *people* are part of our technological systems!

<br>
<br>

### Measuring Criticality {-}

FMEA includes uses 3 measures to calculate a **criticality** index, meaning the *overall risk of each combination of severity and underlying conditions.*

\$ severity \times occurence \times detection = criticality \$

Each gets classified on a scale from 1-10:

-   `severity`: 1 = none, 10 = hazardous/catastrophic

-   `occurrence`: 1 = almost impossible, 10 = almost certain

-   `detection`: 1 = almost certain, 10 = almost impossible

These will produce a `criticality` index from 1 to 1000. Suppose we want to be 99% sure that our technology won't fail and negatively impact society. We would need a `criticality` index (also known as RPN) of `990` points or less! (Because `1000 - 10 = 990)`.)

So, let's analyze them!

<br>
<br>

### Block Diagram {-}

Below, we've visualized what the process of shipping out ice cream looks like once it has been made. This involves the following several steps:

- Worker 1 puts ice cream in Freezer

- Worker 2 loads ice cream into Truck

- Worker 3 transports ice cream to Store

- Also, Worker 2 takes the ice cream from the Freezer for loading

- And Worker 3 drives the ice cream from loading dock to Store

Plus, several possible failure modes are involved, as discussed below.

<div class="figure">

```{=html}
<div class="DiagrammeR html-widget html-fill-item-overflow-hidden html-fill-item" id="htmlwidget-7355da3baba1da8f02f5" style="width:100%;height:384px;"></div>
<script type="application/json" data-for="htmlwidget-7355da3baba1da8f02f5">{"x":{"diagram":"graph LR\n subgraph People\nw1(Worker 1)\nw2(Worker 2)\nw3(Worker 3)\nend\n subgraph Events\n freezer[Freeze<br>Ice Cream]\n loading[Load<br>onto Truck]\n transport[Transport<br>to Store]\n end\n w1 --> freezer\n w2 --> loading\n w3 --> transport\n freezer --> w2\n loading --> w3\n subgraph Failures\n fail_break[freezer breaks]\n fail_time[left out too long]\n fail_eat[worker eats it]\n end\n freezer --> fail_break\n loading --> fail_time\n loading --> fail_eat\n transport --> fail_time\n transport --> fail_eat"},"evals":[],"jsHooks":[]}</script>
```

<p class="caption">(\#fig:unnamed-chunk-3)Ben & Jerry's Ice Cream Block Diagram</p>
</div>

<br>
<br>

### Failure Modes {-}

We'll make a tidy `data.frame()` of each of the ways our `block diagram` above could fail, which were contained above in `failures`. We'll call this data.frame `f`.


```r
f <- tibble(
  # Make a vector of routes to failure
  failure_mode = c(
    "freezer --> fail_break",
    "loading --> fail_time",
    "loading --> fail_eat",
    "transport --> fail_time",
    "transport --> fail_eat")
)

  # Worker 2 could leave ice cream out while loading
  # Worker 2 could eat the ice cream while loading
  # Worker 3 could leave the ice cream out in transit
  # Worker 3 could eat the ice cream in transit
```

## Calculating Criticality {-}

Next, we're going to make a few judgement calls, to calculate the overall risk for this FMEA.

<br>
<br>

### Estimate Severity {-}

What's the `severity` of the effects of these failures, on a scale from 1 (low) to 10 (high)? We'll `mutate()` the `data.frame` to include a new column `severity`, and save it as a new data.frame `f1`.

-   `fail_break`: It's pretty bad it the freezer breaks; that could ruin days worth of product. Let's call that an `8`. Not catastrophic, but not good for the company!

-   `fail_time`: It's not great it a single shipment gets left out and melts while waiting for pickup. But it's just one shipment. Let's call that a `5`.

-   `fail_eat`: How much ice cream could one worker really eat? That's probably a `1`.


```r
f1 <- f %>%
  mutate(severity = c(8, 5, 1, 5, 1))
# Check out the contents!
f1
```

```
## # A tibble: 5 × 2
##   failure_mode            severity
##   <chr>                      <dbl>
## 1 freezer --> fail_break         8
## 2 loading --> fail_time          5
## 3 loading --> fail_eat           1
## 4 transport --> fail_time        5
## 5 transport --> fail_eat         1
```

<br>
<br>

### Estimate Occurrence {-}

How often does this occur, from 1 (almost never) to 10 (almost always)? Let's rank `occurrence` as follows:

-   `fail_break`: It's pretty rare that the freezer would break (eg. `2`).

-   `fail_time`: It's probably somewhat rare that shipments melt (eg. `5`).

-   `fail_eat`: If I were a worker, I would eat that all the time (eg. `8`).


```r
f2 <- f1 %>%
  mutate(occurrence = c(2, 5, 8, 5, 8))
```

<br>
<br>

### Estimate Detection {-}

Finally, how likely is it that we would detect the occurrence? If very likely, that's a `1`. If very unlikely, that's a `10`.

-   `fail_break`: Workers would very quickly detect if the freezer were broken. (eg. `1`).

-   `fail_time`: You might not know it had melted until the product gets to the store. (eg. `8`)

-   `fail_eat`: Might get caught. Low chance. (eg. `3`).


```r
f3 <- f2 %>%
  mutate(detection = c(1, 8, 3, 8, 3))
```

<br>
<br>

### Estimate Criticality (RPN) {-}

Using our data in `f3`, let's estimate `criticality` (aka RPN, the risk priority number).


```r
f4 <- f3 %>%
  mutate(criticality = severity * occurrence * detection)
```

We can add up the `criticality/RPN` to estimate the total risk priority, out of `1000`, which is the `max_criticality` possible. We can divide these two to get the `probability` of system failure. Is that risk greater than `0.010`, aka `0.1%`? If so, bad news!


```r
f4 %>%
  summarize(
    total_criticality = sum(criticality),
    max_criticality = 10*10*10,
    probability = total_criticality / max_criticality)
```

```
## # A tibble: 1 × 3
##   total_criticality max_criticality probability
##               <dbl>           <dbl>       <dbl>
## 1               464            1000       0.464
```

Well, that's not good! Looks like the new factory will need to figure out a way to keep their product from melting! (In reality, I'm sure Ben and Jerry's has strict quality control!)

<br>
<br>

---

## Learning Check 1 {.unnumbered #LC1}

**Question**

What *other* ways could failure occur here? Add three more kinds of failure to your `tibble` `f`, then estimate their `severity`, `occurence`, `detection`, and `criticality`, and recalculate the total probability of `failure` at this ice cream plant.


<details><summary>**[View Answer!]**</summary>
  

```r
fprime <- tibble(
  # Make a vector of routes to failure
  failure_mode = c(
    "freezer --> fail_break",
    "loading --> fail_time",
    "loading --> fail_eat",
    "transport --> fail_time",
    "transport --> fail_eat",
    # Technically, worker 1 could eat it before taking it to freezer
    "w1 --> fail_eat",
    # A fourth worker at the store could eat it before delivering it
    "w4 --> fail_eat",
    # The fourth worker could also leave it out!
    "w4 --> fail_time")
) %>%
  # Estimate quantities of interest
    mutate(severity = c(8, 5, 1, 5, 1, 1, 1, 5),
           occurrence = c(2, 5, 8, 5, 8, 8, 8, 5),
           detection = c(1, 8, 3, 8, 3, 3, 3, 8)) %>%
  # Calculate criticality
  mutate(criticality = severity * occurrence * detection)

# Let's check it out!
fprime
```

```
## # A tibble: 8 × 5
##   failure_mode            severity occurrence detection criticality
##   <chr>                      <dbl>      <dbl>     <dbl>       <dbl>
## 1 freezer --> fail_break         8          2         1          16
## 2 loading --> fail_time          5          5         8         200
## 3 loading --> fail_eat           1          8         3          24
## 4 transport --> fail_time        5          5         8         200
## 5 transport --> fail_eat         1          8         3          24
## 6 w1 --> fail_eat                1          8         3          24
## 7 w4 --> fail_eat                1          8         3          24
## 8 w4 --> fail_time               5          5         8         200
```


```r
# Let's calculate the total risk!
fprime %>%
  summarize(
    total_criticality = sum(criticality),
    max_criticality = 10*10*10,
    probability = total_criticality / max_criticality)
```

```
## # A tibble: 1 × 3
##   total_criticality max_criticality probability
##               <dbl>           <dbl>       <dbl>
## 1               712            1000       0.712
```

Ooph! Not good!

<br>

</details>
  
---

<br>
<br>

<br>

## Conclusion {-}

Great work! All done! See you in class!



