//------------------------------------------------------------------------------
// Stata Code: Simulate Heterogeneous Nepal Census Data (7 Provinces)
// Includes Unique Municipality IDs (1-753), Ethnicity, and Updated Sex Coding
//------------------------------------------------------------------------------

// Version Check
version 16 // Ensure compatibility, adjust if needed

// Clear existing data and set seed for reproducibility
clear all
set seed 12345
set obs 1000000

// --- 1. Generate Province Variable ---
// Assign provinces based on approximate population distribution percentages
// Koshi: 17%, Madhesh: 21%, Bagmati: 23%, Gandaki: 9%, Lumbini: 17%, Karnali: 6%, Sudurpashchim: 7%
gen double u_prov = runiform()
gen byte province = 1 if u_prov <= 0.17
replace province = 2 if u_prov > 0.17 & u_prov <= 0.38 // 0.17 + 0.21
replace province = 3 if u_prov > 0.38 & u_prov <= 0.61 // 0.38 + 0.23
replace province = 4 if u_prov > 0.61 & u_prov <= 0.70 // 0.61 + 0.09
replace province = 5 if u_prov > 0.70 & u_prov <= 0.87 // 0.70 + 0.17
replace province = 6 if u_prov > 0.87 & u_prov <= 0.93 // 0.87 + 0.06
replace province = 7 if u_prov > 0.93 // Remaining 0.07
drop u_prov

label define province_lbl 1 "Koshi" 2 "Madhesh" 3 "Bagmati" 4 "Gandaki" 5 "Lumbini" 6 "Karnali" 7 "Sudurpashchim"
label values province province_lbl
label variable province "Province of Nepal"

// --- 1.5 Generate Unique Simulated Municipality ID (1-753) ---
// Assigns a unique ID from 1 to 753. Each ID belongs to only one province.
// ID ranges are based on the approximate number of municipalities per province:
// P1 (Koshi, 137 mun.): IDs 1-137
// P2 (Madhesh, 136 mun.): IDs 138-273
// P3 (Bagmati, 119 mun.): IDs 274-392
// P4 (Gandaki, 85 mun.): IDs 393-477
// P5 (Lumbini, 109 mun.): IDs 478-586
// P6 (Karnali, 79 mun.): IDs 587-665
// P7 (Sudurpashchim, 88 mun.): IDs 666-753
gen municipality_id = . // Initialize variable

replace municipality_id = runiformint(1, 137)   if province == 1 // Koshi IDs
replace municipality_id = runiformint(138, 273) if province == 2 // Madhesh IDs
replace municipality_id = runiformint(274, 392) if province == 3 // Bagmati IDs
replace municipality_id = runiformint(393, 477) if province == 4 // Gandaki IDs
replace municipality_id = runiformint(478, 586) if province == 5 // Lumbini IDs
replace municipality_id = runiformint(587, 665) if province == 6 // Karnali IDs
replace municipality_id = runiformint(666, 753) if province == 7 // Sudurpashchim IDs

label variable municipality_id "Simulated Unique Municipality ID (1-753)"

// --- 2. Generate Age ---
// Normally distributed, truncated at 0 and 100, different means per province
gen double age_mean = 28 if province == 1 // Koshi: Moderate
replace age_mean = 25 if province == 2 // Madhesh: Younger
replace age_mean = 32 if province == 3 // Bagmati: Older
replace age_mean = 30 if province == 4 // Gandaki: Slightly Older
replace age_mean = 29 if province == 5 // Lumbini: Moderate
replace age_mean = 24 if province == 6 // Karnali: Youngest
replace age_mean = 26 if province == 7 // Sudurpashchim: Younger

gen double age_sd = 15 // Standard deviation (can also vary by province if desired)

gen double age_raw = rnormal(age_mean, age_sd)
gen age = round(age_raw) // Round to nearest integer
replace age = 0 if age < 0
replace age = 100 if age > 100 // Truncate
drop age_raw age_mean age_sd
label variable age "Age of Individual (Years)"

