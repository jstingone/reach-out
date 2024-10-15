#Updated on 7/25 to change pollutant contrast

## 0 Load packages

library(tidyverse)
library(dplyr)
library(haven)
library(survival)
library(survminer)
library(naniar)
library(sandwich)
library(lmtest)
library(readxl)
library(multcomp)
library(openxlsx)

## 1 Prepare Insight Data for Modeling

insight_covid_encounters_nevi = read_sas("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Cong/Datasets/insight_covid_encounters_nevi.sas7bdat")

averages <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Cong/Datasets/AP&NEVI_Merged.xlsx", 
                       sheet = "Averages")

ap_quartiles <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Cong/Datasets/AP&NEVI_Merged.xlsx", 
                           sheet = "Quartiles")

nevi_tertiles <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Cong/Datasets/AP&NEVI_Merged.xlsx", 
                            sheet = "Tertiles")

## Hard-coded Headings

no2_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Headings.xlsx", 
                           sheet = "NO2")

no2_demo_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Headings.xlsx", 
                                sheet = "NO2_DemoNEVI")

no2_econ_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Headings.xlsx", 
                                sheet = "NO2_EconNEVI")

no2_res_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Headings.xlsx", 
                               sheet = "NO2_ResNEVI")

no2_health_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Headings.xlsx", 
                                  sheet = "NO2_HealthNEVI")


bc_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Headings.xlsx", 
                          sheet = "BC")

bc_headings_40cov <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Headings.xlsx", 
                          sheet = "BC_40cov")                          

bc_demo_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Headings.xlsx", 
                               sheet = "BC_DemoNEVI")

bc_demo_headings_40cov <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Headings.xlsx", 
                          sheet = "BC_DemoNEVI_40cov")                               

bc_econ_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Headings.xlsx", 
                               sheet = "BC_EconNEVI")

bc_econ_headings_40cov <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Headings.xlsx", 
                          sheet = "BC_EconNEVI_40cov")                                  

bc_res_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Headings.xlsx", 
                              sheet = "BC_ResNEVI")

bc_res_headings_40cov <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Headings.xlsx", 
                          sheet = "BC_ResNEVI_40cov")   

bc_health_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Headings.xlsx", 
                                 sheet = "BC_HealthNEVI")

bc_health_headings_40cov <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Headings.xlsx", 
                          sheet = "BC_HealthNEVI_40cov")   



o3_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Headings.xlsx",
                          sheet = "O3")

o3_demo_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Headings.xlsx", 
                               sheet = "O3_DemoNEVI")

o3_econ_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Headings.xlsx", 
                               sheet = "O3_EconNEVI")

o3_res_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Headings.xlsx", 
                              sheet = "O3_ResNEVI")

o3_health_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Headings.xlsx", 
                                 sheet = "O3_HealthNEVI")


pm_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Headings.xlsx",
                          sheet = "PM")

pm_headings_40cov <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Headings.xlsx", 
                          sheet = "PM_40cov")                          

pm_demo_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Headings.xlsx", 
                               sheet = "PM_DemoNEVI")

pm_demo_headings_40cov <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Headings.xlsx", 
                          sheet = "PM_DemoNEVI_40cov")  

pm_econ_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Headings.xlsx", 
                               sheet = "PM_EconNEVI")

pm_econ_headings_40cov <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Headings.xlsx", 
                          sheet = "PM_EconNEVI_40cov")                                  

pm_res_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Headings.xlsx", 
                              sheet = "PM_ResNEVI")

pm_res_headings_40cov <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Headings.xlsx", 
                          sheet = "PM_ResNEVI_40cov")                             

pm_health_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Headings.xlsx", 
                                 sheet = "PM_HealthNEVI")

pm_health_headings_40cov <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Headings.xlsx", 
                          sheet = "PM_HealthNEVI_40cov")   

## References

Ref_BC <- c("LowBC_LowNEVI", 1, "","")

Ref_NO2 <- c("LowNO2_LowNEVI", 1, "","")

Ref_PM <- c("LowPM_LowNEVI", 1, "","")

Ref_O3 <- c("LowO3_LowNEVI", 1, "","")

Ref_BC_40cov <- c("MediumBC_LowNEVI", 1, "","")

Ref_PM_40cov <- c("MediumPM_LowNEVI", 1, "","")


Ref_Demo_BC <- c("LowBC_LowDemoNEVI", 1, "","")

Ref_Demo_NO2 <- c("LowNO2_LowDemoNEVI", 1, "","")

Ref_Demo_PM <- c("LowPM_LowDemoNEVI", 1, "","")

Ref_Demo_O3 <- c("LowO3_LowDemoNEVI", 1, "","")

Ref_Demo_BC_40cov <- c("MediumBC_LowDemoNEVI", 1, "","")

Ref_Demo_PM_40cov <- c("MediumPM_LowDemoNEVI", 1, "","")


Ref_Econ_BC <- c("LowBC_LowEconNEVI", 1, "","")

Ref_Econ_NO2 <- c("LowNO2_LowEconNEVI", 1, "","")

Ref_Econ_PM <- c("LowPM_LowEconNEVI", 1, "","")

Ref_Econ_O3 <- c("LowO3_LowEconNEVI", 1, "","")

Ref_Econ_BC_40cov <- c("MediumBC_LowEconNEVI", 1, "","")

Ref_Econ_PM_40cov <- c("MediumPM_LowEconNEVI", 1, "","")


Ref_Res_BC <- c("LowBC_LowResNEVI", 1, "","")

Ref_Res_NO2 <- c("LowNO2_LowResNEVI", 1, "","")

Ref_Res_PM <- c("LowPM_LowResNEVI", 1, "","")

Ref_Res_O3 <- c("LowO3_LowResNEVI", 1, "","")

Ref_Res_BC_40cov <- c("MediumBC_LowResNEVI", 1, "","")

Ref_Res_PM_40cov <- c("MediumPM_LowResNEVI", 1, "","")



Ref_Health_BC <- c("LowBC_LowHealthNEVI", 1, "","")

Ref_Health_NO2 <- c("LowNO2_LowHealthNEVI", 1, "","")

Ref_Health_PM <- c("LowPM_LowHealthNEVI", 1, "","")

Ref_Health_O3 <- c("LowO3_LowHealthNEVI", 1, "","")

Ref_Health_BC_40cov <- c("MediumBC_LowHealthNEVI", 1, "","")

Ref_Health_PM_40cov <- c("MediumPM_LowHealthNEVI", 1, "","")

## Continuous Headings

cont_no2_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings.xlsx", 
                           sheet = "NO2_Cont_NEVI")

cont_no2_demo_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings.xlsx", 
                           sheet = "NO2_Cont_DemoNEVI")

cont_no2_econ_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings.xlsx", 
                           sheet = "NO2_Cont_EconNEVI")

cont_no2_res_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings.xlsx", 
                           sheet = "NO2_Cont_ResNEVI")

cont_no2_health_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings.xlsx", 
                           sheet = "NO2_Cont_HealthNEVI")


cont_no2_int_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings.xlsx", 
                           sheet = "NO2_Cont_Int_NEVI")
 
cont_no2_int_demo_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings.xlsx", 
                           sheet = "NO2_Cont_Int_DemoNEVI")                          

cont_no2_int_econ_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings.xlsx", 
                           sheet = "NO2_Cont_Int_EconNEVI") 

cont_no2_int_res_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings.xlsx", 
                           sheet = "NO2_Cont_Int_ResNEVI")     

cont_no2_int_health_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings.xlsx", 
                           sheet = "NO2_Cont_Int_HealthNEVI")    



cont_bc_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings.xlsx", 
                           sheet = "BC_Cont_NEVI")

cont_bc_demo_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings.xlsx", 
                           sheet = "BC_Cont_DemoNEVI")

cont_bc_econ_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings.xlsx", 
                           sheet = "BC_Cont_EconNEVI")

cont_bc_res_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings.xlsx", 
                           sheet = "BC_Cont_ResNEVI")

cont_bc_health_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings.xlsx", 
                           sheet = "BC_Cont_HealthNEVI")


cont_bc_int_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings.xlsx", 
                           sheet = "BC_Cont_Int_NEVI")
 
cont_bc_int_demo_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings.xlsx", 
                           sheet = "BC_Cont_Int_DemoNEVI")                          

cont_bc_int_econ_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings.xlsx", 
                           sheet = "BC_Cont_Int_EconNEVI") 

cont_bc_int_res_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings.xlsx", 
                           sheet = "BC_Cont_Int_ResNEVI")     

cont_bc_int_health_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings.xlsx", 
                           sheet = "BC_Cont_Int_HealthNEVI")  


                          

cont_pm_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings.xlsx", 
                           sheet = "PM_Cont_NEVI")

cont_pm_demo_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings.xlsx", 
                           sheet = "PM_Cont_DemoNEVI")

cont_pm_econ_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings.xlsx", 
                           sheet = "PM_Cont_EconNEVI")

cont_pm_res_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings.xlsx", 
                           sheet = "PM_Cont_ResNEVI")

cont_pm_health_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings.xlsx", 
                           sheet = "PM_Cont_HealthNEVI")


cont_pm_int_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings.xlsx", 
                           sheet = "PM_Cont_Int_NEVI")
 
cont_pm_int_demo_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings.xlsx", 
                           sheet = "PM_Cont_Int_DemoNEVI")                          

cont_pm_int_econ_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings.xlsx", 
                           sheet = "PM_Cont_Int_EconNEVI") 

cont_pm_int_res_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings.xlsx", 
                           sheet = "PM_Cont_Int_ResNEVI")     

cont_pm_int_health_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings.xlsx", 
                           sheet = "PM_Cont_Int_HealthNEVI")  


                      
cont_o3_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings.xlsx", 
                           sheet = "O3_Cont_NEVI")

cont_o3_demo_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings.xlsx", 
                           sheet = "O3_Cont_DemoNEVI")

cont_o3_econ_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings.xlsx", 
                           sheet = "O3_Cont_EconNEVI")

cont_o3_res_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings.xlsx", 
                           sheet = "O3_Cont_ResNEVI")

cont_o3_health_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings.xlsx", 
                           sheet = "O3_Cont_HealthNEVI")


