
use "$Data_intermediate/env_merged.dta",clear

** A.1 Grouping sectors **

drop if resp_act1 == 998 


numlabel, add

gen resp_act1_grouped = .

local numbers 116 117 120 255 257 284 285 287 289 342
foreach i in `numbers' {
	
	quietly sum compensation_main if resp_act1 == `i', d
	local median_earning = `r(p50)' / 250.64 
	*display as error "`i': `median_earning'"
	
}


*replace resp_act1_grouped = 0 if inrange(resp_act1,112, 114) // Professor/Researcher

replace resp_act1_grouped = 1 if inlist(resp_act1, 112, 114 , 116, 117, 120,255, 256, 257,284, 285,  287, 289, 342) // Teaching and education 

tab resp_act1 if inrange(resp_act1,112, 120) | /// 
inrange(resp_act1,191,192) | inrange(resp_act1,255, 257) ///
| inlist(resp_act1, 284,285, 287, 289, 290, 342)   

replace resp_act1_grouped = 2 if inrange(resp_act1,1,22) | /// 
inrange(resp_act1,231,234) | inlist(resp_act1 , 184, 185, 258,  283, 346, 347, 351, 352,353, 223, 224, 328, 187, 311, 315) // Public administration

replace resp_act1_grouped = 3  if inrange(resp_act1,404, 405) | ///
inrange(resp_act1,411, 415) // Restauration and Hotellerie

replace resp_act1_grouped = 4 if inlist(resp_act1,416, 417, 515,516, 517, 518 ) // Transportation of people (bus/taxi) or goods

replace resp_act1_grouped = 5 if inlist(resp_act1,514, 519,520) // Machine operators

replace resp_act1_grouped = 6 if inrange(resp_act1,432,436) | /// Retail trade: foodstuffs
inlist(resp_act1,407, 408, 409, 440, 503 )

replace resp_act1_grouped = 7 if inrange(resp_act1,428, 431) ///
| inlist(resp_act1,437, 438, 442, 444, 525)  // Retail trade : other


replace resp_act1_grouped = 8 if inlist(resp_act1,537, 424) // Security guard

replace resp_act1_grouped = 9 if inlist(resp_act1,532,536, 533) // housekeeping


replace resp_act1_grouped = 10 if inlist(resp_act1,455, 454, 459) // Fishing

replace resp_act1_grouped = 11 if inrange(resp_act1,451, 453) | ///
inlist(resp_act1,99, 461, 462,243, 99, 239, 241, 243, 245, 319, 322, 323,341, 445, 446, ///
448, 457, 458, 344, 98, 540) // Agriculture /livestock

replace resp_act1_grouped = 12 if inlist(resp_act1,69, 70, 72, 463, 326,379, ///
244, 247, 267, 268, 270,273 )  // Energy

replace resp_act1_grouped = 13 if inlist(resp_act1,80, 82,483, 484, 485, 487, 272  ) // Metallurgy, welding, boiler making

replace resp_act1_grouped = 14 if inlist(resp_act1, 271, 303, 490, 491, 492  ) // Mechanics


replace resp_act1_grouped = 15 if inrange(resp_act1,473, 478) | ///
inlist(resp_act1,480, 481, 489, 541, 62, 63, 64, 66, 67, 302, 85, 264, 266, 394, 395)  // Construction 

replace resp_act1_grouped = 16 if inlist(resp_act1,498, 499, 500,501, 511, 535 ) // textile

replace resp_act1_grouped = 17 if inlist(resp_act1,339, 545, 546, 548,  549, ///
425, 186, 339 ) // Police, Military

** 

replace resp_act1_grouped = 20 if inlist(resp_act1,59, 60, 61, 71, 73, 269,  275, 383  )  // TIC


replace resp_act1_grouped = 21 if inlist(resp_act1,92, 95, 103, 104, 106, 107, 108, 196, 296 )  // Medecine
 
replace resp_act1_grouped = 22 if inlist(resp_act1,109, 89, 199, 201, 202, 206, ///
293, 294, 298, 301, 193, 198, 321, 386, 387, 388, 391, 277, 385, 198) // Health (other)



replace resp_act1_grouped = 23 if inlist(resp_act1, 218, 219  ) // Aviation



