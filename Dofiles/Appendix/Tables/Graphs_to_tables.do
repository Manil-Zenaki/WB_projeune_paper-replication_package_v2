/****************************************************************************************
*Project: 		    Pro-Jeune 
*Purpose: 			EXPLORING RELATIONSHIP BETWEEN ROLE MODELS, SUPPORT AND TRAINING CHOICE
*Authors: 		    Clara Delavallade, Manil Zenaki, Léa Rouanet, Estelle Koussoubé
*Last Edit:		    06/10/2023
*****************************************************************************************/


set cformat %9.3f 


use "$Data_final/cohorts_1_2_clean.dta", clear
******************************************
* A.  Variables to regress and labels  ***
******************************************

** A.1 variables included in the analysis

local sociodemo age_resp_z nkids_dependent_z wealthindex_hh_z
local experience employed30d_dummy selfemployed30d_dummy worked_paid30d_dummy ///
 worked_energy_ict revenues_total_z
local network n5_any n5_size_z n5_male_prop_z 
local rm_support rm_male rm_female rm_energy_ict support
local ga_agency_dv ga_score_z ga_cook ga_expenses ga_abilities ///
 ga_conditions agency_general_z dm_attitude_score_z
local educ educbis_z train_dummy train_energy_ict 


local sections "sociodemo educ experience network rm_support ga_agency_dv"
local section_name "Sociodemographic characteristics" ///
"Education and training" ///
"Employment and revenues"  "Network"  /// 
"Role model and support" ///
"Gender attitudes and agency" ///




** A.2 Labels  (variable labels are sometimes too long and therefore they are truncated)
local sociodemo_labels "Age of the respondent (z-score)" ///
"Number of dependent children (z-score)" ///
"Household wealth index by cohort (z-score)"

local work_labels  "Wage-employed in the last 30d" ///
"Self-employed in the last 30d" ///
"Had a paid work in the last 30d" ///
"Worked in EICT in the last 30d" ///
"Revenues earned in the last 30d (z-score)"

local network_labels "Has a professional Network" ///
"Network size (z-score)" ///
"Proportion of Males in the network (z-score)"

local rm_support_labels "Male role model" ///
"Female role model" ///
"Role model in EICT" ///
"Can seek professional advice from individuals outside the family" 

local ga_agency_dm_labels "Gender attitudes (z-score)" /// 
"Agrees that women’s most important role is to cook and take care of her household " ///
"Agrees that household expenses are the responsibility of the husband"   ///
"Agrees that by nature men and women have different abilities in differenta areas" /// 
 "Agrees that at work, men cope better with difficult conditions than women" ///
 "Agency: input in productive decisions"  /// 
 "Attitudes towards domestic violence (z-score)"


local educ_labels "Years of education (z-score)"   ///
"Any training" ///
"Training in EICT" 




local labels_by_section "sociodemo_labels  educ_labels work_labels  network_labels  rm_support_labels  ga_agency_dm_labels "

local sections "sociodemo educ experience network rm_support ga_agency_dv"

** A.3 Label's column 
gen flag = 0
*when new section name 
local section_count : word count in `sections'
local section_count = `section_count' - 1


display "`section_count'"
gen label_col = "" 

local row= 1  
forval i=1/`section_count'   { // begin loop over sections 


local this_local : word `i' of `sections'
local this_section_name : word `i' of  "`section_name'"
local this_label_section : word `i' of `labels_by_section'

di "`this_section_name'"
di "`this_label_section'"
replace label_col = "`this_section_name'" in `row'
replace flag = 1 in  `row'
local row= `row'  +1 


local j=1
foreach var in "``this_label_section'' "{ // begin loop over variables in this section 

*local lab : word `j' of "``this_label_section''"


replace label_col = "`var'" in `row'
local row = `row'  + 2
}

}

foreach x in "Observations" "Cohort FE" "City FE" {
	replace label_col = "`x'" in `row'
	local row = `row' + 1
}

