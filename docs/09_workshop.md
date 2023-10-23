# Workshop: Fault Tree Analysis in R



Fault trees are visual representation of boolean probability equations, typically depicting the *minimal cut sets* of necessary events leading to system failure. We're going to learn how to make calculations about fault trees in `R`!

## Getting Started {-}

### Prerequisites {-}

As a prerequisite for this workshop, be sure to have read our class reading on Fault Trees! 
You'll need to install a few packages real quick below. Here they are.


```r
install.packages(c("devtools", "admisc", "tidygraph", "ggraph", "QCA"))
# Install the tidyfault package!
devtools::install_github("timothyfraser/tidyfault")
# Select, 'install all packages'
# on the menu that will pop up in your console
```


### Load Packages {-}


```r
library(tidyverse)
library(tidyfault)
```

## Simulating Fault Trees

Fault Trees are a powerful way of modeling the probability of a top event, eg. a big prominent failure, like a nuclear disaster, a missile launch, etc. It supposes that a series of different chains of events can all lead to that top event. Each event in the chain has a probability, and these all can be represented graphically and numerically using boolean logic to create functions! All fault trees can be represented as a function - an equation to estimate the probability of the top event.

Fortunately, fault trees are extremely flexible. You can apply all of our past simulation approaches, probability rules, lifespan distribution concepts, and reliability analysis tools to them. 

### Example: Superman Fault Tree

A favorite simple fault tree example of mine is the 'Superman Turns Evil' fault tree. It consists of a few events:

- `T`: Superman turns evil
- `M`: Superman movies do poorly at the box office
- `C`: Boring Childhood in Kansas
- `D`: Lois Lane Dumps Superman
- `K`: Steps on Kryptonite Lego in the middle of the night

<img src="09_workshop_files/figure-html/unnamed-chunk-3-1.png" width="672" />

In this fault tree, it looks like Superman could turn evil if (A) Superman Movies do poorly at the box office OR (B) if all 3 other conditions happen (boring childhood, dumped by Lois Lane, steps on Kryptonite Lego). 


### Using Raw Probabilities

We could represent that using boolean logic. So if we know the probability of events `m`, `c`, `d`, and `k`, we can calculate the probability of the top event `top`.


```r
f1 = function(m, c, d, k){
  top = m + c * d * k 
  return(top)
}
# For example... given these probabilities, the chance Superman turns evil is highly contigent on event m - the success of superman movies at the box office.
probs1 = f1(m = 0.50, c = 0.99, d = 0.25, k = 0.01)
# view it!
probs1 
```

```
## [1] 0.502475
```

## Learning Check 1 {.unnumbered #LC1}

**Question**

You are tasked with assessing the risk of a widespread outbreak of a contagious disease in a population. The top event is defined as the **widespread outbreak** of a contagious disease in a population. This top event T can occur (G1) if any of the 3 following crises occur (G2, G3, or G4).

**G2: Insufficient Vaccination Coverage**:
All of the following must occur for this crisis to happen:
Causes and Probabilities:
- A. Lack of public awareness: P(Lack of public awareness) = 0.2 (20%)
- B. Limited access to vaccines: P(Limited access) = 0.15 (15%)
- C. Vaccine hesitancy due to misinformation: P(Vaccine hesitancy) = 0.3 (30%)

**G3: Ineffective Quarantine Measures**:
Any of the following can lead to this crisis:
Causes and Probabilities:
- D. Inadequate quarantine protocols: P(Inadequate protocols) = 0.1 (10%)
- E. Non-compliance with quarantine rules: P(Non-compliance) = 0.15 (15%)
- F. Inefficient monitoring of quarantined individuals: P(Inefficient monitoring) = 0.2 (20%)

**G4: Mutation of the Pathogen:**
Both events must occur for this crisis to occur.
Causes and Probabilities:
- G. High mutation rate of the pathogen: P(High mutation rate) = 0.05 (5%)
- H. Inadequate monitoring of the pathogen mutations: P(Inadequate monitoring) = 0.1 (10%)

<details><summary>**[View Answer!]**</summary>

Use these events' probabilities to construct a boolean equation and its function in R!


