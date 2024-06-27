 
/*******************************************************************************
*Project: 		    Pro-Jeune 
*Purpose: 			VARIABLE CREATION 
*Authors: 		    Clara Delavallade, Manil Zenaki, Léa Rouanet, Estelle Koussoubé
*Last Edit:		    06/10/2023
*******************************************************************************/
use "$Data_intermediate/cohorts_1_2_raw.dta", clear 

***********************
* A. Prelimenaries  ***
***********************
*drop variable created in one dataset but not the others 
drop hh_rel hh_married hh_laborforce hh_sex hh_size hh_age nbr_adults_hh ///
nbr_adults_hh nbr_children_hh hh_size_female marital_status educ network_size 

quietly destring cohort zone se2_new1 age id_age_2 cf9 cf4 id5_gender gend_r cf10b cf11b ///
cf10a cf10b cf11a cf11b ag8_1_mins ag9_2_mins ag10_1_mins ag11_2_mins  /// 
r11_other ec3-ec7 ec9 cr3_montant_* cr4_interet_* cr12_montant_* ///
cr13_interet_*  ep*a ep*b ep*c ep10 ar_a8_* ar_na8_*  ar_s8_* bm*c ///
ec11_total_savings em2_2 em3_3 em_a em_na se3_kids as10 id, replace

egen strata_cohort_zone = group(cohort zone)

****************************
* A. Socio-demographics  ***
****************************

** A.1 Respondent **

gen city = id8_ville 
replace city = 0  if city==2 

gen abidjan = .
replace abidjan = 1 if city == 1
replace abidjan = 0 if city == 0

replace gender= gend_r - 1 if cohort==1 
replace gender= gendc - 1  if cohort>1

gen male = .
replace male = 1 if gender == 0
replace male = 0 if gender == 1 

replace id_age_2 = age if cohort == 1
replace age = id_age_2
gen age_diff = se2_new1 - id_age_2 // 80% of missing values since most have no partner
bysort cohort: tab se2_new1 if inlist(id7_marital, 2, 3, 6), m // 9.25 % of missing  values 




replace married= 1 if inlist(id7_marital,2,3,6)
replace married =0 if !inlist(id7_marital,2,3,0,6)

gen nkids_dependent_cat= se3_kids
replace nkids_dependent_cat = 3 if se3_kids >=3 

gen kids_dummy = (se3_kids >0 & se3_kids!=.) 
** A.2 head of household **
gen hh= .
replace hh=1 if cf1==1 
replace hh=0 if cf1!=1 & cf1!=. 

gen hh_spouse =.
replace hh_spouse= 1 if  inlist(cf1,2,3)
replace hh_spouse= 0 if  (cf1!=2 & cf1!=3 & cf1!=.)


gen hh_laborforce = cf7

replace cf3= cf3 -1 if cohort > 1 // coded 0 1 if baseline 1 & 1 2 in the other baselines 

clonevar hh_sex = cf3


gen hh_age = cf4
replace hh_age= . if hh_age<0 

gen hh_educ= cf6 
replace hh_educ = . if cf6<0 


gen hh_educ_some = .
replace hh_educ_some = 1 if hh_educ >= 3 //  went to primary school 
replace hh_educ_some= 0 if hh_educ < 3 

gen hh_educ_primary =.
replace hh_educ_primary =  1 if hh_educ >=8  // completed primary school 
replace hh_educ_primary = 0 if hh_educ < 8

gen hh_educ_secondary = .
replace hh_educ_secondary=1 if hh_educ>=12 // completed secondary school
replace hh_educ_secondary=0 if hh_educ<12

gen hh_educ_high_school =.
replace hh_educ_high_school = 1 if hh_educ >= 15 // completed high school , no BAC
replace hh_educ_high_school = 0 if hh_educ < 15 

gen hh_educ_diploma= .
replace hh_educ_diploma=1 if hh_educ >=  16  // At least CAP or BAC 
replace hh_educ_diploma= 0 if hh_educ <  16  // At least CAP or BAC 

gen hh_educ_higher = .
replace hh_educ_higher = 1 if hh_educ== 18  // Higher education 
replace hh_educ_higher = 0 if hh_educ< 18  // Higher education 

** A.3 Househhold characteristics **
gen hh_size = cf9 + 1
gen nbr_adults_hh = cf10a + cf10b + 1 

gen nbr_children_hh = cf11a + cf11b

gen  hh_size_female = cf10b 
replace hh_size_female = hh_size_female + 1 if gender==1

gen hh_size_male = cf10a
replace hh_size_male = hh_size_male + 1 if gender==0

gen hh_female_adult_prop= hh_size_female / nbr_adults_hh
gen hh_female_hh_prop= hh_size_female / hh_size



*********************************
* B. Chores/ Domestic tasks   ***
*********************************

** B.1 Easy access to water (proxy for time spent fetching water) ** 

replace water_concession = bm21_water if water_concession==.
replace water_hh= bm22_waterinhouse if water_hh==.

gen water_access=. 
replace water_access= 1 if (water_hh==1| water_concession== 1) 
replace water_access= 0 if (water_hh==0 & water_concession== 0) 
 
**  B.2 division of household & childrearing tasks **

replace ag8_1_mins = ag10_1_mins if ag8_1_mins==.
replace ag9_2_mins = ag11_2_mins if ag9_2_mins==.

gen worked_last24 = .
replace worked_last24= 0 if  ag8_1_mins==0
replace worked_last24= 1 if !inlist(ag8_1_mins, 0,.)

gen chores_last24=.
replace chores_last24=0 if ag9_2_mins==0
replace chores_last24=1 if !inlist(ag9_2_mins,0,.)

gen time_working_last24 = ag8_1_mins 
gen time_chores_last24 = ag9_2_mins 


gen time_ratio = .
replace time_ratio= time_chores_last24 / time_working_last24 if worked_last24!=0  & chores_last24 !=0 


