/*******************************************************************************
*Project: 		    Pro-Jeune 
*Purpose: 			Cleaning and sample selection
*Authors: 		    Clara Delavallade, Manil Zenaki, Léa Rouanet, Estelle Koussoubé
*Last Edit:		    06/10/2023
*******************************************************************************/

*************************
* A. Sample selection ***
*************************

gen to_delete = 0


local var_list train_choice gender city zone age married nkids_dependent hh_female_adult_prop /// 
educbis read write numerical_literacy digital_literacy ///
worked_energy_ict employed_energy_ict selfemployed_energy_ict gender train_energy_ict  ///
n5_eict_dummy n5_size n5_any n5_male n5_eict n5_fr n5_fam ///
rm_dummy rm_male rm_female rm_fam rm_fr rm_energy_ict ///
agency_general_zscore agencycom_general_zscore ///
ga_zscore ga_expenses ga_cook revenues_total revenues_aspiration

foreach var in  `var_list' {
replace to_delete =  1 if `var'==.
} 

mdesc `var_list'
keep if to_delete == 0



*******************************************
* B. Detecting outliers and winsorizing ***
*******************************************

local continuous  hh_size hh_size_female hh_size_male hh_female_hh_prop /// 
nbr_adults_hh nbr_children_hh hh_female_adult_prop ///
 time_ratio n5* network* perceived_support perceived_mockery ///
cognitive_score cognitive_score_z *zscore cognitive_score_p ///
revenues_total total_savings_under total_savings /// 
 lending_totaldue assets_business_value borrowing_totaldue lending_totalnet ///
 revenues_aspiration ///
 ga_score_p agencycom_work_p agencycom_general_p agency_work_p agency_general_p ///
 dm_attitude_score dm_attitude_zscore dm_attitude_p

*set trace on 
foreach var of varlist `continuous' {
count if `var'!= .  & `var'!=0

if `r(N)'!= 0 {
quietly sum `var', d 

if `r(p25)'>0  & `r(sd)'!= 0 {

sum `var',d 
replace `var' = `r(p99)' if `var' > `r(p99)' & `var'!=.
}

sum `var', d 
if `r(p25)'<=0  & `r(sd)'!= 0{
quietly sum `var' if `var'!=0,d 
replace `var' = `r(p99)' if `var' > `r(p99)' & `var'!=.
replace `var' = `r(p1)' if `var' < `r(p1)' & `var'!=0
}
}
}

*****************
* C. Z-scores ***
*****************
local to_normalize ga_score agency_general dm_attitude_score ///
n5_size n5_male_prop n5_fam_prop n5_fr_prop ///
n5_mds_not_eict_prop n5_eict_prop ///
revenues_total educbis ///
age_resp nkids_dependent hh_female_adult_prop 


local j = 1
foreach var in `to_normalize' { //start loop over variables to normalize

	local lab: variable label `var' 
	gen `var'_z= .
	label var `var'_z  "`lab'"

	quietly sum  cohort 

	forval i=`r(min)'/`r(max)'{
	    quietly sum `var' if cohort==`i'
		replace `var'_z = ( `var' - `r(mean)') / `r(sd)' if cohort== `i'
		}   
	

	local j = `j' + 1
} // end loop over variables 
save "$Data_final/cohorts_1_2_clean.dta", replace 

