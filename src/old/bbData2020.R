#key libraries
library(dplyr)
library(reshape2)
library(lubridate)
library(ggplot2)

#upload data file
bb2020 <- read.csv("./data/raw/speedtest.csv")
#name columns
names(bb2020)[1:6] <- c("datetext","speeddown","speedup","provider","lat", "lon") 

str(bb2020)
summary(bb2020) #2030205 obs
#conversions needed to numeric? df$col <- as.numeric(df$col) 
#remove empty rows or coerced to NA? df[complete.cases(df),] or df <- df[!is.na(df$col),]

#remove outliers based on Riddlesden and Singleton 2014 for slower end
#check fastest upload and download speeds commercially available from Virgin Media (Gigaclear offers even faster!)
bb2020 <- bb2020[bb2020$speeddown>512,] 
bb2020 <- bb2020[bb2020$speeddown<362000,]
bb2020 <- bb2020[bb2020$speedup<21000,] #1839332 obs

#remove below seconds, create columns for date and hour
bb2020$datetext <- strtrim(x = bb2020$datetext, width = 19) 
bb2020$datetext2 <- bb2020$datetext
bb2020$datetext2 <- strtrim(x = bb2020$datetext2, width = 13)
bb2020$datetext2 <- colsplit(bb2020$datetext2, pattern = " ", c("date", "hour"))
bb2020$hour <- bb2020$datetext2$hour
bb2020$date <- bb2020$datetext2$date
#delete datetext2 column(s)
bb2020 <- bb2020[ ,c(1:6,8:9)]
#convert to date form datetext and date columns
bb2020$datetext <- as.POSIXct(strptime(bb2020$datetext, format = "%Y-%m-%d %H:%M:%S", "GMT")) 
bb2020$date <- as.POSIXct(strptime(bb2020$date, format = "%Y-%m-%d", "GMT"))

#add library to explore data temporally
library(openair)
#create dataframe with number of tests, mean and standard deviation by month for adding to dataframe later
MonthFreq <- timeAverage(bb2020, avg.time = "month", statistic = "frequency")
MonthMean <- timeAverage(bb2020, avg.time = "month", statistic = "mean")
MonthSD <- timeAverage(bb2020, avg.time = "month", statistic = "sd")
MonthStats <- cbind(MonthFreq[,1:2], MonthMean[,c(3:4)], 
                    MonthSD[,c(3:4)])
names(MonthStats) <- c("month", "monthlyTests", "monthlyMeanSpDown", 
                       "monthlyMeanSpUp", "monthlySDSpDown", 
                       "monthlySDSpUp")
MonthStats$month <- month(MonthStats$month, label = TRUE, abbr = TRUE)
#add column for month and day of the week to create stats below
bb2020$month <- month(bb2020$date, label = TRUE, abbr = TRUE)
bb2020$weekday <- wday(bb2020$date, label = TRUE)
#divide MonthStats for future join with separate 2019 and 2020 dataframes
MonthStats19 <- MonthStats[1:6,]
MonthStats20 <- MonthStats[13:17,]

#create 2 dataframes for 2 matching periods
Wks2019 <- selectByDate(bb2020, start = "2019-01-21", end = "2019-06-02")
names(Wks2019)[1:2] <- c("dateOnly", "date")
Wks2020 <- selectByDate(bb2020, start = "2020-01-20", end = "2020-05-31")
names(Wks2020)[1:2] <- c("dateOnly", "date")
#timeplots
TimeVar2019 <- timeVariation(Wks2019, pollutant = "speeddown", 
                        statistic = "mean", name.pol = "speedown 2019")
TimeVar2019up <- timeVariation(Wks2019, pollutant = "speedup",
                        statistic = "mean", name.pol = "speedup 2019")
TimeVar2020 <- timeVariation(Wks2020, pollutant = "speeddown", 
                        statistic = "mean", name.pol = "speeddown 2020")
TimeVar2020up <- timeVariation(Wks2020, pollutant = "speedup",
                        statistic = "mean", name.pol = "speedup 2020")
timePlot(Wks2019, pollutant = "speeddown", avg.time = "day", 
         smooth = TRUE, name.pol = "speeddown 2019")
timePlot(Wks2020, pollutant = "speeddown", avg.time = "day", 
         smooth = TRUE, name.pol = "speeddown 2020")
timePlot(Wks2019, pollutant = "speedup", avg.time = "day", 
         smooth = TRUE, name.pol = "speedup 2019")
timePlot(Wks2020, pollutant = "speedup", avg.time = "day", 
         smooth = TRUE, name.pol = "speedup 2020")
