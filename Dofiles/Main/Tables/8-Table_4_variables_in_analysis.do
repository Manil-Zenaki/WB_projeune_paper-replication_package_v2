/****************************************************************************************
*Project: 		    Pro-Jeune 
*Purpose: 			Table 4: Variables Included in the analysis
*Authors: 		    Clara Delavallade, Manil Zenaki, Léa Rouanet, Estelle Koussoubé
*Last Edit:		    06/10/2023
*****************************************************************************************/


use "$Data_final/cohorts_1_2_clean.dta", clear
******************************************
* A.  Variables included in the analysis *
******************************************

** A.1 variables included in the analysis

local sociodemo age_resp_z nkids_dependent_z wealth_hh_rich
local experience worked_paid30d_dummy worked_energy_ict 
local network n5_size_z n5_male_prop_z 
local rm_support rm_male rm_female support_bothsex
local ga_agency_dv ga_score_z agency_general_z 
local educ educbis_z train_energy_ict 


local sections "sociodemo educ experience network rm_support ga_agency_dv"
local section_name "Sociodemographic characteristics" ///
"Education and training" ///
"Employment and revenues" /// 
"Network"  /// 
"Role model and support" ///
"Gender attitudes, agency and attitudes toward domestic violence"




** A.2 Labels  (variable labels are sometimes too long and therefore they are truncated)



local sociodemo_labels "Age of the respondent" ///
"Number of dependent children"  ///
"Household wealth"

local educ_labels "Years of education" ///
"Any training"  ///
"Training in EICT"


local work_labels  "Wage-employed in the last 6m" ///
"Self-employed in the last 6m" ///
"Had a paid work in the last 30d" ///
"Worked in MDSs (excluding EICT) in the last 30d" ///
"Worked in EICT in the last 30d" ///
"Revenues earned in the last 30d (USD PPP)"

local network_labels "Has a professional Network" ///
"Network size" ///
"Proportion of Males in the network"


local rm_support_labels "Male role model"  ///
"Female role model" ///
"Role model in EICT" ///
"Can seek professional advice from individuals outside the family"



local ga_agency_dm_labels "Gender attitudes" ///
"Agrees that women’s most important role is to cook and take care of her household" ///
"Agrees that household expenses are the responsibility of the husband" ///
"Agrees that by nature men and women have different abilities in differenta areas" ///
"Agrees that at work, men cope better with difficult conditions than women" ///
"Agency: input in productive decisions" ///
"Attitudes towards domestic violence"

***********


local labels_by_section "sociodemo_labels educ_labels   work_labels  network_labels  rm_support_labels  ga_agency_dm_labels"

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
keep label_col flag
keep if label_col !=""

*********************
* C.  LATEX TABLE ***
*********************

replace label_col = "\textbf{" + label_col + "}" if flag ==  1

local start_table "\begin{longtable}{m{13cm}}" ///
"\caption{Variables included in the analysis by category}" ///
"\label{tab:variables_included_analysis}\\" ///
"\toprule" ///
"VARIABLES"  ///
"\midrule" ///
"\endfirsthead" ///
"%" ///
"\multicolumn{1}{c}%" ///
"{{\bfseries Table \thetable\ continued from previous page}} \\" ///
"\toprule" ///
"VARIABLES \\*" ///
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
"Robust standard errors in parentheses. \\" ///
"*** p\textless{}0.01, ** p\textless{}0.05, * p\textless{}0.1 . \\" ///
"Variables included in the analysis by category. Categories are shown in bold" ///
"}" ///
"\end{minipage} \\* \bottomrule" ///
"\end{longtable}" ///


listtab label_col ///
using  "$Table_main/Table_4_variables_in_analysis.tex" ,  ///
rs(tabular)  footlines("`end_table'") headlines("`start_table'") replace