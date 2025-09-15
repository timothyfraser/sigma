# System Reliability in Python



In this tutorial, we learn core Reliability/Survival Analysis concepts in Python by mirroring the R workflow.


## Getting Started {-}

### Packages {-}


```python
# Remember to install these packages using a terminal, if you haven't already!
!pip install pandas plotnine sympy scipy
```


```python
import pandas as pd
from plotnine import *
import sympy as sp
```

### Custom Functions {-}

This workshop uses custom reliability functions from the `functions_distributions.py` module. To use these functions, you need to download them from the repository:

**Option 1: Clone the entire repository**
```bash
git clone https://github.com/timothyfraser/sigma.git
cd sigma
```

**Option 2: Download just the functions file**
```bash
# Download the functions file directly
curl -O https://raw.githubusercontent.com/timothyfraser/sigma/main/functions/functions_distributions.py
```

**Option 3: Add the functions directory to your Python path**

```python
import sys
import os
# Add the functions directory to Python path
sys.path.append('functions')  # or path to wherever you placed the functions folder
```

Once you have the functions available, you can import them:


```python
from functions_distributions import rnorm, density, tidy_density, approxfun
```

## Concepts

In Reliability/Survival Analysis, our quantity of interest is the amount of time it takes to reach a particular outcome (eg. time to failure, time to death, time to market saturation, etc.) Let's learn how to approximate them in Python!

<br>
<br>

### Life Distributions

All technologies, operations, etc. have a 'lifetime distribution'. If you took a sample of, say, cars in New York, you could measure *how long each car functioned properly* (its life-span), and build a *Lifetime Distribution* from that vector.


```python
# Add functions directory to path if not already there
import sys
if 'functions' not in sys.path:
    sys.path.append('functions')

from functions_distributions import rnorm, density, tidy_density, approxfun

# Let's imagine a normally distributed lifespan for these cars...
lifespan = rnorm(100, mean=5, sd=1)
```

The *lifetime distribution* is the probability density function telling us how *frequently* each potential lifespan is expected to occur.


```python
# We can build ourself the PDF of our lifetime distribution here
dlife = density(lifespan)
dlife = tidy_density(dlife)
dlife_fn = approxfun(dlife)
```

In contrast, the Cumulative Distribution Function (CDF) for a lifetime distribution tells us, for any time $t$, the *probability that a car will fail by time* $t$.


```python
# And we can build the CDF here
plife_df = tidy_density(density(lifespan))
plife_df = plife_df.sort_values('x')
plife_df['y'] = plife_df.y.cumsum() / plife_df.y.sum()
plife = approxfun(plife_df)
```

Having built these functions for our cars, we can generate the probability (PDF) and cumulative probability (CDF) of failure across our observed vector of car lifespans.

Reliability or Survival Analysis is concerned with *the probability* that a unit (our car) will still be operating by a specific time $t$, representing the percentage of all cars that will survive to that point in time. So let's also calculate `1 - cumulative probability of failure`.


```python
import numpy as np
time = np.arange(lifespan.min(), lifespan.max(), 0.1)
mycars = pd.DataFrame({
  'time': time,
  'prob': dlife_fn(time),
  'prob_cumulative': plife(time)
})
mycars['prob_survival'] = 1 - mycars['prob_cumulative']
```

Let's plot our three curves!


```python
(ggplot(mycars, aes(x='time')) +
  geom_area(aes(y='prob_cumulative', fill='"Cumulative Probability"'), alpha=0.5) +
  geom_area(aes(y='prob_survival', fill='"Reliability (Survival)"'), alpha=0.5) +
  geom_area(aes(y='prob', fill='"Probability"'), alpha=0.5) +
  theme_classic() + theme(legend_position='bottom') +
  labs(x='Lifespan of Car', y='Probability', subtitle='Example Life Distributions'))
```

```
## <plotnine.ggplot.ggplot object at 0x0000027F6C515280>
```

This new reliability function allows us to calculate 2 quantities of interest:

-   expected (average) number of cars that fail up to time $t$.
-   total cars expected to still operate after time $t$.

<br> <br>