```r
f = function(a = 0.2, b = 0.15, c = 0.3, d = 0.1, e = 0.15, f = 0.2, g = 0.05, h = 0.1){
  # G2. Probability of Insufficient Vaccination Coverage:
  # All of the sub-events must occur for this intermediate event to happen:
  p_insufficient_vaccine_coverage = a * b * c # Probabilities for AND logic
  
  # G3. Probability of Ineffective Quarantine Measures:
  # Any of the sub-event event can lead to this intermediate event:
  p_quarantine_measures = d + e + f   # Probabilities for OR logic
  
  # G4. Probability of Mutation of the Pathogen:
  # Both conditions need to be present in order for pathogen to mutate:
  p_pathogen_mutation <- g * h  # Probabilities for AND logic

  
  # If EITHER insufficient vaccine coverage 
  # OR no quarantine measures 
  # OR pathogen mutation occur,
  # the outbreak occurs.
  
  # T = OR Gate G1 = G2 + G3 + G4
  p_top = p_insufficient_vaccine_coverage + p_quarantine_measures + p_pathogen_mutation
  
  return(p_top)
}
```


Let's see what the probability of widespread outbreak, in this hypothetical scenario, turns out to be:


```r
f(a = 0.2, b = 0.15, c = 0.3, d = 0.1, e = 0.15, f = 0.2, g = 0.05, h = 0.1)
```

```
## [1] 0.464
```

</details>


---



### Using Failure Rates at Time `t`

But if we knew the failure rate of each event, we could calculate the probability of the top event at any time `t`!


```r
f2 = function(t, lambda_m, lambda_c, lambda_d, lambda_k){
  # Get probability at time t...
  prob_m = pexp(t, rate = lambda_m)
  prob_c = pexp(t, rate = lambda_c)
  prob_d = pexp(t, rate = lambda_d)
  prob_k = pexp(t, rate = lambda_k)
  # Use boolean equation to calculate top event
  prob_top = prob_m + (prob_c * prob_d * prob_k)
  return(prob_top)
}

# Then we could simulate the probability of the top event over time!
probs2 = tibble(t = 1:100) %>%
  mutate(prob = f2(t = t, lambda_m = 0.01, lambda_c = 0.001, 
                   lambda_d = 0.025, lambda_k = 0.00005))
# Check out the first few rows!
probs2 %>% head(3)
```

```
## # A tibble: 3 × 2
##       t    prob
##   <int>   <dbl>
## 1     1 0.00995
## 2     2 0.0198 
## 3     3 0.0296
```


```r
# Let's visualize it!
ggplot() + 
  geom_area(data = probs2, mapping = aes(x = t, y = prob))
```

<img src="09_workshop_files/figure-html/unnamed-chunk-8-1.png" width="672" />

---

## Learning Check 2 {.unnumbered #LC2}

**Question**

Suppose we have a small fault tree, where the top event T depends on either [A and B] OR [B and C] occuring. What is the probability of the top event after `1` hour vs. after `10` hours, given the following parameters? 

- `lambda_a = 0.05`
- `lambda_b = 0.03`
- `lambda_c = 0.02`


<details><summary>**[View Answer!]**</summary>


```r
# Let's create a function calculate probability of the top event using failure rates and time period
f = function(
    t = 1, # Time period we want to analyze the events for    
    lambda_a = 0.05, # Failure rate for event A 
    lambda_b = 0.03, # Failure rate for event B
    lambda_c = 0.02 # Failure rate for event C
    ){
  
  # As these events follow exponential distribution, we need to calculate intermediate probabilities accoridingly
  prob_a = pexp(t, rate = lambda_a)
  prob_b = pexp(t, rate = lambda_b)
  prob_c = pexp(t, rate = lambda_c)
  
  # Get probability of top event
  prob_top = (prob_a * prob_b) + (prob_b * prob_c)
  
  return(prob_top)
} 
```


```r
# Probability of failure after 1 hour
f(t = 1, lambda_a = 0.05, lambda_b = 0.03, lambda_c = 0.02)
```

```
## [1] 0.002026606
```


```r
# Probability of failure after 10 hours
f(t = 10, lambda_a = 0.05, lambda_b = 0.03, lambda_c = 0.02)
```

```
## [1] 0.1489618
```

