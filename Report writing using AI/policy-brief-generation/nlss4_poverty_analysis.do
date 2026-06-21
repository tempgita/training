version 18.0
clear all
set more off
set linesize 120
set scheme s2color

capture mkdir "output"
capture mkdir "output/figures"
capture mkdir "output/results"

/*
  NLSS IV poverty dynamics: complete replication program
  Inputs: poverty.dta (the supplied weight/poverty file) and S01.dta
  Unit of analysis: household. Person estimates use hhs_wt * hhsize.
*/

* Extract the sex of the unique household head.
use "S01.dta", clear
keep if q01_04 == 1
isid psu_number hh_number
keep psu_number hh_number q01_02
rename q01_02 head_gender
label variable head_gender "Sex of household head"
tempfile heads
save `heads'

* Merge head characteristics into the poverty/weight file.
use "poverty.dta", clear
isid psu_number hh_number
merge 1:1 psu_number hh_number using `heads', assert(match) nogen
assert poor == (pcep < pline)
assert abs(ind_wt - hhs_wt * hhsize) < .1

generate byte urban = inlist(ad_4, 1, 2)
label define urban_lab 0 "Rural" 1 "Urban"
label values urban urban_lab
label variable urban "Urban/rural residence"

tempfile analysis
save `analysis'

* Weighted Gini from the trapezoidal area under the Lorenz curve.
capture program drop weighted_gini
program define weighted_gini, rclass
    syntax varname, Wvar(varname)
    preserve
        keep `varlist' `wvar'
        drop if missing(`varlist', `wvar') | `wvar' <= 0
        sort `varlist'
        quietly generate double __wx = `wvar' * `varlist'
        quietly summarize `wvar', meanonly
        local W = r(sum)
        quietly summarize __wx, meanonly
        local Y = r(sum)
        quietly generate double __L = sum(__wx) / `Y'
        quietly generate double __L0 = __L[_n-1]
        quietly replace __L0 = 0 in 1
        quietly generate double __area2 = (__L + __L0) * (`wvar' / `W')
        quietly summarize __area2, meanonly
        return scalar gini = 1 - r(sum)
        return scalar N = _N
    restore
end

tempname results_post
tempfile results
postfile `results_post' str24 section str48 group int display_order ///
    long sample_households double households persons hc_household hc_individual gini ///
    using `results', replace
global NLSS_RESULTS_POST `results_post'

capture program drop post_estimate
program define post_estimate
    syntax, Section(string) Group(string) Order(integer) Condition(string)
    preserve
        quietly keep if `condition'
        quietly count
        local n = r(N)
        quietly summarize hhs_wt, meanonly
        local households = r(sum)
        quietly summarize ind_wt, meanonly
        local persons = r(sum)
        quietly summarize poor [aw=hhs_wt], meanonly
        local hc_hh = r(mean)
        quietly summarize poor [aw=ind_wt], meanonly
        local hc_ind = r(mean)
        quietly weighted_gini pcep, wvar(ind_wt)
        local gini = r(gini)
        post $NLSS_RESULTS_POST ("`section'") ("`group'") (`order') (`n') ///
            (`households') (`persons') (`hc_hh') (`hc_ind') (`gini')
    restore
end

use `analysis', clear
post_estimate, section("National") group("Nepal") order(1) condition("1")

foreach u in 1 0 {
    local ulab : label urban_lab `u'
    local ord = cond(`u' == 1, 1, 2)
    post_estimate, section("Urban/rural") group("`ulab'") order(`ord') condition("urban == `u'")
}

foreach g in 1 2 {
    local glab : label Q01_02_VS1 `g'
    post_estimate, section("Head gender") group("`glab'") order(`g') condition("head_gender == `g'")
}

levelsof domain, local(domains)
local ord = 0
foreach d of local domains {
    local ++ord
    local dlab : label domainlab `d'
    post_estimate, section("Analytical domain") group("`dlab'") order(`ord') condition("domain == `d'")
}
postclose `results_post'
macro drop NLSS_RESULTS_POST

use `results', clear
sort section display_order
format households persons %15.0fc
format hc_household hc_individual gini %9.6f
export delimited using "output/results/poverty_results.csv", replace
save "output/results/poverty_results.dta", replace

* Chart 1: National person-weighted Lorenz curve.
use `analysis', clear
sort pcep
generate double __wx = ind_wt * pcep
quietly summarize ind_wt, meanonly
generate double population_share = sum(ind_wt) / r(sum)
quietly summarize __wx, meanonly
generate double consumption_share = sum(__wx) / r(sum)
local newN = _N + 1
set obs `newN'
replace population_share = 0 in `newN'
replace consumption_share = 0 in `newN'
sort population_share
twoway (line consumption_share population_share, sort lcolor(navy) lwidth(medthick)) ///
       (function y=x, range(0 1) lcolor(gs8) lpattern(dash)), ///
       title("Lorenz curve of real per-capita consumption") ///
       subtitle("Nepal, NLSS IV; person-weighted") ///
       xtitle("Cumulative share of persons") ytitle("Cumulative share of consumption") ///
       xlabel(0(.2)1, format(%3.1f)) ylabel(0(.2)1, format(%3.1f) angle(horizontal)) ///
       legend(order(1 "Lorenz curve" 2 "Line of equality") rows(1)) ///
       graphregion(color(white)) plotregion(color(white)) name(lorenz, replace)
graph export "output/figures/lorenz_curve.svg", replace
export delimited population_share consumption_share using ///
    "output/results/lorenz_coordinates.csv", replace

* Chart 2: Individual poverty headcount by analytical domain.
use "output/results/poverty_results.dta", clear
keep if section == "Analytical domain"
generate double hc_percent = 100 * hc_individual
graph hbar (asis) hc_percent, over(group, sort(1) descending label(labsize(small))) ///
    title("Poverty prevalence varies sharply across Nepal") ///
    subtitle("Individual headcount ratio by analytical domain (%)") ///
    ytitle("Percent of persons below the poverty line") ///
    ylabel(0(5)35, angle(horizontal)) blabel(bar, format(%4.1f) size(vsmall)) ///
    bar(1, color(navy)) graphregion(color(white)) plotregion(color(white)) ///
    name(domain_poverty, replace)
graph export "output/figures/domain_poverty.svg", replace

* Chart 3: Poverty and inequality by urban/rural residence.
use "output/results/poverty_results.dta", clear
keep if section == "Urban/rural"
generate double hc_percent = 100 * hc_individual
graph bar (asis) hc_percent, over(group) ///
    title("Rural and urban poverty prevalence") ///
    subtitle("Individual headcount ratio (%)") ytitle("Percent") ///
    ylabel(0(5)30, angle(horizontal)) blabel(bar, format(%4.1f)) ///
    bar(1, color(navy)) graphregion(color(white)) plotregion(color(white)) ///
    name(urban_poverty, replace)
graph export "output/figures/urban_rural_poverty.svg", replace

display as result "Analysis complete. Results are in output/results and figures in output/figures."
exit, clear