// --- 3. Generate Sex ---
// Binary (1=Male, 2=Female), slight variation around 50/50
// Assuming slightly fewer females (49%) for illustration
gen byte sex = 1 + rbinomial(1, 0.49) // Generates 1 (if 0) or 2 (if 1)
label define sex_lbl 1 "Male" 2 "Female"
label values sex sex_lbl
label variable sex "Sex of Individual"

// --- 4. Generate Urban/Rural Status ---
// Binary (1=Urban, 0=Rural), different probabilities per province
gen double urban_prob = 0.35 if province == 1 // Koshi
replace urban_prob = 0.20 if province == 2 // Madhesh
replace urban_prob = 0.75 if province == 3 // Bagmati
replace urban_prob = 0.50 if province == 4 // Gandaki
replace urban_prob = 0.40 if province == 5 // Lumbini
replace urban_prob = 0.10 if province == 6 // Karnali
replace urban_prob = 0.15 if province == 7 // Sudurpashchim

gen byte urban = rbinomial(1, urban_prob)
label define urban_lbl 0 "Rural" 1 "Urban"
label values urban urban_lbl
label variable urban "Residence Status (1=Urban)"
drop urban_prob

// --- 5. Generate Education Level ---
// Categorical (0=None, 1=Primary, 2=Secondary, 3=Higher)
// Probabilities vary by province (cumulative probabilities used for generation)
gen double u_educ = runiform()
gen byte education = 0 // Default: None

// Koshi (Moderate)
replace education = 1 if province == 1 & u_educ > 0.20 & u_educ <= 0.55 // Primary (35%)
replace education = 2 if province == 1 & u_educ > 0.55 & u_educ <= 0.85 // Secondary (30%)
replace education = 3 if province == 1 & u_educ > 0.85 // Higher (15%)

// Madhesh (Lower)
replace education = 1 if province == 2 & u_educ > 0.35 & u_educ <= 0.70 // Primary (35%)
replace education = 2 if province == 2 & u_educ > 0.70 & u_educ <= 0.90 // Secondary (20%)
replace education = 3 if province == 2 & u_educ > 0.90 // Higher (10%)

// Bagmati (Highest)
replace education = 1 if province == 3 & u_educ > 0.10 & u_educ <= 0.35 // Primary (25%)
replace education = 2 if province == 3 & u_educ > 0.35 & u_educ <= 0.70 // Secondary (35%)
replace education = 3 if province == 3 & u_educ > 0.70 // Higher (30%)

// Gandaki (Higher)
replace education = 1 if province == 4 & u_educ > 0.15 & u_educ <= 0.45 // Primary (30%)
replace education = 2 if province == 4 & u_educ > 0.45 & u_educ <= 0.80 // Secondary (35%)
replace education = 3 if province == 4 & u_educ > 0.80 // Higher (20%)

// Lumbini (Moderate)
replace education = 1 if province == 5 & u_educ > 0.25 & u_educ <= 0.60 // Primary (35%)
replace education = 2 if province == 5 & u_educ > 0.60 & u_educ <= 0.88 // Secondary (28%)
replace education = 3 if province == 5 & u_educ > 0.88 // Higher (12%)

// Karnali (Lowest)
replace education = 1 if province == 6 & u_educ > 0.40 & u_educ <= 0.75 // Primary (35%)
replace education = 2 if province == 6 & u_educ > 0.75 & u_educ <= 0.92 // Secondary (17%)
replace education = 3 if province == 6 & u_educ > 0.92 // Higher (8%)

// Sudurpashchim (Lower)
replace education = 1 if province == 7 & u_educ > 0.30 & u_educ <= 0.68 // Primary (38%)
replace education = 2 if province == 7 & u_educ > 0.68 & u_educ <= 0.91 // Secondary (23%)
replace education = 3 if province == 7 & u_educ > 0.91 // Higher (9%)

label define educ_lbl 0 "None" 1 "Primary" 2 "Secondary" 3 "Higher"
label values education educ_lbl
label variable education "Highest Education Level Attained"
drop u_educ

