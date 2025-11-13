# Probability in `R`



This tutorial will review **probability** and how to code joint and conditional probabilistic analyses in `R`!

<br>
<br>

## Getting Started {-}

Please open up your Posit.Cloud project. Start a new R script (File >> New >> R Script). Save a new R script. And let's get started!

### Load Packages {-}

In this tutorial, we're going to use more of the `dplyr` package.


``` r
library(dplyr)
```

## Key Functions

We're going to use 3 functions a *lot* below. This includes `bind_rows()`, `mutate()`, and `summarize()`. So what are they?

- `bind_rows()`: stacks 2 or more `data.frames` on top of each other, matching columns by name.

- `mutate()`: creates or edits variables in a `data.frame`.

- `summarize()`: consolidates many rows of data into a single summary statistic (or a set of them.)

### `bind_rows()`

How might we use `bind_rows()`?


``` r
mycoffee <- bind_rows(
  # Make first data.frame
  data.frame(
    # Containing these vectors style and price
    style = c("latte", "cappuccino", "americano"),
    price = c(5, 4, 3)),
  # Make second data.frame
  data.frame(
    # Containing these vectors style, price, and shop
    style = c("coffee", "hot cocoa"),
             price = c(3, 2),
             shop = c("Gimme Coffee", "Starbucks"))
)
# Notice how they stack, 
# but in first data.frame values,
# shop gets filled with NA, 
# since it wasn't in first dataframe
mycoffee
```

```
##        style price         shop
## 1      latte     5         <NA>
## 2 cappuccino     4         <NA>
## 3  americano     3         <NA>
## 4     coffee     3 Gimme Coffee
## 5  hot cocoa     2    Starbucks
```


### `mutate()`

How might we use `mutate()`?


``` r
mycoffee <- mycoffee %>%
  # Add a new vector (must be of same length as data.frame)
  # vector is number of those drinks purchased
  mutate(purchased = c(5, 4, 10, 2, 1))
```

### `summarize()`

How might we use `summarize()`?


``` r
mycoffee %>%
  # Summarize data.frame into one row
  summarize(
    # Calculate mean price of drinks
    mean_price = mean(price),
    # Calculate total drinks purchased
    total_purchased = sum(purchased))
```

```
##   mean_price total_purchased
## 1        3.4              22
```

Great! Now let's apply these to probability!


<br>
<br>

## Probability

**Probability** refers to how often a specify event is expected to occur, given a sufficient number of times. We're going to learn (and compute!) several common probability formula in `R`.

## Conditional Probability

**Conditional Probability**: probability of two events happening together reflects the probability of the first happening, times the probability of the second happening given that the first has already occurred. 

$$ P(AB) = P(A) \times P(B|A)$$
In other words, if two events are *interdependent*, you **multiply.**

<br>

### Example: Twizzlers

