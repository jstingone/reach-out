
### Program running the model fitting ###
# Structure from Petal et al; Adapted and Run by JAS in R 4.2.2
# gets the parameters
# calls 'functions.R' that contains the necessary functions
# calls 'model.R' that contains the program
# NEEDS - a subdirectory 'tables' containing the datafile
#       - a subdirectory 'images' to place the graphics
#       -Each bock of code requires user input of file name and parameters
#         For illustration, we have kept our inputs.
#########################################################################

setwd("folder-path")
# sets the work directory: replace this one by your own one (the one where you placed this script)
# make sure you created the 'images', 'tables' and 'fichiers' subdirectories

##########LOW AIR POLLUTION########

##################### General Parameters #################
file_base		= './tables/lowap_highnevihealth_2020.csv'	#name of the datafile
nb_app     	= 72 		#length of the training period 
date1_char	= '1/1/2015'	#first date (starting date) of the dataset
time_step	= 'month' 		#time step of the dataset
ylab		= 'monthly mortality (cases for 100000)'			#graphic option for plot
title		= 'All-cause mortality in New York City'	#graphic option for plot
choix_seuil = 'file'	#purging method chosen
#choic_seuil = 'percentile'
file_epid = './purge_lap_hnevihealth.csv'
#s=5
sessionid		= 'lowap_highnevihealth' #Session ID returned by the PHP function session_id()
time			= '114'	#the time this script was executed
###################################################


### Parameters specific to the model fitting ######
setting    	= 'retrospective'  		#type of the analysis ('prospective' or 'retrospective')
temps_epid 	= 1  		#minimal number of high observations in a row allowing to issue an alert (detection rule)
CL			= 95							#confidence interval level
model_choice 	= 'selection_algo'			#name of the model chosen (M11, M12, M13, M21, M22, M23, M31, M32, M33) or 'selection_algo'


###################################################
source('functions.R')
source('model.R')


##################### General Parameters #################
file_base		= './tables/lowap_highneviecon_2020.csv'	#name of the datafile
nb_app     	= 72 		#length of the training period 
date1_char	= '1/1/2015'	#first date (starting date) of the dataset
time_step	= 'month' 		#time step of the dataset
ylab		= 'monthly mortality (cases for 100000)'			#graphic option for plot
title		= 'All-cause mortality in New York City'	#graphic option for plot
choix_seuil = 'file'	#purging method chosen
#choic_seuil = 'percentile'
file_epid = './purge_lap_hneviecon.csv'
#s=5
sessionid		= 'lowap_highneviecon' #Session ID returned by the PHP function session_id()
time			= '114'	#the time this script was executed
###################################################


### Parameters specific to the model fitting ######
setting    	= 'retrospective'  		#type of the analysis ('prospective' or 'retrospective')
temps_epid 	= 1  		#minimal number of high observations in a row allowing to issue an alert (detection rule)
CL			= 95							#confidence interval level
model_choice 	= 'selection_algo'			#name of the model chosen (M11, M12, M13, M21, M22, M23, M31, M32, M33) or 'selection_algo'


###################################################
source('functions.R')
source('model.R')

##################### General Parameters #################
file_base		= './tables/lowap_highnevidem_2020.csv'	#name of the datafile
nb_app     	= 72 		#length of the training period 
date1_char	= '1/1/2015'	#first date (starting date) of the dataset
time_step	= 'month' 		#time step of the dataset
ylab		= 'monthly mortality (cases for 100000)'			#graphic option for plot
title		= 'All-cause mortality in New York City'	#graphic option for plot
choix_seuil = 'file'	#purging method chosen
#choic_seuil = 'percentile'
file_epid = './purge_lap_hnevidem.csv'
#s=5
sessionid		= 'lowap_highnevidem' #Session ID returned by the PHP function session_id()
time			= '114'	#the time this script was executed
###################################################


### Parameters specific to the model fitting ######
setting    	= 'retrospective'  		#type of the analysis ('prospective' or 'retrospective')
temps_epid 	= 1  		#minimal number of high observations in a row allowing to issue an alert (detection rule)
CL			= 95							#confidence interval level
model_choice 	= 'selection_algo'			#name of the model chosen (M11, M12, M13, M21, M22, M23, M31, M32, M33) or 'selection_algo'


###################################################
source('functions.R')
source('model.R')


##################### General Parameters #################
file_base		= './tables/lowap_mednevihealth_2020.csv'	#name of the datafile
nb_app     	= 72 		#length of the training period 
date1_char	= '1/1/2015'	#first date (starting date) of the dataset
time_step	= 'month' 		#time step of the dataset
ylab		= 'monthly mortality (cases for 100000)'			#graphic option for plot
title		= 'All-cause mortality in New York City'	#graphic option for plot
choix_seuil = 'file'	#purging method chosen
#choic_seuil = 'percentile'
file_epid = './purge_lap_mnevihealth.csv'
#s=5
sessionid		= 'lowap_mednevihealth' #Session ID returned by the PHP function session_id()
time			= '114'	#the time this script was executed
###################################################


### Parameters specific to the model fitting ######
setting    	= 'retrospective'  		#type of the analysis ('prospective' or 'retrospective')
temps_epid 	= 1  		#minimal number of high observations in a row allowing to issue an alert (detection rule)
CL			= 95							#confidence interval level
model_choice 	= 'selection_algo'			#name of the model chosen (M11, M12, M13, M21, M22, M23, M31, M32, M33) or 'selection_algo'


