library(tidyr)
library(dplyr)
library(magrittr)
library(lubridate)
library(zoo)


#Set working dir
setwd("D:\\WLE-Basin Tool\\Test\\1023_ABM_SWAT")

########################################################################################
#Survey weights for agriculture, hydropower, ecosystems & WEB USER INPUT
readweights <- read.csv("User_ESS.csv",stringsAsFactors=FALSE) %>% select(-LOC) %>% 
  gather(ESS, rank, -Agent_ID)

# Scenario: #we will need a file or something from web-user team that tells which scenario
#scenario<-"Historical" 
#scenario<-"Current" 
scenario<-"Future" 
if (scenario == "Historical") {
  selection <- c("Historical")} else if(scenario == "Current"){
    selection <- c("Historical","Current")} else if(scenario == "Future"){
      selection <- c("Historical","Current","Future")}

########################################################################################
##### Input Files ######
########################################################################################
agt_sb <- read.csv("MK_Agent_Sub_basins_v6.csv") %>% rename(SB_ID = Subbasin)
num_agt <- length(unique(agt_sb$Agent_ID))
ess <- c("AG","HP","ECO")
resnum <- 35

readhydpow <- read.csv("reservoir_data_for_ABM_v5.csv",stringsAsFactors=FALSE) %>% 
  tbl_df() %>% 
  select(Agent_ID, Reservoir, AveAnnEn_GWh = Mean.Annual.Energy..GWh., DayCap_GWh = Daily.Capacity..GWh.,Efficiency, a, b, c, Status) %>% 
  mutate(Reservoir = as.numeric(Reservoir))

dams <- filter(readhydpow, Status %in% selection) %>% .$Reservoir 

res_ini <- read.csv("Reservoirs_initial_v3.csv")[,-1] # res_ini <- read.table("Reservoir_initial.txt")
colnames(res_ini)[1:ncol(res_ini)] <- c("RS_ID","SB_ID","StartYear","StartMonth","ESA","EVOL","PSA","PVOL","VOL_IN",
                                        paste0("STARG_",1:12),"NDTARG",paste0("MXOUT_",1:12),paste0("MNOUT_",1:12))
res_ini %<>% mutate(StartYear = ifelse(RS_ID %in% dams, 1978, 2100))
write.table(res_ini,"Reservoir_initial.txt", col.names = F, row.names = F,quote=F)


# Crop, Hydropower and Ecosystem (IHA and EFC) targets 
load("HP_Crop_targets.RData")
load("AllEcoTargets.RData")

#Initial SWAT paramters for crops
crop_hru <- read.table("Crop_initial.txt")
colnames(crop_hru) <- c("SB_ID","HRU_ID","LandUse","AreaFrac","PlantDate","IrriHeat","Irri_TS","Irri_eff","Irri_minflow","CTCode")

Crop <- c("AGRL","IRRU","IRR1","IRR2","IRR3","RFR1","RFR2","RFR3")
NonCrop <- c("FRSE","RNGE","WETL")
IRR <- c("IRR1","IRR2","IRR3")

####### IHA AND EFC CALCULATION DATES
leapyears <- c(6,10,14,18,22,26)
yd <- data.frame(cal_day = 1:365, 
                 month = c(rep("January",31),rep("February",28),rep("March",31), rep("April",30),rep("May",31),rep("June",30),
                           rep("July",31),rep("August",31),rep("September",30),rep("October",31),rep("November",30),rep("December",31))
)
lyd <- data.frame(cal_day = 1:366, 
                  month = c(rep("January",31),rep("February",29),rep("March",31), rep("April",30),rep("May",31),rep("June",30),
                            rep("July",31),rep("August",31),rep("September",30),rep("October",31),rep("November",30),rep("December",31))
)
EC_SB <- filter(agt_sb, Downstream_sub == 1) %>% .$SB_ID

SB_ECOIND <- read.csv(file = "SBID_EcoIndicator.csv",na.strings = "") %>% gather(czz,TargetVar, -SB_ID,na.rm = T) %>% select(-czz)

AllEcoSummary <- NULL
lfm <- c("March","April","May")

##############################################################################
###  SWAT  ###################################################################
##############################################################################

file.create("SWAT_flag.txt")
system("swat2012_101916",wait=FALSE,invisible=FALSE)
n<-5 #SWAT reports simulation results from year 5 (1983) onwards, the first four years are for the model to "warm-up"

