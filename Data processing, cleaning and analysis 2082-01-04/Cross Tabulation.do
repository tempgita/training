use census_sim.dta, clear

tabulate sex urban
* Shows the percentage distribution across 'urban' for each 'sex' category.
tabulate sex urban, row

* Shows the percentage distribution across 'sex' for each 'urban' category.
tabulate sex urban, col

* Shows the percentage of each cell relative to the total number of observations.
tabulate sex urban, cell

table education ethnicity

* --- Advanced Cross-Tabulation Examples ---
** table (rowvar) (colvar) (tabvar)

table sex urban //two-way
table (sex urban) (education) //three-way
table (sex urban) (education) (province) //n-way
table (province sex urban) (education)


** Table of statistics
table (sex) (province) (urban), statistic(mean income) statistic(sd income) statistic(median income) statistic(min income) statistic(max income)

collect export "my_table_output.xlsx", replace //exporting the recently prepared table to excel