###################################################
source('functions.R')
source('model.R')

##################### General Parameters #################
file_base		= './tables/lowap_mednevires_2020.csv'	#name of the datafile
nb_app     	= 72 		#length of the training period 
date1_char	= '1/1/2015'	#first date (starting date) of the dataset
time_step	= 'month' 		#time step of the dataset
ylab		= 'monthly mortality (cases for 100000)'			#graphic option for plot
title		= 'All-cause mortality in New York City'	#graphic option for plot
choix_seuil = 'file'	#purging method chosen
#choic_seuil = 'percentile'
file_epid = './purge_lap_mnevires.csv'
#s=5
sessionid		= 'lowap_mednevires' #Session ID returned by the PHP function session_id()
time			= '114'	#the time this script was executed
###################################################


### Parameters specific to the model fitting ######
setting    	= 'retrospective'  		#type of the analysis ('prospective' or 'retrospective')
temps_epid 	= 1  		#minimal number of high observations in a row allowing to issue an alert (detection rule)
CL			= 95							#confidence interval level
model_choice 	= 'selection_algo'			#name of the model chosen (M11, M12, M13, M21, M22, M23, M31, M32, M33) or 'selection_algo'


###################################################
source('functions.R')
source('model.R')

##################### General Parameters #################
file_base		= './tables/lowap_medneviecon_2020.csv'	#name of the datafile
nb_app     	= 72 		#length of the training period 
date1_char	= '1/1/2015'	#first date (starting date) of the dataset
time_step	= 'month' 		#time step of the dataset
ylab		= 'monthly mortality (cases for 100000)'			#graphic option for plot
title		= 'All-cause mortality in New York City'	#graphic option for plot
choix_seuil = 'file'	#purging method chosen
#choic_seuil = 'percentile'
file_epid = './purge_lap_mneviecon.csv'
#s=5
sessionid		= 'lowap_medneviecon' #Session ID returned by the PHP function session_id()
time			= '114'	#the time this script was executed
###################################################


### Parameters specific to the model fitting ######
setting    	= 'retrospective'  		#type of the analysis ('prospective' or 'retrospective')
temps_epid 	= 1  		#minimal number of high observations in a row allowing to issue an alert (detection rule)
CL			= 95							#confidence interval level
model_choice 	= 'selection_algo'			#name of the model chosen (M11, M12, M13, M21, M22, M23, M31, M32, M33) or 'selection_algo'


###################################################
source('functions.R')
source('model.R')

##################### General Parameters #################
file_base		= './tables/lowap_mednevidem_2020.csv'	#name of the datafile
nb_app     	= 72 		#length of the training period 
date1_char	= '1/1/2015'	#first date (starting date) of the dataset
time_step	= 'month' 		#time step of the dataset
ylab		= 'monthly mortality (cases for 100000)'			#graphic option for plot
title		= 'All-cause mortality in New York City'	#graphic option for plot
choix_seuil = 'file'	#purging method chosen
#choic_seuil = 'percentile'
file_epid = './purge_lap_mnevidem.csv'
#s=5
sessionid		= 'lowap_mednevidem' #Session ID returned by the PHP function session_id()
time			= '114'	#the time this script was executed
###################################################


### Parameters specific to the model fitting ######
setting    	= 'retrospective'  		#type of the analysis ('prospective' or 'retrospective')
temps_epid 	= 1  		#minimal number of high observations in a row allowing to issue an alert (detection rule)
CL			= 95							#confidence interval level
model_choice 	= 'selection_algo'			#name of the model chosen (M11, M12, M13, M21, M22, M23, M31, M32, M33) or 'selection_algo'


###################################################
source('functions.R')
source('model.R')

##################### General Parameters #################
file_base		= './tables/lowap_lownevihealth_2020.csv'	#name of the datafile
nb_app     	= 72 		#length of the training period 
date1_char	= '1/1/2015'	#first date (starting date) of the dataset
time_step	= 'month' 		#time step of the dataset
ylab		= 'monthly mortality (cases for 100000)'			#graphic option for plot
title		= 'All-cause mortality in New York City'	#graphic option for plot
choix_seuil = 'file'	#purging method chosen
#choic_seuil = 'percentile'
file_epid = './purge_lap_lnevihealth.csv'
#s=5
sessionid		= 'lowap_lownevihealth' #Session ID returned by the PHP function session_id()
time			= '114'	#the time this script was executed
###################################################


### Parameters specific to the model fitting ######
setting    	= 'retrospective'  		#type of the analysis ('prospective' or 'retrospective')
temps_epid 	= 1  		#minimal number of high observations in a row allowing to issue an alert (detection rule)
CL			= 95							#confidence interval level
model_choice 	= 'selection_algo'			#name of the model chosen (M11, M12, M13, M21, M22, M23, M31, M32, M33) or 'selection_algo'


###################################################
source('functions.R')
source('model.R')

##################### General Parameters #################
file_base		= './tables/lowap_lownevires_2020.csv'	#name of the datafile
nb_app     	= 72 		#length of the training period 
date1_char	= '1/1/2015'	#first date (starting date) of the dataset
time_step	= 'month' 		#time step of the dataset
ylab		= 'monthly mortality (cases for 100000)'			#graphic option for plot
title		= 'All-cause mortality in New York City'	#graphic option for plot
choix_seuil = 'file'	#purging method chosen
#choic_seuil = 'percentile'
file_epid = './purge_lap_lnevires.csv'
#s=5
sessionid		= 'lowap_lownevires' #Session ID returned by the PHP function session_id()
time			= '114'	#the time this script was executed
###################################################


