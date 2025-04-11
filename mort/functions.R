###############################################
# Contains functions used by the model fitting #
# Code from Pelat et al; Run in R 4.2.2 by JAS #
###############################################


# Polygone for highlighting epidemics 
poly_epid <- function(x, y, epid_2_mois, epid_2_mois_avec_dernier_inclus, dmin, dmax, col, density, angle=45){

	bottom=-max(y[!is.na(y)])

	if (dmin==dmax) {
		if (epid_2_mois[x==dmin]==1) lines(dmin,2*max(y[!is.na(y)]),type='h',col=col)
	}else{

	xxx<-x[(x>=dmin) & (x<=dmax)]
	loi1<-c(epid_2_mois[(x>=dmin) & (x<=dmax)],0)

	yy<-y[(x>=dmin) & (x<=dmax)]
	yy[is.na(yy)]<-0 
	yy[epid_2_mois_avec_dernier_inclus[(x>=dmin) & (x<=dmax)]==0]<-bottom
	yy<-c(yy,bottom)

	u_poly<-c(xxx[1],xxx[1]);v_poly<-c(bottom,yy[1])

	for (j in 2:length(xxx) ){
	# if we step from a non-epidemic observation to an epidemic one
  	if (loi1[j-1]==0 & loi1[j]>0){
  		u_poly<-c(u_poly,xxx[j],xxx[j])
  		v_poly<-c(v_poly,bottom,yy[j])
  	} else {
      # if we step from an epidemic observation to a non-epidemic one
  		if (loi1[j-1]>0 & loi1[j]==0){
  			u_poly<-c(u_poly,xxx[j],xxx[j])
  			v_poly<-c(v_poly,yy[j],bottom)
  		}else {  # in the other cases
  			u_poly<-c(u_poly,xxx[j])
  			v_poly<-c(v_poly,yy[j])
  		}
    }
	}# end for j

if (dmax<length(x) & epid_2_mois[dmax]==1){
	u_poly<-c(u_poly,dmax+1,dmax+1)
	v_poly<-c(v_poly,y[dmax+1],bottom)
} else {
	u_poly<-c(u_poly,dmax)
	v_poly<-c(v_poly,bottom)
}

polygon(x=u_poly,y=v_poly,density=density,angle=angle,col=col,border=col)

} # end if dmin==dmax

} #end function poly_epid



# Compares model AA to model AB in which it is nested and model BA in which it is also nested
# using ANOVA comparisons (significance level 0.5).
# If both AB and BA are "better" than AA, AIC is used to select between them.
# The function returns the final model
test<-function(modelAA,modelAB,modelBA=NULL){

	alpha<-0.05

	# If there are at least 2 parameters
	anovaAB<-anova(modelAA,modelAB);anovaAB

	if (is.null(modelBA)){
		if (anovaAB[2,'Pr(>F)']>alpha) {model<-modelAA; num_model<-1; cas=11}
		else {model<-modelAB; num_model<-2; cas=12}
	}else {# If there are 3 parameters
		anovaBA<-anova(modelAA,modelBA);anovaBA

		#### if neither of the 2 models is significative ####
		if (anovaAB[2,'Pr(>F)']>alpha & anovaBA[2,'Pr(>F)']>alpha) {model<-modelAA; num_model<-1; cas=1}

		#### if model AB is significative but not BA ####
		if (anovaAB[2,'Pr(>F)']<=alpha & anovaBA[2,'Pr(>F)']>alpha) {model<-modelAB; num_model<-2; cas=2}

		#### if model BA is significative but not AB ####
		if (anovaAB[2,'Pr(>F)']>alpha & anovaBA[2,'Pr(>F)']<=alpha) {model<-modelBA; num_model<-3; cas=3}

		#### if both modelq AB and BA are significative ####
		if (anovaAB[2,'Pr(>F)']<=alpha & anovaBA[2,'Pr(>F)']<=alpha)
		{
		if (AIC(modelBA)<AIC(modelAB)) {model<-modelBA; num_model<-3; cas=4} else {model<-modelAB; num_model<-2; cas=5}
		}
	} #end if (!is.null(modelBA))

	l<-list(model=model,num_model=num_model,cas=cas)
	l
} #end function test






# Draws an arrow between point (x0,y0) and point (x1,y1)
fleche<-function (x0,y0,x1,y1,...){
		aa=0.40
		if ((x1-x0)>0) a=-aa else a=aa
		arrows(x0,y0,x1+a,y1+aa,length=0.1,...)
} 




# Draws another type of arrow between point (x0,y0) and point (x1,y1)
fleche2<-function (x0,y0,x1,y1,...){
		a=0.2
 		arrows(x0,y0-a,x1,y1+a,length=0.1,...)
} 





