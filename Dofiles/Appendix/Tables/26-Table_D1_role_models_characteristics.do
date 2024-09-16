
use "$Data_final/cohorts_1_2_clean.dta", clear

local rm_general rm_dummy rm_female rm_male  rm_fr rm_fam rm_mds rm_energy_ict  
local rm_female rm_fr_female rm_fam_female  rm_mds_female rm_eict_female
local rm_male rm_fr_male rm_fam_male  rm_mds_male rm_eict_male

local section "rm_general rm_female rm_male"
local section_name "Role models (female and male)" ///
"Female role models" ///
"Male role models"



*when new section name 
local section_count : word count in `section'
local section_count = `section_count' - 1



**************************************
*** B. GENERATE TABLE AS A DATASET ***
**************************************
* 
foreach var in var label_col mean_male mean_female {
	
	gen `var' =  ""
}

gen flag = 0 
*loop 
local row= 1  
forval i=1/`section_count'   { // begin loop over sections 


local this_local : word `i' of `section'
local this_section_name : word `i' of  "`section_name'"


di "`this_section_name'"
di "`this_local'"
replace label_col = "`this_section_name'" in `row'
replace flag = 1 in `row'
local row= `row'  +1 


local j=1
foreach var in ``this_local'' { // begin loop over variables in this section 

local lab : variable label `var'
di as result "`lab'"
*local lab: variable label `var' 
replace label_col = "`lab'" in `row'
replace var = "`var'" in `row'


***
local g = 0 
foreach x in male female { // begin loop over cities
  
   sum `var' if gender == `g'
   
   local mean_`x' : display %9.2f `r(mean)'
   replace mean_`x' = "`mean_`x''" in `row'
   local g = `g' + 1 
} // end loop over x 

local row = `row' + 1 
} // end loop over var

} // end loop over  section count 

keep var label_col flag mean_male mean_female

keep if _n < = `row' - 1 

******************************
*** C. FORMAT LATEX TABLE  ***
******************************
replace label_col = "\textbf{"  + label_col + "}" if flag == 1 


local start_table "\begin{longtable}{m{9cm}cc}" ///
"\caption{Characteristics of role models}" ///
"\label{tab:role_models_descriptive_stats}\\" ///
"\toprule" ///
"VARIABLES & Male & Female \\*"  ///
"\midrule" ///
"\endfirsthead" ///
"%" ///
"\multicolumn{1}{c}%" ///
"{{\bfseries Table \thetable\ continued from previous page}} \\" ///
"\toprule" ///
"VARIABLES & Male & Female \\*"  ///
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
"\begin{minipage}{12cm}" ///
"\small{" ///
"{\textit Notes:} \\" ///
"This table shows the descriptive characteristics of role models by gender. The 2nd and 3rd column show the mean for each gender." ///
"}" ///
"\end{minipage} \\* \bottomrule" ///
"\end{longtable}" ///



listtab label_col mean_male mean_female ///
using  "$Table_appendix/Table_D1_role_models_characteristics.tex" ,  ///
rs(tabular)  footlines("`end_table'") headlines("`start_table'") replace
