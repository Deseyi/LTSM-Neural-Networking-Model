library (lubridate)
library (forecast)
library (zoo)
library (xts)
library (imputeTS)
library (tseries)

# ALWAYS USE / instead ofwhen defining path in R
path <- 'C:/Users/desey/Documents/MACHINE_LEARN'
setwd (path) # set working directory
getwd() # check the current working directory


#Reads data from a cs file,
j17 = read.csv ("j-17.csv")
comal = read.csv ('comal.csv')
san_marcos = read.csv('SanMarcos.csv')
X<-nrow(j17)
y<-nrow(comal)
Z<-nrow(san_marcos)


#Extract begin and end for j-17 dataset
endj <- as.Date(j17$DailyHighDate[1],format='%Y-%m-%d')
bgnj <- as.Date(j17$DailyHighDate[length(j17$DailyHighDate)],format='%Y-%m-%d')
datexj <- seq.Date(bgnj,endj,'day')
pdatexj <- as.Date(j17$DailyHighDate,format='%Y-%m-%d')


#Extract begin and end
bgnc <- as.Date(comal$datetime[1],format='%m/%d/%Y')
endc <- as.Date(comal$datetime[length(comal$datetime)],format='%m/%d/%Y')
datex <- seq.Date(bgnc,endc,'day')
pdatexc <- as.Date(comal$datetime,format='%m/%d/%Y')

#Extract begin and end
bgns <- as.Date(san_marcos$datetime[1],format='%m/%d/%Y')
ends <- as.Date(san_marcos$datetime[length(san_marcos$datetime)],format='%m/%d/%Y')
datexs <- seq.Date(bgns,ends,'day')
pdatexs <- as.Date(san_marcos$datetime,format='%m/%d/%Y')

#create a zoo object
WLzooj <- zoo(j17$WaterLevelElevation,pdatexs)
dum.zooj <-zoo(,datexs) #Dummy dataset with time alone
WLzoomj <- merge(dum.zooj,WLzooj)


#create a zoo object
WLzooc <- zoo(comal$Discharge,pdatexs)
dum.zooc <-zoo(,datexs) #Dummy dataset with time alone
WLzoomc <- merge(dum.zooc,WLzooc)




#create a zoo object
WLzoos <- zoo(san_marcos$Discharge,pdatexs)
dum.zoos <-zoo(,datexs) #Dummy dataset with time alone
WLzooms <- merge(dum.zoos,WLzoos)


#interpolate for missing waterlevel values
WL.tsj <- as.ts(WLzoomj) #convert to ts object of base R
WL.tsfj <- na_kalman(WL.tsj,model= "StructTS") #perform imputation
WL.zoofj <- zoo(WL.tsfj,datexs) #convert back to


#interpolate for missing waterlevel values
WL.tsc <- as.ts(WLzoomc) #convert to ts object of base R
WL.tsfc <- na_kalman(WL.tsc,model= "StructTS") #perform imputation
WL.zoofc <- zoo(WL.tsfc,datexs) #convert back to


#interpolate for missing waterlevel values
WL.tss <- as.ts(WLzooms) #convert to ts object of base R
WL.tsfs <- na_kalman(WL.tss,model= "StructTS") #perform imputation
WL.zoofs <- zoo(WL.tsfs,datex) #convert back to


plot(WL.zoofj, main='j17', xlab='Year',ylab='WaterLevel(ft)') 
plot(WL.zoofc, main='comal', xlab='Year',ylab='WaterLevel(ft)') 
plot(WL.zoofs, main='San_Marcos', xlab='Year',ylab='WaterLevel(ft)') 


#cross correlattion function
ccf(WL.zoofj, WL.zoofc)
ccf(WL.zoofj, WL.zoofs)
ccf(WL.zoofc, WL.zoofs)




