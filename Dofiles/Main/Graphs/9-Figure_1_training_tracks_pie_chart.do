/*******************************************************************************
*Project: 		    Pro-Jeune 
*Purpose: 			Training tracks pie chart
*Authors: 		    Clara Delavallade, Manil Zenaki, Léa Rouanet, Estelle Koussoubé
*Last Edit:		    06/10/2023
*******************************************************************************/
cls
use "$Data_final/cohorts_1_2_clean.dta", clear


tab train_choice, nolabel
bysort gender : tab train_choice

gen order = 1 if train_choice == 3
replace order = 2 if train_choice == 4
replace order = 3 if train_choice == 5
replace order = 4 if train_choice == 1
replace order = 5 if train_choice == 2

graph pie, over(train_choice) by(gender, note("")) ///
plabel(_all percent , format(%1.0f) color(white) size(*0.75)) ///
sort(order) ///
legend( label(4 "Vocational training: Energy")  label(5 "Vocational training: Retail")  label(1 "Wage-employment") ///
label(2 "General Entrepreneurship")  label(3 "Vocational training: ICT") ) 

graph export "$Graph_main/Figure_1_pie_chart_tracks.png", replace