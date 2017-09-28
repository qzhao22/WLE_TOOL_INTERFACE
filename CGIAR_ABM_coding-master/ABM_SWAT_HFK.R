llooo
library(tidyr)
library(dplyr)
library(magrittr)
library(gdata)


file.create("SWAT_flag.txt")
system("swat2012.exe",wait=FALSE,invisible=FALSE)
n<-1

while(n<22) #SWAT simulation period: 22 years
{
  while (file.exists("SWAT_flag.txt"))
  {
  }
  
  ###################################################################################
  #ABM output variables initialization (SWAT input variables)
  #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  nosb<-47;nohru<-376;nores<-10;#number of subbasins, hru's, reservoirs
  
  initcrops<-read.table("Crop_initial.txt",header = FALSE, sep = "")
  colnames(initcrops) <- c("SB_ID","HRU_ID","Area","PlantDate","PotIrri","Irri_TS","Irri_eff")
  irice_area <- initcrops[,3][seq(1, length(initcrops[,3]), 8)]
  rrice_area <- initcrops[,3][seq(2, length(initcrops[,3]), 8)]
  iupl_area <- initcrops[,3][seq(3, length(initcrops[,3]), 8)]
  rupl_area <- initcrops[,3][seq(4, length(initcrops[,3]), 8)]
  forest_area <- initcrops[,3][seq(5, length(initcrops[,3]), 8)]
  grass_area <- initcrops[,3][seq(6, length(initcrops[,3]), 8)]
  urban_area <- initcrops[,3][seq(7, length(initcrops[,3]), 8)]
  wetland_area <- initcrops[,3][seq(8, length(initcrops[,3]), 8)]
  
  #for now all hru's are initialized with same irr_eff and all reservoirs with the same starg and ndtargr so no need to extract data
  res_ini <- read.csv(file="Reservoir_initial.txt")
  irr_eff<-vector(,nohru) 
  irr_eff[]<-0.5
  starg<-matrix(nrow=nores, ncol=12)
  starg[]<-99000
  ndtargr<-vector(,nores)
  ndtargr[]<-15
  
  
  #######################################################################################################
  #SWAT output variables (ABM input variables)
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
  
  ####### Crop yield
  crop_mekong  <- read.table("Crop_Mekong.txt")
  colnames(crop_mekong) <- c("year","SB_ID","HRU_ID","yield","IWW")
  
  ###############################
  #Upper level constraints
  #DoE
  #DoA
  #DoEnv
  
  #min_cy: this will be a dataframe that provides a minimum constraint on crop yield for each HRU where there is cropping
  #min_cprod: this will be a dataframe that provides a minimum constraint on crop production for each HRU where there is cropping
  #min_hydpow: this will be a dataframe that provides a minimum constraint on hydropower for each reservoir
  
  ################################
  #Post-calculation for (From SWAT output) ecosystem services
  
  # calculate water availability for domestic use
  # calculate water availability for industrial use
  # ecosystem requirements
  
  ############################################################################################################################
  ############################################################################################################################
  # Loops through agents, subbasins, HRU's and reservoir and ecosystem
  ############################################################################################################################
  ############################################################################################################################
  
  #number of agents
  aaa<-1:12
  
  #number of subbasin in each agent
  ss<-rep(0,12);ss[1]<-9;ss[2]<-2;ss[3]<-1;ss[4]<-6;ss[5]<-1;ss[6]<-6;ss[7]<-3;ss[8]<-5;ss[9]<-6;ss[10]<-2;ss[11]<-3;ss[12]<-3;
  
  #number of reseviors in each agent
  rr<-rep(0,12);rr[1]<-4;rr[2]<-0;rr[3]<-0;rr[4]<-2;rr[5]<-1;rr[6]<-1;rr[7]<-0;rr[8]<-1;rr[9]<-1;rr[10]<-0;rr[11]<-0;rr[12]<-0;
  
  #number of ecosystem hotspots in each agent
  #ee<-rep(0,12);ee[1]<-10;ee[2]<-2;ee[3]<-1;ee[4]<-7;ee[5]<-2;ee[6]<-12;ee[7]<-4;ee[8]<-5;ee[9]<-13;ee[10]<-2;ee[11]<-3;ee[12]<-3;
  ee<-rep(3,12)#temporary
  
  #number of HRU within each agent and subbasin
  hh<-matrix(rep(8,108),12)#12agents*9subbasins(max # of subbasins in an agent)=108
  
  sn=0#for continuous subbasin index
  hn=0#for continuous HRU index
  rn=0#for continuous resevior index
  for (a in aaa){#agent loop
    message<-paste("agent=",a)
    write(message,"")
    sss<-1:ss[a]#index for subbasin loop for specific agent "a"
    rrr<-1:rr[a]#index for reservior loop
    eee<-1:ee[a]#index for ecosystem hotspot loop
    
    for (s in sss){#subbasin loop
      sn=sn+1#which subbasin out of 47 model is currently on
      message<-paste("subbasin=",s)
      write(message,"")
      hhh<-1:hh[a,s]#index for HRU loop
      
      for (h in hhh){#HRU loop
        hn=hn+1#which HRU out of 376 model is currently on
        message<-paste("HRU=",h)
        write(message,"")

        if (h==1){#irrigated rice
          ####################################################
          #if-then-else decision making at the HRU level
          #if (cy < min_cy[hn]){irr.eff[hn] <- irr.eff[hn]*1.1} else {}
        
          #if (cprod < min_cprod[hn]){
          #  irr.eff[hn] <- irr.eff[hn]*1.1
          #  irice_area[sn] <- min(max_irice_area[sn],irice_area[sn]*1.1)
          #} else {}
        }
        if (hh==3){#irrigated upland crop
          #if (cy < min_cy[hn]){irr.eff[hn] <- irr.eff[hn]*1.1} else {}
          
          #if (cprod < min_cprod[hrn]){
          #  irr.eff[hn] <- irr.eff[hn]*1.1
          #  iupl_area[sn] <- min(max_iupl_area[sn],iupl_area[sn]*1.1)
          #} else {}
        }
        
      }#end HRU
    }#end subbasin
    if (rr[a]!=0){
      for (r in rrr){#reservoir loop
        rn=rn+1#which reservior out of 10 the model is currently on
        message<-paste("reservoir=",r)
        write(message,"")

      
        #####################################################
        #hydpow[rn] <- streamflow * drop_hydpow[rn]
      
        #if (hydpow[rn] < min_hydpow[rn]){
        #  resvol[rn] <- resvol[rn]*0.9 # if hydropower generated is less than the minimum constraint, release more water from reservoir storage
        #} else {}
  
      }#end reservoir
    }#end if !0
    
    for (e in eee){#ecosystem loop
      message<-paste("ecosystem=",e)
      write(message,"")
      
      
    }#end ecosystem
    
    #########################################################
    #save decision results for each agent
    
    
  }#end agent
  
  ############################################################################################################################
  ############################################################################################################################
  # Write ABM output (SWAT input) to data file
  ############################################################################################################################
  ############################################################################################################################
  
  res<-cbind(starg,ndtargr)
  land_area<-cbind(irice_area,rrice_area,iupl_area,rupl_area,forest_area,grass_area,urban_area,wetland_area)
  write.table(irr_eff,file="Irr_eff_by_R.txt",col.names = F, row.names = F)
  write.table(res,file="Reservoir_by_R.txt", col.names = F, row.names = F) 
  write.table(land_area,file="HRU_Area_by_R.txt", col.names = F, row.names = F) 
  
  file.create("SWAT_flag.txt")
  n<-n+1
}
