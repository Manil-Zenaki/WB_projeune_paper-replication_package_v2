/****************************************************************************************
*Project: 		    Pro-Jeune 
*Purpose: 			EXPLORING RELATIONSHIP BETWEEN ROLE MODELS, SUPPORT AND TRAINING CHOICE
*Authors: 		    Clara Delavallade, Manil Zenaki, Léa Rouanet, Estelle Koussoubé
*Last Edit:		    06/10/2023
*****************************************************************************************/

cls
use "$Data_final/cohorts_1_2_clean.dta", clear


******************************************
* A.  Variables to regress and labels  ***
******************************************

** A.1 variables included in the analysis

local sections "sociodemo educ experience network rm_support ga_agency_dv"
local section_name `" "Sociodemographic characteristics" "Education and training" "Employment and revenues"  "Network"  "Role model and support" "Gender roles , agency and attitudes toward domestic violence" "'

local test : word 1 of `section_name'
di "`test'"

** A.2 Labels  (variable labels are sometimes too long and therefore they are truncated)
local sociodemo_labels "Age of the respondent (z-score)" ///
"Number of dependent children (z-score)" ///
"Household wealth index by cohort (zscore)"

local work_labels  "Wage-employed in the last 6m" ///
"Self-employed in the last 6m" ///
"Had a paid work in the last 30d" ///
"Worked in MDSs (excluding EICT) in the last 30d" ///
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




local labels_by_section "sociodemo_labels educ_labels work_labels  network_labels  rm_support_labels  ga_agency_dm_labels"

local sections "sociodemo educ experience network rm_support ga_agency_dv"



*****************************
* A.  Variables Selected  ***
*****************************
local sociodemo age_resp_z nkids_dependent_z wealthindex_hh_z
local experience employed6m_dummy selfemployed6m_dummy worked_paid30d_dummy ///
 worked_mds_not_eict worked_energy_ict revenues_total_z
local network n5_any n5_size_z n5_male_prop_z 
local rm_support rm_male rm_female rm_energy_ict support
local ga_agency_dv ga_score_z ga_cook ga_expenses ga_abilities ///
 ga_conditions agency_general_z dm_attitude_score_z
local educ educbis_z train_dummy train_energy_ict 


local all_variables `sociodemo' `educ' `experience' `network' `rm_support' ///
 `a_agency_dv'
 
 
local selected_via_theory age_resp_z nkids_dependent_z wealth_hh_rich ///sociodemo
worked_paid30d_dummy worked_energy_ict  /// work
n5_size_z n5_male_prop_z  /// network
rm_male rm_female support_bothsex /// role model
ga_score_z agency_general_z  /// agency and gender attitudes 
educ educbis_z train_energy_ict  // educ and training 




dsregress train_choice_mds i.cohort i.city if gender == 0, ///
controls(`all_variables') rseed(1947)
	
local selected_lasso_men `e(controls_sel)'

dsregress train_choice_mds i.cohort i.city if gender == 1, ///
controls(`all_variables') rseed(1947)
	
local selected_lasso_women `e(controls_sel)'


***************
* B.  Table ***
***************
gen label_col = "" 
gen variable = ""
gen selected_theory = 0 
gen selected_lasso_men = 0 
gen selected_lasso_women = 0 
gen flag = 0

local row = 1


*when new section name 
local section_count : word count in `sections'
local section_count = `section_count' - 1


display "`section_count'"


forval i=1/`section_count'   { // begin loop over sections 


local this_local : word `i' of `sections'
local this_section_labels: word `i' of `labels_by_section'

local this_section_name:  word `i' of `section_name'

replace label_col =  "`this_section_name'" in `row'
replace flag = 1 in `row'
local row =  `row' + 1

 


local j= 1 
foreach var in ``this_local'' { // begin loop over variables in this section 


local this_label : word `j' of "``this_section_labels''"
display "`var' : `this_label'"
replace label_col =  "`this_label'" in `row'



replace variable = "`var'" in `row'
replace selected_theory = strpos(`"`selected_via_theory'"', "`var'") > 0 in `row'
replace selected_lasso_men = strpos(`"`selected_lasso_men'"', "`var'") > 0 in `row'
replace selected_lasso_women = strpos(`"`selected_lasso_women'"', "`var'") > 0 in `row'
local row = `row' + 1 
local j= `j' + 1 
} //end loop over this_label_section


} // end loop over section_count



foreach var in selected_theory selected_lasso_men selected_lasso_women {
    replace `var' = . if flag ==1 
}
keep variable label_col selected* flag
keep if label_col!=""


*********************
* C.  LATEX TABLE ***
*********************

replace label_col = "\textbf{" + label_col + "}" if flag ==  1

local start_table "\begin{longtable}{m{9cm}ccc}" ///
"\caption{Variable Selection}" ///
"\label{tab:appendix_variable_selection}\\" ///
"\toprule" ///
"VARIABLES & Theory & LASSO MALE & LASSO FEMALE \\*"  ///
"\midrule" ///
"\endfirsthead" ///
"%" ///
"\multicolumn{1}{c}%" ///
"{{\bfseries Table \thetable\ continued from previous page}} \\" ///
"\toprule" ///
"VARIABLES & Theory & LASSO MALE & LASSO FEMALE \\*" ///
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
"\begin{minipage}{13cm}" ///
"\small{" ///
"{\textit Notes:} \\" ///
"This table shows the variables selected for table \ref{tab:results_table_female} and table \ref{tab:results_table_male} (column 1), as well as the variables selected by a LASSO when the sample is restricted to men (column 2) and then women (column 3). \\" ///
"}" ///
"\end{minipage} \\* \bottomrule" ///
"\end{longtable}" ///


listtab label_col  selected_theory selected_lasso_men selected_lasso_women  ///
using  "$Table_appendix/Table_B2_selected_variables.tex" ,  ///
rs(tabular)  footlines("`end_table'") headlines("`start_table'") replace
