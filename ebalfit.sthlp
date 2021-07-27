{smcl}
{* 27jul2021}{...}
{hi:help ebalfit}{...}
{right:{browse "http://github.com/benjann/ebalfit/"}}
{hline}
{p 0 0 2}

{title:Title}

{pstd}{hi:ebalfit} {hline 2} Entropy balancing as an estimation command


{title:Syntax}

{pstd}
    Syntax 1: balance subsamples

{p 8 15 2}
    {cmd:ebalfit} {varlist} {ifin} {weight}{cmd:,} {opth by(varname)}
    [{cmd:,} {help ebalfit##opts:{it:options}} ]

{pstd}
    Syntax 2: adjust sample to population

{p 8 15 2}
    {cmd:ebalfit} {varlist} {ifin} {weight}{cmd:,} {cmdab:pop:ulation(}[{it:size}{cmd::}]{help numlist:{it:numlist}}{cmd:)}
    [{cmd:,} {help ebalfit##opts:{it:options}} ]

{pstd}
    Replay results

{p 8 15 2}
    {cmd:ebalfit} [{cmd:,} {help ebalfit##repopts:{it:reporting_options}} ]

{pstd}
    Generate balancing weights after estimation

{p 8 15 2}
    {cmd:predict} [{help datatypes:{it:type}}] {newvar} {ifin}

{pstd}
    Generate influence functions after estimation

{p 8 15 2}
    {cmd:predict} [{help datatypes:{it:type}}]
        {c -(}{help newvarlist##stub*:{it:stub}}{cmd:*} |
        {it:{help newvar:newvar1}} {it:{help newvar:newvar2}} {cmd:...}{c )-}
        {ifin}{cmd:,} {opt if:s}


{synoptset 21 tabbed}{...}
{marker opts}{col 5}{it:{help robreg##options:options}}{col 28}description
{synoptline}
{syntab :Main}
{synopt :{opt by(groupvar)}}identify subsamples (required in syntax 1)
    {p_end}
{synopt :{opt swap}}swap subsamples (syntay 1 only)
    {p_end}
{synopt :{opt pool:ed}}use pooled sample as reference (syntay 1 only)
    {p_end}
{synopt :{cmdab:pop:ulation(}{help ebalfit##pop:{it:spec}}{cmd:)}}provide population values (required in syntax 2)
    {p_end}
{synopt :{cmdab:tar:gets(}{help ebalfit##tar:{it:options}}{cmd:)}}specify types of moments to be balanced
    {p_end}

{marker repopts}{...}
{syntab :Reporting}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}
    {p_end}
{synopt :{opt nohead:er}}suppress table header
    {p_end}
{synopt :{opt notab:le}}suppress coefficient table
    {p_end}
{synopt :{help ebalfit##displayopts:{it:display_options}}}standard
    reporting options as described in
    {helpb estimation options:[R] estimation options}
    {p_end}
{synopt :{opt bal:tab}[{cmd:(}{help ebalfit##baltab:{it:options}}{cmd:)}]}display balancing table
    {p_end}

{syntab :VCE/SE}
{synopt:{cmd:vce(}{help ebalfit##vce:{it:vcetype}}{cmd:)}}variance estimation
    method; default is {cmd:vce(robust)}
    {p_end}
{synopt :{opt cl:uster(clustvar)}}synonym for
    {cmd:vce(cluster} {it:clustvar}{cmd:)}
    {p_end}
{synopt :{opt nose}}synonym for {cmd:vce(none)}
    {p_end}

{marker genopts}{...}
{syntab :Generate}
{synopt :{opth g:enerate(newvar)}}store balancing weights
    {p_end}
{synopt :{cmdab:if:generate(}{help ebalfit##ifgen:{it:names}}{cmd:)}}store influence functions
    {p_end}
{synopt :{opt nod:escribe}}suppress list of generated variables in output
    {p_end}
{synopt :{opt r:eplace}}allow replacing existing variables
    {p_end}

{marker optimopts}{...}
{syntab :Optimization}
{synopt :{opt btol:erance(#)}}balancing tolerance; default is {bf:1e-6}
    {p_end}
{synopt :{cmd:ltype(}{help ebalfit##ltype:{it:ltype}{cmd:)}}}type of loss function; default is
    {cmd:ltype(reldif)}
    {p_end}
{synopt :{opt iter:ate(#)}}maximum number of iterations;
    default is as set by {helpb set maxiter}
    {p_end}
{synopt :{opt ptol:erance(#)}}convergence tolerance for coefficient
    vector; default is {bf:1e-6}
    {p_end}
{synopt :{opt vtol:erance(#)}}convergence tolerance for the balancing
    loss; default is {bf:1e-7}
    {p_end}
{synopt :{opt dif:ficult}}use a different stepping algorithm in nonconcave
    regions{p_end}
{synopt :{opt nolog}}do not display iteration log
    {p_end}
{synopt :{opt relax}}do not return error if convergence or balancing is not achieved
    {p_end}
{synopt :{opt nowarn}}do not display non-convergence/non-balancing
    messages
    {p_end}
{synoptline}
{pstd}
    {it:varlist} may contain factor variables; see {help fvvarlist}.
    {p_end}
{pstd}
    {cmd:fweight}s, {cmd:iweight}s, and {cmd:pweight}s are allowed; see {help weight}.
    {p_end}


{title:Description}

{pstd}
    {cmd:ebalfit} is an estimation command to perform entropy balancing
    (Hainmueller 2012). The goal of entropy balancing is to find a vector of
    weights that balances the data between two subsamples with respect to
    specific moments of a list of variables (e.g. means and variances). For
    example, we might want to reweight a control group such that the means of
    pre-treatment variables match the means in the treatment group. Likewise,
    entropy balancing can be used to adjust the distribution of a sample to known
    population values.

{pstd}
    Entropy balancing can be expressed as a regression-like model with one
    coefficient for each balancing constraint. {cmd:ebalfit} estimates such a
    model including the variance-covariance matrix of the estimates parameters. The
    balancing weights are then obtained as predictions from this model. The
    variance-covariance matrix computed by {cmd:ebalfit} is based on influence
    functions (see section 3.8 in Jann 2020a). The influence functions can be
    stored for further use, for example, to correct the standard errors of
    statistics computed from the reweighted data (e.g. section 3.7.9 in
    Jann 2020b).

{pstd}
    The heavy lifting is done by function {helpb mf_mm_ebalance:mm_ebalance()}
    from the {helpb moremata} package, which needs to be installed on the
    system. See
    {net "describe moremata, from(http://fmwww.bc.edu/repec/bocode/m/)":ssc describe moremata}.

{pstd}
    For an alternative implementation of entropy balancing in Stata
    see {helpb ebalance} by Hainmueller and Xu (2011, 2013).


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
    {opt by(groupvar)} is required in syntax 1. The
    specified variable must be integer and nonnegative and must identify exactly
    two groups. By default, the lower value identifies the subsample to be
    reweighted and the higher value identifies the reference subsample; also see
    option {cmd:swap}.

{phang}
    {opt swap} swaps the subsamples (only allowed in syntax 1). By default, the
    lower value of {it:groupvar} identifies the subsample to be reweighted. Specify
    {cmd:swap} to identify the subsample to be reweighted by the higher value of
    {it:groupvar}.

{phang}
    {opt pooled} uses the pooled sample across both groups as the reference
    sample (only allowed in syntax 1). In this case, the selected subsample
    will be reweighted with respect to the overall sample (rather than with
    respect to the other subsample).

{marker pop}{...}
{phang}
    {opt population(spec)} is required in syntax 2. Use this option to specify
    the size of the population as well the population averages to which the
    sample should be reweighted. The syntax of {it:spec} is

            [{it:popsize}{cmd::}] {help numlist:{it:numlist}}

{pmore}
    where {it:popsize} is the size of the population and {it:numlist} provides
    the population averages of the variables. {it:numlist} must contain one value
    for each variable. If {it:popsize} omitted, it will be set to existing sum of
    weights in the sample.

{marker tar}{...}
{phang}
     {opt targets(options)} specifies the types of moments to be balanced. {it:options}
     are:

            {cmdab:m:ean}           (the default)
            {cmdab:v:ariance}       (implies {cmd:mean})
            {cmdab:s:keweness}      (implies {cmd:mean} and {cmd:variance})
            {cmdab:c:ovariance}     (implies {cmd:mean})

{pmore}
    By default, only the means of the specified variables will be balanced. If you
    type, for example, {cmd:targets(variance)}, then the variances of the variables
    will be balanced in addition to the means. Balancing of higher moments and
    covariances is implemented by adding extra terms to
    {it:varlist} before running the balancing algorithm. For example, {cmd:variance} will add
    {cmd:c.}{it:varname}{cmd:#}{cmd:c.}{it:varname} for each continuous variable
    in {it:varlist}. Likewise, {cmd:covariance} will add
    {cmd:c.}{it:varname1}{cmd:#}{cmd:c.}{it:varname2} for each combination of
    continuous variables. Factor variables specified as {cmd:i.}{it:varname}
    will be ignored by {cmd:variance} and {cmd:skewness}, but
    {cmd:covariance} will consider them and add appropriate
    interaction terms such as {cmd:i.}{it:fvvar1}{cmd:#}{cmd:c.}{it:varname2}.

{pmore}
    If option {cmd:targets()} is specified, {it:varlist} may only contain
    variables specified as {it:varname} (continuous variable),
    {cmd:c.}{it:varname} (continuous variable; synonym to {it:varname}), or
    {cmd:i.}{it:varname} (factor variable). Other elements of factor-variable
    notation are not allowed in this case. However, if option {cmd:targets()}
    is omitted, you can make full use of factor-variable notation (see
    {helpb fvvarlist:[U] 11.4.3 Factor variables}). For example, you could
    specify

            {com}c.hours##c.tenure i.south i.south#c.tenure{txt}

{pmore}
    to balance the means of {cmd:hours} and {cmd:tenure}, the covariance between
    {cmd:hours} and {cmd:tenure}, the proportions of the levels of {cmd:south},
    as well as the averages of {cmd:tenure} within levels of {cmd:south}. That is,
    you can use extended factor-variable notation as an alternative to option
    {cmd:targets()} if you want to have more control over the exact configuration
    of moments to be balanced.


{marker repoptions}{...}
{dlgtab:Reporting}

{phang}
    {opt level(#)} specifies the confidence level, as a percentage, for
    confidence intervals. The default is {cmd:level(95)} or as set by
    {helpb set level}.

{phang}
    {opt noheader} suppresses the display of the table header.

{phang}
    {opt notable} suppresses the display of the table of results.


{marker displayopts}{...}
{phang}
    {it:display_options} are standard reporting options such as {cmd:eform},
    {cmd:cformat()}, or {cmd:coeflegend}; see {help eform_option:{bf:[R]} {it:eform_option}} and
    the Reporting options in {helpb estimation options:[R] Estimation options}.

{marker baltab}{...}
{phang}
    {cmd:baltab}[{cmd:(}{it:options}{cmd:)}] displays a balancing table in addition
    to the table of coefficients. The balancing table contains for each term
    the raw mean and the reweighted mean, the target value for the
    reweighted mean, as well as the absolute difference and the "relative"
    difference (see {helpb reldif()}) between the reweighted mean and the target
    value. {it:options} are as described in {helpb _matrix_table}.

{dlgtab:VCE/SE}

{marker vce}{...}
{phang}
    {opt vce(vcetype)} determines how standard errors are computed. {it:vcetype} may be:

            {opt r:obust}
            {opt cl:uster} {it:clustvar}
            {opt none}

{pmore}
    {cmd:vce(robust)}, the default, computes standard
    errors based on influence functions. Likewise, {bind:{cmd:vce(cluster} {it:clustvar}{cmd:)}}
    computes standard errors based on influence function allowing for intragroup
    correlation, where {it:clustvar} specifies to which group each observation
    belongs. {cmd:vce(none)} omits the computation of standard errors.

{phang}
    {opt cluster(clustvar)} can be used as a synonym for {cmd:vce(cluster} {it:clustvar}{cmd:)}.

{phang}
    {cmd:nose} omits the computation of standard errors. Use this option to
    save computer time. {cmd:nose} is a synonym for {cmd:vce(none)}.

{dlgtab:Generate}

{phang}
    {opth generate(newvar)} stores the balancing weights in {it:newvar}. Alternatively,
    use command {cmd:predict} to generate the balancing weights after estimation.

{pmore}
    In syntax 1, weights will be filled in for both the reweighted
    subsample and the reference subsample, using a copy of the base weights
    for the latter (or 1 if there are no base weights).

{marker ifgenerate}{...}
{phang}
    {opt ifgenerate(names)} stores the influence functions of the
    coefficients. {it:names} is either a list of (new) variable names
    or {help newvarlist##stub*:{it:stub}}{cmd:*} to create names {it:stub}{cmd:1},
    {it:stub}{cmd:2}, etc. Alternatively, use command {cmd:predict} with option
    {cmd:ifs} to generate the influence functions after estimation.

{phang}
    {opt nodescribe} suppresses the list of generated variables that is displayed
    in the output by default.

{phang}
    {opt replace} allows replacing existing variables.

{marker optimoptions}{...}
{dlgtab:Optimization}

{phang}
    {opt btolerance(#)} sets the balancing tolerance. Balance is achieved if
    the balancing loss is smaller than the balancing tolerance. The
    default is {bf:btolerance(1e-6)}.

{marker ltype}{...}
{phang}
    {opt ltype(ltype)} sets the type of loss function to be used. {it:ltype}
    can be {cmd:reldif} (maximum relative difference) or {cmd:absdif} (maximum
    absolute difference). The default is {cmd:reldif} .

{phang}
    {opt iterate(#)} specifies the maximum number of iterations. Error will be returned
    if convergence is not reached within the specified maximum number of
    iterations. The default is as set by {helpb set maxiter}.

{phang}
    {opt ptolerance(#)} specifies the convergence tolerance for the coefficient
    vector. Convergence is reached if {cmd:ptolerance()} or {cmd:vtolerance()}
    is satisfied. See {helpb mf_optimize##i_ptol:optimize()} for details. The
    default is {cmd:ptolerance(1e-6)}.

{phang}
    {opt vtolerance(#)} specifies the convergence tolerance for the balancing
    loss. Convergence is reached if {cmd:ptolerance()} or {cmd:vtolerance()}
    is satisfied. See {helpb mf_optimize##i_ptol:optimize()} for details. The
    default is {cmd:vtolerance(1e-7)}.

{phang}
    {cmd:difficult} uses a different stepping algorithm in nonconcave. See
    the singular H methods in {helpb mf_optimize##i_singularH:optimize()} and
    the description of the {cmd:difficult} option in {helpb maximize}.

{phang}
    {opt nolog} suppresses the display of progress information.

{phang}
    {opt relax} causes {cmd:ebalfit} to proceed even if convergence or balancing
    is not achieved.

{phang}
    {cmd:nowarn} suppresses any "convergence not achieved" or "balance not achieved"
    messages. This is only relevant if option {cmd:relax} has been specified.


{title:Examples}

{pstd}
    Reweight the sample of unionized workers such that the proportion with college
    degree as well as the averages of working hours,
    work experience, and tenure are the same as for non-unionized workers.

        . {stata sysuse nlsw88, clear}
        . {stata ebalfit i.collgrad hours ttl_exp tenure, by(union) swap baltab}

{pstd}
    As indicated by the balancing loss and illustrated in the balancing table, perfect
    balance has been achieved. We can generate the balancing weights and confirm manually
    that the weights balance the data:

        . {stata predict wbal}
        . {stata tabstat collgrad hours ttl_exp tenure [aw=wbal], by(union) nototal}
        . {stata drop wbal}

{pstd}
    Balance variances and covariances in addition to the means:

        . {stata ebalfit i.collgrad hours ttl_exp tenure, by(union) swap targets(variance covariance)}
        . {stata predict wbal}
        . {stata corr collgrad hours ttl_exp tenure if union==0, cov}
        . {stata corr collgrad hours ttl_exp tenure [aw=wbal] if union==1, cov}
        . {stata drop wbal}

{pstd}
    Again, perfect balance could be achieved. The slight differences between the
    covariance tables for the two groups are because {helpb corr} normalizes
    the weights by the number of (physical) observations (if {helpb corr} would
    treat the sum of weights as the sample size, the results would be identical).

{pstd}
    Reweight a sample to arbitrary target values (e.g. population averages obtained
    from a census):

        . {stata "ebalfit 1.collgrad hours ttl_exp tenure, population(1e7: .30 40 10 5) baltab"}


{title:Stored results}

{pstd}
    {cmd:ebalfit} saves the following results in {cmd:e()}.

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(W)}}sum of weights{p_end}
{synopt:{cmd:e(N_clust)}}number of clusters (if {cmd:vce(cluster)}){p_end}
{synopt:{cmd:e(k_eq)}}number of equations in {cmd:e(b)} (always equal to 1){p_end}
{synopt:{cmd:e(loss)}}balancing loss at final fit{p_end}
{synopt:{cmd:e(iter)}}number of iterations{p_end}
{synopt:{cmd:e(converged)}}1 if convergence achieved, 0 else{p_end}
{synopt:{cmd:e(balanced)}}1 if balance achieved, 0 else{p_end}
{synopt:{cmd:e(cv)}}coefficient of variation of balancing weights{p_end}
{synopt:{cmd:e(deff)}}DEFF (design effect) of balancing weights{p_end}
{synopt:{cmd:e(btolerance)}}setting from {cmd:btolerance()}{p_end}
{synopt:{cmd:e(ptoleranc)}}setting from {cmd:ptolerance()}{p_end}
{synopt:{cmd:e(vtolerance)}}setting from {cmd:vtolerance()}{p_end}
{synopt:{cmd:e(maxiter)}}setting from {cmd:iterate()}{p_end}
{synopt:{cmd:e(df_m)}}model degrees of freedom (unless {cmd:nose}){p_end}
{synopt:{cmd:e(chi2)}}chi-squared value of model test (unless {cmd:nose}){p_end}
{synopt:{cmd:e(p)}}p-value for model test (unless {cmd:nose}){p_end}
{synopt:{cmd:e(rank)}}rank of {cmd:e(V)} (unless {cmd:nose}){p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:ebalfit}{p_end}
{synopt:{cmd:e(predict)}}{cmd:ebalfit_p}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(varlist)}}names of balancing variables{p_end}
{synopt:{cmd:e(by)}}name of variable identifying subsamples{p_end}
{synopt:{cmd:e(balsamp)}}subsample to be reweighted{p_end}
{synopt:{cmd:e(refsamp)}}reference subsample{p_end}
{synopt:{cmd:e(ltype)}}{cmd:reldif} or {cmd:absdif}{p_end}
{synopt:{cmd:e(difficult)}}{cmd:difficult} or empty{p_end}
{synopt:{cmd:e(generate)}}name of variable containing balancing weights{p_end}
{synopt:{cmd:e(ifgenerate)}}names of variables containing influence functions{p_end}
{synopt:{cmd:e(vce)}}{it:vcetype} specified in {cmd:vce()}{p_end}
{synopt:{cmd:e(vcetype)}}title used to label Std. Err.{p_end}
{synopt:{cmd:e(clustvar)}}name of cluster variable{p_end}
{synopt:{cmd:e(wtype)}}weight type{p_end}
{synopt:{cmd:e(wexp)}}weight expression{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(properties)}}{cmd:b} or {cmd:b V}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}estimates{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of estimates (unless {cmd:nose}){p_end}
{synopt:{cmd:e(_N)}}number of (physical) observations in subsamples{p_end}
{synopt:{cmd:e(_W)}}sum of weight in subsamples{p_end}
{synopt:{cmd:e(baltab)}}balancing table{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}estimation sample{p_end}
{p2colreset}{...}


{title:References}

{phang}
    Hainmueller, J. (2012). Entropy Balancing for Causal Effects: A
    Multivariate Reweighting Method to Produce Balanced Samples in
    Observational Studies. Political Analysis
    20(1): 25-46. DOI: {browse "http://doi.org/10.1093/pan/mpr025":10.1093/pan/mpr025}
    {p_end}
{phang}
    Hainmueller, J., Y. Xu (2011). EBALANCE: Stata module to perform Entropy
    reweighting to create balanced samples. Statistical Software Components
    S457326, Boston College Department of Economics. {browse "http://ideas.repec.org/c/boc/bocode/s457326.html"}.
    {p_end}
{phang}
    Hainmueller, J., Y. Xu (2013). ebalance: A Stata Package for Entropy Balancing.
    Journal of Statistical Software
    54(7):1-18. DOI: {browse "http://doi.org/10.18637/jss.v054.i07":10.18637/jss.v054.i07}
    {p_end}
{phang}
    Jann, B. (2020a). Influence functions continued. A framework for estimating standard errors in reweighting,
    matching, and regression adjustment. University of Bern Social Sciences Working Papers 35. Available from
    {browse "http://ideas.repec.org/p/bss/wpaper/35.html"}.
    {p_end}
{phang}
    Jann, B. (2020b). Relative distribution analysis in Stata. University of Bern Social Sciences Working
    Papers 37. Available from
    {browse "http://ideas.repec.org/p/bss/wpaper/37.html"}.
    {p_end}


{title:Author}

{pstd}
    Ben Jann, University of Bern, ben.jann@unibe.ch

{pstd}
    Thanks for citing this software as follows:

{pmore}
    Jann, B. (2021). ebalfit: Stata module to perform entropy balancing. Available
    from http://github.com/benjann/ebalfit/.


{title:Also see}

{psee}
    Official Stata:
    {helpb estcom},
    {helpb teffects}
    {p_end}
{psee}
    SSC Archive:{space 4}
    {helpb ebalance},
    {helpb kmatch},
    {helpb moremata}, {helpb mf_mm_ebalance:mm_ebalance()},
    {helpb mf_mm_wbal:mm_wbal()},
    {helpb mf_mm_ebal:mm_ebal()}