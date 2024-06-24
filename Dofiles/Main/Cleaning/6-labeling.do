/*******************************************************************************
*Project: 		    Pro-Jeune 
*Purpose: 			RENAMING AND LABELING 
*Authors: 		    Clara Delavallade, Manil Zenaki, Léa Rouanet, Estelle Koussoubé
*Last Edit:		    06/10/2023
*******************************************************************************/

****************************
* A. Socio-demographics  ***
****************************

** A.1 Respondent **

rename id_age_2 age_resp 
label var age_resp "Age of the respondent"

label var city "City"
label define citylbl 1 "Abidjan" 0 "Grand Bassam"
label val city citylbl
label val abidjan citylbl

label var abidjan "Abidjan"

label var zone "Zone"

rename id7_marital marital_status 
label var marital_status " Marital status of the respondent"
label def marital_statuslbl 1"Single" 2"Married" 3"Concubinage" 4 "Divorced" 5 "Widow/widower" 6 "Engaged"
label val  marital_status marital_statuslbl
label var married "Married, in concubinage or enganged"

label var gender "Woman"
label define genderlbl 0"Male" 1"Female"
label val gender genderlbl

label var male  "Male"
label define yes_nolbl 0 "No" 1 "Yes"
label val male yes_nolbl 

label var age_diff "Age gap in years (partner - respondent)"

label var kids_dummy "Has at least one dependent child"



** A.2 head of household **
label var hh "Head of household (Dummy)"
label val hh yes_nolbl 

label var hh_spouse "Spouse of the household head (Dummy)"
label val hh_spouse yes_nolbl

rename hh_laborforce hh_income_activity
label var  hh_income_activity "Household head has an an income-generating activity"

label var hh_sex "Head of household is a Female"

label var hh_age "Head of household age"

label var hh_educ "Highest class completed by the household head"
label define educlbl  -999 "Don't Know" 1 "No schooling" 2 "Kindergarten" ///
3 "1st year of primary school" 4 "2nd year primary school" 5 "3rd year primary school" ///
6 "4th year primary school" 7 "5thyear primary school" 8 "6th year primary school" /// 
9 "1st year of secondary school" 10 "2nd year of secondary school"  ///
11 "3rd year of secondary school" 12 "4rth year of secondary school" /// 
13 "1st year of high school" 14 "2nd year of high school" ///
15 "3rd year of high school" 16 "CAP" 17 "Bac" 18 "Higher education" 
label val hh_educ educlbl


label var hh_educ_some "Household head went to primary school"
label var hh_educ_primary "Household head completed primary school"
label var hh_educ_secondary "Household head completed secondary school"
label var hh_educ_high_school "Household head completed high school"
label var hh_educ_diploma "Household head has a least a high school diploma"
label var hh_educ_higher "Household head has a higher education"


** A.3 Househhold characteristics ** 
label var hh_size "Household size"
label var nbr_adults_hh "Number of adults in the household"
label var nbr_children_hh "Number of children in the household"
label var hh_size_female "Number of female adults in the household"
label var hh_size_male "Number of male adults in the household"
label var hh_female_adult_prop "Proportion of adult women in the household (denominator= total number of adults)"
label var hh_female_hh_prop "Proportion of adult women in the household (denominator= household size)"

rename se3_kids nkids_dependent 
label var nkids_dependent "number of dependent children"

label var nkids_dependent_cat "number of dependent children (top coded at 3)"
label define nkids_dependent_catlbl  0 "0" 1 "1" 2 "2" 3 ">=3"
label val nkids_dependent nkids_dependent_catlbl
*********************************
* B. Chores/ Domestic tasks   ***
*********************************

** B.1 Easy access to water (proxy for time spent fetching water) ** 

label var water_access "Drinking water in the home or subdivision/concentration" 
 
**  B.2 division of household and childrearing tasks **
label var worked_last24 "Spent some time working during the last 24 hours"
label var chores_last24 "Spent some time on chores during the last 24 hours"
label var time_working_last24 "Minutes spent working during the last 24 hours"
label var time_chores_last24 "Minutes spent on chores during the last 24 hours"
label var time_ratio "Time spent on chores divied by time spent working"



******************************************
* C.  Respondent Education/ Literacy   ***
******************************************
rename ed8b read  
rename ed8d write 
rename ed8c numerical_literacy
rename ed8e digital_literacy
rename ed7_highestclass educ