### Example: Airplane Propeller Failure!

Suppose Lockheed Martin purchases 800 new airplane propellers. When asked about the failure rate, the seller reports that every 1500 days, 2 of these propellers are expected to break. Using this, we can calculate $m$, the mean time to fail!

$$ \lambda \ t = t_{days} \times \frac{2 \ units}{1500 \ days}   \ \ \  and \ \ \ m = \frac{1500}{2} = 750 \ days $$

This lets us generate the *failure rate* $F(t)$, also known as the Cumulative Distribution Function, and we can write it up like this.

$$ CDF(t) = F(t) = 1 - e^{-(2t/1500)} = 1 - e^{-t/750} $$

What's pretty cool is, we can tell Python to make a matching function `fplane()`, using the `def` command.


```python
import math
# For any value `t` we supply, do the following to that `t` value.
def fplane(t):
  return 1 - math.exp(-(t/750))
```

Let's use our function `fplane()` to answer our Lockheed engineers' questions.

<br>

1.  What's the probability a propeller will fail by `t = 600` days? By `t = 5000` days?


```python
print("fplane(600):", fplane(600))
```

```
## fplane(600): 0.5506710358827784
```

```python
print("fplane(5000):", fplane(5000))
```

```
## fplane(5000): 0.9987273661986602
```

Looks like 55% will fail by `600` days, and 99% fail by `5000` days.

<br>

2.  What's the probability a propeller will fail between `600` and `5000` days?


```python
print("Probability of failure between 600 and 5000 days:", fplane(5000) - fplane(600))
```

```
## Probability of failure between 600 and 5000 days: 0.44805633031588177
```

~45% more will fail between this period.

<br>

3.  What percentage of new propellers will work more than `6000` days?


```python
print("Percentage surviving past 6000 days:", 1 - fplane(6000))
```

```
## Percentage surviving past 6000 days: 0.00033546262790251635
```

0.03% will *survive* past 6000 days.

<br>

4.  If Lockheed uses 300 propellers, how many will fail in 1 year? In 3 years?


```python
# Given a sample of 300 propellers,
n = 300
# We project n * fplane(t = 365.25) will fail in 1 year (365.25 days)
# that's ~115 propellers.
print("Failures in 1 year:", n * fplane(365.25))
```

```
## Failures in 1 year: 115.65989011661077
```

```python
# We also project that n * fplane(t = 3 * 365.25) will fail in 3 years
# that's ~230 propellers!
print("Failures in 3 years:", n * fplane(3*365.25))
```

```
## Failures in 3 years: 230.398753639659
```

Pretty powerful!

<br>
<br>
<br>

### Joint Probabilities

Two extra rules of probability can help us understand system reliability.

#### Multiplication Rule

-   probability that $n$ units with a reliability function $R(t)$ survive past time $t$ is *multiplied*, because of conditional probability, to equal $R(t)^{n}$.

For example, there's a 50% chance that 1 coffee cup breaks at local coffeeshop *Coffee Please!* every 6 months (180 days). Thus, the mean number of days to cup failure is $m = \frac{180 \ days}{ 1 \ cup \times 0.50 \ chance} = 360 \ days$, while the relative frequency (probability) that a cup will break is $\lambda = \frac{1 \ cup}{360 \ days}$.


```python
def fcup(days):
  return 1 - math.exp(-(days/360))

# So the probability that 1 breaks within 100 days is XX percent
print("Probability 1 cup breaks in 100 days:", fcup(100))
```

```
## Probability 1 cup breaks in 100 days: 0.24253487160303355
```

And let's write out a reliability function too, based on our function for the failure function.


```python
# Notice how we can reference an earlier function fcup in our later function? Always have to define functions in order.
def rcup(days):
  return 1 - fcup(days)

# So the probability that 1 *doesn't* break within 100 days is XX percent
print("Probability 1 cup survives 100 days:", rcup(100))
```

```
## Probability 1 cup survives 100 days: 0.7574651283969664
```

But the probability that *two* break within 100 days is...


```python
print("Probability 2 cups break in 100 days:", fcup(100) * fcup(100))
```

