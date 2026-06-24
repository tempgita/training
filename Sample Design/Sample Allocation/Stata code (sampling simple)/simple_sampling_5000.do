* ==============================================================================
* SIMPLE SAMPLING EXAMPLES WITH 5,000 SIMULATED RECORDS
* ==============================================================================
* This file creates a fake population of 5,000 units and demonstrates:
*   1. Simple random sampling
*   2. Systematic sampling
*   3. Stratified proportional sampling
*   4. One-stage cluster sampling
*   5. Unequal probability sampling
*
* Output files are saved in the output folder.
* ==============================================================================

version 16.0
clear all
set more off
set seed 24062026

capture mkdir "output"

* ------------------------------------------------------------------------------
* 1. Create a simulated population of 5,000 units
* ------------------------------------------------------------------------------
set obs 5000
gen long id = _n

* Five strata with fixed sizes.
gen byte region = .
replace region = 1 if inrange(id,    1,  500)
replace region = 2 if inrange(id,  501, 1500)
replace region = 3 if inrange(id, 1501, 2750)
replace region = 4 if inrange(id, 2751, 4250)
replace region = 5 if inrange(id, 4251, 5000)

label define region_lbl 1 "Mountain" 2 "Hill rural" 3 "Hill urban" ///
                        4 "Terai rural" 5 "Terai urban"
label values region region_lbl

* Clusters are groups of 25 records, giving 200 clusters.
gen int cluster = ceil(id / 25)

* Simulated variables for analysis.
gen byte female = runiform() < 0.52
gen byte urban  = inlist(region, 3, 5)
gen double income = 25000 + 3500*region + 8000*urban + 2500*female + rnormal(0, 9000)
replace income = max(income, 5000)

save "output/simulated_population_5000.dta", replace

* We will store a small summary from each sampling design.
tempfile sample_summary selected_clusters
postfile results str35 design int n double mean_income using `sample_summary', replace

* ------------------------------------------------------------------------------
* 2. Simple random sample: select exactly 500 records
* ------------------------------------------------------------------------------
preserve
    sample 500, count
    summarize income
    post results ("Simple random sample") (r(N)) (r(mean))
    save "output/sample_srs_500.dta", replace
restore

* ------------------------------------------------------------------------------
* 3. Systematic sample: choose every 10th record after a random start
* ------------------------------------------------------------------------------
preserve
    sort id
    scalar interval = _N / 500
    scalar start = ceil(runiform() * interval)
    keep if mod(_n - start, interval) == 0
    summarize income
    post results ("Systematic sample") (r(N)) (r(mean))
    save "output/sample_systematic_500.dta", replace
restore

* ------------------------------------------------------------------------------
* 4. Stratified proportional sample: take 10 percent from each region
* ------------------------------------------------------------------------------
preserve
    gen double u = runiform()
    sort region u
    by region: gen long rank_in_region = _n
    by region: gen long n_region = _N
    keep if rank_in_region <= round(0.10 * n_region)
    summarize income
    post results ("Stratified proportional sample") (r(N)) (r(mean))
    save "output/sample_stratified_500.dta", replace
restore

* ------------------------------------------------------------------------------
* 5. One-stage cluster sample: select 20 clusters and keep all records in them
* ------------------------------------------------------------------------------
preserve
    keep cluster
    duplicates drop
    gen double u = runiform()
    sort u
    keep in 1/20
    gen byte selected_cluster = 1
    save `selected_clusters', replace
restore

preserve
    merge m:1 cluster using `selected_clusters', nogen
    keep if selected_cluster == 1
    summarize income
    post results ("One-stage cluster sample") (r(N)) (r(mean))
    save "output/sample_cluster_500.dta", replace
restore

* ------------------------------------------------------------------------------
* 6. Unequal probability sample: urban records are sampled at a higher rate
* ------------------------------------------------------------------------------
preserve
    gen double p_select = cond(urban == 1, 0.15, 0.08)
    keep if runiform() < p_select
    gen double design_weight = 1 / p_select
    summarize income
    post results ("Unequal probability sample") (r(N)) (r(mean))
    save "output/sample_unequal_probability.dta", replace
restore

postclose results

* ------------------------------------------------------------------------------
* 7. Display and save summary table
* ------------------------------------------------------------------------------
use `sample_summary', clear
format mean_income %12.2f
list, noobs abbreviate(24)
save "output/simple_sampling_summary.dta", replace
export delimited using "output/simple_sampling_summary.csv", replace

display as text "Done. Data and sample files are in the output folder."
