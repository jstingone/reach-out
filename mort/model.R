###############################################################################
# Code from Pelat et al; Run by JAS in R 4.2.2
#
# This script runs the model fitting 
# in the retrospective setting it calculates the cumulative excess     
# in the prospective setting it calculates the forecast values for the next year     
# It is called in the script run_model.R after the setting of the parameters 
###############################################################################

# reads the dataset
base<-read.csv(file=file_base,header=FALSE,col.names=c('y'))	
y<-base$y  # y is the vector of observations


#nb_temps: number of observations in 1 year
if (time_step=='day')     nb_temps<-365.25
if (time_step=='week')    nb_temps<-52.179
if (time_step=='month')   nb_temps<-12

if(setting=='prospective')  
{
  nb_predict = round(nb_temps)
  y<-c(y,rep(NA,nb_predict)) # we append nb_predict NA (ie 1 year) at the end of y
} else 
{
  nb_predict = 0
  #nb_app<-length(y)
} 
 
x<-(1:length(y))


date1<-as.Date(date1_char, '%d/%m/%Y')

############### DATES #######################
# attributes a day (or week or month) to each observations, according to the time step you specified
if(!is.na(date1))
{
  dates<-seq(date1,by=time_step,length=length(y))
  dates_char2<-format(dates,'%Y')	
  if (time_step=='day')
  {
  		janv<-x[format(dates,'%d-%m')=='01-01']
  		juil<-x[format(dates,'%d-%m')=='01-07']
  		dates_char1<-format(dates,'%d-%b-%Y')
  }
  if (time_step=='week')
  {
    janv<-x[format(dates,'%m')=='01' & (format(dates,'%d')=='01' | format(dates,'%d')=='02' | 	format(dates,'%d')=='03' | format(dates,'%d')=='04' | format(dates,'%d')=='05' | format(dates,'%d')=='06' | format(dates,'%d')=='07' )]
  	juil<-x[format(dates,'%m')=='07' & (format(dates,'%d')=='01' | format(dates,'%d')=='02' | 	format(dates,'%d')=='03' | format(dates,'%d')=='04' | format(dates,'%d')=='05' | format(dates,'%d')=='06' | format(dates,'%d')=='07' )]
  	dates_char1<-format(dates,'week-%W-%Y')
  }
  if (time_step=='month')
  {
    # We take day 1 of the first month of the series and generate a sequence of months from then, of the same length than y.
    date1_month_1_char<-paste('01/',format(date1,'%m/%Y'),sep='')
    date1_month_1<-as.Date(date1_month_1_char, '%d/%m/%Y')
    dates<-seq(date1_month_1,by=time_step,length=length(y))
  
    date_1_janv<-dates[format(dates,'%m')=='01'][1]
  	date_1_juil<-seq(date_1_janv,by='6 months',length=2)[2]
  	janv<-x[format(dates,'%d-%m')==format(date_1_janv,'%d-%m')]
  	juil<-x[format(dates,'%d-%m')==format(date_1_juil,'%d-%m')]
  	dates_char1<-format(dates,'%b-%Y')
  }
}

### Training Period 
x_app<-(length(x)-nb_app-nb_predict+1):(length(x)-nb_predict) # index of the observations in the training period
y_app<-y[x_app] # observations in the training period


### Purge threshold : vector vect_seuil
vect_seuil<-y+1  # initialisation of the puring threshold for each observation
if(choix_seuil=='percentile')
{
  seuil<-quantile(y_app[!is.na(y_app)],probs = seq(0, 1, 0.05),na.rm=TRUE)[paste(100-s,'%',sep='')]  ## selon la fa?on de purger qu'on a choisie
  vect_seuil<-rep(seuil, length(y))
}
if(choix_seuil=='value')
{
  seuil<-s
  vect_seuil<-rep(seuil, length(y))
}
if(choix_seuil=='file')
{	
	base_epid<-read.csv(file=file_epid, header=FALSE, col.names='epid_period')
	# Pre-treatment if the length of epid_period is not nb_app
	epid_period <- base_epid$epid_period
	if(length(base_epid$epid_period) < nb_app) epid_period <- c(base_epid$epid_period, rep(0,(nb_app-length(base_epid$epid_period))))
	if(length(base_epid$epid_period) > nb_app) epid_period <- base_epid$epid_period[1:nb_app]
		
  vect_seuil[epid_period==1]<--1  
}