</details>

---


### Simulating Uncertainty in Probabilities

We can use simulation to answer several important questions about variation. For example, we can simulate how the probability of the top event would change if the probability of each event varies ever so slightly across 1000 simulations. 

When simulating variation in probabilities, you can use random draws from the binomial distribution, randomly sampling 1s or 0s at a given probability `prob` a total of `n` times.


```r
probs3 = tibble(
  n = 1000,
  prob_m = rbinom(n = n, size = 1, prob = 0.50),
  prob_c = rbinom(n = n, size = 1, prob = 0.99),
  prob_d = rbinom(n = n, size = 1, prob = 0.25),
  prob_k = rbinom(n = n, size = 1, prob = 0.01),
  # Calculate probability of top event for each simulation  
  prob_top = f1(m = prob_m, c = prob_c, d = prob_d, k = prob_k)
)
# Let's get some descriptive statistics - the average will be particularly informative
probs3 %>% 
  summarize(
    mu_top = mean(prob_top),
    sigma_top = sd(prob_top))
```

```
## # A tibble: 1 × 2
##   mu_top sigma_top
##    <dbl>     <dbl>
## 1  0.524     0.502
```

### Simulating Uncertainty in Failure Rates

Usually, we go a few steps further, saying, **suppose the probability of each failure $/lambda$ might vary slightly, according to a normal distribution.** What would be the average probability of failure for the top event? How much should we expect that average to vary, on average? 

Suppose each failure rate has a specific standard error: for `m`, `0.0001`; for `c`, `0.00001`, for `d` and `k`, `0.000002`.


```r
f4 = function(t, lambda_m, lambda_c, lambda_d, lambda_k){
  sim_lambda_m = rnorm(n = 1, mean = lambda_m, sd = 0.0001)
  sim_lambda_c = rnorm(n = 1, mean = lambda_c, sd = 0.00001)
  sim_lambda_d = rnorm(n = 1, mean = lambda_d, sd = 0.000002)
  sim_lambda_k = rnorm(n = 1, mean = lambda_k, sd = 0.000002)
  
  # Get probability at time t...
  sim_prob_m = pexp(t, rate = sim_lambda_m)
  sim_prob_c = pexp(t, rate = sim_lambda_c)
  sim_prob_d = pexp(t, rate = sim_lambda_d)
  sim_prob_k = pexp(t, rate = sim_lambda_k)
  # Use boolean equation to calculate top event
  prob_top = sim_prob_m + (sim_prob_c * sim_prob_d * sim_prob_k)
  return(prob_top)
}

# Then we could simulate the probability of the top event over time,
probs4 = tibble(t = 1:100) %>%
  # This would give us 1 random simulation per time period  
  mutate(prob = f4(t = 1:100, lambda_m = 0.01, lambda_c = 0.001, 
                   lambda_d = 0.025, lambda_k = 0.00005))
```


```r
# But we really probably want MANY random simulations per time period.
probs5 = tibble(reps = 1:1000) %>%
  group_by(reps) %>%
  # We can use `reframe()`, a version of summarize()
  # used when you want to return MANY rows per group
  reframe(
    t = 1:100,
    prob = f4(t = t, lambda_m = 0.01, lambda_c = 0.001, 
              lambda_d = 0.025, lambda_k = 0.00005))

probs5 %>% head(3)
```

```
## # A tibble: 3 × 3
##    reps     t   prob
##   <int> <int>  <dbl>
## 1     1     1 0.0101
## 2     1     2 0.0201
## 3     1     3 0.0301
```


```r
# And then we could get quantities of interest for each time period!
probs6 = probs5 %>%
  group_by(t) %>%
  summarize(
    mu = mean(prob), 
    sigma = sd(prob),
    # Exact lower and upper 95% simulated confidence intervals
    lower = quantile(prob, probs = 0.025),
    upper = quantile(prob, probs = 0.975),
    # Approximated lower and upper 95% confidence intervals
    lower_approx = mu - qnorm(0.025) * sigma,
    upper_approx = mu + qnorm(0.975) * sigma)

probs6 %>% head(3)
```