cont_o3_int_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings.xlsx", 
                           sheet = "O3_Cont_Int_NEVI")
 
cont_o3_int_demo_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings.xlsx", 
                           sheet = "O3_Cont_Int_DemoNEVI")                          

cont_o3_int_econ_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings.xlsx", 
                           sheet = "O3_Cont_Int_EconNEVI") 

cont_o3_int_res_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings.xlsx", 
                           sheet = "O3_Cont_Int_ResNEVI")     

cont_o3_int_health_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings.xlsx", 
                           sheet = "O3_Cont_Int_HealthNEVI")  

## Categorical Headings

cat_no2_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                                sheet = "NO2_Cat_NEVI")

cat_no2_demo_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                                     sheet = "NO2_Cat_DemoNEVI")

cat_no2_econ_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                                     sheet = "NO2_Cat_EconNEVI")

cat_no2_res_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                                    sheet = "NO2_Cat_ResNEVI")

cat_no2_health_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                                       sheet = "NO2_Cat_HealthNEVI")


cat_no2_int_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                                    sheet = "NO2_Cat_Int_NEVI")

cat_no2_int_demo_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                                         sheet = "NO2_Cat_Int_DemoNEVI")                          

cat_no2_int_econ_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                                         sheet = "NO2_Cat_Int_EconNEVI") 

cat_no2_int_res_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                                        sheet = "NO2_Cat_Int_ResNEVI")     

cat_no2_int_health_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                                           sheet = "NO2_Cat_Int_HealthNEVI")    



cat_bc_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                               sheet = "BC_Cat_NEVI")

cat_bc_demo_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                                    sheet = "BC_Cat_DemoNEVI")

cat_bc_econ_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                                    sheet = "BC_Cat_EconNEVI")

cat_bc_res_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                                   sheet = "BC_Cat_ResNEVI")

cat_bc_health_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                                      sheet = "BC_Cat_HealthNEVI")


cat_bc_int_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                                   sheet = "BC_Cat_Int_NEVI")

cat_bc_int_demo_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                                        sheet = "BC_Cat_Int_DemoNEVI")                          

cat_bc_int_econ_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                                        sheet = "BC_Cat_Int_EconNEVI") 

cat_bc_int_res_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                                       sheet = "BC_Cat_Int_ResNEVI")     

cat_bc_int_health_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                                          sheet = "BC_Cat_Int_HealthNEVI")  

cat_bc_int_headings_40cov <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                                   sheet = "BC_Cat_Int_NEVI_40cov")

cat_bc_int_headings_40cov_ph23 <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                                   sheet = "BC_Cat_Int_NEVI_40cov_ph2&3")


cat_pm_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                               sheet = "PM_Cat_NEVI")

cat_pm_demo_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                                    sheet = "PM_Cat_DemoNEVI")

cat_pm_econ_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                                    sheet = "PM_Cat_EconNEVI")

cat_pm_res_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                                   sheet = "PM_Cat_ResNEVI")

cat_pm_health_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                                      sheet = "PM_Cat_HealthNEVI")


cat_pm_int_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                                   sheet = "PM_Cat_Int_NEVI")

cat_pm_int_demo_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                                        sheet = "PM_Cat_Int_DemoNEVI")                          

cat_pm_int_econ_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                                        sheet = "PM_Cat_Int_EconNEVI") 

cat_pm_int_res_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                                       sheet = "PM_Cat_Int_ResNEVI")     

cat_pm_int_health_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                                          sheet = "PM_Cat_Int_HealthNEVI")  



cat_o3_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                               sheet = "O3_Cat_NEVI")

cat_o3_demo_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                                    sheet = "O3_Cat_DemoNEVI")

cat_o3_econ_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                                    sheet = "O3_Cat_EconNEVI")

cat_o3_res_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                                   sheet = "O3_Cat_ResNEVI")

cat_o3_health_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                                      sheet = "O3_Cat_HealthNEVI")


cat_o3_int_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                                   sheet = "O3_Cat_Int_NEVI")

cat_o3_int_demo_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                                        sheet = "O3_Cat_Int_DemoNEVI")                          

cat_o3_int_econ_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                                        sheet = "O3_Cat_Int_EconNEVI") 

cat_o3_int_res_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                                       sheet = "O3_Cat_Int_ResNEVI")     

cat_o3_int_health_headings <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings.xlsx", 
                                          sheet = "O3_Cat_Int_HealthNEVI")  


## Continuous Headings (Cox Models)

cont_no2_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings_Cox.xlsx", 
                                sheet = "NO2_Cont_NEVI")

cont_no2_demo_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings_Cox.xlsx", 
                                     sheet = "NO2_Cont_DemoNEVI")

cont_no2_econ_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings_Cox.xlsx", 
                                     sheet = "NO2_Cont_EconNEVI")

cont_no2_res_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings_Cox.xlsx", 
                                    sheet = "NO2_Cont_ResNEVI")

cont_no2_health_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings_Cox.xlsx", 
                                       sheet = "NO2_Cont_HealthNEVI")


cont_no2_int_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings_Cox.xlsx", 
                                    sheet = "NO2_Cont_Int_NEVI")

cont_no2_int_demo_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings_Cox.xlsx", 
                                         sheet = "NO2_Cont_Int_DemoNEVI")                          

cont_no2_int_econ_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings_Cox.xlsx", 
                                         sheet = "NO2_Cont_Int_EconNEVI") 

cont_no2_int_res_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings_Cox.xlsx", 
                                        sheet = "NO2_Cont_Int_ResNEVI")     

cont_no2_int_health_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings_Cox.xlsx", 
                                           sheet = "NO2_Cont_Int_HealthNEVI")    



cont_bc_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings_Cox.xlsx", 
                               sheet = "BC_Cont_NEVI")

cont_bc_demo_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings_Cox.xlsx", 
                                    sheet = "BC_Cont_DemoNEVI")

cont_bc_econ_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings_Cox.xlsx", 
                                    sheet = "BC_Cont_EconNEVI")

cont_bc_res_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings_Cox.xlsx", 
                                   sheet = "BC_Cont_ResNEVI")

cont_bc_health_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings_Cox.xlsx", 
                                      sheet = "BC_Cont_HealthNEVI")


cont_bc_int_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings_Cox.xlsx", 
                                   sheet = "BC_Cont_Int_NEVI")

cont_bc_int_demo_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings_Cox.xlsx", 
                                        sheet = "BC_Cont_Int_DemoNEVI")                          

cont_bc_int_econ_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings_Cox.xlsx", 
                                        sheet = "BC_Cont_Int_EconNEVI") 

cont_bc_int_res_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings_Cox.xlsx", 
                                       sheet = "BC_Cont_Int_ResNEVI")     

cont_bc_int_health_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings_Cox.xlsx", 
                                          sheet = "BC_Cont_Int_HealthNEVI")  




cont_pm_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings_Cox.xlsx", 
                               sheet = "PM_Cont_NEVI")

cont_pm_demo_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings_Cox.xlsx", 
                                    sheet = "PM_Cont_DemoNEVI")

cont_pm_econ_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings_Cox.xlsx", 
                                    sheet = "PM_Cont_EconNEVI")

cont_pm_res_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings_Cox.xlsx", 
                                   sheet = "PM_Cont_ResNEVI")

cont_pm_health_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings_Cox.xlsx", 
                                      sheet = "PM_Cont_HealthNEVI")


cont_pm_int_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings_Cox.xlsx", 
                                   sheet = "PM_Cont_Int_NEVI")

cont_pm_int_demo_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings_Cox.xlsx", 
                                        sheet = "PM_Cont_Int_DemoNEVI")                          

cont_pm_int_econ_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings_Cox.xlsx", 
                                        sheet = "PM_Cont_Int_EconNEVI") 

cont_pm_int_res_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings_Cox.xlsx", 
                                       sheet = "PM_Cont_Int_ResNEVI")     

cont_pm_int_health_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings_Cox.xlsx", 
                                          sheet = "PM_Cont_Int_HealthNEVI")  



cont_o3_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings_Cox.xlsx", 
                               sheet = "O3_Cont_NEVI")

cont_o3_demo_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings_Cox.xlsx", 
                                    sheet = "O3_Cont_DemoNEVI")

cont_o3_econ_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings_Cox.xlsx", 
                                    sheet = "O3_Cont_EconNEVI")

cont_o3_res_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings_Cox.xlsx", 
                                   sheet = "O3_Cont_ResNEVI")

cont_o3_health_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings_Cox.xlsx", 
                                      sheet = "O3_Cont_HealthNEVI")


cont_o3_int_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings_Cox.xlsx", 
                                   sheet = "O3_Cont_Int_NEVI")

cont_o3_int_demo_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings_Cox.xlsx", 
                                        sheet = "O3_Cont_Int_DemoNEVI")                          

cont_o3_int_econ_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings_Cox.xlsx", 
                                        sheet = "O3_Cont_Int_EconNEVI") 

cont_o3_int_res_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings_Cox.xlsx", 
                                       sheet = "O3_Cont_Int_ResNEVI")     

cont_o3_int_health_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Continuous_Headings_Cox.xlsx", 
                                          sheet = "O3_Cont_Int_HealthNEVI")  

## Categorical Headings (Cox Models)

cat_no2_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings_Cox.xlsx", 
                               sheet = "NO2_Cat_NEVI")

cat_no2_demo_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings_Cox.xlsx", 
                                    sheet = "NO2_Cat_DemoNEVI")

cat_no2_econ_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings_Cox.xlsx", 
                                    sheet = "NO2_Cat_EconNEVI")

cat_no2_res_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings_Cox.xlsx", 
                                   sheet = "NO2_Cat_ResNEVI")

cat_no2_health_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings_Cox.xlsx", 
                                      sheet = "NO2_Cat_HealthNEVI")


cat_no2_int_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings_Cox.xlsx", 
                                   sheet = "NO2_Cat_Int_NEVI")

cat_no2_int_demo_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings_Cox.xlsx", 
                                        sheet = "NO2_Cat_Int_DemoNEVI")                          

cat_no2_int_econ_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings_Cox.xlsx", 
                                        sheet = "NO2_Cat_Int_EconNEVI") 