### Parameters specific to the model fitting ######
setting    	= 'retrospective'  		#type of the analysis ('prospective' or 'retrospective')
temps_epid 	= 1  		#minimal number of high observations in a row allowing to issue an alert (detection rule)
CL			= 95							#confidence interval level
model_choice 	= 'selection_algo'			#name of the model chosen (M11, M12, M13, M21, M22, M23, M31, M32, M33) or 'selection_algo'


###################################################
source('functions.R')
source('model.R')

##################### General Parameters #################
file_base		= './tables/lowap_lowneviecon_2020.csv'	#name of the datafile
nb_app     	= 72 		#length of the training period 
date1_char	= '1/1/2015'	#first date (starting date) of the dataset
time_step	= 'month' 		#time step of the dataset
ylab		= 'monthly mortality (cases for 100000)'			#graphic option for plot
title		= 'All-cause mortality in New York City'	#graphic option for plot
choix_seuil = 'file'	#purging method chosen
#choic_seuil = 'percentile'
file_epid = './purge_lap_lneviecon.csv'
#s=5
sessionid		= 'lowap_lowneviecon' #Session ID returned by the PHP function session_id()
time			= '114'	#the time this script was executed
###################################################


### Parameters specific to the model fitting ######
setting    	= 'retrospective'  		#type of the analysis ('prospective' or 'retrospective')
temps_epid 	= 1  		#minimal number of high observations in a row allowing to issue an alert (detection rule)
CL			= 95							#confidence interval level
model_choice 	= 'selection_algo'			#name of the model chosen (M11, M12, M13, M21, M22, M23, M31, M32, M33) or 'selection_algo'


###################################################
source('functions.R')
source('model.R')

##################### General Parameters #################
file_base		= './tables/lowap_lownevidem_2020.csv'	#name of the datafile
nb_app     	= 72 		#length of the training period 
date1_char	= '1/1/2015'	#first date (starting date) of the dataset
time_step	= 'month' 		#time step of the dataset
ylab		= 'monthly mortality (cases for 100000)'			#graphic option for plot
title		= 'All-cause mortality in New York City'	#graphic option for plot
choix_seuil = 'file'	#purging method chosen
#choic_seuil = 'percentile'
file_epid = './purge_lap_lnevidem.csv'
#s=5
sessionid		= 'lowap_lownevidem' #Session ID returned by the PHP function session_id()
time			= '114'	#the time this script was executed
###################################################


### Parameters specific to the model fitting ######
setting    	= 'retrospective'  		#type of the analysis ('prospective' or 'retrospective')
temps_epid 	= 1  		#minimal number of high observations in a row allowing to issue an alert (detection rule)
CL			= 95							#confidence interval level
model_choice 	= 'selection_algo'			#name of the model chosen (M11, M12, M13, M21, M22, M23, M31, M32, M33) or 'selection_algo'


###################################################
source('functions.R')
source('model.R')



#####MEDIUM AIR POLLUTION###########

##################### General Parameters #################
file_base		= './tables/medap_highnevihealth_2020.csv'	#name of the datafile
nb_app     	= 72 		#length of the training period 
date1_char	= '1/1/2015'	#first date (starting date) of the dataset
time_step	= 'month' 		#time step of the dataset
ylab		= 'monthly mortality (cases for 100000)'			#graphic option for plot
title		= 'All-cause mortality in New York City'	#graphic option for plot
choix_seuil = 'file'	#purging method chosen
#choic_seuil = 'percentile'
file_epid = './purge_map_hnevihealth.csv'
#s=5
sessionid		= 'medap_highnevihealth' #Session ID returned by the PHP function session_id()
time			= '114'	#the time this script was executed
###################################################


### Parameters specific to the model fitting ######
setting    	= 'retrospective'  		#type of the analysis ('prospective' or 'retrospective')
temps_epid 	= 1  		#minimal number of high observations in a row allowing to issue an alert (detection rule)
CL			= 95							#confidence interval level
model_choice 	= 'selection_algo'			#name of the model chosen (M11, M12, M13, M21, M22, M23, M31, M32, M33) or 'selection_algo'


###################################################
source('functions.R')
source('model.R')

##################### General Parameters #################
file_base		= './tables/medap_highnevires_2020.csv'	#name of the datafile
nb_app     	= 72 		#length of the training period 
date1_char	= '1/1/2015'	#first date (starting date) of the dataset
time_step	= 'month' 		#time step of the dataset
ylab		= 'monthly mortality (cases for 100000)'			#graphic option for plot
title		= 'All-cause mortality in New York City'	#graphic option for plot
choix_seuil = 'file'	#purging method chosen
#choic_seuil = 'percentile'
file_epid = './purge_map_hnevires.csv'
#s=5
sessionid		= 'medap_highnevires' #Session ID returned by the PHP function session_id()
time			= '114'	#the time this script was executed
###################################################