******************************************
* C.  Respondent Education/ Literacy   ***
******************************************

gen educ_some = .
replace educ_some = 1 if ed7_highestclass >= 3 //  went to primary school 
replace educ_some= 0 if ed7_highestclass < 3 

gen educ_primary =.
replace educ_primary =  1 if ed7_highestclass>=8  // completed primary school 
replace educ_primary = 0 if ed7_highestclass< 8

gen educ_secondary = .
replace educ_secondary=1 if ed7_highestclass>=12 // completed secondary school
replace educ_secondary=0 if ed7_highestclass <12

gen educ_high_school =.
replace educ_high_school = 1 if ed7_highestclass >= 15 // completed high school , no BAC
replace educ_high_school = 0 if ed7_highestclass< 15 

gen educ_diploma= .
replace educ_diploma=1 if ed7_highestclass >=  16  // At least CAP or BAC 
replace educ_diploma= 0 if ed7_highestclass<  16  // At least CAP or BAC 

gen educ_higher = .
replace educ_higher = 1 if ed7_highestclass== 18  // Higher education 
replace educ_higher = 0 if ed7_highestclass< 18  // Higher education 

gen educbis = 0 if ed7_highestclass ==1
replace educbis = ed7_highestclass -2 if ed7_highestclass>= 3
replace educbis= 14 if educbis >= 14 


gen went_secondary =.
replace went_secondary= 1 if ed7_highestclass>8 & ed7_highestclass!=.  
replace went_secondary=0 if ed7_highestclass<= 8 


****************************
* D.  Experience in MDS  ***
****************************

** D.1 worked as an employee or apprentice in MDS in the last 30 days ** 
local MDS_numbers  "$mds_working_numbers"
local FDS_numbers = "$not_mds_working_numbers"
local unclassified_numbers= "$unclassified_working_numbers"

gen asr_value="" 

gen employed_paid6m_dummy = em2b
replace employed_paid6m_dummy = 0 if em1b == 0 


gen employed6m_dummy = . 


replace employed6m_dummy= 0 if (em2b==0 & em3b==0 & em4b==0 & em5b==0 & em6b==0)  // not employed in the last 6 months or 0 employment activities in the last 30 days 
replace employed6m_dummy=1 if  em2a ==1 | em2b==1 |em3a==1 | em3b==1  ///
|em4a==1 | em4b==1 | em5a==1 | em5b==1  |em6a==1 | em6b==1 

gen employed30d_dummy = . 
replace employed30d_dummy= 0  if (em2b==0 & em3b==0) | (em2_2==0 & em3_3==0)   // not employed in the last 6 months or 0 employment activities in the last 30 days 
replace employed30d_dummy=1 if  !inlist(em2_2,.,0 ) | !inlist(em3_3,.,0 ) // number of activities >0



foreach var of varlist asr_value_* {
   tostring `var' , gen(`var'_str)
}