```
## # A tibble: 3 × 7
##       t      mu     sigma   lower  upper lower_approx upper_approx
##   <int>   <dbl>     <dbl>   <dbl>  <dbl>        <dbl>        <dbl>
## 1     1 0.00995 0.0000998 0.00976 0.0102       0.0101       0.0101
## 2     2 0.0198  0.000198  0.0194  0.0202       0.0202       0.0202
## 3     3 0.0296  0.000293  0.0290  0.0301       0.0301       0.0301
```

Let's visualize that confidence interval over time!


```r
ggplot() +
  geom_ribbon(data = probs6, mapping = aes(x = t, ymin = lower, ymax = upper))
```

<img src="09_workshop_files/figure-html/unnamed-chunk-16-1.png" width="672" />

The sky is the limit! Happy fault tree simulating!




---


<br>
<br>


## Learning Check 3 {.unnumbered  #LC3}

Suppose we have some fault tree involving 3 key events, A, B, and C. Suppose these events have the following failure rates: lambda_a = 0.05, lambda_b = 0.03, and lambda_c = 0.02. 
Simulate the 95% confidence interval for the probability of each event, for each hour from 0 to 100 hours, assuming a standard error for each of 0.001. Then visualize these confidence intervals as a `ribbon` plot.

<details><summary>**[View Answer!]**</summary>


```r
# Firstly, let's load necessary libraries for plotting
library(ggplot2)
library(dplyr)

stat = tibble(
  reps = 1:1000,
  # Simulate 1000 lambdas!
  lambda_a = rnorm(n = 1000, mean = 0.05, sd = 0.001),
  lambda_b = rnorm(n = 1000, mean = 0.03, sd = 0.001),
  lambda_c = rnorm(n = 1000, mean = 0.02, sd = 0.001)
) %>%
  # For each simulation...
  group_by(reps) %>%
  reframe(
    # Get a time frame from 1 to 100 hours
    t = 1:100,
    # Get the probabilities for that time frame given each simulated lambda
    prob_a = pexp(t, rate = lambda_a),
    prob_b = pexp(t, rate = lambda_b),
    prob_c = pexp(t, rate = lambda_c)
  ) %>%
  # For each time period, get the lower and upper confidence interval
  group_by(t) %>%
  summarize(
    # 95% CI for prob a
    lower_a = quantile(prob_a, probs = 0.025),
    upper_a = quantile(prob_a, probs = 0.975),
    # 95% CI for prob b
    lower_b = quantile(prob_b, probs = 0.025),
    upper_b = quantile(prob_b, probs = 0.975),
    # 95% CI for prob c
    lower_c = quantile(prob_c, probs = 0.025),
    upper_c = quantile(prob_c, probs = 0.975))

# Let's view it
stat %>% head(3)
```

```
## # A tibble: 3 × 7
##       t lower_a upper_a lower_b upper_b lower_c upper_c
##   <int>   <dbl>   <dbl>   <dbl>   <dbl>   <dbl>   <dbl>
## 1     1  0.0470  0.0506  0.0277  0.0314  0.0179  0.0218
## 2     2  0.0919  0.0986  0.0546  0.0619  0.0355  0.0430
## 3     3  0.135   0.144   0.0807  0.0913  0.0528  0.0639
```


```r
# Let's make the plot!
ggplot() +
  # Plot bands for event a
  geom_ribbon(
    data = stat, 
    mapping = aes(x = t, ymin = lower_a, ymax = upper_a, fill = "A"), 
    alpha = 0.25) +
  # Plot bands for event b
  geom_ribbon(
    data = stat, 
    mapping = aes(x = t, ymin = lower_b, ymax = upper_b, fill = "B"),
    alpha = 0.25) +
  # Plot bands for event c
  geom_ribbon(
    data = stat, 
    mapping = aes(x = t, ymin = lower_c, ymax = upper_c, fill = "C"),
    alpha = 0.25) +
  theme_classic() +
  labs(title = "Probability of Events over 100 hours",
       x = "Hours", y = "Probability (95% CI)", fill = "Event Type")
```

<img src="09_workshop_files/figure-html/unnamed-chunk-19-1.png" width="672" />

</details>

---

## Visualizing Fault Trees in R