### Parameters specific to the model fitting ######
setting    	= 'retrospective'  		#type of the analysis ('prospective' or 'retrospective')
temps_epid 	= 1  		#minimal number of high observations in a row allowing to issue an alert (detection rule)
CL			= 95							#confidence interval level
model_choice 	= 'selection_algo'			#name of the model chosen (M11, M12, M13, M21, M22, M23, M31, M32, M33) or 'selection_algo'


###################################################
source('functions.R')
source('model.R')

##################### General Parameters #################
file_base		= './tables/medap_highneviecon_2020.csv'	#name of the datafile
nb_app     	= 72 		#length of the training period 
date1_char	= '1/1/2015'	#first date (starting date) of the dataset
time_step	= 'month' 		#time step of the dataset
ylab		= 'monthly mortality (cases for 100000)'			#graphic option for plot
title		= 'All-cause mortality in New York City'	#graphic option for plot
choix_seuil = 'file'	#purging method chosen
#choic_seuil = 'percentile'
file_epid = './purge_map_hneviecon.csv'
#s=5
sessionid		= 'medap_highneviecon' #Session ID returned by the PHP function session_id()
time			= '114'	#the time this script was executed
###################################################


### Parameters specific to the model fitting ######
setting    	= 'retrospective'  		#type of the analysis ('prospective' or 'retrospective')
temps_epid 	= 1  		#minimal number of high observations in a row allowing to issue an alert (detection rule)
CL			= 95							#confidence interval level
model_choice 	= 'selection_algo'			#name of the model chosen (M11, M12, M13, M21, M22, M23, M31, M32, M33) or 'selection_algo'


###################################################
source('functions.R')
source('model.R')

##################### General Parameters #################
file_base		= './tables/medap_highnevidem_2020.csv'	#name of the datafile
nb_app     	= 72 		#length of the training period 
date1_char	= '1/1/2015'	#first date (starting date) of the dataset
time_step	= 'month' 		#time step of the dataset
ylab		= 'monthly mortality (cases for 100000)'			#graphic option for plot
title		= 'All-cause mortality in New York City'	#graphic option for plot
choix_seuil = 'file'	#purging method chosen
#choic_seuil = 'percentile'
file_epid = './purge_map_hnevidem.csv'
#s=5
sessionid		= 'medap_highnevidem' #Session ID returned by the PHP function session_id()
time			= '114'	#the time this script was executed
###################################################


### Parameters specific to the model fitting ######
setting    	= 'retrospective'  		#type of the analysis ('prospective' or 'retrospective')
temps_epid 	= 1  		#minimal number of high observations in a row allowing to issue an alert (detection rule)
CL			= 95							#confidence interval level
model_choice 	= 'selection_algo'			#name of the model chosen (M11, M12, M13, M21, M22, M23, M31, M32, M33) or 'selection_algo'


###################################################
source('functions.R')
source('model.R')


##################### General Parameters #################
file_base		= './tables/medap_mednevihealth_2020.csv'	#name of the datafile
nb_app     	= 72 		#length of the training period 
date1_char	= '1/1/2015'	#first date (starting date) of the dataset
time_step	= 'month' 		#time step of the dataset
ylab		= 'monthly mortality (cases for 100000)'			#graphic option for plot
title		= 'All-cause mortality in New York City'	#graphic option for plot
choix_seuil = 'file'	#purging method chosen
#choic_seuil = 'percentile'
file_epid = './purge_map_mnevihealth.csv'
#s=5
sessionid		= 'medap_mednevihealth' #Session ID returned by the PHP function session_id()
time			= '114'	#the time this script was executed
###################################################


### Parameters specific to the model fitting ######
setting    	= 'retrospective'  		#type of the analysis ('prospective' or 'retrospective')
temps_epid 	= 1  		#minimal number of high observations in a row allowing to issue an alert (detection rule)
CL			= 95							#confidence interval level
model_choice 	= 'selection_algo'			#name of the model chosen (M11, M12, M13, M21, M22, M23, M31, M32, M33) or 'selection_algo'


###################################################
source('functions.R')
source('model.R')

##################### General Parameters #################
file_base		= './tables/medap_mednevires_2020.csv'	#name of the datafile
nb_app     	= 72 		#length of the training period 
date1_char	= '1/1/2015'	#first date (starting date) of the dataset
time_step	= 'month' 		#time step of the dataset
ylab		= 'monthly mortality (cases for 100000)'			#graphic option for plot
title		= 'All-cause mortality in New York City'	#graphic option for plot
choix_seuil = 'file'	#purging method chosen
#choic_seuil = 'percentile'
file_epid = './purge_map_mnevires.csv'
#s=5
sessionid		= 'medap_mednevires' #Session ID returned by the PHP function session_id()
time			= '114'	#the time this script was executed
###################################################


### Parameters specific to the model fitting ######
setting    	= 'retrospective'  		#type of the analysis ('prospective' or 'retrospective')
temps_epid 	= 1  		#minimal number of high observations in a row allowing to issue an alert (detection rule)
CL			= 95							#confidence interval level
model_choice 	= 'selection_algo'			#name of the model chosen (M11, M12, M13, M21, M22, M23, M31, M32, M33) or 'selection_algo'


###################################################
source('functions.R')
source('model.R')

