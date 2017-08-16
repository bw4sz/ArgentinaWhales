#Clean Tracks
library(readxl)
library(dplyr)
library(stringr)
library(measurements)

tracks<-read_xlsx("ShipTracks.xlsx")
sheets<-excel_sheets("ShipTracks.xlsx")
datsheets<-lapply(sheets,function(x){
  print(x)
  allsheets<-read_xlsx("ShipTracks.xlsx",sheet=x)
  allsheets$Date<-x
  
  allsheets$Date<-str_match(allsheets$Date,"\\w+-\\w+-\\w+")
  allsheets<-allsheets[!is.na(allsheets$Date),]
  
  #format dates
  allsheets$Date<-strptime(allsheets$Date,"%m-%d-%Y",tz="GMT")
  allsheets$Date<-format(allsheets$Date,format="%m/%d/%Y")
  
  #label as background
  allsheets$Species<-"Ship"
  
  #format & convert GEO to deciminal degrees.
  allsheets$new_Latitude = gsub('°', ' ', allsheets$Latitude)
  allsheets$new_Longitude = gsub('°', ' ', allsheets$Longitude)
  
  #negative
  allsheets$new_Latitude = gsub('S', '-', allsheets$new_Latitude)
  allsheets$new_Longitude = gsub('W', '-', allsheets$new_Longitude)
  
  #convert 
  allsheets$new_Latitude = measurements::conv_unit(allsheets$new_Latitude, from = 'deg_dec_min', to = 'dec_deg')
  allsheets$new_Longitude = measurements::conv_unit(allsheets$new_Longitude, from = 'deg_dec_min', to = 'dec_deg')
  
  return(allsheets)
})

#bind together
allsheets<-bind_rows(datsheets)

#clean up the whale observations
whales<-read_xlsx("/Users/Ben/Dropbox/Whales/Argentina/Formatted.xlsx")
whales$Date<-strptime(whales$Date,"%Y-%m-%d",tz="GMT")
whales$Date<-format(whales$Date,format="%m/%d/%Y")

#time
whales$Time<-strptime(whales$`Time (local)`,"%Y-%m-%d %H:%M:%S",tz="Etc/GMT+3")

#long lat
whales$new_Latitude = gsub('°', ' ', whales$`Latitude (S)`)
whales$new_Longitude = gsub('°', ' ', whales$`Longitude (W)`)

#get the desired columns
whales<-whales %>% select(Date,Time,`Latitude (S)`,`Longitude (W)`,new_Latitude,new_Longitude,Species,GroupSize=`Group size`)

#add in negatives
whales$new_Latitude<-paste("-",whales$new_Latitude,sep="")
whales$new_Longitude<-paste("-",whales$new_Longitude,sep="")

whales$new_Latitude = measurements::conv_unit(whales$new_Latitude, from = 'deg_dec_min', to = 'dec_deg')
whales$new_Longitude = measurements::conv_unit(whales$new_Longitude, from = 'deg_dec_min', to = 'dec_deg')

#turn time to character
whales$Time<-format(whales$Time,"%H:%M:%S")
dat<-bind_rows(list(allsheets,whales))
dat$Lat<-round(as.numeric(dat$new_Latitude),14)
dat$Long<-round(as.numeric(dat$new_Longitude),14)

dat<-dat %>% select(Lat,Long,Date,Time,Species,GroupSize)

#convert
#clean up dates
write.csv(dat,"AllFormatted.csv")
