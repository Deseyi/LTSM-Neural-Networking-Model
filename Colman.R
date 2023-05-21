library(zoo)
library(xts)
library(imputeTS)

#set working directory
path <- 'C:/Users/desey/Documents/MACHINE_LEARN'
setwd(path)
getwd()

#read in data
a <- read.csv('comal.csv')

#Extract begin and end
bgn <- as.Date(a$datetime[1],format='%m/%d/%Y')
end <- as.Date(a$datetime[length(a$datetime)],format='%m/%d/%Y')
datex <- seq.Date(bgn,end,'day')
pdatex <- as.Date(a$datetime,format='%m/%d/%Y')

#Check to see if there are missing values
theo <- length(datex)
actu <- length(a$Discharge)
if(theo>actu)print("missing value")

#create a zoo object
WLzoo <- zoo(a$Discharge,pdatex)
dum.zoo <-zoo(,datex) #Dummy dataset with time alone
WLzoom <- merge(dum.zoo,WLzoo)
plot(WLzoom,xlab='Year',ylab='Discharge') #see if there are any visible periods of missing records
summary(WLzoom) #check how many NAs

#interpolate for missing waterlevel values
WL.ts <- as.ts(WLzoom) #convert to ts object of base R
WL.tsf <- na_kalman(WL.ts,model= "StructTS") #perform imputation
WL.zoof <- zoo(WL.tsf,datex) #convert back to
plot(WL.zoof,xlab='Year',ylab='Discharge') #see if there are any visible periods of missing records
summary(WL.zoof)

#perform 10-day moving average
WL10d <- rollmean(WL.zoof,10,align='right')
plot(WL10d,xlab='Year',ylab='Discharge') #see if there are any visible periods of missing records
summary(WL10d)

#aggregate to monthly values using mean
WLmon <- apply.monthly(as.xts(WL.zoof),mean) #function in xts
plot(WLmon,xlab='Year',ylab='Discharge') #see if there are any visible periods of missing records
summary(WLmon)

#calculate autocorrelation 
acf(WL.zoof,lag.max=NULL,main='ACF for Colman', type = c('correlation'))
pacf(WL.zoof,main='P.Auto.Cor.Fun COlman',type="o")

#Decompose time series
a <- ts(WLmon, frequency = 12)
deco <- decompose(a)
plot(deco)