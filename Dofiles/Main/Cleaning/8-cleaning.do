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


local var_list train_choice_salaried train_choice_selfemp ///
train_choice_vt train_choice_energy train_choice_tic train_choice_lipton ///  trainin_choice
age_resp  nkids_dependent wealth_hh_rich  wealthindex_hh_z /// sociodemo
educbis  train_dummy  train_energy_ict train_choice_mds /// educ  and past training 
employed30d_dummy selfemployed30d_dummy worked_paid30d_dummy ///
worked_mds_not_eict worked_energy_ict revenues_total /// employment and earnings 
n5_any n5_size n5_male_prop /// network 
rm_male rm_female rm_energy_ict support  /// role models and support
ga_score_p ga_cook ga_expenses ga_abilities ga_conditions agency_general_p dm_attitude_p  // gender attitudes, agency, domestic violence


foreach var in  `var_list' {
replace to_delete =  1 if `var'==.
} 


count if to_delete == 1 
keep if to_delete == 0


******************************
* A. Conversion to USD PPP ***
******************************

local vars_to_convert revenues_total assets_business_value

foreach var in `vars_to_convert' {
	
	replace `var' = `var' / 201.95 if cohort == 1
	replace `var' = `var' / 201.44 if cohort == 2
}

*******************************************
* C. Detecting outliers and winsorizing ***
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
* D. Z-scores ***
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
	label var `var'_z  "`lab' (z-score)"

	quietly sum  cohort 

	forval i=`r(min)'/`r(max)'{
	    quietly sum `var' if cohort==`i'
		replace `var'_z = ( `var' - `r(mean)') / `r(sd)' if cohort== `i'
		}   
	

	local j = `j' + 1
} // end loop over variables 

*****************
* D. Labeling ***
*****************

do "$Dofiles_main_cleaning/7-labeling.do"

save "$Data_final/cohorts_1_2_clean.dta", replace 