cat_no2_int_res_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings_Cox.xlsx", 
                                       sheet = "NO2_Cat_Int_ResNEVI")     

cat_no2_int_health_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings_Cox.xlsx", 
                                          sheet = "NO2_Cat_Int_HealthNEVI")    



cat_bc_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings_Cox.xlsx", 
                              sheet = "BC_Cat_NEVI")

cat_bc_demo_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings_Cox.xlsx", 
                                   sheet = "BC_Cat_DemoNEVI")

cat_bc_econ_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings_Cox.xlsx", 
                                   sheet = "BC_Cat_EconNEVI")

cat_bc_res_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings_Cox.xlsx", 
                                  sheet = "BC_Cat_ResNEVI")

cat_bc_health_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings_Cox.xlsx", 
                                     sheet = "BC_Cat_HealthNEVI")


cat_bc_int_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings_Cox.xlsx", 
                                  sheet = "BC_Cat_Int_NEVI")

cat_bc_int_demo_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings_Cox.xlsx", 
                                       sheet = "BC_Cat_Int_DemoNEVI")                          

cat_bc_int_econ_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings_Cox.xlsx", 
                                       sheet = "BC_Cat_Int_EconNEVI") 

cat_bc_int_res_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings_Cox.xlsx", 
                                      sheet = "BC_Cat_Int_ResNEVI")     

cat_bc_int_health_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings_Cox.xlsx", 
                                         sheet = "BC_Cat_Int_HealthNEVI")  




cat_pm_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings_Cox.xlsx", 
                              sheet = "PM_Cat_NEVI")

cat_pm_demo_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings_Cox.xlsx", 
                                   sheet = "PM_Cat_DemoNEVI")

cat_pm_econ_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings_Cox.xlsx", 
                                   sheet = "PM_Cat_EconNEVI")

cat_pm_res_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings_Cox.xlsx", 
                                  sheet = "PM_Cat_ResNEVI")

cat_pm_health_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings_Cox.xlsx", 
                                     sheet = "PM_Cat_HealthNEVI")


cat_pm_int_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings_Cox.xlsx", 
                                  sheet = "PM_Cat_Int_NEVI")

cat_pm_int_demo_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings_Cox.xlsx", 
                                       sheet = "PM_Cat_Int_DemoNEVI")                          

cat_pm_int_econ_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings_Cox.xlsx", 
                                       sheet = "PM_Cat_Int_EconNEVI") 

cat_pm_int_res_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings_Cox.xlsx", 
                                      sheet = "PM_Cat_Int_ResNEVI")     

cat_pm_int_health_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings_Cox.xlsx", 
                                         sheet = "PM_Cat_Int_HealthNEVI")  



cat_o3_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings_Cox.xlsx", 
                              sheet = "O3_Cat_NEVI")

cat_o3_demo_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings_Cox.xlsx", 
                                   sheet = "O3_Cat_DemoNEVI")

cat_o3_econ_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings_Cox.xlsx", 
                                   sheet = "O3_Cat_EconNEVI")

cat_o3_res_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings_Cox.xlsx", 
                                  sheet = "O3_Cat_ResNEVI")

cat_o3_health_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings_Cox.xlsx", 
                                     sheet = "O3_Cat_HealthNEVI")


cat_o3_int_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings_Cox.xlsx", 
                                  sheet = "O3_Cat_Int_NEVI")

cat_o3_int_demo_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings_Cox.xlsx", 
                                       sheet = "O3_Cat_Int_DemoNEVI")                          

cat_o3_int_econ_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings_Cox.xlsx", 
                                       sheet = "O3_Cat_Int_EconNEVI") 

cat_o3_int_res_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings_Cox.xlsx", 
                                      sheet = "O3_Cat_Int_ResNEVI")     

cat_o3_int_health_headings_cox <- read_excel("L:/dcore-prj0131-SHARED/dcore-prj0131-Stingone/INSIGHT_Kannoth/Programs/Categorical_Headings_Cox.xlsx", 
                                         sheet = "O3_Cat_Int_HealthNEVI")  



vector_averages <- as.vector(averages)
vector_ap_quartiles <- as.vector(ap_quartiles)
vector_nevi_tertiles <- as.vector(nevi_tertiles)

km_df = insight_covid_encounters_nevi %>% 
  filter(sex %in% c('Female', 'Male')) %>% 
  mutate(death = case_when(discharge_disposition == "Expired" ~ 1,
                           discharge_disposition == "Alive" ~ 0),
         nevi = nevi * 10,
         score_demo = score_demo * 10,
         score_economic = score_economic * 10,
         score_residential = score_residential * 10,
         score_healthstatus = score_healthstatus * 10,
         bc_avg = bc_avg * 10) %>%
  dplyr:: select(death, hospital_days, pm_avg, bc_avg, no2_avg, o3_avg,
                 nevi, score_demo, score_economic, score_residential, score_healthstatus,
                 age, sex, admit_date_phase, bmi_num, smoke, race, hispanic, address_zip, ards, asthma, hyper, diabetes, dialysis, vent, pneumo) %>%
  na.omit() %>%  
  mutate(nevi = nevi - vector_averages[[2]][6],
         score_demo = score_demo - vector_averages[[2]][7],
         score_economic = score_economic - vector_averages[[2]][8],
         score_residential = score_residential - vector_averages[[2]][9],
         score_healthstatus = score_healthstatus - vector_averages[[2]][10],
         pm_avg = pm_avg -vector_averages[[2]][1],
         bc_avg = bc_avg - vector_averages[[2]][2],
         no2_avg = no2_avg - vector_averages[[2]][3],
         o3_avg = o3_avg - vector_averages[[2]][5],
         smoke = as.factor(smoke),
         race = as.factor(race),
         address_zip = as.factor(address_zip),
         asthma = as.factor(asthma),
         diabetes = as.factor(diabetes),
         hyper= as.factor(hyper),
         age_cat = dplyr::case_when(
           age >= 20 & age <65 ~ "Less than 65 years",
           age >= 65 ~ "65 years and older"),
         age_cat = factor(age_cat, level = c("Less than 65 years", "65 years and older")), 
         bmi_cat = dplyr::case_when(
           bmi_num >= 10 & bmi_num < 18.5 ~ "Underweight",
           bmi_num >= 18.5 & bmi_num <25 ~ "Healthy Weight",
           bmi_num >= 25 & bmi_num < 30 ~ "Overweight",
           bmi_num >= 30 & bmi_num < 35 ~ "Obesity Class I",
           bmi_num >= 35 & bmi_num < 40 ~ "Obesity Class II",
           bmi_num >= 40 & bmi_num <= 90 ~ "Obesity Class III",
           bmi_num < 10 | bmi_num > 90 ~ "Biologically Impossible"),
         child = dplyr::case_when(
           age >= 2 & age <= 19 ~ "Child",
           age > 19 ~ "NotaChild"),
         child = factor(child),
         infant = dplyr::case_when(
           age < 2 ~ "Infant",
           age >= 2 ~ "NotaInfant"),
         infant = factor(infant),
         discharge = dplyr::case_when(
           death == 1 ~ 0,
           death == 0 ~ 1
         ),
         no_diabetes = dplyr::case_when(
           diabetes == 1 ~ 0,
           diabetes == 0 ~ 1
         ),
         no_asthma = dplyr::case_when(
           asthma == 1 ~ 0,
           asthma == 0 ~ 1
         ))


km_df["bmi_cat"][km_df["bmi_cat"] == "Biologically Impossible"] <- NA
km_df["age_cat"][km_df["age"]< 20] <- NA
km_df <- na.omit(km_df)
km_df$bmi_cat = factor(km_df$bmi_cat, level = c("Underweight", "Healthy Weight", "Overweight", "Obesity Class I", "Obesity Class II", "Obesity Class III"))
km_df$bmi_cat<-relevel(km_df$bmi_cat, "Healthy Weight")

#Obtain IQR
quantile(km_df$bc_avg)  #~2.3
quantile(km_df$no2_avg) #~4.2
quantile(km_df$pm_avg)  #0.9
quantile(km_df$o3_avg)  #1.7

km_df$bc_avg2<-km_df$bc_avg/2
km_df$no2_avg5<-km_df$no2_avg/5
km_df$pm_avg1<-km_df$pm_avg/1
km_df$o3_avg1<-km_df$o3_avg/1

## Excluding those with previous dialysis
km_df <- subset(km_df, dialysis == c(0,1))

## 2 Recode NEVI (based on zip code)

##NEVI
library(dplyr)
km_df <- mutate(km_df, nevi_tertiles = ifelse(nevi<=vector_nevi_tertiles[[2]][1], "Low",ifelse( nevi<=vector_nevi_tertiles[[2]][2], "Medium", "High")))

km_df$nevi_tertiles <- factor(km_df$nevi_tertiles, c("Low", "Medium", "High"))
summary(km_df$nevi_tertiles)

##Demo NEVI
library(dplyr)
km_df <- mutate(km_df, demo_tertiles = ifelse(score_demo<=vector_nevi_tertiles[[3]][1], "Low",ifelse(score_demo<=vector_nevi_tertiles[[3]][2], "Medium", "High")))

km_df$demo_tertiles <- factor(km_df$demo_tertiles, c("Low", "Medium", "High"))
summary(km_df$demo_tertiles)

##Econ NEVI
library(dplyr)
km_df <- mutate(km_df, econ_tertiles = ifelse(score_economic<=vector_nevi_tertiles[[4]][1], "Low",ifelse(score_economic<=vector_nevi_tertiles[[4]][2], "Medium", "High")))

km_df$econ_tertiles <- factor(km_df$econ_tertiles, c("Low", "Medium", "High"))
summary(km_df$econ_tertiles)

##Residential NEVI
library(dplyr)
km_df <- mutate(km_df, res_tertiles = ifelse(score_residential<=vector_nevi_tertiles[[5]][1], "Low",ifelse(score_residential<=vector_nevi_tertiles[[5]][2], "Medium", "High")))

km_df$res_tertiles <- factor(km_df$res_tertiles, c("Low", "Medium", "High"))
summary(km_df$res_tertiles)


