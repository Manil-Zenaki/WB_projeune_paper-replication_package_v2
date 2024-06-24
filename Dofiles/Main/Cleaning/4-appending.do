
/*******************************************************************************
*Project: 		    Pro-Jeune 
*Purpose: 			LOADING AND APPENDING ALL BASELINE DATASETS
*Authors: 		    Clara Delavallade, Manil Zenaki, Léa Rouanet, Estelle Koussoubé
*Last Edit:		    06/10/2023
*******************************************************************************/

***************************************************
* A. Generate Cohort Variable for each baseline ***
***************************************************

local files "$Data_raw\Pro-Jeunes\baseline1_noPII.dta" /// B1
 "$Data_raw\Pro-Jeunes\baseline2_noPII.dta" /// B2

local i=1 
foreach file in "`files'"{
di "`file'"
use `file' , clear
gen cohort=`i'

* To avoid string/numeric mismatch when appending we convert every variable to string 
foreach var in * {
quietly destring `var', replace
}

tempfile temp`i'
save  `temp`i''
local i= `i' +1 

}
*******************
* B. Baseline 1 ***
*******************

use `temp1', clear  // B1


* data type 

/*
destring ar_s10_4 /// 
ar_a2_* ar_a3_*  ar_na10_* ar_na12_*  ar_na2_* ar_na3_* ar_na12_3 ar_s7_* ///
ar_s8_* ar_s10_2  ar_s5_c_3 /// 
ar_s10_3 ar_s11_*  ar_a2_2 ar_na8_* ar_na10_3  ar_s12_4  ar_s10_5 ///
ar_s12_5 ar_na3_4 ar_na12_4 ar_s3_* ar_s5_* ar_na10_4 ar_na11_* ///
ar_a3_2 ar_a12_* ar_a3_3  ar_a12_3  ar_s10_* ar_s11_* ar_s12_* asr_value_* ///
ara_value_* ar_a7_* ar_na5_c_* re3_age_est_* bm16* ec3, replace*/

drop domaine5 

rename em15_1 em15_other_specify
rename em24_1 em24_other_specify
tempfile temp1
save  `temp1'


*******************
* C. Baseline 2 ***
*******************
use `temp2', clear  // B1

/*
destring em_alert1 em_alert2 ed11_jours  ed13e_formation5  ///
ar_a2_* ar_a3_* ar_a12_*  ar_na2_* ar_s12_4 ar_na3_* ar_na10_* ar_na12_* ar_s3_* ///
ar_s3_4 ar_a3_2 ar_a12_2  ar_s5_* ar_s7_* ar_s8_* ar_s10_*  ar_s11_* ar_s5_c_3 /// 
ar_s12_*  ar_na11_* ar_na5_b_* ar_na8_*  ara_value_* gendc ///
ar_a7_* ar_na5_c_* re3_age_est_* bm16* ed5_year ec*, replace  */

drop cr6_1_1_oth_3  cr7_1_1_oth_3

gen alerte_se17_exit_new=.
replace alerte_se17_exit_new= 1 if alerte_se17_exit==1
replace alerte_se17_exit_new= 2 if alerte_se17_exit==2
drop alerte_se17_exit
rename alerte_se17_exit_new alerte_se17_exit



tempfile temp2
save  `temp2'



****************************************
* D. Appending All Baseline Datasets ***
****************************************
use `temp1', clear 
append using  `temp2'

save "$Data_intermediate\cohorts_1_2_raw.dta", replace 

