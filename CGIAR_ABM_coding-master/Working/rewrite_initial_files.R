
crop_hru <- read.table("Crop_initial.txt")
colnames(crop_hru) <- c("SB_ID","HRU_ID","AreaFrac","PlantDate","IrriHeat","Irri_TS","Irri_eff")

#%%%%%%%%%%%%%%%%
ag_sb <- read.csv("MK_Agent_Sub_basins0907.csv") %>% rename(SB_ID = Subbasin) #agent-subbasin relationship
cy_tar <- read.csv("Mean_Irrigated_rice_yield_by_subbasin.csv") %>% rename(SB_ID = subbasin) #target crop yields

sb_char <- read.csv("Subbasins_char.csv") %>% #obtain sub-basin characteristics such as area
  tbl_df() %>% 
  transmute(SB_ID=Subbasin,SB_Area_ha=Area) %>% 
  left_join(ag_sb,by="SB_ID") %>% #agent and sub-basin relationships
  left_join(crop_hru,by="SB_ID") %>% #cropping information for each hru
  left_join(cy_tar,by="SB_ID") %>% 
  select(Agent_ID,SB_ID,SB_Area_ha,HRU_ID,AreaFrac:Irri_eff,kg.ha) %>% 
  rename(tar_kg.ha = kg.ha)
#%%%%%%%%%%%%%

res_ini <- read.table(file="Reservoir_initial.txt")
  other_res <- res_ini[,1:5]
  starg <- res_ini[,6:17]
  ndtargr <- res_ini[,18]
  
  maxout <- matrix(rep(99999999999,nrow(res_ini)*12),nrow(res_ini))
  minout <- matrix(rep(0,nrow(res_ini)*12),nrow(res_ini))
  irr_minflow <- rep(0,nrow(sb_char))
  
  res<-cbind(other_res,starg,ndtargr,maxout,minout)
  irr_out<-cbind(crop_hru,irr_minflow)
  
  
  #test before overwriting
  #write.table(irr_out,file="Crop_initial_test.txt",col.names = F, row.names = F)
  
  #write.table(res,file="Reservoir_initial_test.txt", col.names = F, row.names = F) 
  
  write.table(irr_out,file="Crop_initial.txt",col.names = F, row.names = F)
  
  write.table(res,file="Reservoir_initial.txt", col.names = F, row.names = F) 
  
  

