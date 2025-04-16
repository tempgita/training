************************************************************************
* Simple Random Sampling and weight calculation
************************************************************************

* Load the dataset, clearing any existing data in memory
use census_sim.dta, clear

* --- Data Preparation and Frame Management ---

capture {
    * Switch back to the default frame
    frame change default
    * Drop the 'census' frame if it exists
    frame drop census
}


frame put *, into(census)
set seed 123

* --- Calculate Population Proportions ---
gen pop = _N

* Calculate the population size for each province
bysort province: gen prov_pop = _N

* Calculate the population size for each municipality
bysort municipality_id: gen munic_pop = _N

* Calculate the proportion of the total population residing in each province
bysort province: gen prov_pop_propotion = prov_pop / pop

* Calculate the proportion of the total population residing in each municipality
bysort municipality_id: gen munic_pop_propotion = munic_pop / pop


* --- Create and Analyze a Sample ---
capture {
    frame change default
    frame drop smpl20
}

frame put *, into(smpl20)
frame change smpl20

sample 20 // Draw a random sample of 20% of the observations from the dataset

gen sample_size = _N

bysort province: gen prov_sample_size = _N
bysort municipality_id: gen munic_sample_size = _N

bysort province: gen prov_sample_propotion = prov_sample_size / sample_size
bysort municipality_id: gen munic_sample_propotion = munic_sample_size / sample_size


* --- Calculate Sampling Weights ---
* Calculate "absolute" or "design" weights for municipalities
* This weight represents how many population units each sample unit represents
gen abs_weight_munic = munic_pop / munic_sample_size

* Calculate "proportional" or "balancing" weights for municipalities
* This weight adjusts the sample proportions to match the population proportions
gen prop_weight_munic = munic_pop_propotion / munic_sample_propotion

* --- Survey Data Analysis ---

egen total_pop = total(abs_weight_munic)

svyset [pweight = abs_weight_munic]
frame census: mean income
mean income
svy: mean income

frame census: proportion urban
proportion urban
svy: proportion urban
* --- Alternative Weighting Analysis ---

frame census: sum income
sum income
sum income [aweight = prop_weight_munic]


************************************************************************
* Drawing equal samples from each municipalities
************************************************************************

frame change census
capture {
    * Switch back to the default frame
    frame change default
    * Drop the 'smpl20' frame if it exists
    frame drop smpl_fixed
}
frame put *, into(smpl_fixed)



frame change smpl_fixed
set seed 123
bysort municipality_id: sample 100, count

gen sample_size = _N

bysort province: gen prov_sample_size = _N
bysort municipality_id: gen munic_sample_size = _N

bysort province: gen prov_sample_propotion = prov_sample_size / sample_size
bysort municipality_id: gen munic_sample_propotion = munic_sample_size / sample_size

gen abs_weight_munic = munic_pop / munic_sample_size
gen prop_weight_munic = munic_pop_propotion / munic_sample_propotion

* --- Survey Data Analysis ---
egen total_pop = total(abs_weight_munic)

svyset [pweight = abs_weight_munic]
frame census: mean income
mean income
svy: mean income

frame census: proportion urban
proportion urban
svy: proportion urban

* --- Alternative Weighting Analysis ---
frame census: sum income
sum income
sum income [aweight = prop_weight_munic]


************************************************************************
* Multistage sampling
************************************************************************

frame change census
capture {
    * Switch back to the default frame
    frame change default
    * Drop the 'smpl20' frame if it exists
    frame drop smpl_mult_stg
}
frame put *, into(smpl_mult_stg)

capture {
    * Switch back to the default frame
    frame change default
    * Drop the 'smpl20' frame if it exists
    frame drop temp
}
frame put *, into(temp)

*Randomly selection 300 municipalities
frame change temp
collapse (count) province, by(municipality_id)
drop province
sample 300, count
gen smpld = 1

*merging and keeping randomly selected municipalities
frame change smpl_mult_stg

frlink m:1 municipality_id, frame(temp)
frget smpld, from(temp)
keep if smpld == 1
drop temp smpld


bysort municipality_id: sample 200, count

gen sample_size = _N

bysort province: gen prov_sample_size = _N
bysort municipality_id: gen munic_sample_size = _N

bysort province: gen prov_sample_propotion = prov_sample_size / sample_size
bysort municipality_id: gen munic_sample_propotion = munic_sample_size / sample_size

gen abs_weight_munic = (753/300) * (munic_pop/munic_sample_size)

* --- Survey Data Analysis ---
egen total_pop = total(abs_weight_munic)

svyset [pweight = abs_weight_munic]
frame census: mean income
mean income
svy: mean income

frame census: proportion urban
proportion urban
svy: proportion urban

* --- using weight in regression ---
frame census: reg income i.urban education 
reg income i.urban education 
svy: reg income i.urban education 