##Health Status NEVI
library(dplyr)
km_df <- mutate(km_df, health_tertiles = ifelse(score_healthstatus<=vector_nevi_tertiles[[6]][1], "Low",ifelse(score_healthstatus<=vector_nevi_tertiles[[6]][2], "Medium", "High")))

km_df$health_tertiles <- factor(km_df$health_tertiles, c("Low", "Medium", "High"))
summary(km_df$health_tertiles)

##All tertile boundaries are based on zip code data after centering



## 3 Recode AP (based on zip code)

## PM
km_df <- mutate(km_df, pm_quartiles = ifelse(pm_avg <= vector_ap_quartiles[[2]][1], "Low", ifelse(pm_avg <= vector_ap_quartiles[[2]][2], "Medium",ifelse(pm_avg<= vector_ap_quartiles[[2]][3], "High", "VeryHigh"))))

km_df$pm_quartiles <- factor(km_df$pm_quartiles, c("Low", "Medium", "High", "VeryHigh"))
summary(km_df$pm_quartiles)

## BC
km_df <- mutate(km_df, bc_quartiles = ifelse(bc_avg <= vector_ap_quartiles[[3]][1], "Low", ifelse(bc_avg <= vector_ap_quartiles[[3]][2], "Medium",ifelse(bc_avg<= vector_ap_quartiles[[3]][3], "High", "VeryHigh"))))

km_df$bc_quartiles <- factor(km_df$bc_quartiles, c("Low", "Medium", "High", "VeryHigh"))
summary(km_df$bc_quartiles)

## NO2
km_df <- mutate(km_df, no2_quartiles = ifelse(no2_avg <= vector_ap_quartiles[[4]][1], "Low", ifelse(no2_avg <= vector_ap_quartiles[[4]][2], "Medium",ifelse(no2_avg<= vector_ap_quartiles[[4]][3], "High", "VeryHigh"))))

km_df$no2_quartiles <- factor(km_df$no2_quartiles, c("Low", "Medium", "High", "VeryHigh"))
summary(km_df$no2_quartiles)

## O3
km_df <- mutate(km_df, o3_quartiles = ifelse(o3_avg <= vector_ap_quartiles[[6]][1], "Low", ifelse(o3_avg <= vector_ap_quartiles[[6]][2], "Medium",ifelse(o3_avg<= vector_ap_quartiles[[6]][3], "High", "VeryHigh"))))

km_df$o3_quartiles <- factor(km_df$o3_quartiles, c("Low", "Medium", "High", "VeryHigh"))
summary(km_df$o3_quartiles)


##All quartile boundaries are based on zip code data after centering


## 4 Recode BC-NEVI hard-coded categories (based on zip codes)

### 4.1 Overall NEVI

km_df <- mutate(km_df, bc_nevi = ifelse(km_df$bc_quartiles=="Low" & km_df$nevi_tertiles=="Low", 1, ifelse(km_df$bc_quartiles=="Low" & km_df$nevi_tertiles=="Medium", 2, ifelse(km_df$bc_quartiles=="Low" & km_df$nevi_tertiles=="High", 3, ifelse(km_df$bc_quartiles=="Medium" & km_df$nevi_tertiles=="Low", 4,ifelse(km_df$bc_quartiles=="Medium" & km_df$nevi_tertiles=="Medium", 5,ifelse(km_df$bc_quartiles=="Medium" & km_df$nevi_tertiles=="High", 6,ifelse(km_df$bc_quartiles=="High" & km_df$nevi_tertiles=="Low", 7, ifelse(km_df$bc_quartiles=="High" & km_df$nevi_tertiles=="Medium", 8,ifelse(km_df$bc_quartiles=="High" & km_df$nevi_tertiles=="High", 9,ifelse(km_df$bc_quartiles=="VeryHigh" & km_df$nevi_tertiles=="Low", 10,ifelse(km_df$bc_quartiles=="VeryHigh" & km_df$nevi_tertiles=="Medium", 11, 12))))))))))))

summary(km_df$bc_nevi)
km_df$bc_nevi <- factor(km_df$bc_nevi, levels = c(1,2,3,4,5,6,7,8,9,10,11,12), labels =  c("LowBC_LowNEVI", "LowBC_MediumNEVI", "LowBC_HighNEVI", "MediumBC_LowNEVI", "MediumBC_MediumNEVI", "MediumBC_HighNEVI", "HighBC_LowNEVI", "HighBC_MediumNEVI", "HighBC_HighNEVI", "VeryHighBC_LowNEVI", "VeryHighBC_MediumNEVI", "VeryHighBC_HighNEVI"))

summary(km_df$bc_nevi)


### 4.2 Demographic NEVI

km_df <- mutate(km_df, bc_demo_nevi = ifelse(km_df$bc_quartiles=="Low" & km_df$demo_tertiles=="Low", 1, ifelse(km_df$bc_quartiles=="Low" & km_df$demo_tertiles=="Medium", 2, ifelse(km_df$bc_quartiles=="Low" & km_df$demo_tertiles=="High", 3, ifelse(km_df$bc_quartiles=="Medium" & km_df$demo_tertiles=="Low", 4, ifelse(km_df$bc_quartiles=="Medium" & km_df$demo_tertiles=="Medium", 5, ifelse(km_df$bc_quartiles=="Medium" & km_df$demo_tertiles=="High", 6,ifelse(km_df$bc_quartiles=="High" & km_df$demo_tertiles=="Low", 7,ifelse(km_df$bc_quartiles=="High" & km_df$demo_tertiles=="Medium", 8,ifelse(km_df$bc_quartiles=="High" & km_df$demo_tertiles=="High", 9,ifelse(km_df$bc_quartiles=="VeryHigh" & km_df$demo_tertiles=="Low", 10,ifelse(km_df$bc_quartiles=="VeryHigh" & km_df$demo_tertiles=="Medium", 11, 12))))))))))))

summary(km_df$bc_demo_nevi)
km_df$bc_demo_nevi <- factor(km_df$bc_demo_nevi, levels = c(1,2,3,4,5,6,7,8,9,10,11,12), labels =  c("LowBC_LowDemoNEVI", "LowBC_MediumDemoNEVI", "LowBC_HighDemoNEVI", "MediumBC_LowDemoNEVI", "MediumBC_MediumDemoNEVI", "MediumBC_HighDemoNEVI", "HighBC_LowDemoNEVI", "HighBC_MediumDemoNEVI", "HighBC_HighDemoNEVI", "VeryHighBC_LowDemoNEVI", "VeryHighBC_MediumDemoNEVI", "VeryHighBC_HighDemoNEVI"))

summary(km_df$bc_demo_nevi)


### 4.3 Economic NEVI

km_df <- mutate(km_df, bc_econ_nevi = ifelse(km_df$bc_quartiles=="Low" & km_df$econ_tertiles=="Low", 1, ifelse(km_df$bc_quartiles=="Low" & km_df$econ_tertiles=="Medium", 2, ifelse(km_df$bc_quartiles=="Low" & km_df$econ_tertiles=="High", 3, ifelse(km_df$bc_quartiles=="Medium" & km_df$econ_tertiles=="Low", 4, ifelse(km_df$bc_quartiles=="Medium" & km_df$econ_tertiles=="Medium", 5, ifelse(km_df$bc_quartiles=="Medium" & km_df$econ_tertiles=="High", 6,ifelse(km_df$bc_quartiles=="High" & km_df$econ_tertiles=="Low", 7,ifelse(km_df$bc_quartiles=="High" & km_df$econ_tertiles=="Medium", 8,ifelse(km_df$bc_quartiles=="High" & km_df$econ_tertiles=="High", 9,ifelse(km_df$bc_quartiles=="VeryHigh" & km_df$econ_tertiles=="Low", 10,ifelse(km_df$bc_quartiles=="VeryHigh" & km_df$econ_tertiles=="Medium", 11, 12))))))))))))

summary(km_df$bc_econ_nevi)
km_df$bc_econ_nevi <- factor(km_df$bc_econ_nevi, levels = c(1,2,3,4,5,6,7,8,9,10,11,12), labels =  c("LowBC_LowEconNEVI", "LowBC_MediumEconNEVI", "LowBC_HighEconNEVI", "MediumBC_LowEconNEVI", "MediumBC_MediumEconNEVI", "MediumBC_HighEconNEVI", "HighBC_LowEconNEVI", "HighBC_MediumEconNEVI", "HighBC_HighEconNEVI", "VeryHighBC_LowEconNEVI", "VeryHighBC_MediumEconNEVI", "VeryHighBC_HighEconNEVI"))

summary(km_df$bc_econ_nevi)

### 4.4 Residential NEVI

km_df <- mutate(km_df, bc_res_nevi = ifelse(km_df$bc_quartiles=="Low" & km_df$res_tertiles=="Low", 1, ifelse(km_df$bc_quartiles=="Low" & km_df$res_tertiles=="Medium", 2, ifelse(km_df$bc_quartiles=="Low" & km_df$res_tertiles=="High", 3, ifelse(km_df$bc_quartiles=="Medium" & km_df$res_tertiles=="Low", 4, ifelse(km_df$bc_quartiles=="Medium" & km_df$res_tertiles=="Medium", 5, ifelse(km_df$bc_quartiles=="Medium" & km_df$res_tertiles=="High", 6, ifelse(km_df$bc_quartiles=="High" & km_df$res_tertiles=="Low", 7, ifelse(km_df$bc_quartiles=="High" & km_df$res_tertiles=="Medium", 8, ifelse(km_df$bc_quartiles=="High" & km_df$res_tertiles=="High", 9,ifelse(km_df$bc_quartiles=="VeryHigh" & km_df$res_tertiles=="Low", 10,ifelse(km_df$bc_quartiles=="VeryHigh" & km_df$res_tertiles=="Medium", 11, 12))))))))))))

summary(km_df$bc_res_nevi)
km_df$bc_res_nevi <- factor(km_df$bc_res_nevi, levels = c(1,2,3,4,5,6,7,8,9,10,11,12), labels =  c("LowBC_LowResNEVI", "LowBC_MediumResNEVI", "LowBC_HighResNEVI", "MediumBC_LowResNEVI", "MediumBC_MediumResNEVI", "MediumBC_HighResNEVI", "HighBC_LowResNEVI", "HighBC_MediumResNEVI", "HighBC_HighResNEVI", "VeryHighBC_LowResNEVI", "VeryHighBC_MediumResNEVI", "VeryHighBC_HighResNEVI"))

