library(tidyr)
library(dplyr)
library(magrittr)
library(lubridate)
library(zoo)

leapyears <- c(6,10,14,18,22,26)

yd <- data.frame(cal_day = 1:365, 
                 month = c(rep("January",31),rep("February",28),rep("March",31), rep("April",30),rep("May",31),rep("June",30),
                           rep("July",31),rep("August",31),rep("September",30),rep("October",31),rep("November",30),rep("December",31))
)

lyd <- data.frame(cal_day = 1:366, 
                  month = c(rep("January",31),rep("February",29),rep("March",31), rep("April",30),rep("May",31),rep("June",30),
                            rep("July",31),rep("August",31),rep("September",30),rep("October",31),rep("November",30),rep("December",31))
)

EC_SB <- read.csv("MK_Agent_Sub_basins_v6.csv") %>% rename(SB_ID = Subbasin) %>% 
  filter(Downstream_sub == 1) %>% .$SB_ID

###### Streamflow 
flow_mod <- read.table("Flow_all_subbasins.txt")
colnames(flow_mod)[1:ncol(flow_mod)] <- c("year","cal_day",paste0("Flow_SB_",1:(ncol(flow_mod)-2)))

SB_flowmod <- flow_mod %>% 
  tbl_df() %>%
  gather(key=Subbasin,value=Flow,-year,-cal_day) %>%
  mutate(SB_ID = extract_numeric(Subbasin)) %>%
  select(-Subbasin)

#########################################################
########### EFC CALCULATIONS  ###########################
#########################################################

#CALCULATE THE AVERAGE MONTHLY LOW-FLOWS FOR EACH SUBBASIN
EFC_DF <- NULL
lfm <- c("March","April","May")

for (y in 5:29){
  EFC_TDF <- filter(SB_flowmod, year == y)
  if (y %in% leapyears) {EcoDF <- left_join(EFC_TDF, lyd, by="cal_day")} else {EcoDF <- left_join(EFC_TDF, yd, by="cal_day")}
  EFC_DF <- bind_rows(EFC_DF, EcoDF)
}

LowFlows <- filter(EFC_DF, SB_ID %in% EC_SB & month %in% lfm) %>% 
  group_by(year,SB_ID, month) %>%
  summarise(LFM = min(Flow, na.rm=T)) %>% 
  group_by(SB_ID, month) %>%
  summarise(AveAnnLFM = mean(LFM))

Mar_LFM <- filter(LowFlows, month == "March") %>% select(SB_ID, Mar_AveAnnLF = AveAnnLFM) 
Apr_LFM <- filter(LowFlows, month == "April") %>% select(SB_ID, Apr_AveAnnLF = AveAnnLFM) 
May_LFM <- filter(LowFlows, month == "May") %>% select(SB_ID, May_AveAnnLF = AveAnnLFM) 

#CALCULATE THE AVERAGE HIGH FLOW THRESHOLD FOR EACH SUBBASIN
EFC_HF <- filter(SB_flowmod, SB_ID %in% EC_SB) %>% 
  group_by(year,SB_ID) %>% 
  summarise(HighFlow = quantile(Flow, probs=0.75)) %>% 
  group_by(SB_ID) %>% 
  summarise(AveHF = mean(HighFlow))

#CALCULATE THE AVERAGE SMALL FLOOD AND LARGE FLOOD THRESHOLDS FOR EACH SUBBASIN
EFC_FL <- filter(SB_flowmod, SB_ID %in% EC_SB) %>% 
  left_join(EFC_HF, by="SB_ID") %>% 
  filter(Flow > AveHF) %>% 
  group_by(SB_ID) %>% 
  summarise(SmFl = quantile(Flow, probs=0.5),LgFl = quantile(Flow, probs=0.9))

## THRESHOLDS COMBINED IN ONE DATAFRAME
FL_TH <- left_join(EFC_HF,EFC_FL) 