<div class="figure">
<img src="https://hips.hearstapps.com/del.h-cdn.co/assets/17/20/768x548/gallery-1494972479-12509893-10153286565876806-7249155525568646308-n.jpg" alt="Twizzlers vs. Red Vines" width="100%" />
<p class="caption">(\#fig:img_twizzlers)Twizzlers vs. Red Vines</p>
</div>

You've been hired by the Hershey's Chocolate Company to investigate quality control on their Twizzlers sweets packaging line. At the start of an assembly line, you mixed in 8,000 Red Vines with a sample of 10,000 Twizzlers.

- What's the probability of a packer picking up a Red Vine on the assembly line?


``` r
sweets <- data.frame(
# We know there are 10,000 twizzlers
  twizzlers = 10000,
# and 8,000 redvines
  redvines = 8000) %>%
  # So together, there are 18,000 sweets available
  # So there's a 8000-in-18,000 chance of picking a redvine
  mutate(prob_1 = redvines / (twizzlers + redvines))

# Check it!
sweets
```

```
##   twizzlers redvines    prob_1
## 1     10000     8000 0.4444444
```

- But then, what's the probability of a packer picking up 2 Red Vines in a row on the assembly line?


``` r
sweets %>%
    # After picking 1 Red Vine,
  # there's now 1 less Red Vine in circulation
  mutate(
    # Subtract 1 redvine
    redvines = redvines - 1,
    # Recalculate total
    total = twizzlers + redvines) %>%
  # calculate probability of picking a second red vine now that 1 is gone
  mutate(prob_2 = redvines / total) %>%
  # Finally, multiply the first and second probability together
  # When it's this AND that, you multiply
  mutate(prob = prob_1 * prob_2)
```

```
##   twizzlers redvines    prob_1 total    prob_2      prob
## 1     10000     7999 0.4444444 17999 0.4444136 0.1975171
```

Alternatively, if two events are *independent* (mutually exclusive), meaning they do not affect each other, you *add* those probabilities together.

- You dump in a 1000 pieces of Black Licorice. If a packer picks up 2 sweets, what's the probability it's a piece of Black Licorice *or* Red Vines?


``` r
sweets %>%
  # Add a column for black licorice
  mutate(black_licorice = 1000) %>%
  # Get total
  mutate(total = twizzlers + redvines + black_licorice) %>%
  # Recompute probabilities
  mutate(prob_1 = redvines / total,
         prob_2 = black_licorice / total) %>%
  # When it's this OR that, you add probabilities
  mutate(prob_3 = prob_1 + prob_2)
```

```
##   twizzlers redvines    prob_1 black_licorice total     prob_2    prob_3
## 1     10000     8000 0.4210526           1000 19000 0.05263158 0.4736842
```


``` r
remove(mycoffee, sweets)
```


<br>
<br>

## Total Probabilities

We can also examine *total probabilities.*

Any event $A$ that is mutually exclusive from event $E$ (can't happen at the same time) has the following probability...

$$ P(A) = \sum_{i=1}^{n}{P(A|E_{i}) \times P(E_{i}) } $$

### Example: Marbles!

<div class="figure">
<img src="https://bhi61nm2cr3mkdgk1dtaov18-wpengine.netdna-ssl.com/wp-content/uploads/2017/03/marbles.jpg" alt="So many marbles!" width="100%" />
<p class="caption">(\#fig:img_marbles)So many marbles!</p>
</div>

You've got `3` bags ($E_{1 \to 3}$), each containing `3` marbles, each with a different split of red vs. blue marbles. If we choose a bag at random *and* sample a marble at random (2 mutually exclusive events), what's the probability that marble will be red ($P(A)$)?

I like to map these out, so I understand visually what all the possible pathways are. Here's a chart I made (using `mermaid`), where I've diagrammed each possible set of actions, like choosing Bag 1 then Marble *a* (1 pathway), choosing Bag 1 then Marble *b* (a second pathway), etc.  

If we look at the ties to the marbles, you'll see I labeled each tie to a red marble as `1` and each tie to a blue marble as `0`. If we add these pathways up, we'll get the `total probability`: `0.67` (aka `2/3`).

<div class="figure" style="text-align: center">

```{=html}
<div class="DiagrammeR html-widget html-fill-item" id="htmlwidget-28a6c40138c6fe4e4c25" style="width:100%;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-28a6c40138c6fe4e4c25">{"x":{"diagram":"graph TD\n you[You]\n subgraph Bags\n b1[Bag 1]\n b2[Bag 2]\n b3[Bag 3]\n end\n subgraph Marbles\n b1m1((Marble <i>a<\/i>))\n b1m2((Marble <i>b<\/i>))\n b1m3((Marble <i>c<\/i>))\n style b1m1 fill:#FB52A5\n style b1m2 fill:#FB52A5\n style b1m3 fill:#FB52A5\n b2m1((Marble <i>d<\/i>))\n b2m2((Marble <i>e<\/i>))\n b2m3((Marble <i>f<\/i>))\n style b2m1 fill:#FB52A5\n style b2m2 fill:#84A3F5\n style b2m3 fill:#84A3F5\n b3m1((Marble <i>g<\/i>))\n b3m2((Marble <i>h<\/i>))\n b3m3((Marble <i>j<\/i>))\n style b3m1 fill:#84A3F5\n style b3m2 fill:#FB52A5\n style b3m3 fill:#FB52A5\n end\n you--> b1\n you--> b2\n you--> b3\n b1-->|1|b1m1\n b1-->|1|b1m2\n b1-->|1|b1m3\n b2-->|1|b2m1\n b2-->|0|b2m2\n b2-->|0|b2m3\n b3-->|0|b3m1\n b3-->|1|b3m2\n b3-->|1|b3m3"},"evals":[],"jsHooks":[]}</script>
```

<p class="caption">(\#fig:img_mermaid)Drawing Probability Diagrams</p>
</div>

But what if we *can't* diagram it out? Perhaps we're choosing from 100s of marbles, or we're limited on time! How would we solve this problem mathematically?

The key here is knowing that: 

- the blue marbles don't really matter 
- we need the probability of choosing a *bag*
- we need the probability of choosing a *red marble* in each bag.

Here's what we know:

1. There's an equal chance of choosing any bag of the 3 bags (because random). *(If 1 bag were on a really high shelf, then maybe the probabilities would be different, i.e. not random, but let's assume they're random this time.)*


``` r
# there are 3 bags
n_bags <- 3

# So....
# In this case, P(Bag1) = P(Bag2) = P(Bag3)
# and P(Bag1) + P(Bag2) + P(Bag3) = 100% = 1.0

# 1/3 chance of picking Bag 1
# written P(Bag1)
pbag1 <- 1 / n_bags

# 1/3 chance of picking Bag 2
# written P(Bag2) 
pbag2 <- 1 / n_bags

# 1/3 chance of picking Bag 3
# written P(Bag3)
pbag3 <- 1 / n_bags

# Check it!
c(pbag1, pbag2, pbag3)
```

```
## [1] 0.3333333 0.3333333 0.3333333
```
2. There are 3 marbles in each bag.


``` r
# Total marbles in Bag 1
m_bag1 <- 3
# Total marbles in Bag 2
m_bag2 <- 3
# Total marbles in Bag 3
m_bag3 <- 3
```

3. There are `3` red marbles in bag 1, `1` red marbles in bag 2, and `2` red marbles in bag 3.


``` r
# So, we can calculate the percentages in each bag.

# percentage of red marbles in Bag 1
# written P(Red|Bag1)
pm_bag1 <- 3 / m_bag1

# percentage of red marbles in Bag 2
# written P(Red|Bag2)
pm_bag2 <- 1 / m_bag2

# percentage of red marbles in Bag 3
# written P(Red|Bag3)
pm_bag3 <- 2 / m_bag3

# Check it!
c(pm_bag1, pm_bag2, pm_bag3)
```

```
## [1] 1.0000000 0.3333333 0.6666667
```
4. Selecting Bag 1 and then selecting a Red Marble are *interdependent* events, so we multiply them.


``` r
# For example
# P(Bag1 & Red) = P(Red|Bag1) * P(Bag1)
pm_bag1 * pbag1
```

```
## [1] 0.3333333
```

5. But each pathway (eg. Bag 1 x Marble A) is distinct and *independent* of the other pathways, so we can add them together.


``` r
# P(Bag1 & Red) = P(Red|Bag1) * P(Bag1)
pm_bag1 * pbag1 + 
  # P(Bag2 & Red) = P(Red|Bag2) * P(Bag2)
  pm_bag2 * pbag2 + 
  # P(Bag3 & Red) = P(Red|Bag3) * P(Bag3)
  pm_bag3 * pbag3
```

```
## [1] 0.6666667
```
And that gives us the same answer: `0.67` or `2/3`.

However, that required making a lot of `objects` in `R`. Can we do this more succinctly using `vectors` and `data.frames`?

We could compute a bag-wise `data.frame`, where each row represents a choice (bag) from `event1`.


``` r
bags <- data.frame(
  bag_id = 1:3,
  # For each bag, how many do you get to choose?
  bags = c(1, 1, 1),
  # For each bag, how many marbles do you get to choose?
  marbles = c(3, 3, 3),
  # For each bag, how many marbles are red?
  red = c(3, 1, 2)) %>%
  # Then, we can calculate the probability of...
  mutate(
    # choosing that bag out of all bags
    prob_bag = bags / sum(bags),
    # choosing red out of all marbles in that bag
    prob_red = red / marbles,
    # choosing BOTH that bag AND a red marble in that bag
    prob_bagred = prob_red * prob_bag)
```

Finally, we could just sum the joint probabilities all together.


``` r
bags %>%
  summarize(prob_bagred = sum(prob_bagred))
```

```
##   prob_bagred
## 1   0.6666667
```

Much faster!


``` r
# Let's remove this now unnecessary data
remove(bags, n_bags, 
       m_bag1, m_bag2, m_bag3, 
       pbag1, pbag2, pbag3,
       pm_bag1, pm_bag2, pm_bag3)
```




<br>
<br>


## Bayes Rule

A cool trick, called Bayes' Rule, reveals that we can figure out a probability of interest that *depends* on other probabilities.

Let's say, we want to know, what's the probability of `OUTCOME` given `CONDITION`.

Bayes' Rule states that the probability of the `OUTCOME` occurring given `CONDITION` is equal to the *joint* probability of the Outcome and Condition both occurring, divided by the probability of the condition occurring.

$$ P(Outcome = 1| Condition = 1) = \frac{ P(Outcome = 1\ \& \  Condition = 1) }{ P(Condition = 1)} $$

Thanks to Conditional Probability and Total Probability tricks, we can break that down into quantities we can calculate.

$$ P(Outcome=1 | Condition=0) = \frac{ P(Condition=1|Outcome=1) \times P(Outcome=1) }{ \sum{ P(Condition | Outcome) } \times P(Outcome)} $$

$$ = \frac{ P(Condition=1|Outcome=1) \times P(Outcome=1) }{ P(Condition=1|Outcome=1) \times P(Outcome=1) + P(Condition=1|Outcome=0) \times P(Outcome=0)} $$

Let's define some terms:

- `posterior`: Posterior probability is the probability that the outcome occurs given that the condition occurs.

- `prior`: the probability that the outcome occurs, independent of anything else.

- `likelihood`: the probability that the condition occurs, given that the outcome occurs.

- `evidence`: the total probability that the condition does or does not occur.


<br>
<br>

### Example: Coffee Shop (Incomplete Information) 

<div class="figure">
<img src="https://pictures.dealer.com/m/maguirechryslerllccllc/0765/537937cbf2dd83f8e3bc89996035c3acx.jpg" alt="Yay Coffee!" width="100%" />
<p class="caption">(\#fig:img_coffee)Yay Coffee!</p>
</div>

A local coffee chain needs your help to analyze their supply chain issues. They know that their scones help them sell coffee, but does their coffee help them sell scones?

- Over the last week, when 7 customers bought scones, 3 went on to buy coffee.

- When 3 customers didn't buy scones, just 2 bought coffee.

- In general, 7 out of 10 of customers ever bought scones.

- What's the probability that a customer will buy a scone, given that they just bought coffee?


``` r
# We want to know this
p_scone_coffee <- NULL

# But we know this!
p_coffee_scone <- 3/7
p_coffee_no_scone <- 2/3
p_scone <- 7/10
# AND
# If 7 out of 10 customers ever bought scones,
# then 3 out of 10 NEVER bought scones
p_no_scone <- 3 / 10
```

Using these 3~4 probabilities, we can deduce the *total* probability of coffee (the denominator), meaning whether you got coffee OR whether you didn't get coffee.


``` r
# Total Prob of Coffee = Getting Cofee + Not getting coffee
p_coffee <- p_coffee_scone * p_scone + p_coffee_no_scone * p_no_scone
# Check it!
p_coffee
```

```
## [1] 0.5
```
So let's use `p_coffee` to get the probability of getting a scone given that you got coffee!


``` r
p_scone_coffee <- p_coffee_scone * p_scone / p_coffee
```

It's magic! Bayes' Rule is helpful when we *don't* have complete information, and just have some raw percentages or probabilities. 

<br>
<br>

### Example: Coffee Shop (Complete Information)

But, if we *do* have complete information, then we can actually *prove* Bayes' Rule quite quickly.

For example, say those percentages the shop owner gave us were actually meticulously tabulated by a barista. We talk to the barista, and she explains that she can tell us right away the proportion of folks who got a scone given that they got coffee. She shows us her spreadsheet of `orders`, listing for each customer, whether they got `coffee` and whether they got a `scone`.


``` r
orders <- tibble(
  coffee = c("yes", "no", "yes", "no", "yes", "yes", "yes", "no", "no", "no"),
  scone = c("no", "no", "no", "yes", "yes", "yes", "yes", "yes", "yes", "yes"))
```

We can tabulate these quickly using `table()`, tallying up how many folks did this.


``` r
orders %>% table()
```

```
##       scone
## coffee no yes
##    no   1   4
##    yes  2   3
```


``` r
# Let's skip to the end and just calculate the proportion directly!
# Out of all people who got coffee, how many got scones?
orders %>% 
  summarize(p_scone_coffee = sum(scone == "yes" & coffee == "yes") / sum(coffee == "yes") )
```

```
## # A tibble: 1 × 1
##   p_scone_coffee
##            <dbl>
## 1            0.6
```

``` r
# The end!
```


``` r
# Now that we know this, let's prove that Bayes works.
orders %>% 
  summarize(
    # The goal (posterior)
    p_scone_coffee = sum(scone == "yes" & coffee == "yes") / sum(coffee == "yes"),
    # The data
    p_coffee_scone = sum(coffee == "yes" & scone == "yes") / sum(scone == "yes"),
    p_coffee_no_scone = sum(coffee == "yes" & scone == "no") / sum(scone == "no"),
    p_scone = sum(scone == "yes") / sum(coffee == "yes" | coffee == "no"),
    p_no_scone = sum(scone == "no") / sum(coffee == "yes" | coffee == "no"),
    # Now recalculate the goal, using the data we have collected.
    # Does 'bayes' equal 'p_scone_coffee'?
    bayes = p_coffee_scone * p_scone / (p_coffee_scone * p_scone + p_coffee_no_scone * p_no_scone))
```

```
## # A tibble: 1 × 6
##   p_scone_coffee p_coffee_scone p_coffee_no_scone p_scone p_no_scone bayes
##            <dbl>          <dbl>             <dbl>   <dbl>      <dbl> <dbl>
## 1            0.6          0.429             0.667     0.7        0.3   0.6
```

``` r
# It should! And it does! Tada!
```


### Example: Movie Theatre Popularity

You are the manager of a movie theatre, and you want to determine the popularity of different genres of movies among your customers. 

You have collected data on the genres of movies that customers choose to watch 

- Probability of a customer choosing an Action movie, P(Action) = `0.25`.
- Similarly, P(Comedy) = `0.30`.
- P(Drama) = `0.20`.
- P(Sci-Fi) = `0.15`.
- P(Horror) = `0.10`.

You also have information about the overall popularity of each genre in the market:

- Out of the customers who chose an Action movie, 60% also bought tickets for Comedy.
- Out of the customers who chose a Comedy movie, 40% also bought tickets for Drama.
- Out of the customers who chose a Drama movie, 25% also bought tickets for Sci-Fi.
- Out of the customers who chose a Science Fiction movie, 70% also bought tickets for Action.
- Out of the customers who chose a Horror movie, 20% also bought tickets for Drama.

You want to calculate the probability that a customer chooses a Drama movie given that they have already purchased a ticket.


``` r
# We define the prior probabilities of customers choosing each genre based on the given problem statement.
P_action <- 0.25
P_comedy <- 0.30
P_drama <- 0.20
P_scifi <- 0.15
P_horror <- 0.10
# We define conditional probabilities that represent the likelihood of crossover purchases. 
# For example, the probability of choosing Action given that the customer chose Comedy is 60%.
conP_action_given_drama <- 0.00
conP_comedy_given_drama <- 0.25
conP_drama_given_drama <- 0.00
conP_scifi_given_drama <- 0.00
conP_horror_given_drama <- 0.20
# Specify the target genre
# Our target genre is Drama and we want to calculate the probability that a customer chooses a Drama movie given that they have already purchased a ticket.
target_genre <- "Drama"  # We can change this to our desired target genre
```


To calculate the probability that a customer chooses the target genre given a ticket purchase, let's use Bayes Rule!


``` r
# We will be using Bayes' rule: P(Target Genre | Ticket Purchase) = P(Ticket Purchase | Target Genre) * P(Target Genre) / P(Ticket Purchase)
# We calculate P(Ticket Purchase | Target Genre) * P(Target Genre) as probability_given_purchase
# If target_genre is "Comedy," the switch function will select the conditional probability for choosing Comedy given a ticket purchase 
probability_given_purchase <- switch(
  target_genre,
  "Action" = conP_action_given_drama * P_action,
  "Comedy" = conP_comedy_given_drama * P_comedy,
  "Drama" = conP_drama_given_drama * P_drama,
  "SciFi" = conP_scifi_given_drama * P_scifi,
  "Horror" = conP_horror_given_drama * P_horror
)
# View it!
probability_given_purchase
```

```
## [1] 0
```
Next...


``` r
# We will further calculate the total probability of a ticket purchase P(Ticket Purchase) as total_probability_purchase:
total_probability_purchase <- sum(
  conP_action_given_drama * P_action,
  conP_comedy_given_drama * P_comedy,
  conP_drama_given_drama * P_drama,
  conP_scifi_given_drama * P_scifi,
  conP_horror_given_drama * P_horror
)
# View it!
total_probability_purchase
```

```
## [1] 0.095
```

We want to calculate the probability that a customer chooses a Drama movie given that they have already purchased a ticket, thus target genre is Drama.


``` r
# P(Target Genre | Ticket Purchase) <- P(Ticket Purchase | Target Genre) * P(Target Genre) / P(Ticket Purchase)
probability_target_genre_given_purchase <- probability_given_purchase / total_probability_purchase
# Let's print that using paste!
paste(
  "Probability that a customer chooses a", 
    target_genre, 
  "movie given a ticket purchase:", 
  probability_target_genre_given_purchase)
```

```
## [1] "Probability that a customer chooses a Drama movie given a ticket purchase: 0"
```

## Conclusion {-}

All done! Nice work!


