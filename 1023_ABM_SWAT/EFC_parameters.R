
######only stream flow is necessary for EFC's (this should be a desirable (or historic) stream flow)

###### Streamflow 
flow_mekong <- read.table("Flow_Mekong.txt")
colnames(flow_mekong)[1:ncol(flow_mekong)] <- c("year","cal_day",paste0("Flow_SB_",1:(ncol(flow_mekong)-2)))
spinyear=2;#if zero then set to zero (used a bit later as well)
flow_mekong <- flow_mekong[flow_mekong$year>spinyear,]#remove the spinup years

######First step is to find stream flow for hotspots rather than for subbasins
ag_sb <- read.csv("MK_Agent_Sub_basins_v2.csv")
sbnum=nrow(ag_sb);#number of subbasins
hotnum=max(ag_sb$Hotspot_Number);#number of hotspots

hotflow<-data.frame(matrix(0,ncol = (hotnum+2), nrow = nrow(flow_mekong)));#contains the stream flow for each hotspot
hotflow[,1]=flow_mekong[,1];hotflow[,2]=flow_mekong[,2];
colnames(hotflow)[1:ncol(hotflow)]<-c("year","cal_day",paste0("Flow_HS_",1:(hotnum)));

for (h in 1:hotnum){
  countnum=0;
  for (s in 1:sbnum){
    if (ag_sb$Hotspot_Number[s]==h){
      countnum=countnum+1;#most hotspots are spread across multiple subbasins
      hotflow[,h+2]=hotflow[,h+2]+flow_mekong[,s+2];

    }
  }
  hotflow[,h+2]=hotflow[,h+2]/countnum #currently just taking average of all subbasins that contain the hotspot
}


######2nd step is to define for each hotspot what is a "high flow" and all else is considered a low flow for now -->determined by 75th percentile 
sevfifth=rep(0,hotnum);
for (h in 1:hotnum){
  sevfifth[h]<-quantile(hotflow[,h+2], .75)
}

highlow<-data.frame(matrix(0,ncol = (hotnum+2), nrow = nrow(flow_mekong)));#contains whether a flow is high or low flow
colnames(highlow)[1:ncol(highlow)]<-c("year","cal_day",paste0("highlow_HS_",1:(hotnum)));
highlow[,1]=flow_mekong[,1];highlow[,2]=flow_mekong[,2];

for (h in 1:hotnum){
  for (d in 1:nrow(highlow)){
    if (hotflow[d,h+2]>sevfifth[h]){
      highlow[d,h+2]="H";
    }
    if (hotflow[d,h+2]<=sevfifth[h]){
      highlow[d,h+2]="L";
    }
  }
}


######3 classes of high flows will be necessary:
######if the PEAK flow of a given high flow event is greater than the 10-year return interval then it is classified as a large flood, 
######if it is less than that but greater than the 2-year return interval then the event is classified as a small flood, 
######and if the high flow event is less than that, then it is classified as a high flow pulse
#!!!!!!!!!! this classification can be changed to be however we want to define a small or large flood (if we want to make it more frequent)

######-->thus need to define the 10-year return interval and the 2-year return interval of high flow events
######to do this the next step is to find the annual maximum of the peaks of high flow events
peaks<-data.frame(matrix(0,ncol = (hotnum+1), nrow = max(flow_mekong$year)-spinyear));#contains annual maximum peaks
colnames(peaks)[1:ncol(peaks)]<-c("year",paste0("MaxPeak_HS_",1:(hotnum)));
peaks[,1]<-c((spinyear+1):max(flow_mekong$year));

#cannot just find maximum of each year bc some years have no high flow events
for (h in 1:hotnum){
  for (d in 1:nrow(highlow)){
    y=highlow$year[d];
    if (highlow[d,h+2]=="H"){
      if (hotflow[d,h+2]>peaks[(y-spinyear),h+1]){
        peaks[(y-spinyear),h+1]<-hotflow[d,h+2];
      }
    }
  }
}

######now find 10 year and 2 year return "flood"
return10=rep(0,hotnum);return2=rep(0,hotnum);
for (h in 1:hotnum){
  return10[h]<-quantile(peaks[,h+1], .90);
  return2[h]<-quantile(peaks[,h+1], .50);
}

###### now to find monthly low flows for each hotspot
#defined by less than mean for that month

#make vectors for each month's flow

jan<-rep(0,hotnum);feb<-rep(0,hotnum);mar<-rep(0,hotnum);apr<-rep(0,hotnum);may<-rep(0,hotnum);jun<-rep(0,hotnum);
jul<-rep(0,hotnum);aug<-rep(0,hotnum);sep<-rep(0,hotnum);oct<-rep(0,hotnum);nov<-rep(0,hotnum);dec<-rep(0,hotnum);
for (h in 1:hotnum){
  jan[h]<-mean(hotflow[(hotflow$cal_day>=1)&(hotflow$cal_day<=31),h+2]);
  feb[h]<-mean(hotflow[(hotflow$cal_day>=32)&(hotflow$cal_day<=59),h+2]);
  mar[h]<-mean(hotflow[(hotflow$cal_day>=60)&(hotflow$cal_day<=90),h+2]);
  apr[h]<-mean(hotflow[(hotflow$cal_day>=91)&(hotflow$cal_day<=120),h+2]);
  may[h]<-mean(hotflow[(hotflow$cal_day>=121)&(hotflow$cal_day<=151),h+2]);
  jun[h]<-mean(hotflow[(hotflow$cal_day>=152)&(hotflow$cal_day<=181),h+2]);
  jul[h]<-mean(hotflow[(hotflow$cal_day>=182)&(hotflow$cal_day<=212),h+2]);
  aug[h]<-mean(hotflow[(hotflow$cal_day>=213)&(hotflow$cal_day<=243),h+2]);
  sep[h]<-mean(hotflow[(hotflow$cal_day>=244)&(hotflow$cal_day<=273),h+2]);
  oct[h]<-mean(hotflow[(hotflow$cal_day>=274)&(hotflow$cal_day<=304),h+2]);
  nov[h]<-mean(hotflow[(hotflow$cal_day>=305)&(hotflow$cal_day<=334),h+2]);
  dec[h]<-mean(hotflow[(hotflow$cal_day>=335)&(hotflow$cal_day<=365),h+2]);
}

######The final step is to determine what constitutes an extreme low flow ->tenth percentile of all daily LOW flows
for (h in 1:hotnum){
  assign(paste0("lowh",h),hotflow[(hotflow[,h+2]<sevfifth[h]),h+2]);
}

lows<-data.frame(matrix(0,ncol = (hotnum), nrow = length(lowh1)));#contains low flows only
colnames(lows)[1:ncol(lows)]<-c(paste0("Lows_HS_",1:(hotnum)));
for (h in 1:hotnum){
  data<-get(paste0("lowh",h))
  lows[,h]<-data;
}

xtremelow=rep(0,hotnum);
for (h in 1:hotnum){
  xtremelow[h]<-quantile(lows[,h], .10);
}


######Last step of PART 1 is to write out the EFC parameters necessary to constitute a small flow, a large flood, a high flood pulse and an extreme low flow
EFC_Param<-cbind(sevfifth,return10,return2,xtremelow,jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec);
colnames(EFC_Param)[1:ncol(EFC_Param)]<-c("high","large","small","xtremelow","jan","feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec");
write.csv(EFC_Param, file = "EFC_Param.csv");