```
## Probability 2 cups break in 100 days: 0.05882316394349997
```

And the probability that 5 break within 100 days is... very small!


```python
print("Probability 5 cups break in 100 days:", fcup(100)**5)
```

```
## Probability 5 cups break in 100 days: 0.0008392105809454709
```

#### Compliment Rule

-   The probability that at least 1 of $n$ units fails by time $t$ is $1 - R(t)^{n}$.

So, if *Coffee Please!* buys 2 new cups for their store, the probability that at least 1 unit breaks within a year is...


```python
print("Probability at least 1 of 2 cups breaks in a year:", 1 - rcup(365.25)**2)
```

```
## Probability at least 1 of 2 cups breaks in a year: 0.8685549869686017
```

While if they buy 5 new cups for their store, the chance at least 1 cup breaks within a year is...


```python
print("Probability at least 1 of 5 cups breaks in a year:", 1 - rcup(365.25)**5)
```

```
## Probability at least 1 of 5 cups breaks in a year: 0.9937358768884709
```

## Hazard Rate Function

But if a unit has survived up until now, shouldn't its odds of failing change? We can express this as:

$$ P(Fail \ Tomorrow | Survive \ until \ Today) = \frac{ F(days + \Delta days) - F(days) }{ \Delta days \times R(days)} = \frac{ F(days + 1 ) - F(days) }{ 1 \times R(days)} $$

Local coffeeshop *Coffee Please!* also has a lucky mug, which has stayed intact for 5 years, despite being dropped numerous times by patrons. *Coffee Please!*'s failure rate suggests they had a 99.3% chance of it breaking to date.


```python
# we call this the Hazard Rate Z
def zcup(days, plus=1):
  return (fcup(days + plus) - fcup(days)) / (plus * rcup(days))
```

## Accumulative Hazard Function

-   $H(t)$: total accumulated risk of experiencing the event of interest that has been gained by progressing from 0 to time $t$.
-   the (instantaneous) hazard rate $h(t)$ can grow or shrink over time, but the cumulative hazard rate only increases or stays constant.


```python
def hcup(days):
  return -1*math.log(rcup(days))

# This captures the accumulative probability of a hazard (failure) occurring given the number of days past.
print("Accumulative hazard at 100 days:", hcup(100))
```

```
## Accumulative hazard at 100 days: 0.27777777777777773
```

## Average Failure Rate

The hazard rate $z(t)$ varies over time, so let's generate a single statistic to summarize the distribution of hazard rates that $z(t)$ can provide us between times $t_{a} \to t_{z}$. We'll call this the Average Failure Rate $AFR(T)$.


```python
def afrcup(t1, t2):
  return (hcup(t2) - hcup(t1)) / (t2 - t1)

print("Average failure rate from 0 to 5 days:", afrcup(0, 5))
```

```
## Average failure rate from 0 to 5 days: 0.00277777777777777
```

When the probability for a time $t$ is less than `0.10`, $AFR = F(t) / T$. This means that $F(t) = 1 - e^{-T \times AFR(T)} \approx T \times AFR(T) \ \ when \  F(T) < 0.10$.


```python
def afrcup_approx(days):
  return fcup(days) / days

print("Approximate AFR at 5 days:", afrcup_approx(5))
```

```
## Approximate AFR at 5 days: 0.0027585766512167485
```

## Units and Conversions

Units can be tough with failure rates, because they get tiny really quickly. Here are some common units:

-   *Percent per thousand hours*, where $\% / K = 10^5 \times z(t)$
-   *Failure in Time (FIT) per thousand hours*, also known as *Parts per Million per Thousand Hours*, written $PPM/K = 10^9 \times z(t)$. This equals $10^4 \times Failure \ Rate \ in \ \% / K$.

For this lifetime function $F(t) = 1 - e^{-(t/2000)^{0.5}}$, what's the failure rate at `t = 10`, `t = 1000`, and `t = 10,000` hours? Convert them into $\%/K$ and $PPM/K$.

### Failure Functions

First, let's write the failure function `f(t)`.


```python
# Write failure rate
def f(t):
  return 1 - math.exp(-(t/2000)**0.5)
```