### Covariates of the model
x2<-x**2
x3<-x**3
c1<-cos(2*pi*x/nb_temps) 
s1<-sin(2*pi*x/nb_temps) 
c2<-cos(4*pi*x/nb_temps) 
s2<-sin(4*pi*x/nb_temps)  
c3<-cos(8*pi*x/nb_temps) 
s3<-sin(8*pi*x/nb_temps)


### Models estimated on the Training Period 
subset=((y <vect_seuil) & x %in% x_app)  # subset of the Training period with no epidemic events
model11<-lm(y~x+c1+s1,subset=subset)
model12<-lm(y~x+c1+s1+c2+s2,subset=subset) 	
model13<-lm(y~x+c1+s1+c2+s2+c3+s3,subset=subset)
model21<-lm(y~x+x2+c1+s1,subset=subset) 	
model22<-lm(y~x+x2+c1+s1+c2+s2,subset=subset) 	
model23<-lm(y~x+x2+c1+s1+c2+s2+c3+s3,subset=subset) 	
model31<-lm(y~x+x2+x3+c1+s1,subset=subset) 	
model32<-lm(y~x+x2+x3+c1+s1+c2+s2,subset=subset) 	
model33<-lm(y~x+x2+x3+c1+s1+c2+s2+c3+s3,subset=subset) 	
  
 
### Model selection 	
if (model_choice=='M11') model<-model11
if (model_choice=='M12') model<-model12
if (model_choice=='M13') model<-model13

if (model_choice=='M21') model<-model21
if (model_choice=='M22') model<-model22
if (model_choice=='M23') model<-model23

if (model_choice=='M31') model<-model31
if (model_choice=='M32') model<-model32
if (model_choice=='M33') model<-model33

if (model_choice=='selection_algo')
{
  if(setting=='retrospective')
    model<-selection_retrospective(model11, model12, model13, model21, model22, model23, model31, model32, model33)
  if(setting=='prospective')
    model<-selection_prospective(model11, model12, model13)
}  

  
### Predictions 

# In retrospective setting : only for the  Training Period (TP)
# In prospective setting : for TP + following year 
x_new<-c( rep(NA , length(x)-nb_predict-nb_app) , (length(x)-nb_predict-nb_app+1):(length(x)) )
# We only keep the last nb_app observations in x_new (+ the nb_predict NA if we are in prospective setting)
x2_new<-x_new**2
x3_new<-x_new**3
c1_new<-cos(2*pi*x_new/nb_temps) 
s1_new<-sin(2*pi*x_new/nb_temps) 
c2_new<-cos(4*pi*x_new/nb_temps) 
s2_new<-sin(4*pi*x_new/nb_temps)  
c3_new<-cos(8*pi*x_new/nb_temps) 
s3_new<-sin(8*pi*x_new/nb_temps)
pred.plim2<-predict(model,newdata=data.frame(cbind(x=x_new,x2=x2_new,x3=x3_new,c1=c1_new,s1=s1_new,c2=c2_new,s2=s2_new,c3=c3_new,s3=s3_new)),interval='prediction') 

# Baseline level 
fit<-pred.plim2[,'fit']

# Upper forecast limit
p<-(100-(100-CL)/2)/100
CL_upr_bound<-qnorm(p)	
upr<-fit+CL_upr_bound*sqrt(var(model$residuals))
write.table(round(CL_upr_bound,2),file=paste('fichiers/CL_upr_bound_',sessionid,'_',time,'.txt',sep=''),quote=FALSE,row.names=FALSE,col.names=FALSE)



### Table 1 (for both retrospective and prospective setting) 
# baseline et Upper Forecast Limit pour chaque pas de temps 
nb_digits=3

# Replacement of negative values by 0
fit2 <- fit ; fit2[fit < 0] <- 0
upr2 <- upr ; upr2[upr < 0] <- 0

if (exists('dates_char1')) 
{
  base_result<-data.frame(
  index=formatC(x,width=5,flag=' '), 
  date=dates_char1, 
  observations=formatC(y,digits=nb_digits,width=12,flag=' ',format='f'), predicted_baseline=formatC(fit2[1:length(x)],digits=nb_digits,width=18,flag=' ',format='f'), 
  threshold=formatC(upr2[1:length(x)],digits=nb_digits,width=9,flag=' ',format='f')
  )
  if(nchar(dates_char1[1])==8) names(base_result)[2]<-'    date'
  if(nchar(dates_char1[1])==11) names(base_result)[2]<-'       date'
  if(nchar(dates_char1[1])==12) names(base_result)[2]<-'        date'
}else {
  base_result<-data.frame(
  index=formatC(x,width=5,flag=' '), 
  observations=formatC(y,digits=nb_digits,width=12,flag=' ',format='f'), predicted_baseline=formatC(fit[1:length(x)],digits=nb_digits,width=18,flag=' ',format='f'), 
  threshold=formatC(upr[1:length(x)],digits=nb_digits,width=9,flag=' ',format='f')
  )
}