forval i=1/6 {
capture replace asr_value= asr_value + asr_value_`i'_str + " " if `i'<6 & ///
!strpos(asr_value,asr_value_`i'_str) 
capture replace asr_value= asr_value + asr_value_`i'_str if `i'==6  & ///
!strpos(asr_value,asr_value_`i'_str) 
}


gen employed_mds= .
foreach number of local MDS_numbers {
replace employed_mds = 1 if strpos(asr_act, "`number'")

}

gen employed_fds=. 
foreach number of local FDS_numbers {
replace employed_fds = 1 if strpos(asr_act, "`number'")

}

gen employed_unclassified= .
foreach number of local unclassified_numbers {
replace employed_unclassified= 1 if strpos(asr_act, "`number'")

}


foreach x in mds fds unclassified {
replace employed_`x'=0 if employed30d_dummy==0 | /// not employed
(employed_`x'!= 1  & asr_value!="" & employed30d_dummy !=.) // employed but not in mds 
}



** D.1 worked in Energy or ITC in the last 30 days  ** 
local energy = "10 12 26" // activities related to energy
local ICT =  "27" // activites related to ICT
local energy_ICT  `energy' `ICT'

gen employed_energy=.
foreach number of local energy {
replace employed_energy = 1 if strpos(asr_value, "`number'")
}


gen employed_ict=. 
foreach number of local ICT {
replace employed_ict = 1 if strpos(asr_value, "`number'")
}

foreach x in energy ict {
replace employed_`x'=0 if employed30d_dummy==0 | /// not employed
(employed_`x'!= 1  & asr_value!="" & employed30d_dummy !=.) // employed but not in mds 
}


gen employed_energy_ict=. 
replace employed_energy_ict= 1 if employed_energy==1 | employed_ict==1
replace employed_energy_ict= 0 if ! inlist(employed_energy, 1 , .)  & ! inlist(employed_ict, 1 , .)

gen employed_mds_not_eict  = .
replace  employed_mds_not_eict= 1  if employed30d_dummy==1 & employed_energy_ict ==0
replace  employed_mds_not_eict= 0  if employed30d_dummy==0 | employed_energy_ict ==1

gen employed_not_mds  = .
replace  employed_not_mds = 1  if employed30d_dummy==1 & employed_mds ==0
replace  employed_not_mds = 0  if employed30d_dummy==0 | employed_mds ==1

** D.2 Self-employed / work for the household in an MDS during the last 30 days **

gen anr_value=""

foreach var of varlist anr_value_* {
    tostring `var', gen(`var'_str)
}

forval i=1/8 {
capture replace anr_value= anr_value + anr_value_`i'_str + " " if `i'<8 & ///
!strpos(anr_value,anr_value_`i'_str) 
capture replace anr_value= anr_value + anr_value_`i'_str if `i'==8  & ///
!strpos(anr_value, anr_value_`i'_str) 
}

foreach var of varlist ara_value_* {
    tostring `var', gen(`var'_str)
}

gen ara_value=""
forval i=1/3 {
capture replace ara_value= ara_value + ara_value_`i'_str + " " if `i'<3 & ///
!strpos(ara_value,ara_value_`i'_str) 
capture replace ara_value= ara_value + ara_value_`i'_str if `i'==3  & ///
!strpos(ara_value,ara_value_`i'_str) 
}

gen selfemployed6m_dummy=. 
replace selfemployed6m_dummy =0 if (em4b==0 & em5b==0 &  em6b==0) // nothing during the last 6 months 
replace selfemployed6m_dummy= 1 if  em4b==1| em5b==1| em6b==1

gen selfemployed30d_dummy=. 
replace selfemployed30d_dummy =0 if selfemployed6m_dummy==0 |  /// nothing during the last 6 months
((em4b==1| em5b==1) & em_na==0) &  (em6b==1 & em_a==0) // worked  during the last 6months but not in the last 30 days 
replace selfemployed30d_dummy= 1 if  !inlist(em_a,.,0) | !inlist(em_na,.,0)

gen list_activities = ""
replace list_activities=   anr_value + " " + ara_value if anr_value !="" & ara_value!=""
replace list_activities=   anr_value if anr_value !="" & ara_value==""
replace list_activities=   ara_value if anr_value =="" & ara_value!=""



gen selfemployed_mds= .
foreach number of local MDS_numbers {
replace selfemployed_mds = 1 if strpos(list_activities, "`number'")
}




gen selfemployed_fds=. 
foreach number of local FDS_numbers {
replace selfemployed_fds = 1 if strpos(list_activities, "`number'")
}



gen selfemployed_energy=.
foreach number of local energy {
replace selfemployed_energy = 1 if strpos(list_activities, "`number'")
}


gen selfemployed_ict=. 
foreach number of local ICT {
replace selfemployed_ict = 1 if strpos(list_activities, "`number'")
}

gen selfemployed_unclassified=. 
foreach number of local unclassified_numbers {
replace selfemployed_ict = 1 if strpos(list_activities, "`number'")
}

foreach x in mds fds energy ict unclassified {
replace selfemployed_`x'=0 if selfemployed30d_dummy==0 | /// no activity
(selfemployed_`x'!= 1  & list_activities!="" &  selfemployed30d_dummy !=.) // active but not in mds 
}

gen selfemployed_energy_ict=. 
replace selfemployed_energy_ict= 1 if selfemployed_energy==1 | selfemployed_ict==1
replace selfemployed_energy_ict= 0 if ! inlist(selfemployed_energy, 1 , .)  & ! inlist(selfemployed_ict, 1 , .)

gen selfemployed_mds_not_eict=. 
replace selfemployed_mds_not_eict= 1 if selfemployed_mds==1 & selfemployed_energy_ict==0
replace selfemployed_mds_not_eict= 0 if selfemployed_mds==0 | selfemployed_energy_ict==1

gen selfemployed_not_mds=. 
replace selfemployed_not_mds= 1 if selfemployed30d_dummy==1 & selfemployed_mds==0 
replace selfemployed_not_mds= 0 if selfemployed30d_dummy==0 | selfemployed_mds==1 


** D.3 Worked in MDS (employee or income_generating activity) **

gen worked30d_dummy= .
replace worked30d_dummy=1 if selfemployed30d_dummy==1 | employed30d_dummy==1
replace worked30d_dummy=0 if selfemployed30d_dummy==0 &  employed30d_dummy==0

gen worked6m_dummy= .
replace worked6m_dummy=1 if selfemployed6m_dummy==1 | employed6m_dummy==1
replace worked6m_dummy=0 if selfemployed6m_dummy==0 &  employed6m_dummy==0

foreach x in mds fds energy ict energy_ict unclassified {
gen worked_`x'= .
replace worked_`x'= 1 if employed_`x' == 1 | selfemployed_`x'==1
replace worked_`x'= 0 if employed_`x' == 0 & selfemployed_`x'==0


}

 
gen worked_not_energy_ict=  .
replace worked_not_energy_ict =1 if worked30d_dummy==1 & worked_energy_ict==0
replace worked_not_energy_ict =0 if worked30d_dummy==0 | worked_energy_ict==1

gen worked_mds_not_eict =  .
replace worked_mds_not_eict  =1 if worked_mds==1 & worked_energy_ict==0
replace worked_mds_not_eict  =0 if worked_mds==0 | worked_energy_ict==1

gen worked_not_mds =  .
replace worked_not_mds =1 if  worked30d_dummy==1 & worked_mds==0
replace worked_not_mds =0 if worked30d_dummy== 0 | worked_mds==1


** D.4 Training in MDS **

local train_mds = "$mds_training_numbers"
local train_fds = "not_mds_training_numbers"
local train_energy = "8 12  20" 
local train_ict =  "2 14"

gen train_field = ""
replace train_field = ed13_domaine if cohort==1 

gen train_dummy =  ed9_formationpro



forval i=1/29 {
 replace train_field= train_field +  "`i'" + " " if `i'<29 & ///
ed13_domaine_`i'==1 & cohort > 1 
 replace train_field= train_field + "`i'"   if `i'==29 & ///
ed13_domaine_`i'==1 & cohort > 1
}

foreach x in mds fds energy ict {
gen train_`x'= .
foreach number of local train_`x' {
replace train_`x'  = 1 if strpos(train_field, "`number'")
}
replace train_`x'= 0 if ed9_formationpro==0 | (train_`x'!=1 & train_field!="")
}

gen train_energy_ict = .
replace train_energy_ict = 1 if train_energy==1 | train_ict == 1
replace train_energy_ict = 0 if train_energy==0 & train_ict == 0

gen train_not_mds = .
replace train_not_mds = 1 if train_dummy==1 & train_mds==0
replace train_not_mds =0 if train_dummy==0 | train_mds==1

gen train_not_energy_not_ict= . 
replace train_not_energy_not_ict =  1 if train_dummy==1 & train_energy_ict==0
replace train_not_energy_not_ict =  0 if train_dummy==0 | train_energy_ict==1

gen train_mds_not_eict = . 
replace train_mds_not_eict  =  1 if train_mds==1 & train_energy_ict==0
replace train_mds_not_eict  =  0 if train_mds==0 | train_energy_ict==1

*********************************************
* E.  Network, environment & role models  ***
*********************************************

** E.1 Network size & characteristics**

gen n5_male = 0 
gen n5_female=0

gen n5_mds = 0 
gen n5_eict= 0 
gen n5_eict_male=0 

gen n5_mds_male = 0 
gen n5_fam = 0
gen n5_fr = 0 
gen n5_fam_male=0 
gen n5_fr_male=0

gen n5_mds_fr= 0
gen n5_eict_fr= 0 
gen n5_mds_fam= 0
gen n5_eict_fam= 0

gen n5_mds_not_eict = 0

set trace on 
forval i=1/10 {
replace  n5_female= n5_female + 1 if re2_gender_`i'==2
replace  n5_male= n5_male + 1 if re2_gender_`i'==1
replace n5_fam = n5_fam + 1 if re6_relation_`i'==1
replace n5_fr = n5_fr + 1 if re6_relation_`i'==2
replace n5_fam_male = n5_fam_male + 1 if re6_relation_`i'==1 & re2_gender_`i'==1
replace n5_fr_male = n5_fr_male + 1 if re6_relation_`i'==2 & re2_gender_`i'==1

foreach number of local MDS_numbers {
replace n5_mds = n5_mds + 1 if  re4_`i'== `number'
replace n5_mds_male = n5_mds_male + 1 if  re4_`i'== `number' & re2_gender_`i'==1
}

foreach number_mds of local MDS_numbers {
	foreach number_eict of local energy_ICT {
		
		replace n5_mds_not_eict = n5_mds + 1 if  re4_`i'== `number_mds' & re4_`i'!= `number_eict'
		replace n5_mds_not_eict = n5_mds_male + 1 if  re4_`i'== `number_mds' & re4_`i'!= `number_eict' & re2_gender_`i'==1
}
}


foreach number of local energy_ICT {
replace n5_eict = n5_eict + 1 if  re4_`i'== `number'
replace n5_eict_male = n5_eict_male + 1 if  re4_`i'== `number' & re2_gender_`i'==1

replace n5_eict_fam = n5_eict_fam + 1 if re4_`i'== `number' & re6_relation_`i'==1
replace n5_eict_fr = n5_eict_fr+ 1 if re4_`i'== `number' & re6_relation_`i'==2
}
}

set trace off

gen n5_size = n5_female + n5_male
gen network_size = n5_female + n5_male + r11_other

foreach x in male female mds mds_not_eict mds_male fam fr fam_male fr_male /// 
eict eict_male mds_fr mds_fam eict_fr eict_fam {
gen n5_`x'_prop= n5_`x' / (n5_size) 
replace n5_`x'_prop = 0 if n5_size == 0 

gen n5_`x'_dummy=.
replace n5_`x'_dummy=1 if n5_`x' > 0 & n5_`x'!=. 
replace n5_`x'_dummy=0 if (n5_size==0) | (n5_`x'==0)
}


gen n5_any= .
replace n5_any=1 if n5_size >0 & n5_size!=.
replace n5_any=0 if n5_size==0 

foreach var in n5_size n5_male n5_female n5_fr n5_fam  {
gen `var'_cat= .
replace `var'_cat= `var' if `var' <=3 
replace `var'_cat= 3 if inlist(`var', 3, 4, 5)
}


gen n5_oppositesex_dummy = 0 
replace n5_oppositesex_dummy =1 if (n5_male==1 & gender== 1) | (n5_female==1 & gender== 0)

** E.2 Percieved support from others **

*Nb: these Indicator are not available for cohort 1 

gen perceived_support= ca4a /10
gen perceived_mockery = ca4b /10


** E.3 Role models **
gen rm_dummy= as1_know 

* as1_know  know someone who has been successful in life to be renamed 
* tab as2  sector 
replace as4_lien= 12 if  as4_lien== 98 & (strpos(as4_1_lien_oth, "AMI") | strpos(as4_1_lien_oth,"AMIE") | ///
strpos(as4_1_lien_oth, "AMIS") | strpos(as4_1_lien_oth, "AMi") | strpos(as4_1_lien_oth,"Ami") | ///
strpos(as4_1_lien_oth,"Ami") | strpos(as4_1_lien_oth, "ami")  | /// 
strpos(as4_1_lien_oth, "amie") | strpos(as4_1_lien_oth,"Amis") | ///
 strpos(as4_1_lien_oth, "SIMPLE AMITIE")) & /// 
(!inlist(as4_1_lien_oth ,"EX PETIT AMI", "PETIT AMI" "FRERE D'UN AMI", "FRERE DE MON AMI", ///
"GR&E SOEUR A UNE AMIE", "GR&E SOEUR DE MON AMI", "L'ONCLE A MON AMI") | ///
!inlist(as4_1_lien_oth , "LA MAMAN A UN DE SES AMIS","LA MERE D UN AMI",  ///
"LE FRERE DE MON AMI","LE FRERE DE MON PETIT AMI", "LE PERE D UN AMI", "MAMAN DE SON AMI", ///
 "PERE D UN AMI", "UNE AMIE A MA MERE"))
 
gen rm_mds =. 
gen rm_not_mds =.
gen rm_mds_not_eict = .
gen rm_energy_ict=.  
gen rm_female=.
gen rm_male= .   
gen rm_mds_female=.
gen rm_energy_ict_female=. 
gen rm_fr= . 
gen rm_fam= . 
gen rm_fr_female= .
gen rm_fam_female = .

gen rm_mds_fr= .
gen rm_mds_fam = .

replace as3_gender = as3_gender - 1  if cohort> 1 

replace rm_male = 1 if as3_gender==0 
replace rm_male= 0 if as3_gender==1 |  as1_know==0 

replace rm_female = 1 if as3_gender==1
replace rm_female= 0 if as3_gender==0 | as1_know==0 

replace rm_mds = 1 if  inlist(as2_act,1, 3, 9, 10, 11, 12, 13, 14, ///
 15, 20, 22, 23, 26, 27, 32, 33, 34, 38, 39,40 )
replace rm_mds= 0 if ( as2_act!=. & rm_mds!= 1 ) | as1_know==0 

replace rm_not_mds = 1 if rm_dummy==1 & !inlist(as2_act,1, 3, 9, 10, 11, 12, 13, 14, ///
 15, 20, 22, 23, 26, 27, 32, 33, 34, 38, 39,40,. )
replace rm_not_mds = 0 if rm_dummy==0 | rm_mds==1 

replace rm_energy_ict = 1 if  inlist(as2_act, 10 , 12, 16, 27 )
replace rm_energy_ict= 0 if (as2_act!=. & rm_energy_ict!= 1) |as1_know==0 
 

replace rm_mds_not_eict = 1 if rm_mds == 1  & rm_energy_ict==0
replace rm_mds_not_eict = 0 if rm_mds == 0  | rm_energy_ict==1 

replace rm_fr= 1 if as4_lien==12 
replace rm_fr= 0 if !inlist(as4_lien, 12, .) | as1_know==0  

replace rm_fam=1 if as4_lien <=6 
replace rm_fam=0 if (as4_lien >6 &  as4_lien!=.)  |as1_know==0 

foreach x in mds energy_ict fr fam {
replace rm_`x'_female = 1 if rm_`x'==1 & rm_female==1 
replace rm_`x'_female = 0 if rm_`x'==0 | rm_female==0 | as1_know==0  
}

replace rm_mds_fr=1 if rm_mds== 1  & rm_fr==1 
replace rm_mds_fr=1 if rm_mds== 0  | rm_fr==1 

set trace on 
foreach x in fr fam {

replace rm_mds_`x'=1 if rm_mds== 1  & rm_`x'==1 
replace rm_mds_`x'=1 if rm_mds== 0  | rm_`x'==1  | as1_know==0  

gen rm_energy_ict_`x'=. 
replace rm_energy_ict_`x'=1 if rm_energy_ict== 1  & rm_`x'==1 
replace rm_energy_ict_`x'=1 if rm_energy_ict== 0  | rm_`x'==1  | as1_know==0  
}

gen rm_oppositesex= 0 
replace rm_oppositesex = 1 if (rm_male ==1 & gender ==1) | (rm_female==1 & gender==0)

*

foreach x in fr fam mds not_mds  {
	
gen rm_female_`x' = .
replace rm_female_`x' = 0 if rm_female == 0 | rm_`x'== 0 
replace rm_female_`x'  = 1 if rm_female == 1 & rm_`x'== 1 	
}

gen rm_female_eict = .
replace rm_female_eict = 0 if rm_female == 0 | rm_energy_ict== 0 
replace rm_female_eict  = 1 if rm_female == 1 & rm_energy_ict== 1 	
 

 
** E.4 Entourage (Non-family) support ** 

gen support= .
replace support=1 if as5_modelegender > 1 & as5_modelegender != .
replace support=0 if as5_modelegender ==1 

gen support_onlymale=.
replace support_onlymale=1 if as5_modelegender==3 
replace support_onlymale=0 if !inlist(as5_modelegender, 3, .)

gen support_onlyfemale=.
replace support_onlyfemale= 1 if as5_modelegender==2 
replace support_onlyfemale=0 if !inlist(as5_modelegender, 2, .)

gen support_bothsex=.
replace support_bothsex=1 if as5_modelegender==4 
replace support_bothsex=0 if !inlist(as5_modelegender, 4, .)

gen support_weekly=. 
replace support_weekly= 1 if as6_frequence== 1
replace support_weekly=0 if !inlist(as6_frequence, 1, .)


gen support_male=( support==1 & (support_onlymale==1 | support_bothsex==1))

********************************************
* F. Characteristics of the desired job  ***
********************************************

*Nb only availabe for cohort 1 

*****************************************
* G. Gender Norms / Gender Attitudes  ***
*****************************************

** G.1 Gender attitudes **
foreach var in ag3_role ag4_depenses ag2_conditions ag1_facilite ag2_conditions {

replace `var'= `var' + 2  if cohort==1 & `var' >=2 
replace `var'= `var' + 1 if cohort==1 & `var'<=1

}
gen ga_cook= . 
replace ga_cook= 1 if  inlist(ag3_role, 4, 5)
replace ga_cook= 0 if  !inlist(ag3_role, 4, 5, .)

gen  ga_expenses= . 
replace ga_expenses= 1 if inlist(ag4_depenses, 4, 5) 
replace ga_expenses= 0 if !inlist(ag4_depenses, 4, 5) 

gen ga_abilities =.
replace ga_abilities= 1 if inlist(ag1_facilite, 4, 5) 
replace ga_abilities= 0 if !inlist(ag1_facilite, 4, 5)

gen ga_conditions=.
replace ga_conditions= 1 if inlist(ag2_conditions, 4, 5)
replace ga_conditions=0 if !inlist(ag2_conditions, 4, 5)

gen ga_score=0 
foreach var in ag3_role ag4_depenses ag2_conditions ag1_facilite ag2_conditions {
replace ga_score= ga_score + 1 if `var'==2
replace ga_score= ga_score + 2 if `var'==3
replace ga_score= ga_score + 3 if `var'==4
replace ga_score= ga_score + 4 if `var'==5
} 

replace ga_score=.  if inlist(ga_expenses,.,98) & inlist(ga_cook, ., 98) ///
 & inlist(ga_abilities, ., 98) & inlist(ga_conditions, .,98) 

gen ga_zscore=.


forval i=1/ 2  { 

sum ga_score if cohort==`i'

replace ga_zscore= (ga_score - `r(mean)') / `r(sd)'  if cohort==`i'
}


gen ga_score_p = ga_score / 20 

*****************
* H.  Agency  ***
*****************


** H.1 Effective decision making **

foreach x in  b c e f g h j k l {
	replace ca2_`x' = 3 if inlist(ca2_`x' , 4, 5)
	replace ca3_`x' = 3 if inlist(ca2_`x' , 4, 5)
*Decision making categories

gen ca1_`x'_cat =. // =1 if respondent involved in the decision (joint decision)
replace  ca1_`x'_cat=1 if inlist(ca1_`x', 3, 7, 9 ) 
capture replace  ca1_`x'_cat=1 if (strpos(ca1_oth_`x', "MOI") & strpos(ca1_oth_`x', "ET") )
replace  ca1_`x'_cat= 2 if ca1_`x'==1   
 capture replace  ca1_`x'_cat= 2 if (strpos(ca1_oth_`x', "MOI") &  !strpos(ca1_oth_`x', "ET") ) // sole decision 
