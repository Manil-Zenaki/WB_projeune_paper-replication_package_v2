/*******************************************************************************
*Project: 		    Pro-Jeune 
*Purpose: 			DESCRIPTIVE STATS 
*Authors: 		    Clara Delavallade, Manil Zenaki, Léa Rouanet, Estelle Koussoubé
*Last Edit:		    06/10/2023
*******************************************************************************/

use "$Data_final/cohorts_1_2_clean.dta", clear
set cformat %8.2fc
set sformat %8.2fc
***************************************
*** A. COLUMNS AND VARIABLE LOCALS  ***
***************************************



** A.1 columns 
gen var = ""
gen label_col= ""

foreach district in bassam abidjan all {

gen stars_`district' = ""
gen diff_`district' = ""

foreach x in  male female all {
gen `x'_`district'_mean = . 
}
}

** A.2 variables included in descriptive statistics 

local pj_training_choice  train_choice_salaried train_choice_selfemp ///
train_choice_vt train_choice_energy train_choice_tic train_choice_lipton


local sociodemo age_resp  nkids_dependent wealth_hh_rich // sociodemo

local educ educbis  train_dummy  train_energy_ict train_choice_mds // educ  and past training 

local work  employed30d_dummy selfemployed30d_dummy worked_paid30d_dummy ///
worked_energy_ict revenues_total // employment and earnings 

local network n5_any n5_size n5_male_prop // network 

local rm_support rm_male rm_female rm_energy_ict support  // role models and support

local ga_agency_dm ga_score_p ga_cook ga_expenses ga_abilities ga_conditions agency_general_p dm_attitude_p  // gender attitudes, agency, domestic violence


local continuous age_resp  nkids_dependent  ///
educbis ///
revenues_total ///
n5_size n5_male_prop ///
ga_score_p agency_general_p dm_attitude_p


local all_vars `pj_training_choice' `sociodemo' `educ' `work' `network' `rm_support' `ga_agency_dm'  


** A.3 Sections:  each variable belong to a section
local section "pj_training_choice sociodemo educ work network rm_support ga_agency_dm"
local section_name "PRO-Jeunes Training choice" "Sociodemographics" "Education and training" ///
"Employment and earnings" "Network size and characteristics" ///
"Role Model and support outside the family" "Gender attitudes and agency"

*when new section name 
local section_count : word count in `section'
local section_count = `section_count' - 1


** A.4 condition we use for regressions
*condition 
local condition "if city==0" "if city==1" "if inlist(city,0,1)"

** A.5 Labels  (variable labels are sometimes too long and therefore they are truncated)

local pj_training_choice_labels "Wage-employement track" ///
"Generalist entrepreneurial track" ///
"Vocational training track" ///
"Vocational training in energy" ///
"Vocational training in information and communication technologies (ICT)" ///
"Vocational training in trade"


local sociodemo_labels "Age of the respondent" ///
"Number of dependent children"  ///
"Household is in the top 2 wealth quintile (by cohort)"

local educ_labels "Years of education" ///
"Any training"  ///
"Training in EICT"


local work_labels  "Wage-employed in the last 30d" ///
"Self-employed in the last 30d" ///
"Had a paid work in the last 30d" ///
"Worked in EICT in the last 30d" ///
"Revenues earned in the last 30d (USD PPP)"

local network_labels "Has a professional Network" ///
"Network size" ///
"Proportion of Males in the network"


local rm_support_labels "Male role model"  ///
"Female role model" ///
"Role model in EICT" ///
"Can seek professional advice from individuals outside the family"



local ga_agency_dm_labels "Gender attitudes [0,1]" ///
"Agrees that women’s most important role is to cook and take care of her household" ///
"Agrees that household expenses are the responsibility of the husband" ///
"Agrees that by nature men and women have different abilities in differenta areas" ///
"Agrees that at work, men cope better with difficult conditions than women" ///
"Agency: input in productive decisions [0,1]" ///
"Attitudes towards domestic violence [0,1]"

local labels_by_section "pj_training_choice_labels sociodemo_labels educ_labels  work_labels  network_labels  rm_support_labels  ga_agency_dm_labels "

**************************************
*** B. GENERATE TABLE AS A DATASET ***
**************************************
*loop 
local row= 1  
forval i=1/`section_count'   { // begin loop over sections 


