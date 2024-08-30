# Appendix: test



## Getting Started {-}

This is just a test document, placed at the end of the book.

```r
library(dplyr)
```


### Version 1 {.unnumbered}

::: {.tabset}

#### R

```r
# R code
mtcars$hp %>% mean()
```

```
## [1] 146.6875
```

#### Python


```python
# Python code
import pandas as pd
data = pd.DataFrame({'hello': [1,2,3]})
print(data.hello.mean())
```

```
## 2.0
```

:::

### Version 2 {-}

<div>
  <button onclick="toggleCode('r-code')" class="button">R</button>
  <button onclick="toggleCode('python-code')" class="button button-python">Python</button>
</div>


<div id="r-code" style="display: block;">

```r
# R code
mtcars$hp %>% mean()
```

```
## [1] 146.6875
```
</div> 
<div id="python-code" style="display: none;"> 

```python
# Python code
import pandas as pd
data = pd.DataFrame({'hello': [1,2,3]})
print(data.hello.mean())
```

```
## 2.0
```
</div> 
<script> function toggleCode(codeType) { document.getElementById('r-code').style.display = 'none'; document.getElementById('python-code').style.display = 'none'; document.getElementById(codeType).style.display = 'block'; } </script>


Did it work?