# Selection Algorithm for the retrospective setting 
# compares the 9 models input as parameters 
selection_retrospective <- function (model11, model12, model13, model21, model22, model23, model31, model32, model33)
{
	modeles_traverses<-'M11'

	res<-test(model11,model12,model21)

	if (res$num_model==1) model_final<-model11 # final model 11


	if (res$num_model==2) {   # temporary model 12
		modeles_traverses<-c(modeles_traverses,'M12')
		res<-test(model12,model13,model22)

		if (res$num_model==1) model_final<-model12  # final model 12

  		if (res$num_model==2) {  # temporary model 13
			modeles_traverses<-c(modeles_traverses,'M13')
			res<-test(model13,model23)

			if (res$num_model==1) model_final<-model13   # final model 13

    			if (res$num_model==2) {   # temporary model 23
				modeles_traverses<-c(modeles_traverses,'M23')
				res<-test(model23,model33)

				if (res$num_model==1) model_final<-model23  # final model 23
          			if (res$num_model==2) {model_final<-model33; modeles_traverses<-c(modeles_traverses,'M33')} # final model 33
			}
  		}


		if (res$num_model==3) {  # temporary model 22
			modeles_traverses<-c(modeles_traverses,'M22')
			res<-test(model22,model23,model32)

	  		if (res$num_model==1) model_final<-model22  # final model 22

     			if (res$num_model==2) {  # temporary model 23
				modeles_traverses<-c(modeles_traverses,'M23')
        			res<-test(model23,model33)

				if (res$num_model==1) model_final<-model23  # final model 23
        			if (res$num_model==2) {model_final<-model33; modeles_traverses<-c(modeles_traverses,'M33')} # final model 33
     			}

      		if (res$num_model==3) {  # temporary model 32
				modeles_traverses<-c(modeles_traverses,'M32')
       			res<-test(model32,model33)

				if (res$num_model==1) model_final<-model32  # final model 32
        			if (res$num_model==2)	{model_final<-model33; modeles_traverses<-c(modeles_traverses,'M33')} # final model 33
     			}
  		}
	}

	################################################
	if (res$num_model==3) {   # temporary model 21
		modeles_traverses<-c(modeles_traverses,'M21')
		res<-test(model21,model31,model22)

  		if (res$num_model==1) model_final<-model21  # final model 21

  		if (res$num_model==2) {  # temporary model 31
			modeles_traverses<-c(modeles_traverses,'M31')
			res<-test(model31,model32)

			if (res$num_model==1) model_final<-model31   # final model 31

    			if (res$num_model==2) {     # temporary model 32
				modeles_traverses<-c(modeles_traverses,'M32')
				res<-test(model32,model33)

				if (res$num_model==1) model_final<-model32  # final model 32
        			if (res$num_model==2) {model_final<-model33; modeles_traverses<-c(modeles_traverses,'M33')} # final model 33
			}
		}


		if (res$num_model==3) {  # temporary model 22
			modeles_traverses<-c(modeles_traverses,'M22')
			res<-test(model22,model32,model23)

	   		if (res$num_model==1) model_final<-model22  # final model 22

    			if (res$num_model==2) {  # temporary model 32
        			modeles_traverses<-c(modeles_traverses,'M32')
				res<-test(model32,model33)

				if (res$num_model==1) model_final<-model32  # final model 32
        			if (res$num_model==2) {model_final<-model33; modeles_traverses<-c(modeles_traverses,'M33')} # final model 33
     			}

    			if (res$num_model==3) {  # temporary model 23
				modeles_traverses<-c(modeles_traverses,'M23')
        			res<-test(model23,model33)

				if (res$num_model==1) model_final<-model23  # final model 23
        			if (res$num_model==2) {model_final<-model33; modeles_traverses<-c(modeles_traverses,'M33')} # final model 33
     			}
  		}
	}
  ################################################


  ############ Decision graphic ###########
  a<-rep(NA,12)
  a[1]<-anova(model11,model12)[2,'Pr(>F)']
  a[2]<-anova(model11,model21)[2,'Pr(>F)']
  a[3]<-anova(model12,model13)[2,'Pr(>F)']
  a[4]<-anova(model12,model22)[2,'Pr(>F)']
  a[5]<-anova(model21,model22)[2,'Pr(>F)']
  a[6]<-anova(model21,model31)[2,'Pr(>F)']
  a[7]<-anova(model13,model23)[2,'Pr(>F)']
  a[8]<-anova(model22,model23)[2,'Pr(>F)']
  a[9]<-anova(model22,model32)[2,'Pr(>F)']
  a[10]<-anova(model31,model32)[2,'Pr(>F)']
  a[11]<-anova(model23,model33)[2,'Pr(>F)']
  a[12]<-anova(model32,model33)[2,'Pr(>F)']

  anov<-formatC(a,digits=3,format='f')
  anov[round(a,3)==0]<-'p<0.001'
  label_anov<-anov
  label_anov[round(a,3)!=0]<-paste('p=',anov[round(a,3)!=0],sep='')

  # position of the p-values on the graphic, along the arrows
  posx<-c(-0.5,0.5,-1.5,-0.5,0.5,1.5,-1.5,-0.5,0.5,1.5,-0.5,0.5)
  posy<-c(1.5,1.5,0.5,0.5,0.5,0.5,-0.5,-0.5,-0.5,-0.5,-1.5,-1.5)

  model_aic<-AIC(model11,model12,model21,model13,model22,model31,model23,model32,model33)
  label_model<-paste('M',c(11,12,21,13,22,31,23,32,33),sep='')
  label_model2<-paste('M',c(11,12,21,13,22,31,23,32,33),' (AIC=',formatC(model_aic$AIC,digits=2,format='f'),')',sep='')

  # colouring the models in the selection pathway
  coul<-rep(1,length(label_model))
  for (j in 1:length(label_model)){
	 if (	any(label_model[j]==modeles_traverses))	coul[j]='darkorange2' # temporary models
	 if (	label_model[j]==modeles_traverses[length(modeles_traverses)] )	coul[j]=2  # final models
  }

  font<-rep(1,length(label_model))
  for (j in 1:length(label_model)){
  	if (	any(label_model[j]==modeles_traverses))	font[j]=3
  	if (	label_model[j]==modeles_traverses[length(modeles_traverses)] )	font[j]=4
  }

  # position of the model names
  u=c(0,-1,1,-2,0,2,-1,1,0)
  v=c(2,1,1,0,0,0,-1,-1,-2)

  #### plot ####
  nom_graphe_anova=paste('images/algo_decision_anova_',sessionid,'_',time,'.png',sep='')

  png(file=nom_graphe_anova,width=370,height=250)
  par(mar=c(0,0,0,0),cex=0.7)

  plot(u,v,type='n',ylim=c(-2.5,2.5),xlim=c(-2.7,2.7),axes=F,ylab='',xlab='')
  fleche(0,2,1,1);fleche(0,2,-1,1)
  fleche(-1,1,-2,0);fleche(-1,1,0,0)
  fleche(1,1,2,0);fleche(1,1,0,0)
  fleche(0,0,-1,-1);fleche(0,0,1,-1)
  fleche(-2,0,-1,-1);fleche(2,0,1,-1)
  fleche(-1,-1,0,-2);fleche(1,-1,0,-2)
  text(posx,posy,labels=label_anov,pos=2,cex=0.8)
  text(u,v,labels=label_model2,col=coul,font=font,adj=c(0.5,0))

  dev.off()
  
 cat(modeles_traverses[length(modeles_traverses)],file=paste('fichiers/selected_model_',sessionid,'_',time,'.txt',sep=''))
 
  return(model_final)
  
} # end function selection_retrospectif









