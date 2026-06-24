* ==============================================================================
* SAMPLE ALLOCATION AND SAMPLING EXAMPLES USING A SIMULATED POPULATION
* ==============================================================================
* Purpose:
*   1. Build a reproducible simulated population frame of 300,000 units.
*   2. Save that frame as a Stata .dta file.
*   3. Demonstrate common sample allocation and sampling designs in Stata.
*   4. Produce a self-contained HTML report styled like a Jupyter notebook, with
*      code cells followed immediately by result tables.
*
* Guidebook basis:
*   This do-file follows the sample allocation concepts in
*   "Sample allocation guidebook.pdf": equal allocation, proportional allocation,
*   Neyman allocation, power/square-root allocation, cost-constrained allocation,
*   minimum sample floors, design weights, sample selection, and svyset.
*
* Outputs:
*   output/simulated_population_300000.dta
*   output/allocation_results.dta
*   output/sampling_frame_with_flags.dta
*   output/sampling_examples_notebook.html
*
* Requirements:
*   Stata 16 or newer should run this file. No user-written packages are required.
* ==============================================================================

version 16.0
clear all
set more off
set seed 20830310

capture mkdir "output"

* ------------------------------------------------------------------------------
* User-adjustable design parameters
* ------------------------------------------------------------------------------
local N_population = 300000
local n_total      = 1200
local q_power      = 0.5
local n_min        = 30

* ==============================================================================
* Helper program: largest remainder rounding
* ==============================================================================
* Allocation formulas usually produce decimal sample sizes. The largest remainder
* method floors all allocations, then gives the remaining sample units to strata
* with the largest decimal remainders. This guarantees that the integer allocation
* sums exactly to the requested national sample size.
capture program drop largest_remainder
program define largest_remainder
    syntax varname(numeric), Generate(name) Total(integer)

    tempvar base rem rank add
    quietly {
        gen long `base' = floor(`varlist')
        gen double `rem' = `varlist' - `base'
        summarize `base', meanonly
        local shortfall = `total' - r(sum)

        gen byte `add' = 0
        if `shortfall' > 0 {
            egen long `rank' = rank(-`rem'), unique
            replace `add' = 1 if `rank' <= `shortfall'
        }
        gen long `generate' = `base' + `add'
    }
end

* ==============================================================================
* STEP 1. Create a simulated 300,000-unit population frame
* ==============================================================================
* The stratum structure is scaled from the guidebook's 5-stratum example:
*   Mountain Rural, Hill Rural, Hill Urban, Terai Rural, Terai Urban.
* The simulated population is treated as a household/person frame for sampling
* demonstrations. Each row is one population unit eligible for selection.
clear
input byte stratum str18 stratum_name long N_h double S_h double unit_cost double base_income
1 "Mountain Rural"  12632 12 8000 28000
2 "Hill Rural"      53684 15 4000 34000
3 "Hill Urban"      41053 22 3000 52000
4 "Terai Rural"    123158 18 2500 40000
5 "Terai Urban"     69473 28 2000 65000
end

summarize N_h, meanonly
assert r(sum) == `N_population'

expand N_h
bysort stratum: gen long unit_in_stratum = _n
gen long pop_id = _n
order pop_id stratum stratum_name

* Create artificial primary sampling units (PSUs). Each PSU is roughly 50 units.
bysort stratum: gen long psu_in_stratum = ceil(unit_in_stratum / 50)
egen long psu = group(stratum psu_in_stratum)
bysort psu: gen int psu_size = _N

* Simulated analysis variables. The stratum-level income standard deviations are
* intentionally tied to S_h from the guidebook, measured here in NPR thousands.
gen byte urban = inlist(stratum, 3, 5)
gen byte female = (runiform() < 0.51)
gen byte employed = (runiform() < cond(urban, 0.68, 0.59))
gen byte household_size = ceil(runiform() * 6)
replace household_size = household_size + 1 if stratum == 1 & runiform() < 0.25
gen double income = base_income + (S_h * 1000 * rnormal())
replace income = 5000 + 2000 * runiform() if income < 5000
gen double consumption = 0.72 * income + 3000 * household_size + 5000 * runiform()
label var pop_id "Population unit identifier"
label var stratum "Sampling stratum"
label var stratum_name "Sampling stratum name"
label var psu "Primary sampling unit"
label var income "Simulated monthly income"
label var consumption "Simulated monthly consumption"

compress
save "output/simulated_population_300000.dta", replace

* ==============================================================================
* STEP 2. Compute allocation methods from the guidebook
* ==============================================================================
preserve
keep stratum stratum_name N_h S_h unit_cost
duplicates drop
sort stratum

gen double W_h = N_h / `N_population'
gen double raw_equal   = `n_total' / _N
gen double raw_prop    = `n_total' * W_h
gen double NhSh        = N_h * S_h
summarize NhSh, meanonly
gen double raw_neyman  = `n_total' * NhSh / r(sum)
gen double Nh_q        = N_h ^ `q_power'
summarize Nh_q, meanonly
gen double raw_power   = `n_total' * Nh_q / r(sum)
gen double NhSh_cost   = N_h * S_h / sqrt(unit_cost)
summarize NhSh_cost, meanonly
gen double raw_cost    = `n_total' * NhSh_cost / r(sum)