We can *draw* fault trees easily enough by hand, but how do we record their data in a machine readable format? We can use conventions from *network science* to record these data in two lists: (1) an 'edgelist' of edges connecting nodes, and (2) a 'nodelist' of nodes, connected by edges. 

<br>
<br>

### Making a Nodelist

We can use the `tribble()` function available when loading the `tidyverse` package to write out small data.frames row by row. In `nodes`, our nodelist:

- every node must have a unique ID, called `name`.

- some events reappear multiple times in the same tree; we must give these nodes *different* `name` but the *same* `event` name.

- each node should be classified by `type` as (1) an `and` gate, (2) an `or` gate, or (3) `not` a gate. We can use `factor()` to tell R to always remember `"and"`, `"or"`, and `"not"` in that order (useful for `ggplot` legends).

- classic fault trees sometimes write events and the gates that condition them as separate nodes, but as far as the graph is concerned, they are really the *same node*. So, remember to combine them for analysis.


```r
# Let's make a data.frame of nodes!
tribble(
  # Make the headers, using a tilde
  ~id, ~event, ~type,
  # Add the value entries
  "T",   "T",   "top",
  "G1",  "G1",  "and",
  # Notice how event 'B' appears twice,
  # so it has a logical but differentiated `name` "B1" and "B2"?
  "B1",  "B",   "not",
  "B2",  "B",   "not",
  "C1",  "C",   "not") %>%
  # Classify 'type' as a factor, with specific levels
  mutate(type = factor(type, levels = c("top", "and", "or", "not")))
```

```
## # A tibble: 5 × 3
##   id    event type 
##   <chr> <chr> <fct>
## 1 T     T     top  
## 2 G1    G1    and  
## 3 B1    B     not  
## 4 B2    B     not  
## 5 C1    C     not
```

<br>
<br>

### Making an Edgelist

Next, we can use `tribble()` to make an edgelist of our fault tree (or use `read_csv()` to read in an edgelist). Edgelists should follow these conventions:

- each row shows a unique edge between nodes, recording their node `id`s from the top-down in the `from` and `to` columns.


```r
# For example....
tribble(
  ~from, ~to,
  "T",   "G1",
  "G1", "G2",
  "G2", "B1",
  "G2", "G5") 
```

```
## # A tibble: 4 × 2
##   from  to   
##   <chr> <chr>
## 1 T     G1   
## 2 G1    G2   
## 3 G2    B1   
## 4 G2    G5
```

### Our Data

In this example, we're going to use the default data in `tidyfault`, called `fakenodes` and `fakeedges`. You can download it like this:


```r
data("fakenodes")
data("fakeedges")
```


```r
fakenodes
```

```
## # A tibble: 12 × 3
##       id event type 
##    <dbl> <chr> <fct>
##  1     1 T     top  
##  2     2 G1    and  
##  3     3 G2    and  
##  4     4 G3    or   
##  5     5 G4    and  
##  6     6 G5    or   
##  7     7 A     not  
##  8     8 B     not  
##  9     9 B     not  
## 10    10 C     not  
## 11    11 C     not  
## 12    12 D     not
```


```r
fakeedges
```

```
## # A tibble: 11 × 2
##     from    to
##    <dbl> <dbl>
##  1     1     2
##  2     2     3
##  3     3     8
##  4     3     6
##  5     6    10
##  6     6    12
##  7     2     4
##  8     4     7
##  9     4     5
## 10     5     9
## 11     5    11
```


<br>
<br>

### Getting a Fault Tree Layout

Using `tidyfault`'s `illustrate()` function, we can quickly assign `x` and `y` coordinates for a 'tree' layout to to our `fakenodes` and `fakeedges`. We say `type = "both"` because we want to receive coordinates for *both* the nodes and edges.


```r
gg = illustrate(nodes = fakenodes, edges = fakeedges, 
                type = "both", node_key = "id")
```

This returns a `list()` object. `list()` objects are collections of data.frames - sort of like a vector whose values are entire data.frames. We can query the values inside lists by using the `$`, just like a data.frame.


```r
# see the nodes
gg$nodes %>% head(3)
```

```
##    x y id event type
## 1  0 4  1     T  top
## 2  0 3  2    G1  and
## 3 -1 2  3    G2  and
```