while(n<30) #SWAT simulation period: 25 years - this part returns back to ABM
{
  while (file.exists("SWAT_flag.txt"))
  {
  }

  #SWAT output variables (ABM input variables)
  
  #########################################################
  ####### Reservoir Storage AND RELEASE ################### 
  #########################################################
  
  reservoir_mekong <- read.table("Reservoir_by_SWAT.txt")
  colnames(reservoir_mekong)[1:ncol(reservoir_mekong)] <- c("year","cal_day",paste0("Volume_Res",1:resnum),paste0("Release_Res",1:resnum))
  
  ABM_reservoir <- reservoir_mekong %>% 
    tbl_df() %>% 
    filter(year == n) %>% 
    gather(key=Att,value=Variable,-year,-cal_day) %>%
    separate(col=Att,into=c("Attr","Reservoir"),sep="_") %>%
    spread(Attr, Variable) %>% 
    mutate(Reservoir = extract_numeric(Reservoir))
  
  ABM_HP <- filter(ABM_reservoir, Reservoir %in% dams) %>% 
    left_join(readhydpow, by="Reservoir") %>% 
    select(-AveAnnEn_GWh,-Status) %>% 
    mutate(Head = a*Volume^b+c,
           RawHP_Prod = (1000*9.81*Head*Release/1000000000)*(1/(24*60*60))*24*Efficiency,
           RawHP_Prod_cap = ifelse(RawHP_Prod > DayCap_GWh, DayCap_GWh, RawHP_Prod)) 
  
  ModAnnHP <- group_by(ABM_HP,Reservoir, Agent_ID) %>% 
    summarise(Mod_AnnHP = sum(RawHP_Prod_cap, na.rm=T))
  
  if(n==5){ndtarg <- rep(25,35)}
  
  #########################################################
  ####### Crops ###########################################
  #########################################################
  
  crop_mekong  <- read.table("Crop_by_SWAT.txt") %>% tbl_df()
  colnames(crop_mekong) <- c("year","SB_ID","HRU_ID","LandUse","Act_yield","IWW")
  crop_mekong_f <- filter(crop_mekong, year == n)  
  
  ModCP <- select(valreg, SB_ID:LandUse) %>%
    left_join(crop_mekong_f, by=c("SB_ID", "HRU_ID", "LandUse")) %>%
    left_join(agt_sb, by="SB_ID") %>%
    left_join(crop_hru, by=c("SB_ID", "HRU_ID", "LandUse")) %>%
    select(Agent_name,Agent_ID,SB_ID:IWW, SB_area, AreaFrac) %>%
    mutate(ModCropProd = Act_yield*SB_area*AreaFrac) %>%
    group_by(Agent_ID) %>%
    summarise(ModAgtProd = sum(ModCropProd))

  #########################################################
  ## IHA and EFC Calculations ###
  #########################################################
  ###### Streamflow
  flow_mekong <- read.table("Flow_by_SWAT.txt")
  colnames(flow_mekong)[1:ncol(flow_mekong)] <- c("year","cal_day",paste0("Flow_SB_",1:(ncol(flow_mekong)-2)))
  
  ABM_flow <- flow_mekong %>%
    tbl_df() %>%  
    filter(year == n) %>% 
    gather(key=Subbasin,value=Flow,-year,-cal_day) %>%
    mutate(SB_ID = extract_numeric(Subbasin)) %>%
    select(-Subbasin)
  
  if (n %in% leapyears) {EcoDF <- left_join(ABM_flow, lyd, by="cal_day")} else {EcoDF <- left_join(ABM_flow, yd, by="cal_day")}
  
  IHA_month <- filter(EcoDF, SB_ID %in% EC_SB) %>%
    group_by(SB_ID,month) %>%
    summarise(MonthlyMean = mean(Flow)) %>%
    spread(month,MonthlyMean) %>%
    select(one_of(c("SB_ID",month.name)))
  
  IHA_FW <- filter(EcoDF, SB_ID %in% EC_SB) %>%
    group_by(SB_ID) %>%
    mutate(Q7daysum = rollsumr(x=Flow,k=7,fill=NA),
           Q30daysum = rollsumr(x=Flow,k=30,fill=NA),
           Q90daysum = rollsumr(x=Flow,k=90,fill=NA)) %>%
    mutate(Q7daysum = ifelse(Q7daysum < 0, 0, Q7daysum),
           Q30daysum = ifelse(Q30daysum < 0, 0, Q30daysum),
           Q90daysum = ifelse(Q90daysum < 0, 0, Q90daysum)) %>%
    group_by(SB_ID) %>% summarise(AvQ7daymax = max(Q7daysum, na.rm=T),
                                  AvQ7daymin = min(Q7daysum, na.rm=T),
                                  AvQ30daymax = max(Q30daysum, na.rm=T),
                                  AvQ30daymin = min(Q30daysum, na.rm=T),
                                  AvQ90daymax = max(Q90daysum, na.rm=T))
  AllIHAmod <- left_join(IHA_FW,IHA_month)
  
  ########### EFC CALCULATIONS  ###########################
  
  #CALCULATE THE AVERAGE MONTHLY LOW-FLOWS FOR EACH SUBBASIN
  LowFlows <- filter(EcoDF, SB_ID %in% EC_SB & month %in% lfm) %>% 
    group_by(SB_ID, month) %>%
    summarise(LFM = min(Flow, na.rm=T)) 
  
  Mar_LFM <- filter(LowFlows, month == "March") %>% select(SB_ID, Mar_AveAnnLF = LFM) 
  Apr_LFM <- filter(LowFlows, month == "April") %>% select(SB_ID, Apr_AveAnnLF = LFM) 
  May_LFM <- filter(LowFlows, month == "May") %>% select(SB_ID, May_AveAnnLF = LFM) 

  # CATEGORIZING ALL FLOWS
  
  EFC_CL <- filter(ABM_flow, SB_ID %in% EC_SB) %>%
    left_join(FL_TH) %>%
    mutate(HiFlo = ifelse(AveHF < Flow, ifelse(Flow < SmFl, 1, 0), 0),
           SmallFl = ifelse(SmFl < Flow, ifelse(Flow < LgFl, 1, 0), 0),
           LargeFl = ifelse(Flow > LgFl, 1,0))
  
  #SMALL FLOOD MEAN VALUE
  SFMV <- filter(EFC_CL, HiFlo == 1) %>% group_by(SB_ID) %>% summarise(SmFlMeanVal = mean(Flow, na.rm=T))
  
  # LARGE FLOOD JULIAN DATE
  LFPK <- filter(EFC_CL, LargeFl == 1) %>% group_by(year,SB_ID) %>% top_n(Flow, n=1) %>%
    group_by(SB_ID) %>% summarise(AvLFJD = round(mean(cal_day),digits=0))
  
  # HIGH-FLOW PULSE PEAK VALUE AND JULIAN DATE
  HFPK <- filter(EFC_CL, HiFlo == 1) %>% group_by(year, SB_ID) %>% top_n(Flow, n=1) %>%
    group_by(SB_ID) %>% summarise(AvHFPK = mean(Flow), AvHFPKJD = round(mean(cal_day),digits=0))
  
  # AVERAGE ANNUAL DURATIONS FOR SMALL FLOODS, LARGE FLOODS AND HIGH FLOW PULSES
  ynd <- data.frame(year = 5:29, days = c(365, rep(c(366, 365, 365, 365), 6)))
  ynd[,"End"] <- cumsum(ynd[,2]); ynd[,"Start"] <- lag(ynd[,3],1) ; ynd[1,4] <- 1
  EFC_CL_dur <- mutate(EFC_CL, HiFlo_C = NA, SmallFl_C = NA, LargeFl_C = NA) %>% select(-AveHF:-LgFl) %>%  as.data.frame(EFC_CL)
  z <-dim(EFC_CL_dur)[1] #gives the number of rows for the trick below
  EFC_CL_dur[(z+1):(z+2),] <- EFC_CL_dur[z,] # repeating last two observations because of loop below
  
  if (n %in% leapyears) {end <- 366} else {end <- 365}
  for (x in 5:7){ #for each flow type
    for (a in 1:length(EC_SB)){ # for each subbasin
      counter <- 0
      for (c in 1:end){ # for each day
        if(EFC_CL_dur[(end*(a-1))+c + 2,x] == 1) {
          if(EFC_CL_dur[(end*(a-1))+c +1,x] == 0 & EFC_CL_dur[(end*(a-1))+c,x]==0){counter<- counter + 1}
          EFC_CL_dur[(end*(a-1))+c +2,x+3] <- counter
        }
      }
    }
  }
  
  HF_DUR <- group_by(EFC_CL_dur, SB_ID, HiFlo_C) %>% summarise(Dur = n()) %>% filter(!is.na(HiFlo_C)) %>%
    group_by(SB_ID) %>%  summarise(AvAnnHFDur = mean(Dur))
  SF_DUR <- group_by(EFC_CL_dur, year, SB_ID, SmallFl_C) %>% summarise(Dur = n()) %>% filter(!is.na(SmallFl_C)) %>%
    group_by(SB_ID) %>%  summarise(AvAnnSFDur = mean(Dur))
  LF_DUR <- group_by(EFC_CL_dur, year, SB_ID, LargeFl_C) %>% summarise(Dur = n()) %>% filter(!is.na(LargeFl_C)) %>%
    group_by(SB_ID) %>%  summarise(AvAnnLFDur = mean(Dur))
  
  AllEcoMod <- Reduce(function(...) merge(..., all=TRUE), list(HFPK, HF_DUR, LFPK, LF_DUR, SFMV, SF_DUR, Mar_LFM, Apr_LFM, May_LFM)) %>%
    left_join(AllIHAmod) %>% gather(TargetVar,ModVal,-SB_ID)
  
  AllEcoMod_f <- left_join(SB_ECOIND, AllEcoMod, by=c("SB_ID","TargetVar"))

  #############################################################################
  ######################### DECISIONS #########################################
  #############################################################################
  Need_ECO <- data.frame(Agent_ID = 1:12, ESS = "ECO", Need = 0)
  Need_HP <- data.frame(Agent_ID = 1:12, ESS = "HP", Need = 0)
  Need_AG <- data.frame(Agent_ID = 1:12, ESS = "AG", Need = 0)
  
  ## DETERMINING AGRICULTURE SHORTAGES
  AgCheck <- left_join(ModCP, Targ_irri_crop) %>%
    mutate(Flag = ifelse(ModAgtProd < 0.9*TargAgtCP,1,0)) %>%
    as.data.frame()
  for (c in 1:dim(AgCheck)[1]){if(AgCheck[c,5]>0) {Need_AG[c,3] <- 1}}
  
  ## DETERMINING HYDROPOWER SHORTAGES
  HPcheck <- left_join(ModAnnHP, TargAnnHP, by="Reservoir") %>%
    mutate(Flag = ifelse(Mod_AnnHP < 0.9*Targ_AnnAveHP,1,0)) %>%
    as.data.frame()
  for (q in 1:dim(HPcheck)[1]){
    hp_id <- HPcheck[q,2]
    if(HPcheck[q,6]>0) {Need_HP[Need_HP$Agent_ID == hp_id,3] <- 1}
  }
  
  ## DETERMINING ECO VIOLATIONS
  ## CHECKING WHICH ECO PARAMETERS ARE VIOLATED
  
  ECK <- left_join(AllEcoMod_f, AllEcoTargets,  by=c("SB_ID","TargetVar")) %>%
    mutate(Flag = ifelse(ModVal > 1.5*TargetVal, 1, ifelse(ModVal < 0.5 * TargetVal, 1, 0))) %>%
    mutate(Flag = ifelse(is.na(Flag),1,Flag)) # if a eco parameter is NA, it is counted as a violation
  
  EcoCheck <- group_by(ECK,SB_ID) %>% summarise(TotFlag = sum(Flag, na.rm=T),FlagRatio = mean(Flag, na.rm=T))
  
  EcoReport <- group_by(ECK,SB_ID, Flag) %>% 
    summarise(TotCounts = n()) %>% 
    mutate(FlagType = ifelse(Flag == 0, "Satisfied","Violated")) %>% 
    select(-Flag) %>%  
    spread(FlagType, TotCounts,fill = 0) 
    
  hotspot_agent <- left_join(EcoCheck, agt_sb, by="SB_ID") %>%
    select(SB_ID,Agent_ID,Agent_name,FlagRatio) %>%
    group_by(Agent_ID,Agent_name) %>%
    summarise(AgentFlagRatio = mean(FlagRatio),
              TotHS = n()) %>%
    as.data.frame()
  
  for (e in 1:dim(hotspot_agent)[1]){
    a_id <- hotspot_agent[e,1]
    if(hotspot_agent[e,3]>0.5) {Need_ECO[Need_ECO$Agent_ID == a_id,3] <- 1}
  }
  #########################  ACTUAL DECISION MAKING LOOP ######################
  if(n == 5){foo <- crop_hru} else {foo <- mutate(crop_hru,AreaFrac = hru_fr_k)}
  
  AllNeeds <- bind_rows(Need_AG,Need_ECO,Need_HP)
  
  # Decision Table
  DT <- select(readweights, Agent_ID, ESS, PRI = rank) %>%
    left_join(AllNeeds, by=c("Agent_ID","ESS")) %>% as.data.frame()
  
  Allnew_sbhru <- NULL
  
  for (agt in 1:num_agt){
    AG_pri <- filter(DT,Agent_ID == agt & ESS=="AG") %>% .$PRI; AG_need <- filter(DT,Agent_ID == agt & ESS=="AG") %>% .$Need
    HP_pri <- filter(DT,Agent_ID == agt & ESS=="HP") %>% .$PRI; HP_need <- filter(DT,Agent_ID == agt & ESS=="HP") %>% .$Need
    ECO_pri <- filter(DT,Agent_ID == agt & ESS=="ECO") %>% .$PRI; ECO_need <- filter(DT,Agent_ID == agt & ESS=="ECO") %>% .$Need
    
    ######################################
    # CASE # 1
    ######################################
    
    if(AG_pri == 1){
      if(AG_need == 1){
        # Increase irrigated crop area
        agtsb_AG <- select(foo,SB_ID,HRU_ID,LandUse,AreaFrac) %>%
          left_join(agt_sb, by="SB_ID") %>%
          select(Agent_ID,SB_ID:AreaFrac) %>%
          filter(Agent_ID == agt) %>%
          left_join(valreg, by=c("SB_ID", "HRU_ID", "LandUse")) %>%
          select(-ncropseas:-aveirriww,-CTCode,-HRU_area) %>%
          mutate(FlagRel = ifelse(is.na(FlagRel),0,FlagRel))
        sbz <- unique(agtsb_AG$SB_ID)
        for (sbn in 1:length(sbz)){
          sb_AG <- filter(agtsb_AG, SB_ID==sbz[sbn])
          old_AF <- sb_AG$AreaFrac
          irrhru <- sb_AG$LandUse %in% IRR & sb_AG$FlagRel == 1
          old_IRR_area <- sum(filter(sb_AG, FlagRel == 1 & LandUse %in% IRR) %>% .$AreaFrac)
          if(old_IRR_area > 0 & old_IRR_area < 0.909){
            new_AF <- old_AF
            new_AF[irrhru] <- old_AF[irrhru]*1.1
            new_AF[!irrhru] <- old_AF[!irrhru]*((1-(old_IRR_area*1.1))/(1-old_IRR_area))
            sb_AG  %<>%  mutate(NewAreaFrac = new_AF) %>% select(-FlagRel,-AreaFrac)
          } else {
            sb_AG %<>%  mutate(NewAreaFrac = AreaFrac) %>% select(-FlagRel,-AreaFrac)
          }
          Allnew_sbhru <- rbind(Allnew_sbhru,sb_AG)
        }
      } else if (HP_need == 1){
        # Decrease days needed to satisfy target storage
        AgentRV_HP <- filter(HPcheck,Agent_ID == agt)
        for (rv in 1:dim(AgentRV_HP)[1]){
          if (AgentRV_HP[rv,6] == 1){
            RV <- AgentRV_HP[rv,1]
            ndtarg[RV] <- max(ndtarg[RV] - 1,20) # Decrease target storage by 1 day- lower limit is 20 days
          }
        }
        # THIS CODE BELOW DOES NO NEW CALCULATION FOR AREA FRACTION, JUST MAKES THE NEW SUBBASIN HRU FRACTION FILE
        ANS_x <- select(foo,SB_ID,HRU_ID,LandUse,AreaFrac) %>%
          left_join(agt_sb, by="SB_ID") %>%
          select(Agent_ID,SB_ID:AreaFrac) %>% 
          mutate(NewAreaFrac = AreaFrac) %>% select(-AreaFrac) %>% 
          filter(Agent_ID == agt) 
        
        Allnew_sbhru <- rbind(Allnew_sbhru,ANS_x)
      } else if (AG_need== 0){

        # THIS CODE BELOW DOES NO NEW CALCULATION FOR AREA FRACTION, JUST MAKES THE NEW SUBBASIN HRU FRACTION FILE
        ANS_x <- select(foo,SB_ID,HRU_ID,LandUse,AreaFrac) %>%
          left_join(agt_sb, by="SB_ID") %>%
          select(Agent_ID,SB_ID:AreaFrac) %>% 
          mutate(NewAreaFrac = AreaFrac) %>% select(-AreaFrac) %>% 
          filter(Agent_ID == agt) 
        
        Allnew_sbhru <- rbind(Allnew_sbhru,ANS_x)
      }
      
    }
    
    ######################################
    # CASE #2
    ######################################
    
    if (HP_pri == 1){
      if(HP_need == 1){
        # Decrease days needed to satisfy target storage
        AgentRV_HP <- filter(HPcheck,Agent_ID == agt)
        for (rv in 1:dim(AgentRV_HP)[1]){
          if (AgentRV_HP[rv,6] == 1){
            RV <- AgentRV_HP[rv,1]
            ndtarg[RV] <- max(ndtarg[RV] - 1,20) # Decrease target storage by 1 day- lower limit is 20 days
          }
        }
        # THIS CODE BELOW DOES NO NEW CALCULATION FOR AREA FRACTION, JUST MAKES THE NEW SUBBASIN HRU FRACTION FILE
        ANS_x <- select(foo,SB_ID,HRU_ID,LandUse,AreaFrac) %>%
          left_join(agt_sb, by="SB_ID") %>%
          select(Agent_ID,SB_ID:AreaFrac) %>% 
          mutate(NewAreaFrac = AreaFrac) %>% select(-AreaFrac) %>% 
          filter(Agent_ID == agt) 
        
        Allnew_sbhru <- rbind(Allnew_sbhru,ANS_x)
        
      } else if (AG_need == 1){
        # Increase irrigated crop area
        agtsb_AG <- select(foo,SB_ID,HRU_ID,LandUse,AreaFrac) %>%
          left_join(agt_sb, by="SB_ID") %>%
          select(Agent_ID,SB_ID:AreaFrac) %>%
          filter(Agent_ID == agt) %>%
          left_join(valreg, by=c("SB_ID", "HRU_ID", "LandUse")) %>%
          select(-ncropseas:-aveirriww,-CTCode,-HRU_area) %>%
          mutate(FlagRel = ifelse(is.na(FlagRel),0,FlagRel))
        sbz <- unique(agtsb_AG$SB_ID)
        for (sbn in 1:length(sbz)){
          sb_AG <- filter(agtsb_AG, SB_ID==sbz[sbn])
          old_AF <- sb_AG$AreaFrac
          irrhru <- sb_AG$LandUse %in% IRR & sb_AG$FlagRel == 1
          old_IRR_area <- sum(filter(sb_AG, FlagRel == 1 & LandUse %in% IRR) %>% .$AreaFrac)
          if(old_IRR_area > 0 & old_IRR_area < 0.909){
            new_AF <- old_AF
            new_AF[irrhru] <- old_AF[irrhru]*1.1
            new_AF[!irrhru] <- old_AF[!irrhru]*((1-(old_IRR_area*1.1))/(1-old_IRR_area))
            sb_AG  %<>%  mutate(NewAreaFrac = new_AF) %>% select(-FlagRel,-AreaFrac)
          } else {
            sb_AG %<>%  mutate(NewAreaFrac = AreaFrac) %>% select(-FlagRel,-AreaFrac)
          }
          Allnew_sbhru <- rbind(Allnew_sbhru,sb_AG)
        }
      } else if (AG_need== 0){
        
        # THIS CODE BELOW DOES NO NEW CALCULATION FOR AREA FRACTION, JUST MAKES THE NEW SUBBASIN HRU FRACTION FILE
        ANS_x <- select(foo,SB_ID,HRU_ID,LandUse,AreaFrac) %>%
          left_join(agt_sb, by="SB_ID") %>%
          select(Agent_ID,SB_ID:AreaFrac) %>% 
          mutate(NewAreaFrac = AreaFrac) %>% select(-AreaFrac) %>% 
          filter(Agent_ID == agt) 
        
        Allnew_sbhru <- rbind(Allnew_sbhru,ANS_x)
      }
      
    }
    
    ######################################
    # CASE  3 ######
    ######################################
    
    if(ECO_pri == 1){
      if (ECO_need == 1){
      ANS_x <- select(foo,SB_ID,HRU_ID,LandUse,AreaFrac) %>%
        left_join(agt_sb, by="SB_ID") %>%
        select(Agent_ID,SB_ID:AreaFrac) %>% 
        mutate(NewAreaFrac = AreaFrac) %>% select(-AreaFrac) %>% 
        filter(Agent_ID == agt) 
      
      Allnew_sbhru <- rbind(Allnew_sbhru,ANS_x)
      
    } else {
      if(HP_pri == 2){
        if(HP_need == 1){
          # Decrease days needed to satisfy target storage
          AgentRV_HP <- filter(HPcheck,Agent_ID == agt)
          for (rv in 1:dim(AgentRV_HP)[1]){
            if (AgentRV_HP[rv,6] == 1){
              RV <- AgentRV_HP[rv,1]
              ndtarg[RV] <- max(ndtarg[RV] - 1,20) # Decrease target storage by 1 day- lower limit is 20 days
            }
          }
          
          # THIS CODE BELOW DOES NO NEW CALCULATION FOR AREA FRACTION, JUST MAKES THE NEW SUBBASIN HRU FRACTION FILE
          ANS_x <- select(foo,SB_ID,HRU_ID,LandUse,AreaFrac) %>%
            left_join(agt_sb, by="SB_ID") %>%
            select(Agent_ID,SB_ID:AreaFrac) %>% 
            mutate(NewAreaFrac = AreaFrac) %>% select(-AreaFrac) %>% 
            filter(Agent_ID == agt) 
          
          Allnew_sbhru <- rbind(Allnew_sbhru,ANS_x)
          
        } else if (AG_need == 1){
          # Increase irrigated crop area
          agtsb_AG <- select(foo,SB_ID,HRU_ID,LandUse,AreaFrac) %>%
            left_join(agt_sb, by="SB_ID") %>%
            select(Agent_ID,SB_ID:AreaFrac) %>%
            filter(Agent_ID == agt) %>%
            left_join(valreg, by=c("SB_ID", "HRU_ID", "LandUse")) %>%
            select(-ncropseas:-aveirriww,-CTCode,-HRU_area) %>%
            mutate(FlagRel = ifelse(is.na(FlagRel),0,FlagRel))
          sbz <- unique(agtsb_AG$SB_ID)
          for (sbn in 1:length(sbz)){
            sb_AG <- filter(agtsb_AG, SB_ID==sbz[sbn])
            old_AF <- sb_AG$AreaFrac
            irrhru <- sb_AG$LandUse %in% IRR & sb_AG$FlagRel == 1
            old_IRR_area <- sum(filter(sb_AG, FlagRel == 1 & LandUse %in% IRR) %>% .$AreaFrac)
            if(old_IRR_area > 0 & old_IRR_area < 0.909){
              new_AF <- old_AF
              new_AF[irrhru] <- old_AF[irrhru]*1.1
              new_AF[!irrhru] <- old_AF[!irrhru]*((1-(old_IRR_area*1.1))/(1-old_IRR_area))
              sb_AG  %<>%  mutate(NewAreaFrac = new_AF) %>% select(-FlagRel,-AreaFrac)
            } else {
              sb_AG %<>%  mutate(NewAreaFrac = AreaFrac) %>% select(-FlagRel,-AreaFrac)
            }
            Allnew_sbhru <- rbind(Allnew_sbhru,sb_AG)
          }
        } else if (AG_need== 0){
          
          # THIS CODE BELOW DOES NO NEW CALCULATION FOR AREA FRACTION, JUST MAKES THE NEW SUBBASIN HRU FRACTION FILE
          ANS_x <- select(foo,SB_ID,HRU_ID,LandUse,AreaFrac) %>%
            left_join(agt_sb, by="SB_ID") %>%
            select(Agent_ID,SB_ID:AreaFrac) %>% 
            mutate(NewAreaFrac = AreaFrac) %>% select(-AreaFrac) %>% 
            filter(Agent_ID == agt) 
          
          Allnew_sbhru <- rbind(Allnew_sbhru,ANS_x)
        }
        
      }
      if(AG_pri == 2){
        if(AG_need == 1){
          # Increase irrigated crop area
          agtsb_AG <- select(foo,SB_ID,HRU_ID,LandUse,AreaFrac) %>%
            left_join(agt_sb, by="SB_ID") %>%
            select(Agent_ID,SB_ID:AreaFrac) %>%
            filter(Agent_ID == agt) %>%
            left_join(valreg, by=c("SB_ID", "HRU_ID", "LandUse")) %>%
            select(-ncropseas:-aveirriww,-CTCode,-HRU_area) %>%
            mutate(FlagRel = ifelse(is.na(FlagRel),0,FlagRel))
          sbz <- unique(agtsb_AG$SB_ID)
          for (sbn in 1:length(sbz)){
            sb_AG <- filter(agtsb_AG, SB_ID==sbz[sbn])
            old_AF <- sb_AG$AreaFrac
            irrhru <- sb_AG$LandUse %in% IRR & sb_AG$FlagRel == 1
            old_IRR_area <- sum(filter(sb_AG, FlagRel == 1 & LandUse %in% IRR) %>% .$AreaFrac)
            if(old_IRR_area > 0 & old_IRR_area < 0.909){
              new_AF <- old_AF
              new_AF[irrhru] <- old_AF[irrhru]*1.1
              new_AF[!irrhru] <- old_AF[!irrhru]*((1-(old_IRR_area*1.1))/(1-old_IRR_area))
              sb_AG  %<>%  mutate(NewAreaFrac = new_AF) %>% select(-FlagRel,-AreaFrac)
            } else {
              sb_AG %<>%  mutate(NewAreaFrac = AreaFrac) %>% select(-FlagRel,-AreaFrac)
            }
            Allnew_sbhru <- rbind(Allnew_sbhru,sb_AG)
          }
        } else if (HP_need == 1){
          # Decrease days needed to satisfy target storage
          AgentRV_HP <- filter(HPcheck,Agent_ID == agt)
          for (rv in 1:dim(AgentRV_HP)[1]){
            if (AgentRV_HP[rv,6] == 1){
              RV <- AgentRV_HP[rv,1]
              ndtarg[RV] <- max(ndtarg[RV] - 1,20) # Decrease target storage by 1 day- lower limit is 20 days
            }
          }
          
          # THIS CODE BELOW DOES NO NEW CALCULATION FOR AREA FRACTION, JUST MAKES THE NEW SUBBASIN HRU FRACTION FILE
          ANS_x <- select(foo,SB_ID,HRU_ID,LandUse,AreaFrac) %>%
            left_join(agt_sb, by="SB_ID") %>%
            select(Agent_ID,SB_ID:AreaFrac) %>% 
            mutate(NewAreaFrac = AreaFrac) %>% select(-AreaFrac) %>% 
            filter(Agent_ID == agt) 
          
          Allnew_sbhru <- rbind(Allnew_sbhru,ANS_x)
          
        } else if (AG_need== 0){
          
          # THIS CODE BELOW DOES NO NEW CALCULATION FOR AREA FRACTION, JUST MAKES THE NEW SUBBASIN HRU FRACTION FILE
          ANS_x <- select(foo,SB_ID,HRU_ID,LandUse,AreaFrac) %>%
            left_join(agt_sb, by="SB_ID") %>%
            select(Agent_ID,SB_ID:AreaFrac) %>% 
            mutate(NewAreaFrac = AreaFrac) %>% select(-AreaFrac) %>% 
            filter(Agent_ID == agt) 
          
          Allnew_sbhru <- rbind(Allnew_sbhru,ANS_x)
        }
      }
    }
      
    } # END OF CASE 3 LOOP 
  } # END OF AGENT DECISION MAKING LOOP

  #########################################################################
  #########################################################################

  hru_fr_k <- left_join(crop_hru, Allnew_sbhru, by = c("SB_ID", "HRU_ID", "LandUse")) %>%.$NewAreaFrac
  
  HRU_FR_ABM <- left_join(crop_hru,Allnew_sbhru, by = c("SB_ID", "HRU_ID", "LandUse")) %>% 
    mutate(NewAreaFrac = ifelse(LandUse %in% NonCrop,-99,NewAreaFrac)) %>% 
    .$NewAreaFrac
  
  #IRR_eff_by_R is already constructed
  IRR_ABM <- crop_hru[,c("Irri_eff","Irri_minflow")]
  
  flag <- rep(0,35);flag[dams] <- 1
  EndYearStor <- filter(ABM_reservoir, cal_day == 365) %>% select(Reservoir, Volume) %>% arrange(Reservoir) %>% .$Volume
  RES_ABM <- mutate(res_ini, 
                    Flag = flag,
                    NDTARG = ndtarg,
                    VOL_IN = EndYearStor) %>% 
    select(Flag, ESA, EVOL, PSA, PVOL, VOL_IN, NDTARG,STARG_1:STARG_12, MXOUT_1:MNOUT_12)

  
  # test1 <- group_by(Allnew_sbhru, SB_ID) %>% summarise(TotArea = sum(NewAreaFrac)) # DIAGNOSTICS

  write.table(IRR_ABM,file="IRR_eff_by_ABM.txt",col.names = F, row.names = F)
  write.table(RES_ABM,file="Reservoir_by_ABM.txt", col.names = F, row.names = F) 
  write.table(HRU_FR_ABM,file="HRU_FR_by_ABM.txt", col.names = F, row.names = F)
  
  eco_summary <- left_join(EcoReport, agt_sb, by="SB_ID") %>%
    mutate(Year = n) %>% 
    select(Year, Agent_ID,Hotspot_name,Satisfied, Violated) %>%
    arrange(Agent_ID) 
  
  AllEcoSummary <- rbind(AllEcoSummary,eco_summary)

  ################################################################
  
  #save decision variables: combines all years of simulation (by append) 
  
  HRU_FR_save <- cbind(n,HRU_FR_ABM)
  RES_ABM_save <- cbind(n,RES_ABM)
  IRR_ABM_save <- cbind(n,IRR_ABM)
  
  write.table(IRR_ABM_save,file="save_Irr_eff_by_R.txt",col.names = F, row.names = F, append =T)
  write.table(RES_ABM_save,file="save_Reservoir_by_R.txt", col.names = F, row.names = F, append =T) 
  write.table(HRU_FR_save,file="save_HRU_FR_by_R.txt", col.names = F, row.names = F, append =T) 

  if (n==29){#for last year of the simulation make and write out summary info
    
    ##### CROP OUTPUT ###########################################

    cropmekong_x <- select(crop_mekong, -IWW) %>% mutate(year = paste0("Year_",year)) %>% spread(year,Act_yield)
    
    crop_summary <- select(valreg, SB_ID:LandUse) %>%
      left_join(cropmekong_x, by=c("SB_ID", "HRU_ID", "LandUse")) %>%
      left_join(agt_sb, by="SB_ID") %>%
      select(Agent_ID, SB_ID, HRU_ID,Year_10:Year_9) %>% 
      gather(key = year,IRRI_Yield, Year_10:Year_9, -Agent_ID, -SB_ID, -HRU_ID) %>% 
      mutate(year = extract_numeric(year)) %>% 
      arrange(year) %>% 
      group_by(year, Agent_ID, SB_ID) %>% 
      summarise(IRR_Yield_tons = sum(IRRI_Yield))


    ##### HYDROPOWER OUTPUT ###########################################

    hp_summary <- reservoir_mekong %>% 
      tbl_df() %>% 
      gather(key=Att,value=Variable,-year,-cal_day) %>%
      separate(col=Att,into=c("Attr","Reservoir"),sep="_") %>%
      spread(Attr, Variable) %>% 
      mutate(Reservoir = extract_numeric(Reservoir)) %>% 
      filter(Reservoir %in% dams) %>% 
      left_join(readhydpow, by="Reservoir") %>% 
      select(-AveAnnEn_GWh,-Status) %>% 
      mutate(Head = a*Volume^b+c,
             RawHP_Prod = (1000*9.81*Head*Release/1000000000)*(1/(24*60*60))*24*Efficiency,
             RawHP_Prod_cap = ifelse(RawHP_Prod > DayCap_GWh, DayCap_GWh, RawHP_Prod)) %>% 
      group_by(year, Agent_ID, Reservoir) %>% 
      summarise(Annual_HP_GWh = sum(RawHP_Prod_cap, na.rm=T))
    
    ###########################################################################
    write.csv(crop_summary, file = "crop_summary.csv",row.names = FALSE)
    write.csv(AllEcoSummary, file = "eco_summary.csv",row.names = FALSE)
    write.csv(hp_summary, file = "hydropower_summary.csv",row.names = FALSE)
    ##########################################################################
  }
  
  file.create("SWAT_flag.txt")
  n<-n+1

} # END OF SWAT WHILE LOOP