summary(km_df$bc_res_nevi)

### 4.5 Health NEVI

km_df <- mutate(km_df, bc_health_nevi = ifelse(km_df$bc_quartiles=="Low" & km_df$health_tertiles=="Low", 1, ifelse(km_df$bc_quartiles=="Low" & km_df$health_tertiles=="Medium", 2, ifelse(km_df$bc_quartiles=="Low" & km_df$health_tertiles=="High", 3, ifelse(km_df$bc_quartiles=="Medium" & km_df$health_tertiles=="Low", 4, ifelse(km_df$bc_quartiles=="Medium" & km_df$health_tertiles=="Medium", 5, ifelse(km_df$bc_quartiles=="Medium" & km_df$health_tertiles=="High", 6,ifelse(km_df$bc_quartiles=="High" & km_df$health_tertiles=="Low", 7, ifelse(km_df$bc_quartiles=="High" & km_df$health_tertiles=="Medium", 8,ifelse(km_df$bc_quartiles=="High" & km_df$health_tertiles=="High", 9,ifelse(km_df$bc_quartiles=="VeryHigh" & km_df$health_tertiles=="Low", 10, ifelse(km_df$bc_quartiles=="VeryHigh" & km_df$health_tertiles=="Medium", 11, 12))))))))))))

summary(km_df$bc_health_nevi)
km_df$bc_health_nevi <- factor(km_df$bc_health_nevi, levels = c(1,2,3,4,5,6,7,8,9,10,11,12), labels =  c("LowBC_LowHealthNEVI", "LowBC_MediumHealthNEVI", "LowBC_HighHealthNEVI", "MediumBC_LowHealthNEVI", "MediumBC_MediumHealthNEVI", "MediumBC_HighHealthNEVI", "HighBC_LowHealthNEVI", "HighBC_MediumHealthNEVI", "HighBC_HighHealthNEVI", "VeryHighBC_LowHealthNEVI", "VeryHighBC_MediumHealthNEVI", "VeryHighBC_HighHealthNEVI"))

summary(km_df$bc_health_nevi)

## 5 Recode NO2-NEVI hard-coded categories (based on zip codes)

### 5.1 Overall NEVI

km_df <- mutate(km_df, no2_nevi = ifelse(km_df$no2_quartiles=="Low" & km_df$nevi_tertiles=="Low", 1, ifelse(km_df$no2_quartiles=="Low" & km_df$nevi_tertiles=="Medium", 2, ifelse(km_df$no2_quartiles=="Low" & km_df$nevi_tertiles=="High", 3, ifelse(km_df$no2_quartiles=="Medium" & km_df$nevi_tertiles=="Low", 4,ifelse(km_df$no2_quartiles=="Medium" & km_df$nevi_tertiles=="Medium", 5,ifelse(km_df$no2_quartiles=="Medium" & km_df$nevi_tertiles=="High", 6,ifelse(km_df$no2_quartiles=="High" & km_df$nevi_tertiles=="Low", 7, ifelse(km_df$no2_quartiles=="High" & km_df$nevi_tertiles=="Medium", 8,ifelse(km_df$no2_quartiles=="High" & km_df$nevi_tertiles=="High", 9,ifelse(km_df$no2_quartiles=="VeryHigh" & km_df$nevi_tertiles=="Low", 10,ifelse(km_df$no2_quartiles=="VeryHigh" & km_df$nevi_tertiles=="Medium", 11, 12))))))))))))

summary(km_df$no2_nevi)
km_df$no2_nevi <- factor(km_df$no2_nevi, levels = c(1,2,3,4,5,6,7,8,9,10,11,12), labels =  c("LowNO2_LowNEVI", "LowNO2_MediumNEVI", "LowNO2_HighNEVI", "MediumNO2_LowNEVI", "MediumNO2_MediumNEVI", "MediumNO2_HighNEVI", "HighNO2_LowNEVI", "HighNO2_MediumNEVI", "HighNO2_HighNEVI", "VeryHighNO2_LowNEVI", "VeryHighNO2_MediumNEVI", "VeryHighNO2_HighNEVI"))

summary(km_df$no2_nevi)

### 5.2 Demographic NEVI

km_df <- mutate(km_df, no2_demo_nevi = ifelse(km_df$no2_quartiles=="Low" & km_df$demo_tertiles=="Low", 1, ifelse(km_df$no2_quartiles=="Low" & km_df$demo_tertiles=="Medium", 2, ifelse(km_df$no2_quartiles=="Low" & km_df$demo_tertiles=="High", 3, ifelse(km_df$no2_quartiles=="Medium" & km_df$demo_tertiles=="Low", 4, ifelse(km_df$no2_quartiles=="Medium" & km_df$demo_tertiles=="Medium", 5, ifelse(km_df$no2_quartiles=="Medium" & km_df$demo_tertiles=="High", 6,ifelse(km_df$no2_quartiles=="High" & km_df$demo_tertiles=="Low", 7,ifelse(km_df$no2_quartiles=="High" & km_df$demo_tertiles=="Medium", 8,ifelse(km_df$no2_quartiles=="High" & km_df$demo_tertiles=="High", 9,ifelse(km_df$no2_quartiles=="VeryHigh" & km_df$demo_tertiles=="Low", 10,ifelse(km_df$no2_quartiles=="VeryHigh" & km_df$demo_tertiles=="Medium", 11, 12))))))))))))

summary(km_df$no2_demo_nevi)
km_df$no2_demo_nevi <- factor(km_df$no2_demo_nevi, levels = c(1,2,3,4,5,6,7,8,9,10,11,12), labels =  c("LowNO2_LowDemoNEVI", "LowNO2_MediumDemoNEVI", "LowNO2_HighDemoNEVI", "MediumNO2_LowDemoNEVI", "MediumNO2_MediumDemoNEVI", "MediumNO2_HighDemoNEVI", "HighNO2_LowDemoNEVI", "HighNO2_MediumDemoNEVI", "HighNO2_HighDemoNEVI", "VeryHighNO2_LowDemoNEVI", "VeryHighNO2_MediumDemoNEVI", "VeryHighNO2_HighDemoNEVI"))

summary(km_df$no2_demo_nevi)


### 5.3 Economic NEVI

km_df <- mutate(km_df, no2_econ_nevi = ifelse(km_df$no2_quartiles=="Low" & km_df$econ_tertiles=="Low", 1, ifelse(km_df$no2_quartiles=="Low" & km_df$econ_tertiles=="Medium", 2, ifelse(km_df$no2_quartiles=="Low" & km_df$econ_tertiles=="High", 3, ifelse(km_df$no2_quartiles=="Medium" & km_df$econ_tertiles=="Low", 4, ifelse(km_df$no2_quartiles=="Medium" & km_df$econ_tertiles=="Medium", 5, ifelse(km_df$no2_quartiles=="Medium" & km_df$econ_tertiles=="High", 6,ifelse(km_df$no2_quartiles=="High" & km_df$econ_tertiles=="Low", 7,ifelse(km_df$no2_quartiles=="High" & km_df$econ_tertiles=="Medium", 8,ifelse(km_df$no2_quartiles=="High" & km_df$econ_tertiles=="High", 9,ifelse(km_df$no2_quartiles=="VeryHigh" & km_df$econ_tertiles=="Low", 10,ifelse(km_df$no2_quartiles=="VeryHigh" & km_df$econ_tertiles=="Medium", 11, 12))))))))))))

summary(km_df$no2_econ_nevi)
km_df$no2_econ_nevi <- factor(km_df$no2_econ_nevi, levels = c(1,2,3,4,5,6,7,8,9,10,11,12), labels =  c("LowNO2_LowEconNEVI", "LowNO2_MediumEconNEVI", "LowNO2_HighEconNEVI", "MediumNO2_LowEconNEVI", "MediumNO2_MediumEconNEVI", "MediumNO2_HighEconNEVI", "HighNO2_LowEconNEVI", "HighNO2_MediumEconNEVI", "HighNO2_HighEconNEVI", "VeryHighNO2_LowEconNEVI", "VeryHighNO2_MediumEconNEVI", "VeryHighNO2_HighEconNEVI"))

summary(km_df$no2_econ_nevi)

### 5.4 Residential NEVI

km_df <- mutate(km_df, no2_res_nevi = ifelse(km_df$no2_quartiles=="Low" & km_df$res_tertiles=="Low", 1, ifelse(km_df$no2_quartiles=="Low" & km_df$res_tertiles=="Medium", 2, ifelse(km_df$no2_quartiles=="Low" & km_df$res_tertiles=="High", 3, ifelse(km_df$no2_quartiles=="Medium" & km_df$res_tertiles=="Low", 4, ifelse(km_df$no2_quartiles=="Medium" & km_df$res_tertiles=="Medium", 5, ifelse(km_df$no2_quartiles=="Medium" & km_df$res_tertiles=="High", 6, ifelse(km_df$no2_quartiles=="High" & km_df$res_tertiles=="Low", 7, ifelse(km_df$no2_quartiles=="High" & km_df$res_tertiles=="Medium", 8, ifelse(km_df$no2_quartiles=="High" & km_df$res_tertiles=="High", 9,ifelse(km_df$no2_quartiles=="VeryHigh" & km_df$res_tertiles=="Low", 10,ifelse(km_df$no2_quartiles=="VeryHigh" & km_df$res_tertiles=="Medium", 11, 12))))))))))))

summary(km_df$no2_res_nevi)
km_df$no2_res_nevi <- factor(km_df$no2_res_nevi, levels = c(1,2,3,4,5,6,7,8,9,10,11,12), labels =  c("LowNO2_LowResNEVI", "LowNO2_MediumResNEVI", "LowNO2_HighResNEVI", "MediumNO2_LowResNEVI", "MediumNO2_MediumResNEVI", "MediumNO2_HighResNEVI", "HighNO2_LowResNEVI", "HighNO2_MediumResNEVI", "HighNO2_HighResNEVI", "VeryHighNO2_LowResNEVI", "VeryHighNO2_MediumResNEVI", "VeryHighNO2_HighResNEVI"))

summary(km_df$no2_res_nevi)


### 5.5 Health NEVI

