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
  
  crop_ini<-read.table("Crop_initial.txt",header = FALSE, sep = "")
  colnames(crop_ini) <- c("SB_ID","HRU_ID","Area","PlantDate","PotIrri","Irri_TS","Irri_eff")
  irice_area <- crop_ini[,3][seq(1, length(crop_ini[,3]), 8)]
  rrice_area <- crop_ini[,3][seq(2, length(crop_ini[,3]), 8)]
  iupl_area <- crop_ini[,3][seq(3, length(crop_ini[,3]), 8)]
  rupl_area <- crop_ini[,3][seq(4, length(crop_ini[,3]), 8)]
  forest_area <- crop_ini[,3][seq(5, length(crop_ini[,3]), 8)]
  grass_area <- crop_ini[,3][seq(6, length(crop_ini[,3]), 8)]
  urban_area <- crop_ini[,3][seq(7, length(crop_ini[,3]), 8)]
  wetland_area <- crop_ini[,3][seq(8, length(crop_ini[,3]), 8)]
  irr_eff <- crop_ini[,7]
  
  res_ini <- read.table(file="Reservoir_initial.txt")
  starg <- res_ini[,4:17]
  ndtargr <- res_ini[,18]


  
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
  #min_starg: this will be a dataframe that provides a minimum constraint on reservoir target storage
  #max_starg: this will be a dataframe that provides a maxmum constraint (capacity) on reservoir target storage
  #min_ndtargr: this will be a dataframe that provides a minimum number of days to reach target storage
  #min_wetstor: this will be a dataframe that provides a minimum constraint on wetland storage
  #max_wetstor: this will be a dataframe that provides a maxmum constraint on wetland storage (might need for very wet years?, might not be necessary if consistently drying)
  
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
          if (cy[hn] < min_cy[hn]){irr.eff[hn] <- irr.eff[hn]*1.1} else {}
             eff_cost[hn] <- (irr.eff*.1)*costfactor #cost of changing irr_eff should be recorded
          
          if (cprod[hn] < min_cprod[hn]){
            irr.eff[hn] <- irr.eff[hn]*1.1
            eff_cost[hn] <- (irr.eff[hn]*.1)*costfactor #cost of changing irr_eff should be recorded
            change_area <- min(max_irice_area[sn],irice_area[sn]*1.1)-irice_area[sn]#area added to irice must be taken from another HRU
            irice_area[sn] <- min(max_irice_area[sn],irice_area[sn]*1.1)
            
            #which HRU's the additional crop area is taken from (weights add to 1) should depend on survey?
            rrice_area[sn] <- rrice_area[sn]-change_area*weight1
            rupl_area[sn] <- rupl_area[sn]-change_area*weight2
            forest_area[sn] <- forest_area[sn]-change_area*weight3
            grass_area[sn] <- grass_area[sn]-change_area*weight4
            #urban_area <- probably can't take from urban?
            #wetland_area <- probably don't want to take from wetland?
            
          } else {}
        }
        if (hh==3){#irrigated upland crop
          if (cy[hn] < min_cy[hn]){irr.eff[hn] <- irr.eff[hn]*1.1} else {}
          
          if (cprod[hn] < min_cprod[hn]){
            irr.eff[hn] <- irr.eff[hn]*1.1
            eff_cost[hn] <- (irr.eff[hn]*.1)*costfactor #cost of changing irr_eff should be recorded
            change_area <- min(max_iupl_area[sn],iupl_area[sn]*1.1)-iupl_area[sn]#area added to irice must be taken from another HRU
            iupl_area[sn] <- min(max_iupl_area[sn],iupl_area[sn]*1.1)
            
            #which HRU's the additional crop area is taken from (weights add to 1) should depend on survey?
            rrice_area[sn] <- rrice_area[sn]-change_area*weight1
            rupl_area[sn] <- rupl_area[sn]-change_area*weight2
            forest_area[sn] <- forest_area[sn]-change_area*weight3
            grass_area[sn] <- grass_area[sn]-change_area*weight4
            #urban_area <- probably can't take from urban?
            #wetland_area <- probably don't want to take from wetland?
 
          } else {}
        }
        
      }#end HRU
    }#end subbasin
    if (rr[a]!=0){
      for (r in rrr){#reservoir loop
        rn=rn+1#which reservior out of 10 the model is currently on
        message<-paste("reservoir=",r)
        write(message,"")

        #####################################################
        if (starg[rn] > max_starg[rn]){
          starg[rn] <- min(starg[rn]*0.9,max_starg[rn])
        } else{}
        
        if (starg[rn] < min_starg[rn]){
          starg[rn] <- max(min_starg[rn],starg[rn]*1.1)
        } else{}
        
        #which of these two (min storage/hydropower) takes priority based on survey results? for the agent containing the reservoir
        
        hydpow[rn] <- streamflow * drop_hydpow[rn]
      
        if (hydpow[rn] < min_hydpow[rn]){
          if (starg[rn]*.9 > min_starg[rn]){
            starg[rn] <- starg[rn]*0.9# if hydropower generated is less than the minimum constraint, release more water from reservoir storage
            
          }else{#if dropping storage drops it below minimum storage instead decrease number of target days at storage
            ndtargr[rn] <- max(ndtargr[rn]-2,min_ndtargr[rn])
          }
          #if hydropower is still less than min, may want to repeat these loops until at min_starg and min_ndtargr? 
          #(change "if" hydrow< to "while" and include: & > starg ndtargr minimums)
          
        } else {}

  
      }#end reservoir
    }#end if !0
    
    for (e in eee){#ecosystem loop
      message<-paste("ecosystem=",e)
      write(message,"")
      
      if (e==?){#wetlands
        if (wetstor[a] < min_wetstor[a]){#probably indexed by agent as ecosystem services are specific to agent in survey
          #options(these may apply to a variety of ecosystem services):
          #lower reservoir volume upstream?
          #decrease maximum allowable water withdrawl?
          #increase Minimum allowable flow in river reach (m3/s)?
          
        }else if (wetstor[a] > max_wetstor[a]){
          #optons: 
          #increase target volume upstream (may affect hydropower minimum)?
          #increase maximum allowable water widthdrawl?
          #decrease Minimum allowable flow in river reach (m3/s)?
          
        }
      }
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