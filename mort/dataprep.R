###########################################################
# Program to Create Purging Files                         #
# JAS 2/26/2023                                           #
# Run after initial purge at 5%, Before Full Data         #
# Purpose: Extract Epidemic Periods from Purge and        #
#           Create Files for Full Model Run               #
# NOTE: Files have to be updated manually before code     #
#       Convert formula to value in last column           #
# Run in R Version 4.2.2                                  #
###########################################################


###REQUIRES USER INPUT####
# insert-file-path indicates location where output files from initial purge are stored. must also include 
# specific file name in the path.

# insert-output-file indicates path and name of generated files from write.csv 

#Import output files from initial 5% purge
base_result_english_highap_highnevi_111 <- read.delim("insert-file-path")
base_result_english_highap_mednevi_111 <- read.delim("insert-file-path")
base_result_english_highap_lownevi_111 <- read.delim("insert-file-path")
base_result_english_medap_highnevi_111 <- read.delim("insert-file-path")
base_result_english_medap_mednevi_111 <- read.delim("insert-file-path")
base_result_english_medap_lownevi_111 <- read.delim("insert-file-path")
base_result_english_lowap_highnevi_111 <- read.delim("insert-file-path")
base_result_english_lowap_mednevi_111 <- read.delim("insert-file-path")
base_result_english_lowap_lownevi_111 <- read.delim("insert-file-path")

#Create dataframe of 1s to append in order to purge all of 2020
dataset2020<-data.frame(rep(1,12))
colnames(dataset2020)<-"epid"

#Create dataframes of just epidemic indicator variables
int.data<-data.frame(base_result_english_highap_highnevi_111[,6])
colnames(int.data)<-"epid"

int.data2<-data.frame(base_result_english_highap_mednevi_111[,6])
colnames(int.data2)<-"epid"

int.data3<-data.frame(base_result_english_highap_lownevi_111[,6])
colnames(int.data3)<-"epid"

int.data4<-data.frame(base_result_english_medap_highnevi_111[,6])
colnames(int.data4)<-"epid"

int.data5<-data.frame(base_result_english_medap_mednevi_111[,6])
colnames(int.data5)<-"epid"

int.data6<-data.frame(base_result_english_medap_lownevi_111[,6])
colnames(int.data6)<-"epid"

int.data7<-data.frame(base_result_english_lowap_highnevi_111[,6])
colnames(int.data7)<-"epid"

int.data8<-data.frame(base_result_english_lowap_mednevi_111[,6])
colnames(int.data8)<-"epid"

int.data9<-data.frame(base_result_english_lowap_lownevi_111[,6])
colnames(int.data9)<-"epid"

#Append 2020 purge to epidemic id from 2015-2019
purge_highap_highnevi<-rbind(int.data, dataset2020)
purge_highap_mednevi<-rbind(int.data2, dataset2020)
purge_highap_lownevi<-rbind(int.data3, dataset2020)
purge_medap_highnevi<-rbind(int.data4, dataset2020)
purge_medap_mednevi<-rbind(int.data5, dataset2020)
purge_medap_lownevi<-rbind(int.data6, dataset2020)
purge_lowap_highnevi<-rbind(int.data7, dataset2020)
purge_lowap_mednevi<-rbind(int.data8, dataset2020)
purge_lowap_lownevi<-rbind(int.data9, dataset2020)


#Export file to be used in modelling
write.csv(purge_highap_highnevi, file="insert-output-file", row.names = FALSE)
write.csv(purge_highap_mednevi, file="insert-output-file", row.names = FALSE)
write.csv(purge_highap_lownevi, file="insert-output-file", row.names = FALSE)
write.csv(purge_medap_highnevi, file="insert-output-file", row.names = FALSE)
write.csv(purge_medap_mednevi, file="insert-output-file", row.names = FALSE)
write.csv(purge_medap_lownevi, file="insert-output-file", row.names = FALSE)
write.csv(purge_lowap_highnevi, file="insert-output-file", row.names = FALSE)
write.csv(purge_lowap_mednevi, file="insert-output-file", row.names = FALSE)
write.csv(purge_lowap_lownevi, file="insert-output-file", row.names = FALSE)