# CATEGORIZING ALL FLOWS
EFC_CL <- filter(SB_flowmod, SB_ID %in% EC_SB) %>% 
  left_join(FL_TH) %>% 
  mutate(HiFlo = ifelse(AveHF < Flow, ifelse(Flow < SmFl, 1, 0), 0),
         SmallFl = ifelse(SmFl < Flow, ifelse(Flow < LgFl, 1, 0), 0),
         LargeFl = ifelse(Flow > LgFl, 1,0))


# CALCULATING THE EFC TARGETS 

# AVERAGE ANNUAL DURATIONS FOR SMALL FLOODS, LARGE FLOODS AND HIGH FLOW PULSES 
ynd <- data.frame(year = 5:29, days = c(365, rep(c(366, 365, 365, 365), 6)))
ynd[,"End"] <- cumsum(ynd[,2]); ynd[,"Start"] <- lag(ynd[,3],1) ; ynd[1,4] <- 1
EFC_CL_dur <- mutate(EFC_CL, HiFlo_C = NA, SmallFl_C = NA, LargeFl_C = NA) %>% select(-AveHF:-LgFl) %>%  as.data.frame(EFC_CL)
z <-dim(EFC_CL_dur)[1] #gives the number of rows for the trick below
EFC_CL_dur[(z+1):(z+2),] <- EFC_CL_dur[z,] # repeating last two observations because of loop below

for (x in 5:7){ #for each flow type
  for (a in 1:length(EC_SB)){ # for each subbasin
    for(b in 1:dim(ynd)[1]){ # for each year
      start <- ynd[b,4]
      end <- ynd[b,3]
      counter <- 0
      for(c in start:end){ # for each day
        if(EFC_CL_dur[(9131*(a-1))+c + 2,x] == 1) {
          if(EFC_CL_dur[(9131*(a-1))+c +1,x] == 0 & EFC_CL_dur[(9131*(a-1))+c,x]==0){counter<- counter + 1}
          EFC_CL_dur[(9131*(a-1))+c +2,x+3] <- counter
        }
      }
    }
  }
}

# dur <- function(foo,cname){
#   gv1 <- list(~year,~SB_ID,~foo)
#   bar  <- group_by_(EFC_CL_dur, .dots = gv1) %>% summarise(Dur = n()) %>% filter(!is.na(foo)) #%>% 
#     # group_by_("SB_ID", year) %>% summarise(AvDur = mean(Dur)) %>% # average duration in each year
#     # group_by_("SB_ID") %>%  summarise(AvAnnDur = mean(AvDur)) %>% # average duration across all years
#     # rename(AvAnnDur = cname)
# 
#   return(bar)
# }
# 
# HF_DUR <- dur(HiFlo_C, AvAnnHFDur)

HF_DUR <- group_by(EFC_CL_dur, year, SB_ID, HiFlo_C) %>% summarise(Dur = n()) %>% filter(!is.na(HiFlo_C)) %>% 
  group_by(SB_ID, year) %>% summarise(AvDur = mean(Dur)) %>% # average duration in each year 
  group_by(SB_ID) %>%  summarise(AvAnnHFDur = mean(AvDur)) # average duration across all years

SF_DUR <- group_by(EFC_CL_dur, year, SB_ID, SmallFl_C) %>% summarise(Dur = n()) %>% filter(!is.na(SmallFl_C)) %>% 
  group_by(SB_ID, year) %>% summarise(AvDur = mean(Dur)) %>% # average duration in each year 
  group_by(SB_ID) %>%  summarise(AvAnnSFDur = mean(AvDur)) # average duration across all years

LF_DUR <- group_by(EFC_CL_dur, year, SB_ID, LargeFl_C) %>% summarise(Dur = n()) %>% filter(!is.na(LargeFl_C)) %>% 
  group_by(SB_ID, year) %>% summarise(AvDur = mean(Dur)) %>% # average duration in each year 
  group_by(SB_ID) %>%  summarise(AvAnnLFDur = mean(AvDur)) # average duration across all years