local last_row = `row' - 1
** A.4 Stat column 

gen coeff_0 = ""
gen coeff_1 = ""
gen coeff_diff= ""
*********************
* B.  Regression  ***
*********************
cls
local variables_included  = ""


local i = 1 
local row = 2
	
foreach section in `sections' { // start loop  over sections
	
	
	
	foreach var in ``section'' { // start loop over variables
	
	
	if flag[`row'] == 1 {
			local row = `row' + 1 
			}
			
	foreach g in 0 1 { // start loop over gender
	
		reg train_choice_mds `var' i.cohort i.city ///
		if gender == `g',  cluster(zone)
		local obs = "`e(N)'"
	

		local coeff = _b[`var'] 
		local coeff : display %9.3f `coeff'
	
		local se = _se[`var'] 
		local se : display %9.3f `se'
		
		replace coeff_`g'= "`obs'" if label_col == "Observations"
		 
		*same reg with bootstrap clustering
		boottest `var', level(90) weighttype(webb) seed(1947) nograph
		local p_bootstrapped = `r(p)' 
		replace coeff_`g' =  "`coeff'"  in `row' if `r(p)'  >0.1
		replace coeff_`g' =  "`coeff'" + "*"  in `row' if `r(p)' >0.05 & `r(p)' <=0.1
		replace coeff_`g' =  "`coeff'" + "**"  in `row' if `r(p)' >0.01 & `r(p)' <=0.05
		replace coeff_`g' =  "`coeff'" + "*"  in `row' if `r(p)' <=0.01
		local row_se = `row' + 1 
		replace coeff_`g'=  "(" + "`se'" + ")" in `row_se'
		
	
	
		} // end loop over gender
	
	

reg train_choice_mds `var' i.cohort i.city ///
		if gender == 0

est store male
		
reg train_choice_mds `var' i.cohort i.city ///
		if gender ==1
est store female



suest male female, cluster(zone)
lincom [male_mean]:`var'  - [female_mean]:`var' 


local coeff: display %9.3f `r(estimate)'



replace coeff_diff =  "`coeff'"  in `row' if `r(p)'  >0.1
replace coeff_diff =  "`coeff'" + "*"  in `row' if `r(p)' >0.05 & `r(p)' <=0.1
replace coeff_diff =  "`coeff'" + "**"  in `row' if `r(p)' >0.01 & `r(p)' <=0.05
replace coeff_diff =  "`coeff'" + "*"  in `row' if `r(p)' <=0.01


local row = `row_se' + 1
	
	} // endloop over variables
	replace coeff_0 = subinstr(coeff_0, " ", "", .)
	replace coeff_1 = subinstr(coeff_1, " ", "", .)
	
} // end loop over sections 


foreach x in  "0" "1" "diff" {
replace coeff_`x' = "YES" if label_col == "Cohort FE"
replace coeff_`x' = "YES" if label_col == "City FE"
}



keep label_col coeff_* flag


keep if _n <= `last_row'


*********************
* C.  LATEX TABLE ***
*********************

replace label_col = "\textbf{" + label_col + "}" if flag ==  1

local start_table "\begin{longtable}{m{9cm}ccc}" ///
"\caption{Regression of training choice in ICT and energy on isolated factors}" ///
"\label{tab:graphs_to_tables}\\" ///
"\toprule" ///
"VARIABLES & Male & Female & Male - Female\\*"  ///
"\midrule" ///
"\endfirsthead" ///
"%" ///
"\multicolumn{1}{c}%" ///
"{{\bfseries Table \thetable\ continued from previous page}} \\" ///
"\toprule" ///
"VARIABLES & Male & Female & Male - Female\\*"  ///
"\midrule" ///
"\endhead" ///
"%" ///
"\bottomrule" ///
"\endfoot" ///
"%" ///
"\endlastfoot" ///
"%"  


local end_table ///
"\midrule" ///
"\begin{minipage}{16cm}" ///
"\small{" ///
"{\textit Notes:} \\" ///
"Robust standard errors in parentheses. \\" ///
"*** p\textless{}0.01, ** p\textless{}0.05, * p\textless{}0.1 . \\" ///
"The first two coloumns correspond to coefficient estimates from an OLS regression of training choice on respondent characteristics as specified in  \ref{eq:E1}, separately for men (first column) and women (second column). In the third column, we show the difference between the two coefficients. " ///
"}" ///
"\end{minipage} \\* \bottomrule" ///
"\end{longtable}" ///


listtab label_col coeff_0 coeff_1 coeff_diff ///
using  "$Table_appendix/Table_C1_graphs_to_tables.tex" ,  ///
rs(tabular)  footlines("`end_table'") headlines("`start_table'") replace
