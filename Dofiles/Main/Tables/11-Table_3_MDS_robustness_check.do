/*******************************************************************************************
*Project: 		    Pro-Jeune 
*Purpose: 			Table 2: Robustness check for the classification of male-dominated sectors
*Authors: 		    Clara Delavallade, Manil Zenaki, Léa Rouanet, Estelle Koussoubé
*Last Edit:		    06/10/2023
******************************************************************************************/
set cformat %9.3f

**********************************************
* A. Male-dominated sectors by treshold  *****
**********************************************

* training sectors 
use $Data_final/projeune_training_sector_classification.dta , clear 
foreach x in 75 65 60 {
	
	levelsof act_projeune_number if male_proportion >= 0.`x' & male_proportion!=. 
	local mds_training_`x' `r(levels)'
}

* working sectors 
use $Data_final/projeune_working_sector_classification.dta , clear 
foreach x in 75 65 60 {
	
	levelsof act_projeune_number if male_proportion >= 0.`x' & male_proportion!=. 
	local mds_`x' `r(levels)'
}

use "$Data_final/cohorts_1_2_clean.dta", clear 
foreach x in 75 65 60 {
    
gen employed_mds_`x'= .
gen selfemployed_mds_`x'= .
gen train_mds_`x'= . 
gen n5_mds_`x' = 0 
gen rm_mds_`x' = .


foreach number of local mds_training_`x' {
replace train_mds_`x'  = 1 if strpos(train_field, "`number'")
} 

foreach number of local mds_`x' {
display "`number'"
replace employed_mds_`x' = 1 if strpos(asr_act, "`number'")
replace selfemployed_mds_`x' = 1 if strpos(list_activities, "`number'")

forval i=1/10 {
 replace n5_mds_`x' = n5_mds_`x' + 1 if  re4_`i'== `number'   
} // end i loop 


replace rm_mds_`x' = 1 if as2_act==`number'
}  // end loop over numbers 

replace train_mds_`x'= 0 if ed9_formationpro==0 | (train_mds_`x'!=1 & train_field!="")

replace selfemployed_mds_`x'=0 if selfemployed30d_dummy==0 | /// no activity
(selfemployed_mds_`x'!= 1  & list_activities!="" &  selfemployed30d_dummy !=.)

replace employed_mds_`x'=0 if employed30d_dummy==0 | /// not employed
(employed_mds_`x'!= 1  & asr_value!="" & employed30d_dummy !=.) // employed but not in mds 

gen worked_mds_`x'= .
replace worked_mds_`x'= 1 if employed_mds_`x' == 1 | selfemployed_mds_`x'==1
replace worked_mds_`x'= 0 if employed_mds_`x' == 0 & selfemployed_mds_`x'==0

gen n5_mds_`x'_prop= n5_mds_`x' / (n5_size) 

replace rm_mds_`x'= 0 if ( as2_act!=. & rm_mds_`x'!= 1 ) | as1_know==0

label var train_mds_`x'  "Had a training in MDSs"
label var  worked_mds_`x' "Worked in MDSs"
label var n5_mds_`x'_prop "Proportion of contacts in the network working in MDSs"
label var rm_mds_`x' "Has a role model working in MDSs"

} // end loop over x 



****************************
* B. Table as a dataset  ***
****************************

* do the regression 

gen var_name="" 


local i= 0
foreach g in male female {
    


foreach x in 75 65 60 {
    
gen treshold_`x'_`g' = ""

local row= 1 
foreach var in train_mds_`x' worked_mds_`x'  n5_mds_`x'_prop rm_mds_`x'  {


reg  train_choice_mds `var' ///
age_resp nkids_dependent hh_female_adult_prop wealth_hh_rich ///
i.cohort i.city if gender== `i', cluster(zone) 

boottest `var', level(90) weighttype(webb) seed(1947) nograph

local coeff = round(_b[`var'], 0.001) 
local coeff : display %9.3f `coeff'

local ste = round(_se[`var'], 0.001) 
local ste : display %9.3f `ste'
local p_value = `r(p)'

if `p_value' < = 0.01 {
replace treshold_`x'_`g'= "`coeff'" + "***" in `row'
}

if `p_value' < = 0.05 & `p_value' > 0.01 {
replace treshold_`x'_`g'= "`coeff'" + "**" in `row'
}


if `p_value' < = 0.1 & `p_value' > 0.05  {
replace treshold_`x'_`g'= "`coeff'" + "**" in `row'
 
}

if `p_value'> 0.1   {
replace treshold_`x'_`g'= "`coeff'"  in `row'
 
}

local lab: var label `var'
replace var_name = "`lab'"  in `row'
local row= `row' + 1
replace treshold_`x'_`g'= "`ste'" in `row'
local row= `row' + 1
} // loop over variables 
    
	
} // loop over treshold 


local i= `i' + 1 
}  // loop over gender 


keep var_name  treshold_75_male treshold_65_male treshold_60_male ///
treshold_75_female treshold_65_female treshold_60_female

keep if _n<= `row' -1 

*********************
* B. Latex Table  ***
*********************
gen empty_col1= . 
local start_table ///
"\begin{landscape}" ///
"\begin{table}[]" ///
"\caption{Robustness check for the classification of male-dominated sectors}" ///
"\label{tab:MDS_reg_robustness}" ///
"\begin{tabular}{@{}lccccccc@{}}" ///
"\toprule" ///
"& \multicolumn{3}{c}{Male}        &  & \multicolumn{3}{c}{Female}     \\ \cmidrule(lr){2-4}  \cmidrule(l){6-8}" ///
"VARIABLES  & T\_75    & T\_65     & T\_60    &  & T\_75    & T\_65    & T\_60    \\ \midrule"

local end_table /// 
"\midrule" ///
"\end{tabular}" /// 
"\begin{minipage}{21cm}" ///
"\small{" ///
"{\textit Notes:} \\" ///
"Robust standard errors in parentheses. \\" ///
"*** p\textless{}0.01, ** p\textless{}0.05, * p\textless{}0.1 \\" ///
"This table shows the regression of training choices on different variables. The outcome is a dummy equal to one when the respondent chose the ICT or energy vocational training (MDSs). For each variable (i.e. row)/gender combination, a separate regression is done. In each column, we vary the threshold used to determine whether a sector is classified as male-dominated.  Our reference threshold is T\_75, i.e. 75\%. In other words, using the reference threshold, any sector that is at least 75\% male is considered male-dominated. Note that for each regression, we use cohort and city fixed effects. In addition, we include sociodemographic controls (respondent age, marital status, number of dependent children, proportion of female adults in the household, and household wealth index). Standard errors are clustered by zone. Due to a low number of clusters (6), we rely on wild bootstrap to compute p-values." ///
"}" ///
"\end{minipage}" ///
"\end{table}" ///
"\end{landscape}"


listtab var_name treshold_75_male treshold_65_male treshold_60_male ///
empty_col1 ///
treshold_75_female treshold_65_female treshold_60_female  ///
using "$Table_main/Table_3_MDS_threshold_robustness_check.tex",  ///
rs(tabular) footlines("`end_table'") headlines("`start_table'") replace