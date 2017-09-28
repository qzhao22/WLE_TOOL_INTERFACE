library(tidyr)
library(dplyr)
library(magrittr)
library(gdata)

###################################################################################
# initialization 
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

res_ini <- read.table(file="Reservoir_initial.txt")
starg <- res_ini[,6:17]
ndtargr <- res_ini[,18]
maxout <-res_ini[,19:30]
minout <- res_ini[,31:42]

### THIS CROP YIELD DATA DOES NOT CHANGE ########
ag_sb <- read.csv("MK_Agent_Sub_basins0907.csv") %>% rename(SB_ID = Subbasin) #agent-subbasin relationship
cy_tar <- read.csv("TargetYields_rice_maize.csv") %>% rename(SB_ID = subbasin) %>% #target crop yields
  gather(key=Crop,value=TarYields,-SB_ID) %>% 
  separate(Crop,into = c("CName","Unit"),sep = "_") %>% 
  mutate(TarYields = TarYields/907.2,
         HRU_ID = ifelse(CName == "IRICE",1,3)) %>%
  left_join(ag_sb,by="SB_ID") %>% 
  select(Agent_ID,SB_ID,HRU_ID,TarYields)

crop_hru <- read.table("Crop_initial.txt")
colnames(crop_hru) <- c("SB_ID","HRU_ID","AreaFrac","PlantDate","IrriHeat","Irri_TS","Irri_eff","Irri_minflow")

costfactor = 1000 #this is the cost of increasing efficiency by 1%

#trigger to keep track of long term hydropower generation and whether it falls below minimum
hptrig <- matrix(rep(FALSE,nrow(res_ini)*10),nrow(res_ini)); 
hptrigcount <- rep(0,nrow(res_ini))#this count is used to ensure that it has been 10 years since start of simulation or 10 years since hydropower regulations have been altered

########################################################################################
#Survey weights for agriculture, hydropower, ecosystems
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

readweights <- read.csv("Survey_Retabulated.csv",stringsAsFactors=FALSE)# mean annual energy (GW)
weights <- data.frame(readweights$Agriculture..,readweights$Hydropower..,readweights$Ecosystem.Services..)
colnames(weights)<-c("A_weight","H_weight","E_weight")

#%%%%%%%%%%%%%%%%%%%%%%%%  SWAT  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
file.create("SWAT_flag.txt")
system("swat2012.exe",wait=FALSE,invisible=FALSE)
n<-1

