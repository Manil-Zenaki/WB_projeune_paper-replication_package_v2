
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

  
global Output "$maindir/Outputs"
global Table_main "$Output/Main/Tables"
global Graph_main "$Output/Main/Graphs"
global Table_appendix "$Output/Appendix/Tables"
global Graph_appendix "$Output/Appendix/Graphs"



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
do "$Dofiles_main_cleaning/6-labeling.do"
do "$Dofiles_main_cleaning/7-cleaning.do"



**********************************
***III. DESCRIPTIVE STATISTICS  **
**********************************
do "$Dofiles_main_tables/8-Table_4_descriptive_stats.do"


***********************
*** IV. Main Results **
***********************

* Tables 
do "$Dofiles_main_tables/9-Table_1_male_dominated_working_sectors.do"
do "$Dofiles_main_tables/10-Table_2_male_dominated_training_sectors.do"
do "$Dofiles_main_tables/11-Table_3_MDS_robustness_check.do"


do "$Dofiles_main_tables/12-Table_5_6_all_variables_simultaneously.do"

* Figures


do "$Dofiles_main_graphs/13-Figure_2_sectors_male_prop_and_earnings.do"
do "$Dofiles_main_graphs/14-Figure_3_sociodemo.do"
do "$Dofiles_main_graphs/15-Figure_4_educ.do"
do "$Dofiles_main_graphs/16-Figure_5_experience.do"
do "$Dofiles_main_graphs/17-Figure_6_network.do"
do "$Dofiles_main_graphs/18-Figure_7_rolemodel.do"
do "$Dofiles_main_graphs/19-Figure_8_gender_attitudes.do"



**************
** Appendix **
**************

* Figures
do "$Dofiles_appendix_graphs/20-Appendix_Figure_A1.do"


log close