label var read "Can read an instruction manual in French"
label var write "Can write in French"
label var numerical_literacy "Can read an invoice or financial accounts"
label var digital_literacy "Can use a smartphone or a tablet"
label var educ "Highest class completed by the respondent"

label val educ educlbl 
label var educ_some "Respondent went to primary school"
label var educ_primary "Respondent  head completed primary school"
label var educ_secondary "Respondent  head completed secondary school"
label var educ_high_school "Respondent  head completed high school"
label var educ_diploma "Respondent  head has a least a high school diploma"
label var educ_higher "Respondent  head has a higher education"
 
label var educbis "Years of education"

label var went_secondary "Went to Secondary school"
label define went_secondarylbl 0 "No secondary schooling" 1"Secondary schooling"
label val went_secondary went_secondarylbl
****************************
* D.  Experience in MDS  ***
****************************
label var asr_value "list of activities conducted by the respondent as an employee or apprentice "
label var list_activities "list of income-generating activities conducted by the respondent"
label var train_field "list of all trainings the respondent had"

foreach x in mds fds energy ict energy_ict {
label var  employed_`x' "Employed as an employee or apprentice in `x' in the last 30 days"

label var  selfemployed_`x' "Self-employed or worked for the household in `x' in the last 30 days"

label var worked_`x' "Employed or self-employed in `x' in the last 30 days"

label var  train_`x' "Had a training in `x'"


}
label var train_not_energy_not_ict "Had a training but not in EICT"
label var train_mds_not_eict "Had a training  in MDS (excluding EICT)"
label var train_not_mds "Had a training but not in MDS"

label var worked_not_energy_ict "Wage employed or self-employed in the last 30 days but not in EICT"
label var worked_mds_not_eict  "Wage employed or self-employed the last 30 days in MDSs (excluding EICT)"
label var worked_not_mds "Wage employed or self-employed the last 30 days but not  in MDSs"


label var employed_mds_not_eict  "Wage employed the last 30 days in MDSs (excluding EICT)"
label var employed_not_mds "Wage employed the last 30 days but not  in MDSs"


label var selfemployed_mds_not_eict  "Self-employed the last 30 days in MDSs (excluding EICT)"
label var selfemployed_not_mds "Self-employed the last 30 days but not  in MDSs"

label var employed30d_dummy "Employed as an employee or apprentice in the last 30 days"
label var train_dummy "Had a professional training"
label var selfemployed30d_dummy "Had an income-generating activity in the last 30 days"
label var worked30d_dummy  "Employed or self-employed in the last 30 days"

label var employed6m_dummy "Employed as an employee or apprentice in the last 30 days"
label var selfemployed6m_dummy "Had an income-generating activity in the last 30 days"
label var worked6m_dummy  "Wage employed or self-employed in the last 30 days"
label var worked_paid30d_dummy "Had a paid job in the last 30 days"

**********************************
* E.  Network and role models  ***
**********************************

** E.1 Network size and characteristics**
label var network_size "Number of individuals in the network"
label var n5_size "Number of individuals mentioned as being in the top 5 contacts"

label var n5_any "Has at least one professional contact in his network"

label var n5_male "Number of males mentioned as being in the top 5 contacts"
label var n5_male_dummy "Has at least one man in his network"
label var n5_female "Number of females mentioned as being in the top 5 contacts"
label var n5_male_prop "Proportion of male contacts in the top 5 contacts "



label var n5_mds "Number of individuals working in MDS mentioned as being in the top 5 contacts"
label var n5_mds_not_eict "Number of individuals working in MDS(excluding EICT) mentioned as being in the top 5 contacts"
label var n5_mds_male "Number of males working in MDS mentioned as being in the top 5 contacts"
label var n5_mds_prop  "Proportion of individuals working in MDS mentioned as being in the top 5 contacts"
label var n5_mds_not_eict_prop  "Proportion of individuals working in MDS (excluding eict) mentioned as being in the top 5 contacts"
label var n5_mds_male_prop  "Proportion of males working in MDS mentioned as being in the top 5 contacts"


label var n5_fr "Number of friends mentioned as being in the top 5 contacts"
label var n5_fam "Number of relatives mentioned as being in the top 5 contacts"
label var n5_fr_male "Number of male friends mentioned as being in the top 5 contacts"
label var n5_fam_male  "Number of male relatives mentioned as being in the top 5 contacts"

