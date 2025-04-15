This folder contains programming code related to data preparation. This includes:
 
* code construct the inpatient study population within INSIGHT;
* code to clean and create analytic datasets.

All files are listed below with brief descriptions

* Insight_COVID_Inpatient_Population_final.sas: SAS Program to Create Inpatient Population for Subsequent Analyses. Uses Input Files provided by INSIGHT, as well as air pollution and NEVI estimates provided in publicdata folder

* Data Processing.R: R Script Called to within Analytic Programs to Clean Data and Derive Analytic Variables. This version is for all outcomes, except Dialysis.

* Data Processing2.R:R Script Called to within Analytic Programs to Clean Data and Derive Analytic Variables. This version is only for Dialysis because the population excludes individuals who received dialysis prior to COVID19 infection. 

* Data Processing_Descriptives.R: R Script Called to within Program to Describe Data to Clean Data and Derive Analytic Variables. Minor differences from Data Processing.R.