km_df <- mutate(km_df, no2_health_nevi = ifelse(km_df$no2_quartiles=="Low" & km_df$health_tertiles=="Low", 1, ifelse(km_df$no2_quartiles=="Low" & km_df$health_tertiles=="Medium", 2, ifelse(km_df$no2_quartiles=="Low" & km_df$health_tertiles=="High", 3, ifelse(km_df$no2_quartiles=="Medium" & km_df$health_tertiles=="Low", 4, ifelse(km_df$no2_quartiles=="Medium" & km_df$health_tertiles=="Medium", 5, ifelse(km_df$no2_quartiles=="Medium" & km_df$health_tertiles=="High", 6,ifelse(km_df$no2_quartiles=="High" & km_df$health_tertiles=="Low", 7, ifelse(km_df$no2_quartiles=="High" & km_df$health_tertiles=="Medium", 8,ifelse(km_df$no2_quartiles=="High" & km_df$health_tertiles=="High", 9,ifelse(km_df$no2_quartiles=="VeryHigh" & km_df$health_tertiles=="Low", 10, ifelse(km_df$no2_quartiles=="VeryHigh" & km_df$health_tertiles=="Medium", 11, 12))))))))))))

summary(km_df$no2_health_nevi)
km_df$no2_health_nevi <- factor(km_df$no2_health_nevi, levels = c(1,2,3,4,5,6,7,8,9,10,11,12), labels =  c("LowNO2_LowHealthNEVI", "LowNO2_MediumHealthNEVI", "LowNO2_HighHealthNEVI", "MediumNO2_LowHealthNEVI", "MediumNO2_MediumHealthNEVI", "MediumNO2_HighHealthNEVI", "HighNO2_LowHealthNEVI", "HighNO2_MediumHealthNEVI", "HighNO2_HighHealthNEVI", "VeryHighNO2_LowHealthNEVI", "VeryHighNO2_MediumHealthNEVI", "VeryHighNO2_HighHealthNEVI"))

summary(km_df$no2_health_nevi)

## 6 Recode PM-NEVI hard-coded categories (based on zip codes)

### 6.1 Overall NEVI

km_df <- mutate(km_df, pm_nevi = ifelse(km_df$pm_quartiles=="Low" & km_df$nevi_tertiles=="Low", 1, ifelse(km_df$pm_quartiles=="Low" & km_df$nevi_tertiles=="Medium", 2, ifelse(km_df$pm_quartiles=="Low" & km_df$nevi_tertiles=="High", 3, ifelse(km_df$pm_quartiles=="Medium" & km_df$nevi_tertiles=="Low", 4,ifelse(km_df$pm_quartiles=="Medium" & km_df$nevi_tertiles=="Medium", 5,ifelse(km_df$pm_quartiles=="Medium" & km_df$nevi_tertiles=="High", 6,ifelse(km_df$pm_quartiles=="High" & km_df$nevi_tertiles=="Low", 7, ifelse(km_df$pm_quartiles=="High" & km_df$nevi_tertiles=="Medium", 8,ifelse(km_df$pm_quartiles=="High" & km_df$nevi_tertiles=="High", 9,ifelse(km_df$pm_quartiles=="VeryHigh" & km_df$nevi_tertiles=="Low", 10,ifelse(km_df$pm_quartiles=="VeryHigh" & km_df$nevi_tertiles=="Medium", 11, 12))))))))))))

summary(km_df$pm_nevi)
km_df$pm_nevi <- factor(km_df$pm_nevi, levels = c(1,2,3,4,5,6,7,8,9,10,11,12), labels =  c("LowPM_LowNEVI", "LowPM_MediumNEVI", "LowPM_HighNEVI", "MediumPM_LowNEVI", "MediumPM_MediumNEVI", "MediumPM_HighNEVI", "HighPM_LowNEVI", "HighPM_MediumNEVI", "HighPM_HighNEVI", "VeryHighPM_LowNEVI", "VeryHighPM_MediumNEVI", "VeryHighPM_HighNEVI"))

summary(km_df$pm_nevi)

### 6.2 Demographic NEVI
km_df <- mutate(km_df, pm_demo_nevi = ifelse(km_df$pm_quartiles=="Low" & km_df$demo_tertiles=="Low", 1, ifelse(km_df$pm_quartiles=="Low" & km_df$demo_tertiles=="Medium", 2, ifelse(km_df$pm_quartiles=="Low" & km_df$demo_tertiles=="High", 3, ifelse(km_df$pm_quartiles=="Medium" & km_df$demo_tertiles=="Low", 4, ifelse(km_df$pm_quartiles=="Medium" & km_df$demo_tertiles=="Medium", 5, ifelse(km_df$pm_quartiles=="Medium" & km_df$demo_tertiles=="High", 6,ifelse(km_df$pm_quartiles=="High" & km_df$demo_tertiles=="Low", 7,ifelse(km_df$pm_quartiles=="High" & km_df$demo_tertiles=="Medium", 8,ifelse(km_df$pm_quartiles=="High" & km_df$demo_tertiles=="High", 9,ifelse(km_df$pm_quartiles=="VeryHigh" & km_df$demo_tertiles=="Low", 10,ifelse(km_df$pm_quartiles=="VeryHigh" & km_df$demo_tertiles=="Medium", 11, 12))))))))))))

summary(km_df$pm_demo_nevi)
km_df$pm_demo_nevi <- factor(km_df$pm_demo_nevi, levels = c(1,2,3,4,5,6,7,8,9,10,11,12), labels =  c("LowPM_LowDemoNEVI", "LowPM_MediumDemoNEVI", "LowPM_HighDemoNEVI", "MediumPM_LowDemoNEVI", "MediumPM_MediumDemoNEVI", "MediumPM_HighDemoNEVI", "HighPM_LowDemoNEVI", "HighPM_MediumDemoNEVI", "HighPM_HighDemoNEVI", "VeryHighPM_LowDemoNEVI", "VeryHighPM_MediumDemoNEVI", "VeryHighPM_HighDemoNEVI"))

summary(km_df$pm_demo_nevi)


### 6.3 Economic NEVI

km_df <- mutate(km_df, pm_econ_nevi = ifelse(km_df$pm_quartiles=="Low" & km_df$econ_tertiles=="Low", 1, ifelse(km_df$pm_quartiles=="Low" & km_df$econ_tertiles=="Medium", 2, ifelse(km_df$pm_quartiles=="Low" & km_df$econ_tertiles=="High", 3, ifelse(km_df$pm_quartiles=="Medium" & km_df$econ_tertiles=="Low", 4, ifelse(km_df$pm_quartiles=="Medium" & km_df$econ_tertiles=="Medium", 5, ifelse(km_df$pm_quartiles=="Medium" & km_df$econ_tertiles=="High", 6,ifelse(km_df$pm_quartiles=="High" & km_df$econ_tertiles=="Low", 7,ifelse(km_df$pm_quartiles=="High" & km_df$econ_tertiles=="Medium", 8,ifelse(km_df$pm_quartiles=="High" & km_df$econ_tertiles=="High", 9,ifelse(km_df$pm_quartiles=="VeryHigh" & km_df$econ_tertiles=="Low", 10,ifelse(km_df$pm_quartiles=="VeryHigh" & km_df$econ_tertiles=="Medium", 11, 12))))))))))))

summary(km_df$pm_econ_nevi)
km_df$pm_econ_nevi <- factor(km_df$pm_econ_nevi, levels = c(1,2,3,4,5,6,7,8,9,10,11,12), labels =  c("LowPM_LowEconNEVI", "LowPM_MediumEconNEVI", "LowPM_HighEconNEVI", "MediumPM_LowEconNEVI", "MediumPM_MediumEconNEVI", "MediumPM_HighEconNEVI", "HighPM_LowEconNEVI", "HighPM_MediumEconNEVI", "HighPM_HighEconNEVI", "VeryHighPM_LowEconNEVI", "VeryHighPM_MediumEconNEVI", "VeryHighPM_HighEconNEVI"))

summary(km_df$pm_econ_nevi)

### 6.4 Residential NEVI

km_df <- mutate(km_df, pm_res_nevi = ifelse(km_df$pm_quartiles=="Low" & km_df$res_tertiles=="Low", 1, ifelse(km_df$pm_quartiles=="Low" & km_df$res_tertiles=="Medium", 2, ifelse(km_df$pm_quartiles=="Low" & km_df$res_tertiles=="High", 3, ifelse(km_df$pm_quartiles=="Medium" & km_df$res_tertiles=="Low", 4, ifelse(km_df$pm_quartiles=="Medium" & km_df$res_tertiles=="Medium", 5, ifelse(km_df$pm_quartiles=="Medium" & km_df$res_tertiles=="High", 6, ifelse(km_df$pm_quartiles=="High" & km_df$res_tertiles=="Low", 7, ifelse(km_df$pm_quartiles=="High" & km_df$res_tertiles=="Medium", 8, ifelse(km_df$pm_quartiles=="High" & km_df$res_tertiles=="High", 9,ifelse(km_df$pm_quartiles=="VeryHigh" & km_df$res_tertiles=="Low", 10,ifelse(km_df$pm_quartiles=="VeryHigh" & km_df$res_tertiles=="Medium", 11, 12))))))))))))

summary(km_df$pm_res_nevi)
km_df$pm_res_nevi <- factor(km_df$pm_res_nevi, levels = c(1,2,3,4,5,6,7,8,9,10,11,12), labels =  c("LowPM_LowResNEVI", "LowPM_MediumResNEVI", "LowPM_HighResNEVI", "MediumPM_LowResNEVI", "MediumPM_MediumResNEVI", "MediumPM_HighResNEVI", "HighPM_LowResNEVI", "HighPM_MediumResNEVI", "HighPM_HighResNEVI", "VeryHighPM_LowResNEVI", "VeryHighPM_MediumResNEVI", "VeryHighPM_HighResNEVI"))

summary(km_df$pm_res_nevi)

### 6.5 Health NEVI

