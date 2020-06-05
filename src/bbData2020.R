#key libraries
library(data.table)
library(dplyr)
library(reshape2)
library(lubridate)
library(openair)
library(ggplot2)
library(rgdal)
library(maptools)
library(sp)
library(rgeos)
library(tmap)
library(classInt)
library(RColorBrewer)

#upload data file
bb2020 <- fread("speedtest.csv") 
#name columns
names(bb2020)[1:6] <- c("datetext","speeddown","speedup","provider","lat", "lon") 

str(bb2020)
summary(bb2020) #2030205 obs
#conversions needed to numeric? df$col <- as.numeric(df$col) 
#remove empty rows or coerced to NA? df[complete.cases(df),] or df <- df[!is.na(df$col),]

#remove outliers based on Riddlesden and Singleton 2014
bb2020 <- bb2020[bb2020$speeddown<102400,]
bb2020 <- bb2020[bb2020$speeddown>512,] #1875325 obs 

#remove minutes and below from date and hour and split into 2 columns
bb2020$datetext <- strtrim(x = bb2020$datetext, width = 13) 
bb2020$datetext <- colsplit(bb2020$datetext, pattern = " ", c("datetext", "hour"))
bb2020$hour <- bb2020$datetext$hour
bb2020$date <- bb2020$datetext$datetext
#convert datetext to date and add date and hour columns to dataframe
bb2020$date <- as.POSIXct(strptime(bb2020$date, format = "%Y-%m-%d", "GMT")) 
#delete datetext column(s)
bb2020 <- bb2020[ ,2:8]

#add column for day of the week and year
bb2020$weekday <- wday(bb2020$date, label = TRUE)
bb2020 <- splitByDate(bb2020, dates = "1/1/2020", labels = c("2019", "2020"))
names(bb2020) [9] <- "Year"
bb2020$Year <- as.numeric(bb2020$Year)
Wks2019 <- selectByDate(bb2020, start = "2019-01-21", end = "2019-06-02")
Wks2020 <- selectByDate(bb2020, start = "2020-01-20", end = "2020-05-31")

#frequency per date
DateCount19 <- count(Wks2019, date)
names(DateCount19) <- c("Date19", "tests19")
HrCount19 <- count(Wks2019, date, hour)
HrSpeed19 <- summarise(group_by(Wks2019, date, hour), mean(speeddown))
HrStats19 <- left_join(HrCount19, HrSpeed19)
names(HrStats19) <- c("Date19", "Hour19", "test19", "meanSp19")
DateCount20 <- count(Wks2020, date)
names(DateCount20) <- c("Date20", "tests20")
HrCount20 <- count(Wks2020, date, hour)
HrSpeed20 <- summarise(group_by(Wks2020, date, hour), mean(speeddown))
HrStats20 <- left_join(HrCount20, HrSpeed20)
names(HrStats20) <- c("Date20", "Hour20", "test20", "meanSp20")
DateCount <- cbind(DateCount19, DateCount20)
HrStats <- cbind(HrStats19, HrStats20)
write.csv(DateCount, "DailyTestFreq.csv")
write.csv(HrStats, "HrTestFreqMean.csv")
Plot2019 <- ggplot(DateCount19, aes(Date19, tests19))
Plot2019 + geom_line()
Plot2020 <- ggplot(DateCount20, aes(Date20, tests20))
Plot2020 + geom_line()

#timeplots per date
calendarPlot(bb2020, pollutant = "speeddown", year = 2019, statistic = "mean")
calendarPlot(bb2020, pollutant = "speeddown", year = 2020, statistic = "mean")
timePlot(Wks2019, pollutant = "speeddown", avg.time = "day", smooth = TRUE)
timePlot(Wks2020, pollutant = "speeddown", avg.time = "day", smooth = TRUE)
timeVariation(Wks2019, pollutant = "speeddown", statistic = "mean")


#convert to spatial object
coords_bb <- cbind(bb2020$lon, bb2020$lat)
bbNUTS3 <- SpatialPointsDataFrame(coords_bb, data = data.frame(bb2020))
proj4string(bbNUTS3) <- CRS("+init=epsg:4326") #define projection

#get NUTS3 from up a level and read in (145 NUTS3)
NUTS3 <- readOGR("../NUTS_Level_3_January_2015_Super_Generalised_Clipped_Boundaries_in_England_and_Wales.shp") 
NUTS3 <- spTransform(NUTS3, CRS("+init=epsg:4326"))                                
NUTS3@data$nuts315nm <- as.character(NUTS3@data$nuts315nm)

#spatial join to NUTS3
bbNUTS3sp <- over(bbNUTS3, NUTS3[, "nuts315nm"]) #not a spatial object
bbNUTS3$nuts315nm <- bbNUTS3sp$nuts315nm

#create dataframe object to analyse (remove lat and lon?)
bb2020sp <- bbNUTS3@data
#% obs NA for NUTS3?

#summarise by date and geography
NUTS3datecount <- count(bb2020sp, nuts315nm, date)
NUTS3dateAvg <- summarise(group_by(NUTS3datecount, nuts315nm), mean(n))

#map NUTS3 mean test frequency per date
NUTS3@data <- left_join(NUTS3@data, NUTS3dateAvg, by = "nuts315nm")
var <- NUTS3@data[ ,'mean(n)']
breaks <- classIntervals(var, n = 5, style = "quantile")
my_colours <- brewer.pal(5, "Blues")
plot(NUTS3, col = my_colours[findInterval(var, breaks$brks, all.inside = TRUE)], axes = FALSE,
     border = rgb(0.8, 0.8, 0.8, 0))
legend(x = "top", legend = leglabs(breaks$brks), fill = my_colours, bty = "n", cex = 0.5)