base_result2<-base_result[(length(x)-nb_predict-nb_app+1):(length(x)),]
index = 1:dim(base_result2)[1]
base_result2$observations <- as.character(base_result2$observations)
base_result2$observations <- as.numeric(base_result2$observations)
base_result2$observations[is.na(base_result2$observations)]  <- "paste observation"
base_result2$epid<-paste("=si(C",index+1,"-E",index+1,">0,1,0)",sep="")
write.table(base_result2,file=paste('fichiers/base_result_french_',sessionid,'_',time,'.xls',sep=''),sep='\t',quote=FALSE,row.names=FALSE)
base_result2$epid<-paste("=if(C",index+1,"-E",index+1,">0,1,0)",sep="")
write.table(base_result2,file=paste('fichiers/base_result_english_',sessionid,'_',time,'.xls',sep=''),sep='\t',quote=FALSE,row.names=FALSE)



### Table 2 (retrospective setting only) ###
# Cumulate excess and dates of start/end
if( setting=='retrospective'){
 
  epid<-rep(0,length(y))  # marks with 1 every observations higher than the Upper Forecast Limit (UFL)
  epid[y>upr[1:length(x)]]<-1  
  
  debut<-rep(0,length(y)) # Marks the start(1) and end(-1) of the epidemics 
  memoire<--1  # vkeeps in memory if we are inside or outside an epidemic period  
  for (j in 1:(length(y)-temps_epid))
  {
    if (sort(unique(epid[j:(j+temps_epid)]==c(0,rep(1,temps_epid))))[1]==TRUE & (memoire==-1)) 
	   {debut[j+1]<-1;memoire<-1}
    if (sort(unique(epid[j:(j+temps_epid)]==c(1,rep(0,temps_epid))))[1]==TRUE & (memoire==1)) 
	   {debut[j+1]<--1;memoire<--1} #debut=-1 at the first observation below the threshold
  }

  epid_2_mois<-rep(0,length(y))  
  # Mark with 1 every observation in an epidemic longer than tps_epid
 
  epid_2_mois_avec_dernier_inclus<-rep(0,length(y))
  # Same thing but the first obs after the epidemic is also marked with 1

  memoire<--1
  for (j in 1:(length(y))) 
  {
	 if (debut[j]==1) {memoire<-1; epid_2_mois[j]<-1; epid_2_mois_avec_dernier_inclus[j]<-1}
	 if (debut[j]==-1) {memoire<--1; epid_2_mois_avec_dernier_inclus[j]<-1}
	 if ((debut[j]==0) & (memoire==1)) {epid_2_mois[j]<-1;  epid_2_mois_avec_dernier_inclus[j]<-1}
  }

  # Calculation of cumulated excess
  dans_epid<-FALSE
  vect_exces_mort_cum<-NULL
  vect_expected_mort_cum<-NULL
  vect_debut_epid<-NULL
  vect_fin_epid<-NULL
  date_debut_epid<-NULL
  date_fin_epid<-NULL

  for (k in 1:length(y))
  {
	   if (debut[k]==1)
	   {
		    dans_epid<-TRUE;
		    exces_mort_cum<-y[k]-fit[k]
		    expected_mort_cum<-fit[k]
		    vect_debut_epid<-c(vect_debut_epid,k)
		    if (exists('dates_char1')) date_debut_epid<-c(date_debut_epid,dates_char1[k])
	   }
	
    	if ((debut[k]==0) & (dans_epid))
	   {
	     	exces_mort_cum<-exces_mort_cum+y[k]-fit[k]
	     	expected_mort_cum<-expected_mort_cum+fit[k]
	   }
    
      if ((debut[k]==-1) & (dans_epid) )
	   {
		    dans_epid<-FALSE
		    vect_exces_mort_cum<-c(vect_exces_mort_cum,exces_mort_cum)
		    vect_expected_mort_cum<-c(vect_expected_mort_cum,expected_mort_cum)
	     	vect_fin_epid<-c(vect_fin_epid,k)
		    if (exists('dates_char1')) date_fin_epid<-c(date_fin_epid,dates_char1[k])
	   }
  }
  
  # if the dataset finishes inside an epidemic, we do not know the end of the epidemic
  # thus we do not know the cumulated excess
  # We replace it by NA
  if (length(vect_debut_epid) > length(vect_fin_epid))
	 {	
  	vect_exces_mort_cum<-c(vect_exces_mort_cum,rep(NA,(length(vect_debut_epid)-length(vect_fin_epid))))
	 vect_expected_mort_cum<-c(vect_expected_mort_cum,rep(NA,(length(vect_debut_epid)-length(vect_fin_epid))))
  	vect_fin_epid<-c(vect_fin_epid,rep(NA,(length(vect_debut_epid)-length(vect_fin_epid))))
	 if (exists('dates_char1')) date_fin_epid<-c(date_fin_epid,rep(NA,(length(date_debut_epid)-length(date_fin_epid))))
	}


  if(!is.null(vect_exces_mort_cum)){
    nb_digits_cum=2
    percent=round(vect_exces_mort_cum/vect_expected_mort_cum*100)
    if(exists('dates_char1')) 
    {
      base_exces<- data.frame(
      start_index=formatC(vect_debut_epid,width=11,flag=' '),
      end_index=formatC(vect_fin_epid,width=9,flag=' '), 
      start_date=formatC(date_debut_epid,width=max(nchar('start_date'),nchar(date_debut_epid[1])),flag=''), 
      end_date=formatC(date_fin_epid,width=max(nchar('end_date'),nchar(date_fin_epid[1])),flag=''), 
      cum_excess=formatC(vect_exces_mort_cum,digits=nb_digits_cum,width=10,flag=' ',format='f'), 
      cum_expected=formatC(vect_expected_mort_cum,digits=nb_digits_cum,width=12,flag=' ',format='f'),
      excess_percentage=paste(formatC(percent,width=16,flag=' '),'%',sep=''))

      if(nchar(date_debut_epid[1])==11) {names(base_exces)[3]<-' start_date';names(base_exces)[4]<-'   end_date' }
      if(nchar(date_debut_epid[1])==12) {names(base_exces)[3]<-'  start_date';names(base_exces)[4]<-'    end_date' }
    }else {
      base_exces<- data.frame(
      start_index=formatC(vect_debut_epid,width=11,flag=' '),
      end_index=formatC(vect_fin_epid,width=9,flag=' '), 
      cum_excess=formatC(vect_exces_mort_cum,digits=nb_digits_cum,width=10,flag=' ',format='f'), 
      cum_expected=formatC(vect_expected_mort_cum,digits=nb_digits_cum,width=12,flag=' ',format='f'),
      excess_percentage=paste(formatC(percent,width=16,flag=' '),'%',sep=''))
    }
    write.table(base_exces,file=paste('fichiers/base_exces_',sessionid,'_',time,'.xls',sep=''),quote=FALSE,row.names=FALSE,sep='\t')
  }else
    cat('The Periodic Regression Method does not detect any epidemic period longer than ',temps_epid,' ',time_step,'s ' ,'in your data.',sep='',file=paste('fichiers/base_exces_',sessionid,'_',time,'.txt',sep=''))

} # end of if( setting=='retrospective')