Second, let's write the hazard rate `z(t)`, for a 1 unit change in `t`.


```python
# Write hazard rate
def z(t, change=1):
  # Often I like to break up my functions into multiple lines;
  # it makes it much clearer to me.
  # To help, we can make 'temporary' objects; 
  # they only exist within the function.
  
  # Get change in failure function
  deltaf = (f(t+change) - f(t)) / change
  # Get reliability function
  r = 1 - f(t)
  # Get hazard rate
  return deltaf / r
```

Third, let's write the average hazard rate `afr(t1,t2)`.


```python
def afr(t1, t2):
  # Let's get the survival rate r(t)
  r1 = 1 - f(t1)
  r2 = 1 - f(t2)
  
  # Let's get the accumulative hazard rate h(t)
  h1 = -math.log(r1)
  h2 = -math.log(r2)
  
  # And let's calculate the average failure rate!
  return (h2 - h1) / (t2 - t1)
```

### Conversion Functions

Fourth, let's write some functions to convert our results into %/K and PPM/K, so we can be lazy! We'll call our functions `pk()` and `ppmk()`.


```python
# % per 1000 hours
def pk(rate):
  return rate * 100 * 10**3

# PPM/1000 hours
def ppmk(rate):
  return rate * 10**9
```

### Converting Estimates

Let's compare our hazard rates when `t = 10`, per hour, in % per 1000 hours, and in PPM per 1000 hours.


```python
# Per hour... Ew. Not very readable.
print("Hazard rate per hour at t=10:", z(10))
```

```
## Hazard rate per hour at t=10: 0.0034453578389621797
```

```python
# % per 1000 hours.... Wheee! Much more legible
print("Hazard rate %/K at t=10:", pk(z(10)))
```

```
## Hazard rate %/K at t=10: 344.535783896218
```

```python
# PPM per 1000 hours.... Whoa! Big numbers!
print("Hazard rate PPM/K at t=10:", ppmk(z(10)))
```

```
## Hazard rate PPM/K at t=10: 3445357.8389621796
```

Finally, let's calculate the Average Failure Rate between 1000 and 10000 hours, in %/K.


```python
# Tada! Average Failure Rate from 1000 to 10000 hours, in % of units per 1000 hours
print("AFR %/K from 1000 to 10000 hours:", pk(afr(1000, 10000)))
```

```
## AFR %/K from 1000 to 10000 hours: 16.9884577368138
```

```python
# And in ppmk!
print("AFR PPM/K from 1000 to 10000 hours:", ppmk(afr(1000, 10000)))
```

```
## AFR PPM/K from 1000 to 10000 hours: 169884.577368138
```

<br> <br> <br>

---

## Learning Check 1 {.unnumbered .LC}

**Question**

### 📱💥Exploding Phones!

