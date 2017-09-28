library(tidyr)
library(dplyr)


file.create("SWAT_flag.txt")
system("swat2012.exe",wait=FALSE,invisible=FALSE)
n<-1

while(n<22) #SWAT simulation period: 22 years
{
  while (file.exists("SWAT_flag.txt"))
  {
  }
  cat ("Press [enter] to continue") # these two lines are added so that you can check the format of the SWAT output files
  line <- readline()
  
  
  ###################################################################################
  #ABM output variables initialization (SWAT input variables)
  #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  nosb<-47;nohru<-376;nores<-10;#number of subbasins, hru's, reservoirs
  
  initcrops<-read.table("Crop_initial.txt",header = FALSE, sep = "")
  i_rice_area <- initcrops[,3][seq(1, length(initcrops[,3]), 8)]
  r_rice_area <- initcrops[,3][seq(2, length(initcrops[,3]), 8)]
  i_upl_area <- initcrops[,3][seq(3, length(initcrops[,3]), 8)]
  r_upl_area <- initcrops[,3][seq(4, length(initcrops[,3]), 8)]
  forest_area <- initcrops[,3][seq(5, length(initcrops[,3]), 8)]
  grass_area <- initcrops[,3][seq(6, length(initcrops[,3]), 8)]
  urban_area <- initcrops[,3][seq(7, length(initcrops[,3]), 8)]
  wetland_area <- initcrops[,3][seq(8, length(initcrops[,3]), 8)]
  
  #for now all hru's are initialized with same irr_eff and all reservoirs with the same starg and ndtargr so no need to extract data
  irr_eff<-vector(,nohru) 
  irr_eff[]<-0.5
  starg<-matrix(nrow=nores, ncol=12)
  starg[]<-99000
  ndtargr<-vector(,nores)
  ndtargr[]<-15
  
  
  #######################################################################################################
  #SWAT output variables (ABM input variables)
  #first two years of simulation are spin up --> lets read all data but extract for only the current simulation year
  #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  sflow<-read.table("Flow_Mekong.txt",header = FALSE, sep = "",)
  #Column 1: year (1-22)
  #Column 2: calendar day (1-365/366)
  #Column 3-49: flows in river reaches in subbasin 1-47 (m3/s)
  
  
  sres<-read.table("Reservoir_Mekong.txt",header = FALSE, sep = "",)
  #Column 1: year (1-22)
  #Column 2: calendar day (1-365/366)
  #Column 3-12: water volume (m3)
  #Column 13-22: water surface area (ha)
  #Column 23-32: outflow (m3/s)
  
  scrop<-read.table("Crop_Mekong.txt",header = FALSE, sep = "",)
  #Column 1: year (1-22)
  #Column 2: subbasin ID (1-47)
  #Column 3: HRU ID (1-8)
  #Column 4: yield (ton/yr)
  #Column 5: irrigation water withdrawal (m3)
  #-	Only the yields and water use for irrigated rice and irrigated upland crop HRU are exported. The values of the two quantities for other HRUs are set to zero. The crops in some subbasins in upper Mekong are zero due to the problem with temperature, which needs to be fixed in future
  #-	The results for most results are exported in all three files in an appending manner
  #-	A warming-up is required in SWAT simulation. the results for the first 2 or 3 years should be dropped
  

  ##################################################################################
  #Upper level constraints
  #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  #DoE
  #DoA
  #DoEnv
  
  
  ##################################################################################
  #Post-calculation for (From sWAT output) ecosystem services
  #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  
 
  
  #######################################################################################
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
  
  sbn=0#for subbasin index
  rvn=0#for resevior index
  for (a in aaa){#agent loop
    message<-paste("agent=",a)
    write(message,"")
    sss<-1:ss[a]#index for subbasin loop for specific agent "a"
    rrr<-1:rr[a]#index for reservior loop
    eee<-1:ee[a]#index for ecosystem hotspot loop
    
    for (s in sss){#subbasin loop
      sbn=sbn+1#which subbasin out of 47 model is currently on
      message<-paste("subbasin=",s)
      write(message,"")
      hhh<-1:hh[a,s]#index for HRU loop
      
      for (h in hhh){#HRU loop
        message<-paste("HRU=",h)
        write(message,"")
        
        ####################################################
        #if-then-else decision making at the HRU level
        #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        if (h==1){#irrigated rice
          
        } 
        if (h==3){#irrigated upland crop
          
        }
        
      }#end HRU
    }#end subbasin
    
    for (r in rrr){#reservoir loop
      message<-paste("reservoir=",r)
      write(message,"")
      rvn=rvn+1#which reservior out of 10 the model is currently on
    
      #####################################################
      #if-then-else decision making at the agent level
      #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
    }#end reservoir
    
    for (e in eee){#ecosystem loop
      message<-paste("ecosystem=",e)
      write(message,"")
    
      #####################################################
      #if-then-else decision making at the agent level
      #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
    }#end ecosystem
    
    #########################################################
    #save decision results for each agent
    #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  
    
  }#end agent
  
  
  ##############################################################
  #Write ABM output (SWAT input) to data file
  #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  res<-cbind(starg,ndtargr)
  land_area<-cbind(i_rice_area,r_rice_area,i_upl_area,r_upl_area,forest_area,grass_area,urban_area,wetland_area)
  write.table(irr_eff,file="Irr_eff_by_R.txt",col.names = F, row.names = F)
  write.table(res,file="Reservoir_by_R.txt", col.names = F, row.names = F) 
  write.table(land_area,file="Landclass_Area_by_R.txt", col.names = F, row.names = F) 
  
  
  #create flag after finishing writing data so SWAT will run next year
  file.create("SWAT_flag.txt")
  n<-n+1#year index
  
}#end year

#############################################
# wite decision results
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!



