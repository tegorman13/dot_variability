#' ---
#' title: Process 2022 data
#' author: Thomas Gorman
#' date: 01/18/24
#' format: html
#' ---

# packages <- c('plyr','dplyr','tidyr','ggplot2','magrittr',
#              'psych','data.table','grid','gridExtra','R.matlab','units','readr')
# have = packages %in% rownames(installed.packages())
# if ( any(!have) ) { install.packages(packages[!have]) }
# (lapply(packages, require, character.only = TRUE))


# Data variable order, from left to right:
#   
# 1. Phase type (1 = Training, 2 = Transfer)
# 2. Block number (1-15 training, 1 transfer)
# 3. Trial number (1-15 training, 1-63 transfer)
# 4. Pattern type (1 = old medium, 2 = prototype, 3 = new low, 4 = new medium, 5 = new high)
# 5. Category number (1-3)
# 6. Pattern token* 
#   7. Category response (1-3)
# 8. Correct/Incorrect (0 = Incorrect, 1 = Correct)
# 9. Reaction time (in milliseconds)
# 10-27.Coordinates of nine dots* (-25 through 24)
# 
# *Pattern token: index of unique tokens for each category of each type of pattern. The numbering of old medium patterns differs for the two conditions.
# *Coordinates of nine dots: every two columns represent the x and y coordinates of a dot on a 50 x 50 grid
# 
# file names starting with "polyrep" contain data from repeating condtion.
# file names starting with "polynrep" contain data from non-repeating condtion.


#rm(list=ls())

pacman::p_load(dplyr,purrr,tidyr,ggplot2, data.table,readr,here, patchwork, conflicted)
conflict_prefer_all("dplyr", quiet = TRUE)

col.names = c("Phase","Block","BlockTrial","Pattern","Category","Pattern.Token","Response","Corr","rt",
              "x1","y1","x2","y2","x3","y3","x4","y4","x5","y5","x6","y6","x7","y7","x8","y8","x9","y9")

pathLoad="data/lmc_2022/Exp2_Classification"
loadPattern="*.txt"
pathString=paste(pathLoad,"/Data/",sep="")
mFiles <- list.files(path=pathString,pattern = loadPattern, recursive = FALSE) # should be 89 in exp 2
nFiles=length(mFiles)

dCat <- data.frame(matrix(ncol=27,nrow=0)) %>% purrr::set_names(col.names)

for (i in 1:nFiles){
  ps=paste(pathString,mFiles[i],sep="")
  sbj = readr::parse_number(mFiles[i])
  ind1=regexpr("y",mFiles[i])
  ind2=regexpr(sbj,mFiles[i])
  d.load=read.table(ps) %>% set_names(col.names) %>% mutate(file=mFiles[i],condit=substr(file,ind1+1,ind2-1),sbjCode=as.factor(sbj))
  dCat=rbind(dCat,d.load)
}


dCat <- dCat %>% group_by(sbjCode,condit,file) %>% mutate(ind=1,trial=cumsum(ind),id=paste0(sbjCode,".",condit))  %>%
  group_by(sbjCode,condit,Phase) %>%
  mutate(nPhase=n(),phaseAvg=sum(Corr)/nPhase,
         Pattern.Type=recode_factor(Pattern,`1` = 'Trained.Med', `2` = 'Prototype',  `3` = 'New.Low', `4` = 'New.Med',`5` = 'New.High'),
         Stage=car::recode(trial, "1:75='Start'; 76:150='Med'; 151:225='End';226:288='Test';else='Junk'"),
         Phase2=car::recode(trial, "1:225='Training'; 226:288='Transfer';else='Junk'"),
         id=as.factor(id),condit=as.factor(condit)) %>% 
  relocate(id,condit,.before=Phase) %>%
  relocate(id,trial,Phase,Phase2,Stage,Block,BlockTrial,Pattern.Type,Category,Corr,rt,phaseAvg,Pattern,Pattern.Token,Response,.after="condit") %>%
  arrange(condit,sbj) %>% 
  as.data.frame()

dCat <- dCat %>% group_by(sbjCode,Pattern.Type) %>% 
  mutate(patN=cumsum(ind)) %>%
  group_by(sbjCode,Pattern.Type,Category) %>% 
  mutate(patCatN=cumsum(ind),typeCount=paste0(Pattern.Type,".",patCatN)) %>% 
  relocate(typeCount,.after="Pattern.Type") 

dCat$Block = ifelse(dCat$Phase==2,16,dCat$Block)
dCat$Stage = factor(dCat$Stage,levels=c("Start","Med","End","Test")) 


dCat$Pattern.Type = factor(dCat$Pattern.Type,levels=c("Trained.Med","Prototype","New.Low","New.Med","New.High")) 
dCat$Pattern.Type2 <- ifelse(dCat$Phase==1,"Training",dCat$Pattern.Type)
dCat$Pattern.Type2=recode_factor(dCat$Pattern.Type2,"Training"="End.Training",`1` = 'Trained.Med', `2` = 'Prototype',  `3` = 'New.Low', `4` = 'New.Med',`5` = 'New.High')
dCat$Pattern.Type2 = factor(dCat$Pattern.Type2,levels=c("End.Training","Trained.Med","Prototype","New.Low","New.Med","New.High")) 
dCat$Condition = factor(dCat$condit,levels=c("rep","nrep"))
dCat$Phase2 = factor(dCat$Phase2,levels=c("Training","Transfer"))


