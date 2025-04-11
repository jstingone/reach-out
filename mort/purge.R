###############################################################################
# Code from Pelat et al; Run by JAS in R 4.2.2                                #
# This script allows to purge the epidemic events in the training period      #
# It is called in the script run_purge.R after the setting of the parameters  #
###############################################################################

# reads the dataset
base<-read.csv(file=file_base,header=FALSE,col.names=c("y"))
y<-base$y  #time series as a vector : y
x<-(1:length(y))
date1<-as.Date(date1_char, "%d/%m/%Y")

############### DATES #######################
# attributes a day (or week or month) to each observations, according to the time step you specified
if(!is.na(date1))
{
  date<-seq(date1,by=time_step,length=length(y))
  dates_char1<-format(date,'%b %Y')
  dates_char2<-format(date,'%Y')
  if(time_step == 'day')
  {
    janv<-x[format(date,'%d-%m')=='01-01']
    juil<-x[format(date,'%d-%m')=='01-07']
  } else if(time_step=='week')
  {
    janv<-x[format(date,'%m')=='01' & (format(date,'%d')=='01' | format(date,'%d')=='02' | 	format(date,'%d')=='03' | format(date,'%d')=='04' | format(date,'%d')=='05' | format(date,'%d')=='06' | format(date,'%d')=='07' )]
    juil<-x[format(date,'%m')=='07' & (format(date,'%d')=='01' | format(date,'%d')=='02' | 	format(date,'%d')=='03' | format(date,'%d')=='04' | format(date,'%d')=='05' | format(date,'%d')=='06' | format(date,'%d')=='07' )]
  } else
  {
    date_1_janv<-date[format(date,'%m')=='01'][1]
    date_1_juil<-seq(date_1_janv,by='6 months',length=2)[2]
    janv<-x[format(date,'%d-%m')==format(date_1_janv,'%d-%m')]
    juil<-x[format(date,'%d-%m')==format(date_1_juil,'%d-%m')]
  }
}
###############################################


app = (length(y)-nb_app+1):length(y)  # index of the observations in the training period
y_app = y[app]  # observations in the training period
	
if(choix_seuil=='percentile') seuil<-quantile(y_app[!is.na(y_app)],probs = seq(0, 1, 0.05),na.rm=TRUE)[paste(100-s,'%',sep='')]
if(choix_seuil=='value') seuil<-s
if(choix_seuil=='file') {
	base_epid <- read.csv(file=file_epid, header=FALSE, col.names='epid_period')
	
	# Pre-treatment if the length of epid_period is not nb_app
	epid_period <- base_epid$epid_period
	if(length(base_epid$epid_period) < nb_app) epid_period <- c(base_epid$epid_period, rep(0,(nb_app-length(base_epid$epid_period))))
	if(length(base_epid$epid_period) > nb_app) epid_period <- base_epid$epid_period[1:nb_app]
	
  seuil = rep(NA, length(y))
  seuil[app][epid_period==1] = y[app][epid_period==1]
  
}

### Graphics ###
# will be output in the subdirectory "images" (make sure you created it, otherwise the program will crash)

### Time series ###
png(file=paste('images/plot_incidences_',sessionid,'_',time,'.png',sep=''),width=700,height=270) 
par(las=1,tcl=-0.2,mar=c(2,4,2,1),mgp=c(3,0.3,0),bty='l',xaxs='i',yaxs='i',cex.main=0.8,cex.axis=0.7,cex.lab=0.7)
plot(x[app],y[app],type='l',xaxt='n',xlab='',ylab=ylab)
if(!is.na(date1))
{
  axis(side=1,at=x[janv],labels=F,las=1,tick=T)
  axis(side=1,at=x[juil],labels=dates_char2[juil],las=1,tick=F,mgp=c(3,0.2,0))	
}
if(choix_seuil=='percentile' | choix_seuil=='value') lines(x[app],rep(seuil,length(app)),col=2) 
if(choix_seuil=='file') {
  lines(x[app], seuil[app],col=2)
  points(x[app], seuil[app], pch=16, cex=0.5, col=2)
}
title(paste(title,"\nTraining period"))
box()
dev.off()

### Histogram ###
png(file=paste('images/plot_hist_',sessionid,'_',time,'.png',sep=''),width=233,height=225) 
par(las=1,tcl=-0.2,mar=c(2,4,2,0.5),mgp=c(2.5,0.3,0),bty='l',xaxs='i',yaxs='i',cex.main=0.8,cex.axis=0.7,cex.lab=0.7)
hist(y[app],breaks=50,col="#BBBBBB",freq=FALSE,main='Histogram')
if(choix_seuil=='percentile' | choix_seuil=='value') lines( seuil , max(y_app[!is.na(y_app)]), type='h', col=2)
box()
dev.off()

### Boxplot ###
png(file=paste('images/plot_box_',sessionid,'_',time,'.png',sep=''),width=233,height=225)
par(las=1,tcl=-0.2,mar=c(2,4,2,0.5),mgp=c(2.5,0.3,0),bty='l',xaxs='i',yaxs='i',cex.main=0.8,cex.axis=0.7,cex.lab=0.7)
boxplot(y[app],main=paste('Boxplot'),pch=16,cex=0.4,ylab=ylab)
if(choix_seuil=='percentile' | choix_seuil=='value') lines((0:2),rep(seuil,3),col=2)
box()
dev.off()

### Cumulative density ###
png(file=paste('images/plot_cum_',sessionid,'_',time,'.png',sep=''),width=233,height=225)
par(las=1,tcl=-0.2,mar=c(2,4,2,0.5),mgp=c(2.5,0.3,0),bty='l',xaxs='i',yaxs='i',cex.main=0.8,cex.axis=0.7,cex.lab=0.7)
plot(ecdf(y[app]),main=paste('Cumulative density'),ylab='Density',
xlab='incidence',do.points=FALSE,verticals=TRUE)
if(choix_seuil=='percentile' | choix_seuil=='value') lines(rep(seuil,2),c(0,1),col=2)
box()
dev.off()