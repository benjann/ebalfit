# ebalfit
Stata module to perform entropy balancing

`ebalfit` is an estimation command to perform entropy balancing.
Entropy balancing can be expressed as a regression-like model with one
coefficient for each balancing constraint. `ebalfit` estimates such a model
including the variance-covariance matrix of the estimates parameters. The
balancing weights are then obtained as predictions from this model. The
variance-covariance matrix computed by `ebalfit` is based on influence
functions. The influence functions can be stored for further use, for example,
to correct the standard errors of statistics computed from the reweighted data.

To install `ebalfit`, type

    . net install ebalfit, replace from(https://raw.githubusercontent.com/benjann/ebalfit/main/)

in Stata. Stata version 14 or newer is required. Furthermore, the `moremata` package
is required. To install `moremata`, type

    . net install moremata, replace from(https://raw.githubusercontent.com/benjann/moremata/master/)

---

Main changes:

    27jul2021 (version 1.0.0)
    - ebalfit released on GitHub
