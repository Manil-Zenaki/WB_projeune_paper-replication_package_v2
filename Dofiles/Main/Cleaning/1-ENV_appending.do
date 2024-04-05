/*******************************************************************************************
*Project: 		    Pro-Jeune 
*Purpose: 			USING THE ENV 2015 DATASETS TO DETERMINE WHICH SECTORS ARE MALE DOMINATED
*Authors: 		    Clara Delavallade, Manil Zenaki, Léa Rouanet, Estelle Koussoubé
*Last Edit:		    06/10/2023
******************************************************************************************/


**************************
* A. Activity dataset  ***
**************************


use "$Data_raw/ENV_2015/Section EB.dta", clear


*Ensure consistent variable length 
foreach var in hh1 hh2 ebqid {
    
quietly sum `var'
local max= "`r(max)'"
local len = strlen("`max'")

local i_up = `len' -1 
forval i=1/`i_up' {
local k= `len' - `i'

tostring `var', replace
replace `var' = `k'*"0" + `var' if strlen(`var') == `i'
}

}

* Unique id 
gen unique_id = hh1 + hh2 + ebqid 

tempfile activity
save  `activity'



****************
* B. Gender  ***
****************

use "$Data_raw/ENV_2015/Section A.dta", clear

*Ensure consistent variable length 
foreach var in hh1 hh2 a0 {
    
quietly sum `var'
local max= "`r(max)'"
local len = strlen("`max'")

local i_up = `len' -1 
forval i=1/`i_up' {
local k= `len' - `i'

tostring `var', replace
replace `var' = `k'*"0" + `var' if strlen(`var') == `i'
}

}

* Unique id 
gen unique_id = hh1 + hh2 + a0


tempfile gender
save  `gender'


**********************
* C. Remuneration  ***
**********************


use "$Data_raw/ENV_2015/Section I.dta", clear

*Ensure consistent variable length 
foreach var in hh1 hh2 iid {
    
quietly sum `var'
local max= "`r(max)'"
local len = strlen("`max'")

local i_up = `len' -1 
forval i=1/`i_up' {
local k= `len' - `i'

tostring `var', replace
replace `var' = `k'*"0" + `var' if strlen(`var') == `i'
}

}

* Unique id 
gen unique_id = hh1 + hh2 + iid

rename i1a compensation_main 
rename i1b compensation_main_unit_time 


sum compensation_main  if compensation_main!=0 //& compensation_main_unit_time == 6

replace compensation_main = compensation_main  * 30 if compensation_main_unit_time ==1
replace compensation_main = compensation_main  * 4 if compensation_main_unit_time ==2
replace compensation_main = compensation_main  / 4 if compensation_main_unit_time ==4
replace compensation_main = compensation_main  / 6 if compensation_main_unit_time ==5
replace compensation_main = compensation_main  / 12 if compensation_main_unit_time ==6

tempfile remuneration
save  `remuneration'


***************
* D. Merge  ***
***************
use  `activity', clear 
merge 1:1 unique_id using `gender', gen(merge_act_gender)

merge 1:1 unique_id using `remuneration'

gen male = (a1==1)
rename eb1b_code resp_act1

save "$Data_intermediate/env_merged.dta", replace