replace ca1_`x'_cat=0 if !inlist(ca1_`x'_cat , 1,2)  & ca1_`x'!=.

*Sole or joint decision making 
gen ca1_`x'_dummy =. // =1 if respondent involved in the decision
replace  ca1_`x'_dummy=1 if inlist(ca1_`x', 1, 3, 7, 9 ) 
capture replace ca1_`x'_dummy=1  if strpos(ca1_oth_`x', "MOI")
replace ca1_`x'_dummy=0 if ca1_`x'!= . & ca1_`x'_dummy!=1 


*Sole decision making 
gen ca1_`x'_soledecision =. // =1 if respondent involved in the decision
replace  ca1_`x'_soledecision=1 if ca1_`x' ==1 
capture replace  ca1_`x'_soledecision=1 if (strpos(ca1_oth_`x', "MOI") &  !strpos(ca1_oth_`x', "ET") )
replace ca1_`x'_soledecision=0 if ca1_`x'!= . & ca1_`x'_soledecision!=1 

*Joint 
gen ca1_`x'_jointdecision =. // =1 if respondent involved in the decision
replace  ca1_`x'_jointdecision=1 if inlist(ca1_`x', 3, 7, 9 ) 
capture replace  ca1_`x'_jointdecision=1 if (strpos(ca1_oth_`x', "MOI") & strpos(ca1_oth_`x', "ET") )
replace ca1_`x'_jointdecision=0 if ca1_`x'!= . & ca1_`x'_jointdecision!=1 