label var n5_fr_prop "Proportion of friends mentioned as being in the top 5 contacts"
label var n5_fr_male_prop "Proportion of male friends mentioned as being in the top 5 contacts"
label var n5_fam_prop "Proportion of relatives mentioned as being in the top 5 contacts"
label var n5_fam_male_prop " Proportion of male relatives mentioned as being in the top 5 contacts"


label var n5_eict "Number of individuals working in energy or ICT mentioned as being in the top 5 contacts"
label var n5_eict_prop "Proportion of individuals working in energy or ICT mentioned as being in the top 5 contacts"
label var n5_eict_male "Number of males working in energy or ICT mentioned as being in the top 5 contacts"
label var n5_eict_male_prop  "Proportion of males working in energy or ICT mentioned as being in the top 5 contacts"

label var n5_mds_fr "Number of friends working in MDS mentioned as being in the top 5 contacts"
label var n5_mds_fam "Number of relatives working in MDS mentioned as being in the top 5 contacts"
label var n5_eict_fr "Number of friends working in energy or ICT mentioned as being in the top 5 contacts"
label var n5_eict_fam "Number of relatives working in energy or ICT mentioned as being in the top 5 contacts"
 
label var n5_mds_fr_prop "Proportion of friends working in MDS mentioned as being in the top 5 contacts"
label var n5_mds_fam_prop "Proportion of relatives working in MDS mentioned as being in the top 5 contacts"
label var n5_eict_fr_prop "Proportion of friends working in energy or ICT mentioned as being in the top 5 contacts"
label var n5_eict_fam_prop "Proportion of relatives working in energy or ICT mentioned as being in the top 5 contacts"

label var n5_eict_dummy "Has a contact working in EICT"
label var n5_mds_dummy "Has a contact working in a MDS"

label var n5_female_dummy "Has at least one female in the network"

label var n5_size "Network size (top coded at 3)"
label var n5_male "Number of male contacts (top coded at 3)"
label var n5_female "Number of female contacts (top coded at 3)"
label var n5_fam "Number of family contacts (top coded at 3)"
label var n5_fr "Number of friend contacts (top coded at 3)"
label var n5_oppositesex_dummy "Has at least one contact of opposite sex"

label define n5_size_catlbl 0 "0" 1 "1" 2 "2" 3 ">=3"
foreach var in n5_size n5_male n5_female n5_fam n5_fr {
label val `var'_cat n5_size_catlbl 
}
** E.2 Percieved support from others **

*Nb: these Indicator are only available for cohort 2 and 3 

label var perceived_support "Perceived percent. of people who would support the respondent if he/she started a new business"

label var perceived_mockery "Perceived percent. of people who would ridicule the respondent if he/she started an unsuccessful new business"


** E.3 Role models **
label var rm_dummy "Has a role model"
label var rm_mds "Has a role model working in a Male Dominated Sector"
label var rm_mds_not_eict "Has a role model working in MDSs (excluding EICT)"
label var rm_energy_ict "Has a role model working in the energy or ICT sectors"
label var rm_female "Has a female role model"
label var rm_male "Has a male role model"
label var rm_mds_female "Has a female role model working in a Male Dominated Sector"
label var rm_energy_ict_female "Has a female role model working in the energy or ICT sectors"
label var rm_fr "Role model is a friend"
label var rm_fam "Role model is a family member"
label var rm_fr_female "Role model is a female friend"
label var rm_fam_female "Role model is a female family member"


label var rm_mds_fr "Role model is a friend woking in a Male Dominated Sector"
label var rm_mds_fam  "Role model is a family member working in a Male Dominated Sector"
label var rm_energy_ict_fr "Role model is a friend working in the energy or ICT sectors"
label var rm_energy_ict_fam "Role model is a family member working in the energy or ICT sectors"
label var rm_oppositesex "Role model is off opposite sex"
** E.4 Entourage (Non-family) support ** 

label var support "Can ask for professional advice from people around him/her (outside the family) "

label var support_onlymale "Can ask for professional advice only from men around him/her"
label var support_onlyfemale "Can ask for professional advice only from women around him/her"
label var support_bothsex "Can ask for professional advice from both men and women around him/her" 
label var support_weekly "Ask for professional advice at least once a week from people around him/her"

********************************************
* F. Characteristics of the desired job  ***
********************************************

*Nb only availabe for cohort 1 
rename em25a job_money_ranking 
label var job_money_ranking "Ranking of the importance of money (1= most important)"

rename em25b job_flexibility_ranking 
label var job_flexibility_ranking "Ranking of the importance of a flexible working schedule(1= most important)"

rename em25c job_efforts_ranking 
label var job_efforts_ranking "Ranking of the importance of low physical efforts (1= most important)"

rename em25d job_useful_ranking  
label var job_useful_ranking "Ranking of the importance of being useful to the community (1= most important)"

foreach var in job_efforts_ranking job_flexibility_ranking job_money_ranking job_useful_ranking {
label define `var'lbl 1 "Most important characteristic" 2 "2nd most important" /// 
3 "3rd most important" 4 "Least important"
label val `var' `var'lbl
} 