#SMALL FLOOD MEAN VALUE
SFMV <- filter(EFC_CL, HiFlo == 1) %>% group_by(SB_ID) %>% summarise(SmFlMeanVal = mean(Flow, na.rm=T))

# LARGE FLOOD JULIAN DATE
LFPK <- filter(EFC_CL, LargeFl == 1) %>% group_by(year,SB_ID) %>% top_n(Flow, n=1) %>% 
  group_by(SB_ID) %>% summarise(AvLFJD = round(mean(cal_day),digits=0))

# HIGH-FLOW PULSE PEAK VALUE AND JULIAN DATE
HFPK <- filter(EFC_CL, HiFlo == 1) %>% group_by(year, SB_ID) %>% top_n(Flow, n=1) %>% 
  group_by(SB_ID) %>% summarise(AvHFPK = mean(Flow), AvHFPKJD = round(mean(cal_day),digits=0))

AllEFCTargets <- Reduce(function(...) merge(..., all=TRUE), list(HFPK, HF_DUR, LFPK, LF_DUR, SFMV, SF_DUR, Mar_LFM, Apr_LFM, May_LFM))

#######################################################################################
### IHA TARGETS #######################################################################
#######################################################################################
IHA_DF <- NULL

for (y in 5:29){
  IHA_TDF <- filter(SB_flowmod, year == y)
  if (y %in% leapyears) {EcoDF <- left_join(IHA_TDF, lyd, by="cal_day")} else {EcoDF <- left_join(IHA_TDF, yd, by="cal_day")}
  IHA_DF <- bind_rows(IHA_DF, EcoDF)
}

IHA_month <- filter(IHA_DF, SB_ID %in% EC_SB) %>% 
  group_by(SB_ID,year,month) %>% 
  summarise(MonthlyTotal = sum(Flow)) %>% 
  group_by(SB_ID, month) %>% 
  summarise(AvAnMonTot = mean(MonthlyTotal)) %>% 
  spread(month,AvAnMonTot) %>% 
  select(one_of(c("SB_ID",month.name)))

IHA_FW <- filter(IHA_DF, SB_ID %in% EC_SB) %>% 
  group_by(SB_ID, year) %>% 
  mutate(Q7daysum = rollsumr(x=Flow,k=7,fill=NA),
         Q30daysum = rollsumr(x=Flow,k=30,fill=NA),
         Q90daysum = rollsumr(x=Flow,k=90,fill=NA)) %>%
  mutate(Q7daysum = ifelse(Q7daysum < 0, 0, Q7daysum),
         Q30daysum = ifelse(Q30daysum < 0, 0, Q30daysum),
         Q90daysum = ifelse(Q90daysum < 0, 0, Q90daysum)) %>% 
  group_by(SB_ID, year) %>% 
  summarise(Q7daymax = max(Q7daysum, na.rm=T),
            Q7daymin = min(Q7daysum, na.rm=T),
            Q30daymax = max(Q30daysum, na.rm=T),
            Q30daymin = min(Q30daysum, na.rm=T),
            Q90daymax = max(Q90daysum, na.rm=T)) %>% 
  group_by(SB_ID) %>% 
  summarise(AvQ7daymax = mean(Q7daymax, na.rm=T),
            AvQ7daymin = mean(Q7daymin, na.rm=T),
            AvQ30daymax = mean(Q30daymax, na.rm=T),
            AvQ30daymin = mean(Q30daymin, na.rm=T),
            AvQ90daymax = mean(Q90daymax, na.rm=T))
  
AllIHATargets <- left_join(IHA_FW,IHA_month)

#########################################################
#########################################################
#########################################################

AllEcoTargets <- left_join(AllEFCTargets, AllIHATargets) %>% 
  gather(key = TargetVar,value = TargetVal,-SB_ID)

save(FL_TH,AllEcoTargets,file = "C:/Users/Hassaan/Desktop/CGIAR_ABM_coding_HK/ABM_Mekong/SWAT4ABM_072616/AllEcoTargets.RData")


