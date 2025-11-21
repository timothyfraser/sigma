# Import scipy functions
from scipy.stats import chi2
import numpy as np
import pandas as pd
from pandas import Series, DataFrame

# Import helper functions from functions_distributions
# Note: These should be imported when the file is used
# from functions_distributions import runif, approxfun, density

def qk(p, r, time=False, failure=False):
    """
    k-factor Quantiles
    
    Function to return quantiles for k-factors.
    Intended for estimating confidence intervals for failure rates.
    
    Parameters:
    -----------
    p : float or array-like
        vector of probabilities / percentile(s)
    r : int
        number of failures (non-negative integers; can include zero)
    time : bool, default False
        logical; is case time-censored data?
    failure : bool, default False
        logical; is case failure-censored data?
    
    Returns:
    --------
    k : float or Series
        k-factor quantiles
    """
    # Testing values
    # p = 0.95; r = 20; time = False; failure = False
    
    # Convert p to numpy array for vectorized operations
    p = np.asarray(p)
    is_scalar = p.ndim == 0
    if is_scalar:
        p = np.array([p])
    
    # Input error handling
    if not (np.all(np.isreal(p)) and np.all((p >= 0) & (p <= 1))):
        raise ValueError("p must be numeric and between 0 and 1")
    if not (isinstance(r, (int, np.integer)) or (isinstance(r, float) and r.is_integer())):
        raise ValueError("r must be numeric and convertible to integer")
    r = int(r)
    if not isinstance(time, bool):
        raise ValueError("time must be logical (bool)")
    if not isinstance(failure, bool):
        raise ValueError("failure must be logical (bool)")
    if not ((time == True and failure == False) or 
            (time == False and failure == False) or 
            (time == False and failure == True)):
        raise ValueError("time and failure cannot both be True")
    if not ((r > 0) or (r == 0 and time == True)):
        raise ValueError("r must be > 0, or r == 0 and time == True")
    
    # Evaluate if p is in the upper or lower tail
    upper = p > 0.5
    
    # Does r == 0?
    zerofailures = (r == 0)
    
    # Initialize k array
    k = np.full(len(p), np.nan)
    
    # Apply conditional logic for each element
    for i in range(len(p)):
        p_val = p[i]
        upper_val = upper[i]
        
        if (zerofailures == False and time == False and failure == False and upper_val == True):
            # 1+ failures AND complete data AND UPPER tail --> Get k-factor for r as normal
            k[i] = chi2.ppf(p_val, df=2*r) / (2*r)
        elif (zerofailures == False and time == False and failure == False and upper_val == False):
            # 1+ failures AND complete data AND LOWER tail --> Get k-factor for r as normal
            k[i] = chi2.ppf(p_val, df=2*r) / (2*r)
        elif (zerofailures == False and time == True and failure == False and upper_val == True):
            # 1+ failures AND time-censored data AND UPPER tail --> Get k-factor for r+1
            k[i] = chi2.ppf(p_val, df=2*(r + 1)) / (2*r)
        elif (zerofailures == False and time == True and failure == False and upper_val == False):
            # 1+ failures AND time-censored data AND LOWER tail --> Get k-factor for r as normal
            k[i] = chi2.ppf(p_val, df=2*r) / (2*r)
        elif (zerofailures == False and time == False and failure == True and upper_val == True):
            # 1+ failures AND failure-censored data AND UPPER tail --> Get k-factor with adjustment
            k[i] = chi2.ppf(p_val, df=2*((r-1) + 1)) / (2 * (r-1)) * (r-1)/r
        elif (zerofailures == False and time == False and failure == True and upper_val == False):
            # 1+ failures AND failure-censored data AND LOWER tail --> Get k-factor with r as normal
            k[i] = chi2.ppf(p_val, df=2*r) / (2*r)
        elif (zerofailures == True and time == True and failure == False):
            # If zero failures --> then time-censored --> time = True, and upper/lower distinction doesn't matter.
            k[i] = -np.log(1 - p_val)
        else:
            # Otherwise, return NA.
            k[i] = np.nan
    
    if np.any(np.isnan(k)):
        print("At least 1 k-factor could not be calculated, due to improper inputs. Review the rules for time-censored, failure-censored, and zero-failure data.")
    
    # Return scalar if input was scalar, otherwise return Series
    if is_scalar:
        return float(k[0])
    else:
        return Series(k)