while(n<22) #SWAT simulation period: 22 years - this part returns back to ABM
{
  while (file.exists("SWAT_flag.txt"))
  {
  }
  
  #################################################################################
  #SWAT output variables (ABM input variables)
  #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  ###### Streamflow 
  flow_mekong <- read.table("Flow_Mekong.txt")
  colnames(flow_mekong)[1:49] <- c("year","cal_day",paste0("Flow_SB_",1:47))
  
  ABM_flow <- flow_mekong %>% 
    tbl_df() %>%
    gather(key=Subbasin,value=Flow,-year,-cal_day) %>%
    mutate(SB_ID = extract_numeric(Subbasin)) %>%
    select(-Subbasin)
  
  ####### Reservoir Storage, outflow and surface area
  reservoir_mekong <- read.table("Reservoir_Mekong.txt")
  colnames(reservoir_mekong)[1:32] <- c("year","cal_day",paste0("Volume_Res",1:10),paste0("SurfArea_Res",1:10),paste0("Outflow_Res",1:10))
  
  ABM_reservoir <- reservoir_mekong %>% 
    tbl_df() %>% 
    gather(key=Att,value=Variable,-year,-cal_day) %>%
    separate(col=Att,into=c("Attr","Reservoir"),sep="_") %>%
    mutate(Reservoir = extract_numeric(Reservoir)) 
  #note: reservoir 1 and 7 are not actually reservoirs- created due to issues with SWAT
  
  ####### Crops
  crop_mekong  <- read.table("Crop_Mekong.txt")
  colnames(crop_mekong) <- c("year","SB_ID","HRU_ID","Act_yield","IWW")

  ########################################################################################
  #Crops constraints and decision making
  #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  if (n == 1){ # for the first year, the initial area fraction and efficiency will be used, and updated subsequently
    crop_eff <- select(crop_hru,SB_ID,HRU_ID,Irri_eff)
    crop_area <- select(crop_hru,SB_ID,HRU_ID,AreaFrac)
  } else {
    foo<-IRR_eff_by_R$New_Irri_eff
    crop_eff <- select(crop_hru,SB_ID,HRU_ID) %>%  mutate(Irri_eff = foo)
    crop_area <- select(crop_hru,SB_ID,HRU_ID) %>% mutate(AreaFrac = HRU_FR_by_R)
  }
  New_Eff <- filter(crop_mekong, year == n & HRU_ID %in% c(1,3)) %>% 
    select(SB_ID, HRU_ID,Act_yield) %>% 
    left_join(cy_tar) %>% 
    left_join(crop_eff) %>% 
     mutate(New_Irri_eff = ifelse(Act_yield < TarYields,min(0.8,Irri_eff*1.1),Irri_eff)) %>%
     mutate(AddEffCost = (New_Irri_eff-Irri_eff)*100*costfactor)%>%
     mutate(Irri_eff = New_Irri_eff)
  #save New_Eff for later use with hpflag or a similar data frame if it gets changed

  IRR_eff_by_R <- left_join(crop_hru,New_Eff,by=c("SB_ID","HRU_ID")) %>%
    mutate(min_irr_flow = 1) %>% 
    select(New_Irri_eff,min_irr_flow)
  
  UpdateAreas <- NULL
  
  for (sb in 1:47){
    temp <- mutate(crop_area,NewAreaFrac =AreaFrac) %>% 
      filter(SB_ID==sb) %>% 
      data.frame()
    
    val <- filter(New_Eff,SB_ID==sb & HRU_ID == 1) %>% .$New_Irri_eff
    
    if(val ==1){
      del_inc <- temp[temp$HRU_ID==1,"AreaFrac"]*0.1
      
      temp[temp$HRU_ID==5,"NewAreaFrac"] <- max(0,temp[temp$HRU_ID==5,"AreaFrac"] - 0.5*del_inc)
      temp[temp$HRU_ID==6,"NewAreaFrac"] <- max(0,temp[temp$HRU_ID==6,"AreaFrac"] - 0.5*del_inc)
      temp[temp$HRU_ID==1,"NewAreaFrac"] <- 1- sum(temp[-1,"NewAreaFrac"])
      
    }
    
    UpdateAreas <- bind_rows(UpdateAreas,temp)
  }
  
  HRU_FR_by_R <- UpdateAreas$NewAreaFrac
  ###############################################################################
  # Hydropower generation calculation, constraints, and flags
  ###!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  
  if (n<=3){#first year of simulation is year 3
    readhydpow <- read.csv("reservoir_data_for_ABM.csv",stringsAsFactors=FALSE)# mean annual energy (GW)
    mean_hydpow <- as.numeric(readhydpow$Mean.Annual.Energy..GWh.) #(GWh)
    capacity_hydpow <- as.numeric(readhydpow$Daily.Capacity..GWh.) #(GWh)
    min_hydpow <- mean_hydpow *0.9# set min at 90% of mean for now
    res_eff <- readhydpow$Efficiency
    res_a <- readhydpow$a
    res_b <- readhydpow$b
    res_c <- readhydpow$c}
  if (n>3){min_hydpow <- min_hydpow*1.07}#increase 7% per year (first year of simulation is year 3)
  #power demands  expected to increase by about 7% per year between (2010 and 2030)
  
  daily_res_Q <- reservoir_mekong[which(reservoir_mekong$year==n),paste0("Outflow_Res",1:10)]/86400;
  names(daily_res_Q)<-paste0("daily_Q_res",1:10)
  #daily outflow for each reservoir converted to m3/s from m3/day

  daily_res_head <- as.data.frame(t(res_a*t(reservoir_mekong[which(reservoir_mekong$year==n),paste0("Volume_Res",1:10)])^res_b+res_c));
  names(daily_res_head)<-paste0("daily_head_res",1:10)
  #daily mean head for each reservoir calculated from storage and empircal data
  
  #hydpow = u*rho*g*H*Q/1,000,000,000 for GW (kgm^2/s^3*10^9) then *24 to GWh
  #u = efficiency (in general ranging 0.75 to 0.95) but taken from data if exists
  raw_hydpow <- data.frame(mapply('*',((1000*9.81*daily_res_head*daily_res_Q)/1000000000*24),res_eff));
  names(raw_hydpow)<-paste0("raw_hydpow_res",1:10)
  raw_hydpow <- as.matrix(raw_hydpow)
  #raw hydropower without accounting for capacity
  
  max_hydpow <- matrix(capacity_hydpow,nrow=ncol(raw_hydpow),ncol=nrow(raw_hydpow))
  max_hydpow <- t(max_hydpow)
  daily_hydpow <- pmin(raw_hydpow,max_hydpow)
  #need two matrices to use pmindaily
  colnames(daily_hydpow)<-paste0("daily_hydpow_res",1:10)
  #capacity is now accounted for as a maximum value
  
  hydpow <-colSums(daily_hydpow)
  names(hydpow)<-paste0("hydpow_res",1:10)
  #hydropower is now summed to annual for later management decisions (compare to annual means)
  
  nn=rep(n,nrow(readhydpow));resagent<-ag_sb$Agent_ID[ag_sb$SB_ID%in%readhydpow$subbasin..090715.setup.]
  hydpow1<-data.frame(cbind(nn,resagent,readhydpow$Reservoir.name,hydpow));names(hydpow1)<-c("year","Agent_ID","Reservoir","Hydro.Power")
  if (n==1){
    hydpow_save<-hydpow1
  }else{
    hydpow_save<-rbind(hydpow_save,hydpow1)}
  #hydropower needs to be saved for each year for later analysis (summary tables)
  
  hpflag <- rep(0,nrow(ag_sb))#number of rows = number of subbasins
  res_exist <- rep(0,nrow(ag_sb)); res_exist=ifelse(ag_sb$SB_ID %in% readhydpow$subbasin,1,0)
  hpinfo <- data.frame(ag_sb$SB_ID,res_exist,hpflag);names(hpinfo)<-c("SB_ID","res_exist","hpflag")
  #this is used to see if hydropower requirements are not met on any particular year,
  #if they are not, then increase irr_eff in all subbasins in that agent such that there is more water for storage/hydropower
  New_Eff <- right_join(New_Eff,hpinfo,by="SB_ID")
  #the hpinfo dataframe is combined with the crops one for later ease
  
  ###############################################################################
  # Hydropower decisions (management changes)
  ###!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
  
  nores=nrow(readhydpow);rr=1:nores
  for (r in rr){#reservoir loop
    
    if (!is.na(min_hydpow[r])){#for now some of the reservoirs are either not reservoirs but mistakes on SWAT side or have no 
      #data from mrc such as (volume to head relationship, efficency) so ignore them
      
      hptrigcount[r] <- hptrigcount[r]+1
      
      if (hydpow[r]< min_hydpow[r]){
        New_Eff$hpflag <- ifelse(New_Eff$SB_ID==readhydpow$subbasin[r],1,New_Eff$hpflag)#hp flag for later irr_eff change
        
        #asign TRUE to most recent year and replace all other years with the value from the year before
        hptrig[r,10]<-hptrig[r,9];hptrig[r,9]<-hptrig[r,8];hptrig[r,8]<-hptrig[r,7];hptrig[r,7]<-hptrig[r,6];hptrig[r,6]<-hptrig[r,5];hptrig[r,5]<-hptrig[r,4];hptrig[r,4]<-hptrig[r,3];hptrig[r,3]<-hptrig[r,2];hptrig[r,2]<-hptrig[r,1];hptrig[r,1]<-TRUE;
        if (all(hptrig[])==TRUE & hptrigcount[r]>=10){#if hydropower generated is less than the minimum over last 10 years 
          #decrease number of days required to reach target and target storage during dry season
          starg[r,-(5:10)] <- starg[r,-(5:10)]*0.7
          ndtargr[r] <- ndtargr[r]-4
          hptrigcount[r]=0#reset hydropower trigger count after changing reservoir managemnt practices to ensure it will not be changed for at least 10 more years (if ever again)
          
        }else if (sum(hptrig[r,])==9 & hptrigcount[r]>=10){#if hydropower generated is less than the minimum for 9 of last 10 years
          #decrease number of days required to reach target and target storage to a lesser extent than for 10/10 years
          starg[r,-(5:10)] <- starg[r,-(5:10)]*0.8
          ndtargr[r] <- ndtargr[r]-3
          hptrigcount[r]=0#reset hydropower trigger count
          
        }else if (sum(hptrig[r,])==8 & hptrigcount[r]>=10){#if hydropower generated is less than the minimum for 8 of last 10 years
          #decrease number of days required to reach target and target storage to a lesser extent than for 9/10 years
          starg[r,-(5:10)] <- starg[r,-(5:10)]*0.9
          ndtargr[r] <- ndtargr[r]-2
          hptrigcount[r]=0#reset hydropower trigger count
          
        }else{}
        
      }else{
        #asign FALSE to most recent year and replace all other years with the value from the year before
        hptrig[r,10]<-hptrig[r,9];hptrig[r,9]<-hptrig[r,8];hptrig[r,8]<-hptrig[r,7];hptrig[r,7]<-hptrig[r,6];hptrig[r,6]<-hptrig[r,5];hptrig[r,5]<-hptrig[r,4];hptrig[r,4]<-hptrig[r,3];hptrig[r,3]<-hptrig[r,2];hptrig[r,2]<-hptrig[r,1];hptrig[r,1]<-FALSE;
      }
    }#end if nan
  }#end for loop
  
  ##########################################################
  # If hydropower requirements not met (hpflag), then increase irr_eff 
  #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  #OPTION 1: increase irr_eff in just that subbasin
  #mutate(New_Eff, New_Irri_eff = ifelse(hpflag==1,min(1,Irri_eff*1.1),Irri_eff)) %>% 
  #mutate(AddEffCost = (New_Irri_eff-Irri_eff)*100*costfactor)
  
  #OPTION 2:increase irr_eff in all subbasins in that agent
  for (i in 1:nrow(New_Eff)){
    ifelse(New_Eff$Agent_ID[i] %in% New_Eff$Agent_ID[New_Eff$hpflag==1],New_Eff$New_Irri_eff[i] <- min(0.8,New_Eff$Irri_eff[i]*1.1),New_Eff$New_Irri_eff[i] <-New_Eff$Irri_eff[i])
    New_Eff$AddEffCost[i] = New_Eff$AddEffCost[i]+(New_Eff$New_Irri_eff[i]-New_Eff$Irri_eff[i])*100*costfactor
      }
  #adjust irr eff in New_Eff for later use (above) and in IRR_eff_by_R for writing out (below)
  final_Irri_eff<-rep(New_Eff$New_Irri_eff,1,each=4);
  IRR_eff_by_R<-mutate(IRR_eff_by_R,New_Irri_eff =final_Irri_eff)
  ###########################################################
  #Post-calculation for (From SWAT output) ecosystem services
  #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  
  # calculate water availability for domestic use
  
  # calculate water availability for industrial use
  
  ############ecosystem requirements!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  columnend<-(nrow(ag_sb)+2);
  ecoyear<-flow_mekong[which(flow_mekong$year==n),3:columnend];
  
  #Magnitude Timing (IHA 1:12 - mean streamflow for each calendar month)!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  jan<-as.vector(colMeans(ecoyear[1:31,]));feb<-as.vector(colMeans(ecoyear[32:59,]));mar<-as.vector(colMeans(ecoyear[60:90,]));apr<-as.vector(colMeans(ecoyear[91:120,]));may<-as.vector(colMeans(ecoyear[121:151,]));jun<-as.vector(colMeans(ecoyear[152:181,]));
  jul<-as.vector(colMeans(ecoyear[182:212,]));aug<-as.vector(colMeans(ecoyear[213:243,]));sep<-as.vector(colMeans(ecoyear[244:273,]));oct<-as.vector(colMeans(ecoyear[274:304,]));nov<-as.vector(colMeans(ecoyear[305:334,]));dec<-as.vector(colMeans(ecoyear[335:365,]));
  
  #Magnitude Duration (IHA 13:22 - annual max/min 1,3,7,30,90-day means)!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  day1min<-apply(ecoyear,2,min); day1max<-apply(ecoyear,2,max)
  
  for (t in seq(1,365,90)){
    for (s in t:(t+89)){
      if (s==1){
        hold90<-colSums(ecoyear[s:(s+89),])
      }else{
        hold90new<-colSums(ecoyear[s:(s+89),])
        hold90<-rbind(hold90,hold90new)
      }
    }
  }
  day90max<-apply(hold90[1:276,],2,max);day90min<-apply(hold90[1:276,],2,min)
  #will be 276 saved 90day values in hold90 for 90day means
  
  for (t in seq(1,365,30)){
    for (s in t:(t+29)){
      if (s==1){
        hold30<-colSums(ecoyear[s:(s+29),])
      }else{
        hold30new<-colSums(ecoyear[s:(s+29),])
        hold30<-rbind(hold30,hold30new)
      }
    }
  }
  day30max<-apply(hold30[1:336,],2,max);day30min<-apply(hold30[1:336,],2,min)
  #will be 336 saved 30day values in hold30 for 30day means
  
  for (t in seq(1,365,7)){
    for (s in t:(t+6)){
      if (s==1){
        hold7<-colSums(ecoyear[s:(s+6),])
      }else{
        hold7new<-colSums(ecoyear[s:(s+6),])
        hold7<-rbind(hold7,hold7new)
      }
    }
  }
  day7max<-apply(hold7[1:359,],2,max);day7min<-apply(hold7[1:359,],2,min)
  #will be 359 saved 7day values in hold7 for 7day means
  
  for (t in seq(1,365,3)){
    for (s in t:(t+2)){
      if (s==1){
        hold3<-colSums(ecoyear[s:(s+2),])
      }else{
        hold3new<-colSums(ecoyear[s:(s+2),])
        hold3<-rbind(hold3,hold3new)
      }
    }
  }
  day3max<-apply(hold3[1:363,],2,max);day3min<-apply(hold3[1:363,],2,min)
  #will be 363 saved 3day values in hold3 for 3day means

  #Timing (IHA 23:24 - day of 1-day min and max)!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  mindate<-apply(ecoyear,2,which.min); maxdate<-apply(ecoyear,2,which.max)
  
  #Magnitude Frequency Duration (IHA 25:28 - number of low/high pulses, mean duration of low/high pulses)!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  # to quantify these we need to establish thresholds for what constitutes a high or low pulse- e.g. 75percentile,25percentile of values over long period of time (pre-simulation)
  highpulse<-apply(ecoyear,2,max)*.8; lowpulse<-apply(ecoyear,2,max)*.2; #high and low pulse threshold NEED to be taken from historic data once obtained
  counthigh<-matrix(rep(0),nrow(ecoyear),ncol(ecoyear));countlow<-matrix(rep(0),nrow(ecoyear),ncol(ecoyear))#reinitialize each year
  for (i in 1:ncol(ecoyear)){
    hptrig <- matrix(rep(FALSE,nrow(res_ini)*10),nrow(res_ini)); 
    counthigh[,i]<-ecoyear[,i]>highpulse[i];countlow[,i]<-ecoyear[,i]>lowpulse[i];
  }
  hipulse_no<-apply(counthigh,2,sum); lopulse_no<-apply(countlow,2,sum)
  hipulse_dur<-apply(counthigh,2,function(x){
    hirle<-rle(x);mean(hirle$lengths[hirle$values==TRUE])})
  lopulse_dur<-apply(countlow,2,function(x){
    lorle<-rle(x);mean(lorle$lengths[lorle$values==TRUE])})
    
  #Frequency Rate of Change (IHA 29:32 - mean of positive/negative differences between daily values, number of rises/falls)!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  ecochange1<-data.frame(diff(as.matrix(ecoyear[,]),lag=1));ecochange2<-data.frame(diff(as.matrix(ecoyear[,]),lag=1));
  ecochange1[ecochange1<=0]<-NA; ecochange2[ecochange2>=0]<-NA;
  mean_increase <- colMeans(ecochange1,na.rm=TRUE); mean_decrease <- colMeans(ecochange2,na.rm=TRUE);
  number_rises <- apply(ecochange1, 2, function(x) length(which(!is.na(x)))); number_falls <- apply(ecochange2, 2, function(x) length(which(!is.na(x))))
  
  if (n==1){
    IHA <- data.frame(n,ag_sb$SB_ID,jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec,day1min,day1max,day3min,day3max,day7min,day7max,day30min,day30max,day90min,day90max,mindate,maxdate,hipulse_no,lopulse_no,hipulse_dur,lopulse_dur,mean_increase,mean_decrease,number_rises,number_falls)
    colnames(IHA)[1:34] <- c("year","sub_ID","jan","feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec","1daymin","1daymax","3daymin","3daymax","7daymin","7daymax","30daymin","30daymax","90daymin","90daymax","dayofmin","dayofmax","hipulse_no","lopulse_no","hipulse_dur","lopulse_dur","ave_increa","ave_decrea","No. Rises","No. Falls")
    rownames(IHA) <- NULL
  }else{
    IHAnew <- data.frame(n,ag_sb$SB_ID,jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec,day1min,day1max,day3min,day3max,day7min,day7max,day30min,day30max,day90min,day90max,mindate,maxdate,hipulse_no,lopulse_no,hipulse_dur,lopulse_dur,mean_increase,mean_decrease,number_rises,number_falls)
    colnames(IHAnew)[1:34] <- c("year","sub_ID","jan","feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec","1daymin","1daymax","3daymin","3daymax","7daymin","7daymax","30daymin","30daymax","90daymin","90daymax","dayofmin","dayofmax","hipulse_no","lopulse_no","hipulse_dur","lopulse_dur","ave_increa","ave_decrea","No. Rises","No. Falls")
    rownames(IHAnew) <- NULL
    IHA <- rbind(IHA,IHAnew)
  }
  #"IHAnew" holds IHA's for current year and "IHA" holds all years
  
  ############################################################################################################################
  ############################################################################################################################
  # Write ABM output (SWAT input) to data file
  ############################################################################################################################
  ############################################################################################################################
  #IRR_eff_by_R is already constructed
  
  hru_out<-crop_hru[,-8];hru_out<-hru_out[,-3];hru_out<-cbind(hru_out,HRU_FR_by_R);hru_out<-hru_out[c(1,2,7,3,4,5,6)]
  #this uses the initial file as a template because the write out mimics that file. Irrigation minimum flow is removed since that is not suppose
  #to be written out in this file, however the initial areas are replaced with what was decided upon by the crop section of the ABM
  
  res<-cbind(starg,ndtargr,maxout,minout)

  write.table(IRR_eff_by_R,file="Irr_eff_by_R.txt",col.names = F, row.names = F)
  write.table(res,file="Reservoir_by_R.txt", col.names = F, row.names = F) 
  write.table(hru_out,file="HRU_FR_by_R.txt", col.names = F, row.names = F) 
  ################################################################
  #save decision variables for each year for later analysis
  #way this is written now basically just combines all years of simulation (by append) and writes similarly as for SWAT input only including year
  
  hru_out_save<-cbind(n,hru_out)
  res_save<-cbind(n,res)
  IRR_eff_by_R_save<-cbind(n,IRR_eff_by_R)
  write.table(IRR_eff_by_R_save,file="save_Irr_eff_by_R.txt",col.names = F, row.names = F, append =T)
  write.table(res_save,file="save_Reservoir_by_R.txt", col.names = F, row.names = F, append =T) 
  write.table(hru_out_save,file="save_HRU_FR_by_R.txt", col.names = F, row.names = F, append =T) 
  
  
  file.create("SWAT_flag.txt")
  n<-n+1
}