** H.2 Perceived ability of sole decision making **


gen ca2_`x'_dummy =. // =1 if respondent thinks he/ she can take the decision alone
replace  ca2_`x'_dummy=1 if ca2_`x'==3
replace ca2_`x'_dummy=0 if ca2_`x'!= . & ca2_`x'_dummy!=1 

}

foreach x in  b c e f g h  i j k l {
** H.3 Attitude on women’s rights in the community **
replace ca3_`x' = 3  if inlist(ca3_`x', 4,5)
gen ca3_`x'_dummy =. // =1 if respondent thinks he/ she can take the decision alone
replace  ca3_`x'_dummy=1 if ca3_`x'==3
replace ca3_`x'_dummy=0 if ca3_`x'!= . & ca3_`x'_dummy!=1 
}



** H.4 Computing scores for all agency related variables **

* Score for involvment in decisions(joint or sole decision maker) + perceived ability to make sole decisions if desired  + perceived ability of other women in the community 

local i= 1 
foreach x in involved agency agencycom {

if `i' ==1{
gen `x'_general = ca`i'_b_dummy + ca`i'_c_dummy + ca`i'_e_dummy  + ca`i'_f_dummy + ///
ca`i'_g_dummy  + ca`i'_h_dummy 

gen `x'_work = ca`i'_b_dummy + ca`i'_c_dummy
gen `x'_married_money = ca`i'_j_dummy + ca`i'_k_dummy + ca`i'_l_dummy
}

if `i' ==2{
gen `x'_general = ca`i'_b + ca`i'_c + ca`i'_e + ca`i'_f + ///
ca`i'_g  + ca`i'_h

gen `x'_work = ca`i'_b + ca`i'_c
gen `x'_married_money = ca`i'_j + ca`i'_k+ ca`i'_l
}

if `i' ==3 {
gen `x'_general = ca`i'_b + ca`i'_c+ ca`i'_e  + ca`i'_f + ///
ca`i'_g  + ca`i'_h + ca`i'_j

gen `x'_work = ca`i'_b + ca`i'_c



}

