/****************************************************************************************
*Project: 		    Pro-Jeune 
*Purpose: 			EXPLORING RELATIONSHIP BETWEEN ROLE MODELS, SUPPORT AND TRAINING CHOICE
*Authors: 		    Clara Delavallade, Manil Zenaki, Léa Rouanet, Estelle Koussoubé
*Last Edit:		    06/10/2023
*****************************************************************************************/


set cformat %9.3f 

local gender_code  = 0 
local t= 7 // for table name 

foreach gender_name in male female  {
	use "$Data_final/cohorts_1_2_clean.dta", clear
	keep if cohort == 1 
******************************************
* A.  Variables to regress and labels  ***
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
"Employment and revenues"  ///
"Network"  /// 
"Role model and support" ///
"Gender attitudes, agency and attitudes toward domestic violence" ///




** A.2 Labels  (variable labels are sometimes too long and therefore they are truncated)
local sociodemo_labels "Age of the respondent (z-score)" ///
"Number of dependent children (z-score)"  ///
"Household wealth index by cohort (zscore)"

local work_labels  "Had a paid job in the last 30d" ///
"Worked in EICT in the last 30d"

local network_labels "Network size (z-score)" ///
"Proportion of males in the network (z-score)" 

local rm_support_labels "Male role model" ///
"Female role model"  ///
"Can seek professional advice from individuals outside the family" 

local ga_agency_dm_labels "Gender attitudes (z-score)" ///
"Agency: input in productive decisions (z-score)" 


local educ_labels "Years of education (z-score)"  ///
"Training in EICT" 




local labels_by_section "sociodemo_labels educ_labels work_labels  network_labels  rm_support_labels  ga_agency_dm_labels"

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

forval i=1/`section_count' {
	
	gen coeff_`i' = ""
}
*********************
* B.  Regression  ***
*********************
cls
local variables_included  = ""


local i = 1 
foreach vars_in_section in `sections' { // start loop  over sections
	local variables_included  `variables_included'   ``vars_in_section''
	
	reg train_choice_mds `variables_included' i.cohort i.city ///
	if gender == `gender_code',  cluster(zone)
	local obs = "`e(N)'"
	
	local row = 2
	foreach var in `variables_included' {
	
	local coeff = _b[`var'] 
	local coeff : display %9.3f `coeff'
	
	local se = _se[`var'] 
	local se : display %9.3f `se'
	
	
	
	if flag[`row'] == 1 {
		local row = `row' + 1 
	}
	
	
	replace coeff_`i' = "`obs'" if label_col == "Observations"
	replace coeff_`i' = "YES" if label_col == "Cohort FE"
	replace coeff_`i' = "YES" if label_col == "City FE" 
	*same reg with bootstrap clustering
	boottest `var', level(90) weighttype(webb) seed(1947) nograph
	local p_bootstrapped = `r(p)' 
	replace coeff_`i' =  "`coeff'"  in `row' if `r(p)'  >0.1
	replace coeff_`i' =  "`coeff'" + "*"  in `row' if `r(p)' >0.05 & `r(p)' <=0.1
	replace coeff_`i' =  "`coeff'" + "**"  in `row' if `r(p)' >0.01 & `r(p)' <=0.05
	replace coeff_`i' =  "`coeff'" + "*"  in `row' if `r(p)' <=0.01
	local row_se = `row' + 1 
	replace coeff_`i'=  "(" + "`se'" + ")" in `row_se'
	
	local row = `row_se' + 1
	}
	replace coeff_`i' = subinstr(coeff_`i', " ", "", .)
	local i = `i' + 1 
} // end loop over sections 

keep label_col coeff_* flag


keep if _n <= `last_row'



*********************
* C.  LATEX TABLE ***
*********************
local gender_name_alt = "men"
if `gender_code' == 1 {
    local gender_name_alt = "women"
}

replace label_col = "\textbf{" + label_col + "}" if flag ==  1

local start_table "\begin{landscape}" ///
"\begin{longtable}{m{9cm}cccccc}" ///
"\caption{Correlates of `gender_name_alt''s training choices in ICT and energy}" ///
"\label{tab:results_table_`gender_name'}\\" ///
"\toprule" ///
"& \multicolumn{6}{c}{Chose the ICT or the energy vocational training} \\* \cmidrule(l){2-7}"  ///
"\endfirsthead" ///
"%" ///
"\multicolumn{7}{c}%" ///
"{{\bfseries Table \thetable\ continued from previous page}} \\" ///
"\toprule" ///
"& \multicolumn{6}{c}{Chose the ICT or the energy vocational training} \\* \cmidrule(l){2-7}" ///
"& (1)        & (2)        & (3)        & (4)        & (5)        & (6)         \\* \midrule" ///
"\endhead" ///
"%" ///
"\bottomrule" ///
"\endfoot" ///
"%" ///
"\endlastfoot" ///
"%" ///
"VARIABLES"  ///
"& (1)        & (2)     & (3)        & (4)        & (5)        & (6)         \\* \midrule" 


local end_table ///
"\midrule" ///
"\begin{minipage}{21cm}" ///
"\small{" ///
"{\textit Notes:} \\" ///
"Robust standard errors in parentheses. \\" ///
"*** p\textless{}0.01, ** p\textless{}0.05, * p\textless{}0.1 . \\" ///
"Standard errors are clustered by zone. Due to a low number of clusters (6), we rely on wild bootstrap to compute p-values. For each column, we include cohort and city fixed-effects. The acronym EICT stands for Energy or Information Communication and Technology." ///
"}" ///
"\end{minipage} \\* \bottomrule" ///
"\end{longtable}" ///
"\end{landscape}"

listtab label_col  coeff_1 coeff_2 coeff_3 coeff_4 coeff_5 coeff_6 ///
using  "$Table_main/Table_`gender_name'_c1_theory.tex" ,  ///
rs(tabular)  footlines("`end_table'") headlines("`start_table'") replace


local gender_code = `gender_code' + 1
local t = `t' - 1
}

