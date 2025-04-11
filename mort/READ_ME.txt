This folder contains the programming code to replicate the excess mortality analysis. We used methods and code originally reported in the Pelat et al article cited below. 

Code and Instructions from 

C Pelat et al "Online detection and quantification of epidemics"  BMC Medical Informatics and Decision Making doi:https://doi.org/10.1186/1472-6947-7-29

Instructions to replicate excess mortality analysis

- create a working directory
Put the 5 scripts there. (functions.R, model.R, purge.R, run_model.R, run_purge.R)

- create the subdirectories "tables", "images", "fichiers".
Place your datafile in "tables".
"images" and "fichiers" will respectively receive the generated graphics and output files.
(They must have the necessary rights for being written in).

- in both "run" scripts paste the absolute path to your work directory in the setwd() command and enter your parameters.

- run the scripts with R software.

*Note: We also include dataprep.R, programming code to create the purge files used in the run_model program. These could also be made manually.

*Note: We cannot post original data files or data dictionaries for files provided by DOHMH. The datafiles placed in the "tables" folder (as described above) are a single column containing the counts of excess mortality for each month. Each data file corresponds to the different strata of interest (e.g. low NEVI and low air pollution, high NEVI and high air pollution, etc)