replace resp_act1_grouped = 24 if inlist(resp_act1,121, 122, 123, 124, ///
125, 313, 318, 348 ) // Accounting

replace resp_act1_grouped = 25 if inlist(resp_act1,128, 131, 134 ) // Law

replace resp_act1_grouped = 26 if inrange(resp_act1,154, 157) | inlist(resp_act1, 299, 189 ) // social


replace resp_act1_grouped = 27 if inlist(resp_act1,494, 495, 496, 497, 512) // Other Craftsmen



replace resp_act1_grouped = 28 if inlist(resp_act1, 212, 214, 215,220, 222,  543 ) // Maritime

replace resp_act1_grouped = 29 if inlist(resp_act1, 170, 171, 172, 173, 175, 178, 179, 180, 181,   254, 334) // Art et sport


drop if resp_act1_grouped ==.

label define resp_act1_groupedlbl 0 "Research and university teaching" 1 "Teaching" 2 "Public administration" ///  
3 "Restaurant" 4 "Transportation"  5 "Machine operation"  6 "Retail trade: food" ///
7 "Retail trade: other"  8 "Security guard" 9 "Housekeeping"   /// 
10 "Fishing" 11 "Agriculture/livestock" 12 "Energy" 13 "Metallurgy"  ///
14 "Mechanics" 15 "Construction" 16 "Textile" 17 "Police, Army" 18 "Joiner" 19 "Hairdressing" 20 "TIC"  ///
21 "Medecine" 22"Health (other)" 23 "Aviation" 24 "Acounting" 25 "Law" 26 "Social" ///
27 "Craftsmen (other)"  28 "Maritime" 29 "Art and Sport" 



label values resp_act1_grouped resp_act1_groupedlbl

rename resp_act1_grouped sector
rename male male_proportion
rename compensation_main earnings


** A.2 Male proportion **
preserve

collapse (mean) male_proportion [pweight=pond], by(sector) 

tempfile male_proportion
save `male_proportion'

** A.3 Male earnings **
restore
keep if !inlist(earnings, ., 0)
collapse (median) earnings [pweight=pond], by(sector) 

merge 1:1 sector using `male_proportion'
gen source = "ENV"

drop _merge

* Compute in PPP using worldbank PPP conversion factor
replace earnings =  earnings / 250.64 




***************
***B. GRAPH ***
***************

order earnings male_proportion
sort earnings male_proportion

gen lab_position = .

replace lab_position = 3 if inlist(sector, 1,4,5, 8,13,16, 17,23,  27) // right

replace lab_position = 9 if inlist(sector, 2, 3, 6,11,  18, 21, 22, 24, 26) // left


replace lab_position = 6 if inlist(sector, 9, 10) // bottom 

replace lab_position = 12 if inlist(sector, 7,15,  29) // top 






/*
label define resp_act1_groupedlbl 1 "Teaching" 2 "Public administration" ///  
3 "Restaurant" 4 "Transportation"  5 "Machine operation"  6 "Retail trade: food" ///
7 "Retail trade: other"  8 "Security guard" 9 "Housekeeping"   /// 
10 "Fishing" 11 "Agriculture/livestock" 12 "Energy" 13 "Metallurgy, welding"  ///
14 "Mechanics" 15 "Construction" 16 "Textile" 17 "Police, Army" 18 "Joiner" 19 "Hairdressing" 20 "TIC"  ///
21 "Medecine" 22"Health (other)" 23 "Aviation" 24 "Acounting" 25 "Law" 26 "Social" ///
27 "Craftsmen (other)"  28 "Maritime" 29 "Art and Sport" 
*/


twoway (scatter earnings male_proportion , color(black) ///
mlabcolor(black) mlabvposition(lab_position) mlabel(sector) mlabgap(0.1) ///
xline(0.75, lcolor(black) lstyle(line)) ///
xscale(lstyle(none) r(-0.2 1.2)) ///
xlabel( 0 0.2 0.4 0.6 0.75  1,  notick) ///
yscale( lstyle(none)) ///
title("") ///
ytitle("Median earnings PPP") xtitle("Proportion of men") ///
)

graph export "$Graph_main/Figure_2_ENV_earnings.png", replace
graph export "$Graph_main/Figure_2_ENV_earnings.svg", replace