#add stats for each month: 
#test frequency, mean and standard deviation of speeddown and speedup
#note that Jan 2019, Jun 2019 and Jan 2020 inc WHOLE month in stats 
#weekends and nights included
Wks2019 <- left_join(Wks2019, MonthStats19)
Wks2020 <- left_join(Wks2020, MonthStats20)
#add stats for days of week, one set of stats with all hours 
#one set exc 00.00-06.00
WkdyCount19 <- count(Wks2019, weekday)
WkdyMeanSp19down <- summarise(group_by(Wks2019, weekday), mean(speeddown))
WkdyMeanSp19up <- summarise(group_by(Wks2019, weekday), mean(speedup))
WkdySDSp19down <- summarise(group_by(Wks2019, weekday), sd(speeddown))
WkdySDSp19up <- summarise(group_by(Wks2019, weekday), sd(speedup))
WkdyCount19ex <- count(Wks2019[which(Wks2019$hour != 0:5),], weekday)
WkdyMeanSp19downex <- summarise(group_by(Wks2019[which(Wks2019$hour 
                                != 0:5),], weekday), mean(speeddown))
WkdyMeanSp19upex <- summarise(group_by(Wks2019[which(Wks2019$hour
                                != 0:5),], weekday), mean(speedup))
WkdySDSp19downex <- summarise(group_by(Wks2019[which(Wks2019$hour 
                                != 0:5),], weekday), sd(speeddown))
WkdySDSp19upex <- summarise(group_by(Wks2019[which(Wks2019$hour 
                                != 0:5),], weekday), sd(speedup))
WkdyStats19 <- cbind(WkdyCount19ex, WkdyCount19[,2], 
                     WkdyMeanSp19downex[,2], WkdyMeanSp19down[,2],
                     WkdyMeanSp19upex[,2], WkdyMeanSp19up[,2],
                     WkdySDSp19downex[,2], WkdySDSp19down[,2],
                     WkdySDSp19upex[,2],WkdySDSp19up[,2])
names(WkdyStats19) <- c("weekday", "testsWkdyEx", "testsWkdy",
                        "MeanSpDownWkdyEx", "MeanSpDownWkdy", 
                        "MeanSpUpWkdyEx", "MeanSpUpWkdy", 
                        "SDSpDownWkdyEx", "SDSpDownWkdy", "SDSpUpWkdyEx", 
                        "SDSpUpWkdy")
Wks2019 <- left_join(Wks2019, WkdyStats19)
WkdyCount20 <- count(Wks2020, weekday)
WkdyMeanSp20down <- summarise(group_by(Wks2020, weekday), mean(speeddown))
WkdyMeanSp20up <- summarise(group_by(Wks2020, weekday), mean(speedup))
WkdySDSp20down <- summarise(group_by(Wks2020, weekday), sd(speeddown))
WkdySDSp20up <- summarise(group_by(Wks2020, weekday), sd(speedup))
WkdyCount20ex <- count(Wks2020[which(Wks2020$hour != 0:5),], weekday)
WkdyMeanSp20downex <- summarise(group_by(Wks2020[which(Wks2020$hour 
                                != 0:5),], weekday), mean(speeddown))
WkdyMeanSp20upex <- summarise(group_by(Wks2020[which(Wks2020$hour
                                != 0:5),], weekday), mean(speedup))
WkdySDSp20downex <- summarise(group_by(Wks2020[which(Wks2020$hour 
                                != 0:5),], weekday), sd(speeddown))
WkdySDSp20upex <- summarise(group_by(Wks2020[which(Wks2020$hour 
                                != 0:5),], weekday), sd(speedup))
WkdyStats20 <- cbind(WkdyCount20ex, WkdyCount20[,2], 
                     WkdyMeanSp20downex[,2], WkdyMeanSp20down[,2],
                     WkdyMeanSp20upex[,2], WkdyMeanSp20up[,2],
                     WkdySDSp20downex[,2], WkdySDSp20down[,2],
                     WkdySDSp20upex[,2],WkdySDSp20up[,2])
names(WkdyStats20) <- c("weekday", "testsWkdyEx", "testsWkdy",
                        "MeanSpDownWkdyEx", "MeanSpDownWkdy", 
                        "MeanSpUpWkdyEx", "MeanSpUpWkdy", 
                        "SDSpDownWkdyEx", "SDSpDownWkdy", "SDSpUpWkdyEx",
                        "SDSpUpWkdy")