```r
# see the edges
gg$edges %>% head(3)
```

```
## # A tibble: 3 × 5
## # Groups:   edge_id [2]
##   edge_id direction    id     x     y
##     <int> <chr>     <dbl> <dbl> <dbl>
## 1       1 from          1     0     4
## 2       1 to            2     0     3
## 3       2 from          2     0     3
```


### Visualize a Fault Tree


```r
ggplot() +
  # Plot each line corresponding to the unique edge id, used to group them
  geom_line(data = gg$edges, mapping = aes(x = x, y = y, group = edge_id)) +
  # Plot each point
  geom_point(data = gg$nodes, 
             mapping = aes(x = x, y = y, shape = type, fill = type),
             size = 10) +
  # Plot labels!
  geom_text(data = gg$nodes, mapping = aes(x = x, y = y, label = event)) +
  # We can also assign shapes!
  # (shapes 21, 22, 23, 24, and 25 have fill and color)
  scale_shape_manual(values = c(22, 24, 25, 21)) +
  # And assign some poppy colors here
  scale_fill_manual(values = c("darkgrey", "cyan", "coral", "lightgrey")) +
  # Finally, we can make a clean void theme, with the legend below.
  theme_void(base_size = 14) +
  theme(legend.position = "bottom")
```

<img src="09_workshop_files/figure-html/unnamed-chunk-28-1.png" width="672" />

<br>
<br>

---

## Cutsets

Fault Trees are *big* - and some `events` are more critical than others. We want to identify two kinds of information.

1. **cutsets**: all the possible sets of events which together trigger failure, called **cutsets**.

2. **minimal cutsets**: the most reduced set of events which trigger failure.

To do this, we're going to use an algorithm, called the MOCUS top-down algorithm. I wrote it in `R` for you! Yay!

### Gates


```r
# To get a data.frame of gates, use curate()!
g = curate(fakenodes, fakeedges)
# Check it
g
```

```
## # A tibble: 6 × 6
##   gate  type  class     n set           items    
##   <chr> <fct> <fct> <int> <chr>         <list>   
## 1 T     top   top       1 " (G1) "      <chr [1]>
## 2 G1    and   gate      2 " (G2 * G3) " <chr [2]>
## 3 G2    and   gate      2 " (B * G5) "  <chr [2]>
## 4 G3    or    gate      2 " (A + G4) "  <chr [2]>
## 5 G4    and   gate      2 " (B * C) "   <chr [2]>
## 6 G5    or    gate      2 " (C + D) "   <chr [2]>
```

### Equations

To get the full boolean equation of the fault tree, use `equate()`!


```r
g %>% equate() 
```

```
## [1] " ( ( (B *  (C + D) )  *  (A +  (B * C) ) ) ) "
```

We can format it as a function too!


```r
f = g %>% equate() %>% formulate()

# Suppose there is each of these probabilities that A, B, C, and D occur
# what's the probability of the top event?
f(A = 0.3, B = 0.5, C = 0.1, D = 0.5)
```

```
## [1] 0.105
```

### Minimal Cutsets

To simplify down to the minimal cutsets, use `concentrate()`! It's pretty quick for small graphs, but gets exponentially longer the more nodes you add. (Especially with `OR` statements.) That's MOCUS's value as well as its tradeoff.


```r
m = g %>% 
  concentrate(method = "mocus")
# 
m
```

```
## [1] "B*C"   "A*B*D"
```

### Coverage

We might want to know, *how important* are each of my minimal cutsets? We can compute the total number of cutsets that include the minimal cutset, the total cutsets leading to failure in general, and the percentage (`coverage`) of cutsets containing your minimal cutset out of all total cutsets leading to failure. It's basically a measure of the explanatory power of your cutsets!


```r
m %>% 
  tabulate(formula = f)
```

```
## # A tibble: 2 × 5
##   mincut query                                        cutsets failures coverage
##   <chr>  <chr>                                          <int>    <int>    <dbl>
## 1 A*B*D  filter(A == 1, B == 1, D == 1, outcome == 1)       2        5      0.4
## 2 B*C    filter(B == 1, C == 1, outcome == 1)               4        5      0.8
```



Happy Fault Tree analysis!