local i= `i' + 1 
}

*Score for joint decisions & score for sole decisions 

foreach x in jointdecision soledecision {

gen `x'_general = ca1_b_`x' + ca1_c_`x' + ca1_e_`x'  + ca1_f_`x' + ///
ca1_g_`x' + ca1_h_`x'

gen `x'_work = ca1_b_`x'+ ca1_c_`x'
gen `x'_married_money = ca1_j_`x'+ ca1_k_`x'+ ca1_l_`x'

}


foreach cat in general work  { // begin cat loop 

foreach x in involved agency agencycom jointdecision soledecision {  // begin x loop 

gen `x'_`cat'_zscore = .

forval i=1/2 {  // begin i loop
sum `x'_`cat' if cohort==`i'
if `r(N)' > 0 { // begin condition 
replace `x'_`cat'_zscore =(`x'_`cat' - `r(mean)') / `r(sd)'  if cohort==`i'
} // end condition 

} // end i loop 

} // end x loop 
} // end cat loop 


gen agency_general_p= agency_general / 18
gen agency_work_p= agency_work / 6

gen agencycom_general_p= agencycom_general / 21
gen agencycom_work_p= agencycom_work / 6



*****************************
* I. Cognitive abilities  ***
*****************************

gen cognitive_score= 0 

