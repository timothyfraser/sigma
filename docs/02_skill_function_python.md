# Functions in `Python`



We've learned how to use built-in functions to analyze data, but sometimes it's more helpful to (A) do the math by hand or (B) write your own function. Let's learn how!

<br>
<br>

## Getting Started {-}

### Packages {-}

We'll use base Python here. No extra packages needed.

<br>

## Coding your own function!

`Functions` are machines that do a specific calculation using an input to produce a specific output.


```{=html}
<div class="DiagrammeR html-widget html-fill-item" id="htmlwidget-704a3fc7eaedc008047f" style="width:100%;height:144px;"></div>
<script type="application/json" data-for="htmlwidget-704a3fc7eaedc008047f">{"x":{"diagram":"graph LR\n subgraph before\n i[input data <i>x<\/i>]\n end\n subgraph function\n c[calculation]\n end\n subgraph after\n o[output data <i>y<\/i>]\n end\n i --> c\n c --> o"},"evals":[],"jsHooks":[]}</script>
```

Below, we'll write an example function, called `add(a, b)`. 

- This function takes two `numeric` values, `a` and `b`, as `inputs`, and adds them together. 

- Using `def`, we'll tell `Python` that our function contains two inputs, `a` and `b`. 

- The function can involve multiple operations inside it. But at the end, you need to print *one* final output, or put `return` before your output.


```python
# Make function
def add(a, b):
  # Compute and directly output
  return a + b

add(1, 2)
```

```
## 3
```


```python
# This also works
def add(a, b):
  # Assign output to a temporary object
  output = a + b
  # Return the temporary object 'output'
  return output

add(1, 2)
```

```
## 3
```

<br>
<br>

## Functions with Default Inputs

You can assign default input values. Below, by default, `b = 2`. If we supply a different `b`, the default gets overwritten.


```python
def add(a, b = 2):
  return a + b
```

Let's try it!


```python
# Only provide 'a'
add(1)
```

```
## 3
```

```python
# Provide both
add(1, 2)
```

```
## 3
```

```python
# Change 'b'
add(1, 3)
```

```
## 4
```


```python
# clear data
del add
```

## Conclusion {-}

Great! Let's go make some functions!



