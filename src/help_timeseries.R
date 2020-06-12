library(workflows)
library(parsnip)
library(recipes)
library(yardstick)
library(glmnet)
library(tidyverse)
library(tidyquant)
library(timetk) # Use >= 0.1.3, remotes::install_github("business-science/timetk")
library(geojsonio)



# Add time series signature
bb2020test <- bb2020 %>% 
  select(datetext,speedup)
    
# Add time series signature
recipe_spec_timeseries <- recipe(speedup ~ ., data = bb2020test) %>%
  step_timeseries_signature(datetext) 

bb2020test_ <- bake(prep(recipe_spec_timeseries), new_data = bb2020test)
options(tibble.width = Inf) 
head(bb2020test_)

bb2020test_final <- recipe_spec_timeseries %>%
  step_rm(date) %>%
  step_rm(contains("iso"), 
          contains("second"), contains("minute"), contains("hour"),
          contains("am.pm"), contains("xts")) %>%
  step_normalize(contains("index.num"), date_year) %>%
  step_interact(~ date_month.lbl * date_day) %>%
  step_interact(~ date_month.lbl * date_mweek) %>%
  step_interact(~ date_month.lbl * date_wday.lbl * date_yday) %>%
  step_dummy(contains("lbl"), one_hot = TRUE) 

bake(prep(bb2020test_final), new_data = bb2020test_)

bake(prep(recipe_spec_final), new_data = train_tbl)

##########
# install.packages("devtools")
devtools::install_github("robjhyndman/anomalous-acm")
library(anomalousACM)

z <- ts(matrix(rnorm(3000),ncol=100),freq=4)
y <- tsmeasures(z)
biplot.features(y)
anomaly(y)

y_ <- tsmeasures(bb2020test$speedup)


########
# tsfeatures is the cran and advanced version of anomalousACM
library(tsfeatures)
ft <- tsfeatures(bb2020test$speedup)
head(ft)
dim(ft)
entropy(bb2020test$speedup)
stability(bb2020test$speedup)
lumpiness(bb2020test$speedup)
crossing_points(bb2020test$speedup)
length(bb2020test$speedup)
flat_spots(bb2020test$speedup)
hurst(bb2020test$speedup)
acf_features(bb2020test$speedup)

# reproducing Hyndman, Wang & Laptev (ICDM 2015)
yahoo <- yahoo_data()
head(yahoo)

hwl <- bind_cols(
  tsfeatures(yahoo,
             c("acf_features","entropy","lumpiness",
               "flat_spots","crossing_points")),
  tsfeatures(yahoo,"stl_features", s.window='periodic', robust=TRUE),
  tsfeatures(yahoo, "max_kl_shift", width=48),
  tsfeatures(yahoo,
             c("mean","var"), scale=FALSE, na.rm=TRUE),
  tsfeatures(yahoo,
             c("max_level_shift","max_var_shift"), trim=TRUE)) %>%
  select(mean, var, x_acf1, trend, linearity, curvature,
         seasonal_strength, peak, trough,
         entropy, lumpiness, spike, max_level_shift, max_var_shift, flat_spots,
         crossing_points, max_kl_shift, time_kl_shift)
head(hwl)


# Structured TS ----

# convert to spatial object
coords_bb <- cbind(bb2020$lon, bb2020$lat)
bb.la <- SpatialPointsDataFrame(coords_bb, data = data.frame(bb2020))
proj4string(bb.la) <- CRS("+init=epsg:4326") #define projection

# get LA 
la <- readOGR("http://geoportal1-ons.opendata.arcgis.com/datasets/b6d2e15801de45328b760a4f55d74318_0.geojson?outSR={%22latestWkid%22:3857,%22wkid%22:102100}")#, layer="OGRGeoJSON")
# from https://data.gov.uk/dataset/7c387c64-d25f-474a-b07e-b933578caea2/local-authority-districts-april-2019-boundaries-uk-bfe
la <- spTransform(la, CRS("+init=epsg:4326"))
la@data$LAD19NM <- as.character(la@data$LAD19NM)

# spatial join to LAD
bb.la.sp <- over(bb.la, la[, "LAD19NM"]) #not a spatial object
bb.la$LAD19NM <- bb.la.sp$LAD19NM

# create dataframe object to analyse (remove lat and lon?)
bb2020sp <- bb.la@data

# drop NAs
bb2020sp <- bb2020sp[!is.na(bb2020sp$LAD19NM),]
#13431/1839332 = .0073 NA LAD19NM, coord outside UK

