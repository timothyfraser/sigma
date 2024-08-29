# 02_workshop.py

# Upgrade pip
# !/opt/python/3.8.17/bin/python3.8 -m pip install --upgrade pip

# Install main python packages for this course
# !pip install scipy # for probabilities
# !pip install statsmodels # for models
# !pip install patsy # for model specification

# !pip install dplython
# !pip install dfply
# !pip install plotnine

# !pip install os
# !pip install sys

import os
import sys


# Load packages
import pandas as p # for data.frames
# Import stats and broom functions
from functions_models import * 
# Import data wrangling and pipelines
from dfply import * 
# Import distribution functions
from scipy.stats import norm


# Append files in this folder (functions) to the Python Path
sys.path.append(os.path.abspath('functions'))
# Now you can reference them directly
from functions_models import *
from distributions import *


# Load the statsmodels package
import statsmodels.api as sm
from functions_models import *
# Load the mtcars dataset
mtcars = sm.datasets.get_rdataset('mtcars', package='datasets').data
# Check it out...
mtcars

# Assuming the script is in a folder named 'my_folder' located one level up
script_dir = os.path.abspath('../my_folder')
sys.path.append(script_dir)

from ..functions import functions_models 

m = sm.formula.ols(formula = "hp ~ cyl", data = mtcars).fit()

m.summary()

new_data = p.DataFrame({'cyl' : [4, 6, 8]})

new_data['yhat'] = m.predict(new_data)
new_data





# mtcars %>% 
#   group_by(cyl) %>%
#   summarize(mean = mean(mpg), sd = sd(mpg))

mtcars.groupby('cyl').agg(
    mean = ('mpg', 'mean'),
    sd=('mpg', 'std')  )


# mtcars %>%
#   group_by(cyl) %>%
#   summarize(sim = rnorm(n = 5, mean = 2, sd = 0.5))

mtcars.groupby('cyl').apply(lambda df: pd.Series({
  'sim' : norm.rvs(size=5, loc=2, scale=0.5)
})).explode('sim')


mtcars.groupby('cyl').apply(lambda df: pd.Series({
  'sim' : rnorm(n = 5, mean = 2, sd = 0.5)
})).explode('sim')


# mtcars %>%
#   group_by(cyl) %>%
#   summarize(sim = rnorm(n = n(), mean = mean(mpg), sd = sd(mpg)))
mtcars.groupby('cyl').apply(
  lambda df: pd.Series({
    'sim': rnorm(n = len(df), mean = df['mpg'].mean(), sd = df['mpg'].std())
  })
).explode('sim')



m = lm(formula = 'mpg ~ cyl', data = mtcars)

tidy(m)


# mtcars %>%
#   group_by(cyl) %>%
#   reframe( lm(formula = mpg ~ hp, data = .) %>% 
#     broom::tidy())

# m.summary2().tables[1]

mtcars.groupby('cyl').apply(
  lambda df:  lm(formula = 'mpg ~ hp', data = df).summary2().tables[1]
)

mtcars.groupby('cyl').apply(
  lambda df:  tidy(lm(formula = 'mpg ~ hp', data = df))
)

mtcars.groupby('cyl').apply(
  lambda df:  glance(lm(formula = 'mpg ~ hp', data = df))
)

import statsmodels.formula.api as smf
smf.ols(formula = 'mpg ~ C(cyl)', data = mtcars).fit().summary()


smf.ols(formula = 'mpg ~ C(cyl) + hp', data = mtcars).fit().summary()

smf.ols(formula = 'mpg ~ C(cyl) + hp - 1', data = mtcars).fit().summary()

smf.ols(formula = 'mpg ~ C(cyl) * hp', data = mtcars).fit().summary()
tidy(smf.ols(formula = 'mpg ~ C(cyl) * hp', data = mtcars).fit())


mtcars.groupby('cyl').apply(
  lambda df: tidy(smf.ols(formula = 'mpg ~ hp', data = mtcars).fit())
)

m = smf.ols(formula = 'mpg ~ hp', data = mtcars).fit()
newdata = pd.DataFrame({'hp': [4, 6, 8] })
m.predict(newdata)

