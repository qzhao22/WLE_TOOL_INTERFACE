library(tidyr)
library(dplyr)
library(magrittr)


file.create("SWAT_flag.txt")
system("swat2012.exe",wait=FALSE,invisible=FALSE)
n<-1

while(n<22) #SWAT simulation period: 22 years
{
  while (file.exists("SWAT_flag.txt"))
  {
  }

  #Streamflow
  flow_mekong <- read.table("Flow_Mekong.txt")
  colnames(flow_mekong)[1:49] <- c("year","cal_day",paste0("Flow_SB_",1:47))
  
  ABM_flow <- flow_mekong %>% 
    tbl_df() %>%
    gather(key=Subbasin,value=Flow,-year,-cal_day) %>%
    mutate(SB_ID = extract_numeric(Subbasin)) %>%
    select(-Subbasin)
  
  ####### Storage, outflow and surface area########
  reservoir_mekong <- read.table("Reservoir_Mekong.txt")
  colnames(reservoir_mekong)[1:32] <- c("year","cal_day",paste0("Volume_Res",1:10),paste0("SurfArea_Res",1:10),paste0("Outflow_Res",1:10))
  
  ABM_reservoir <- reservoir_mekong %>% 
    tbl_df() %>% 
    gather(key=Att,value=Variable,-year,-cal_day) %>%
    separate(col=Att,into=c("Attr","Reservoir"),sep="_") %>%
    mutate(Reservoir = extract_numeric(Reservoir))
  
  res_ini <- read.csv(file="resini.csv")

  #Crop yield
  crop_hru <- read.table("Crop_initial.txt")
  colnames(crop_hru) <- c("SB_ID","HRU_ID","AreaFrac","PlantDate","IrriHeat","Irri_TS","Irri_eff")
  
  ag_sb <- read.csv("MK_Agent_Sub_basins0907.csv") %>% rename(SB_ID = Subbasin) #agent-subbasin relationship
  cy_tar <- read.csv("Mean_Irrigated_rice_yield_by_subbasin.csv") %>% rename(SB_ID = subbasin) #target crop yields

  #########################################################################
  #########################################################################
  #########################################################################
  #########################################################################
  
  sb_char <- read.csv("Subbasins_char.csv") %>% #obtain sub-basin characteristics such as area
    tbl_df() %>% 
    transmute(SB_ID=Subbasin,SB_Area_ha=Area) %>% 
    left_join(ag_sb,by="SB_ID") %>% #agent and sub-basin relationships
    left_join(crop_hru,by="SB_ID") %>% #cropping information for each hru
    left_join(cy_tar,by="SB_ID") %>% 
    select(Agent_ID,SB_ID,SB_Area_ha,HRU_ID,AreaFrac:Irri_eff,kg.ha) %>% 
    rename(tar_kg.ha = kg.ha)

  crop_mekong  <- read.table("Crop_Mekong.txt")
  colnames(crop_mekong) <- c("year","SB_ID","HRU_ID","Act_yield","IWW")
  
  costfactor = 1000 #this is the cost of increasing efficiency by 1%
  
  New_Eff <- filter(crop_mekong, year == 1 & HRU_ID == 1) %>% select(SB_ID, HRU_ID,Act_yield) %>% 
    left_join(sb_char) %>% 
    select(HRU_ID,SB_ID,Agent_ID,Act_yield,tar_kg.ha,SB_Area_ha,AreaFrac,Irri_TS,Irri_eff) %>%
    mutate(tar_yield = SB_Area_ha*AreaFrac*tar_kg.ha*(1/907.2)) %>% #convert target yield into tonnes from kg/ha 
    mutate(New_Irri_eff = ifelse(Act_yield < tar_yield,min(1,Irri_eff*1.1),Irri_eff)) %>% 
    mutate(AddEffCost = (New_Irri_eff-Irri_eff)*100*costfactor)

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
    
  ###############################
  #Upper level constraints
  #DoE
  #DoA
  #DoEnv
  
  
  ################################
  #Post-calculation for (From SWAT output) ecosystem services
  
  # calculate water availability for domestic use
  # calculate water availability for industrial use
  # ecosystem requirements
  
  ############################################################################################################################
  ############################################################################################################################
  # Loops through agents, subbasins, HRU's and reservoir
  ############################################################################################################################
  ############################################################################################################################
  
  for (a in aaa){#agent loop
    message<-paste("agent=",a)
    write(message,"")
    
    for (s in sss){#subbasin loop
      message<-paste("subbasin=",s)
      write(message,"")
      
    }#end subbasin
    

    
  }#end agent
  
  ############################################################################################################################
  ############################################################################################################################
  # Write ABM output (SWAT input) to data file
  ############################################################################################################################
  ############################################################################################################################
  
  irr_eff<-rep(0.8,376) #assign values to irrigation efficieny
  starg<-matrix(data = 99000,nrow=10, ncol=12) #target
  x<-cbind(starg,rep(15,10))
  
  # write new managment parameters to files
  write.table(irr_eff,file="Irr_eff_by_R.txt",col.names = F, row.names = F)
  write.table(x,file="Reservoir_by_R.txt", col.names = F, row.names = F) 
  
  file.create("SWAT_flag.txt")
  n<-n+1
}