forval i=1/16 {
replace cognitive_score= cognitive_score + 1 if cc`i'==1
}
gen cognitive_score_z= .
forval i=1/2 {
sum cognitive_score if cohort==`i'

replace cognitive_score_z= (cognitive_score -`r(mean)') / `r(sd)' if cohort==`i'

}
gen cognitive_score_p = (cognitive_score / 16 )* 100




***************************************
* J. Savings / Credit & Borrowing ***
***************************************

** J.1 Savings **
replace ec11_total_savings = . if ec11_total_savings <0

egen wanted=rowmax(ec3-ec7 ec9) 

foreach var of varlist  ec3-ec7 ec9 {
gen `var'_bis=  `var'
replace `var'_bis= 0 if `var'_bis<0 | `var'_bis==. 
}


/* total_savings_understimate replace saving =0 if saving = . & at least 
one of the saving variables was not missing*/

gen total_savings_under= .
replace total_savings_under = ec3_bis +ec4_bis +ec5_bis + ec6_bis + ///
ec7_bis  + ec9_bis if !inlist(wanted, . , -999)
replace total_savings_under = . if inlist(wanted, . , -999)


drop wanted ec3_bis - ec9_bis

** J.2 Credit / Borrowing **



forval i=1/5 {
gen borrowing_k_plus_i_`i ' = cr3_montant_`i' + cr4_interet_`i'
replace borrowing_k_plus_i_`i ' =. if  cr3_montant_`i'<0 | cr4_interet_`i'< 0

gen lending_k_plus_i_`i ' = cr12_montant_`i' + cr13_interet_`i'
replace lending_k_plus_i_`i ' =. if  cr12_montant_`i'<0 | cr13_interet_`i'< 0
}

egen borrowing_totaldue= rowtotal(borrowing_k_plus_i_1-borrowing_k_plus_i_5 )  
replace borrowing_totaldue= 0 if cr1_credit==0 

gen borrow_business = .
forval i=1/5 {
replace borrow_business=1 if cr6_1_raisonpret_`i'==3
replace borrow_business=0 if !inlist(cr6_1_raisonpret_`i',3,.)
}

egen lending_totaldue= rowtotal(lending_k_plus_i_1-lending_k_plus_i_5 )  
replace lending_totaldue= 0 if cr8_pret==0 

gen lending_totalnet = lending_totaldue - borrowing_totaldue 

gen access_fund= .
replace access_fund= 1  if inlist(cr14_urgence, 1,2 ) 
replace access_fund= 0  if !inlist(cr14_urgence, 1,2 ,.) 


*****************************
* K. Revenues & Capital ***
*****************************

** K.1 Revenues ** 
quietly ds ar_a8_* ar_na8_* ar_s8_*
local all_rev  `r(varlist)'
scalar var_count = `:word count `all_rev'' // number of variables in varlist 
di var_count
gen missing_count= 0 

gen revenues_total= 0
foreach var of varlist ar_a8_* ar_na8_* ar_s8_* {

replace revenues_total= revenues_total + `var' if `var'>=0 & `var'!=.
replace missing_count= missing_count +1 if `var'==. | `var'<0
}

replace revenues_total=. if missing_count>=var_count
replace revenues_total = 0 if worked30d_dummy ==0

gen worked_paid30d_dummy = .

replace worked_paid30d_dummy = 0 if worked30d_dummy == 0 |  revenues_total == 0 
replace worked_paid30d_dummy = 1 if worked30d_dummy == 1 &  !inlist(revenues_total, ., 0)



drop missing_count 

egen revenues_total_q = xtile(revenues_total), by(cohort) nq(5)
egen revenues_aspiration_q = xtile(as10), by(cohort) nq(5)

gen revenues_rich= . 
replace revenues_rich = 1 if inlist(revenues_total_q, 4, 5)
replace revenues_rich = 0 if !inlist(revenues_total_q, 4, 5,.)

gen revenues_aspiration_rich= . 
replace revenues_aspiration_rich = 1 if inlist(revenues_aspiration_q, 4, 5)
replace revenues_aspiration_rich = 0 if !inlist(revenues_aspiration_q, 4, 5,.)

replace as10 =. if as10 <0
** K.2 Capital / Working assets  ** 

ds ep*a, not(type string)
local ep_varlist  `r(varlist)'

scalar var_count = `:word count `ep_varlist'' // number of variables in varlist 
gen missing_count= 0 

foreach var of varlist `ep_varlist'{
replace missing_count= missing_count +1 if `var'==. | `var'<0
}

egen t_max= rowtotal(`ep_varlist') // to determine if there is any asset 

gen total_value= 0 
foreach var of varlist ep*c {
replace total_value= total_value + `var' if `var'>0 & `var'!=.
}


gen assets_business_dummy = ep9 if cohort >1  
replace assets_business_dummy= 1 if cohort==1 & t_max >=1 & t_max!=.
replace assets_business_dummy= 0 if cohort==1 & t_max ==0 & missing_count != var_count

gen assets_business_value=ep10 if cohort > 1 & ep10>=0
replace assets_business_value= total_value if cohort==1 & missing_count != var_count
replace assets_business_value= .  if cohort==1 & missing_count >= var_count

drop total_value missing_count t_max

egen assets_business_q = xtile(assets_business_value), by(cohort) nq(5)

gen assets_business_rich = 1 if inlist(assets_business_q,4,5) 
replace assets_business_rich = 0 if !inlist(assets_business_q,4,5,.)

*********************
* L. Wealth Index ***
*********************

** L.1 Household wealth index  ** 
local dummies bm1 bm5 bm6 bm8  bm9  bm10 bm12 bm15  bm16 bm17  bm18   /// 
bm19_floor-bm23_power
foreach var of varlist `dummies'{
tab `var' cohort, m
}


local continuous_toclean bm5 bm6 bm8 bm9 bm10 bm12 bm15  bm16 bm18 
foreach var of varlist `continuous_toclean' {
destring `var'a, replace
replace `var'a=0 if `var'==0 // if doesn't possess the object , then number of object possessed=0 
}

