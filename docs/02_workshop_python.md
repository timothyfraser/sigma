# Distributions and Descriptive Statistics in Python



This tutorial introduces distributions and descriptive statistics in Python using pandas and helper functions that mirror `R`'s syntax.

## Getting Started {-}

### Install and Import Packages {-}


```python
%pip install pandas plotnine scipy
```


```python
import os, sys
import pandas as p
from plotnine import *
sys.path.append(os.path.abspath('functions'))
from functions_distributions import *
```

## Our Data


```python
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


```python
len(sw)
```

```
## 10
```

## Location

### Mean and Median


```python
sw.mean()
```

```
## np.float64(5.35)
```


```python
sw.median()
```

```
## np.float64(5.25)
```

### Mode


```python
sw.mode()
```

```
## 0    5.0
## dtype: float64
```

## Spread (1)

### Percentiles


```python
sw.quantile(q=0)  # min
```

```
## np.float64(4.0)
```

```python
sw.quantile(q=1)  # max
```

```
## np.float64(6.5)
```

```python
sw.quantile(q=.75)
```

```
## np.float64(5.875)
```

## Spread (2)

### Standard Deviation, Variance, CV, SE


```python
# Manual SD (sample)
x = ((sw - sw.mean())**2).sum()
x = x / (len(sw) - 1)
x**0.5
```

```
## np.float64(0.8181958472422385)
```


```python
sw.std()
```

```
## np.float64(0.8181958472422385)
```

```python
sw.var()
```

```
## np.float64(0.6694444444444445)
```

```python
sw.std()**2
```

```
## np.float64(0.6694444444444444)
```

```python
sw.std() / sw.mean()  # CV
```

```
## np.float64(0.15293380322284833)
```


```python
se = sw.std() / (len(sw)**0.5)
se
```

```
## np.float64(0.25873624493766706)
```

## Shape

### Skewness and Kurtosis


```python
diff = sw - sw.mean()
n = len(sw) - 1
sigma = sw.std()
sum(diff**3) / (n * sigma**3)
```

```
## np.float64(0.024342597820882206)
```

```python
sum(diff**4) / (n * sigma**4)
```

```
## np.float64(1.8758509667533272)
```


```python
# Using helper functions mirroring R
skewness(sw)
```

```
## np.float64(0.024342597820882206)
```

```python
kurtosis(sw)
```

```
## np.float64(1.8758509667533272)
```

## Finding Parameters for Your Distributions


```python
sw = p.Series([4.5, 5, 5.5, 5, 5.5, 6.5, 6.5, 6, 5, 4])
mymean = sw.mean()
mysd = sw.std()
```

## Common Distributions

### Normal


```python
mynorm = rnorm(n=1000, mean=mymean, sd=mysd)
hist(mynorm)
```

```
## <plotnine.ggplot.ggplot object at 0x000001CAEBA9B3B0>
```

### Poisson


```python
mypois = rpois(n=1000, mu=mymean)
hist(mypois)
```

```
## <plotnine.ggplot.ggplot object at 0x000001CAFF825C10>
```

### Exponential


```python
myrate_e = 1 / sw.mean()
myexp = rexp(n=1000, rate=myrate_e)
hist(myexp)
```

```
## <plotnine.ggplot.ggplot object at 0x000001CAFF5D7E00>
```

### Gamma


```python
myshape = sw.mean()**2 / sw.var()
myrate = 1 / (sw.var() / sw.mean())
mygamma = rgamma(n=1000, shape=myshape, rate=myrate)
hist(mygamma)
```

```
## <plotnine.ggplot.ggplot object at 0x000001CAFF826CC0>
```

### Weibull


```python
from scipy import stats as fitdistr
myshape_w, loc, myscale_w = fitdistr.weibull_min.fit(sw, floc=0)
myweibull = rweibull(n=1000, shape=myshape_w, scale=myscale_w)
hist(myweibull)
```

```
## <plotnine.ggplot.ggplot object at 0x000001CAFF4CD640>
```

## Comparing Distributions


```python
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
g1
```

```
## <plotnine.ggplot.ggplot object at 0x000001CAFF5D7CE0>
```


```python
g1 + xlim(0,10)
```

```
## <plotnine.ggplot.ggplot object at 0x000001CAFF825970>
```

---

## Learning Check 1 {.unnumbered .LC}

**Question**

Simulate 1000 draws from a normal distribution using your `sw` mean and standard deviation. What are the simulated mean and sd? How close are they to `sw`’s?

<details><summary>**[View Answer!]**</summary>


```python
mymean = sw.mean(); mysd = sw.std()
m = rnorm(1000, mean=mymean, sd=mysd)
[m.mean(), m.std()]
```

```
## [np.float64(5.348166130314063), np.float64(0.8011466977915525)]
```

</details>

---

## Conclusion {.unnumbered}

You computed size, location, spread, and shape statistics and compared common simulated distributions using helper functions that mirror R.



