/*******************************************************************************************
*Project: 		    Pro-Jeune 
*Purpose: 			APPENDIX FIGURE A1: ROBUSTNESS CHECK FOR THE CLASSIFICATION OF MDSs
*Authors: 		    Clara Delavallade, Manil Zenaki, Léa Rouanet, Estelle Koussoubé
*Last Edit:		    06/10/2023
******************************************************************************************/



use $Data_final/projeune_working_sector_classification.dta , clear 
drop if  male_proportion == . 

count 
local N_sectors = `r(N)'
set obs  101

*The goal is to see how many values would change 

foreach var in x n_changes p_changes  n_mds {
gen `var' = .
}
count if male_proportion >= 75 
local ref= `r(N)'
	

forval i = 1/101 {
local j= (`i'- 1) 

replace x= `i' in `i'

if `i' <=75 {
count if male_proportion!=. &  male_proportion < 75 &  male_proportion>=`j'
replace n_changes=  `r(N)' in `i'
count if male_proportion!=. &  male_proportion>=`j'
replace n_mds= `r(N)' in `i'
}

if `i' >75 {
count if male_proportion!=. &  male_proportion > 75 &  male_proportion<`j'
replace n_changes=  `r(N)' in `i'
count if male_proportion!=. &   male_proportion>=`j'
replace n_mds= `r(N)' in `i'
}

}
replace x=x-1
replace p_changes=  100 * (n_changes / `N_sectors') 
gen p_mds= 100 * (n_mds / `N_sectors') 



twoway line p_mds x , sort  ///
title("Percentage of Male-Dominated Sectors by threshold", size(medium)) ///
ytitle("Percentage of Male-Dominated Sectors") ///
xtitle("Threshold (male percentage)") ///
yscale(range(0 45)) ///
xline(75, lcolor(red) lstyle(line)) ///
xlabel(75 "75", add custom labcolor(red) tlc(red))

graph export "$Graph_appendix/Appendix_Figure_A1_MDS_Robustness_check.png", replace
graph export "$Graph_appendix/Appendix_Figure_A1_MDS_Robustness_check.svg", replace
