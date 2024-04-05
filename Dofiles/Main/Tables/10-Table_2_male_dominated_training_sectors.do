/*******************************************************************************************
*Project: 		    Pro-Jeune 
*Purpose: 			Table 2 : Male dominated  training sectors and median earnings 
USING THE ENV 2015 DATASETS TO DETERMINE WHICH TRAINING SECTORS ARE MALE DOMINATED 
 AND  THE MEDIAN EARNING IN EACH SECTOR
 
*Authors: 		    Clara Delavallade, Manil Zenaki, Léa Rouanet, Estelle Koussoubé
*Last Edit:		    06/10/2023
******************************************************************************************/



*************************
* A. Latex Table 2 ******
*************************
set seed 1947
use "$Data_final/projeune_training_sector_classification.dta", clear

gen mds_label = ""
replace mds_label = "MDS"  if mds_75 == 1
replace mds_label = "Not MDS"  if mds_75 != 1

replace male_proportion= round(male_proportion *100 , 0.01)
gsort - male_proportion

local start_table "{\small\tabcolsep=3pt  % hold it local" ///
"\begin{longtable}{m{9cm}ccc}" ///
"\caption{Male dominated training sectors}" ///
"\label{tab:MDS_table}\\" ///
"\toprule" ///
"\textbf{Training sector} &" ///
"\textbf{Category} &" ///
"\textbf{Male percentage} &" ///
"\textbf{Median earning PPP} \\* \midrule" ///
"\endfirsthead" ///
"%" ///
"\multicolumn{4}{c}%" ///
"{{\bfseries Table \thetable\ continued from previous page}} \\" ///
"\toprule" ///
"\textbf{Activity/Sector} &" ///
"\textbf{Category} &" ///
"\textbf{Male percentage} &" ///
"\textbf{Median earning PPP} \\* \midrule" ///
"\endhead" ///
"%" ///
"\endfoot" ///
"%" ///
"\endlastfoot" ///

local end_table  "\midrule" ///
"\begin{minipage}{17cm}" /// 
"\small{" /// 
"{\textit Notes:} \\"  /// 
"*Not MDS   by default. \\" ///
"We consider that electricity, oil production and air conditioning" /// 
"belong to  the energy sector. Informatics and electronics" /// 
"were assigned to ICT." /// 
"}" /// 
"\end{minipage} \\* \bottomrule" /// 
"\end{longtable}" /// 
"}"

listtab act_label mds_label male_proportion earnings using "$Table_main/Table_2_MDS_training.tex",  ///
 rs(tabular) missnum("NA") footlines("`end_table'") headlines("`start_table'") replace
 

