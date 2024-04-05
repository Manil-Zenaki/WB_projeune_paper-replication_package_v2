/*******************************************************************************************
*Project: 		    Pro-Jeune 
*Purpose: 			USING THE ENV 2015 DATASETS TO DETERMINE WHICH TRAINING SECTORS ARE MALE DOMINATED AND  THE MEDIAN EARNING IN EACH SECTOR
 
*Authors: 		    Clara Delavallade, Manil Zenaki, Léa Rouanet, Estelle Koussoubé
*Last Edit:		    06/10/2023
******************************************************************************************/

******************************************************
* A. Linking Pro-Jeunes Sectors and ENV Sectors ******
******************************************************


set seed 1947
use "$Data_intermediate/env_merged.dta", clear
numlabel, add
cls 
tab  resp_act1
gen act_projeune_number= . 



replace act_projeune_number=1 if inlist(resp_act1,121, 122, 123, 124, ///
125, 313, 318, 348 ) // Gestion/Enterpreneuriat/Business/Comptabilité

replace act_projeune_number=2 if inlist(resp_act1,59, 60, 61, 275) // Informatique/Bureautique


replace act_projeune_number=3 if inlist(resp_act1,498, 499, 500,501, 511, 535 ) // Textile/Couture/Broderie

replace act_projeune_number=4 if  inlist(resp_act1, 414) //Kitchen/pastry/restaurant

replace act_projeune_number=5 if inlist(resp_act1, 405, 411, 412,413,415) // Services in the hotel/restaurant industry

replace act_projeune_number=6 if  inlist(resp_act1, 418) // Hairdressing/Cosmetic care

replace act_projeune_number=7 if  inlist(resp_act1,496, 473) // Menuiserie/Ebenisterie/Charpenterie


replace act_projeune_number=8 if  inlist(resp_act1,69,  72, 480) // Electricity 


replace act_projeune_number=9 if  inrange(resp_act1,473, 478) | ///
inlist(resp_act1, 264, 266,302, 394, 395, 481, 541) // Maçonnerie/Construction/Plomberie/ Peinture
  

replace act_projeune_number= 10  if inlist(resp_act1,483) // Soudure 

replace act_projeune_number= 11  if inlist(resp_act1,211) // Maintenance industrielle

replace act_projeune_number=12 if  (resp_act1==270) // Heat and Air conditioning

replace act_projeune_number=13 if inlist(resp_act1,416, 417, 515,516, 517, 518, 514, 519,520 ) // Logistique/Transport/Conduite

replace act_projeune_number=14 if inlist(resp_act1,70, 267,268  ) // Electronics

replace act_projeune_number=15 if inlist(resp_act1,271, 303, 491, 492 ) // Mécanique générale

replace act_projeune_number=16 if  inlist(resp_act1,490 )  // Auto mechanics


replace act_projeune_number=17 if  inlist(resp_act1,537, 424 ) // Securité et gardiennage

replace act_projeune_number=18 if inlist(resp_act1,92, 95, 103, 104, ///
106, 107, 108, 196, 296 ) | inlist(resp_act1,109, 89, 199, 201, 202, 206, ///
293, 294, 298, 301, 193, 19, 321, 386, 387, 388, 391, 277, 385, 198) // Health


replace act_projeune_number = 19  if inlist(resp_act1,99, 461,243, 99, 239, ///
 241, 243, 319, 322, 323,341, 445, 446, ///
448, 344, 98, 540) // Agriculture 

replace act_projeune_number = 22  if inlist(resp_act1,150, 151, 152 ) // formation en langue 

replace act_projeune_number = 23  if inlist(resp_act1, 112, 114 , 116,  ///
117, 120,255, 256, 257,284, 285,  287, 289, 342)    // Enseignement 




replace act_projeune_number = 25  if inlist(resp_act1,224, 226)  // Douanes, Transit

replace act_projeune_number = 26  if inlist(resp_act1,484)   // Tuyauterie/Chaudronnerie

replace act_projeune_number = 27  if inlist(resp_act1,276, 253, 180)   // Audiovisuel (cameras, photos)

replace act_projeune_number = 28  if inlist(resp_act1,535)   // Blanchisserie/Nettoyage textile

replace act_projeune_number = 29  if inlist(resp_act1,169)   // Journaliste

replace act_projeune_number = 30 if inlist(resp_act1,170, 172, 173, 175, 178, 179,  181,   254, 334)   // Musique / sport



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


*************************
* C. Sector labels ******
*************************
local act_labels  "Business/accounting" ///
"Informatics" ///
"Textile/sewing/embroidery" ///
"Catering/cooking/pastry-making" ///
"Hotel industry/tourism" ///
"Hairdressing" ///
"Joinery/cabinetmaking/carpentry" ///
"Electricity" ///
"Masonry/construction/plumbing/painting" ///
"Welding" ///
"Industrial maintenance" ///
"Air conditioning/cooling" ///
"Logistics/transport" ///
"Electronics" ///
"General mechanical engineering" ///
"Automotive mechanics" ///
"Security/guarding" ///
"Health" ///
"Agriculture" ///
"Oil production" ///
"Health, safety/environment" ///
"Foreign language training" ///
"Teaching" /// 
"Computer graphics" ///
"Customs/transit" ///
"Piping / boilermaking" ///
"Audiovisual (cameras, photos)" ///
"Laundry/textile cleaning" ///
"Journalism" ///
"Music/sports" ///

gen act_label  = ""

local i = 1

foreach x in "`act_labels' "{
	
	local this_label : word `i' of "`act_labels'"
	replace act_label = "`this_label'" if act_projeune_number == `i'
	local i = `i' + 1 
}




drop if act_projeune_number == . 
order  act_projeune_number male_proportion earnings
sort act_projeune_number

local other_act  "Oil production*" "Health, safety/environment*" "Computer graphics*" 
 local i = 1 
foreach x in 20 21 24{
local this_label : word `i' of "`other_act'"

set obs `=_N+1'
replace act_projeune_number = `x' if _n == _N
replace act_label = "`this_label'" if _n == _N
local i = `i' + 1 
}


gen mds_75= (male_proportion >=0.75 & male_proportion != .)

levelsof act_projeune_number if mds_75 >= 0.75 & mds_75!= . 
global mds_training_numbers  `r(levels)'

levelsof act_projeune_number if mds_75 < 0.75
global not_mds_training_numbers  `r(levels)'

levelsof act_projeune_number if mds_75 == .
global unclassified_training_numbers  `r(levels)'

gsort - male_proportion -earnings -act_projeune_number

save "$Data_final/projeune_training_sector_classification.dta" , replace