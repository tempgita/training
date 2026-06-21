********************************************************************************
* File: weighted_population.do
* Purpose: Estimate the weighted numbers of households and individuals in
*          poverty.dta and export reproducible results.
* Software: Stata 18 (the commands also use standard syntax from earlier versions).
********************************************************************************

version 18.0                         // Make Stata use version 18 command behavior.
clear all                            // Remove any data and stored objects from memory.
set more off                         // Prevent output from pausing in batch execution.
capture log close _all               // Close any user-opened logs without stopping on error.

use "poverty.dta", clear             // Load the household-level analysis dataset.

describe psu_number hh_number hhsize hhs_wt ind_wt // Document IDs, size, and weights.
isid psu_number hh_number            // Confirm that one observation represents one household.
assert !missing(hhsize, hhs_wt, ind_wt) // Require all inputs used in the totals to be present.
assert hhsize >= 1                   // A sampled household must contain at least one person.
assert hhs_wt > 0 & ind_wt > 0       // Expansion weights must be strictly positive.

* ind_wt should equal the household expansion factor multiplied by household size.
* The relative tolerance allows for harmless storage rounding in float variables.
generate double expected_ind_wt = hhs_wt * hhsize
assert abs(ind_wt - expected_ind_wt) <= 1e-6 * max(1, expected_ind_wt)
drop expected_ind_wt                 // Remove the temporary validation variable.

* Define a reusable estimator. It sums an expansion weight by applying it as a
* probability weight to a variable equal to one. The returned scalar r(total)
* is therefore the estimated population represented by the current observations.
capture program drop expansion_total // Allow the do-file to be rerun in one Stata session.
program define expansion_total, rclass
    syntax varname(numeric) [if] [in] // Accept a numeric weight plus optional restrictions.
    marksample touse                  // Mark observations satisfying if/in and nonmissing inputs.
    tempvar one                       // Reserve a collision-free name for a temporary variable.
    quietly generate byte `one' = 1 if `touse' // Give every included record a value of one.
    quietly total `one' [pweight=`varlist'] if `touse' // Estimate the expanded count.
    return scalar total = el(e(b), 1, 1) // Return the point estimate to the caller.
    quietly count if `touse'          // Count the contributing sample observations.
    return scalar sample_n = r(N)     // Return that unweighted sample count as a check.
end

expansion_total hhs_wt               // Expand household records to all households.
scalar weighted_households = r(total) // Store the weighted household population.
scalar sample_households = r(sample_n) // Store the unweighted household sample size.

expansion_total ind_wt               // Expand household sizes to all individuals.
scalar weighted_individuals = r(total) // Store the weighted individual population.
scalar mean_household_size = weighted_individuals / weighted_households // Implied mean size.

display as text "Weighted households: " as result %15.0fc weighted_households
display as text "Weighted individuals: " as result %15.0fc weighted_individuals
display as text "Implied persons per household: " as result %9.3f mean_household_size
display as text "Unweighted sampled households: " as result %12.0f sample_households

* Create a machine-readable table containing the overall results.
preserve                              // Keep the microdata available after this export block.
clear                                // Start a small results dataset in memory.
set obs 2                             // Allocate one row for each target population.
generate str20 population = ""       // Create a label describing the population type.
replace population = "Households" in 1 // Label the household estimate.
replace population = "Individuals" in 2 // Label the individual estimate.
generate double weighted_total = .   // Create the numeric estimate field.
replace weighted_total = scalar(weighted_households) in 1 // Insert household total.
replace weighted_total = scalar(weighted_individuals) in 2 // Insert individual total.
generate long sample_households = scalar(sample_households) // Record common sample base.
format weighted_total %15.0fc         // Display totals with separators and no decimals.
export delimited using "weighted_population_results.csv", replace // Write overall CSV.
restore                               // Restore the original household microdata.

* Produce diagnostic breakdowns. These sum the same weights within mutually
* exclusive groups, so their totals should reconcile to the national estimates.
table prov, statistic(sum hhs_wt) statistic(sum ind_wt) nformat(%15.0fc)
table ad_4, statistic(sum hhs_wt) statistic(sum ind_wt) nformat(%15.0fc)

* Export province totals with value labels rendered as readable text.
preserve                              // Protect the original microdata.
collapse (sum) hhs_wt ind_wt, by(prov) // Sum both expansion weights within province.
decode prov, generate(province)       // Convert numeric province codes to their labels.
rename hhs_wt weighted_households     // Give the exported field an explicit name.
rename ind_wt weighted_individuals    // Give the exported field an explicit name.
order prov province weighted_households weighted_individuals // Arrange CSV columns.
export delimited using "weighted_population_by_province.csv", replace // Export table.
restore                               // Return to the household microdata.

* Export residence totals with value labels rendered as readable text.
preserve                              // Protect the original microdata.
collapse (sum) hhs_wt ind_wt, by(ad_4) // Sum both expansion weights by residence group.
decode ad_4, generate(residence)      // Convert numeric residence codes to their labels.
rename hhs_wt weighted_households     // Give the exported field an explicit name.
rename ind_wt weighted_individuals    // Give the exported field an explicit name.
order ad_4 residence weighted_households weighted_individuals // Arrange CSV columns.
export delimited using "weighted_population_by_residence.csv", replace // Export table.
restore                               // Return to the household microdata.

exit, clear                           // End batch Stata and release the dataset.
