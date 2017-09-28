library(tidyr)
library(dplyr)
library(magrittr)
library(gdata)


#trigger to keep track of long term hydropower generation and whether it falls below minimum
hptrig <- matrix(rep(FALSE,100),10); 
hptrigcount <- rep(0,10)#this count is used to ensure that it has been 10 years since start of simulation or 10 years since hydropower regulations have been altered


file.create("SWAT_flag.txt")
system("swat2012.exe",wait=FALSE,invisible=FALSE)
n<-1

while(n<22) #SWAT simulation period: 22 years
{
  while (file.exists("SWAT_flag.txt"))
  {
  }
  
  ###################################################################################
  # initialization 
  #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  
  crop_hru <- read.table("Crop_initial.txt")
  colnames(crop_hru) <- c("SB_ID","HRU_ID","AreaFrac","PlantDate","IrriHeat","Irri_TS","Irri_eff","Irri_minflow")

  res_ini <- read.table(file="Reservoir_initial.txt")
  
  if (n<=3){#year 3 is the first year of simulation (we do not want to reinitialize values as Reservoir_initial.txt will not be updated)
    starg <- res_ini[,6:17]
    ndtargr <- res_ini[,18]
    maxout <-res_ini[,19:30]
    minout <- res_ini[,31:42]
  }
  
  ########################################################################################
  #Survey weights for agriculture, hydropower, ecosystems
  #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  
  readweights <- read.csv("Survey_Retabulated.csv",stringsAsFactors=FALSE)# mean annual energy (GW)
  weights <- data.frame(readweights$Agriculture..,readweights$Hydropower..,readweights$Ecosystem.Services..)
  colnames(weights)<-c("A_weight","H_weight","E_weight")
  
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
  
  ag_sb <- read.csv("MK_Agent_Sub_basins0907.csv") %>% rename(SB_ID = Subbasin) #agent-subbasin relationship
  cy_tar <- read.csv("Mean_Irrigated_rice_yield_by_subbasin.csv") %>% rename(SB_ID = subbasin) #target crop yields
  
  sb_char <- read.csv("Subbasins_char.csv") %>% #obtain sub-basin characteristics such as area
    tbl_df() %>% 
    transmute(SB_ID=Subbasin,SB_Area_ha=Area) %>% 
    left_join(ag_sb,by="SB_ID") %>% #agent and sub-basin relationships
    left_join(crop_hru,by="SB_ID") %>% #cropping information for each hru
    left_join(cy_tar,by="SB_ID") %>% 
    select(Agent_ID,SB_ID,SB_Area_ha,HRU_ID,AreaFrac:Irri_minflow,kg.ha) %>% 
    rename(tar_kg.ha = kg.ha)
  
  costfactor = 1000 #this is the cost of increasing efficiency by 1%
  
  New_Eff <- filter(crop_mekong, year == 1 & HRU_ID == 1) %>% select(SB_ID, HRU_ID,Act_yield) %>% 
    left_join(sb_char) %>% 
    select(HRU_ID,SB_ID,Agent_ID,Act_yield,tar_kg.ha,SB_Area_ha,AreaFrac,Irri_TS,Irri_eff,Irri_minflow) %>%
    mutate(tar_yield = SB_Area_ha*AreaFrac*tar_kg.ha*(1/907.2)) #%>% #convert target yield into tonnes from kg/ha 
    #mutate(New_Irri_eff = ifelse(Act_yield < tar_yield,min(1,Irri_eff*1.1),Irri_eff)) %>% 
    #mutate(AddEffCost = (New_Irri_eff-Irri_eff)*100*costfactor)
    #save New_Eff for later use with hpflag or a similar data frame if it gets changed
  
  UpdateAreas <- NULL
  
  for (sb in 1:47){
    temp <- select(sb_char,Agent_ID,SB_ID,HRU_ID,AreaFrac) %>% 
      mutate(NewAreaFrac =AreaFrac) %>% 
      filter(SB_ID==sb) %>% 
      data.frame()
    
    val <- filter(New_Eff,SB_ID==sb) %>% .$New_Irri_eff
    
    if(val ==1){
      del_inc <- temp[temp$HRU_ID==1,"AreaFrac"]*0.1
      
      temp[temp$HRU_ID==5,"NewAreaFrac"] <- max(0,temp[temp$HRU_ID==5,"AreaFrac"] - 0.5*del_inc)
      temp[temp$HRU_ID==6,"NewAreaFrac"] <- max(0,temp[temp$HRU_ID==6,"AreaFrac"] - 0.5*del_inc)
      temp[temp$HRU_ID==1,"NewAreaFrac"] <- 1- sum(temp[-1,"NewAreaFrac"])
      
    }
    
    UpdateAreas <- bind_rows(UpdateAreas,temp)
  }
  
###############################################################################
# Hydropower generation calculation, constraints, and flags
###!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  
  if (n<=3){#first year of simulation is year 3
    readhydpow <- read.csv("reservoir_data_for_ABM.csv",stringsAsFactors=FALSE)# mean annual energy (GW)
    mean_hydpow <- as.numeric(readhydpow$Mean.Annual.Energy..GWh.) #(GWh)
    min_hydpow <- mean_hydpow *0.9# set min at 90% of mean for now
    res_eff <- readhydpow$Efficiency
    res_a <- readhydpow$a
    res_b <- readhydpow$b}
  if (n>3){min_hydpow <- min_hydpow*1.07}#increase 7% per year (first year of simulation is year 3)
  #power demands  expected to increase by about 7% per year between (2010 and 2030)
  res_Q <- (colMeans(reservoir_mekong[which(reservoir_mekong$year==n),paste0("Outflow_Res",1:10)]))/86400;names(res_Q)<-paste0("Q_res",1:10)
  #mean of daily flow converted to m3/s (from m3/day)
  res_head <- colMeans(t(res_a*t(reservoir_mekong[which(reservoir_mekong$year==n),paste0("Volume_Res",1:10)])^res_b));names(res_head)<-paste0("head_res",1:10)
  #mean head for the year for each reservoir
  
  #hydpow = u*rho*g*H*Q/1,000,000,000 for GW (kgm^2/s^3*10^9) then *8760 to GWh
  #u = efficiency (in general ranging 0.75 to 0.95)
  hydpow <- (res_eff*1000*9.81*res_head*res_Q)/1000000000*8760;names(hydpow)<-paste0("hydpow_res",1:10)
  

  hpflag <- rep(0,nrow(ag_sb))#number of rows = number of subbasins
  res_exist <- rep(0,nrow(sb_char)); res_exist=ifelse(ag_sb$SB_ID %in% readhydpow$subbasin,1,0)
  hpinfo <- data.frame(ag_sb$SB_ID,res_exist,hpflag);names(hpinfo)<-c("SB_ID","res_exist","hpflag")
  #this is used to see if hydropower requirements are not met on any particular year,
  #if they are not, then increase irr_eff in all subbasins in that agent such that there is more water for storage/hydropower
  New_Eff <- right_join(New_Eff,hpinfo,by="SB_ID")
  #the hpinfo dataframe is combined with the crops one for later ease
  
  ###############################################################################
  # Hydropower decisions (management changes)
  ###!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
  
  nores=10;rr=1:nores
  for (r in rr){#reservoir loop
      
    if (!is.na(min_hydpow[r])){#for now some of the reservoirs are either not reservoirs but mistakes on SWAT side or have no 
      #data from mrc such as (volume to head relationship, efficency) so ignore them
        
      hptrigcount[r] <- hptrigcount[r]+1
        
      if (hydpow[r]< min_hydpow[r]){
        New_Eff$hpflag <- ifelse(New_Eff$SB_ID==readhydpow$subbasin[r],1,0)#hp flag for later irr_eff change
          
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

  ###################################################
  # If hydropower requirements not met (hpflag), then increase irr_eff 
  #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  
  #OPTION 1: increase irr_eff in just that subbasin
  #mutate(New_Eff, New_Irri_eff = ifelse(hpflag==1,min(0.75,Irri_eff*1.1),Irri_eff)) %>% 
  #mutate(AddEffCost = (New_Irri_eff-Irri_eff)*100*costfactor)
  
  #OPTION 2:increase irr_eff in all subbasins in that agent
  New_Eff <- mutate(New_Eff,New_Irri_eff = ifelse(New_Eff$Agent_ID==New_Eff$Agent_ID[New_Eff$hpflag==1],min(0.75,Irri_eff*1.1),Irri_eff))%>% 
  mutate(AddEffCost = (New_Irri_eff-Irri_eff)*100*costfactor)
  
  ################################
  #Post-calculation for (From SWAT output) ecosystem services
  
  # calculate water availability for domestic use
  # calculate water availability for industrial use
  # ecosystem requirements
  
  ############################################################################################################################
  ############################################################################################################################
  # Write ABM output (SWAT input) to data file
  ############################################################################################################################
  ############################################################################################################################
  irr_minflow[] <- crop_hru$Irri_minflow
  #when this variable is used later this may need to be changed as it will not read initial value
  
  hru_out<-crop_hru[,-8]
  res<-cbind(starg,ndtargr,maxout,minout)
  irr_out<-cbind(irr_eff,irr_minflow)
  write.table(irr_out,file="Irr_eff_by_R.txt",col.names = F, row.names = F)
  write.table(res,file="Reservoir_by_R.txt", col.names = F, row.names = F) 
  write.table(hru_out,file="HRU_FR_by_R.txt", col.names = F, row.names = F) 
  
  #########################################################
  #save decision variables for each year for later analysis
  #way this is written now basically just combines all years of simulation and writes similarly as for SWAT input only including year
  
  hru_out_save<-cbind(n,crop_hru[,-8])
  res_save<-cbind(n,starg,ndtargr,maxout,minout)
  irr_out_save<-cbind(n,irr_eff,irr_minflow)
  write.table(irr_out_save,file="save_Irr_eff_by_R.txt",col.names = F, row.names = F, append =T)
  write.table(res_save,file="save_Reservoir_by_R.txt", col.names = F, row.names = F, append =T) 
  write.table(hru_out_save,file="save_HRU_FR_by_R.txt", col.names = F, row.names = F, append =T) 
  
  
  file.create("SWAT_flag.txt")
  n<-n+1
}