Hypothetical: Samsung is releasing a new Galaxy phone. But after the [2016 debacle of exploding phones](https://www.businessinsider.com/samsung-infographic-explains-why-galaxy-note-7-phones-exploded-2017-1), they want to estimate how likely it is a phone will explode (versus stay intact). Their pre-sale trials suggest that every 500 days, 5 phones are expected to explode. What percentage of phones are expected to work after more than 6 months? 1 year?

<details><summary>**[View Answer!]**</summary>
  
Using the information above, we can calculate the mean time to fail `m`, the rate of how many days it takes for an average unit to fail.


```python
days = 500
units = 5
m = days / units
# Check it!
print("Mean time to fail (days):", m)
```

```
## Mean time to fail (days): 100.0
```

We can use `m` to make our explosion function `fexplode()`, which in this case, is our (catastrophic) failure function $f(t)$!

$$ CDF(days) = Explode(days) = 1 - e^{-(days \times \frac{1 \ unit}{100 \ days})} = 1 - e^{-0.01 \times days} $$


```python
import math
def fexplode(days):
  return 1 - math.exp(-0.01*days)
```

Then, we can calculate $r(t)$, the cumulative probability that a phone will *not* explode after $t$ days.

Let's answer our questions!

What percentage of phones are expected to survive 6 months?


```python
# What percent
print("6 months survival:", 1 - fexplode(365.25 / 2))
```

```
## 6 months survival: 0.16101624797343572
```

What percentage of phones are expected to survive 1 year?


```python
print("1 year survival:", 1 - fexplode(365.25))
```

```
## 1 year survival: 0.02592623211144296
```

</details>

## Units and Conversions


```python
def pk(rate):
  return rate * 100 * 10**3

def ppmk(rate):
  return rate * 10**9
```


```python
def f(t):
  return 1 - math.exp(-((t/2000)**0.5))

def z(t, change=1):
  deltaf = (f(t+change) - f(t)) / change
  r = 1 - f(t)
  return deltaf / r

def afr(t1, t2):
  r1 = 1 - f(t1)
  r2 = 1 - f(t2)
  h1 = -math.log(r1)
  h2 = -math.log(r2)
  return (h2 - h1) / (t2 - t1)
```


```python
# Hazard rate at t=10
z(10)
```

```
## 0.0034453578389621797
```


```python
# Hazard rate per 1000 hours
pk(z(10))
```

```
## 344.535783896218
```


```python
# PPM per 1000 hours
ppmk(z(10))
```

```
## 3445357.8389621796
```


```python
# Average failure rate from 1000 to 10000 hours
afr(1000, 10000)
```

```
## 0.000169884577368138
```


```python
# Average failure rate in % per 1000 hours
pk(afr(1000, 10000))
```

```
## 16.9884577368138
```


```python
# Average failure rate in PPM per 1000 hours
ppmk(afr(1000, 10000))
```

```
## 169884.577368138
```


---

## Learning Check 2 {.unnumbered .LC}

**Question**

### 🍜 Does Instant Ramen *ever* go bad?

A food safety inspector is investigating the average shelf life of instant ramen noodles. A company estimates the average shelf life of a package of ramen noodles at ~240 days per package. In a moment of poor judgement, she hires a team of hungry college students to taste-test old packages of that company's ramen noodles, randomly sampled from a warehouse. When a student comes down with food poisoning, she records that product as having gone bad after XX days. She treats the record of ramen food poisonings as a sample of the lifespan of ramen products.


```python
ramen = [163, 309, 215, 211, 246, 198, 281, 180, 317, 291, 
         238, 281, 215, 208, 212, 300, 231, 240, 285, 232, 
         252, 261, 310, 226, 282, 140, 208, 280, 237, 270, 
         185, 409, 293, 164, 231, 237, 269, 233, 246, 287, 
         187, 232, 180, 227, 215, 260, 236, 229, 263, 220]
```

Using this data, please calculate...

1.  What's the cumulative probability of a pack of ramen going bad within 8 months (240 days)? Are the company's predictions accurate?

2.  What's the average failure rate ($\lambda$) for the period between 8 months (240 days) to 1 year?

3.  What's the mean time to fail ($m$) for the period between 8 months to 1 year?

<br>

<details><summary>**[View Answer!]**</summary>

First, we take her ramen lifespan data, estimate the PDF with `density()`, and make the failure function (CDF), which I've called `framen()` below.


```python
import numpy as np
import pandas as pd
from scipy.stats import gaussian_kde

# Get failure function f(t) = CDF of ramen failure
# Create a density estimate
kde = gaussian_kde(ramen)
x_range = np.linspace(min(ramen), max(ramen), 1000)
density_values = kde(x_range)

# Create CDF by integrating the density
cdf_values = np.cumsum(density_values) / np.sum(density_values)

# Create interpolation function for CDF
from scipy.interpolate import interp1d
framen = interp1d(x_range, cdf_values, kind='linear', bounds_error=False, fill_value=(0, 1))
```

Second, we calculate the reliability function `rramen()`.


```python
# Get survival function r(t) = 1 - f(t)
def rramen(days):
  return 1 - framen(days)
```

Third, we can shortcut to the average failure rate, called `afrramen()` below, by using the reliability function `rramen()` to make our hazard rates at time 1 (`h1`) and time 2 (`h2`).


```python
# Get average failure rate from time 1 to time 2
def afrramen(days1, days2):
  h1 = -1*np.log(rramen(days1))
  h2 = -1*np.log(rramen(days2))
  return (h2 - h1) / (days2 - days1)
```

1.  What's the cumulative probability of a pack of ramen going bad within 8 months (240 days)? Are the company's predictions accurate?


```python
print("Cumulative probability of going bad within 240 days:", framen(240))
```

```
## Cumulative probability of going bad within 240 days: 0.49920812311668555
```

Yes! ~50% of packages will go bad within 8 months. Pretty accurate!

<br>

2.  What's the average failure rate ($\lambda$) for the period between 8 months (240 days) to 1 year?


```python
lambda_val = afrramen(240, 365)
# Check it!
print("Average failure rate (lambda):", lambda_val)
```

```
## Average failure rate (lambda): 0.030972058387967075
```

On average, between 8 months to 1 year, ramen packages go bad at a rate of ~`0.026` units per day.

<br>

3.  What's the mean time to fail ($m$) for the period between 8 months to 1 year?


```python
# Calculate the inverse of lambda!
m = 1 / lambda_val
# check it!
print("Mean time to fail (days):", m)
```

```
## Mean time to fail (days): 32.28716630563079
```

`39` days per package. In other words, during this period post-expiration, this data suggests 1 package will go bad every `39` days.

<br>
  
</details>

---

## System Reliability

Reliability rates become *extremely* useful when we look at an entire *system*! This is where system reliability analysis can really improve the lives of ordinary people, decision-makers, and day-to-day users, because we can give *them* the knowledge they need to make decisions.

*So what knowledge do users usually need?* How likely is the system *as a whole* to survive (or fail) over time?

### Series Systems

In a **series system**, we have a set of $n$ components (sometimes called *nodes* in a network), which get utilized *sequentially*. A domino train, for example, is a series system. It only takes *1 component* to fail to stop the entire system (causing system failure). The overall reliability of a series system is defined as the success of *every individual component* (A *AND* B *AND* C). We write it using the formula below.

$$ Series \ System \ Reliability = R_{S} = \prod^{n}_{i = 1}R_{i} = R_1 \times R_2 \times ... \times R_n $$

### Parallel Systems

In a **parallel system** (a.k.a. *redundant* system), we have a set of $n$ components, but only *1* component needs to function in order for the system to function. The overall reliability of a parallel system is defined as the success of *any individual component* (A *OR* B *OR* [A *AND* B]). A silverware drawer is an simple example of a parallel system. You probably just need 1 spoon for yourself at any time, but you have a stock of several spoons available in case you need them.

We write it using the formula below, where each component $i$ has a reliability rate of $R_{i}$ and a failure rate of $F_{i}$.

$$ Parallel \ System \ Reliability = R_{P} = 1 - \prod^{n}_{i = 1}(1 - R_{i}) = 1 - \prod^{n}_{i = 1}F_{i} = 1 - (F_1 \times F_2 \times ... \times F_n) $$

### Combined Systems

Most systems actually involve combining the probabilities of several subsystems.

When combining configurations, we calculate the probabilities of each subsystem, then then calculate the overall probability of the final system.

For systems in series, multiply component reliabilities. For parallel, use complements.


```python
def r_exp(t, mean_time):
  import math
  return math.exp(-t/mean_time)

def series_reliability(t, means):
  r = 1.0
  for m in means:
    r *= r_exp(t, m)
  return r

def parallel_reliability(t, means):
  import math
  prod_fail = 1.0
  for m in means:
    prod_fail *= (1 - r_exp(t, m))
  return 1 - prod_fail

print("Series reliability:", series_reliability(1000, [750, 900, 1200]))
```

```
## Series reliability: 0.0377119681337726
```

```python
print("Parallel reliability:", parallel_reliability(1000, [750, 900, 1200]))
```

```
## Parallel reliability: 0.720700446343458
```

The key is identifying exactly which system is nested in which system!

## Conclusion {.unnumbered}

You translated reliability concepts to Python: failure, reliability, hazard, cumulative hazard, and AFR with simple functions, plus basic series/parallel reasoning.



