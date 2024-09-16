/****************************************************************************************
*Project: 		    Pro-Jeune 
*Purpose: 			Table 4: Variables Included in the analysis
*Authors: 		    Clara Delavallade, Manil Zenaki, Léa Rouanet, Estelle Koussoubé
*Last Edit:		    06/10/2023
*****************************************************************************************/
set cformat %9.3f 


use "$Data_final/cohorts_1_2_clean.dta", clear
******************************************
* A.  Variables to regress and labels  ***
******************************************

** A.1 Variables included in isolated factors analysis

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



local sections "sociodemo educ experience network rm_support ga_agency_dv"

** A.1 Variables included in combined factors analysis factors analysis

local selected_combined_factors ///
age_resp_z nkids_dependent_z wealthindex_hh_z ///
worked_paid30d_dummy worked_energy_ict  ///
n5_size_z n5_male_prop_z  ///
rm_male rm_female support_bothsex ///
ga_score_z agency_general_z  ///
educbis_z train_energy_ict  


** A.3 Label's column 
gen flag = 0
gen included_isolated = ""
gen included_combined = "" 
*when new section name 
local section_count : word count in `sections'
local section_count = `section_count' - 1


display "`section_count'"
gen label_col = "" 
gen varname = ""

local row= 1  
forval i=1/`section_count'   { // begin loop over sections 


local this_local : word `i' of `sections'
local this_section_name : word `i' of  "`section_name'"
local this_label_section : word `i' of `labels_by_section'

di "`this_section_name'"
di "`this_label_section'"
replace label_col = "`i'- `this_section_name'" in `row'
replace flag = 1 in  `row'
local row= `row'  +1 


local j=1
foreach var in ``this_local'' { // begin loop over variables in this section 

local lab : variable label `var'

replace varname = "`var'" in `row'
replace label_col = "`lab'" in `row'
local row = `row'  + 1
}

}

replace label_col = "Agrees that women’s most important role is to cook and take care of her household"  if varname == "ga_cook"
replace included_combined = "1" if strpos("`selected_combined_factors'", varname) > 0 & flag == 0 
replace included_combined = "0" if !strpos("`selected_combined_factors'", varname) > 0 & flag == 0 
replace included_isolated = "1" if flag == 0 


order varname flag label_col included_isolated included_combined
browse varname flag label_col included_isolated included_combined
keep if label_col !=""


*********************
* C.  LATEX TABLE ***
*********************

replace label_col = "\textbf{" + label_col + "}" if flag ==  1

local start_table "\begin{longtable}{m{11cm}cc}" ///
"\caption{Variables included in the analysis by category}" ///
"\label{tab:variables_included_analysis}\\" ///
"\toprule" ///
"Variables &" ///
"Isolated factors &" ///
"Combined factors \\" ///
"\midrule" ///
"\endfirsthead" ///
"%" ///
"\multicolumn{1}{c}%" ///
"{{\bfseries Table \thetable\ continued from previous page}} \\" ///
"\toprule" ///
"Variables &" ///
"Isolated factors &" ///
"Combined factors \\" ///
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
"\begin{minipage}{17cm}" ///
"\small{" ///
"{\textit Notes:} \\" ///
"Variables included in the analysis by category. Categories are shown in bold. A value of 1 in the second column signifies that the variable was selected for the isolated factors analysis, while a value of 1 in the third column indicates its selection for the combined factors analysis." ///
"}" ///
"\end{minipage} \\* \bottomrule" ///
"\end{longtable}" ///


listtab label_col included_isolated included_combined ///
using  "$Table_main/Table_2_variables_in_analysis.tex" ,  ///
rs(tabular)  footlines("`end_table'") headlines("`start_table'") replace