# summarise by date and geography
la.date.count <- count(bb2020sp, LAD19NM, date)
la.dateAvg <- summarise(group_by(la.date.count, LAD19NM), mean(n))
range(la.dateAvg$`mean(n)`)

# map LA mean test frequency per date
la@data <- left_join(la@data, la.dateAvg, by = "LAD19NM")
var <- la@data[ ,'mean(n)']
breaks <- classIntervals(var, n = 5, style = "quantile")
my_colours <- brewer.pal(5, "Blues")
plot(la, col = my_colours[findInterval(var, breaks$brks, all.inside = TRUE)], axes = FALSE,
                 border = rgb(0.8, 0.8, 0.8, 0))

# new daily TS 
ts <- bb2020sp %>%
  group_by(date,LAD19NM) %>%
  summarise(mean.up = mean(speedup)) 

ggplot(ts, aes(x=as.numeric(date), y=mean.up, group = LAD19NM, colour = LAD19NM)) + # date as numeric??
  geom_line() + guides(colour=FALSE) + xlab("Date") +
  ylab("up load speed") +
  #geom_text_repel(aes(label=outlier.io), cex = 4) + #this line is from the previous version
  scale_y_continuous(labels = scales::comma) +
  scale_x_continuous(labels = scales::number_format(accuracy = 1))

# new sub-daily TS 
bb2020sp$block[bb2020sp$hour>=0 & bb2020sp$hour<8] <- 1
bb2020sp$block[bb2020sp$hour>=8 & bb2020sp$hour<16] <- 2
bb2020sp$block[bb2020sp$hour>=16 & bb2020sp$hour<24] <- 3

#bb2020sp$date.block <- paste(bb2020sp$date, bb2020sp$date.block, sep = "_")
# I use block as hour for the ts_wide()
bb2020sp$date.block = ymd_h(paste(bb2020sp$date, bb2020sp$block))
head(bb2020sp)

ts <- bb2020sp %>%
  group_by(date.block,LAD19NM) %>%
  summarise(mean.down = mean(speeddown))#, mean.down = mean(speeddown), n.tests = n())
sapply(ts, function(x) sum(is.na(x)))

hist(ts$n.tests)
summary(ts$n.tests)
# I am keeping all the obs. despite the n. of tests for now

# spagetti plot
ggplot(ts[ts$LAD19NM=="City of London",], 
       aes(x=as.POSIXct(date.block), y=mean.down, group = LAD19NM, colour = LAD19NM)) +
  geom_line() + guides(colour=FALSE) + ggtitle("City of London") + #xlab("") +
  ylab("download speed") +
  #geom_text_repel(aes(label=outlier.io), cex = 4) + #this line is from the previous version
  scale_y_continuous(labels = scales::comma) +
  scale_x_datetime(date_breaks = "1 month") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), axis.title.x = element_blank(),
        plot.title = element_text(hjust = 0.5))




# reproducing Hyndman, Wang & Laptev (ICDM 2015)
# long to wide
library(tsbox)
ts.wide <- ts_wide(ts)

# on our data
hwl.bb <- bind_cols(
  tsfeatures(ts.wide[,-1],
             c("acf_features","entropy","lumpiness",
               "flat_spots","crossing_points")),
  tsfeatures(ts.wide[,-1],"stl_features", s.window='periodic', robust=TRUE),
  tsfeatures(ts.wide[,-1], "max_kl_shift", width=48),
  tsfeatures(ts.wide[,-1],
             c("mean","var"), scale=FALSE, na.rm=TRUE),
  tsfeatures(ts.wide[,-1],
             c("max_level_shift","max_var_shift"), trim=TRUE)) %>%
  select(mean, var, x_acf1, trend, linearity, curvature,
   #     seasonal_strength, peak, trough,
         entropy, lumpiness, spike, max_level_shift, max_var_shift, flat_spots,
         crossing_points, max_kl_shift, time_kl_shift)
head(hwl.bb)

# remove nperiods and seasonal_period
#hwl.bb <- hwl.bb[,-(11:12)]

library(ggplot2)
hwl_pca <- hwl.bb %>%
  na.omit() %>%
  prcomp(scale=T)
hwl_pca$x %>%
  as_tibble() %>%
  ggplot(aes(x=PC1, y=PC2)) +
  geom_point()


library(babynames)
# Load dataset from github
data <- babynames %>% 
  filter(name %in% c("Mary","Emma", "Ida", "Ashley", "Amanda", "Jessica",    "Patricia", "Linda", "Deborah",   "Dorothy", "Betty", "Helen")) %>%
  filter(sex=="F")
head(data)

tmp <- data %>%
  mutate(name2=name)
head(tmp)
