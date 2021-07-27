*! version 1.0.0  27jul2021  Ben Jann

capt findfile lmoremata.mlib
if _rc {
    di as error "-moremata- is required; type {stata ssc install moremata}"
    error 499
}

program ebalfit, eclass
    version 14
    if replay() {
        Replay `0'
        exit
    }
    local version : di "version " string(_caller()) ":"
    Get_diopts `0' // returns 00, diopts, nodescribe
    Estimate `00'
    eret local cmdline `"dstat `0'"'
    Replay, `diopts'
    if "`nodescribe'"=="" {
        if `"`e(generate)'`e(ifgenerate)'"'!="" {
            tempname rcurrent
            _return hold `rcurrent'
            describe `e(generate)' `e(ifgenerate)'
            _return restore `rcurrent'
        }
    }
end

program Get_diopts
    _parse comma lhs 0 : 0
    syntax [, noHEADer NOTABle NODescribe BALtable BALtable2(passthru) * ]
    _get_diopts diopts options, `options'
    _get_eformopts, soptions eformopts(`options') allowed(__all__)
    local options `s(options)'
    c_local diopts `diopts' `s(eform)' `header' `notable' `baltable' `baltable2'
    if `"`options'"'!="" local lhs `lhs', `options'
    c_local nodescribe `nodescribe'
    c_local 00 `lhs'
end

program Replay
    if `"`e(cmd)'"'!="ebalfit" {
        di as err "last ebalfit results not found"
        exit 301
    }
    if c(noisily)==0 exit
    syntax [, noHeader NOTABle BALtable BALtable2(str) * ]
    if `"`baltable2'"'!="" local baltable baltable
    if "`header'"=="" {
        local w1 17
        local c1 49
        local c2 = `c1' + `w1' + 1
        local w2 10
        local hopts head2left(`w1') head2right(`w2')
        if      c(stata_version)<17            local hopts
        else if d(`c(born_date)')<d(13jul2021) local hopts
        _coef_table_header, `hopts'
        local by = `"`e(by)'"'!=""
        if `by' {
            if `"`e(wtype)'"'=="fweight" local obs _W
            else                         local obs _N
            local balobs: di " (" el(e(`obs'),1,1) " obs)"
            local refobs: di " (" el(e(`obs'),1,2) " obs)"
            local w0 = max(strlen("`balobs'"), strlen("`refobs'"))
            local w0 = max(6,34-`w0')
            local balsamp = abbrev(e(balsamp),`w0')
            local refsamp = abbrev(e(refsamp),`w0')
            local w0 = max(strlen("`balsamp'"), strlen("`refsamp'"))
        }
        di as txt _col(`c1') "Balancing loss" _col(`c2') "= " /*
            */as res %10.0g e(loss)
        di as txt _col(`c1') "Loss type" _col(`c2') "= " /*
            */as res %10s e(ltype)
        if `by' di as txt "Sample    = " as res %-`w0's "`balsamp'" /*
            */ as txt "`balobs'" _c
        else    di "" _c
        di as txt _col(`c1') "CV of weights" _col(`c2') "= " /*
            */as res %10.0g e(cv)
        if `by' di as txt "Reference = " as res %-`w0's "`refsamp'" /*
            */ as txt "`refobs'" _c
        else    di "" _c
        if `by'==0 {
            local popsize = el(e(_W),1,2)
            local w0 = floor(log10(`popsize')) + floor(log10(`popsize')/3) + 3
            local w0 = min(24, max(10, `w0'))
            di as txt "Population size = " /*
                */as res %-`w0'.0gc `popsize' _c
        }
        di as txt _col(`c1') "DEFF of weights" _col(`c2') "= " /*
            */as res %10.0g e(deff)
    }
    if "`notable'"=="" {
        di ""
        ereturn display, `options'
    }
    if "`baltable'"!="" {
        di as txt _n "Balancing table"
        _matrix_table e(baltab), `baltable2'
    }
end

program Estimate, eclass
    // syntax
    syntax varlist(numeric fv) [if] [in] [fw iw pw/], [ ///
        by(varname numeric) swap POOLed POPulation(str) ///
        TARgets(str) ///
        BTOLerance(numlist max=1 >=0) ltype(name) ///
        ITERate(numlist integer max=1 >=0 <=16000) ///
        PTOLerance(numlist max=1 >=0) ///
        VTOLerance(numlist max=1 >=0) ///
        DIFficult NOLOG relax NOWARN ///
        vce(str) NOSE CLuster(varname) ///
        Generate(name) IFgenerate(passthru) Replace ]
    if `"`by'"'!="" {
        if `"`population'"'!="" {
            di as err "only one of by() and population() allowed"
            exit 198
        }
    }
    else if `"`population'"'!="" {
        if "`pooled'"!="" {
            di as err "pooled not allowed with population()"
            exit 198
        }
        local cpos = strpos(`"`population'"', ":")
        if `cpos' {
            local popsize = strtrim(substr(`"`population'"', 1, `cpos'-1))
            local popvals = substr(`"`population'"', `cpos'+1, .)
        }
        else {
            local popvals `"`population'"'
        }
        if `"`popsize'"'!="" {
            capt numlist `"`popsize'"', max(1) range(>0)
            if _rc==1 exit _rc
            if _rc {
                di as error "invalid {it:size} in {bf:population()}"
                exit 198
            }
        }
        if `"`popvals'"'!="" {
            capt numlist `"`popvals'"'
            if _rc==1 exit _rc
            if _rc {
                di as error "invalid {it:numlist} in {bf:population()}"
                exit 198
            }
        }
    }
    else {
        di as err "either by() or population() required"
        exit 198
    }
    Parse_ltype, `ltype'
    if "`replace'"=="" & "`generate'"!="" {
        confirm new var `generate'
    }
    Parse_ifgenerate, `ifgenerate' `replace'
    if "`cluster'"!="" {
        if `"`vce'"'!="" {
            di as err "vce() and cluster() not both allowed"
            exit 198
        }
        local vce cluster `cluster'
        local cluster
    }
    Parse_vce `vce'
    Parse_targets, `targets'
    if `targets' {
        Parse_expand_varlist `t_var' `t_cov' `t_sk' `varlist'
    }
    
    // sample and weights
    marksample touse
    if "`clustvar'"!="" {
        markout `touse' `clustvar', strok
    }
    if `"`by'"'!="" {
        markout `touse' `by'
        capt assert ((`by'==floor(`by')) & (`by'>=0)) if `touse'
        if _rc==1 exit _rc
        if _rc {
            di as err "variable in by() must be integer and nonnegative"
            exit 452
        }
        qui levelsof `by' if `touse', local(bylevels)
        if `: list sizeof bylevels'!=2 {
            di as err "variable in by() must identify exactly two groups"
            exit 498
        }
        if "`swap'"!="" {
            local by0: word 1 of `bylevels'
            local by1: word 2 of `bylevels'
        }
        else {
            local by1: word 1 of `bylevels'
            local by0: word 2 of `bylevels'
        }
        tempvar stag
        qui gen byte `stag' = `by'==`by1' & `touse'
    }
    if "`weight'"!="" {
        capt confirm variable `exp'
        if _rc==1 exit _rc
        if _rc {
            tempvar wvar
            qui gen double `wvar' = `exp' if `touse'
        }
        else {
            unab exp: `exp', min(1) max(1)
            local wvar `exp'
        }
        local wgt "[`weight'=`wvar']"
        local exp `"= `exp'"'
    }
    else local wvar 1
    _nobs `touse' `wgt', min(1)
    if "`weight'"=="iweight" {
        su `wvar' if `touse', meanonly
        local N = r(sum)
    }
    else {
        local N = r(N)
    }
    
    // expand factor variables
    fvexpand `varlist' if `touse'
    local varlist `r(varlist)'
    if `"`population'"'!="" {
        if `: list sizeof population' < `: list sizeof varlist' {
            di as error "too few values specified in {bf:population()}"
            exit 198
        }
    }
    
    // expand generate_stub, if necessary
    if "`ifgenerate_stub'"!="" {
        local ifgenerate
        forv i = 1/`=`:list sizeof varlist'+1' {
            if "`replace'"=="" confirm new variable `ifgenerate_stub'`i'
            local ifgenerate `ifgenerate' `ifgenerate_stub'`i'
        }
        local ifgenerate_stub
    }
    
    // estimate
    if "`generate'"!="" {
        tempname WVAR
        qui gen double `WVAR' = .
    }
    tempname b W LOSS BTAB CV DEFF _N _W
    mata: ebalfit()
    
    // returns
    local coln: colnames `b'
    if "`V'"!="" {
        mat coln `V' = `coln'
        mat rown `V' = `coln'
    }
    eret post `b' `V' [`weight'`exp'], obs(`N') esample(`touse')
    eret local cmd "ebalfit"
    eret local predict "ebalfit_p"
    eret local title "Entropy balancing"
    eret local varlist "`varlist'"
    eret scalar W = `W'
    eret scalar k_eq = 1
    eret scalar cv = `CV'
    eret scalar deff = `DEFF'
    eret scalar loss = `LOSS'
    eret local ltype "`ltype'"
    eret scalar iter = `iter'
    eret scalar converged = `converged'
    eret scalar balanced = `balanced'
    eret scalar btolerance = `btolerance'
    eret scalar ptolerance = `ptolerance'
    eret scalar vtolerance = `vtolerance'
    eret scalar maxiter = `iterate'
    eret local difficult "`difficult'"
    eret matrix baltab = `BTAB'
    eret matrix _N = `_N'
    eret matrix _W = `_W'
    if "`by'"!="" {
        eret local by `"`by'"'
        eret local balsamp "`by1'.`by'"
        if "`pooled'"!=""  eret local refsamp "pooled"
        else               eret local refsamp "`by0'.`by'"
    }
    if "`nose'"=="" {
        eret local vcetype "`vcetype'"
        eret local vce "`vce'"
        eret scalar df_m = `df_m'
        eret scalar rank = `rank'
        eret scalar chi2 = `chi2'
        eret scalar p = `chi2_p'
        if "`vce'"=="cluster" {
            eret local clustvar "`clustvar'"
            eret scalar N_clust = `N_clust'
        }
    }

    // generate
    if "`ifgenerate'"!="" {
        local vlist
        foreach IF of local IFs {
            gettoken nm coln : coln
            gettoken var ifgenerate : ifgenerate
            if "`var'"=="" continue, break
            capt confirm new variable `var'
            if _rc==1 exit _rc
            if _rc drop `var'
            lab var `IF' "IF of _b[`nm']"
            rename `IF' `var'
            local vlist `vlist' `var'
        }
        eret local ifgenerate "`vlist'"
    }
    if "`generate'"!="" {
        capt confirm new variable `generate'
        if _rc==1 exit _rc
        if _rc drop `generate'
        lab var `WVAR' "Balancing weights"
        rename `WVAR' `generate'
        eret local generate "`generate'"
    }
end

program Parse_targets
    capt n syntax [, Mean Variance Covariance Skewness ]
    if _rc {
        di as err "error in option {bf:targets()}"
        exit 198
    }
    if "`skewness'"!="" local variance variance
    c_local targets = "`mean'`variance'`covariance'`skewness'"!=""
    c_local t_var = "`variance'"!=""
    c_local t_cov = "`covariance'"!=""
    c_local t_sk  = "`skewness'"!=""
end

program Parse_expand_varlist
    gettoken var 0 : 0
    gettoken cov 0 : 0
    gettoken sk  0 : 0
    local terms
    foreach v of local 0 {
        local isfv 0
        local prefix = substr("`v'",1,2)
        if "`prefix'"=="i." {
            local isfv 1
            local v = substr("`v'",3,.)
        }
        else if "`prefix'"=="c." {
            local v = substr("`v'",3,.)
        }
        capt confirm variable `v'
        if _rc {
            di as err "invalid varlist ... targets()..."
            exit 198
        }
        if `isfv' local v "i.`v'"
        else      local v "c.`v'"
        local terms `terms' `v'
    }
    local vlist
    foreach v of local terms {
        local vlist `vlist' `v'
        if substr("`v'",1,2)=="i." continue
        if `var' {
            local vlist `vlist' `v'#`v'
        }
        if `sk' {
            local vlist `vlist' `v'#`v'#`v'
        }
    }
    if `cov' {
        local i 0
        foreach x of local terms {
            local ++i
            local j 0
            foreach y of local terms {
                local ++j
                if `i'==`j' continue, break
                local vlist `vlist' `x'#`y'
            }
        }
    }
    c_local varlist `vlist'
end

program Parse_ltype
    capt n syntax [, Reldif Absdif ]
    if _rc {
        di as err "error in option {bf:ltype()}"
        exit 198
    }
    c_local ltype `reldif' `absdif'