**************************************
* G. Gender Norms / Gender biases  ***
**************************************
label var ga_cook "Agrees that women's most important role is to cook and take care of her home"
label var ga_expenses "Agrees that household expenses are the responsibility of the husband"
label var ga_abilities "Agrees that by nature men and women have different abilities in differenta areas"
label var ga_conditions "Agrees that at work, men cope better with difficult conditions than women."

label var ga_score "Gender attitudes score"
label var ga_score_p "Gender attitudesscore (1= agrees with all stereotypes, 0= agrees with none)"
label var ga_zscore "Gender attitudes zscore"

*****************
* H.  Agency  ***
*****************

local x  `" "Joint or sole effective decision regarding" "Joint effective decision regarding" "Sole effective decision regarding" "Effective decisions regarding" "'

local y `" "own business activities" "own employment and remuneration" "household s durable goods expenses" "household's minor expenses" "own serious health issues" "own daily tasks" "borrowing money" "investing money in a new business" "savings" "' 

local suffixe "dummy jointdecision soledecision cat" 
local letter  "b c e f g h j k l"

local n_x : word count `x'
local n_y : word count `y'

forval i= 1/`n_x' { //loop over x
local x_sentence : word `i' of `x'
local suff: word `i' of `suffixe'
forval j=1/`n_y' {

local y_sentence : word `j' of `y'
local l: word `j' of `letter'

local thislabel = "`x_sentence'" + " `y_sentence'"

label var ca1_`l'_`suff' "`thislabel'"



}

}


label var ca2_b_dummy "Perceives he/she could take decisions alone regarding own business activities"
label var ca2_c_dummy "Perceives he/she could take decisions alone regarding own employment and remuneration"
label var ca2_e_dummy "Perceives he/she could take decisions alone regarding household's durable goods expenses"
label var ca2_f_dummy "Perceives he/she could take decisions alone regarding household's minor expenses"
label var ca2_g_dummy "Perceives he/she could take decisions alone to deal with own serious health issues"
label var ca2_h_dummy "Perceives he/she could take decisions alone regarding own daily tasks"
label var ca2_j_dummy "CPerceives he/she could take decisions alone regarding borrowing money"
label var ca2_k_dummy "Perceives he/she could take decisions aloneregarding investing money in a new business"
label var ca2_l_dummy "Perceives he/she could take decisions alone regarding savings "


label var involved_general_zscore "Joint or sole decisions regarding own work, health, household expenses and daily tasks (zscore)"
label var involved_work_zscore "Joint or sole decisions in important decisions regarding own business activities, employment and remuneration (zscore)"

label var jointdecision_general_zscore "Joint decisions regarding own work, health, household expenses and daily tasks (zscore)"
label var jointdecision_work_zscore "Joint decisions in important decisions regarding own business activities, employment and remuneration (zscore)"

label var soledecision_general_zscore "Joint decisions regarding own work, health, household expenses and daily tasks (zscore)"
label var soledecision_work_zscore "Joint decisions in important decisions regarding own business activities, employment and remuneration (zscore)"

label var agency_general "Agency"
label var agency_general_p "Perceived ability to take decisions alone if desired (score=[0,1])"
label var agencycom_general_p "Perceives women in the community can take their own decisions (score=[0,1])"
label var agency_general_zscore "Perceived ability to take his/her own decision (zscore)" 
label var agency_work_zscore "Perceives he/she could take decisions alone regarding own business activities, employment and remuneration (zscore)"

label var agencycom_general_zscore "Perceived ability of women in the community to make their own decisions (zscore)"
label var agencycom_work_zscore "Perceives he/she could take decisions alone regarding own business activities, employment and remuneration (zscore)"


