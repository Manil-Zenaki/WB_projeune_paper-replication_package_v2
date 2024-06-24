
use "$Data_intermediate/cohorts_1_2_raw.dta", clear

iecodebook export  using "$maindir\Documentation\cohorts_1_2_raw_codebook.xlsx", replace


use "$Data_final/cohorts_1_2_clean.dta", clear

iecodebook export  using "$maindir\Documentation\cohorts_1_2_clean_codebook.xlsx", replace
 