local this_local : word `i' of `section'
local this_section_name : word `i' of  "`section_name'"
local this_label_section : word `i' of `labels_by_section'

di "`this_section_name'"
di "`this_local'"
replace label_col = "`this_section_name'" in `row'
local row= `row'  +1 


local j=1
foreach var in ``this_local'' { // begin loop over variables in this section 

local lab : word `j' of "``this_label_section''"
di as result "`lab'"
*local lab: variable label `var' 
replace label_col = "`lab'" in `row'
replace var = "`var'" in `row'


local d= 1 
foreach district in bassam abidjan all { // begin loop over cities

local this_condition : word `d' of "`condition'"

quietly sum `var' `this_condition' & male==1 
replace male_`district'_mean = round(`r(mean)', 0.01) in `row'
local male_`district'_sd = round(`r(sd)', 0.01)

quietly sum `var' `this_condition' & male==0
replace female_`district'_mean = round(`r(mean)', 0.01) in `row'
local female_`district'_sd = round(`r(sd)', 0.01)



quietly  reg `var' male `this_condition', cluster(zone)

boottest male, level(90) weighttype(webb) seed(1947) nograph


*Significance level;
replace stars_`district'=" " if (`r(p)'>0.1)
replace stars_`district'="*" if (`r(p)'>0.05 & `r(p)'<=0.1)
replace stars_`district'="**" if (`r(p)'>0.01 & `r(p)'<=0.05)
replace stars_`district'="***" if (`r(p)'<=0.01)

local coeff = round(_b[male] , 0.01)

if `coeff' < 1 {
	local coeff : display %9.2f `coeff'
}
else {
	local coeff : display %9.2gc `coeff'
}

replace diff_`district'=  "`coeff'" + stars_`district' in `row'

display diff_`district'[1]	

local step= 0 
if strpos("`continuous'","`var'") { // if var is continuous , show SD in the next line
local step = 1
if `d'== 1 {
local row_sd= `row' +1 

}
replace male_`district'_mean = `male_`district'_sd' in `row_sd'
replace female_`district'_mean = `female_`district'_sd' in `row_sd'

replace label_col= "SD" in `row_sd'
} // end condition var is continuous 



local d= `d' +1 	
} // end loop over districts 

local row= `row'  +1  + `step'
local j = `j' + 1 
} // end loop over variables in this section 


local i= `i' +1 
} // end loop over sections 

replace label_col = "N" in `row'
local d= 1 
foreach district in bassam abidjan all { 
local this_condition : word `d' of "`condition'"
quietly  count `this_condition' & male==1
replace male_`district'_mean= `r(N)' in `row'
quietly  count `this_condition' & male==0
replace female_`district'_mean= `r(N)' in `row'