Wks2020 <- left_join(Wks2020, WkdyStats20)
#add stats for hours of the day, 
#one set with those hours from all days included
#one set exc those hours on Sat-Sun
HrCount19 <- count(Wks2019, hour)
HrMeanSp19down <- summarise(group_by(Wks2019, hour), mean(speeddown))
HrMeanSp19up <- summarise(group_by(Wks2019, hour), mean(speedup))
HrSDSp19down <- summarise(group_by(Wks2019, hour), sd(speeddown))
HrSDSp19up <- summarise(group_by(Wks2019, hour), sd(speedup))
HrCount19ex <- count(Wks2019[which(Wks2019$weekday != "Sat" &
                                   Wks2019$weekday != "Sun"),], hour)
HrMeanSp19downex <- summarise(group_by(Wks2019[which(Wks2019$weekday 
                              != "Sat" & Wks2019$weekday != "Sun"),], 
                              hour), mean(speeddown))
HrMeanSp19upex <- summarise(group_by(Wks2019[which(Wks2019$weekday 
                              != "Sat" & Wks2019$weekday != "Sun"),], 
                              hour), mean(speedup))
HrSDSp19downex <- summarise(group_by(Wks2019[which(Wks2019$weekday 
                              != "Sat" & Wks2019$weekday != "Sun"),], 
                              hour), sd(speeddown))
HrSDSp19upex <- summarise(group_by(Wks2019[which(Wks2019$weekday 
                              != "Sat" & Wks2019$weekday != "Sun"),], 
                              hour), sd(speedup))
HrStats19 <- cbind(HrCount19ex, HrCount19[,2], 
                     HrMeanSp19downex[,2], HrMeanSp19down[,2],
                     HrMeanSp19upex[,2], HrMeanSp19up[,2],
                     HrSDSp19downex[,2], HrSDSp19down[,2],
                     HrSDSp19upex[,2],HrSDSp19up[,2])
names(HrStats19) <- c("hour", "testsHrEx", "testsHr",
                        "MeanSpDownHrEx", "MeanSpDownHr", 
                        "MeanSpUpHrEx", "MeanSpUpHr", 
                        "SDSpDownHrEx", "SDSpDownHr", "SDSpUpHrEx", 
                        "SDSpUpHr")
Wks2019 <- left_join(Wks2019, HrStats19)
HrCount20 <- count(Wks2020, hour)
HrMeanSp20down <- summarise(group_by(Wks2020, hour), mean(speeddown))
HrMeanSp20up <- summarise(group_by(Wks2020, hour), mean(speedup))
HrSDSp20down <- summarise(group_by(Wks2020, hour), sd(speeddown))
HrSDSp20up <- summarise(group_by(Wks2020, hour), sd(speedup))
HrCount20ex <- count(Wks2020[which(Wks2020$weekday != "Sat" &
                               Wks2020$weekday != "Sun"),], hour)
HrMeanSp20downex <- summarise(group_by(Wks2020[which(Wks2020$weekday 
                               != "Sat" & Wks2020$weekday != "Sun"),], 
                                       hour), mean(speeddown))
HrMeanSp20upex <- summarise(group_by(Wks2020[which(Wks2020$weekday 
                               != "Sat" & Wks2020$weekday != "Sun"),], 
                                     hour), mean(speedup))
HrSDSp20downex <- summarise(group_by(Wks2020[which(Wks2020$weekday 
                               != "Sat" & Wks2020$weekday != "Sun"),], 
                                     hour), sd(speeddown))
HrSDSp20upex <- summarise(group_by(Wks2020[which(Wks2020$weekday 
                                != "Sat" & Wks2020$weekday != "Sun"),], 
                                   hour), sd(speedup))
HrStats20 <- cbind(HrCount20ex, HrCount20[,2], 
                   HrMeanSp20downex[,2], HrMeanSp20down[,2],
                   HrMeanSp20upex[,2], HrMeanSp20up[,2],
                   HrSDSp20downex[,2], HrSDSp20down[,2],
                   HrSDSp20upex[,2],HrSDSp20up[,2])
names(HrStats20) <- c("hour", "testsHrEx", "testsHr",
                      "MeanSpDownHrEx", "MeanSpDownHr", 
                      "MeanSpUpHrEx", "MeanSpUpHr", 
                      "SDSpDownHrEx", "SDSpDownHr", "SDSpUpHrEx", 
                      "SDSpUpHr")
