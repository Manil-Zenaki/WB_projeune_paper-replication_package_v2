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
	
reg  train_choice_mds `all_vars' i.cohort i.city if gender== `i', cluster(zone)

foreach var in `all_vars'  {

	
	
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
local x= `x' + 1
}
local row= `row' + 1
local x= `x' +  1
local w = `w' +1 
}


keep if  x!= .
keep varname label_col gender_name x coeff mde p ub lb  




replace x = x - 14.5 if gender_name =="Female" 
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


/*v1


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
title("Education and Training") ///
ytitle("") xtitle("Regression coefficient") ///
ylabel(none, notick labsize(small) angle(horizontal) nogrid) ///
ylabel( ///
14.25 "Age of the respondent (z-score)" ///
13.25 "Number of dependent children (z-score)" /// 
12.25 "Household wealth index by cohort (z-score)" /// 
11.25 "Years of education (z-score)" /// 
10.25 "Already received training in EICT in the past" /// 
9.25 "Had a paid work in the last 30d" /// 
8.25  "Worked in EICT in the last 30d" /// 
7.25 "Network size (z-score)" /// 
6.25 "Proportion of males in the network (z-score)" /// 
5.25 "Male role model" /// 
4.25 "Female role model" /// 
3.25 "Can seek professional advice from individuals outside the family" /// 
2.25 "Gender attitudes (z-score)" /// 
1.25 "Agency: input in productive decisions (z-score)" /// 
, add ) /// styling trick
yline(14.25 13.25 12.25 11.25 10.25 9.25 8.25 7.25 6.25 5.25  ///
4.25 3.25 2.25 1.25 , lstyle(grid)) ///
legend( order (1 "Male" 2 "Female" 3 "90% CI" 4 "90% CI") /// 
pos(6) row(1))  ///
)
*/

*v2
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
title("Correlates of training choices in EICT" "by gender", justification(center)) ///
ytitle("") xtitle("Regression coefficient") ///
ylabel(none, notick labsize(small) angle(horizontal) nogrid) ///
ylabel( ///
14.25 "Age of the respondent (z-score)" ///
13.25 "Number of dependent children (z-score)" /// 
12.25 "Household wealth index by cohort (z-score)" /// 
11.25 "Years of education (z-score)" /// 
10.25 "Already received training in EICT in the past" /// 
9.25 "Had a paid work in the last 30d" /// 
8.25  "Worked in EICT in the last 30d" /// 
7.25 "Network size (z-score)" /// 
6.25 "Proportion of males in the network (z-score)" /// 
5.25 "Male role model" /// 
4.25 "Female role model" /// 
3.25 "Can seek professional advice from individuals outside the family" /// 
2.25 "Gender attitudes (z-score)" /// 
1.25 "Agency: input in productive decisions (z-score)" /// 
, add ) /// styling trick
yline(13.75 12.75 11.75 10.75 9.75 8.75 7.75 6.75 5.75  ///
4.75 3.75 2.75 1.75 , lstyle(grid)) ///
legend( order (1 "Male" 2 "Female" 3 "90% CI" 4 "90% CI") /// 
pos(6) row(1))  ///
)

* v3




graph export "$Output/short_paper/Figure_1_v1.png", replace
graph export "$Output/short_paper/Figure_1_v1.svg", replace