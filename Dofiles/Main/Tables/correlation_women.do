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

dsregress train_choice_mds i.cohort i.city if gender == 1,  ///
controls(`all_vars') rseed(1947)



local variables_selected_women `e(controls_sel)'
	

* Identify missing vars women 
local missing_women selfemployed_mds_not_eict selfemployed_not_mds support_onlymale


*preserve
quietly generate str varnames = ""
local i = 1 

foreach var in `missing_women' `variables_selected_women' {
	local this_label: variable label `var'
    quietly replace varnames = "`this_label' `i'" in `i'
	if `i' <=3 {
		replace flag_row = 1 in `i'
	}
	local i = `i' + 1 
}


pwcorr `missing_women' `variables_selected_women' if gender ==  1 
matrix define C = r(C)


keep varnames flag_row
keep if varnames!=""
svmat double C, names(col)
matrix drop C


*********************
* B.  LATEX TABLE ***
*********************
replace varnames = "\textbf{" + varnames + "}" if flag_row ==  1
drop flag_row

local start_table "\begin{landscape}" ///
"\begin{longtable}{m{9cm}ccccccccc}" ///
"\caption{Correlation between variables selected by LASSO and other non-selected variables of interest: sample restricted to women}" ///
"\label{tab:lasso_correlation_women'}\\" ///
"\toprule" ///
"VARIABLES"  ///
"& 1     & 2 & 3 & 4 & 5 & 6 & 7 & 8 & 9" ///
" \\* \midrule" 


local end_table ///
"\midrule" ///
"\begin{minipage}{21cm}" ///
"\small{" ///
"{\textit Notes:} \\" ///
"Correlation between variables selected in the previous results but not sected by the LASSO (in bold) with variables selected by the LASSO. Sample is restricted to woman" ///
"}" ///
"\end{minipage} \\* \bottomrule" ///
"\end{longtable}" ///
"\end{landscape}"

format selfemployed_mds_not_eict selfemployed_not_mds ///
support_onlymale age_resp_z educbis_z ga_cook rm_male ///
 support_bothsex train_not_mds %9.2f 

quietly ds
listtab `r(varlist)'  ///
using  "$Table_main/Correlation_women.tex" ,  ///
rs(tabular)  footlines("`end_table'") headlines("`start_table'") replace

