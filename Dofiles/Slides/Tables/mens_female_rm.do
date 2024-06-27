/****************************************************************************************
*Project: 		    Pro-Jeune 
*Purpose: 			Analysis of men's female role models 
*Authors: 		    Clara Delavallade, Manil Zenaki, Léa Rouanet, Estelle Koussoubé
*Last Edit:		    06/10/2023
*****************************************************************************************/


use "$Data_final/cohorts_1_2_clean.dta", clear

keep if gender == 0   & rm_female == 1 


local rm_female_vars rm_female_fr rm_female_fam rm_female_not_mds rm_female_mds  rm_female_eict
local labels "Female role model is a friend" ///
"Female role model is a family member" ///
"Female role model works in a non MDS" ///
"Female role model works in MDS" ///
"Female role model works in EICT" ///


gen var_mean =.
gen var_name = "" 
gen var_label = ""

local row = 1
foreach var in `rm_female_vars' {
    
	replace var_name = "`var'" in  `row'
    
	local this_label : word `row' of "`labels'"
	replace var_label = "`this_label'" in `row'
	quietly sum `var'
	replace var_mean = `r(mean)' in  `row'
	
	local row =  `row' + 1 
}


keep if var_mean!=. 
order var_name var_label var_mean
keep var_name  var_label var_mean