##################### General Parameters #################
file_base		= './tables/medap_medneviecon_2020.csv'	#name of the datafile
nb_app     	= 72 		#length of the training period 
date1_char	= '1/1/2015'	#first date (starting date) of the dataset
time_step	= 'month' 		#time step of the dataset
ylab		= 'monthly mortality (cases for 100000)'			#graphic option for plot
title		= 'All-cause mortality in New York City'	#graphic option for plot
choix_seuil = 'file'	#purging method chosen
#choic_seuil = 'percentile'
file_epid = './purge_map_mneviecon.csv'
#s=5
sessionid		= 'medap_medneviecon' #Session ID returned by the PHP function session_id()
time			= '114'	#the time this script was executed
###################################################


### Parameters specific to the model fitting ######
setting    	= 'retrospective'  		#type of the analysis ('prospective' or 'retrospective')
temps_epid 	= 1  		#minimal number of high observations in a row allowing to issue an alert (detection rule)
CL			= 95							#confidence interval level
model_choice 	= 'selection_algo'			#name of the model chosen (M11, M12, M13, M21, M22, M23, M31, M32, M33) or 'selection_algo'


###################################################
source('functions.R')
source('model.R')

##################### General Parameters #################
file_base		= './tables/medap_mednevidem_2020.csv'	#name of the datafile
nb_app     	= 72 		#length of the training period 
date1_char	= '1/1/2015'	#first date (starting date) of the dataset
time_step	= 'month' 		#time step of the dataset
ylab		= 'monthly mortality (cases for 100000)'			#graphic option for plot
title		= 'All-cause mortality in New York City'	#graphic option for plot
choix_seuil = 'file'	#purging method chosen
#choic_seuil = 'percentile'
file_epid = './purge_map_mnevidem.csv'
#s=5
sessionid		= 'medap_mednevidem' #Session ID returned by the PHP function session_id()
time			= '114'	#the time this script was executed
###################################################


### Parameters specific to the model fitting ######
setting    	= 'retrospective'  		#type of the analysis ('prospective' or 'retrospective')
temps_epid 	= 1  		#minimal number of high observations in a row allowing to issue an alert (detection rule)
CL			= 95							#confidence interval level
model_choice 	= 'selection_algo'			#name of the model chosen (M11, M12, M13, M21, M22, M23, M31, M32, M33) or 'selection_algo'


###################################################
source('functions.R')
source('model.R')

##################### General Parameters #################
file_base		= './tables/medap_lownevihealth_2020.csv'	#name of the datafile
nb_app     	= 72 		#length of the training period 
date1_char	= '1/1/2015'	#first date (starting date) of the dataset
time_step	= 'month' 		#time step of the dataset
ylab		= 'monthly mortality (cases for 100000)'			#graphic option for plot
title		= 'All-cause mortality in New York City'	#graphic option for plot
choix_seuil = 'file'	#purging method chosen
#choic_seuil = 'percentile'
file_epid = './purge_map_lnevihealth.csv'
#s=5
sessionid		= 'medap_lownevihealth' #Session ID returned by the PHP function session_id()
time			= '114'	#the time this script was executed
###################################################


### Parameters specific to the model fitting ######
setting    	= 'retrospective'  		#type of the analysis ('prospective' or 'retrospective')
temps_epid 	= 1  		#minimal number of high observations in a row allowing to issue an alert (detection rule)
CL			= 95							#confidence interval level
model_choice 	= 'selection_algo'			#name of the model chosen (M11, M12, M13, M21, M22, M23, M31, M32, M33) or 'selection_algo'


###################################################
source('functions.R')
source('model.R')

##################### General Parameters #################
file_base		= './tables/medap_lownevires_2020.csv'	#name of the datafile
nb_app     	= 72 		#length of the training period 
date1_char	= '1/1/2015'	#first date (starting date) of the dataset
time_step	= 'month' 		#time step of the dataset
ylab		= 'monthly mortality (cases for 100000)'			#graphic option for plot
title		= 'All-cause mortality in New York City'	#graphic option for plot
choix_seuil = 'file'	#purging method chosen
#choic_seuil = 'percentile'
file_epid = './purge_map_lnevires.csv'
#s=5
sessionid		= 'medap_lownevires' #Session ID returned by the PHP function session_id()
time			= '114'	#the time this script was executed
###################################################


### Parameters specific to the model fitting ######
setting    	= 'retrospective'  		#type of the analysis ('prospective' or 'retrospective')
temps_epid 	= 1  		#minimal number of high observations in a row allowing to issue an alert (detection rule)
CL			= 95							#confidence interval level
model_choice 	= 'selection_algo'			#name of the model chosen (M11, M12, M13, M21, M22, M23, M31, M32, M33) or 'selection_algo'


###################################################
source('functions.R')
source('model.R')

##################### General Parameters #################
file_base		= './tables/medap_lowneviecon_2020.csv'	#name of the datafile
nb_app     	= 72 		#length of the training period 
date1_char	= '1/1/2015'	#first date (starting date) of the dataset
time_step	= 'month' 		#time step of the dataset
ylab		= 'monthly mortality (cases for 100000)'			#graphic option for plot
title		= 'All-cause mortality in New York City'	#graphic option for plot
choix_seuil = 'file'	#purging method chosen
#choic_seuil = 'percentile'
file_epid = './purge_map_lneviecon.csv'
#s=5
sessionid		= 'medap_lowneviecon' #Session ID returned by the PHP function session_id()
time			= '114'	#the time this script was executed
###################################################


