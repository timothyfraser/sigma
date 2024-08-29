?lm()
rbinom(n =3,size =1, prob =0.1)
?broom::tidy()

broom::tidy(lm(hp ~ cyl, data = mtcars), conf.int = 0.95)
broom::glance(lm(hp ~ cyl, data = mtcars))

r.squared
adj.r.squared
sigma
statistic
p.value
df
logLik
AIC
BIC
deviance
df.residual
nobs