##############################################
######### GRAPHIC ##########################
##############################################
slide<-paste('./images/slide_',sessionid,'_',time,'.png',sep='')
png(file=slide,width=755, height=300)
par(las=1,lend=2,tcl=-0.2,mar=c(2,3,3,1),mgp=c(2.3,0.3,0),bty='l',xaxs='i',yaxs='r',cex.main=0.8,cex.axis=0.7,cex.lab=0.7)
# mar=c(2,3,3,0.2)
plot(x, y, type = 'l', xaxt='n', xlab = '', ylab = ylab)
title(title)  
if(setting=='retrospective') 
{
  poly_epid(x, y, epid_2_mois, epid_2_mois_avec_dernier_inclus, dmin=x_app[1],dmax=x_app[length(x_app)],col=2,density=-30)
  lines(x,y)
  lines(x,fit[1:length(x)],col=3,lty=1)
  lines(x,upr[1:length(x)],col=3,lty=2) 
  if(!is.na(date1))
  {
    axis(side=1,at=x[janv],labels=F,las=1,tick=T)
    axis(side=1,at=x[juil],labels=dates_char2[juil],las=1,tick=F,mgp=c(3,0.2,0))	
  }
}
if(setting=='prospective') 
{
  lines(x_new,fit,col=3,lty=1)
  lines(x_new,upr,col=3,lty=2) 
  if(!is.na(date1))
  {
    axis(side=1,at=x[janv],labels=F,las=1,tick=T)
    axis(side=1,at=x[juil],labels=dates_char2[juil],las=1,tick=F,mgp=c(3,0.2,0))	
  }
}
box()
dev.off()
###################################################