// --- 6. Generate Ethnicity ---
// Categorical with heterogeneous distribution across provinces
// Categories (simplified): 1=Bahun/Chhetri/Thakuri, 2=Janajati(Hill), 3=Janajati(Terai/Tharu), 4=Madhesi, 5=Dalit, 6=Other
gen double u_eth = runiform()
gen byte ethnicity = 6 // Default: Other

// Province 1: Koshi (High Hill Janajati, BC, Dalit)
replace ethnicity = 1 if province == 1 & u_eth <= 0.35 // BC (35%)
replace ethnicity = 2 if province == 1 & u_eth > 0.35 & u_eth <= 0.70 // Hill Janajati (35%)
replace ethnicity = 3 if province == 1 & u_eth > 0.70 & u_eth <= 0.75 // Tharu (5%)
replace ethnicity = 4 if province == 1 & u_eth > 0.75 & u_eth <= 0.85 // Madhesi (10%)
replace ethnicity = 5 if province == 1 & u_eth > 0.85 & u_eth <= 0.95 // Dalit (10%)

// Province 2: Madhesh (High Madhesi, Dalit, Tharu)
replace ethnicity = 1 if province == 2 & u_eth <= 0.10 // BC (10%)
replace ethnicity = 2 if province == 2 & u_eth > 0.10 & u_eth <= 0.15 // Hill Janajati (5%)
replace ethnicity = 3 if province == 2 & u_eth > 0.15 & u_eth <= 0.25 // Tharu (10%)
replace ethnicity = 4 if province == 2 & u_eth > 0.25 & u_eth <= 0.80 // Madhesi (55%)
replace ethnicity = 5 if province == 2 & u_eth > 0.80 & u_eth <= 0.95 // Dalit (15%)

// Province 3: Bagmati (High BC, Newar, Tamang, Dalit)
replace ethnicity = 1 if province == 3 & u_eth <= 0.40 // BC (40%)
replace ethnicity = 2 if province == 3 & u_eth > 0.40 & u_eth <= 0.80 // Hill Janajati (split below) (40%)
    // Sub-dividing Hill Janajati for illustration (e.g., Tamang vs Newar)
    // Note: This is a simplified representation. Real distributions are complex.
    // Assign code 7 temporarily for Newar within this block
    replace ethnicity = 7 if province == 3 & u_eth > 0.40 & u_eth <= 0.56 // Approx 16% Newar (within the 40% Janajati block)
    replace ethnicity = 2 if province == 3 & u_eth > 0.56 & u_eth <= 0.80 // Approx 24% Tamang/Other Hill J.
replace ethnicity = 3 if province == 3 & u_eth > 0.80 & u_eth <= 0.82 // Tharu (2%)
replace ethnicity = 4 if province == 3 & u_eth > 0.82 & u_eth <= 0.85 // Madhesi (3%)
replace ethnicity = 5 if province == 3 & u_eth > 0.85 & u_eth <= 0.95 // Dalit (10%)
// For simplicity in final categories, map Newar (7) back or keep as separate category
// Mapping back to category 2 (Hill Janajati) here:
replace ethnicity = 2 if ethnicity == 7

// Province 4: Gandaki (High Gurung/Magar, BC, Dalit)
replace ethnicity = 1 if province == 4 & u_eth <= 0.35 // BC (35%)
replace ethnicity = 2 if province == 4 & u_eth > 0.35 & u_eth <= 0.75 // Hill Janajati (Gurung/Magar dom.) (40%)
replace ethnicity = 3 if province == 4 & u_eth > 0.75 & u_eth <= 0.77 // Tharu (2%)
replace ethnicity = 4 if province == 4 & u_eth > 0.77 & u_eth <= 0.80 // Madhesi (3%)
replace ethnicity = 5 if province == 4 & u_eth > 0.80 & u_eth <= 0.95 // Dalit (15%)

// Province 5: Lumbini (High Tharu, BC, Magar, Madhesi, Dalit)
replace ethnicity = 1 if province == 5 & u_eth <= 0.30 // BC (30%)
replace ethnicity = 2 if province == 5 & u_eth > 0.30 & u_eth <= 0.45 // Hill Janajati (Magar) (15%)
replace ethnicity = 3 if province == 5 & u_eth > 0.45 & u_eth <= 0.65 // Tharu (20%)
replace ethnicity = 4 if province == 5 & u_eth > 0.65 & u_eth <= 0.80 // Madhesi (15%)
replace ethnicity = 5 if province == 5 & u_eth > 0.80 & u_eth <= 0.95 // Dalit (15%)