km_df <- mutate(km_df, pm_health_nevi = ifelse(km_df$pm_quartiles=="Low" & km_df$health_tertiles=="Low", 1, ifelse(km_df$pm_quartiles=="Low" & km_df$health_tertiles=="Medium", 2, ifelse(km_df$pm_quartiles=="Low" & km_df$health_tertiles=="High", 3, ifelse(km_df$pm_quartiles=="Medium" & km_df$health_tertiles=="Low", 4, ifelse(km_df$pm_quartiles=="Medium" & km_df$health_tertiles=="Medium", 5, ifelse(km_df$pm_quartiles=="Medium" & km_df$health_tertiles=="High", 6,ifelse(km_df$pm_quartiles=="High" & km_df$health_tertiles=="Low", 7, ifelse(km_df$pm_quartiles=="High" & km_df$health_tertiles=="Medium", 8,ifelse(km_df$pm_quartiles=="High" & km_df$health_tertiles=="High", 9,ifelse(km_df$pm_quartiles=="VeryHigh" & km_df$health_tertiles=="Low", 10, ifelse(km_df$pm_quartiles=="VeryHigh" & km_df$health_tertiles=="Medium", 11, 12))))))))))))

summary(km_df$pm_health_nevi)
km_df$pm_health_nevi <- factor(km_df$pm_health_nevi, levels = c(1,2,3,4,5,6,7,8,9,10,11,12), labels =  c("LowPM_LowHealthNEVI", "LowPM_MediumHealthNEVI", "LowPM_HighHealthNEVI", "MediumPM_LowHealthNEVI", "MediumPM_MediumHealthNEVI", "MediumPM_HighHealthNEVI", "HighPM_LowHealthNEVI", "HighPM_MediumHealthNEVI", "HighPM_HighHealthNEVI", "VeryHighPM_LowHealthNEVI", "VeryHighPM_MediumHealthNEVI", "VeryHighPM_HighHealthNEVI"))

summary(km_df$pm_health_nevi)



## 7 Recode O3-NEVI hard-coded categories (based on zip codes)

### 7.1 Overall NEVI

km_df <- mutate(km_df, o3_nevi = ifelse(km_df$o3_quartiles=="Low" & km_df$nevi_tertiles=="Low", 1, ifelse(km_df$o3_quartiles=="Low" & km_df$nevi_tertiles=="Medium", 2, ifelse(km_df$o3_quartiles=="Low" & km_df$nevi_tertiles=="High", 3, ifelse(km_df$o3_quartiles=="Medium" & km_df$nevi_tertiles=="Low", 4,ifelse(km_df$o3_quartiles=="Medium" & km_df$nevi_tertiles=="Medium", 5,ifelse(km_df$o3_quartiles=="Medium" & km_df$nevi_tertiles=="High", 6,ifelse(km_df$o3_quartiles=="High" & km_df$nevi_tertiles=="Low", 7, ifelse(km_df$o3_quartiles=="High" & km_df$nevi_tertiles=="Medium", 8,ifelse(km_df$o3_quartiles=="High" & km_df$nevi_tertiles=="High", 9,ifelse(km_df$o3_quartiles=="VeryHigh" & km_df$nevi_tertiles=="Low", 10,ifelse(km_df$o3_quartiles=="VeryHigh" & km_df$nevi_tertiles=="Medium", 11, 12))))))))))))

summary(km_df$o3_nevi)
km_df$o3_nevi <- factor(km_df$o3_nevi, levels = c(1,2,3,4,5,6,7,8,9,10,11,12), labels =  c("LowO3_LowNEVI", "LowO3_MediumNEVI", "LowO3_HighNEVI", "MediumO3_LowNEVI", "MediumO3_MediumNEVI", "MediumO3_HighNEVI", "HighO3_LowNEVI", "HighO3_MediumNEVI", "HighO3_HighNEVI", "VeryHighO3_LowNEVI", "VeryHighO3_MediumNEVI", "VeryHighO3_HighNEVI"))

summary(km_df$o3_nevi)

### 7.2 Demographic NEVI

km_df <- mutate(km_df, o3_demo_nevi = ifelse(km_df$o3_quartiles=="Low" & km_df$demo_tertiles=="Low", 1, ifelse(km_df$o3_quartiles=="Low" & km_df$demo_tertiles=="Medium", 2, ifelse(km_df$o3_quartiles=="Low" & km_df$demo_tertiles=="High", 3, ifelse(km_df$o3_quartiles=="Medium" & km_df$demo_tertiles=="Low", 4, ifelse(km_df$o3_quartiles=="Medium" & km_df$demo_tertiles=="Medium", 5, ifelse(km_df$o3_quartiles=="Medium" & km_df$demo_tertiles=="High", 6,ifelse(km_df$o3_quartiles=="High" & km_df$demo_tertiles=="Low", 7,ifelse(km_df$o3_quartiles=="High" & km_df$demo_tertiles=="Medium", 8,ifelse(km_df$o3_quartiles=="High" & km_df$demo_tertiles=="High", 9,ifelse(km_df$o3_quartiles=="VeryHigh" & km_df$demo_tertiles=="Low", 10,ifelse(km_df$o3_quartiles=="VeryHigh" & km_df$demo_tertiles=="Medium", 11, 12))))))))))))

summary(km_df$o3_demo_nevi)
km_df$o3_demo_nevi <- factor(km_df$o3_demo_nevi, levels = c(1,2,3,4,5,6,7,8,9,10,11,12), labels =  c("LowO3_LowDemoNEVI", "LowO3_MediumDemoNEVI", "LowO3_HighDemoNEVI", "MediumO3_LowDemoNEVI", "MediumO3_MediumDemoNEVI", "MediumO3_HighDemoNEVI", "HighO3_LowDemoNEVI", "HighO3_MediumDemoNEVI", "HighO3_HighDemoNEVI", "VeryHighO3_LowDemoNEVI", "VeryHighO3_MediumDemoNEVI", "VeryHighO3_HighDemoNEVI"))

summary(km_df$o3_demo_nevi)


### 7.3 Economic NEVI

km_df <- mutate(km_df, o3_econ_nevi = ifelse(km_df$o3_quartiles=="Low" & km_df$econ_tertiles=="Low", 1, ifelse(km_df$o3_quartiles=="Low" & km_df$econ_tertiles=="Medium", 2, ifelse(km_df$o3_quartiles=="Low" & km_df$econ_tertiles=="High", 3, ifelse(km_df$o3_quartiles=="Medium" & km_df$econ_tertiles=="Low", 4, ifelse(km_df$o3_quartiles=="Medium" & km_df$econ_tertiles=="Medium", 5, ifelse(km_df$o3_quartiles=="Medium" & km_df$econ_tertiles=="High", 6,ifelse(km_df$o3_quartiles=="High" & km_df$econ_tertiles=="Low", 7,ifelse(km_df$o3_quartiles=="High" & km_df$econ_tertiles=="Medium", 8,ifelse(km_df$o3_quartiles=="High" & km_df$econ_tertiles=="High", 9,ifelse(km_df$o3_quartiles=="VeryHigh" & km_df$econ_tertiles=="Low", 10,ifelse(km_df$o3_quartiles=="VeryHigh" & km_df$econ_tertiles=="Medium", 11, 12))))))))))))

summary(km_df$o3_econ_nevi)
km_df$o3_econ_nevi <- factor(km_df$o3_econ_nevi, levels = c(1,2,3,4,5,6,7,8,9,10,11,12), labels =  c("LowO3_LowEconNEVI", "LowO3_MediumEconNEVI", "LowO3_HighEconNEVI", "MediumO3_LowEconNEVI", "MediumO3_MediumEconNEVI", "MediumO3_HighEconNEVI", "HighO3_LowEconNEVI", "HighO3_MediumEconNEVI", "HighO3_HighEconNEVI", "VeryHighO3_LowEconNEVI", "VeryHighO3_MediumEconNEVI", "VeryHighO3_HighEconNEVI"))

summary(km_df$o3_econ_nevi)


### 7.4 Residential NEVI

km_df <- mutate(km_df, o3_res_nevi = ifelse(km_df$o3_quartiles=="Low" & km_df$res_tertiles=="Low", 1, ifelse(km_df$o3_quartiles=="Low" & km_df$res_tertiles=="Medium", 2, ifelse(km_df$o3_quartiles=="Low" & km_df$res_tertiles=="High", 3, ifelse(km_df$o3_quartiles=="Medium" & km_df$res_tertiles=="Low", 4, ifelse(km_df$o3_quartiles=="Medium" & km_df$res_tertiles=="Medium", 5, ifelse(km_df$o3_quartiles=="Medium" & km_df$res_tertiles=="High", 6, ifelse(km_df$o3_quartiles=="High" & km_df$res_tertiles=="Low", 7, ifelse(km_df$o3_quartiles=="High" & km_df$res_tertiles=="Medium", 8, ifelse(km_df$o3_quartiles=="High" & km_df$res_tertiles=="High", 9,ifelse(km_df$o3_quartiles=="VeryHigh" & km_df$res_tertiles=="Low", 10,ifelse(km_df$o3_quartiles=="VeryHigh" & km_df$res_tertiles=="Medium", 11, 12))))))))))))

summary(km_df$o3_res_nevi)
km_df$o3_res_nevi <- factor(km_df$o3_res_nevi, levels = c(1,2,3,4,5,6,7,8,9,10,11,12), labels =  c("LowO3_LowResNEVI", "LowO3_MediumResNEVI", "LowO3_HighResNEVI", "MediumO3_LowResNEVI", "MediumO3_MediumResNEVI", "MediumO3_HighResNEVI", "HighO3_LowResNEVI", "HighO3_MediumResNEVI", "HighO3_HighResNEVI", "VeryHighO3_LowResNEVI", "VeryHighO3_MediumResNEVI", "VeryHighO3_HighResNEVI"))

summary(km_df$o3_res_nevi)

### 7.5 Health NEVI

km_df <- mutate(km_df, o3_health_nevi = ifelse(km_df$o3_quartiles=="Low" & km_df$health_tertiles=="Low", 1, ifelse(km_df$o3_quartiles=="Low" & km_df$health_tertiles=="Medium", 2, ifelse(km_df$o3_quartiles=="Low" & km_df$health_tertiles=="High", 3, ifelse(km_df$o3_quartiles=="Medium" & km_df$health_tertiles=="Low", 4, ifelse(km_df$o3_quartiles=="Medium" & km_df$health_tertiles=="Medium", 5, ifelse(km_df$o3_quartiles=="Medium" & km_df$health_tertiles=="High", 6,ifelse(km_df$o3_quartiles=="High" & km_df$health_tertiles=="Low", 7, ifelse(km_df$o3_quartiles=="High" & km_df$health_tertiles=="Medium", 8,ifelse(km_df$o3_quartiles=="High" & km_df$health_tertiles=="High", 9,ifelse(km_df$o3_quartiles=="VeryHigh" & km_df$health_tertiles=="Low", 10, ifelse(km_df$o3_quartiles=="VeryHigh" & km_df$health_tertiles=="Medium", 11, 12))))))))))))