label define decision_catlbl 0 "Not involved" 1 "Joint decision"  2 "Sole decision"

foreach x in  b c e f g h j k l {
label val ca1_`x'_cat decision_catlbl
}



*****************************
* I. Cognitive abilities  ***
*****************************
label var cognitive_score "Number of correct answers out of 16 cognitive questions"
label var cognitive_score_p "Percentage of correct answers on cognitive questions"
label var cognitive_score_z "Cognitive score (z-score)"


***************************************
* J. Savings / Credit and Borrowing ***
***************************************
rename ec1 saved
label var saved "Saved during the last 6 months"

rename ec11_total_savings total_savings
label var total_savings "total savings"

label var total_savings_under "Underestimate of the total savings"


** J.2 Credit / Borrowing **
rename cr1_credit borrow 
rename cr8_pret lend 
label var borrow "Has loans or borrowed money"
label var borrow_business "Borrowed money for his/her business"
label var borrowing_totaldue  "Total amount borrowed"
label var lending_totaldue "Total amount of money lended"
label var access_fund "Declared being able to raise 200,000 CFA in one month"


** J.3 Financial Inclusion **
rename  cr0_compte bank_account 
label var bank_account " Has a bank account in his/her name"

*****************************
* K. Revenues and Capital ***
*****************************

** K.1 Revenues ** 
label var revenues_total "Total revenue earned during the last 30 days"
label var revenues_total_q "Quintiles of total revenue earned during the last 30days"
label var as10 "Monthly income would like to achieve in 10 years"
rename as10 revenues_aspiration 
** K.2 Capital / Working assets  ** 
label var assets_business_dummy "Has business assets"
label var assets_business_value "Value of all business assets owned in FCFA"
label var assets_business_q "Business assets quintiles by cohort"
label var assets_business_rich "Business assets top 2 quintiles"

*
*********************
* L. Wealth Index ***
*********************
label var wealthindex_hh "Household wealth index"
label var wealth_hh_q "Household wealth index quintile (by cohort)"
label var wealth_hh_rich  "Household is in the top 2 wealth quintile (by cohort)"
label var wealthindex_hh_z "Household wealth index by cohort (zscore)"

label var wealthindex_indiv "Respondent wealth index"
label var wealth_indiv_q "Respondent wealth index quintile (by cohort)"
label var wealth_indiv_rich  "Respondent is in the top 2 wealth quintile (by cohort)"
label var wealthindex_indiv_z "Respondent wealth index by cohort (zscore)"
************************
* M. Training Choice ***
************************
label var train_choice_mds "Want to be trained in energy or ICT"


label var train_choice_energy "Want to be trained in the energy sector"
label var train_choice_lipton "Want to be trained to work with lipton"
label var train_choice_salaried "Want to be trained to obtain a salaried job"
label var train_choice_selfemp "Want to be trained to be self-employed (generalist entrepreneurial pathway)"
label var train_choice_tic "Want to be trained in Technology Information and communication"
label var train_choice_vt "Want to be trained through vocational training"


**************************
* N. Domestic violence ***
**************************

label var dm_attitude_score "Score out of 6 (higher score means a higher propensity to justify domestic violence)"
label var dm_attitude_p " Attitude towards domestic violence (1= Think it is always justified, 0= Never justified)"
label var dm_attitude_zscore "Attitude towards domestic violence (z-score)"
label var dm_attitude_dummy "Domestic violence is justifiable"
label var dm_violence_exp_score "Domestic violence experienced (score out of 7)"
label var dm_violence_exp_zscore "Domestic violence experienced (z-score)"

**********************
* O. Risk Aversion ***
**********************
label var risk_aversion_score "Risk aversion score (0 = no risk aversion)"

***********
* Other ***
***********
local dummies married hh hh_spouse hh_income_activity hh_sex  hh_educ_some ///
hh_educ_primary hh_educ_secondary hh_educ_high_school hh_educ_diploma /// 
hh_educ_higher educ_some educ_primary educ_secondary educ_high_school ///
educ_diploma educ_higher read write numerical_literacy digital_literacy ///
employed* worked*  selfemployed*  *_dummy  train_mds ///
train_fds train_energy train_ict train_energy_ict ///
train_choice_mds rm* support* ga_cook ga_expenses ///
ga_abilities ga_conditions saved borrow_business borrow lend  access_funds ///
bank_account n5_any


foreach var of varlist `dummies' {
label val `var' yes_nolbl 
}