end

program Parse_ifgenerate
    syntax [, ifgenerate(str) replace ]
    if `"`ifgenerate'"'=="" {
        c_local ifgenerate
        exit
    }
    if substr(`"`ifgenerate'"', -1, 1)=="*" {
        local ifgenerate = substr(`"`ifgenerate'"', 1, strlen(`"`ifgenerate'"')-1)
        confirm name `ifgenerate'
        c_local ifgenerate_stub `ifgenerate'
        exit
    }
    local 0 `" , ifgenerate(`ifgenerate')"'
    syntax [, ifgenerate(namelist) ]
    c_local ifgenerate `ifgenerate'
    if "`replace'"!="" exit
    foreach v of local ifgenerate {
        confirm new var `v'
    }
end

program Parse_vce
    if `"`0'"'=="none" {
        c_local nose "nose"
        c_local vce
        c_local vcetype
        c_local clustvar
        exit
    }
    if `"`0'"'=="" | `"`0'"'==substr("robust", 1, strlen(`"`0'"')) {
        c_local vce "robust"
        c_local vcetype Robust
        c_local clustvar
        exit
    }
    else {
        gettoken vce arg : 0
        if `"`vce'"'==substr("cluster", 1, max(2,strlen(`"`vce'"'))) {
            local 0 `"`arg'"'
            capt n syntax varname
            if _rc==1 exit _rc
            if _rc {
                di as err "error in option {bf:vce()}"
                exit 198
            }
            c_local vce "cluster"
            c_local vcetype Robust
            c_local clustvar `varlist'
            exit
        }
    }
    di as err `"vce(`0') not allowed"'
    exit 198
end

version 14

// class/struct
local EB     class mm_ebalance scalar
// string
local SS     string scalar
local SR     string rowvector
local SC     string colvector
local SM     string matrix
local SV     string vector
// real
local RS     real scalar
local RC     real colvector
local RM     real matrix
// counters
local Int    real scalar
local IntC   real colvector
// boolean
local Bool   real scalar
local BoolC  real colvector
// transmorphic
local TC     transmorphic colvector

mata:
mata set matastrict on

void ebalfit()
{
    `EB'   S
    `SS'   touse
    `SR'   vlist, cnm
    `Bool' pop, pooled, hasw, nose, relax
    `IntC' p, pref
    `RC'   w, wref, wvar
    `RM'   X, Xref, IF
    pragma unset X
    pragma unset Xref
    pragma unset IF
    
    // data
    touse = st_local("touse")
    vlist = tokens(st_local("varlist"))
    st_view(X, ., vlist, touse)
    hasw = st_local("weight")!=""
    if (hasw) w = st_data(., st_local("wvar"), touse)
    else w = 1
    pop = st_local("population")!=""
    if (pop) {
        Xref = strtoreal(tokens(st_local("popvals")))
        if (cols(Xref)>cols(X)) Xref = Xref[|1 \ cols(X)|]
        if (st_local("popsize")!="") wref = strtoreal(st_local("popsize"))
        else wref = hasw ? quadsum(w) : rows(X) // use sample size
    }
    else {
        p = selectindex(st_data(., st_local("stag"), touse))
        if (length(p)==0) _error(3498, "subsample selected for reweighting is empty")
        pref = selectindex(st_data(., st_local("stag"), touse):==0)
        if (length(pref)==0) _error(3498, "reference sample is empty")
        pooled = st_local("pooled")!=""
        if (pooled) {
            st_subview(Xref, X, ., .)
            wref = w
        }
        else {
            st_subview(Xref, X, pref, .)
            if (hasw) wref = w[pref]
            else wref = 1
        }
        st_subview(X, X, p, .)
        if (hasw) w = w[p]
    }
    
    // settings for mm_ebalance()
    relax = st_local("relax")!=""
    if (st_local("nolog")!="") S.trace("none")
    if (relax) S.nowarn(st_local("nowarn")!="")
    else       S.nowarn(1)
    if (st_local("ltype")!="") S.ltype(st_local("ltype"))
    else st_local("ltype", S.ltype())
    if (st_local("btolerance")!="") S.btol(strtoreal(st_local("btolerance")))
    else st_local("btolerance", strofreal(S.btol()))
    if (st_local("ptolerance")!="") S.ptol(strtoreal(st_local("ptolerance")))
    else st_local("ptolerance", strofreal(S.ptol()))
    if (st_local("vtolerance")!="") S.ptol(strtoreal(st_local("vtolerance")))
    else st_local("vtolerance", strofreal(S.vtol()))
    if (st_local("iterate")!="") S.maxiter(strtoreal(st_local("iterate")))
    else st_local("iterate", strofreal(S.maxiter()))
    S.difficult(st_local("difficult")!="")
    
    // run mm_eblance()
    S.data(X, w, Xref, wref, 1)
    st_local("iter", strofreal(S.iter()))
    st_local("converged", strofreal(S.converged()))
    st_local("balanced", strofreal(S.balanced()))
    if (!relax) {
        if (S.converged()==0) exit(error(430))
        if (S.balanced()==0) {
            stata(`"di as err "balance not achieved""')
            exit(430)
        }
    }
    
    // store coefficients
    st_matrix(st_local("b"), (S.b()',S.a()))
    cnm = vlist
    if (S.k_omit()) _put_omit(cnm, S.omit())
    st_matrixcolstripe(st_local("b"), _cstripe(cnm' \ "_cons"))
    st_numscalar(st_local("LOSS"), S.loss())
    
    // sample sizes
    st_numscalar(st_local("W"), pooled ? S.Wref() : S.W()+S.Wref())
    st_matrix(st_local("_N"), (S.N(), S.Nref()))
    st_matrixcolstripe(st_local("_N"), _cstripe(("sample", "reference")'))
    st_matrix(st_local("_W"), (S.W(), S.Wref()))
    st_matrixcolstripe(st_local("_W"), _cstripe(("sample", "reference")'))
    
    // balancing table
    st_matrix(st_local("BTAB"), (S.m()', S.madj()', S.mref()', abs(S.madj()-S.mref())', reldif(S.madj(),S.mref())'))
    st_matrixrowstripe(st_local("BTAB"), _cstripe(vlist'))
    st_matrixcolstripe(st_local("BTAB"), _cstripe(("raw","adjusted","reference","absdif", "reldif")'))
    
    // balancing weights
    st_numscalar(st_local("CV"), sqrt(mm_variance0(S.wbal()))/mean(S.wbal()))
    st_numscalar(st_local("DEFF"), S.N() / (quadsum(S.wbal())^2 / quadsum(S.wbal():^2)))
    if (st_local("WVAR")!="") {
        if (pop) st_store(., st_local("WVAR"), touse, S.wbal())
        else {
            wvar = J(pooled ? S.Nref() : S.N()+S.Nref(), 1, .)
            wvar[p] = S.wbal()
            wvar[pref] = (hasw==0 ? J(rows(pref), 1, wref) : (pooled ? wref[pref] : wref))
            st_store(., st_local("WVAR"), touse, wvar)
        }
    }
    
    // influence functions and VCE
    nose = st_local("nose")!=""
    if (st_local("ifgenerate")!="" | nose==0) {
        _init_IF(IF, S.k()+1, touse)
        if (pop) {
            IF[.,.] = (S.IF_b(), S.IF_a())
        }
        else if (pooled) {
            IF[.,.] = (S.IFref_b(), S.IFref_a())
            IF[p,.] = IF[p,.] + (S.IF_b(), S.IF_a())
        }
        else {
            IF[pref,.] = (S.IFref_b(), S.IFref_a())
            IF[p,.]    = (S.IF_b(), S.IF_a())
        }
    }
    if (nose==0) _ebalfit_vce(IF, S.k()-S.k_omit(), S.b())
}

`SM' _cstripe(`SC' cn) return((J(rows(cn),1,""), cn))

void _put_omit(`SV' cn, `BoolC' omit)
{
    `Int' i
    
    i = length(cn)
    for (; i; i--) {
        if (omit[i]==0) continue
        stata("_ms_put_omit " + cn[i])
        cn[i] = st_global("s(ospec)")
    }
}

void _init_IF(`RM' IF, `Int' k, `SS' touse)
{
    `SR' vnm

    vnm = st_tempname(k)
    st_view(IF, ., st_addvar("double", vnm), touse)
    st_local("IFs", invtokens(vnm))
}

void _ebalfit_vce(`RM' IF, `Int' p, `RC' b)
{
    `SS'   touse, clust
    `Int'  N, N_clust
    `RS'   c, chi2
    `Bool' fw
    `RC'   w
    `RM'   V, X
    
    // variance matrix
    touse = st_local("touse")
    fw = st_local("weight")=="fweight"
    if (st_local("weight")=="") w = 1
    else w = st_data(., st_local("wvar"), touse)
    if (fw) N = sum(w)
    else    N = rows(IF)
    clust = st_local("clustvar")
    if (clust=="") {
        c = max((editmissing(N / (N-p-1), 0), 0))
        if (w==1)    V = c * cross(IF, IF)
        else if (fw) V = c * cross(IF, w, IF)
        else         V = c * cross(IF, w:^2, IF)
        _makesymmetric(V)
    }
    else {
         X = _ebalfit_vce_csum(IF, w, st_isstrvar(clust) ? 
             st_sdata(., clust, touse) : st_data(., clust, touse))
         N_clust = rows(X)
         c = max((editmissing((N_clust/(N_clust-1) * (N-1)/(N-p-1)),0),0))
         V = makesymmetric(c * cross(X, X))
         st_local("N_clust", strofreal(N_clust))
    }
    st_local("V", st_tempname())
    st_matrix(st_local("V"), V)
    st_local("rank", strofreal(rank(V)))
    
    // model test
    st_local("df_m", strofreal(p))
    chi2 = b' * invsym(V[|1,1 \ rows(V)-1,cols(V)-1|]) * b
    st_local("chi2", st_tempname())
    st_numscalar(st_local("chi2"), chi2)
    st_local("chi2_p", st_tempname())
    st_numscalar(st_local("chi2_p"), chi2tail(p, chi2))
} 

`RM' _ebalfit_vce_csum(`RM' X, `RC' w, `TC' C)
{   // aggregate X*w by clusters
    `Int' i, a, b
    `RC'  p, nc
    `RM'  S
    
    if (rows(w)!=1) p = mm_order(C, 1, 1) // stable sort
    else            p = order(C, 1)
    nc = selectindex(_mm_unique_tag(C[p])) // tag first obs in each cluster
    i  = rows(nc)
    S  = J(i, cols(X), .)
    a  = rows(C) + 1
    if (rows(w)==1) {
        for (;i;i--) {
            b = a - 1
            a = nc[i]
            S[i,.] = cross(w, X[p[|a\b|],.]) 
        }
    }
    else {
        for (;i;i--) {
            b = a - 1
            a = nc[i]
            S[i,.] = cross(w[p[|a\b|]], X[p[|a\b|],.])
        }
    }
    return(S)
}

end

exit
