/*******************************************************************************************
*Project: 		    Pro-Jeune 
*Purpose: 			Table 1 : Male Dominated  Working Sectors and Median earnings 
USING THE ENV 2015 DATASETS TO DETERMINE WHICH PRO-JEUNES WORKING SECTORS ARE MALE DOMINATED 
 AND  THE MEDIAN EARNING IN EACH SECTOR
 
*Authors: 		    Clara Delavallade, Manil Zenaki, Léa Rouanet, Estelle Koussoubé
*Last Edit:		    06/10/2023
******************************************************************************************/



*************************
* A. Latex Table 1 ******
*************************

set seed 1947
use "$Data_final/projeune_working_sector_classification.dta", clear

local start_table "{\small\tabcolsep=3pt  % hold it local" ///
"\begin{longtable}{m{9cm}ccc}" ///
"\caption{Male dominated working sectors}" ///
"\label{tab:MDS_table}\\" ///
"\toprule" ///
"\textbf{Activity/Sector} &" ///
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
"We consider that electrical, mining/Oil workers and refrigeration" /// 
"and air conditioning belong to  the energy sector. Computer and electronics" /// 
"were assigned to ICT." /// 
"}" /// 
"\end{minipage} \\* \bottomrule" /// 
"\end{longtable}" /// 
"}"

listtab act_label mds_label male_proportion earnings using "$Table_main/Table_1_MDS_work.tex",  ///
 rs(tabular) missnum("NA") footlines("`end_table'") headlines("`start_table'") replace
 
