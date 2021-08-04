# ebalfit
Stata module to perform entropy balancing

`ebalfit` is an estimation command to perform entropy balancing.
Entropy balancing can be expressed as a regression-like model with one
coefficient for each balancing constraint. `ebalfit` estimates such a model
including the variance-covariance matrix of the estimated parameters. The
balancing weights are then obtained as predictions from this model. The
variance-covariance matrix computed by `ebalfit` is based on influence
functions. The influence functions can be stored for further use, for example,
to correct the standard errors of statistics computed from the reweighted data.

To install `ebalfit` from the SSC Archive, type

    . ssc install ebalfit, replace

in Stata. Stata version 14 or newer is required. Furthermore, the `moremata` package
is required. To install `moremata` from the SSC Archive, type

    . ssc install moremata, replace

---

Installation from GitHub:

    . net install ebalfit, replace from(https://raw.githubusercontent.com/benjann/ebalfit/main/)
    . net install moremata, replace from(https://raw.githubusercontent.com/benjann/moremata/master/)

---

Main changes:

    04aug2021 (version 1.0.4)
    - new etype() option to select the type of evaluator; option alteval is now 
      undocumented
    - indicators for omitted terms now returned in e(omit)

    03aug2021 (version 1.0.3)
    - new option tau() to set target sum of weights
    - -pscore- now allowed as synonym for -pr-in predict
    - new option -u- in predict to compute raw balancing weights (without base weights)
    - new option -nocons-/-noalpha- in predict to skips IF for constant
    - adaptions to take account of changes in moremata's mm_ebalance() function

    29jul2021 (version 1.0.2)
    - varlist only allowed elements such as -varname-, -c.varname-, or -i.varname-
      if targets() was specified; this is fixed; factor-variable notation is now 
      fully supported (apart from interactions) even if targets() is specified
    - predict now has additional options -xb- (linear prediction) and -pr-
      (propensity score)
    - -norm- added as an additional ltype()
    - option -alteval- added
    - option trace() added (undocumented; specify tracelevel for Mata's optimize())
    - vtolerance() was not passed through to the optimization; this is fixed

    28jul2021 (version 1.0.1)
    - option -nostd- added

    27jul2021 (version 1.0.0)
    - ebalfit released on GitHub