local continuous bm5a bm6a bm8a bm9a bm10a bm12a bm15a bm16a bm18a

pca `dummies' , comp(1)
predict pc_dummies, score 
estat kmo // minimum acceptable value is 0.6 



pca `continuous' bm17 , comp(1)
predict pc_continuous, score // trying  to keep continuous variables 
estat kmo // minimum acceptable value is 0.6 

gen wealthindex_hh = .
replace wealthindex_hh = pc_dummies if cohort==1
replace wealthindex_hh = pc_continuous if cohort >1


egen wealth_hh_q = xtile(wealthindex_hh), by(cohort) nq(5)
gen wealth_hh_rich= inlist(wealth_hh_q, 4, 5)


gen wealthindex_hh_z=. 

forval i=1/2 {
sum wealthindex_hh if cohort==`i'
replace wealthindex_hh_z = (wealthindex_hh -`r(mean)') / `r(sd)' if cohort==`i'

}

** L.2 Individual wealth index  ** 
local toclean bm1 bm5 bm6 bm8 bm9 bm10 bm12 bm15  bm16 bm17 bm18 

set trace on
foreach var of varlist `toclean' {

replace `var'c=0 if `var'==0
replace `var'c=. if `var'c<0 & (`var'!=. | `var'<0)

gen `var'_dummy =. 
replace `var'_dummy = 1 if cohort >1 & `var'c >0 & `var'c !=. 
replace `var'_dummy = 1 if cohort ==1 & strpos(`var'b , "1")
replace `var'_dummy = 0 if cohort >1 & (`var' ==0 | `var'c ==0)
replace `var'_dummy = 0 if cohort ==1 & (`var' ==0 |(!strpos(`var'b , "1") & `var'b!="" ))
}
set trace off


local dummies bm*_dummy 


pca `dummies' , comp(1)
predict pca_indiv_dummies, score 
estat kmo // minimum acceptable value is 0.6 

pca bm1c bm5c bm6c bm8c bm9c bm10c bm12c bm15c  bm16c bm17c bm18c, comp(1)
predict pca_indiv_continue, score 
estat kmo // minimum acceptable value is 0.6 

gen wealthindex_indiv = .
replace wealthindex_indiv= pca_indiv_dummies if cohort==1
replace wealthindex_indiv= pca_indiv_continue if cohort>=1

egen wealth_indiv_q = xtile(wealthindex_indiv), by(cohort) nq(5)
gen wealth_indiv_rich= inlist(wealth_indiv_q, 4, 5)

gen wealthindex_indiv_z=. 
forval i=1/2 {
sum wealthindex_indiv if cohort==`i'
replace wealthindex_indiv_z = (wealthindex_indiv -`r(mean)') / `r(sd)' if cohort==`i'

}

************************
* M. Training Choice ***
************************

replace id_choix = "ENERGY" if id_choix == "lot_vt_energy"
replace id_choix = "LIPTON" if id_choix == "lot_vt_lipton"
replace id_choix = "SALARIED JOB" if id_choix == "lot_employment"
replace id_choix = "TIC" if id_choix == "lot_vt_TIC"
replace id_choix = "SELF-EMPLOYMENT" if id_choix == "lot_propre_affaire"

encode id_choix, gen(train_choice)


gen train_choice_mds=.
replace train_choice_mds= 1 if inlist(train_choice, 1,5)
replace train_choice_mds= 0 if !inlist(train_choice, 1,5,.)


gen train_choice_energy=.
replace train_choice_energy=  1 if train_choice== 1 
replace train_choice_energy = 0 if !inlist(train_choice, 1, . )

gen train_choice_lipton=.
replace train_choice_lipton=  1 if train_choice== 2 
replace train_choice_lipton = 0 if !inlist(train_choice, 2, . )


gen train_choice_salaried=.
replace train_choice_salaried=  1 if train_choice== 3 
replace train_choice_salaried = 0 if !inlist(train_choice, 3, . )

gen train_choice_selfemp=.
replace train_choice_selfemp=  1 if train_choice== 4 
replace train_choice_selfemp = 0 if !inlist(train_choice, 4, . )

gen train_choice_tic=.
replace train_choice_tic=  1 if train_choice== 5
replace train_choice_tic = 0 if !inlist(train_choice, 5, . )


gen train_choice_vt= .
replace train_choice_vt = 1 if inlist(train_choice, 1, 2, 5)
replace train_choice_vt = 0 if !inlist(train_choice, 1, 2, 5,.)


 


**************************
* N. Domestic violence ***
**************************
gen dm_attitude_score = vd1_att + vd2_att + vd3_att + vd4_att + vd5_att + vd6_att
gen dm_attitude_p = dm_attitude_score /6 
gen dm_attitude_zscore=. 
forval i=1/2 {
sum dm_attitude_score  if cohort==`i'
replace dm_attitude_zscore = (dm_attitude_score -`r(mean)') / `r(sd)' if cohort==`i'
}

gen dm_attitude_dummy =  (dm_attitude_score>=1) 

gen dm_violence_exp_score = vd7 + vd10 + vd13 + vd16 + vd19 + vd22 + vd25

gen dm_violence_exp_zscore = . 
forval i=1/1 {
sum dm_violence_exp_score if cohort==`i'
replace dm_violence_exp_zscore = (dm_violence_exp_score -`r(mean)') / `r(sd)' if cohort==`i'
}


**********************
* O. Risk Aversion ***
**********************
gen risk_aversion_score = 0 

foreach var in pr1 pr2 pr3 {
	replace risk_aversion_score = risk_aversion_score + 1 if `var'==2
}

