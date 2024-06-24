# ***************************************************************************************
# Project: 		    Pro-Jeune 
# Purpose: 			EXPLORING RELATIONSHIP BETWEEN Sociodemo characteristics AND TRAINING CHOICE
# Authors: 		    Clara Delavallade, Manil Zenaki, Léa Rouanet, Estelle Koussoubé
# Last Edit:		    06/10/2023
# ****************************************************************************************#
rm(list = ls(all.names = TRUE)) 
#Library
library(haven)
library(dplyr)
library(tidyr)
library(selectiveInference)

# Data 
main_path <-  'C:/Users/manil/OneDrive/Documents/Work/WB/WB_projeune_paper-replication_package_v2'
graph_path<- paste(main_path,"Outputs/Main/Graphs" , sep= "/")
table_path<- paste(main_path,"Outputs/Main/Tables" , sep= "/")
data_path <- paste(main_path, "Data/Final", sep= "/")

data <- read_dta(paste(data_path,"cohorts_1_2_clean.dta" , sep= "/"))

data$cohort1 <- as.numeric(data$cohort == 1)

#divide girls and boys 
data_girls =  data[data$gender== 1,]
data_boys=  data[data$gender==0,]

# ***********************
# * A.  Var selection  **
# ***********************

educ <- c("educbis_z",  "train_dummy", "train_mds", "train_mds_not_eict", 
          "train_energy_ict", "train_not_mds")


work <- c("employed6m_dummy", "worked_mds_not_eict" ,
          "worked_energy_ict", "worked_not_mds", "revenues_total_z")

sociodemo <- c("age_resp_z", "nkids_dependent_z", "hh_female_adult_prop_z", "wealth_hh_rich")

network <-  c("n5_any", "n5_size_z", "n5_male_prop_z", "n5_fam_prop_z", "n5_fr_prop_z",
              "n5_mds_not_eict_prop_z", "n5_eict_prop_z") 

rolemodel <- c("rm_dummy", "rm_male", "rm_female",  "rm_mds_not_eict", "rm_energy_ict",
               "support", "support_male" )

ga <- c("ga_score_z", "ga_cook", "ga_expenses", "ga_abilities", "ga_conditions", 
        "agency_general_z", "dm_attitude_score_z")


other_vars <- c("cohort1", "city")
predictor <-  c(educ, work, sociodemo, network, rolemodel, ga, other_vars)

x_matrix <- data.matrix(data_girls[,predictor])
y_matrix <-  data.matrix(data_girls[, "train_choice_mds"])
lasso <- lar(x=x_matrix, y= y_matrix)

postlasso1 <- larInf(lasso, type = "all", k = 7)

postlasso1_df <- data.frame(predictor[postlasso1$vars] ,postlasso1$sign, postlasso1$vars, postlasso1$pv)



postlasso2 <- larInf(lasso,sigma =estimateSigma(x_matrix, y_matrix)$sigmahat, type="aic", ntimes=1) 
postlasso2_df <- data.frame(predictor[postlasso2$vars] ,postlasso2$sign, postlasso2$vars, postlasso2$pv)

randomizedLassoInf(lasso)
  






# fit <- lar(x, y, maxsteps = 20 )
#larInf(fit,sigma =estimateSigma(x_matrix, y_matrix)$sigmahat, type="aic", ntimes=1)
