# REACH-OUT
This repository contains code created and used as part of the Race, Ethnicity and Air pollution in COVID19 Hospitalization Outcomes (REACH-OUT) Project. REACH-OUT aimed to estimate the effect of chronic air pollution exposure on risk of COVID-19 morbidity and mortality and determine if these effects vary by neighborhood-level vulnerability, defined by multiple social and structural factors, to explain the COVID-19 disparities observed in New York City (NYC). 


Data sources used within the project include:
* Publicly-available data on COVID19 in NYC (public and accessible repo at : https://github.com/nychealth/coronavirus-data)
* Neighborhood Environmental Vulnerability Index (public and accessible repo at https://github.com/jstingone/nevi). Contains reference to:
	* US Census Data (public)
	* CDC Places Project data (public and accessible at https://cdc.gov/places/index.html)
 * Publicly-available New York City Community Air Survey (NYCCAS) Data (public and accessible at : https://data.cityofnewyork.us/Environment/NYCCAS-Air-Pollution-Rasters/q68s-8qxv/about_data)
* Hospitalization data from the INSIGHT Clinical Research Network (https://insightcrn.org/ for access procedures)
* All-Cause Mortality data from NYC Department of Health and Mental Hygiene ( https://www.nyc.gov/site/doh/data/data-sets/data-requests-application-process-for-identifiable-vital-statistics-data.page for access procedures)


Code is organized into folders based on outcomes under study
* /hosp: Analysis of hospitalization outcomes using harmonized EHR data within the INSIGHT CRN
* /validation: Demographic Comparison of Institution-Specific Data to INSIGHT CRN
* /mort: Analysis of Excess Mortality using All-Cause Mortality Records from NYC
* /publicdata: Programming Code, Datasets and Data Dictionaries associated with Public Data Sources Used within REACH-OUT


Links to publications will be added as they become available.

**REACH-OUT Investigators**\
Principal Investigators: Jeanette A Stingone PhD MPH and Stephanie Lovinsky-Desir MD MS

Co-Investigators:\
Sandra S Albrecht PHD MPH\
                  Alexander Azan MD\
                  Earle C Chambers PhD MPH\
                  Sneha Kannoth PhD MPH\
                  Min Qian PhD\
                  Mehr Shafiq MPH\
                  Perry E Sheffield MD MPH\
                  Azure Thompson DrPH MPH\
                  Jennifer Woo Baidal MD MPH\
                  Cong Zhang MS


The REACH-OUT Project was conducted under contrast to the Health Effects Institute (HEI), an organization jointly funded by the United States
Environmental Protection Agency (Assistance Award No CR-83998101) and certain motor vehicle and engine manufacturers.
(Contract #4985-RFA20-1B/21-8) The contents of this repository do not necessarily reflect the views of HEI, or its sponsors, nor do they
necessarily reflect the views and policies of the EPA or motor vehicle and engine manufacturers.