largest_remainder raw_equal,  generate(n_equal)  total(`n_total')
largest_remainder raw_prop,   generate(n_prop)   total(`n_total')
largest_remainder raw_neyman, generate(n_neyman) total(`n_total')
largest_remainder raw_power,  generate(n_power)  total(`n_total')
largest_remainder raw_cost,   generate(n_cost)   total(`n_total')

* Minimum-floor adjustment for cost-constrained allocation. Any stratum below
* n_min is fixed at n_min; the remaining sample is reallocated by the original
* cost priority measure until all strata meet the floor.
gen double raw_cost_floor = raw_cost
gen byte floor_fixed = 0
local done = 0
while `done' == 0 {
    replace floor_fixed = 1 if raw_cost_floor < `n_min'
    summarize floor_fixed, meanonly
    local fixed_n = r(sum) * `n_min'
    summarize NhSh_cost if floor_fixed == 0, meanonly
    local free_sum = r(sum)
    replace raw_cost_floor = `n_min' if floor_fixed == 1
    replace raw_cost_floor = (`n_total' - `fixed_n') * NhSh_cost / `free_sum' if floor_fixed == 0
    count if raw_cost_floor < `n_min' & floor_fixed == 0
    if r(N) == 0 local done = 1
}
largest_remainder raw_cost_floor, generate(n_cost_floor) total(`n_total')

foreach v in equal prop neyman power cost cost_floor {
    gen double f_`v' = n_`v' / N_h
    gen double w_`v' = N_h / n_`v'
}

label var n_equal "Equal allocation"
label var n_prop "Proportional allocation"
label var n_neyman "Neyman optimal allocation"
label var n_power "Power allocation, q = 0.5"
label var n_cost "Cost-constrained allocation"
label var n_cost_floor "Cost-constrained allocation with minimum floor"

save "output/allocation_results.dta", replace
restore

* ==============================================================================
* STEP 3. Draw example samples from the simulated population
* ==============================================================================
use "output/simulated_population_300000.dta", clear
merge m:1 stratum using "output/allocation_results.dta", nogen

* 3.1 Simple random sampling without replacement: same probability for every unit.
gen double rand_srs = runiform()
sort rand_srs
gen byte sample_srs = (_n <= `n_total')

* 3.2 Systematic sampling: select every kth unit after a random start.
sort pop_id
local k = floor(_N / `n_total')
local start = ceil(runiform() * `k')
gen byte sample_systematic = (mod(pop_id - `start', `k') == 0)

* 3.3-3.8 Stratified sampling using the guidebook allocation methods.
foreach method in equal prop neyman power cost cost_floor {
    gen double rand_`method' = runiform()
    bysort stratum (rand_`method'): gen long rank_`method' = _n
    gen byte sample_`method' = (rank_`method' <= n_`method')
}

* 3.9 One-stage cluster sampling: select PSUs and include every unit inside them.
preserve
keep psu psu_size
duplicates drop
gen double rand_cluster = runiform()
sort rand_cluster
gen byte selected_cluster = (_n <= 24)
tempfile selected_clusters
save `selected_clusters', replace
restore
merge m:1 psu using `selected_clusters', keep(master match) nogen
replace selected_cluster = 0 if missing(selected_cluster)
gen byte sample_cluster = selected_cluster

* 3.10 Two-stage cluster sampling: select PSUs, then select 10 units in each PSU.
preserve
keep psu psu_size
duplicates drop
gen double rand_twostage_psu = runiform()
sort rand_twostage_psu
gen byte selected_twostage_psu = (_n <= 120)
tempfile selected_twostage_psus
save `selected_twostage_psus', replace
restore
merge m:1 psu using `selected_twostage_psus', keep(master match) nogen
replace selected_twostage_psu = 0 if missing(selected_twostage_psu)
gen double rand_twostage_unit = runiform()
bysort psu (rand_twostage_unit): gen long rank_twostage_unit = _n
gen byte sample_twostage = (selected_twostage_psu == 1 & rank_twostage_unit <= 10)

* Define example design weights for the allocation-based stratified samples.
* The same stratum-level weight applies to every selected unit in a given
* allocation method. We store it on every row so svyset can be declared without
* an if qualifier; analyses can then be restricted to the relevant sample flag.
foreach method in equal prop neyman power cost cost_floor {
    gen double weight_`method' = N_h / n_`method'
}

svyset pop_id [pweight = weight_prop], strata(stratum)

compress
save "output/sampling_frame_with_flags.dta", replace

* ==============================================================================
* STEP 4. Build result datasets used by the HTML notebook
* ==============================================================================
tempfile pop_summary sample_summary sample_by_stratum

use "output/simulated_population_300000.dta", clear
collapse (count) N=pop_id (mean) mean_income=income mean_consumption=consumption ///
    (sd) sd_income=income, by(stratum stratum_name)
