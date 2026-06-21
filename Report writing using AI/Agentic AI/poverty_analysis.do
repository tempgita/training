*****************************************************************************
* File:        poverty_analysis.do
* Purpose:     Estimate the represented populations of households and people
*              by summing the survey expansion weights in poverty.dta.
* Software:    Stata 18 (the commands also work in recent earlier versions).
* Input:       poverty.dta, located in the current working directory.
* Output:      poverty_results.log, a plain-text execution and results log.
*****************************************************************************

* Remove any data, stored estimates, and other objects left in memory.
clear all

* Prevent Stata from pausing output and waiting for a key press in batch runs.
set more off

* Close an existing log if this script is rerun in the same Stata session.
capture log close

* Record all commands and results in a reproducible plain-text log file.
log using "poverty_results.log", text replace

* Load the household-level analytical dataset; clear permits memory replacement.
use "poverty.dta", clear

* Verify the expected number of sampled household records has not changed.
assert _N == 9600

* Confirm PSU number plus household number uniquely identifies every household.
* This guards against counting duplicated household records in either total.
isid psu_number hh_number

* Confirm all variables needed for the two population estimates are observed.
* A missing weight or household size would otherwise make a record incomplete.
assert !missing(hhs_wt, ind_wt, hhsize)

* Expansion weights and household sizes must be strictly positive by definition.
assert hhs_wt > 0
assert ind_wt > 0
assert hhsize > 0

* Verify the supplied person expansion value equals the adjusted household
* expansion weight multiplied by household size, allowing only float rounding.
assert reldif(ind_wt, hhs_wt * hhsize) < 1e-6

* Sum hhs_wt across household records. Each sampled household contributes its
* census-adjusted expansion weight, i.e., represented households in population.
egen double weighted_households = total(hhs_wt)

* Sum ind_wt across the same records. Since ind_wt = hhs_wt * hhsize, each
* household contributes the number of represented people, not merely one case.
egen double weighted_individuals = total(ind_wt)

* Store each constant total as a scalar so it can be displayed cleanly.
scalar N_households = weighted_households[1]
scalar N_individuals = weighted_individuals[1]

* Display the raw full-precision totals for machine-readable reproducibility.
display as text "Weighted household population (raw): " ///
    as result %21.9f scalar(N_households)
display as text "Weighted individual population (raw): " ///
    as result %21.9f scalar(N_individuals)

* Display rounded counts because populations of households and people are
* ordinarily communicated as whole units rather than fractional expansions.
display as text "Weighted household population (rounded): " ///
    as result %15.0fc round(scalar(N_households))
display as text "Weighted individual population (rounded): " ///
    as result %15.0fc round(scalar(N_individuals))

* Report the implied population-average household size as a consistency aid.
scalar average_household_size = N_individuals / N_households
display as text "Implied average household size: " ///
    as result %9.3f scalar(average_household_size)

* Remove generated working variables; the source file itself is never changed.
drop weighted_households weighted_individuals

* Close the results log and terminate cleanly when the file is run in batch mode.
log close
exit, clear
