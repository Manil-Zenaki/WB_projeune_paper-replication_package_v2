/****************************************************************************************
*Project: 		    Pro-Jeune 
*Purpose: 			EXPLORING RELATIONSHIP BETWEEN ROLE MODELS, SUPPORT AND TRAINING CHOICE
*Authors: 		    Clara Delavallade, Manil Zenaki, Léa Rouanet, Estelle Koussoubé
*Last Edit:		    06/10/2023
*****************************************************************************************/

local var_label "Attitude toward gender roles" "Agrees that women’s most important role is to cook and take care of her household "  "Agrees that household expenses are the responsibility of the husband"   ///
"Agrees that by nature men and women have different abilities in differenta areas" /// 
 "Agrees that at work, men cope better" "with difficult conditions than women"  "Agency" "Attitude towards domestic violence"


 use "$Data_final/cohorts_1_2_clean.dta", clear


**************************************************
* A.  Generate variables needed for the table  ***
**************************************************
local gender_name "Male Female"
gen varname= ""
gen gender_name= ""
gen x=.
gen coeff=.
gen coeff_educ = .

foreach x in ub lb p mde {
	gen `x' = .
	foreach y in educ nocluster bootstrapped{
		gen `x'_`y'=.
	}
}


*significance_level and confidence interval
local CI_95 = 0.025
local CI_90 = 0.05

******************************************************************
* B.  Generate required dataframe with cohort specific zscore  ***
******************************************************************


local row = 1
local x = 1 
local w = 1


foreach var in  ga_score_z ga_cook ga_expenses ga_abilities ga_conditions agency_general_z dm_attitude_score_z {
	
	local lab : word `w' of "`var_label'"
	
forval i=0/1{
local j= `i' +1 
local this_gender :word `j' of `gender_name'


*reg 
reg  train_choice_mds `var' i.cohort i.city if gender== `i', cluster(zone)
test `var'

replace coeff=  _b[`var'] in `row'
replace p= `r(p)' in `row'
replace lb= _b[`var'] - invttail(e(df_r),`CI_90') * _se[`var'] in `row'
replace ub=  _b[`var'] + invttail(e(df_r),`CI_90') * _se[`var'] in `row'
replace mde = 2.8 * _se[`var'] in `row'
replace varname= "`lab'"	in `row'
replace gender_name= "`this_gender'"	in `row'
replace x=  `x' in `row'

*same reg with bootstrap clustering
boottest `var', level(90) weighttype(webb) seed(1947) nograph

replace p_bootstrapped = `r(p)' in `row'
replace lb_bootstrapped = r(CI)[1,1]  in `row'
replace ub_bootstrapped = r(CI)[1,2]  in `row'

* same reg without clustering 

reg  train_choice_mds `var' i.cohort i.city if gender== `i', robust
test `var'
replace mde_nocluster = 2.8 * _se[`var'] in `row'
replace p_nocluster = `r(p)' in `row'
replace lb_nocluster= _b[`var'] - invttail(e(df_r),`CI_90') * _se[`var'] in `row'
replace ub_nocluster=  _b[`var'] + invttail(e(df_r),`CI_90') * _se[`var'] in `row'


*reg with sociodemo and education controls + normal clustering
reg  train_choice_mds `var' ///
educbis ///
i.cohort i.city if gender== `i', cluster(zone)

test `var'
replace coeff_educ=  _b[`var'] in `row'
replace mde_educ = 2.8 * _se[`var'] in `row'
replace p_educ = `r(p)' in `row'
replace lb_educ= _b[`var'] - invttail(e(df_r),`CI_90') * _se[`var'] in `row'
replace ub_educ=  _b[`var'] + invttail(e(df_r),`CI_90') * _se[`var'] in `row'

local row= `row' + 1 
local x= `x' + 1	
}
local row= `row' + 1
local x= `x' +  2
local w = `w' +1 
}


keep if  x!= .



keep varname gender_name x coeff mde p ub lb  /// cluster 
 p_bootstrapped ub_bootstrapped lb_bootstrapped    /// cluster + bootstrapped
 p_nocluster  ub_nocluster lb_nocluster ///nocluster
coeff_educ p_educ ub_educ lb_educ

* reverse x 

gen x1= x 

count
forval i=`r(N)'(-1)1{
local j = `r(N)' - `i' +1 
replace x1=  x[`i'] in `j'
}



*******************************************
* C.  Graph with cohort specific zscore ***
*******************************************
tab x
tab coeff


*v3 
set scheme white_tableau
twoway (scatter x1 coeff if gender_name=="Male", color(orange)) ///
(scatter  x1 coeff if gender_name=="Female", color(ebblue)) ///
(rcap lb_bootstrapped ub_bootstrapped x1 if gender_name=="Male", horizontal lcolor(orange))  ///
(rcap lb_bootstrapped ub_bootstrapped x1 if gender_name=="Female", horizontal lcolor(ebblue) ///
xline(0, lcolor(red) lstyle(line)) ///
xlabel(none) xlab( "-0.3 -0.2  -0.1  0.1 0.2 0.3" , add labcolor(grey)) xlab(0, add custom labcolor(red) tlc(red)) ///
yscale(lstyle(none) alt) ///
graphregion(color(white)) ///
ysize(5) xsize(9) ///
title("Gender roles, agency and domestic violence", size(medium)) ///
ytitle("") xtitle("Regression coefficient") ///
ylabel(25.5 "Attitude toward gender roles" 21.5 `" "Agrees that women’s most important role" "is to cook and take care of her household "'  17.5 `" "Agrees that household expenses" "are the responsibility of the husband" "'  ///
13.25 `""Agrees that by nature men and women" "have different abilities in differenta areas" "'   9.5 `""Agrees that at work, men cope better " "with difficult conditions than women" "' 5.25 "Agency" ///
1.5 "Attitude towards domestic violence", notick labsize(small) angle(horizontal)) ///
legend(label(1 "Male") label(2 "Female") label(3 "90% CI") label(4 "90% CI") /// 
pos(6) row(1)) ///
)


graph save "$Graph_main/Figure_8_gender_attitudes.gph", replace
graph export "$Graph_main/Figure_8_gender_attitudes.png", replace
graph export "$Graph_main/Figure_8_gender_attitudes.svg", replace