save `pop_summary', replace

use "output/sampling_frame_with_flags.dta", clear
postfile smry str22 method long selected double mean_income double weighted_income ///
    double min_weight double max_weight using `sample_summary', replace

foreach method in srs systematic cluster twostage {
    quietly count if sample_`method' == 1
    local selected = r(N)
    quietly summarize income if sample_`method' == 1, meanonly
    local mean_income = r(mean)
    post smry ("`method'") (`selected') (`mean_income') (.) (.) (.)
}

foreach method in equal prop neyman power cost cost_floor {
    quietly count if sample_`method' == 1
    local selected = r(N)
    quietly summarize income if sample_`method' == 1, meanonly
    local mean_income = r(mean)
    quietly summarize income [aw=weight_`method'] if sample_`method' == 1, meanonly
    local weighted_income = r(mean)
    quietly summarize weight_`method' if sample_`method' == 1, meanonly
    local min_weight = r(min)
    local max_weight = r(max)
    post smry ("`method'") (`selected') (`mean_income') (`weighted_income') (`min_weight') (`max_weight')
}
postclose smry

use "output/sampling_frame_with_flags.dta", clear
postfile bys str22 method byte stratum str18 stratum_name long selected using `sample_by_stratum', replace
foreach method in srs systematic equal prop neyman power cost cost_floor cluster twostage {
    forvalues h = 1/5 {
        quietly count if sample_`method' == 1 & stratum == `h'
        local selected = r(N)
        quietly levelsof stratum_name if stratum == `h', local(sname)
        local sname_clean : subinstr local sname `"""' "", all
        post bys ("`method'") (`h') ("`sname_clean'") (`selected')
    }
}
postclose bys

* ==============================================================================
* STEP 5. Write the self-contained Jupyter-style HTML notebook
* ==============================================================================
local html "output/sampling_examples_notebook.html"
file open html using "`html'", write replace

file write html "<!doctype html>" _n
file write html "<html><head><meta charset='utf-8'><title>Sample allocation and sampling examples</title>" _n
file write html "<style>" _n
file write html "body{margin:0;background:#f5f6f8;color:#111827;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Arial,sans-serif;}" _n
file write html ".page{max-width:1120px;margin:0 auto;padding:28px 24px 60px;}" _n
file write html "h1{font-size:30px;margin:10px 0 8px;} h2{font-size:23px;margin:34px 0 10px;border-bottom:1px solid #d8dee9;padding-bottom:8px;} h3{font-size:18px;margin:24px 0 8px;}" _n
file write html "p{line-height:1.55;margin:8px 0 14px;} .note{background:#fff;border:1px solid #d8dee9;border-left:5px solid #4c78a8;border-radius:6px;padding:12px 14px;margin:14px 0;}" _n
file write html ".cell{background:#fff;border:1px solid #d8dee9;border-radius:6px;margin:16px 0 22px;overflow:hidden;box-shadow:0 1px 2px rgba(0,0,0,.04);}" _n
file write html ".prompt{float:left;width:82px;color:#2563eb;font-family:Consolas,Menlo,monospace;font-size:13px;padding:13px 0;text-align:right;}" _n
file write html ".input,.output{margin-left:96px;padding:12px 16px;border-left:1px solid #edf0f5;}" _n
file write html ".output{border-top:1px solid #edf0f5;background:#fcfcfd;} pre{margin:0;white-space:pre-wrap;font-family:Consolas,Menlo,monospace;font-size:13px;line-height:1.45;}" _n
file write html "table{border-collapse:collapse;width:100%;font-size:13px;margin:4px 0 8px;} th,td{border:1px solid #d8dee9;padding:7px 8px;text-align:right;} th{background:#eef2f7;font-weight:600;} td:first-child,th:first-child{text-align:left;} .small{font-size:12px;color:#4b5563;}" _n
file write html "</style></head><body><main class='page'>" _n
file write html "<h1>Sample Allocation and Sampling Examples in Stata</h1>" _n
file write html "<p>This notebook-style report was generated by <code>sample_allocation_simulation.do</code>. It uses a simulated population of 300,000 units and demonstrates the allocation methods described in the guidebook, followed by common sampling designs.</p>" _n
file write html "<div class='note'><strong>Files created:</strong> <code>output/simulated_population_300000.dta</code>, <code>output/allocation_results.dta</code>, <code>output/sampling_frame_with_flags.dta</code>.</div>" _n

* Population summary section
file write html "<h2>1. Simulated Population Frame</h2>" _n
file write html "<div class='cell'><div class='prompt'>In [1]:</div><div class='input'><pre>clear" _n
file write html "set seed 20830310" _n
file write html "input byte stratum str18 stratum_name long N_h double S_h double unit_cost double base_income" _n
file write html "expand N_h" _n
file write html "generate income = base_income + (S_h * 1000 * rnormal())" _n
file write html "save ""output/simulated_population_300000.dta"", replace</pre></div>" _n
file write html "<div class='output'><table><thead><tr><th>Stratum</th><th>Name</th><th>Population</th><th>Mean income</th><th>Income SD</th><th>Mean consumption</th></tr></thead><tbody>" _n
use `pop_summary', clear
sort stratum
forvalues i = 1/`=_N' {
    file write html "<tr><td>" %4.0f (stratum[`i']) "</td><td>" (stratum_name[`i']) "</td><td>" %12.0fc (N[`i']) "</td><td>" %12.0fc (mean_income[`i']) "</td><td>" %12.0fc (sd_income[`i']) "</td><td>" %12.0fc (mean_consumption[`i']) "</td></tr>" _n
}
file write html "</tbody></table></div></div>" _n

* Allocation section
file write html "<h2>2. Allocation Methods</h2>" _n
file write html "<p>The total target sample size is <code>n = `n_total'</code>. Integer allocations use largest remainder rounding so every method sums exactly to the target.</p>" _n
file write html "<div class='cell'><div class='prompt'>In [2]:</div><div class='input'><pre>generate W_h = N_h / `N_population'" _n
file write html "generate raw_prop = `n_total' * W_h" _n
file write html "generate NhSh = N_h * S_h" _n
file write html "egen total_NhSh = total(NhSh)" _n
file write html "generate raw_neyman = `n_total' * NhSh / total_NhSh" _n
file write html "generate Nh_q = N_h ^ `q_power'" _n
file write html "egen total_Nh_q = total(Nh_q)" _n
file write html "generate raw_power = `n_total' * Nh_q / total_Nh_q" _n
file write html "generate NhSh_cost = N_h * S_h / sqrt(unit_cost)" _n
file write html "egen total_NhSh_cost = total(NhSh_cost)" _n
file write html "generate raw_cost = `n_total' * NhSh_cost / total_NhSh_cost" _n
file write html "largest_remainder raw_prop, generate(n_prop) total(`n_total')</pre></div>" _n
file write html "<div class='output'><table><thead><tr><th>Stratum</th><th>Name</th><th>Population</th><th>Equal</th><th>Proportional</th><th>Neyman</th><th>Power q=.5</th><th>Cost</th><th>Cost + floor</th></tr></thead><tbody>" _n
use "output/allocation_results.dta", clear
sort stratum
forvalues i = 1/`=_N' {
    file write html "<tr><td>" %4.0f (stratum[`i']) "</td><td>" (stratum_name[`i']) "</td><td>" %12.0fc (N_h[`i']) "</td><td>" %8.0fc (n_equal[`i']) "</td><td>" %8.0fc (n_prop[`i']) "</td><td>" %8.0fc (n_neyman[`i']) "</td><td>" %8.0fc (n_power[`i']) "</td><td>" %8.0fc (n_cost[`i']) "</td><td>" %8.0fc (n_cost_floor[`i']) "</td></tr>" _n
}
file write html "</tbody></table></div></div>" _n

* Sampling examples summary
file write html "<h2>3. Sampling Examples</h2>" _n
file write html "<p>Each example uses the same simulated population frame. For allocation-based stratified samples, the weighted income column uses the inverse sampling fraction, <code>N_h / n_h</code>.</p>" _n
file write html "<div class='cell'><div class='prompt'>In [3]:</div><div class='input'><pre>* Simple random sample" _n
file write html "generate rand_srs = runiform()" _n
file write html "sort rand_srs" _n
file write html "generate sample_srs = (_n &lt;= `n_total')" _n
file write html "" _n
file write html "* Systematic sample" _n
file write html "local k = floor(_N / `n_total')" _n
file write html "local start = ceil(runiform() * `k')" _n
file write html "generate sample_systematic = (mod(pop_id - `start', `k') == 0)" _n
file write html "" _n
file write html "* Stratified sample using one allocation column" _n
file write html "generate rand_prop = runiform()" _n
file write html "bysort stratum (rand_prop): generate rank_prop = _n" _n
file write html "generate sample_prop = (rank_prop &lt;= n_prop)</pre></div>" _n
file write html "<div class='output'><table><thead><tr><th>Method</th><th>Selected n</th><th>Mean income</th><th>Weighted income</th><th>Min weight</th><th>Max weight</th></tr></thead><tbody>" _n
use `sample_summary', clear
gen byte order = .
replace order = 1 if method == "srs"
replace order = 2 if method == "systematic"
replace order = 3 if method == "equal"
replace order = 4 if method == "prop"
replace order = 5 if method == "neyman"
replace order = 6 if method == "power"
replace order = 7 if method == "cost"
replace order = 8 if method == "cost_floor"
replace order = 9 if method == "cluster"
replace order = 10 if method == "twostage"
sort order
forvalues i = 1/`=_N' {
    file write html "<tr><td>" (method[`i']) "</td><td>" %8.0fc (selected[`i']) "</td><td>" %12.0fc (mean_income[`i']) "</td><td>" %12.0fc (weighted_income[`i']) "</td><td>" %10.1fc (min_weight[`i']) "</td><td>" %10.1fc (max_weight[`i']) "</td></tr>" _n
}
file write html "</tbody></table><p class='small'>Blank weighted cells indicate examples where no design weight was computed in this teaching notebook.</p></div></div>" _n

* Counts by stratum
file write html "<h2>4. Selected Units by Stratum</h2>" _n
file write html "<div class='cell'><div class='prompt'>In [4]:</div><div class='input'><pre>tabulate stratum if sample_method == 1</pre></div>" _n
file write html "<div class='output'><table><thead><tr><th>Method</th><th>Mountain Rural</th><th>Hill Rural</th><th>Hill Urban</th><th>Terai Rural</th><th>Terai Urban</th><th>Total</th></tr></thead><tbody>" _n
use `sample_by_stratum', clear
reshape wide selected, i(method) j(stratum)
egen total = rowtotal(selected1 selected2 selected3 selected4 selected5)
gen byte order = .
replace order = 1 if method == "srs"
replace order = 2 if method == "systematic"
replace order = 3 if method == "equal"
replace order = 4 if method == "prop"
replace order = 5 if method == "neyman"
replace order = 6 if method == "power"
replace order = 7 if method == "cost"
replace order = 8 if method == "cost_floor"
replace order = 9 if method == "cluster"
replace order = 10 if method == "twostage"
sort order
forvalues i = 1/`=_N' {
    file write html "<tr><td>" (method[`i']) "</td><td>" %8.0fc (selected1[`i']) "</td><td>" %8.0fc (selected2[`i']) "</td><td>" %8.0fc (selected3[`i']) "</td><td>" %8.0fc (selected4[`i']) "</td><td>" %8.0fc (selected5[`i']) "</td><td>" %8.0fc (total[`i']) "</td></tr>" _n
}
file write html "</tbody></table></div></div>" _n

* Survey declaration section
file write html "<h2>5. Survey Declaration Example</h2>" _n
file write html "<div class='cell'><div class='prompt'>In [5]:</div><div class='input'><pre>use ""output/sampling_frame_with_flags.dta"", clear" _n
file write html "svyset pop_id [pweight = weight_prop], strata(stratum)" _n
file write html "svy, subpop(sample_prop): mean income consumption</pre></div>" _n
file write html "<div class='output'><p>The proportional stratified sample is declared with unit identifier <code>pop_id</code>, stratum variable <code>stratum</code>, and design weight <code>N_h / n_prop</code>. The same pattern can be applied to the other stratified allocation examples by replacing <code>weight_prop</code>.</p></div></div>" _n

file write html "<h2>6. Quality Checks</h2>" _n
file write html "<div class='note'>All allocation columns in <code>output/allocation_results.dta</code> sum to <code>`n_total'</code>. The floor-adjusted cost allocation enforces <code>n_h &gt;= `n_min'</code>. No stratum is over-allocated because every <code>n_h</code> is less than its simulated population size.</div>" _n
file write html "</main></body></html>" _n
file close html

* ==============================================================================
* STEP 6. Write a detailed annotated-source notebook
* ==============================================================================
* This second HTML presents the do-file itself as a teaching notebook. Every line
* of source code is shown with a short explanation, and the result tables are
* repeated so the reader can connect the program text to its outputs.
local annotated_html "output/sample_allocation_simulation_annotated.html"
file open ann using "`annotated_html'", write replace

file write ann "<!doctype html>" _n
file write ann "<html><head><meta charset='utf-8'><title>Annotated Stata notebook</title>" _n
file write ann "<style>" _n
file write ann "body{margin:0;background:#f5f6f8;color:#111827;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Arial,sans-serif;}" _n
file write ann ".page{max-width:1220px;margin:0 auto;padding:28px 24px 64px;}" _n
file write ann "h1{font-size:30px;margin:8px 0 8px;} h2{font-size:22px;margin:32px 0 10px;border-bottom:1px solid #d8dee9;padding-bottom:8px;}" _n
file write ann "p{line-height:1.55;margin:8px 0 14px;} code,pre{font-family:Consolas,Menlo,monospace;} .note{background:#fff;border:1px solid #d8dee9;border-left:5px solid #4c78a8;border-radius:6px;padding:12px 14px;margin:14px 0;}" _n
file write ann ".cell{background:#fff;border:1px solid #d8dee9;border-radius:6px;margin:16px 0 22px;overflow:hidden;box-shadow:0 1px 2px rgba(0,0,0,.04);}" _n
file write ann ".prompt{float:left;width:82px;color:#2563eb;font-family:Consolas,Menlo,monospace;font-size:13px;padding:13px 0;text-align:right;}" _n
file write ann ".input,.output{margin-left:96px;padding:12px 16px;border-left:1px solid #edf0f5;} .output{border-top:1px solid #edf0f5;background:#fcfcfd;}" _n
file write ann "table{border-collapse:collapse;width:100%;font-size:13px;margin:6px 0 10px;} th,td{border:1px solid #d8dee9;padding:7px 8px;text-align:right;vertical-align:top;} th{background:#eef2f7;font-weight:600;} td:first-child,th:first-child{text-align:left;}" _n
file write ann ".source td:nth-child(1){width:54px;text-align:right;color:#6b7280;} .source td:nth-child(2){width:52%;text-align:left;background:#fbfdff;} .source td:nth-child(3){text-align:left;} .source code{white-space:pre-wrap;}" _n
file write ann "</style></head><body><main class='page'>" _n
file write ann "<h1>Annotated Notebook: <code>sample_allocation_simulation.do</code></h1>" _n
file write ann "<p>This file presents the complete Stata program line by line. The right-hand column explains what each command or comment contributes to the simulation, allocation, sampling, result-building, or HTML-writing workflow.</p>" _n
file write ann "<div class='note'><strong>Main outputs:</strong> <code>output/simulated_population_300000.dta</code>, <code>output/allocation_results.dta</code>, <code>output/sampling_frame_with_flags.dta</code>, <code>output/sampling_examples_notebook.html</code>, and this annotated notebook.</div>" _n

file write ann "<h2>1. Complete Annotated Source Code</h2>" _n
file write ann "<div class='cell'><div class='prompt'>In [1]:</div><div class='input'><table class='source'><thead><tr><th>Line</th><th>Stata code</th><th>Explanation</th></tr></thead><tbody>" _n

file open src using "sample_allocation_simulation.do", read
local line_no = 0
file read src source_line
while r(eof) == 0 {
    local ++line_no
    local code `"`macval(source_line)'"'
    local shown `"`macval(code)'"'
    local shown : subinstr local shown "&" "&amp;", all
    local shown : subinstr local shown "<" "&lt;", all
    local shown : subinstr local shown ">" "&gt;", all
    local shown : subinstr local shown `"""' "&quot;", all

    local t = strtrim(`"`macval(code)'"')
    local tmatch `"`macval(t)'"'
    local tmatch : subinstr local tmatch "`" "", all
    local tmatch : subinstr local tmatch "'" "", all
    if strpos(`"`tmatch'"', "STEP 6. Write a detailed annotated-source notebook") > 0 {
        file write ann "<tr><td>" %5.0f (`line_no') "</td><td><code>" `"`macval(shown)'"' "</code></td><td>This starts the notebook generator block. The analytical workflow above is annotated line by line; the result tables below document the outputs generated by the full do-file.</td></tr>" _n
        continue, break
    }
    local explain "This line is part of the Stata workflow."
    if `"`tmatch'"' == "" local explain "Blank line used to separate logical blocks and make the program easier to read."
    else if substr(`"`tmatch'"',1,1) == "*" local explain "Comment line. It documents the purpose, section, or reasoning without changing the data."
    else if regexm(`"`tmatch'"',"^version ") local explain "Locks the script to a Stata version so command behavior is reproducible."
    else if regexm(`"`tmatch'"',"^clear") local explain "Clears the data currently in memory before starting a new step."
    else if regexm(`"`tmatch'"',"^set more off") local explain "Prevents Stata from pausing output during batch execution."
    else if regexm(`"`tmatch'"',"^set seed") local explain "Sets the random-number seed so the simulated population and samples are reproducible."
    else if regexm(`"`tmatch'"',"^capture mkdir") local explain "Creates the output folder if it does not already exist."
    else if regexm(`"`tmatch'"',"^local ") local explain "Defines a local macro used as a parameter or temporary value in later commands."
    else if regexm(`"`tmatch'"',"^global ") local explain "Defines a global macro. This program mainly uses local macros to keep scope controlled."
    else if regexm(`"`tmatch'"',"^capture program drop") local explain "Removes any old copy of the helper program so it can be redefined cleanly."
    else if regexm(`"`tmatch'"',"^program define") local explain "Starts a reusable Stata helper program."
    else if regexm(`"`tmatch'"',"^syntax ") local explain "Declares the required arguments and options for the helper program."
    else if regexm(`"`tmatch'"',"^tempvar ") local explain "Creates temporary variable names that will not conflict with variables already in the data."
    else if regexm(`"`tmatch'"',"^quietly") local explain "Runs the command while suppressing routine output."
    else if regexm(`"`tmatch'"',"^gen |^generate ") local explain "Creates a new variable used in the simulation, allocation, sampling, weighting, or reporting step."
    else if regexm(`"`tmatch'"',"^replace ") local explain "Updates values in an existing variable for observations that meet the stated condition."
    else if regexm(`"`tmatch'"',"^summarize ") local explain "Calculates summary statistics; the script often reads totals or means from returned results."
    else if regexm(`"`tmatch'"',"^assert ") local explain "Checks an expected condition and stops the script if it is false."
    else if regexm(`"`tmatch'"',"^input ") local explain "Begins inline data entry for the five stratum-level design records."
    else if `"`tmatch'"' == "end" local explain "Closes an input block, program definition, or loop block depending on context."
    else if regexm(`"`tmatch'"',"^expand ") local explain "Expands stratum records into individual population units."
    else if regexm(`"`tmatch'"',"^bysort ") local explain "Sorts within groups and runs the following command separately inside each group."
    else if regexm(`"`tmatch'"',"^egen ") local explain "Uses Stata extended generate functions for grouped identifiers, ranks, totals, or row calculations."
    else if regexm(`"`tmatch'"',"^order ") local explain "Reorders variables in the dataset for easier inspection."
    else if regexm(`"`tmatch'"',"^label var ") local explain "Adds a readable variable label for documentation."
    else if regexm(`"`tmatch'"',"^compress") local explain "Reduces storage size by using the smallest safe storage types."
    else if regexm(`"`tmatch'"',"^save ") local explain "Writes the current dataset to disk."
    else if regexm(`"`tmatch'"',"^preserve") local explain "Temporarily saves the current dataset state before making a derived table."
    else if regexm(`"`tmatch'"',"^restore") local explain "Returns to the dataset state saved by preserve."
    else if regexm(`"`tmatch'"',"^keep ") local explain "Keeps only the variables or observations needed for the next step."
    else if regexm(`"`tmatch'"',"^duplicates drop") local explain "Reduces repeated records to one unique record, such as one row per stratum or PSU."
    else if regexm(`"`tmatch'"',"^sort ") local explain "Sorts the data to control order before ranking, sampling, or display."
    else if regexm(`"`tmatch'"',"^largest_remainder") local explain "Calls the helper program that converts raw decimal allocations into integer allocations summing exactly to n."
    else if regexm(`"`tmatch'"',"^foreach ") local explain "Starts a loop over a list of sampling or allocation methods."
    else if regexm(`"`tmatch'"',"^forvalues ") local explain "Starts a numeric loop, here mainly for stratum numbers or table rows."
    else if regexm(`"`tmatch'"',"^while ") local explain "Starts an iterative loop that repeats until a convergence condition is met."
    else if regexm(`"`tmatch'"',"^if ") local explain "Runs the command only when the stated condition is true."
    else if regexm(`"`tmatch'"',"^count") local explain "Counts observations that satisfy a condition and stores the result in r(N)."
    else if regexm(`"`tmatch'"',"^use ") local explain "Loads a Stata dataset from disk into memory."
    else if regexm(`"`tmatch'"',"^merge ") local explain "Joins allocation or PSU-selection information onto the population frame."
    else if regexm(`"`tmatch'"',"^tempfile ") local explain "Creates a temporary file path that Stata will manage during this run."
    else if regexm(`"`tmatch'"',"^postfile ") local explain "Opens a temporary results dataset that will be filled row by row."
    else if regexm(`"`tmatch'"',"^post ") local explain "Writes one row of calculated results into a postfile results dataset."
    else if regexm(`"`tmatch'"',"^postclose ") local explain "Closes the postfile so the temporary results dataset can be used."
    else if regexm(`"`tmatch'"',"^collapse ") local explain "Aggregates the unit-level data into summary statistics by stratum."
    else if regexm(`"`tmatch'"',"^levelsof ") local explain "Extracts distinct values from a variable into a local macro."
    else if regexm(`"`tmatch'"',"^reshape ") local explain "Reshapes long result data into wide form for a compact HTML table."
    else if regexm(`"`tmatch'"',"^svyset ") local explain "Declares the survey design variables: unit identifier, weights, and strata."
    else if regexm(`"`tmatch'"',"^file open ") local explain "Opens a text or HTML file for reading or writing."
    else if regexm(`"`tmatch'"',"^file write ") local explain "Writes HTML, text, or table rows to an output file."
    else if regexm(`"`tmatch'"',"^file read ") local explain "Reads one line from a text file into a local macro."
    else if regexm(`"`tmatch'"',"^file close ") local explain "Closes an open file handle after reading or writing is complete."
    else if regexm(`"`tmatch'"',"^display ") local explain "Prints a completion message to the Stata log."

    local explain : subinstr local explain "&" "&amp;", all
    local explain : subinstr local explain "<" "&lt;", all
    local explain : subinstr local explain ">" "&gt;", all
    file write ann "<tr><td>" %5.0f (`line_no') "</td><td><code>" `"`macval(shown)'"' "</code></td><td>" `"`explain'"' "</td></tr>" _n

    file read src source_line
}
file close src
file write ann "</tbody></table></div></div>" _n

file write ann "<h2>2. Population Simulation Results</h2>" _n
file write ann "<p>The table below confirms that the simulated population has 300,000 rows distributed across the five guidebook strata.</p>" _n
file write ann "<div class='cell'><div class='prompt'>Out [2]:</div><div class='output'><table><thead><tr><th>Stratum</th><th>Name</th><th>Population</th><th>Mean income</th><th>Income SD</th><th>Mean consumption</th></tr></thead><tbody>" _n
use `pop_summary', clear
sort stratum
forvalues i = 1/`=_N' {
    file write ann "<tr><td>" %4.0f (stratum[`i']) "</td><td>" (stratum_name[`i']) "</td><td>" %12.0fc (N[`i']) "</td><td>" %12.0fc (mean_income[`i']) "</td><td>" %12.0fc (sd_income[`i']) "</td><td>" %12.0fc (mean_consumption[`i']) "</td></tr>" _n
}
file write ann "</tbody></table></div></div>" _n

file write ann "<h2>3. Allocation Results</h2>" _n
file write ann "<p>All allocation columns sum to the target sample size of <code>`n_total'</code>. The floor-adjusted cost method also enforces the minimum sample floor of <code>`n_min'</code>.</p>" _n
file write ann "<div class='cell'><div class='prompt'>Out [3]:</div><div class='output'><table><thead><tr><th>Stratum</th><th>Name</th><th>Population</th><th>Equal</th><th>Proportional</th><th>Neyman</th><th>Power q=.5</th><th>Cost</th><th>Cost + floor</th></tr></thead><tbody>" _n
use "output/allocation_results.dta", clear
sort stratum
forvalues i = 1/`=_N' {
    file write ann "<tr><td>" %4.0f (stratum[`i']) "</td><td>" (stratum_name[`i']) "</td><td>" %12.0fc (N_h[`i']) "</td><td>" %8.0fc (n_equal[`i']) "</td><td>" %8.0fc (n_prop[`i']) "</td><td>" %8.0fc (n_neyman[`i']) "</td><td>" %8.0fc (n_power[`i']) "</td><td>" %8.0fc (n_cost[`i']) "</td><td>" %8.0fc (n_cost_floor[`i']) "</td></tr>" _n
}
file write ann "</tbody></table></div></div>" _n

file write ann "<h2>4. Sampling Result Summary</h2>" _n
file write ann "<p>The table reports selected sample size and income estimates for each example sampling method.</p>" _n
file write ann "<div class='cell'><div class='prompt'>Out [4]:</div><div class='output'><table><thead><tr><th>Method</th><th>Selected n</th><th>Mean income</th><th>Weighted income</th><th>Min weight</th><th>Max weight</th></tr></thead><tbody>" _n
use `sample_summary', clear
gen byte order = .
replace order = 1 if method == "srs"
replace order = 2 if method == "systematic"
replace order = 3 if method == "equal"
replace order = 4 if method == "prop"
replace order = 5 if method == "neyman"
replace order = 6 if method == "power"
replace order = 7 if method == "cost"
replace order = 8 if method == "cost_floor"
replace order = 9 if method == "cluster"
replace order = 10 if method == "twostage"
sort order
forvalues i = 1/`=_N' {
    file write ann "<tr><td>" (method[`i']) "</td><td>" %8.0fc (selected[`i']) "</td><td>" %12.0fc (mean_income[`i']) "</td><td>" %12.0fc (weighted_income[`i']) "</td><td>" %10.1fc (min_weight[`i']) "</td><td>" %10.1fc (max_weight[`i']) "</td></tr>" _n
}
file write ann "</tbody></table></div></div>" _n

file write ann "<h2>5. Selected Units by Stratum</h2>" _n
file write ann "<p>This result table shows how each sampling method distributes selected units across strata.</p>" _n
file write ann "<div class='cell'><div class='prompt'>Out [5]:</div><div class='output'><table><thead><tr><th>Method</th><th>Mountain Rural</th><th>Hill Rural</th><th>Hill Urban</th><th>Terai Rural</th><th>Terai Urban</th><th>Total</th></tr></thead><tbody>" _n
use `sample_by_stratum', clear
reshape wide selected, i(method) j(stratum)
egen total = rowtotal(selected1 selected2 selected3 selected4 selected5)
gen byte order = .
replace order = 1 if method == "srs"
replace order = 2 if method == "systematic"
replace order = 3 if method == "equal"
replace order = 4 if method == "prop"
replace order = 5 if method == "neyman"
replace order = 6 if method == "power"
replace order = 7 if method == "cost"
replace order = 8 if method == "cost_floor"
replace order = 9 if method == "cluster"
replace order = 10 if method == "twostage"
sort order
forvalues i = 1/`=_N' {
    file write ann "<tr><td>" (method[`i']) "</td><td>" %8.0fc (selected1[`i']) "</td><td>" %8.0fc (selected2[`i']) "</td><td>" %8.0fc (selected3[`i']) "</td><td>" %8.0fc (selected4[`i']) "</td><td>" %8.0fc (selected5[`i']) "</td><td>" %8.0fc (total[`i']) "</td></tr>" _n
}
file write ann "</tbody></table></div></div>" _n

file write ann "<h2>6. Survey Design Declaration</h2>" _n
file write ann "<div class='cell'><div class='prompt'>In [6]:</div><div class='input'><pre>svyset pop_id [pweight = weight_prop], strata(stratum)" _n
file write ann "svy, subpop(sample_prop): mean income consumption</pre></div><div class='output'><p>The proportional sample can be analyzed with Stata survey commands after declaring <code>pop_id</code> as the unit identifier, <code>weight_prop</code> as the probability weight, and <code>stratum</code> as the stratification variable.</p></div></div>" _n
file write ann "</main></body></html>" _n
file close ann

display as text "Done. Created:"
display as result "  output/simulated_population_300000.dta"
display as result "  output/allocation_results.dta"
display as result "  output/sampling_frame_with_flags.dta"
display as result "  output/sampling_examples_notebook.html"
display as result "  output/sample_allocation_simulation_annotated.html"
