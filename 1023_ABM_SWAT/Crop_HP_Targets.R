library(tidyr)
library(dplyr)
library(magrittr)

#data needed for hydropower calculation
readhydpow <- read.csv("reservoir_data_for_ABM_v5.csv",stringsAsFactors=FALSE) %>% 
  tbl_df() %>% 
  select(Reservoir, AveAnnEn_GWh = Mean.Annual.Energy..GWh., DayCap_GWh = Daily.Capacity..GWh.,Efficiency, a, b, c, Status) %>% 
  mutate(Reservoir = as.numeric(Reservoir))


####### Reservoir Storage and outflow FOR NON-COMMUNICATION MODE SWAT
resstore_mekong <- read.table("reservoir_storage.txt")
colnames(resstore_mekong)[1:ncol(resstore_mekong)] <- c("year","cal_day",paste0("Volume_Res",1:(ncol(resstore_mekong)-2)))  

resstore_mekong %<>% tbl_df() %>% 
  gather(key=Att,value=Volume,-year,-cal_day) %>%
  separate(col=Att,into=c("Attr","Reservoir"),sep="_") %>%
  mutate(Reservoir = extract_numeric(Reservoir)) %>% 
  select(-Attr)

resrel_mekong <- read.table("reservoir_release.txt")
colnames(resrel_mekong)[1:ncol(resrel_mekong)] <- c("year","cal_day",paste0("Outflow_Res",1:(ncol(resrel_mekong)-2)))   

resrel_mekong %<>% tbl_df() %>% 
  gather(key=Att,value=Release,-year,-cal_day) %>%
  separate(col=Att,into=c("Attr","Reservoir"),sep="_") %>%
  mutate(Reservoir = extract_numeric(Reservoir)) %>% 
  select(-Attr)

#hydpow is using equation: = u*rho*g*H*Q/1,000,000,000 for GW (kgm^2/s^3*10^9) then *24 to GWh
#Q in m^3/s and H in m, rho 1000kg/m^3; we convert modeled Q from m3/day to m3/sec
#u = efficiency (in general 0.8) but taken from data if exists
ModDailyHP <- left_join(resstore_mekong,resrel_mekong,by=c("year","cal_day","Reservoir")) %>% 
  # filter(Reservoir %in% c(2,14,21,29,31)) %>% 
  left_join(readhydpow, by="Reservoir") %>% 
  select(-AveAnnEn_GWh,-Status) %>% 
  mutate(Head = a*Volume^b+c,
         RawHP_Prod = (1000*9.81*Head*Release/1000000000)*(1/(24*60*60))*24*Efficiency,
         RawHP_Prod_cap = ifelse(RawHP_Prod > DayCap_GWh, DayCap_GWh, RawHP_Prod)) 

TargAnnHP <- group_by(ModDailyHP,Reservoir, year) %>% 
  summarise(Mod_AnnHP = sum(RawHP_Prod_cap, na.rm=T)) %>%
  mutate(Mod_AnnHP = ifelse(Mod_AnnHP == 0, NA_real_,  Mod_AnnHP)) %>% 
  group_by(Reservoir) %>% 
  summarise(Targ_AnnAveHP = mean(Mod_AnnHP, na.rm=T)) %>% 
  left_join(readhydpow, by="Reservoir") %>% 
  select(-DayCap_GWh:-Status) %>% 
  mutate(Targ_AnnAveHP = ifelse(is.na(Targ_AnnAveHP), AveAnnEn_GWh,  Targ_AnnAveHP))

################################
########## CROP TARGETS ########
################################
ag_sb <- read.csv("MK_Agent_Sub_basins_v5.csv") %>% select(Agent_ID,Agent_name,SB_ID = Subbasin)

#Initial SWAT paramters for crops
crop_hru <- read.table("Crop_initial.txt")
colnames(crop_hru) <- c("SB_ID","HRU_ID","LandUse","AreaFrac","PlantDate","IrriHeat","Irri_TS","Irri_eff","Irri_minflow","CTCode")

modcrop <- read.table("Results_summary_crop.txt",stringsAsFactors=FALSE)
colnames(modcrop) <- c("SB_ID","HRU_ID","LandUse","ncropseas","avelencropseas","avecropyield",
                   "aveirriww","FlagRel","CTCode","HRU_area")

irrihru <- c("IRR1","IRR2","IRR3")
valreg <- filter(modcrop, LandUse %in% irrihru & FlagRel == 1) 

Targ_irri_crop <- mutate(valreg,crop_prod = avecropyield*HRU_area) %>% #crop yield converted to production
  left_join(ag_sb, by="SB_ID") %>% 
  group_by(Agent_ID, Agent_name) %>% 
  summarise(TargAgtCP = sum(crop_prod)) #average annual crop production in tonnes/year

save(valreg,TargAnnHP,Targ_irri_crop, file="C:/Users/Hassaan/Desktop/CGIAR_ABM_coding_HK/ABM_Mekong/SWAT4ABM_072616/HP_Crop_targets.RData")