Wks2020 <- left_join(Wks2020, HrStats20)
#add daily stats - with and without 0:00-0:600
DateCount19 <- count(Wks2019, dateOnly)
DateSp19down <- summarise(group_by(Wks2019, dateOnly), mean(speeddown))
DateSp19up <- summarise(group_by(Wks2019, dateOnly), mean(speedup))
DateSDSp19down <- summarise(group_by(Wks2019, dateOnly), sd(speeddown))
DateSDSp19up <- summarise(group_by(Wks2019, dateOnly), sd(speedup))
DateCount19ex <- count(Wks2019[which(Wks2019$hour
                      != 0:5),], dateOnly)
DateSp19downEx <- summarise(group_by(Wks2019[which(Wks2019$hour
                      != 0:5),], dateOnly), mean(speeddown))
DateSp19upEx <- summarise(group_by(Wks2019[which(Wks2019$hour
                      != 0:5),], dateOnly), mean(speedup))
DateSDSp19downEx <- summarise(group_by(Wks2019[which(Wks2019$hour
                      != 0:5),], dateOnly), sd(speeddown))
DateSDSp19upEx <- summarise(group_by(Wks2019[which(Wks2019$hour
                      != 0:5),], dateOnly), sd(speedup))
DateStats19 <- cbind(DateCount19ex, DateCount19[,2], 
                   DateSp19downEx[,2], DateSp19down[,2],
                   DateSp19upEx[,2], DateSp19up[,2],
                   DateSDSp19downEx[,2], DateSDSp19down[,2],
                   DateSDSp19upEx[,2], DateSDSp19up[,2])
names(DateStats19) <- c("dateOnly", "test19ex", "tests19",
                      "MeanSpDownDateEx", "MeanSpDownDate", 
                      "MeanSpUpDateEx", "MeanSpUpDate", 
                      "SDSpDownDateEx", "SDSpDownDate", "SDSpUpDateEx", 
                      "SDSpUpDate")
Wks2019 <- left_join(Wks2019, DateStats19)
DateCount20 <- count(Wks2020, dateOnly)
DateSp20down <- summarise(group_by(Wks2020, dateOnly), mean(speeddown))
DateSp20up <- summarise(group_by(Wks2020, dateOnly), mean(speedup))
DateSDSp20down <- summarise(group_by(Wks2020, dateOnly), sd(speeddown))
DateSDSp20up <- summarise(group_by(Wks2020, dateOnly), sd(speedup))
DateCount20ex <- count(Wks2020[which(Wks2020$hour != 0:5),], dateOnly)
DateSp20downEx <- summarise(group_by(Wks2020[which(Wks2020$hour
                              != 0:5),], dateOnly), mean(speeddown))
DateSp20upEx <- summarise(group_by(Wks2020[which(Wks2020$hour
                                   != 0:5),], dateOnly), mean(speedup))
DateSDSp20downEx <- summarise(group_by(Wks2020[which(Wks2020$hour
                              != 0:5),], dateOnly), sd(speeddown))
DateSDSp20upEx <- summarise(group_by(Wks2020[which(Wks2020$hour
                            != 0:5),], dateOnly), sd(speedup))
DateStats20 <- cbind(DateCount20ex, DateCount20[,2], 
                     DateSp20downEx[,2], DateSp20down[,2],
                     DateSp20upEx[,2], DateSp20up[,2],
                     DateSDSp20downEx[,2], DateSDSp20down[,2],
                     DateSDSp20upEx[,2], DateSDSp20up[,2])
names(DateStats20) <- c("dateOnly", "test20ex", "tests20",
                        "MeanSpDownDateEx", "MeanSpDownDate", 
                        "MeanSpUpDateEx", "MeanSpUpDate", 
                        "SDSpDownDateEx", "SDSpDownDate", "SDSpUpDateEx", 
                        "SDSpUpDate")
Wks2020 <- left_join(Wks2020, DateStats20)
#frequency plot
Plot2019 <- ggplot(Wks2019, aes(dateOnly, tests19))
Plot2019 + geom_line()
Plot2020 <- ggplot(Wks2020, aes(dateOnly, tests20))
Plot2020 + geom_line()
HrDateCount19 <- count(Wks2019, dateOnly, hour)
HrDateCount20 <- count(Wks2020, dateOnly, hour)
names(HrDateCount19)[3] <- "testFreq19"
names(HrDateCount20)[3] <- "testFreq20"
Wks2019 <- left_join(Wks2019, HrDateCount19)
Wks2020 <- left_join(Wks2020, HrDateCount20)
TimeVar2019n <- timeVariation(Wks2019, pollutant = "testFreq19", 
                    statistic = "mean")
TimeVar2020n <- timeVariation(Wks2020, pollutant = "testFreq20", 
                              statistic = "mean")
#save files
write.csv(Wks2019, "Wks2019.csv")
write.csv(Wks2020, "Wks2020.csv")



