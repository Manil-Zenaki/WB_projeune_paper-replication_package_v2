cls
use "$Data_final/cohorts_1_2_clean.dta", clear


gen flag_row = 0 

***************
* A.  Lasso ***
***************

* Lasso 

local sociodemo age_resp_z nkids_dependent_z hh_female_adult_prop_z wealthindex_hh_z
local experience selfemployed_mds_not_eict selfemployed_energy_ict selfemployed_not_mds /// 
employed_mds_not_eict employed_energy_ict employed_not_mds
local network n5_size_z n5_male_prop_z n5_fam_prop_z n5_eict_prop_z
local rm_support rm_male rm_female support_onlymale support_onlyfemale support_bothsex
local educ educbis_z train_mds_not_eict train_energy_ict train_not_mds 
local ga_agency_dv ga_cook ga_expenses agency_general_z dm_attitude_score_z

local all_vars `sociodemo' `experience' `network' `rm_support' `ga_agency_dv' `educ' 


lasso linear train_choice_mds i.cohort i.city `all_vars' if gender == 0, ///
rseed(1947)

lassocoef, display(coef, postselection)

matrix list `e(b)'

lasso train_choice_mds i.cohort i.city  if gender == 0,  ///
controls(`all_vars') rseed(1947) vce(robust) // vce(cluster idcode) available starting stata 17