### Parameters specific to the model fitting ######
setting    	= 'retrospective'  		#type of the analysis ('prospective' or 'retrospective')
temps_epid 	= 1  		#minimal number of high observations in a row allowing to issue an alert (detection rule)
CL			= 95							#confidence interval level
model_choice 	= 'selection_algo'			#name of the model chosen (M11, M12, M13, M21, M22, M23, M31, M32, M33) or 'selection_algo'


###################################################
source('functions.R')
source('model.R')

##################### General Parameters #################
file_base		= './tables/medap_lownevidem_2020.csv'	#name of the datafile
nb_app     	= 72 		#length of the training period 
date1_char	= '1/1/2015'	#first date (starting date) of the dataset
time_step	= 'month' 		#time step of the dataset
ylab		= 'monthly mortality (cases for 100000)'			#graphic option for plot
title		= 'All-cause mortality in New York City'	#graphic option for plot
choix_seuil = 'file'	#purging method chosen
#choic_seuil = 'percentile'
file_epid = './purge_map_lnevidem.csv'
#s=5
sessionid		= 'medap_lownevidem' #Session ID returned by the PHP function session_id()
time			= '114'	#the time this script was executed
###################################################


### Parameters specific to the model fitting ######
setting    	= 'retrospective'  		#type of the analysis ('prospective' or 'retrospective')
temps_epid 	= 1  		#minimal number of high observations in a row allowing to issue an alert (detection rule)
CL			= 95							#confidence interval level
model_choice 	= 'selection_algo'			#name of the model chosen (M11, M12, M13, M21, M22, M23, M31, M32, M33) or 'selection_algo'


###################################################
source('functions.R')
source('model.R')


##### HIGH AIR POLLUTION###########

##################### General Parameters #################
file_base		= './tables/highap_highnevihealth_2020.csv'	#name of the datafile
nb_app     	= 72 		#length of the training period 
date1_char	= '1/1/2015'	#first date (starting date) of the dataset
time_step	= 'month' 		#time step of the dataset
ylab		= 'monthly mortality (cases for 100000)'			#graphic option for plot
title		= 'All-cause mortality in New York City'	#graphic option for plot
choix_seuil = 'file'	#purging method chosen
#choic_seuil = 'percentile'
file_epid = './purge_hap_hnevihealth.csv'
#s=5
sessionid		= 'highap_highnevihealth' #Session ID returned by the PHP function session_id()
time			= '114'	#the time this script was executed
###################################################


### Parameters specific to the model fitting ######
setting    	= 'retrospective'  		#type of the analysis ('prospective' or 'retrospective')
temps_epid 	= 1  		#minimal number of high observations in a row allowing to issue an alert (detection rule)
CL			= 95							#confidence interval level
model_choice 	= 'selection_algo'			#name of the model chosen (M11, M12, M13, M21, M22, M23, M31, M32, M33) or 'selection_algo'


###################################################
source('functions.R')
source('model.R')

##################### General Parameters #################
file_base		= './tables/highap_highnevires_2020.csv'	#name of the datafile
nb_app     	= 72 		#length of the training period 
date1_char	= '1/1/2015'	#first date (starting date) of the dataset
time_step	= 'month' 		#time step of the dataset
ylab		= 'monthly mortality (cases for 100000)'			#graphic option for plot
title		= 'All-cause mortality in New York City'	#graphic option for plot
choix_seuil = 'file'	#purging method chosen
#choic_seuil = 'percentile'
file_epid = './purge_hap_hnevires.csv'
#s=5
sessionid		= 'highap_highnevires' #Session ID returned by the PHP function session_id()
time			= '114'	#the time this script was executed
###################################################


### Parameters specific to the model fitting ######
setting    	= 'retrospective'  		#type of the analysis ('prospective' or 'retrospective')
temps_epid 	= 1  		#minimal number of high observations in a row allowing to issue an alert (detection rule)
CL			= 95							#confidence interval level
model_choice 	= 'selection_algo'			#name of the model chosen (M11, M12, M13, M21, M22, M23, M31, M32, M33) or 'selection_algo'


###################################################
source('functions.R')
source('model.R')

##################### General Parameters #################
file_base		= './tables/highap_highneviecon_2020.csv'	#name of the datafile
nb_app     	= 72 		#length of the training period 
date1_char	= '1/1/2015'	#first date (starting date) of the dataset
time_step	= 'month' 		#time step of the dataset
ylab		= 'monthly mortality (cases for 100000)'			#graphic option for plot
title		= 'All-cause mortality in New York City'	#graphic option for plot
choix_seuil = 'file'	#purging method chosen
#choic_seuil = 'percentile'
file_epid = './purge_hap_hneviecon.csv'
#s=5
sessionid		= 'highap_highneviecon' #Session ID returned by the PHP function session_id()
time			= '114'	#the time this script was executed
###################################################


### Parameters specific to the model fitting ######
setting    	= 'retrospective'  		#type of the analysis ('prospective' or 'retrospective')
temps_epid 	= 1  		#minimal number of high observations in a row allowing to issue an alert (detection rule)
CL			= 95							#confidence interval level
model_choice 	= 'selection_algo'			#name of the model chosen (M11, M12, M13, M21, M22, M23, M31, M32, M33) or 'selection_algo'


###################################################
source('functions.R')
source('model.R')

