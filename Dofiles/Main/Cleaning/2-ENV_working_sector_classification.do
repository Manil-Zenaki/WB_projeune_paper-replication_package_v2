/*******************************************************************************************
*Project: 		    Pro-Jeune 
*Purpose: 			USING THE ENV 2015 DATASETS TO DETERMINE WHICH PRO-JEUNES WORKING SECTORS 	ARE MALE DOMINATED AND  THE MEDIAN EARNING IN EACH SECTOR
 
*Authors: 		    Clara Delavallade, Manil Zenaki, Léa Rouanet, Estelle Koussoubé
*Last Edit:		    06/10/2023
******************************************************************************************/

**********************************************************************
* A. Linking Pro-Jeunes working sectors and ENV working sectors ******
**********************************************************************


set seed 1947
use "$Data_intermediate/env_merged.dta", clear
numlabel, add
cls 
tab  resp_act1
gen act_projeune_number= . 

replace act_projeune_number=1 if inrange(resp_act1,432,436) | /// Retail trade: foodstuffs
inlist(resp_act1,407, 408, 409, 440, 503 )

replace act_projeune_number=2 if inrange(resp_act1,428, 431) ///
| inlist(resp_act1,437, 438, 442, 444, 525)  // Retail trade : other


replace act_projeune_number=3 if inrange(resp_act1,451, 453) | ///
inlist(resp_act1,99, 461, 462,243, 99, 239, 241, 243, 245, 319, 322, 323,341, 445, 446, ///
448, 457, 458, 344, 98, 540) // Agriculture /livestock

replace act_projeune_number=5 if  inlist(resp_act1, 414) //Kitchen/pastry/restaurant

replace act_projeune_number=6 if inlist(resp_act1, 405, 411, 412,413,415) // Services in the hotel/restaurant industry


replace act_projeune_number=7 if  inlist(resp_act1, 404, 532) // Housekeeping/ Governor
replace act_projeune_number=8 if  inlist(resp_act1,531,532, 533, 539) // Maintenance and cleaning/Surface technician



replace act_projeune_number=9 if inrange(resp_act1,473, 478) | ///
inlist(resp_act1,480, 481, 489, 541, 62, 63, 64, 66, 67, 302, 85, 264, 266, 394, 395)  // Construction 


replace act_projeune_number=10 if  inlist(resp_act1,69,  72, 480) // Electrician



replace act_projeune_number=13 if  inlist(resp_act1, 496) // Furniture making
replace act_projeune_number=14 if inlist(resp_act1, 271, 303, 491, 492 ) // General Mechanics
replace act_projeune_number=15 if  inlist(resp_act1,490 )  // Auto mechanics

replace act_projeune_number=16 if  inlist(resp_act1, 418) // Hairdressing/Cosmetic care


replace act_projeune_number=17 if  inlist(resp_act1,498, 499, 500,501, 511, 535 ) // textile




replace act_projeune_number=20 if  inlist(resp_act1,80, 82, 272, 487 ) // Metal Joining/Welding


replace act_projeune_number=21 if  inlist(resp_act1,537, 424 ) // security gard

replace act_projeune_number=22 if inlist(resp_act1,416, 417, 515,516, 517, 518 ) // Transportation of people (bus/taxi) or goods

replace act_projeune_number=24 if  inlist(resp_act1,40 ) // Factory worker/Industrial manufacturing




replace act_projeune_number=26 if inlist(resp_act1,273, 463 )  // Mining/Oil worker

replace act_projeune_number=29 if inrange(resp_act1,1,22) | /// 
inrange(resp_act1,231,234) | inlist(resp_act1 , 184, 185, 258,  283, 346, 347, 351, 352,353, 223, 224, 328, 187, 311, 315) // Public administration

replace act_projeune_number=31 if inlist(resp_act1, 112, 114 , 116,  ///
117, 120,255, 256, 257,284, 285,  287, 289, 342)    // Teaching and education professions

replace act_projeune_number=33 if inlist(resp_act1,455, 454, 459) // Fishing



replace act_projeune_number=39 if  inlist(resp_act1,483 ) // soudure

replace act_projeune_number=4 if  inlist(resp_act1, 408,435) // Food processing 
replace act_projeune_number=11 if (resp_act1==478) // Plumbing
replace act_projeune_number=12 if  (resp_act1==270) // Heat and Air conditioning
replace act_projeune_number=18 if  (resp_act1==507) // Cobbling
replace act_projeune_number=19 if resp_act1==533 // textile cleaning 
replace act_projeune_number=23 if inlist(resp_act1, 394 540, 541, 543) // manoeuvre
replace act_projeune_number=25 if  (resp_act1==427) // Pump operator
replace act_projeune_number=27 if  inlist(resp_act1, 59, 61, 70, 267,268 , 275, 493) // electronics
replace act_projeune_number=28 if  inlist(resp_act1, 253, 170, 171 , 172, 173, 175, 176, 178, 179,180, 181)  // artist 

replace act_projeune_number=30 if inlist(resp_act1, 95, 103, 104, 106, 107, 108, 109, 110, ///
155, 156, 157, 198, 199, 201, 202, 207, 277, 293, 294, 296, 297, 298, 299, 300, 321, ///
385, 386, 387, 388, 389, 391) // health

replace act_projeune_number=32 if  inlist(resp_act1, 295, 390) // Sewage
replace act_projeune_number=34 if inlist(resp_act1, 369, 370) // Real estate 