m.predict(pd.DataFrame({'hp': [4, 6, 8] }))


# m = lm(formula = 'mpg ~ cyl', data = mtcars)
# tibble(cyl = c(4,6,8)) %>%
#   mutate(yhat = predict(m, newdata = tibble(.)))


# Import statsmodels
# import statsmodels.api as s # for linear models
# from patsy import dmatrices as d # for model specification

# let's bundle them into a data.frame with pandas.
sw = p.DataFrame({
  'height': [4, 4.5, 5, 5, 5, 5.5, 5.5, 6, 6.5, 6.5],
  'year': [1990, 2015, 2020, 1993, 1996, 2000, 2004, 1992, 2005, 2010]
}) 

# Example application
m = lm(formula = 'height ~ year', data = sw)

m.summary()
tidy(m)
glance(m)


predict(m, newdata = p.DataFrame({'year': [1990]}), formula = 'year')

# Let's try to use predict() within a dplyr context.

#sw >> mutate(yhat = Series(predict(m, newdata = p.DataFrame({'year' = X.year}))))

# sw >> \
#   group_by('year') >> \
#   reframe(tidy(m))


# Get n() per group
sw >>\
  group_by(X.year) >> \
  mutate(count = n(X.year))

sw >>\
  group_by(X.height) >> \
  summarize(count = n(X.year))

# We can't use reframe(), but we can summarize multiple lines of data into one line,
# and then explode that one line of multiple values out.
data = sw >>\
  group_by(X.height) >> \
  summarize(count = p.Series([1,2,3]) )
# Expand out that data.frame
data = data.explode('count')

# Let's try this with probabilities

# Import our probability distribution functions
from functions_distributions import *


sw >> summarize(mu = mean(X.height), sigma = sd(X.height), n = n(X.height), q25 = X.height.quantile(q = 0.25))

p.DataFrame({ 'value': rnorm(n = 5, mean = 2, sd = 0.5)})

# Get a bunch of random samples
mysims = p.DataFrame({ 'id': [1,2,3,4,5]}) >>\
  group_by('id') >>\
  summarize(sim = rnorm(n = 100, mean = 2, sd= 5)) 
# Explode them out
mysims = mysims.explode('sim') 

mysims >>\
  group_by('id') >>\
  summarize(mu = mean(X.sim))

mysims.groupby('id').aggregate(func = mean)





import pandas as pd
from dfply import *

# Sample DataFrame
sw = pd.DataFrame({
    'year': [1990, 1992, 1993, 1996, 2000, 2004, 2005, 2010, 2015, 2020],
    'prob': [[1, 0], [1, 0], [1, 0], [1, 0], [1, 0], [1, 0], [1, 0], [1, 0], [1, 0], [1, 0]]
})
# Transform the DataFrame to explode the 'prob' column
result = (sw >>
          mutate(prob=lambda df: df.prob) >>  # Ensure the column is properly referenced
          mutate(exploded_prob=lambda df: df.prob.explode()) >>  # Explode the 'prob' column
          select(X.year, X.exploded_prob)  # Select columns to display
         )
from pandas import explode

sw >> mutate(prob = X.prob.explode())
sw.explode('prob')

sw >> group_by('year') >>\ 
  # Add an example series to each group
  summarize(prob = [0,1] ) >>\
  gather('year', 'prob')


# sw >> group_by('year') >>summarize(prob = [0,1] ) >> gather('year','prob')

# Let's unpack them...
sw >>\
  group_by('year') >>\ 
  # Add an example series to each group
  summarize(prob = [0,1] ) >>\
  summarize(prob = pd.DataFrame.explode(self = X, column = 'prob')) 
  
x = sw >>\
  group_by('year') >>\ 
  # Add an example series to each group
  summarize(prob = [0,1] )
  


print(result)

len(sw.height)

# sw.values.
# sw >> \
#     group_by(X.year) >> \
#     mutate(tidy_results=lambda group: fit_and_tidy(group)) >> \
#     select(X.year, X.tidy_results)
  
  

sw.groupby('year').apply(tidy(m))

predict(m, newdata = p.DataFrame({'year': [1990]}), formula = 'year')


# Clear environment
globals().clear()