def rk(n, r, time=False, failure=False):
    """
    k-factor Random Deviates
    
    Get a random sample of k-factor values for simulating sampling distributions of failure rates.
    
    Parameters:
    -----------
    n : int
        number of observations
    r : int
        number of failures (non-negative integers; can include zero)
    time : bool, default False
        logical; is case time-censored data?
    failure : bool, default False
        logical; is case failure-censored data?
    
    Returns:
    --------
    k : Series
        random sample of k-factor values
    """
    # Testing values
    # n = 100; r = 20; time = False; failure = False
    
    # Import runif here to avoid circular imports
    import sys
    import os
    # Try to import from functions_distributions
    try:
        from functions_distributions import runif
    except ImportError:
        # If not available, define a simple runif
        from scipy.stats import uniform
        def runif(n, min=0, max=1):
            output = uniform.rvs(loc=min, scale=max, size=n)
            return Series(output)
    
    # Input error handling
    if not (isinstance(n, (int, np.integer)) or (isinstance(n, float) and n.is_integer())):
        raise ValueError("n must be numeric and convertible to integer")
    n = int(n)
    if n <= 0:
        raise ValueError("n must be > 0")
    if not isinstance(time, bool):
        raise ValueError("time must be logical (bool)")
    if not isinstance(failure, bool):
        raise ValueError("failure must be logical (bool)")
    if not ((time == True and failure == False) or 
            (time == False and failure == False) or 
            (time == False and failure == True)):
        raise ValueError("time and failure cannot both be True")
    
    # Does r == 0?
    zerofailures = (r == 0)
    
    # Generate a uniform distribution of percentiles p
    p_uniform = runif(n=n, min=0, max=1)
    
    # Return quantiles for the random percentiles
    k = qk(p=p_uniform, r=r, time=time, failure=failure)
    return k


def pk(q, r, time=False, failure=False):
    """
    k-factor Cumulative Distribution Function
    
    Function to return cumulative probabilities / percentiles given a supplied k-factor quantile `q`.
    Intended for confidence intervals for failure rates.
    
    Parameters:
    -----------
    q : float or array-like
        vector of quantiles (k-factors)
    r : int
        number of failures (non-negative integers; can include zero)
    time : bool, default False
        logical; is case time-censored data?
    failure : bool, default False
        logical; is case failure-censored data?
    
    Returns:
    --------
    p : float or Series
        cumulative probabilities / percentiles
    """
    # Testing values
    # q = 2; r = 20; time = False; failure = False
    
    # Import approxfun here to avoid circular imports
    try:
        from functions_distributions import approxfun
    except ImportError:
        from scipy.interpolate import interp1d
        def approxfun(data, fill_value='extrapolate', bounds_error=False):
            output = interp1d(data.x, data.y, kind='linear', fill_value=fill_value, bounds_error=bounds_error)
            return output
    
    # Convert q to numpy array for vectorized operations
    q = np.asarray(q)
    is_scalar = q.ndim == 0
    if is_scalar:
        q = np.array([q])
    
    # Construct an approximation function f, which gives the inverse of the Quantile Function,
    # such that you use linear interpolation to return a Probability for any Quantile supplied.
    by = 0.001
    p_range = np.concatenate([
        [by/10000, by/1000, by/100, by/10],
        np.arange(0, 1 + by, by),
        [1 - by/10, 1 - by/100, 1 - by/1000, 1 - by/10000]
    ])
    p_range = np.sort(p_range)
    
    # Get the quantiles for that range
    q_range = qk(p=p_range, r=r, time=time, failure=failure)
    
    # Convert to Series if needed for approxfun
    if isinstance(q_range, Series):
        q_range_values = q_range.values
    else:
        q_range_values = np.asarray(q_range)
    
    # Create DataFrame for approxfun
    data = DataFrame({'x': Series(q_range_values), 'y': Series(p_range)})
    
    # Get the inverse quantile function
    f = approxfun(data, fill_value='extrapolate', bounds_error=False)
    
    # Return the expected CDF for that quantile
    p = f(q)
    
    # Convert to Series if input was array-like, scalar if input was scalar
    if is_scalar:
        return float(p)
    else:
        return Series(p)