// Province 6: Karnali (High BC, Dalit, Magar)
replace ethnicity = 1 if province == 6 & u_eth <= 0.55 // BC (Thakuri incl.) (55%)
replace ethnicity = 2 if province == 6 & u_eth > 0.55 & u_eth <= 0.70 // Hill Janajati (Magar) (15%)
replace ethnicity = 3 if province == 6 & u_eth > 0.70 & u_eth <= 0.71 // Tharu (1%)
replace ethnicity = 4 if province == 6 & u_eth > 0.71 & u_eth <= 0.72 // Madhesi (1%)
replace ethnicity = 5 if province == 6 & u_eth > 0.72 & u_eth <= 0.95 // Dalit (23%)

// Province 7: Sudurpashchim (High BC, Tharu, Dalit)
replace ethnicity = 1 if province == 7 & u_eth <= 0.50 // BC (Thakuri incl.) (50%)
replace ethnicity = 2 if province == 7 & u_eth > 0.50 & u_eth <= 0.55 // Hill Janajati (5%)
replace ethnicity = 3 if province == 7 & u_eth > 0.55 & u_eth <= 0.75 // Tharu (20%)
replace ethnicity = 4 if province == 7 & u_eth > 0.75 & u_eth <= 0.77 // Madhesi (2%)
replace ethnicity = 5 if province == 7 & u_eth > 0.77 & u_eth <= 0.95 // Dalit (18%)

label define ethnicity_lbl 1 "Bahun/Chhetri/Thakuri" 2 "Hill Janajati" 3 "Tharu" 4 "Madhesi" 5 "Dalit" 6 "Other"
label values ethnicity ethnicity_lbl
label variable ethnicity "Ethnic Group (Simulated)"
drop u_eth

// --- 7. Generate Income (Annual, NPR) ---
// Log-normally distributed (using rgamma as a base for skewness)
// Different means (shape*scale) and variance per province
// Note: These are illustrative values for simulation purposes
gen double income_shape = 5 if province == 1
replace income_shape = 4 if province == 2
replace income_shape = 8 if province == 3
replace income_shape = 7 if province == 4
replace income_shape = 5.5 if province == 5
replace income_shape = 3 if province == 6
replace income_shape = 3.5 if province == 7

gen double income_scale = 60000 if province == 1 // Mean ~ 300,000
replace income_scale = 50000 if province == 2 // Mean ~ 200,000
replace income_scale = 90000 if province == 3 // Mean ~ 720,000
replace income_scale = 80000 if province == 4 // Mean ~ 560,000
replace income_scale = 65000 if province == 5 // Mean ~ 357,500
replace income_scale = 45000 if province == 6 // Mean ~ 135,000
replace income_scale = 55000 if province == 7 // Mean ~ 192,500

gen income = rgamma(income_shape, income_scale)
replace income = round(income, 1000) // Round to nearest 1000 NPR
label variable income "Annual Household Income (NPR, Simulated)"
drop income_shape income_scale

// --- 8. Final Touches ---
order province municipality_id age sex urban education ethnicity income
compress // Save memory

// --- 9. Display Summary Statistics by Province ---
summarize age income, detail // Overall summary

// Show heterogeneity by province
bysort province: summarize age income
tabulate province urban, row // Urban distribution
tabulate province education, row // Education distribution
tabulate province ethnicity, row // Ethnicity distribution

// Check municipality ID ranges per province (optional)
// tabulate province municipality_id if municipality_id <= 10 // Check low IDs
// tabulate province municipality_id if municipality_id >= 740 // Check high IDs
// bysort province: summarize municipality_id // Check min/max ID per province

// Describe the data
describe

di "Simulated Nepal Census Data (N=1,000,000) with unique municipality IDs generated successfully."

// Optional: Save the dataset
save "census_sim.dta", replace