dCatTrain <- dCat %>% filter(Phase==1)%>% relocate(sbjCode,condit,file) %>% group_by(id) %>%
   relocate(trial,phaseAvg,.after="condit") %>% arrange(condit,sbj) %>% mutate(Category=as.factor(Category))


dCatTrainAvg=dCatTrain  %>% group_by(id,condit,Condition,Block) %>% 
  summarise(nCorr=sum(Corr),propCor=nCorr/15,rtMean=mean(rt),phaseAvg=mean(phaseAvg),nTrain=max(nPhase)) %>% ungroup() %>% group_by(condit) %>%
  mutate(grpRank=factor(rank(-phaseAvg)),id=factor(id)) %>% arrange(-phaseAvg) %>% as.data.frame()
dCatTrainAvg$id <-factor(dCatTrainAvg$id,levels=unique(dCatTrainAvg$id))

dCatTrainAvg2=dCatTrain  %>% group_by(id,condit,Condition,Category,Block) %>% 
  summarise(nCorr=sum(Corr),propCor=nCorr/5,rtMean=mean(rt),phaseAvg=mean(phaseAvg),nTrain=max(nPhase)) %>% ungroup() %>% group_by(condit) %>%
  mutate(grpRank=factor(rank(-phaseAvg)),id=factor(id)) %>% arrange(-phaseAvg) %>% as.data.frame()
dCatTrainAvg2$id <-factor(dCatTrainAvg2$id,levels=unique(dCatTrainAvg2$id))


dCatAvg <- dCat %>% group_by(id,condit,Condition,Stage,Pattern.Type) %>% 
  dplyr::summarise(nPatStage=n(),nCorr=sum(Corr),propCor=nCorr/nPatStage,rt=mean(rt)) %>% ungroup() 
dCatAvg$id <-factor(dCatAvg$id,levels=unique(dCatTrainAvg2$id))



dCatAvg2 <- dCat %>% filter(trial>=151) %>% group_by(id,condit,Condition,Pattern.Type2,Category) %>% 
  dplyr::summarise(nPatStage=n(),nCorr=sum(Corr),propCor=nCorr/nPatStage,rt=mean(rt)) %>% ungroup() 
dCatAvg2$id <-factor(dCatAvg2$id,levels=unique(dCatTrainAvg2$id))


dCatAvg3 <- dCatAvg2 %>% group_by(id,condit,Pattern.Type2) %>% 
  dplyr::summarise(propCor=mean(propCor)) %>% ungroup() 


sbjTrainAvg <- dCatTrainAvg %>% filter(Block>12) %>% 
  group_by(id,condit,Condition) %>% summarise(endTrain=mean(propCor)) %>% ungroup() %>% as.data.frame() %>% group_by(condit,Condition) %>% 
  mutate(conditRank=rank(-endTrain),cq=factor(ntile(endTrain,2))) 
sbjTrainAvg$cq=recode_factor(sbjTrainAvg$cq,`1` = 'low-Performers', `2` = 'High-Performers')



dCat <- dCat |> mutate(exp="lmc22") |> 
  relocate(id,sbjCode,exp,condit,Phase,Phase2,Stage,
           trial,Block,BlockTrial,Pattern.Type,Pattern,Pattern.Token,
           Category,Response,Corr,rt)

#write out aggregated trial level data
#write_rds(dCat, "data/lmc22.rds")

# dCatBlockAvg <- dCat %>% group_by(id,condit,Block,Pattern.Type) %>% 
#   summarise(nCorr=sum(Corr),propCor=nCorr/15,rtMean=mean(rt),phaseAvg=mean(phaseAvg)) %>% ungroup() %>% group_by(condit) %>%
#   mutate(grpRank=factor(rank(-phaseAvg)),id=factor(id)) %>% arrange(-phaseAvg) %>% as.data.frame()
# dCatAvg$id <-factor(dCatAvg$id,levels=unique(dCatAvg$id))


# dCatAvg=dCatTrain  %>% group_by(condit,Block) %>%
#   mutate(group.nCorr=sum(Corr),group.propCor=group.nCorr/15,grp.sd=sd(group.nCorr)) %>% group_by(sbjCode,id,condit,Block) %>% 
#   summarise(nCorr=sum(Corr),propCor=nCorr/15,rtMean=mean(rt),zProp=propCor-(group.propCor*grp.sd),group.nCorr=mean(group.nCorr),
#             group.propCor=mean(group.propCor),grp.sd=mean(grp.sd))