replace act_projeune_number=38 if  inlist(resp_act1, 481, 482 ) // Painting
replace act_projeune_number=40 if (resp_act1==484) // Piping/boil making
replace act_projeune_number=43 if  inlist(resp_act1, 254, 255, 291, 332, 334, 337) // sports
replace act_projeune_number=44 if inlist(resp_act1, 284, 285) // tutor (private teacher)


replace act_projeune_number=45 if  inrange(resp_act1, 2, 10) // Political party leader 
replace act_projeune_number=46 if inlist(resp_act1, 62, 103, 104, 106, 108, 109, 110, 123, 128, 129, 131, 132, 153,  169, 204, 293, 294, 375) // "Liberal intellectual and scientific professions(journalists, lawyers, accountants, etc.)"

 replace act_projeune_number=47 if inlist(resp_act1,182,183) // Priest / Pastor / Imam
 
replace act_projeune_number=48 if inlist(resp_act1,53, 77, 89) // Chemical technician

rename male male_proportion
rename compensation_main earnings




**************************************************************************
* B. Computing Male proportion and  median earnings for each sector ******
**************************************************************************
preserve

collapse (mean) male_proportion [pweight=pond], by(act_projeune_number) 

tempfile male_proportion
save `male_proportion'


restore
keep if !inlist(earnings, ., 0)
collapse (median) earnings [pweight=pond], by(act_projeune_number) 

merge 1:1 act_projeune_number using `male_proportion'

* Compute in PPP using worldbank PPP conversion factor
replace earnings =  round(earnings / 250.64, 1) 

drop _merge
gen ict = 0 
replace ict = 1  if inlist(act_projeune_number,27)

gen energy = 0 
replace energy = 1 if inlist(act_projeune_number,10,12,26)
*************************
* C. Sector labels ******
*************************
local act_labels "Retail trade: foodstuffs" ///
"Retail trade: other" ///
"Agriculture/livestock" ///
"Food/beverage processing" ///
"Kitchen/pastry/restaurant" ///
"Services in the hotel/restaurant industry" ///
"Governor" ///
"Maintenance and cleaning/surface technician" ///
"Construction (masonry/scaffolding)" ///
"Electricity" ///
"Plumbing" ///
"Refrigeration and air conditioning" ///
"Furniture making" ///
"General mechanics" ///
"Auto mechanics" ///
"Hairdressing/cosmetic care" ///
"Textile: sewing/embroidery/weaving/dyeing" ///
"Cobbling" ///
"Laundry/Textile Cleaning" ///
"Metal joining" ///
"Security guard" ///
"Transportation of people (bus/taxi) or goods"  ///
"Material handling" ///
"Factory worker/industrial manufacturing" ///
"Pump operator (gas station)" ///
"Mining/oil worker" ///
"Computer/Electronics/computer and mobile repair" ///
"Artist/art Maker/photographer/musician" ///
"Public administration" ///
"Health and social work professions (doctors, pharmacists, nurses, other)" ///
"Teaching and education professions" ///
"Sewage and refuse disposal" ///
"Fishing" ///
"Real estate activity" ///
"Telephone booth" ///
"Discotheque" ///
"Video game room" ///
"Painting" ///
"Welding" ///
"Piping/Boil making" ///
"Chair/chapel rental" ///
"Miscellaneous services (campaigns, events, etc.)" ///
"Sports" ///
"Tutor (private teacher)" ///
"Political party leader/executive" ///
"Liberal intellectual and scientific professions(journalists, lawyers, accountants, etc.)" ///
"Priest/Pastor/Imam/Marabout" ///
"Chemical technician" 

gen act_label  = ""

local i = 1

foreach x in "`act_labels' "{
	
	local this_label : word `i' of "`act_labels'"
	replace act_label = "`this_label'" if act_projeune_number == `i'
	local i = `i' + 1 
}

replace act_label =  act_label + " [ICT]" if ict ==1 
replace act_label =  act_label + " [Energy]" if energy ==1 

drop if act_projeune_number == . 
order  act_projeune_number male_proportion earnings
sort act_projeune_number

local other_act  "Telephone booth*" "Discotheque*" "Video game room*" ///
 "Chair/chapel rental*" "Miscellaneous services (campaigns, events, etc.)*" /// 
 "Other*"

 local i = 1 
foreach x in 35 36 37 41 42 98{
local this_label : word `i' of "`other_act'"

set obs `=_N+1'
replace act_projeune_number = `x' if _n == _N
replace act_label = "`this_label'" if _n == _N
local i = `i' + 1 
}


gen mds_75= (male_proportion >=0.75 & male_proportion!=.)

levelsof act_projeune_number if male_proportion >= 0.75 & male_proportion!= . 
global mds_working_numbers  `r(levels)'

levelsof act_projeune_number if male_proportion< 0.75
global not_mds_working_numbers  `r(levels)'

levelsof act_projeune_number if male_proportion == .
global unclassified_working_numbers  `r(levels)'

gen mds_label = ""
replace mds_label = "MDS"  if mds_75 == 1
replace mds_label = "Not MDS"  if mds_75 != 1

replace male_proportion= round(male_proportion *100 , 0.01)
gsort - male_proportion -earnings -act_projeune_number

save $Data_final/projeune_working_sector_classification.dta , replace