def dk(x, r, time=False, failure=False):
    """
    k-factor Probability Density Function
    
    Function to return probability densities given a supplied k-factor quantile `x`.
    Intended for visualizing sampling distributions of failure rates.
    
    Parameters:
    -----------
    x : float or array-like
        vector of quantiles (k-factors)
    r : int
        number of failures (non-negative integers; can include zero)
    time : bool, default False
        logical; is case time-censored data?
    failure : bool, default False
        logical; is case failure-censored data?
    
    Returns:
    --------
    d : float or Series
        probability densities
    """
    # Testing values
    # x = 2; r = 21; time = True; failure = False
    
    # Import helper functions here to avoid circular imports
    try:
        from functions_distributions import density, approxfun
    except ImportError:
        from scipy.stats import gaussian_kde
        from scipy.interpolate import interp1d
        def density(x):
            output = gaussian_kde(x)
            return output
        def approxfun(data, fill_value='extrapolate', bounds_error=False):
            output = interp1d(data.x, data.y, kind='linear', fill_value=fill_value, bounds_error=bounds_error)
            return output
    
    # Convert x to numpy array for vectorized operations
    x = np.asarray(x)
    is_scalar = x.ndim == 0
    if is_scalar:
        x = np.array([x])
    
    # Construct a range of quantiles corresponding to a range of cumulative probabilities
    by = 0.001
    p_range = np.concatenate([
        [by/10000, by/1000, by/100, by/10],
        np.arange(0, 1 + by, by),
        [1 - by/10, 1 - by/100, 1 - by/1000, 1 - by/10000]
    ])
    p_range = np.sort(p_range)
    
    # Get the quantiles for that range
    q_range = qk(p=p_range, r=r, time=time, failure=failure)
    
    # Convert to numpy array
    if isinstance(q_range, Series):
        q_range_values = q_range.values
    else:
        q_range_values = np.asarray(q_range)
    
    # Filter out NaN, inf, and negative values (equivalent to R's cut = c(0))
    # First filter finite values, then filter >= 0
    valid_mask = np.isfinite(q_range_values) & (q_range_values >= 0)
    q_range_values = q_range_values[valid_mask]
    
    # Check if we have any valid values
    if len(q_range_values) == 0:
        # If no valid values, return zeros
        if is_scalar:
            return 0.0
        else:
            return Series(np.zeros(len(x)))
    
    # Need at least 2 points for KDE
    if len(q_range_values) < 2:
        # If only one point, return 0 for all queries
        if is_scalar:
            return 0.0
        else:
            return Series(np.zeros(len(x)))
    
    # Fit a density curve to that quantile data, truncated at 0
    curve_model = density(q_range_values)
    
    # Create a range of x values for the density curve
    # Use a range that covers the data
    x_min = q_range_values.min()
    x_max = q_range_values.max()
    x_density = np.linspace(x_min, x_max, num=1000)
    y_density = curve_model(x_density)
    
    # Create DataFrame for approxfun
    data = DataFrame({'x': Series(x_density), 'y': Series(y_density)})
    
    # Approximate a function using the density curve's x and y values
    f = approxfun(data, fill_value=0, bounds_error=False)
    
    # Estimate density
    d = f(x)
    
    # Handle any negative results (shouldn't happen, but safety check)
    d = np.maximum(d, 0)
    
    # Return scalar if input was scalar, otherwise return Series
    if is_scalar:
        return float(d)
    else:
        return Series(d)