##################### General Parameters #################
file_base		= './tables/highap_highnevidem_2020.csv'	#name of the datafile
nb_app     	= 72 		#length of the training period 
date1_char	= '1/1/2015'	#first date (starting date) of the dataset
time_step	= 'month' 		#time step of the dataset
ylab		= 'monthly mortality (cases for 100000)'			#graphic option for plot
title		= 'All-cause mortality in New York City'	#graphic option for plot
choix_seuil = 'file'	#purging method chosen
#choic_seuil = 'percentile'
file_epid = './purge_hap_hnevidem.csv'
#s=5
sessionid		= 'highap_highnevidem' #Session ID returned by the PHP function session_id()
time			= '114'	#the time this script was executed
###################################################


### Parameters specific to the model fitting ######
setting    	= 'retrospective'  		#type of the analysis ('prospective' or 'retrospective')
temps_epid 	= 1  		#minimal number of high observations in a row allowing to issue an alert (detection rule)
CL			= 95							#confidence interval level
model_choice 	= 'selection_algo'			#name of the model chosen (M11, M12, M13, M21, M22, M23, M31, M32, M33) or 'selection_algo'


###################################################
source('functions.R')
source('model.R')


##################### General Parameters #################
file_base		= './tables/highap_mednevihealth_2020.csv'	#name of the datafile
nb_app     	= 72 		#length of the training period 
date1_char	= '1/1/2015'	#first date (starting date) of the dataset
time_step	= 'month' 		#time step of the dataset
ylab		= 'monthly mortality (cases for 100000)'			#graphic option for plot
title		= 'All-cause mortality in New York City'	#graphic option for plot
choix_seuil = 'file'	#purging method chosen
#choic_seuil = 'percentile'
file_epid = './purge_hap_mnevihealth.csv'
#s=5
sessionid		= 'highap_mednevihealth' #Session ID returned by the PHP function session_id()
time			= '114'	#the time this script was executed
###################################################


### Parameters specific to the model fitting ######
setting    	= 'retrospective'  		#type of the analysis ('prospective' or 'retrospective')
temps_epid 	= 1  		#minimal number of high observations in a row allowing to issue an alert (detection rule)
CL			= 95							#confidence interval level
model_choice 	= 'selection_algo'			#name of the model chosen (M11, M12, M13, M21, M22, M23, M31, M32, M33) or 'selection_algo'


###################################################
source('functions.R')
source('model.R')

##################### General Parameters #################
file_base		= './tables/highap_mednevires_2020.csv'	#name of the datafile
nb_app     	= 72 		#length of the training period 
date1_char	= '1/1/2015'	#first date (starting date) of the dataset
time_step	= 'month' 		#time step of the dataset
ylab		= 'monthly mortality (cases for 100000)'			#graphic option for plot
title		= 'All-cause mortality in New York City'	#graphic option for plot
choix_seuil = 'file'	#purging method chosen
#choic_seuil = 'percentile'
file_epid = './purge_hap_mnevires.csv'
#s=5
sessionid		= 'highap_mednevires' #Session ID returned by the PHP function session_id()
time			= '114'	#the time this script was executed
###################################################


### Parameters specific to the model fitting ######
setting    	= 'retrospective'  		#type of the analysis ('prospective' or 'retrospective')
temps_epid 	= 1  		#minimal number of high observations in a row allowing to issue an alert (detection rule)
CL			= 95							#confidence interval level
model_choice 	= 'selection_algo'			#name of the model chosen (M11, M12, M13, M21, M22, M23, M31, M32, M33) or 'selection_algo'


###################################################
source('functions.R')
source('model.R')

##################### General Parameters #################
file_base		= './tables/highap_medneviecon_2020.csv'	#name of the datafile
nb_app     	= 72 		#length of the training period 
date1_char	= '1/1/2015'	#first date (starting date) of the dataset
time_step	= 'month' 		#time step of the dataset
ylab		= 'monthly mortality (cases for 100000)'			#graphic option for plot
title		= 'All-cause mortality in New York City'	#graphic option for plot
choix_seuil = 'file'	#purging method chosen
#choic_seuil = 'percentile'
file_epid = './purge_hap_mneviecon.csv'
#s=5
sessionid		= 'highap_medneviecon' #Session ID returned by the PHP function session_id()
time			= '114'	#the time this script was executed
###################################################


### Parameters specific to the model fitting ######
setting    	= 'retrospective'  		#type of the analysis ('prospective' or 'retrospective')
temps_epid 	= 1  		#minimal number of high observations in a row allowing to issue an alert (detection rule)
CL			= 95							#confidence interval level
model_choice 	= 'selection_algo'			#name of the model chosen (M11, M12, M13, M21, M22, M23, M31, M32, M33) or 'selection_algo'


###################################################
source('functions.R')
source('model.R')

##################### General Parameters #################
file_base		= './tables/highap_mednevidem_2020.csv'	#name of the datafile
nb_app     	= 72 		#length of the training period 
date1_char	= '1/1/2015'	#first date (starting date) of the dataset
time_step	= 'month' 		#time step of the dataset
ylab		= 'monthly mortality (cases for 100000)'			#graphic option for plot
title		= 'All-cause mortality in New York City'	#graphic option for plot
choix_seuil = 'file'	#purging method chosen
#choic_seuil = 'percentile'
file_epid = './purge_hap_mnevidem.csv'
#s=5
sessionid		= 'highap_mednevidem' #Session ID returned by the PHP function session_id()
time			= '114'	#the time this script was executed
###################################################


