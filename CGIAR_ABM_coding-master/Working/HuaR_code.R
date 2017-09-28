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
  
  #insert your code here-read output files from SWAT and make changes to management parameters
  irr_eff<-vector(,376) #assign values to irrigation efficieny
  irr_eff[]<-0.8
  starg<-matrix(nrow=10, ncol=12)
  starg[]<-99000
  ndtargr<-vector(,10)
  ndtargr[]<-15
  x<-cbind(starg,ndtargr)
  
  # write new managment parameters to files
  write.table(irr_eff,file="Irr_eff_by_R.txt",col.names = F, row.names = F)
  write.table(x,file="Reservoir_by_R.txt", col.names = F, row.names = F) 
  
  file.create("SWAT_flag.txt")
  n<-n+1
}