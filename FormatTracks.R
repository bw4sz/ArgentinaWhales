#Clean Tracks
library(readxl)
library(dplyr)
library(stringr)
library(measurements)

tracks<-read_xlsx("ShipTracks.xlsx")
sheets<-excel_sheets("ShipTracks.xlsx")
allsheets<-lapply(sheets,function(x){
  dat<-read_xlsx("ShipTracks.xlsx")
  dat$Date<-x
  return(dat)
})

#bind together
allsheets<-bind_rows(allsheets)
#reformat to drop tracks
allsheets$Date<-str_match(allsheets$Date,"\\w+-\\w+-\\w+")

#format dates
allsheets$Date<-strptime(allsheets$Date,"%m-%d-%Y",tz="GMT")
allsheets$Date<-format(allsheets$Date,format="%m/%d/%Y")

#label as background
allsheets$species<-"Ship"

#format & convert GEO to deciminal degrees.
allsheets$new_Latitude = gsub('°', ' ', allsheets$Latitude)
allsheets$new_Longitude = gsub('°', ' ', allsheets$Longitude)

#negative
allsheets$new_Latitude = gsub('S', '-', allsheets$new_Latitude)
allsheets$new_Longitude = gsub('W', '-', allsheets$new_Longitude)

#convert 
allsheets$new_Latitude = measurements::conv_unit(allsheets$new_Latitude, from = 'deg_dec_min', to = 'dec_deg')
allsheets$new_Longitude = measurements::conv_unit(allsheets$new_Longitude, from = 'deg_dec_min', to = 'dec_deg')

#clean up the whale observations
whales<-read_xlsx("/Users/Ben/Dropbox/Whales/Argentina/Formatted.xlsx")
whales$Date<-strptime(whales$Date,"%Y-%m-%d",tz="GMT")
whales$Date<-format(whales$Date,format="%m/%d/%Y")

#time
whales$Time<-strptime(whales$`Time (local)`,"%Y-%m-%d %H:%M:%S",tz="Etc/GMT+3")

#long lat
whales$new_Latitude = gsub('°', ' ', whales$`Latitude (S)`)
whales$new_Longitude = gsub('°', ' ', whales$`Longitude (W)`)

#add in negatives
whales$new_Latitude<-paste("-",whales$new_Latitude,sep="")
whales$new_Longitude<-paste("-",whales$new_Longitude,sep="")

whales$new_Latitude = measurements::conv_unit(whales$new_Latitude, from = 'deg_dec_min', to = 'dec_deg')
whales$new_Longitude = measurements::conv_unit(whales$new_Longitude, from = 'deg_dec_min', to = 'dec_deg')

#convert
whales %>% select(Date,Time,Lat=new_Latitude,Long=new_Longitude)
#clean up dates
write.csv(allsheets,"ShipFormatted.csv")