### Parameters specific to the model fitting ######
setting    	= 'retrospective'  		#type of the analysis ('prospective' or 'retrospective')
temps_epid 	= 1  		#minimal number of high observations in a row allowing to issue an alert (detection rule)
CL			= 95							#confidence interval level
model_choice 	= 'selection_algo'			#name of the model chosen (M11, M12, M13, M21, M22, M23, M31, M32, M33) or 'selection_algo'


###################################################
source('functions.R')
source('model.R')

##################### General Parameters #################
file_base		= './tables/highap_lownevihealth_2020.csv'	#name of the datafile
nb_app     	= 72 		#length of the training period 
date1_char	= '1/1/2015'	#first date (starting date) of the dataset
time_step	= 'month' 		#time step of the dataset
ylab		= 'monthly mortality (cases for 100000)'			#graphic option for plot
title		= 'All-cause mortality in New York City'	#graphic option for plot
choix_seuil = 'file'	#purging method chosen
#choic_seuil = 'percentile'
file_epid = './purge_hap_lnevihealth.csv'
#s=5
sessionid		= 'highap_lownevihealth' #Session ID returned by the PHP function session_id()
time			= '114'	#the time this script was executed
###################################################


### Parameters specific to the model fitting ######
setting    	= 'retrospective'  		#type of the analysis ('prospective' or 'retrospective')
temps_epid 	= 1  		#minimal number of high observations in a row allowing to issue an alert (detection rule)
CL			= 95							#confidence interval level
model_choice 	= 'selection_algo'			#name of the model chosen (M11, M12, M13, M21, M22, M23, M31, M32, M33) or 'selection_algo'


###################################################
source('functions.R')
source('model.R')

##################### General Parameters #################
file_base		= './tables/highap_lownevires_2020.csv'	#name of the datafile
nb_app     	= 72 		#length of the training period 
date1_char	= '1/1/2015'	#first date (starting date) of the dataset
time_step	= 'month' 		#time step of the dataset
ylab		= 'monthly mortality (cases for 100000)'			#graphic option for plot
title		= 'All-cause mortality in New York City'	#graphic option for plot
choix_seuil = 'file'	#purging method chosen
#choic_seuil = 'percentile'
file_epid = './purge_hap_lnevires.csv'
#s=5
sessionid		= 'highap_lownevires' #Session ID returned by the PHP function session_id()
time			= '114'	#the time this script was executed
###################################################


### Parameters specific to the model fitting ######
setting    	= 'retrospective'  		#type of the analysis ('prospective' or 'retrospective')
temps_epid 	= 1  		#minimal number of high observations in a row allowing to issue an alert (detection rule)
CL			= 95							#confidence interval level
model_choice 	= 'selection_algo'			#name of the model chosen (M11, M12, M13, M21, M22, M23, M31, M32, M33) or 'selection_algo'


###################################################
source('functions.R')
source('model.R')

##################### General Parameters #################
file_base		= './tables/highap_lowneviecon_2020.csv'	#name of the datafile
nb_app     	= 72 		#length of the training period 
date1_char	= '1/1/2015'	#first date (starting date) of the dataset
time_step	= 'month' 		#time step of the dataset
ylab		= 'monthly mortality (cases for 100000)'			#graphic option for plot
title		= 'All-cause mortality in New York City'	#graphic option for plot
choix_seuil = 'file'	#purging method chosen
#choic_seuil = 'percentile'
file_epid = './purge_hap_lneviecon.csv'
#s=5
sessionid		= 'highap_lowneviecon' #Session ID returned by the PHP function session_id()
time			= '114'	#the time this script was executed
###################################################


### Parameters specific to the model fitting ######
setting    	= 'retrospective'  		#type of the analysis ('prospective' or 'retrospective')
temps_epid 	= 1  		#minimal number of high observations in a row allowing to issue an alert (detection rule)
CL			= 95							#confidence interval level
model_choice 	= 'selection_algo'			#name of the model chosen (M11, M12, M13, M21, M22, M23, M31, M32, M33) or 'selection_algo'


###################################################
source('functions.R')
source('model.R')

##################### General Parameters #################
file_base		= './tables/highap_lownevidem_2020.csv'	#name of the datafile
nb_app     	= 72 		#length of the training period 
date1_char	= '1/1/2015'	#first date (starting date) of the dataset
time_step	= 'month' 		#time step of the dataset
ylab		= 'monthly mortality (cases for 100000)'			#graphic option for plot
title		= 'All-cause mortality in New York City'	#graphic option for plot
choix_seuil = 'file'	#purging method chosen
#choic_seuil = 'percentile'
file_epid = './purge_hap_lnevidem.csv'
#s=5
sessionid		= 'highap_lownevidem' #Session ID returned by the PHP function session_id()
time			= '114'	#the time this script was executed
###################################################


### Parameters specific to the model fitting ######
setting    	= 'retrospective'  		#type of the analysis ('prospective' or 'retrospective')
temps_epid 	= 1  		#minimal number of high observations in a row allowing to issue an alert (detection rule)
CL			= 95							#confidence interval level
model_choice 	= 'selection_algo'			#name of the model chosen (M11, M12, M13, M21, M22, M23, M31, M32, M33) or 'selection_algo'


###################################################
source('functions.R')
source('model.R')



