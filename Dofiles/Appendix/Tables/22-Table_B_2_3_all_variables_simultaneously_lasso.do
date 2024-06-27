/****************************************************************************************
*Project: 		    Pro-Jeune 
*Purpose: 			EXPLORING RELATIONSHIP BETWEEN ROLE MODELS, SUPPORT AND TRAINING CHOICE
*Authors: 		    Clara Delavallade, Manil Zenaki, Léa Rouanet, Estelle Koussoubé
*Last Edit:		    06/10/2023
*****************************************************************************************/


set cformat %9.3f 

local gender_code  = 0 
local t= 3 // for table name 
foreach gender_name in male female  {
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

local all_vars `sociodemo' `educ' `experience' `network' `rm_support' `ga_agency_dv'

local all_vars_count: word count in `all_vars'
display "`all_vars_count'"

local sections "sociodemo educ experience network rm_support ga_agency_dv"
local section_name "Sociodemographic characteristics" ///
"Education and training" ///
"Employment and revenues"  "Network"  /// 
"Role model and support" ///
"Gender attitudes and agency" 




** A.2 Labels  (variable labels are sometimes too long and therefore they are truncated)
local sociodemo_labels "Age (z-score)" ///
"Number of children (z-score)" ///
"Household wealth index by cohort (zscore)"

local work_labels  "Wage-employed in the last 30 days" ///
"Self-employed in the last 30 days" ///
"Had a paid work in the last 30 days" ///
"Worked in EICT in the last 30 days" ///
"Revenues earned in the last 30 days (z-score)"

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
 "Agency (z-score)"  /// 
 "Attitudes towards domestic violence (z-score)"


local educ_labels "Education (z-score)"   ///
"Any training" ///
"Had a training in EICT" 




local labels_by_section "sociodemo_labels educ_labels work_labels  network_labels  rm_support_labels  ga_agency_dm_labels"

local sections "sociodemo educ experience network rm_support ga_agency_dv"

** A.3 Label's column 
gen flag = 0
*when new section name 
local section_count : word count in `sections'
local section_count = `section_count' - 1


display "`section_count'"
gen label_col = "" 

forval i=1/`section_count'   { // begin loop over sections 


local this_local : word `i' of `sections'

local this_label_section : word `i' of `labels_by_section'

*di "`this_section_name'"
*di "`this_label_section'"



local j=1
foreach var in ``this_local'' { // begin loop over variables in this section 


local this_label : word `j' of "``this_label_section''"
display "`var' : `this_label'"
label variable `var' "`this_label'"
local j = `j' + 1 

} //end loop over this_label_section

} // end loop over section_count




*********************
* B.  Regression  ***
*********************
cls
local row = 1 
gen coeff =  ""
local variables_included  = ""


local i = 1 

	
	
	*lasso selection 
	

	
	dsregress train_choice_mds i.cohort i.city if gender == `gender_code', ///
	controls(`all_vars') rseed(1947)
	
	local variables_selected `e(controls_sel)'
	

	
	* regression 
	
	local i = `i' + 1 
	
	reg train_choice_mds `variables_selected' i.cohort i.city ///
	if gender == `gender_code',  cluster(zone)
	local obs2 = "`e(N)'"
	
	local row = 2
	
	
	foreach var in `variables_selected' {
	
	local var_label : variable label `var'
	replace  label_col = "`var_label'" in `row'
	local coeff = _b[`var'] 
	local coeff : display %9.3f `coeff'
	
	local se = _se[`var'] 
	local se : display %9.3f `se'
	
	
	
	if flag[`row'] == 1 {
		local row = `row' + 1 
	}
	
	
	replace coeff = "`obs'" if label_col == "Observations"
	replace coeff = "YES" if label_col == "Cohort FE"
	replace coeff = "YES" if label_col == "City FE" 
	*same reg with bootstrap clustering
	boottest `var', level(90) weighttype(webb) seed(1947) nograph
	local p_bootstrapped = `r(p)' 
	replace coeff =  "`coeff'"  in `row' if `r(p)'  >0.1
	replace coeff =  "`coeff'" + "*"  in `row' if `r(p)' >0.05 & `r(p)' <=0.1
	replace coeff =  "`coeff'" + "**"  in `row' if `r(p)' >0.01 & `r(p)' <=0.05
	replace coeff =  "`coeff'" + "*"  in `row' if `r(p)' <=0.01
	local row_se = `row' + 1 
	replace coeff=  "(" + "`se'" + ")" in `row_se'
	
	local row = `row_se' + 1
	
	}
	replace coeff = subinstr(coeff, " ", "", .)

keep label_col coeff flag



foreach x in "Observations" "Cohort FE" "City FE" {
	replace label_col = "`x'" in `row'
	local row = `row' + 1
}


forvalues i=1/2 {
replace coeff = "`obs`i''" if label_col == "Observations"
replace coeff  = "YES" if label_col == "Cohort FE"
replace coeff = "YES" if label_col == "City FE" 
}

keep if _n < `row'

*********************
* C.  LATEX TABLE ***
*********************
local gender_name_alt = "men"
if `gender_code' == 1 {
    local gender_name_alt = "women"
}

replace label_col = "\textbf{" + label_col + "}" if flag ==  1

local start_table "\begin{longtable}{m{9cm}c}" ///
"\caption{LASSO: Correlates of `gender_name_alt''s training choices in ICT and energy}" ///
"\label{tab:results_lasso_`gender_name'}\\" ///
"\toprule" ///
"VARIABLES & \multicolumn{1}{c}{Chose the ICT or the energy vocational training} \\*"  ///
"\midrule" ///
"\endfirsthead" ///
"%" ///
"\multicolumn{2}{c}%" ///
"{{\bfseries Table \thetable\ continued from previous page}} \\" ///
"\toprule" ///
"VARIABLES & \multicolumn{1}{c}{Chose the ICT or the energy vocational training} \\* " ///
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
"\begin{minipage}{18cm}" ///
"\small{" ///
"{\textit Notes:} \\" ///
"Robust standard errors in parentheses. \\" ///
"*** p\textless{}0.01, ** p\textless{}0.05, * p\textless{}0.1 . \\" ///
"The variables included in the model are selected using a LASSO procedure. In both columns, we include cohort and city fixed effects. Standard errors are clustered by zone. Due to a low number of clusters (6), we rely on wild bootstrap to compute p-values. The acronym EICT stands for Energy or Information Communication and Technology." ///
"}" ///
"\end{minipage} \\* \bottomrule" ///
"\end{longtable}"

listtab label_col  coeff  ///
using  "$Table_appendix/Table_B_`t'_drivers_`gender_name'_lasso.tex" ,  ///
rs(tabular)  footlines("`end_table'") headlines("`start_table'") replace


local gender_code = `gender_code' + 1
local t = `t' - 1
}