quietly count `this_condition'
replace diff_`district'= "`r(N)'" in `row'
local d= `d' +1 

}

 
keep var label_col male_abidjan_mean female_abidjan_mean diff_abidjan ///
male_bassam_mean female_bassam_mean diff_bassam male_all_mean female_all_mean diff_all 

format male_abidjan_mean female_abidjan_mean ///
male_bassam_mean female_bassam_mean male_all_mean female_all_mean  %9.2fc

foreach var of varlist diff* {
	replace `var' = "" if label_col =="N"
}
keep if _n <=(`row')



gen empty_col1 = .
gen empty_col2 = . 

******************************
*** C. FORMAT LATEX TABLE  ***
******************************
replace label_col = "\multicolumn{1}{r}{\textit{\textbf{SD}}}" if label_col == "SD"



foreach var in male_abidjan_mean female_abidjan_mean ///
male_bassam_mean female_bassam_mean male_all_mean female_all_mean {
	
	gen this_var =  ""
	replace this_var = string(`var', "%9.2fc")  if label_col!="N"
	replace this_var = string(`var', "%8.0g")  if label_col=="N"
	replace this_var  =  "" if this_var  == "."
	replace this_var = "\textit{" + this_var  + "}" if ///
	diff_abidjan == ""  & diff_bassam =="" & this_var !="" & label_col!="N"
	
	drop `var'
	rename this_var  `var'
}




replace label_col = "\textbf{" + label_col + "}" if male_all_mean =="" & female_all_mean == ""
local start_table "\begin{landscape}" ///
"{\small\tabcolsep=1.5pt  % hold it local" ///
"\begin{longtable}{m{9cm}ccccccccccc}" /// 
"\caption{Descriptive Statistics} \label{tab:descriptive_stats} \\" ///
"\toprule" ///
"\textbf{} &" ///
"\multicolumn{3}{c}{Abidjan} &" ///
"&" ///
"\multicolumn{3}{c}{Grand Bassam} &" ///
"&" ///
"\multicolumn{3}{c}{Sample} \\" ///
"\cmidrule{2-4} \cmidrule{6-8} \cmidrule{10-12}" ///
"\endfirsthead" ///
"%" ///
"\multicolumn{12}{c}%" ///
"{{\bfseries Table \thetable\ continued from previous page}} \\" ///
"\toprule" ///
"\textbf{} &" ///
"\multicolumn{3}{c}{Abidjan} &" ///
"&" ///
"\multicolumn{3}{c}{Grand Bassam} &" ///
"&" ///
"\multicolumn{3}{c}{Sample} \\" ///
"\cmidrule{2-4} \cmidrule{6-8} \cmidrule{10-12}" ///
"&" ///
"\multicolumn{1}{l}{Male} &" ///
"\multicolumn{1}{l}{Female} &" ///
"\multicolumn{1}{l}{Diff} &" ///
"\multicolumn{1}{l}{} &" ///
"\multicolumn{1}{l}{Male} &" ///
"\multicolumn{1}{l}{Female} &" ///
"\multicolumn{1}{l}{Diff} &" ///
"\multicolumn{1}{l}{} &" ///
"\multicolumn{1}{l}{Male} &" ///
"\multicolumn{1}{l}{Female} &" ///
"\multicolumn{1}{l}{Diff} \\" ///
"\midrule" ///
"\endhead" ///
"%" ///
"&" ///
"\multicolumn{1}{l}{Male} &" ///
"\multicolumn{1}{l}{Female} &" ///
"\multicolumn{1}{l}{Diff} &" ///
"\multicolumn{1}{l}{} &" ///
"\multicolumn{1}{l}{Male} &" ///
"\multicolumn{1}{l}{Female} &" ///
"\multicolumn{1}{l}{Diff} &" ///
"\multicolumn{1}{l}{} &" ///
"\multicolumn{1}{l}{Male} &" ///
"\multicolumn{1}{l}{Female} &"  ///
"\multicolumn{1}{l}{Diff} \\" ///
"\midrule" 


local end_table ///
"\bottomrule" ///
"\begin{minipage}{21cm}" ///
"\small {Notes:  \\" ///
"Robust standard errors in parentheses. \\" ///
"*** p\textless{}0.01, ** p\textless{}0.05, * p\textless{}0.1 \\" ///
"This table shows the descriptive statistics, i.e., the characteristics of the sample. For each characteristic, we indicate the mean. When the variable is continuous, the standard deviation (SD) is shown in italics below the mean. The acronym EICT stands for Energy or  Information Communication and Technology. Gender attitudes are measured as the ratio of stereotypes to which the respondent agrees, divided by the number of questions on gender attitudes. Hence, when the variable gender attitudes is equal to 1,  the respondent agrees with all stereotypes. Standard errors are clustered by zone. Due to a low number of clusters (6), we rely on wild bootstrap to compute p-values." ///
"}" ///
"\end{minipage}" ///
"\end{longtable}" ///
"}" ///
"\end{landscape}" 


 
listtab label_col male_abidjan_mean female_abidjan_mean diff_abidjan empty_col1 ///
male_bassam_mean female_bassam_mean diff_bassam empty_col2 male_all_mean female_all_mean diff_all ///
using  "$Table_main/Table_5_descriptive_statistics.tex" ,  ///
rs(tabular)  footlines("`end_table'") headlines("`start_table'") replace