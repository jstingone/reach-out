
### Program running the purge of the epiresics in the training period ###
# Structure from Pelat et al; Adapted and Run by JAS in R 4.2.2
# gets the parameters
# calls 'purge.R' that contains the algorithm
# NEEDS - a subdirectory 'tables' containing the datafile
#       - a subdirectory 'images' to place the graphics
#       - requires user input for wd and parameters
#         leaving ours as an illustration
#########################################################################

setwd("folder-path")
# sets the work directory: replace this one by your own one (the one where you placed this script)
# make sure you created the 'images', 'tables' and 'fichiers' subdirectories

##################### General Parameters #################
file_base		= './tables/lowap_lownevires_baseline.csv'	#name of the datafile
nb_app     	= 60  		#length of the training period 
date1_char	= '1/1/2015'	#first date (starting date) of the dataset
time_step	= 'month' 		#time step of the dataset
ylab		= 'monthly mortality (cases for 100000)'			#graphic option for plot
title		= 'All-cause mortality in New York City-'	#graphic option for plot
# choix_seuil = 'file'	#purging method chosen
choix_seuil = 'percentile'	#purging method chosen
# file_epid = './purge_hap_hnevires.csv'
s = 5
sessionid		= 'lowap_lownevires' #Session ID returned by the PHP function session_id()
time			= '113'	#the time this script was executed
###################################################


source('purge.R')

