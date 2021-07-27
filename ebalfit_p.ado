*! version 1.0.0  27jul2021  Ben Jann

program ebalfit_p
    if `"`e(cmd)'"'!="ebalfit" {
        di as err "last ebalfit results not found"
        exit 301
    }
    syntax [anything] [if] [in], [ IFs ]
    if `"`if'`in'"'!="" local iff `if' `in'
    else                local iff if e(sample)
    if "`ifs'"=="" {
        syntax newvarname [if] [in]
        tempname z
        qui _predict double `z' `iff', xb nolabel
        if `"`e(by)'"'!="" {
            local byval = substr(e(balsamp),1,strpos(e(balsamp),".")-1)
            qui replace `z' = 0 if `e(by)'!=`byval' & `z'<.
        }
        if `"`e(wtype)'"'!="" {
            tempname w0
            qui gen double `w0' `e(wexp)' `iff'
            gen `typlist' `varlist' = `w0' * exp(`z') `iff'
        }
        else {
            gen `typlist' `varlist' = exp(`z') `iff'
        }
        lab var `varlist' "Balancing weights"
        exit
    }
    tempname touse
    qui gen byte `touse' = e(sample)==1
    if `"`e(by)'"'!="" {
        local byval = substr(e(balsamp),1,strpos(e(balsamp),".")-1)
        tempname touse1 touse0
        qui gen byte `touse1' = `e(by)'==`byval' & `touse'
        if `"`e(refsamp)'"'=="pooled" local touse0 `touse'
        else {
            qui gen byte `touse0' = `touse1'==0 & `touse'
        }
    }
    else {
        local touse1 `touse'
        local touse0 `touse'
    }
    if `"`e(wtype)'"'!="" {
        tempname w0
        qui gen double `w0' `e(wexp)' if `touse'
    }
    mata: ebalfit_p_IFs()
    capt syntax newvarlist [if] [in]
    if _rc==1 exit _rc
    if _rc {
        tempname b
        mat `b' = e(b)
        mata: st_local("coleq", ///
            invtokens("eq":+strofreal(1..cols(st_matrix("e(b)")))))
        mat coleq `b' = `coleq'
        _score_spec `anything', scores b(`b')
        local varlist `s(varlist)'
        local typlist `s(typlist)'
    }
    local coln: colnames e(b)
    foreach v of local varlist {
        gettoken typ typlist : typlist
        gettoken lbl coln : coln
        gettoken IF IFs : IFs
        if "`IF'"=="" continue, break
        qui gen `typ' `v' = cond(e(sample), `IF', 0) `iff'
        lab var `v' `"IF of _b[`lbl']"'
    }
end

version 14

mata:
mata set matastrict on

void ebalfit_p_IFs()
{
    real scalar      k, pop, pooled, Wref
    real colvector   b, w, wbal
    real rowvector   mref, madj
    real matrix      X, Xref
    string rowvector xvars, IFs
    string scalar    touse, touse1, touse0
    struct _mm_ebalance_IF scalar IF
    pragma unset X
    pragma unset Xref
    
    // collect info
    touse  = st_local("touse")
    touse1 = st_local("touse1")
    touse0 = st_local("touse0")
    madj = st_matrix("e(baltab)")[,2]'
    mref = st_matrix("e(baltab)")[,3]'
    Wref = st_matrix("e(_W)")[1,2]
    pop = st_global("e(by)")==""
    pooled = st_global("e(refsamp)")=="pooled"
    xvars = tokens(st_global("e(varlist)"))
    st_view(X, ., xvars, touse) // read full data matrix first
    if (st_local("w0")!="") w = st_data(., st_local("w0"), touse1)
    else                    w = 1
    if (pop) {
        Xref = mref
    }
    else if (pooled) {
        st_subview(Xref, X, ., .)
        st_subview(X, X, selectindex(st_data(., touse1, touse)), .)
    }
    else {
        st_subview(Xref, X, selectindex(st_data(., touse0, touse)), .)
        st_subview(X, X, selectindex(st_data(., touse1, touse)), .)
    }
    b = st_matrix("e(b)")'
    k = rows(b)
    wbal = w :* exp(X*b[|1\k-1|] :+ b[k])
    
    // prepare tempvars
    IFs = st_tempname(k)
    (void) st_addvar("double", IFs)
    st_local("IFs", invtokens(IFs))
    
    // compute IFs
    _mm_ebalance_IF_b(IF, X, Xref, w, wbal, mref)
    _mm_ebalance_IF_a(IF, madj, w, wbal, Wref)
    
    // copy IFs to tempvars
    if (pop) st_store(., IFs, touse, (IF.b, IF.a))
    else {
        st_store(., IFs, touse0, (IF.b0, IF.a0))
        
        if (pooled) st_store(., IFs, touse1,
            st_data(., IFs, touse1) + (IF.b, IF.a))
        else st_store(., IFs, touse1, (IF.b, IF.a))
    }
}

end

exit