summary(km_df$o3_health_nevi)
km_df$o3_health_nevi <- factor(km_df$o3_health_nevi, levels = c(1,2,3,4,5,6,7,8,9,10,11,12), labels =  c("LowO3_LowHealthNEVI", "LowO3_MediumHealthNEVI", "LowO3_HighHealthNEVI", "MediumO3_LowHealthNEVI", "MediumO3_MediumHealthNEVI", "MediumO3_HighHealthNEVI", "HighO3_LowHealthNEVI", "HighO3_MediumHealthNEVI", "HighO3_HighHealthNEVI", "VeryHighO3_LowHealthNEVI", "VeryHighO3_MediumHealthNEVI", "VeryHighO3_HighHealthNEVI"))

summary(km_df$o3_health_nevi)



## 8 Organize data by phase

library(dplyr)
km_df <- km_df %>%
  mutate(phase = case_when(admit_date_phase == 1 ~ "Phase 1",
                           admit_date_phase == 2 | admit_date_phase == 3 ~ "Phase 2 and 3"))

coxph_phase1_df = km_df %>% 
  filter(admit_date_phase == 1)

coxph_phase2and3_df = km_df %>% 
  filter(admit_date_phase == 2 | admit_date_phase == 3)


## 9 Restrict by zip codes with 40% coverage

## Phase 1

coxph_phase1_40cov <- subset(coxph_phase1_df, address_zip == 10001 | address_zip == 10002 | address_zip == 10004 | address_zip == 10005 | address_zip == 10006 | address_zip == 10007 | address_zip == 10010| address_zip == 10012| address_zip == 10013| address_zip == 10016 | address_zip == 10017 | address_zip == 10018| address_zip == 10021 | address_zip == 10022 | address_zip == 10028 | address_zip == 10031 | address_zip == 10032 | address_zip == 10033 | address_zip == 10034 | address_zip == 10038 | address_zip == 10040 | address_zip == 10065 | address_zip == 10069 | address_zip == 10128 | address_zip == 10280 | address_zip == 10282 | address_zip == 10458 | address_zip == 10460 | address_zip == 10461 | address_zip == 10462 | address_zip == 10463 | address_zip == 10464 | address_zip == 10465 | address_zip == 10466 | address_zip == 10467 | address_zip == 10468 | address_zip == 10469 | address_zip == 10470 | address_zip == 10471  | address_zip == 10472 | address_zip == 10473  | address_zip == 10475  | address_zip == 11101  | address_zip == 11109  | address_zip == 11201  | address_zip == 11209  | address_zip == 11211  | address_zip == 11220  | address_zip == 11222  | address_zip == 11228  | address_zip == 11231  | address_zip == 11232 )

## Phase 2 and 3

coxph_phase2and3_40cov <- subset(coxph_phase2and3_df, address_zip == 10001 | address_zip == 10002 | address_zip == 10003 | address_zip == 10004 | address_zip == 10005 | address_zip == 10006 | address_zip == 10007 | address_zip == 10009 | address_zip == 10010| address_zip == 10011| address_zip == 10013| address_zip == 10016 | address_zip == 10017 | address_zip == 10018| address_zip == 10021 | address_zip == 10022 | address_zip == 10023| address_zip == 10028 | address_zip == 10031 | address_zip == 10032 | address_zip == 10033 | address_zip == 10034 | address_zip == 10036 | address_zip == 10038 | address_zip == 10040 | address_zip == 10065 |  address_zip == 10128 | address_zip == 10280 | address_zip == 10458| address_zip == 10459 | address_zip == 10460 | address_zip == 10461 | address_zip == 10462 | address_zip == 10463 | address_zip == 10464 | address_zip == 10465 | address_zip == 10466 | address_zip == 10467 | address_zip == 10468 | address_zip == 10469 | address_zip == 10470 | address_zip == 10471  | address_zip == 10472 | address_zip == 10473  | address_zip == 10475  | address_zip == 11106  | address_zip == 11109  | address_zip == 11201  | address_zip == 11209  | address_zip == 11214  | address_zip == 11220  | address_zip == 11222  | address_zip == 11228  | address_zip == 11231  | address_zip == 11232 )



## 10 Make population subsets for stratification

##Age
coxph_phase1_df_65andolder <- subset(coxph_phase1_df, age >= 65)
coxph_phase1_df_youngerthan65 <- subset(coxph_phase1_df, age < 65)

coxph_phase2and3_df_65andolder <- subset(coxph_phase2and3_df, age >= 65)
coxph_phase2and3_df_youngerthan65 <- subset(coxph_phase2and3_df, age < 65)

coxph_phase1_40cov_65andolder <- subset(coxph_phase1_40cov, age >= 65)
coxph_phase1_40cov_youngerthan65 <- subset(coxph_phase1_40cov, age < 65)

coxph_phase2and3_40cov_65andolder <- subset(coxph_phase2and3_40cov, age >= 65)
coxph_phase2and3_40cov_youngerthan65 <- subset(coxph_phase2and3_40cov, age < 65)


##Race
coxph_phase1_df_whiterace <- subset(coxph_phase1_df, race == "White")
coxph_phase1_df_blackrace <- subset(coxph_phase1_df, race == "Black")

coxph_phase2and3_df_whiterace <- subset(coxph_phase2and3_df, race == "White")
coxph_phase2and3_df_blackrace <- subset(coxph_phase2and3_df, race == "Black")

coxph_phase1_40cov_whiterace <- subset(coxph_phase1_40cov, race == "White")
coxph_phase1_40cov_blackrace <- subset(coxph_phase1_40cov,race == "Black")

coxph_phase2and3_40cov_whiterace <- subset(coxph_phase2and3_40cov, race == "White")
coxph_phase2and3_40cov_blackrace <- subset(coxph_phase2and3_40cov, race == "Black")

##Asthma
coxph_phase1_df_asthma <- subset(coxph_phase1_df, asthma == 1)
coxph_phase1_df_noasthma <- subset(coxph_phase1_df, asthma == 0)

coxph_phase2and3_df_asthma <- subset(coxph_phase2and3_df, asthma == 1)
coxph_phase2and3_df_noasthma <- subset(coxph_phase2and3_df, asthma == 0)

coxph_phase1_40cov_asthma <- subset(coxph_phase1_40cov, asthma == 1)
coxph_phase1_40cov_noasthma <- subset(coxph_phase1_40cov,asthma == 0)

coxph_phase2and3_40cov_asthma <- subset(coxph_phase2and3_40cov, asthma == 1)
coxph_phase2and3_40cov_noasthma <- subset(coxph_phase2and3_40cov, asthma == 0)

##Diabetes
coxph_phase1_df_diabetes <- subset(coxph_phase1_df, diabetes == 1)
coxph_phase1_df_nodiabetes <- subset(coxph_phase1_df, diabetes == 0)

coxph_phase2and3_df_diabetes <- subset(coxph_phase2and3_df, diabetes == 1)
coxph_phase2and3_df_nodiabetes <- subset(coxph_phase2and3_df, diabetes == 0)

coxph_phase1_40cov_diabetes <- subset(coxph_phase1_40cov, diabetes == 1)
coxph_phase1_40cov_nodiabetes <- subset(coxph_phase1_40cov,diabetes == 0)

coxph_phase2and3_40cov_diabetes <- subset(coxph_phase2and3_40cov, diabetes == 1)
coxph_phase2and3_40cov_nodiabetes <- subset(coxph_phase2and3_40cov, diabetes == 0)

##Hispanic
coxph_phase1_df_hispanic <- subset(coxph_phase1_df, hispanic == "Yes")
coxph_phase1_df_nonhispanic <- subset(coxph_phase1_df, hispanic == "No")

coxph_phase2and3_df_hispanic <- subset(coxph_phase2and3_df, hispanic == "Yes")
coxph_phase2and3_df_nonhispanic <- subset(coxph_phase2and3_df, hispanic == "No")

coxph_phase1_40cov_hispanic <- subset(coxph_phase1_40cov, hispanic == "Yes")
coxph_phase1_40cov_nonhispanic <- subset(coxph_phase1_40cov,hispanic == "No")

coxph_phase2and3_40cov_hispanic <- subset(coxph_phase2and3_40cov, hispanic == "Yes")
coxph_phase2and3_40cov_nonhispanic <- subset(coxph_phase2and3_40cov, hispanic == "No")

##NEVI

coxph_phase1_lownevi <- subset(coxph_phase1_df, nevi_tertiles == "Low")
coxph_phase1_mediumnevi <- subset(coxph_phase1_df, nevi_tertiles == "Medium")
coxph_phase1_highnevi <- subset(coxph_phase1_df, nevi_tertiles == "High")

coxph_phase1_40cov_lownevi <- subset(coxph_phase1_40cov, nevi_tertiles == "Low")
coxph_phase1_40cov_mediumnevi <- subset(coxph_phase1_40cov, nevi_tertiles == "Medium")
coxph_phase1_40cov_highnevi <- subset(coxph_phase1_40cov, nevi_tertiles == "High")

##hyper
coxph_phase1_df_hyper <- subset(coxph_phase1_df, hyper == 1)
coxph_phase1_df_nohyper <- subset(coxph_phase1_df, hyper == 0)

coxph_phase2and3_df_hyper <- subset(coxph_phase2and3_df, hyper == 1)
coxph_phase2and3_df_nohyper <- subset(coxph_phase2and3_df, hyper == 0)

coxph_phase1_40cov_hyper <- subset(coxph_phase1_40cov, hyper == 1)
coxph_phase1_40cov_nohyper <- subset(coxph_phase1_40cov,hyper == 0)

coxph_phase2and3_40cov_hyper <- subset(coxph_phase2and3_40cov, hyper == 1)
coxph_phase2and3_40cov_nohyper <- subset(coxph_phase2and3_40cov, hyper == 0)