# 
# dCatAvg=dCatTrain %>% group_by(sbjCode,id,condit,Block) %>% 
#   summarise(nCorr=sum(Corr),propCor=nCorr/15,rtMean=mean(rt),trainAvg=mean(trainAvg)) %>% ungroup() %>% group_by(sbjCode,id,condit) %>%
#   mutate(sbjAvg=mean(propCor)) %>% group_by(condit) %>% mutate(grpRank=rank(sbjAvg)) %>% arrange(grpRank)

# dCatAvg %>% ggplot(aes(x=Block,y=propCor,col=condit))+stat_summary(geom="point",fun="mean")+stat_summary(geom="line",fun="mean")



# We started by conducting preliminary analyses to remove severe outlier subjects. 
# For the learning phase, the performance measure used for identifying outliers was the 
# same as in Experi- ment 1. For the classification-transfer phase, we measured average
# accuracy computed across all 63 transfer trials. We again removed the data of any 
# subject who performed more than 2.5 standard deviations below the mean in each condition 
# on either measure. We removed four subjects from the REP condition (leaving 39 valid subjects)
# and two subjects from the NREP condition (leaving 44 valid subjects).
# 
# Data variable order, from left to right:
#   
# 1. Phase type (1 = Training, 2 = Transfer)
# 2. Block number (1-15 training, 1 transfer)
# 3. Trial number (1-15 training, 1-39 transfer)
# 4. Pattern type (1 = old medium, 2 = prototype, 4 = new medium, 6 = Foil)
# 5. Category number (1-3)
# 6. Pattern token* 
# 7. Category/Recognition response (1-3 category training; 1 = old 2 = new recognition transfer)
# 8. Correct/Incorrect (0 = Incorrect, 1 = Correct)
# 9. Reaction time (in milliseconds)
# 10-27.Coordinates of nine dots* (-25 through 24)
# *Pattern token: index of unique tokens for each category of each type of pattern. The numbering of old medium patterns differs across the two conditions.
# *Coordinates of nine dots: every two columns represent the x and y coordinates of a dot on a 50 x 50 grid

# file names starting with "polyrep" contain data from repeating condtion.
# file names starting with "polynrep" contain data from non-repeating condtion.


# pathLoad="Exp1_Recognition"
# loadPattern="*.txt"
# pathString=paste(pathLoad,"/Data/",sep="")
# mFiles <- list.files(path="Exp1_Recognition/Data/",pattern = loadPattern, recursive = FALSE) # should be 198 in exp1
# nFiles=length(mFiles)
# 
# dRec <- data.frame(matrix(ncol=27,nrow=0)) %>% purrr::set_colnames(col.names)
# 
# for (i in 1:nFiles){
#   ps=paste(pathString,mFiles[i],sep="")
#   sbj = readr::parse_number(mFiles[i])
#   ind1=regexpr("y",mFiles[i])
#   ind2=regexpr(sbj,mFiles[i])
#   d.load=read.table(ps) %>% set_names(col.names) %>% mutate(file=mFiles[i],condit=substr(file,ind1+1,ind2-1),sbjCode=as.factor(sbj))
#   dRec=rbind(dRec,d.load)
# }
# 
# dRec <- dRec %>% relocate(sbjCode,condit,file) %>% group_by(sbjCode) %>%
#   mutate(nTrain=n(),ind=1,trial=cumsum(ind),id=paste0(sbjCode,".",condit),trainAvg=sum(Corr)/nTrain) %>% relocate(trial,.after="condit") %>% arrange(condit,sbj)

# we conducted preliminary analyses to identify severe outlier sub- jects within each condition. 
# In the learning phase, we computed mean proportion correct for each subject during 
# the final eight blocks. In the transfer phase, we computed the difference between mean 
# proportion of old judgments on the old learning patterns and the foils. We removed from 
# all subsequently reported analyses the data of any subject who performed more than 2.5 
# standard deviations below the mean on either measure. We removed seven subjects from 
# the REP condition (leaving 91 valid subjects) and five subjects from the NREP 
# condition (leaving 95 valid subjects).

#library(forcats)

# dRecAvg=dRec %>% filter(Phase==1) %>% group_by(sbjCode,id,condit,Block) %>% 
#   summarise(nCorr=sum(Corr),propCor=nCorr/15,rtMean=mean(rt),trainAvg=mean(trainAvg)) %>% ungroup() %>% group_by(condit) %>%
#   mutate(sbjAvg=mean(propCor)) %>% 
#   mutate(grpRank=factor(rank(-trainAvg)),id=factor(id)) %>% arrange(-trainAvg) %>% as.data.frame()
# 
# dRecAvg$id <-factor(dRecAvg$id,levels=unique(dRecAvg$id))
# 
# dRecAvg %>% ggplot(aes(x=Block,y=propCor,col=condit))+stat_summary(geom="point",fun="mean")+stat_summary(geom="line",fun="mean")
# dRecAvg %>% ggplot(aes(x=Block,y=rtMean,col=condit))+stat_summary(geom="point",fun="mean")+stat_summary(geom="line",fun="mean")
# dRecAvg %>% ggplot(aes(x=Block,y=propCor,col=condit))+
#   stat_summary(geom="point",fun="mean")+stat_summary(geom="line",fun="mean")+facet_wrap(~sbjCode)
