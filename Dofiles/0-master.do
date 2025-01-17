
/*******************************************************************************
*Project: 		    Pro-Jeune 
*Purpose: 			Master File 
*Authors: 		    Clara Delavallade, Manil Zenaki, Léa Rouanet, Estelle Koussoubé
*Last Edit:		    06/10/2023
*******************************************************************************/

*******************
*** USER INPUTS ***
*******************
clear all
version 16.1 
set matsize 400
set varabbrev off
pause on
set more off
cap log close

 
 if "`c(username)'" == "manil"{
 	global maindir "C:\Users\manil\OneDrive\Documents\Work\WB\WB_projeune_paper-replication_package_v2"
	}
		
else{
	global maindir ==  "xxxx"
	}
		
display "$maindir"

global Data_raw "$maindir/Data/Raw"
global Data_intermediate "$maindir/Data/Intermediate"
global Data_final "$maindir/Data/Final"

global Dofiles_main_cleaning "$maindir/Dofiles/Main/Cleaning"
global Dofiles_main_tables "$maindir/Dofiles/Main/Tables"
global Dofiles_main_graphs"$maindir/Dofiles/Main/Graphs"

global Dofiles_appendix_graphs "$maindir/Dofiles/Appendix/Graphs"
global Dofiles_appendix_tables "$maindir/Dofiles/Appendix/Tables"

global Dofiles_slides_graphs "$maindir/Dofiles/Slides/Graphs"
global Dofiles_slides_tables "$maindir/Dofiles/Slides/Tables"

  
global Output "$maindir/Outputs"
global Table_main "$Output/Main/Tables"
global Graph_main "$Output/Main/Graphs"
global Table_appendix "$Output/Appendix/Tables"
global Graph_appendix "$Output/Appendix/Graphs"

global Table_slides "$Output/Slides/Tables"
global Graph_slides "$Output/Slides/Graphs"



* PACKAGES 

local packages = 0 // set to 1 to install required packages
	if `packages' {
		foreach egenmore  schemepack boottest listtab {
			capture which `package'
            if _rc == 111	ssc install `package'
		}
	}
        
		

set scheme white_tableau

log using $maindir/logfile, replace

set seed 1947 


		
**********************************************************
***I. ENV WORKING AND TRAINING SECTORS CLASSIFICATION  ***
**********************************************************
do "$Dofiles_main_cleaning/1-ENV_appending.do"
do "$Dofiles_main_cleaning/2-ENV_working_sector_classification.do"
do "$Dofiles_main_cleaning/3-ENV_training_sector_classification.do"

******************************************************
***II. PRO-JEUNES APPENDING, CLEANING AND LABELING ***
******************************************************

do "$Dofiles_main_cleaning/4-appending.do"
do "$Dofiles_main_cleaning/5-variables_creation.do"
do "$Dofiles_main_cleaning/6-renaming.do"

do "$Dofiles_main_cleaning/8-cleaning.do"




**********************************************
***III. VARIABLES & DESCRIPTIVE STATISTICS  **
**********************************************
do "$Dofiles_main_graphs/9-Figure_1_training_tracks_pie_chart.do"

do "$Dofiles_main_tables/10-Table_2_variables_in_analysis.do"

do "$Dofiles_main_tables/11-Table_3_descriptive_stats.do"


***********************
*** IV. Main Results **
***********************

* Tables 
do "$Dofiles_main_tables/12-Table_1_male_dominated_working_sectors.do"
do "$Dofiles_main_tables/13-Table_4_5_all_variables_simultaneously_theory.do"


* Figures


do "$Dofiles_main_graphs/14-Figure_2_sectors_male_prop_and_earnings.do"
do "$Dofiles_main_graphs/15-Figure_3_sociodemo.do"
do "$Dofiles_main_graphs/16-Figure_4_educ.do"
do "$Dofiles_main_graphs/17-Figure_5_experience.do"
do "$Dofiles_main_graphs/18-Figure_6_network.do"
do "$Dofiles_main_graphs/19-Figure_7_rolemodel.do"
do "$Dofiles_main_graphs/20-Figure_8_gender_attitudes.do"



**************
** Appendix **
**************

* Figures
do "$Dofiles_appendix_graphs/21-Appendix_Figure_A1.do"


*Tables
do "$Dofiles_appendix_tables/22-Table_A1_MDS_robustness_check.do"
do "$Dofiles_appendix_tables/24-Table_B1_Variable_selection.do"
do "$Dofiles_appendix_tables/25-Table_C1_isolated_factors.do"
do "$Dofiles_appendix_tables/26-Table_D1_role_models_characteristics"



log close