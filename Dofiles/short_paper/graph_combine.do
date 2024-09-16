/****************************************************************************************
*Project: 		    Pro-Jeune 
*Purpose: 			EXPLORING RELATIONSHIP BETWEEN EDUCATION, PAST TRAINING AND TRAINING CHOICE
*Authors: 		    Clara Delavallade, Manil Zenaki, Léa Rouanet, Estelle Koussoubé
*Last Edit:		    06/10/2023
*****************************************************************************************/



local var_label "Education" "Any training" "Training EICT" 

 use "$Data_final/cohorts_1_2_clean.dta", clear


**************************************************
* A.  Generate variables needed for the table  ***
**************************************************
local gender_name "Male Female"
gen varname= ""
gen gender_name= ""
gen label_col =  ""
gen x=.
gen coeff=.
gen coeff_educ = .

foreach x in ub lb p mde {
	gen `x' = .
	
}


*significance_level and confidence interval
local CI_95 = 0.025
local CI_90 = 0.05

** A.1 variables included in the analysis

local sociodemo age_resp_z nkids_dependent_z wealthindex_hh_z
local experience worked_paid30d_dummy worked_energy_ict 
local network n5_size_z n5_male_prop_z 
local rm_support rm_male rm_female support_bothsex
local ga_agency_dv ga_score_z agency_general_z 
local educ educbis_z train_energy_ict 


local sections "sociodemo educ experience network rm_support ga_agency_dv"
local all_vars `sociodemo' `educ' `experience' `network' `rm_support' `ga_agency_dv'

**************************************
* B.  Generate required dataframe  ***
**************************************

local row = 1
local x = 1  
local w = 1  

forval i=0/1{
	local j= `i' +1 
	


foreach var in `all_vars'  {

	reg  train_choice_mds `var' i.cohort i.city if gender== `i', cluster(zone)
	
	local this_gender :word `j' of `gender_name'
	local lab : variable label `var'
	replace label_col = "`lab'" in `row'
	replace varname= "`var'"	in `row'




*reg 

test `var'

replace coeff=  _b[`var'] in `row'

replace gender_name= "`this_gender'"	in `row'
replace x=  `x' in `row'

*same reg with bootstrap clustering
boottest `var', level(90) weighttype(webb) seed(1947) nograph

replace p = `r(p)' in `row'
replace lb = r(CI)[1,1]  in `row'
replace ub = r(CI)[1,2]  in `row'




local row= `row' + 1 
local x= `x' + 4
}
local row= `row' + 1
local x= `x' +  1
local w = `w' +1 
}


keep if  x!= .
keep varname label_col gender_name x coeff mde p ub lb  




replace x = x - 55.5 if gender_name =="Female" 
sort x

* reverse x 

gen x1= x 

count
forval i=`r(N)'(-1)1{
local j = `r(N)' - `i' +1 
replace x1=  x[`i'] in `j'
}



***************
* C.  Graph ***
***************

gen min_x = -0.3
gen max_x = 0.3





set scheme white_tableau
twoway (scatter x1 coeff if gender_name=="Male", color(orange)) ///
(scatter  x1 coeff if gender_name=="Female", color(ebblue)) ///
(rcap lb ub x1 if gender_name=="Male", horizontal lcolor(orange))  ///
(rcap lb ub x1 if gender_name=="Female" ///
& lb >= min_x  & ub <= max_x, horizontal lcolor(ebblue)) ///
(pcbarrow min_x x1 max_x x1 if gender_name=="Female" ///
& lb< min_x  | ub > max_x, horizontal lcolor(ebblue) mlcolor(ebblue) ///
xline(0, lcolor(red) lstyle(line)) ///
xlabel(none) xlab("-0.3 -0.2 -0.1  0 0.1 0.2 0.3", add labcolor(grey)) xlab(0, add custom labcolor(red) tlc(red)) ///
yscale(lstyle(none) alt) ///
graphregion(color(white)) ///
ysize(5) xsize(9) ///
title("Isolated Factors", justification(center)) ///
ytitle("") xtitle("Regression coefficient") ///
ylabel(none, notick labsize(small) angle(horizontal) nogrid) ///
yline(3.75 7.75 11.75 15.75 19.75 23.75 27.75 31.75 /// 
35.75 39.75 43.75  47.75 51.75 ) ///
legend( order (1 "Male" 2 "Female") /// 
pos(6) row(1))  ///
)

graph export "$Output/short_paper/Figure_2_v1.png", replace
graph save "$Output/short_paper/Figure_2_v1.gph", replace

set scheme white_tableau
twoway (scatter x1 coeff if gender_name=="Male", color(orange)) ///
(scatter  x1 coeff if gender_name=="Female", color(ebblue)) ///
(rcap lb ub x1 if gender_name=="Male", horizontal lcolor(orange))  ///
(rcap lb ub x1 if gender_name=="Female" ///
& lb >= min_x  & ub <= max_x, horizontal lcolor(ebblue)) ///
(pcbarrow min_x x1 max_x x1 if gender_name=="Female" ///
& lb< min_x  | ub > max_x, horizontal lcolor(ebblue) mlcolor(ebblue) ///
xline(0, lcolor(red) lstyle(line)) ///
xlabel(none) xlab("-0.3 -0.2 -0.1  0 0.1 0.2 0.3", add labcolor(grey)) xlab(0, add custom labcolor(red) tlc(red)) ///
yscale(lstyle(none) alt) ///
graphregion(color(white)) ///
ysize(5) xsize(9) ///
title("Isolated Factors", justification(center)) ///
ytitle("") xtitle("Regression coefficient") ///
ylabel(none, notick labsize(small) angle(horizontal) nogrid) ///
ylabel( ///
53.75 "Age of the respondent [Z]" ///
49.75 "Number of dependent children [Z]" /// 
45.75 "Household wealth index [Z]" /// 
41.75 "Years of education [Z]" /// 
37.75 "Already received training in EICT in the past" /// 
33.75 "Had a paid work in the last 30d" /// 
29.75  "Worked in EICT in the last 30d" /// 
25.75 "Network size [Z]" /// 
21.75 "Proportion of males in the network [Z]" /// 
17.75 "Male role model" /// 
13.75 "Female role model" /// 
9.75 "Can seek professional advice" /// 
5.75 "Gender attitudes [Z]" /// 
1.75 "Agency: input in productive decisions [Z]" /// 
, add ) /// styling trick
yline(3.75 7.75 11.75 15.75 19.75 23.75 27.75 31.75 /// 
35.75 39.75 43.75  47.75 51.75 ) ///
legend( order (1 "Male" 2 "Female") /// 
pos(6) row(1))  ///
)

graph export "$Output/short_paper/Figure_2_v2.png", replace
graph save "$Output/short_paper/Figure_2_v2.gph", replace



***************
* D.  Graph ***
***************

graph combine "$Output/short_paper/Figure_2_v1.gph" ///
"$Output/short_paper/Figure_1_v5.gph", row(1) ycommon xcommon


grc1leg2 "$Output/short_paper/Figure_2_v2.gph" ///
"$Output/short_paper/Figure_1_v6.gph", ///
row(1) ycommon xcommon legendfrom("$Output/short_paper/Figure_1_v6.gph") ///
xsize(10) ysize(4) imargin(tiny)

graph export "$Output/short_paper/Figure_3_v1.png", replace