################################################################
while (file.exists("SWAT_flag.txt"))
{
}#still need to wait for SWAT to finish or wont have last year of data

crop_mekong  <- read.table("Crop_Mekong.txt")
colnames(crop_mekong) <- c("year","SB_ID","HRU_ID","Act_yield","IWW")
#have to reread final data since what has been read by ABM is only for 21 years (SWAT doesnt return to ABM for final year)
  
crop_mekongsum <- crop_mekong[crop_mekong$HRU_ID==1,c(1,2,4)]
#first remove all rows for non rice and colums for hru # and water withdrawl
  
crop_mekong1 <- crop_mekong[crop_mekong$HRU_ID==3,c(1,2,4)]
crop_mekongsum["M_Act_yield"] <- crop_mekong1$Act_yield
#now add maize
  
agentinfo <- rep(ag_sb$Agent_ID,n); crop_mekongsum["Agent_ID"] <- agentinfo; crop_mekongsum <- crop_mekongsum[c(1,5,2,3,4)]
#now add column for agent and rearange
  
#!!!crummy part about not returning to ABM after year 22 is that the hydropower has to be calculated for that final year now and added to dataframe
reservoir_mekong <- read.table("Reservoir_Mekong.txt");colnames(reservoir_mekong)[1:32] <- c("year","cal_day",paste0("Volume_Res",1:10),paste0("SurfArea_Res",1:10),paste0("Outflow_Res",1:10))
daily_res_Q <- reservoir_mekong[which(reservoir_mekong$year==n),paste0("Outflow_Res",1:10)]/86400;names(daily_res_Q)<-paste0("daily_Q_res",1:10)
daily_res_head <- as.data.frame(t(res_a*t(reservoir_mekong[which(reservoir_mekong$year==n),paste0("Volume_Res",1:10)])^res_b+res_c));names(daily_res_head)<-paste0("daily_head_res",1:10)
raw_hydpow <- data.frame(mapply('*',((1000*9.81*daily_res_head*daily_res_Q)/1000000000*24),res_eff));names(raw_hydpow)<-paste0("raw_hydpow_res",1:10)
raw_hydpow <- as.matrix(raw_hydpow);max_hydpow <- matrix(capacity_hydpow,nrow=ncol(raw_hydpow),ncol=nrow(raw_hydpow));max_hydpow <- t(max_hydpow)
daily_hydpow <- pmin(raw_hydpow,max_hydpow);colnames(daily_hydpow)<-paste0("daily_hydpow_res",1:10)
hydpow <-colSums(daily_hydpow);names(hydpow)<-paste0("hydpow_res",1:10)
nn=rep(n,nrow(readhydpow));resagent<-ag_sb$Agent_ID[ag_sb$SB_ID%in%readhydpow$subbasin..090715.setup.]
hydpow1<-data.frame(cbind(nn,resagent,readhydpow$Reservoir.name,hydpow));names(hydpow1)<-c("year","Agent_ID","Reservoir","Hydro.Power");hydpow_save<-rbind(hydpow_save,hydpow1)
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

write.csv(crop_mekongsum, file = "crop_summary.csv",row.names = FALSE)
write.csv(hydpow_save, file = "hydropower_summary.csv",row.names = FALSE)

################################################################
