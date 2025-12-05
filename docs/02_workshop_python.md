en di# Distributions and Descriptive Statistics in Python



This tutorial introduces distributions and descriptive statistics in Python using pandas and helper functions that mirror `R`'s syntax.

## Getting Started {-}

### Install and Import Packages {-}


``` python
%pip install pandas plotnine scipy
```


``` python
import os, sys
import pandas as p
from plotnine import *
sys.path.append(os.path.abspath('functions'))
from functions_distributions import *
```

## Our Data


``` python
sw = p.Series([4.5, 5, 5.5, 5, 5.5, 6.5, 6.5, 6, 5, 4])
sw
```

```
## 0    4.5
## 1    5.0
## 2    5.5
## 3    5.0
## 4    5.5
## 5    6.5
## 6    6.5
## 7    6.0
## 8    5.0
## 9    4.0
## dtype: float64
```

## Size

### Length


``` python
len(sw)
```

```
## 10
```

## Location

### Mean and Median


``` python
sw.mean()
```

```
## 5.35
```


``` python
sw.median()
```

```
## 5.25
```

### Mode


``` python
sw.mode()
```

```
## 0    5.0
## dtype: float64
```

## Spread (1)

### Percentiles


``` python
sw.quantile(q=0)  # min
```

```
## 4.0
```

``` python
sw.quantile(q=1)  # max
```

```
## 6.5
```

``` python
sw.quantile(q=.75)
```

```
## 5.875
```

## Spread (2)

### Standard Deviation, Variance, CV, SE


``` python
# Manual SD (sample)
x = ((sw - sw.mean())**2).sum()
x = x / (len(sw) - 1)
x**0.5
```

```
## 0.8181958472422385
```


``` python
sw.std()
```

```
## 0.8181958472422385
```

``` python
sw.var()
```

```
## 0.6694444444444444
```

``` python
sw.std()**2
```

```
## 0.6694444444444444
```

``` python
sw.std() / sw.mean()  # CV
```

```
## 0.15293380322284833
```


``` python
se = sw.std() / (len(sw)**0.5)
se
```

```
## 0.25873624493766706
```

## Shape

### Skewness and Kurtosis


``` python
diff = sw - sw.mean()
n = len(sw) - 1
sigma = sw.std()
sum(diff**3) / (n * sigma**3)
```

```
## 0.024342597820882206
```

``` python
sum(diff**4) / (n * sigma**4)
```

```
## 1.8758509667533272
```


``` python
# Using helper functions mirroring R
skewness(sw)
```

```
## 0.024342597820882206
```

``` python
kurtosis(sw)
```

```
## 1.8758509667533272
```

## Finding Parameters for Your Distributions


``` python
sw = p.Series([4.5, 5, 5.5, 5, 5.5, 6.5, 6.5, 6, 5, 4])
mymean = sw.mean()
mysd = sw.std()
```

## Common Distributions

### Normal


``` python
mynorm = rnorm(n=1000, mean=mymean, sd=mysd)
h1 = hist(mynorm)
h1.save("plotnine_figures/02_hist_normal.png", dpi=100, width=6, height=4)
```

<div class="figure">
<img src="plotnine_figures/02_hist_normal.png" alt="Normal distribution histogram" width="100%" />
<p class="caption">(\#fig:unnamed-chunk-16)Normal distribution histogram</p>
</div>

### Poisson


``` python
mypois = rpois(n=1000, mu=mymean)
h2 = hist(mypois)
h2.save("plotnine_figures/02_hist_poisson.png", dpi=100, width=6, height=4)
```

<div class="figure">
<img src="plotnine_figures/02_hist_poisson.png" alt="Poisson distribution histogram" width="100%" />
<p class="caption">(\#fig:unnamed-chunk-18)Poisson distribution histogram</p>
</div>

### Exponential


``` python
myrate_e = 1 / sw.mean()
myexp = rexp(n=1000, rate=myrate_e)
h3 = hist(myexp)
h3.save("plotnine_figures/02_hist_exponential.png", dpi=100, width=6, height=4)
```

<div class="figure">
<img src="plotnine_figures/02_hist_exponential.png" alt="Exponential distribution histogram" width="100%" />
<p class="caption">(\#fig:unnamed-chunk-20)Exponential distribution histogram</p>
</div>

### Gamma


``` python
myshape = sw.mean()**2 / sw.var()
myrate = 1 / (sw.var() / sw.mean())
mygamma = rgamma(n=1000, shape=myshape, rate=myrate)
h4 = hist(mygamma)
h4.save("plotnine_figures/02_hist_gamma.png", dpi=100, width=6, height=4)
```

<div class="figure">
<img src="plotnine_figures/02_hist_gamma.png" alt="Gamma distribution histogram" width="100%" />
<p class="caption">(\#fig:unnamed-chunk-22)Gamma distribution histogram</p>
</div>

### Weibull


``` python
from scipy import stats as fitdistr
myshape_w, loc, myscale_w = fitdistr.weibull_min.fit(sw, floc=0)
myweibull = rweibull(n=1000, shape=myshape_w, scale=myscale_w)
h5 = hist(myweibull)
h5.save("plotnine_figures/02_hist_weibull.png", dpi=100, width=6, height=4)
```

<div class="figure">
<img src="plotnine_figures/02_hist_weibull.png" alt="Weibull distribution histogram" width="100%" />
<p class="caption">(\#fig:unnamed-chunk-24)Weibull distribution histogram</p>
</div>

## Comparing Distributions


``` python
mysim = p.concat([
  p.DataFrame({'x': sw, 'type': "Observed"}),
  p.DataFrame({'x': mynorm, 'type': "Normal"}),
  p.DataFrame({'x': mypois, 'type': "Poisson"}),
  p.DataFrame({'x': mygamma, 'type': "Gamma"}),
  p.DataFrame({'x': myexp, 'type': "Exponential"}),
  p.DataFrame({'x': myweibull, 'type': "Weibull"})
])

g1 = (ggplot(mysim, aes(x='x', fill='type')) +
  geom_density(alpha=0.5) +
  labs(x='Seawall Height (m)', y='Density (Frequency)', subtitle='Which distribution fits best?', fill='Type'))
g1.save("plotnine_figures/02_density_comparison.png", dpi=100, width=8, height=6)
```

<div class="figure">
<img src="plotnine_figures/02_density_comparison.png" alt="Distribution comparison" width="100%" />
<p class="caption">(\#fig:unnamed-chunk-26)Distribution comparison</p>
</div>


``` python
g2 = g1 + xlim(0,10)
g2.save("plotnine_figures/02_density_comparison_xlim.png", dpi=100, width=8, height=6)
```

<div class="figure">
<img src="plotnine_figures/02_density_comparison_xlim.png" alt="Distribution comparison with x-axis limits" width="100%" />
<p class="caption">(\#fig:unnamed-chunk-28)Distribution comparison with x-axis limits</p>
</div>

---

## Learning Check 1 {.unnumbered .LC}

**Question**

Simulate 1000 draws from a normal distribution using your `sw` mean and standard deviation. What are the simulated mean and sd? How close are they to `sw`’s?

<details><summary>**[View Answer!]**</summary>


``` python
mymean = sw.mean(); mysd = sw.std()
m = rnorm(1000, mean=mymean, sd=mysd)
[m.mean(), m.std()]
```

```
## [5.321696687180736, 0.8217958033483576]
```

</details>

---

## Conclusion {.unnumbered}

You computed size, location, spread, and shape statistics and compared common simulated distributions using helper functions that mirror R.