# Selection Algorithm for the prospective setting  
# compares the 3 models input as parameters 
selection_prospective <- function (model11, model12, model13)
{
  alpha<-0.05

  a<-c()
  a[1]<-anova(model11,model12)[2,'Pr(>F)']
  a[2]<-anova(model12,model13)[2,'Pr(>F)']

  modeles_traverses<-'M11'
  if(a[1] > alpha)
  {
    model_final<-model11
  } else {
    modeles_traverses<-c(modeles_traverses,'M12')
    if(a[2] > alpha)
    {
      model_final<-model12
     } else
     {
      modeles_traverses<-c(modeles_traverses,'M13')
      model_final<-model13
      }
  }

  # position of the 3 models names
  u=c(0,0,0)
  v=c(1,0,-1)
  model_aic<-AIC(model11,model12,model13)
  label_model<-paste('M',c(11,12,13),sep='')
  label_model2<-paste(label_model,' (AIC=',formatC(model_aic$AIC,digits=2,format='f'),')',sep='')
  
  # position of the 2 p-values
  posx=c(0,0)+1
  posy=c(0,-1) +0.5
  anov<-formatC(a,digits=3,format='f')
  anov[round(a,3)==0]<-'p<0.001'
  label_anov<-anov
  label_anov[round(a,3)!=0]<-paste('p=',anov[round(a,3)!=0],sep='')

   # colouring the models in the selection pathway
   coul<-rep(1,length(label_model))
   for (j in 1:length(label_model)){
	  if (	any(label_model[j]==modeles_traverses))	coul[j]='darkorange2'     # temporary models
	   if (	label_model[j]==modeles_traverses[length(modeles_traverses)] )	coul[j]=2     # final model
    }

  font<-rep(1,length(label_model))
  for (j in 1:length(label_model)){
  	if (	any(label_model[j]==modeles_traverses))	font[j]=3
  	if (	label_model[j]==modeles_traverses[length(modeles_traverses)] )	font[j]=4
  }


  #### plot ####
  nom_graphe_anova=paste('images/algo_decision_anova_',sessionid,'_',time,'.png',sep='')
  png(file=nom_graphe_anova,width=300,height=350)
  par(mar=c(2,2,2,2),cex=0.7)
  plot(u,v,ylim=c(-1,1.5),xlim=c(-1,1),type='n',axes=F,ylab='',xlab='')
  fleche2(0,1,0,0)
  fleche2(0,0,0,-1)
  text(posx,posy,labels=label_anov,pos=2, cex=0.9)
  text(u,v,labels=label_model2,col=coul,font=font,adj=c(0.5,0))
  dev.off()

  cat(modeles_traverses[length(modeles_traverses)],file=paste('fichiers/selected_model_',sessionid,'_',time,'.txt',sep=''))
  
  return(model_final)
} # end function selection_prospectif

